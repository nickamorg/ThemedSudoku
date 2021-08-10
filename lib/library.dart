const List<String> THEMES = ['colors', 'elements', 'emoji', 'fruit', 'numbers', 'planets', 'sweets', 'vegetables', 'zombies'];

String getDurationInTime(int seconds) {
    final now = Duration(seconds: seconds);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(now.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(now.inSeconds.remainder(60));
    return '${twoDigits(now.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
}

String themeTrim(idx) {
    String str = THEMES[idx][0].toUpperCase() + THEMES[idx].substring(1);
    if (str[str.length - 1] == 's') return str.substring(0, str.length - 1);
    return str;
}