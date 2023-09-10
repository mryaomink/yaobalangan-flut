import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act_reborn/slide_to_act_reborn.dart';

class YaoAttendance extends StatefulWidget {
  const YaoAttendance({super.key});

  @override
  State<YaoAttendance> createState() => _YaoAttendanceState();
}

class _YaoAttendanceState extends State<YaoAttendance> {
  final GlobalKey<SlideActionState> key = GlobalKey<SlideActionState>();
  final GlobalKey<SlideActionState> keyPulang = GlobalKey<SlideActionState>();
  String namaGuru = '';
  int sekolahId = 0;
  int guruId = 0;
  String noIdentitas = '';
  String namaSekolah = '';
  String currentDate = '';
  String absensiStatus = '';
  String waktuMasuk = '--/--';
  String waktuPulang = '--/--';
  Position? currentPosition;
  String statusAbsensi = '';
  bool isButtonDisabled = false;

  String token = '';
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();

    _getUserData();
    currentDate = DateFormat("dd MMMM yyyy").format(DateTime.now());
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    token = (prefs.getString('yaotoken'))!;
  }

  Future<void> _showSuccessDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: const TextStyle(fontSize: 12.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // void getLocation() async {
  //   // Minta izin lokasi
  //   LocationPermission permission = await Geolocator.requestPermission();

  //   if (permission == LocationPermission.denied) {
  //     // Handle jika izin ditolak
  //     print('Izin lokasi ditolak');
  //     return;
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Handle jika izin ditolak secara permanen
  //     print('Izin lokasi ditolak secara permanen');
  //     return;
  //   }

  //   try {
  //     final position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     setState(() {
  //       // Menggabungkan latitude dan longitude menjadi satu string
  //       _locationString =
  //           'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
  //     });
  //   } catch (e) {
  //     // Handle location capture errors (e.g., permissions not granted)
  //     print('Location capture error: $e');
  //   }
  // }

  Future<void> absenMasuk() async {
    // Memeriksa dan meminta izin lokasi
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Izin lokasi diberikan, lanjut ke pengambilan lokasi
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Mengambil tanggal dan jam dari perangkat
      DateTime currentDateTime = DateTime.now();
      String tanggal =
          currentDateTime.toLocal().toIso8601String().split('T')[0];
      String jam = DateFormat.Hm().format(currentDateTime);

      // Data yang akan dikirim ke backend
      final Map<String, dynamic> requestData = {
        'guru_id': guruId.toString(),
        'sekolah_id': sekolahId.toString(),
        'tanggal': tanggal,
        'jam_masuk': jam,
        'lokasi': '${position.latitude}, ${position.longitude}'
      };

      // Endpoint URL di backend Anda
      const apiUrl = 'http://192.168.148.86:8000/api/absensi/masuk';

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // Tambahkan header lain jika diperlukan (misalnya, token otentikasi)
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: json.encode(requestData),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final pesan = responseData['status'];
          setState(() {
            waktuMasuk = jam;
            statusAbsensi = pesan;
          });
          _showSuccessDialog("Anda Berhasil Melakukan Absen di $namaSekolah",
              "Terimakasih, Semangat bekerja");
          print('Absen masuk berhasil');
        } else {
          // Handle kesalahan jika diperlukan (misalnya, server error)
          print(
              'Gagal melakukan absen masuk. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // Handle kesalahan koneksi atau kesalahan lainnya
        print('Terjadi kesalahan: $e');
      }
    } else {
      // Izin lokasi ditolak, tampilkan pesan atau lakukan penanganan lain
      print('Izin lokasi ditolak');
    }
  }

  Future<void> absenPulang() async {
    // Memeriksa dan meminta izin lokasi
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Izin lokasi diberikan, lanjut ke pengambilan lokasi
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Mengambil tanggal dan jam dari perangkat
      DateTime currentDateTime = DateTime.now();
      String tanggal =
          currentDateTime.toLocal().toIso8601String().split('T')[0];
      String jamPulang = DateFormat.Hm().format(currentDateTime);

      // Data yang akan dikirim ke backend
      final Map<String, dynamic> requestData = {
        'guru_id': guruId.toInt(),
        'sekolah_id': sekolahId.toInt(),
        'tanggal': tanggal,
        'jam_pulang': jamPulang,
        'lokasi': '${position.latitude}, ${position.longitude}'
      };

      // Endpoint URL di backend Anda
      const apiUrl = 'http://192.168.148.86:8000/api/absensi/pulang';

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        // Tambahkan header lain jika diperlukan (misalnya, token otentikasi)
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: json.encode(requestData),
        );

        if (response.statusCode == 200) {
          setState(() {
            waktuPulang = jamPulang;
          });
          _showSuccessDialog(
              "Tetap Semangat bekerja sampai bertemu besok di $namaSekolah",
              "Terimakasih");
          print('Absen pulang berhasil');
        } else {
          // Handle kesalahan jika diperlukan (misalnya, server error)
          print(
              'Gagal melakukan absen pulang. Status code: ${response.statusCode}');
        }
      } catch (e) {
        // Handle kesalahan koneksi atau kesalahan lainnya
        print('Terjadi kesalahan: $e');
      }
    } else {
      // Izin lokasi ditolak, tampilkan pesan atau lakukan penanganan lain
      print('Izin lokasi ditolak');
    }
  }

  Future<void> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('yaotoken');

    const url = 'http://192.168.148.86:8000/api/guru-info';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        guruId = data['guru_id'];
        namaGuru = data['nama'];
        noIdentitas = data['nip_nik'];
        namaSekolah = data['nama_sekolah'];
        sekolahId = data['sekolah_id'];
      });
    } else {
      print('Terjadi kesalahan saat mengambil data pengguna');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Selamat Datang di',
                    style: TextStyle(fontSize: 30.0, color: Colors.black54),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    namaSekolah,
                    style: const TextStyle(fontSize: 20.0, color: Colors.black),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    namaGuru,
                    style: const TextStyle(fontSize: 18.0, color: Colors.green),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    noIdentitas,
                    style:
                        const TextStyle(fontSize: 16.0, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 10),
                // Row(
                //   children: [
                //     IconButton(
                //         onPressed: () {
                //           _requestLocationPermission();
                //         },
                //         icon: const Icon(Icons.location_on)),
                //     Expanded(
                //       child: Text(
                //         locationMessage,
                //         style: const TextStyle(fontSize: 12),
                //         textAlign: TextAlign.center,
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.only(top: 30.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Status Absen: $statusAbsensi'.toLowerCase(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20.0, bottom: 32.0),
                  height: 150.0,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(blurRadius: 10, offset: Offset(2, 2)),
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Jam Masuk',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.black54),
                            ),
                            const SizedBox(
                              width: 80,
                              child: Divider(),
                            ),
                            Text(
                              waktuMasuk,
                              style: const TextStyle(fontSize: 25.0),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Jam Pulang',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.black54),
                            ),
                            const SizedBox(
                              width: 80,
                              child: Divider(),
                            ),
                            Text(
                              waktuPulang,
                              style: const TextStyle(fontSize: 25.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat("dd MMMM yyyy").format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 25.0,
                    ),
                  ),
                ),
                StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat("hh:mm:ss a").format(DateTime.now()),
                          style: const TextStyle(
                              fontSize: 15.0, color: Colors.black54),
                        ),
                      );
                    }),
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 25.0),
                      child: Builder(builder: (context) {
                        return SlideAction(
                          text: "Absen Masuk",
                          textStyle: const TextStyle(
                              fontSize: 18.0, color: Colors.black54),
                          outerColor: Colors.white,
                          innerColor: Colors.green,
                          key: key,
                          onSubmit: () async {
                            if (!isButtonDisabled) {
                              // Nonaktifkan tombol
                              setState(() {
                                isButtonDisabled = true;
                              });

                              // Panggil metode absenMasuk
                              await absenMasuk();

                              // Aktifkan tombol kembali setelah selesai
                              setState(() {
                                key.currentState!.deactivate();
                              });

                              key.currentState!.reset();
                            }
                          },
                        );
                      }),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 25.0),
                      child: Builder(builder: (context) {
                        return SlideAction(
                          text: "Absen Pulang",
                          textStyle: const TextStyle(
                              fontSize: 18.0, color: Colors.black54),
                          outerColor: Colors.white,
                          innerColor: Colors.redAccent,
                          key: keyPulang,
                          onSubmit: () {
                            absenPulang();
                            keyPulang.currentState!.reset();
                          },
                        );
                      }),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
