import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  late Box _box;

  DatabaseHelper._internal();

  Future<void> initialize() async {
    _box = await Hive.openBox('bibleBox');
  }

  Future<bool> isDatabaseEmpty() async {
    return _box.isEmpty;
  }

  Future<void> insertVerse(Map<String, dynamic> verse) async {
    await _box.add(verse);
  }

  Future<List<Map<String, dynamic>>> getVerses() async {
    return _box.values.toList().cast<Map<String, dynamic>>();
  }
}