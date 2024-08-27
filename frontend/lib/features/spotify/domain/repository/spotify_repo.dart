import 'package:clean_spotify_connec/core/failure/failure.dart';
import 'package:clean_spotify_connec/features/spotify/data/data_source/spotify_remote_data_source.dart';
import 'package:clean_spotify_connec/features/spotify/data/repository/spotify_repo_interface.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final spotifyRemoteRepositoryProvider =
    Provider.autoDispose<ISpotifyRepository>(
  (ref) => SpotifyRemoteRepoImpl(
      spotifyRemoteDataSource: ref.read(spotifyRemoteDatasourceProvider)),
);

class SpotifyRemoteRepoImpl implements ISpotifyRepository {
  final SpotifyRemoteDataSource spotifyRemoteDataSource;
  const SpotifyRemoteRepoImpl({required this.spotifyRemoteDataSource});
 

  @override
  Future<Either<Failure,  bool>> postPrompt(String prompt) {
    return spotifyRemoteDataSource.postPrompt(prompt);
  }
}
