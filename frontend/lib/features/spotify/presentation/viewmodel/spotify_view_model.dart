import 'package:clean_spotify_connec/core/shared_pref/user_shared_prefs.dart';
import 'package:clean_spotify_connec/features/spotify/data/data_source/spotify_remote_data_source.dart';
import 'package:clean_spotify_connec/features/spotify/presentation/state/spotify_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final spotifyViewModelProvider =
    StateNotifierProvider<SpotifyViewModel, SpotifyState>((ref) {
  final photoDataSource = ref.read(spotifyRemoteDatasourceProvider);
  final userSharedPrefs = ref.read(userSharedPrefsProvider);
  return SpotifyViewModel(photoDataSource, userSharedPrefs);
});

class SpotifyViewModel extends StateNotifier<SpotifyState> {
  final SpotifyRemoteDataSource _spotifyRemoteDataSource;
  final UserSharedPrefs userSharedPrefs;

  SpotifyViewModel(this._spotifyRemoteDataSource, this.userSharedPrefs)
      : super(SpotifyState.initial());

  Future resetState() async {
    state = SpotifyState.initial();
  }

  Future<void> sendPrompt(String prompt) async {
    state = state.copyWith(isLoading: true);
    _spotifyRemoteDataSource.postPrompt(prompt).then((value) {
      value.fold(
          (failure) => state = state.copyWith(
              showMessage: true,
              isLoading: false,
              isError: true,
              message: failure.error), (success) {
        state = state.copyWith(
            isLoading: false,
            showMessage: true,
            message: "Playlist created sucessfully");
      });
    });
  }
}
