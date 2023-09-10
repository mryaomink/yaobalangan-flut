import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static const String authTokenKey = 'yaotoken';

  // Menyimpan token ke shared_preferences
  static Future<bool> saveToken(SharedPreferences prefs, String token) async {
    return await prefs.setString(authTokenKey, token);
  }

  // Mendapatkan token dari shared_preferences
  static String getToken(SharedPreferences prefs) {
    return prefs.getString(authTokenKey) ?? '';
  }

  // Menghapus token dari shared_preferences
  static Future<bool> clearToken(SharedPreferences prefs) async {
    return await prefs.remove(authTokenKey);
  }

  // Cek apakah token sudah tersimpan di shared_preferences
  static bool isTokenExist(SharedPreferences prefs) {
    return prefs.containsKey(authTokenKey);
  }
}
