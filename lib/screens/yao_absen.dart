import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ihsan_balangan/utils/auth_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YaoAbsen extends StatefulWidget {
  const YaoAbsen({super.key});

  @override
  State<YaoAbsen> createState() => _YaoAbsenState();
}

class _YaoAbsenState extends State<YaoAbsen> {
  final _formKey = GlobalKey<FormState>();
  final _sekolahIdController = TextEditingController();
  final _lokasiAbsenController = TextEditingController();
  final _idGuruC = TextEditingController();
  final _namaSekolahC = TextEditingController();

  final _namaGuruC = TextEditingController();
  final _jamAbsenC = TextEditingController();
  final _statusC = TextEditingController();

  String _errorMessage = '';
  final String baseUrl = "http://192.168.148.86:8000/api";
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> sendDataToServer() async {
    final token = AuthUtils.getToken(prefs);
    final response = await http.post(
      Uri.parse(
          '$baseUrl/api/absensi'), // Ganti dengan URL endpoint absensi di server Anda
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
      body: jsonEncode(<String, String>{
        'id_guru': _idGuruC.text,
        'id_sekolah': _sekolahIdController.text,
        'titik_koordinat': _lokasiAbsenController.text,
        'nama_guru': _namaGuruC.text,
        'nama_sekolah': _namaSekolahC.text,
        'jam_absen': _jamAbsenC.text,
        'status_absen': _statusC.text
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Absensi berhasil terkirim!'),
        ),
      );
    } else {
      print('Gagal mengirim data absensi');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Absen"),
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
                    controller: _sekolahIdController,
                    decoration: InputDecoration(labelText: 'ID Sekolah'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'ID Sekolah harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _namaGuruC,
                    decoration: InputDecoration(labelText: 'Nama Guru'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'ID Sekolah harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _idGuruC,
                    decoration: InputDecoration(labelText: 'ID Guru'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'ID Sekolah harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _namaSekolahC,
                    decoration: InputDecoration(labelText: 'Nama Sekolah'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'ID Sekolah harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _statusC,
                    decoration: InputDecoration(labelText: 'Status'),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'ID Sekolah harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _jamAbsenC,
                    decoration: InputDecoration(labelText: 'Jam Absen'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'ID Sekolah harus diisi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _lokasiAbsenController,
                    decoration: InputDecoration(labelText: 'Lokasi Absen'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lokasi Absen harus diisi';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        sendDataToServer();
                      }
                    },
                    child: Text('Absen'),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
