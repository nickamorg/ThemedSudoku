import 'package:audioplayers/audioplayers.dart';

class AudioPlayer {
	static AudioCache player = AudioCache();
    static bool isAudioEnabled = true;

	static play(String fileName) {
		if (isAudioEnabled) player.play(fileName);
	}
}

class AudioList {
	static const String WRONG_ANSWER = 'audio/wrong_answer.mp3';
	static const String CORRECT_ANSWER = 'audio/correct_answer.mp3';
    static const String WIN = 'audio/win.mp3';
}