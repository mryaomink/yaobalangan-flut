import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/auth_utils.dart';

class AuthController {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('yaotoken', token);
  }

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/login'),
      body: {
        'nip_nik': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['yaotoken'];
      return token;
    } else {
      throw Exception('Gagal melakukan login');
    }
  }
}

class YaoLogin extends StatefulWidget {
  const YaoLogin({super.key});

  @override
  State<YaoLogin> createState() => _YaoLoginState();
}

class _YaoLoginState extends State<YaoLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  String _errorMessage = '';
  final String baseUrl = "http://192.168.148.86:8000/api";
  String token = '';

  Future<void> loginUser() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'), // Ganti dengan URL login di server Anda
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token
        },
        body: jsonEncode(<String, dynamic>{
          'nip_nik': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Simpan token di SharedPreferences jika diperlukan
        await AuthUtils.saveToken(prefs, token);
        Navigator.pushNamed(context, '/absen');

        // Tambahkan logika navigasi ke halaman beranda atau halaman lain yang sesuai
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal login'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat login'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Nip/Nik'),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'NIP/NIK harus diisi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      const url = 'http://10.160.250.169:8000/api/login';

                      final response = await http.post(
                        Uri.parse(url),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(
                            {'nip_nik': email, 'password': password}),
                      );

                      if (response.statusCode == 200) {
                        // Login berhasil
                        final data = jsonDecode(response.body);
                        final token = data['access_token'];

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('yaotoken', token);
                        Navigator.pushReplacementNamed(context, '/absen');
                      } else {
                        // Login gagal
                        print('Terjadi kesalahan saat login');
                      }
                    }
                  },
                  child: const Text('Login'),
                ),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
