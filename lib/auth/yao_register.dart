import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ihsan_balangan/utils/auth_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YaoRegister extends StatefulWidget {
  const YaoRegister({super.key});

  @override
  State<YaoRegister> createState() => _YaoRegisterState();
}

class _YaoRegisterState extends State<YaoRegister> {
  final TextEditingController _idSekolahC = TextEditingController();
  final TextEditingController _namaGurC = TextEditingController();
  final TextEditingController _userNameC = TextEditingController();
  final TextEditingController _passC = TextEditingController();

  final String baseUrl = "http://192.168.148.86:8000/api";
  String token = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(),
                child: TextField(
                  controller: _idSekolahC,
                  decoration: const InputDecoration(
                    labelText: 'Id Sekolah',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueGrey,
                      ),
                    ),
                    helperText: "Harus diisi",
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(),
                child: TextField(
                  controller: _namaGurC,
                  decoration: const InputDecoration(
                    labelText: 'Nama',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueGrey,
                      ),
                    ),
                    helperText: "Harus diisi",
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(),
                child: TextField(
                  controller: _userNameC,
                  decoration: const InputDecoration(
                    labelText: 'NIP/NIK',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueGrey,
                      ),
                    ),
                    helperText: "Harus diisi",
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(),
                child: TextField(
                  obscureText: true,
                  controller: _passC,
                  decoration: const InputDecoration(
                    labelText: 'password',
                    labelStyle: TextStyle(
                      color: Colors.blueGrey,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueGrey,
                      ),
                    ),
                    helperText: "Harus diisi",
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                onPressed: () async {
                  String namaGuru = _namaGurC.text;
                  String idSekolah = _idSekolahC.text;
                  String nipNik = _userNameC.text;
                  String password = _passC.text;
                  if (namaGuru.isEmpty ||
                      idSekolah.isEmpty ||
                      nipNik.isEmpty ||
                      password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Semua Fields Harus diisi!!'),
                      ),
                    );
                    return;
                  }
                  try {
                    final response =
                        await http.post(Uri.parse('$baseUrl/register'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                              'Authorization': token,
                            },
                            body: jsonEncode(<String, dynamic>{
                              'nama_guru': namaGuru,
                              'id_sekolah': idSekolah,
                              'nip_nik': nipNik,
                              'password': password,
                            }));
                    if (response.statusCode == 201) {
                      final data = jsonDecode(response.body);
                      final token = data['token'];
                      final prefs = await SharedPreferences.getInstance();
                      await AuthUtils.saveToken(prefs, token);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Pendaftaran Berhasi, Silahkan Login')));
                      // ignore: use_build_context_synchronously
                    } else {
                      final data = jsonDecode(response.body);
                      print(data);
                      Navigator.pushNamed(context, '/login');
                    }
                  } catch (e) {
                    // ignore: avoid_print
                    print('Error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Terjadi Kesalahan')));
                  }
                },
                child: const Text("Daftar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
