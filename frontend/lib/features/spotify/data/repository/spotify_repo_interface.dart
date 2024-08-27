import 'package:clean_spotify_connec/core/failure/failure.dart';
import 'package:clean_spotify_connec/features/spotify/domain/repository/spotify_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final spotifyRepositoryProvider =
    Provider.autoDispose<ISpotifyRepository>((ref) {
  return ref.read(spotifyRemoteRepositoryProvider);
});

abstract class ISpotifyRepository {

  Future<Either<Failure, bool>> postPrompt(String prompt);
}
