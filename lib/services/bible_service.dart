import 'dart:convert';
import 'package:flutter/services.dart';
import 'database_helper.dart';

class BibleService {
  Future<Map<String, dynamic>> loadBible(String version) async {
    String path = 'assets/bible/$version.json';
    String data = await rootBundle.loadString(path);
    return json.decode(data);
  }

  Future<void> insertBibleData(Map<String, dynamic> bibleData, String version) async {
    final dbHelper = DatabaseHelper();
    for (var book in bibleData.keys) {
      for (var chapter in bibleData[book].keys) {
        for (var verse in bibleData[book][chapter]) {
          await dbHelper.insertVerse({
            'book': book,
            'chapter': chapter,
            'verse': verse['verse'],
            'text': verse['text'],
            'version': version,
          });
        }
      }
    }
  }
}
