import 'dart:async';
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:clean_spotify_connec/config/constants/api_endpoints.dart';
import 'package:clean_spotify_connec/core/failure/failure.dart';
import 'package:clean_spotify_connec/core/networking/http_service.dart';
import 'package:clean_spotify_connec/core/shared_pref/user_shared_prefs.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

String generateRandomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}

final spotifyRemoteDatasourceProvider =
    Provider.autoDispose<SpotifyRemoteDataSource>(
  (ref) => SpotifyRemoteDataSource(
    dio: ref.read(httpServiceProvider),
    userSharedPrefs: ref.read(userSharedPrefsProvider),
  ),
);

class SpotifyRemoteDataSource {
  final Dio dio;
  final UserSharedPrefs userSharedPrefs;

  StreamSubscription? _sub;
  SpotifyRemoteDataSource({
    required this.userSharedPrefs,
    required this.dio,
  });

  void dispose() {
    _sub?.cancel();
  }

  Future<Either<Failure, String>> createPlaylist(
      String accessToken, String userId, String playlistName) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.spotify.com/v1/users/$userId/playlists'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': playlistName,
          'description': 'New playlist created via playlist app',
          'public': false,
        }),
      );

      if (response.statusCode == 201) {
        final playlist = jsonDecode(response.body);
        // print('Created Playlist ID: ${playlist['id']}');
        return Right(playlist['id']);
      } else {
        // print(response);
        // print('Failed to create playlist: ${response.statusCode} ');
        return Left(Failure(
            error: 'Failed to create playlist: ${response.statusCode}'));
      }
    } catch (e) {
      // print('Error creating playlist: $e');
      return Left(Failure(error: 'Error creating playlist: $e'));
    }
  }

  Future<Either<Failure, bool>> addTracksToPlaylist(
      String accessToken, String playlistId, List<String> trackUris) async {
    try {
      Map<String, dynamic> payload = {
        'uris': trackUris,
      };

      final response = await http.post(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left(
            Failure(error: 'Failed to add tracks: ${response.statusCode}'));
      }
    } catch (e) {
      return Left(Failure(error: 'Error adding tracks: $e'));
    }
  }

  Future<Either<String, bool>> loginWithSpotify(
      List<String> trackUris, String playlistName) async {
    try {
      String clientId = "c124d7424f22461893354226af2d2e17";
      String clientSecret = "5a98a721835d40dfae5536e76d6234ab";

      final result = await FlutterWebAuth.authenticate(
        url:
            'https://accounts.spotify.com/authorize?client_id=$clientId&response_type=code&redirect_uri=myapp://callback&scope=user-read-private%20user-read-email%20playlist-modify-public%20playlist-modify-private',
        callbackUrlScheme: 'myapp',
      );

      final code = Uri.parse(result).queryParameters['code'];

      if (code != null) {
        final response = await http.post(
          Uri.parse('https://accounts.spotify.com/api/token'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': 'myapp://callback',
            'client_id': clientId,
            'client_secret': clientSecret,
          },
        );

        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final accessToken = responseBody['access_token'];

        if (accessToken != null) {
          userSharedPrefs.setAcessToken(accessToken);
          userSharedPrefs.setRefreshToken(responseBody['refresh_token']);

          String id = await getUserId(accessToken);
          if (id != "failed") {
            final playlistResult =
                await createPlaylist(accessToken, id, playlistName);
            return playlistResult.fold(
              (failure) => Left(failure.error),
              (playlistId) async {
                final addTracksResult = await addTracksToPlaylist(
                    accessToken, playlistId, trackUris);
                return addTracksResult.fold(
                  (failure) => Left(failure.error),
                  (success) {
                    _openPlaylist(playlistId);
                    return const Right(true);
                  },
                );
              },
            );
          } else {
            return const Left("Failed to retrieve user ID.");
          }
        } else {
          return const Left("Failed to retrieve access token.");
        }
      } else {
        return const Left("Authorization code not found in URI.");
      }
    } catch (e) {
      return Left("Error during Spotify login: $e");
    }
  }

  Future<void> _openPlaylist(String playlistId) async {
    final Uri spotifyUri = Uri.parse('spotify:playlist:$playlistId');
 

    try {
      if (await canLaunchUrl(spotifyUri)) {
        // print('Trying to launch Spotify URI...');
        await launchUrl(spotifyUri, mode: LaunchMode.externalApplication);
      } else {
        // print('Spotify URI not supported, trying web URL...');
        await launchUrl(spotifyUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // print('Error launching URL: $e');
    }
  }

  Future<String> getUserId(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        final userProfile = jsonDecode(response.body);
        userSharedPrefs.setUserId(userProfile['id']);
        return userProfile['id'];
      } else {
        return "failed";
      }
    } catch (e) {
      return "failed";
    }
  }

  Future<Either<Failure, bool>> postPrompt(String prompt) async {
    try {
      var response = await dio.post(
        ApiEndpoints.listPlaylist,
        data: {"description": prompt},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data != null && response.data.isNotEmpty) {
        // print('response.data type: ${response.data.runtimeType}');

        List<String> data =
            response.data.map<String>((item) => item.toString()).toList();

        loginWithSpotify(data, prompt).then((value) => {
              value.fold((error) {
                Left(Failure(error: error));
              }, (success) {
                const Right(true);
              })
            });
        return const Right(true);
      } else {
        return Left(Failure(
            error: "Failed to load playlist",
            statusCode: response.statusCode.toString()));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return Left(Failure(
            error: 'API connection error',
            statusCode: e.response!.statusCode.toString()));
      } else {
        // print(e);
        return Left(Failure(error: "API connection error", statusCode: "400"));
      }
    }
  }
}
