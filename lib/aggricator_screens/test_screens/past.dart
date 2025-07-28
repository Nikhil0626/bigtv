import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  String? ipAddress;
  String? deviceName;
  String? os;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDeviceInfo();
  }

  Future<void> fetchDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      // Get OS and device name
      String? _deviceName;
      String? _os;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _deviceName = "${androidInfo.brand} ${androidInfo.model}";
        _os = "Android ${androidInfo.version.release}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _deviceName = iosInfo.name ?? iosInfo.model;
        _os = "iOS ${iosInfo.systemVersion}";
      } else {
        _deviceName = "Unknown";
        _os = Platform.operatingSystem;
      }

      // Get IP address (public IP via web)
      // You can use any other IP service if you like
      final ipRes = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      String? _ip;
      if (ipRes.statusCode == 200) {
        _ip = jsonDecode(ipRes.body)['ip'] ?? "Unavailable";
      } else {
        _ip = "Unavailable";
      }

      setState(() {
        deviceName = _deviceName;
        os = _os;
        ipAddress = _ip;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Device Info")),
      body: Center(
        child: loading
            ? CircularProgressIndicator()
            : error != null
            ? Text("Error: $error")
            : Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow("IP Address", ipAddress ?? ""),
                SizedBox(height: 12),
                _infoRow("Device Name", deviceName ?? ""),
                SizedBox(height: 12),
                _infoRow("OS", os ?? ""),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F5F5),
    );
  }

  Widget _infoRow(String title, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "$title:",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          value,
          style: TextStyle(fontSize: 16),
        ),
      ),
    ],
  );
}

