class SpotifyState {
  final bool isLoading;
  final bool showMessage;
  final String? message;
  final bool isError;

  const SpotifyState(
      {required this.isLoading, this.message, required this.showMessage, required this.isError});

  factory SpotifyState.initial() {
    return const SpotifyState(
        isLoading: false, message: "", showMessage: false, isError: false);
  }

  SpotifyState copyWith({bool? isLoading, String? message, bool? showMessage, bool? isError}) {
    return SpotifyState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      showMessage: showMessage ?? this.showMessage,
      isError: isError ?? this.isError
    );
  }
}
