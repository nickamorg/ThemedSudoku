const List<String> THEMES = ['emoji', 'vegetables', 'fruit', 'emoji', 'vegetables', 'fruit', 'emoji', 'vegetables', 'fruit'];

String getDurationInTime(int seconds) {
    final now = Duration(seconds: seconds);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(now.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(now.inSeconds.remainder(60));
    return '${twoDigits(now.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
}