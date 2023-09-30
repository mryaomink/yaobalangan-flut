import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('yaotoken');

    final response = await http.get(
      Uri.parse(
          'https://bukutamutes.banjarbarukota.go.id/laravel/public/api/guru'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final namaGuru = data['nama'];
      final namaSekolah = data['nama_sekolah'];

      return {
        'nama': namaGuru,
        'nama_sekolah': namaSekolah,
      };
    } else {
      throw Exception('Gagal mengambil data pengguna');
    }
  }
}
