// lib/data/repositories/cache_repo.dart
import 'package:shared_preferences/shared_preferences.dart';

abstract class CacheRepo {
  Future<void> save(String key, String value);
  Future<String?> get(String key);
  Future<void> remove(String key);
}

class CacheRepoImpl implements CacheRepo {
  final SharedPreferences _prefs;

  CacheRepoImpl(this._prefs);

  @override
  Future<void> save(String key, String value) => _prefs.setString(key, value);

  @override
  Future<String?> get(String key) async => _prefs.getString(key);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}