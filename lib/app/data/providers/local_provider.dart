import 'package:get_storage/get_storage.dart';

class LocalProvider {
  static final GetStorage _storage = GetStorage();

  static Future<void> saveData(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  static T? getData<T>(String key) {
    return _storage.read<T>(key);
  }

  static Future<void> removeData(String key) async {
    await _storage.remove(key);
  }

  static Future<void> clearAll() async {
    await _storage.erase();
  }
}
