import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class DataStorage {
	static Future<String> get _localPath async {
		final directory = await getApplicationDocumentsDirectory();

		return directory.path;
	}

	static Future<File> get _localFile async {
		final path = await _localPath;

		return File('$path/data.json');
	}

	static Future<String> readData() async {
		try {
			final file = await _localFile;

			return await file.readAsString();
		} catch (e) {
			return '';
		}
	}

	static Future<File> writeData(String data) async {
		final file = await _localFile;

		return file.writeAsString(data);
	}

	static Future<bool> fileExists() async {
		final file = await _localFile;
		
		return await file.exists();
	}

	static Future<File> createFile() async {
		final file = await _localFile;
		
		return await file.create();
	}
}