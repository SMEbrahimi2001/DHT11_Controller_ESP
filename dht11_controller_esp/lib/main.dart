import 'dart:async';

import 'package:dht11_controller_esp/apiESP.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePageScreen(),
    );
  }
}

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  static const String baseUrl = 'http://10.72.163.246';
  final service = EspService();
  bool relayState = false;
  Timer? timer;

  DeviceStatus? status;
  Future<void> turnOnRelay() async {
    await http.get(Uri.parse('$baseUrl/relay/on'));
  }

  Future<void> turnOffRelay() async {
    await http.get(Uri.parse('$baseUrl/relay/off'));
  }

  Future<void> loadStatus() async {
    final result = await EspService().getStatus();

    setState(() {
      status = result;
      // *** is for Termostat House ***
      if (status!.temperature >= 35) {
        turnOffRelay();
      } else {
        turnOnRelay();
      }
      // *** ***
      relayState = status!.relay;
    });
  }

  @override
  void initState() {
    super.initState();

    loadStatus();

    timer = Timer.periodic(const Duration(seconds: 2), (_) {
      loadStatus();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.height * 0.08,
        title: Text('Temperature & Humidity Sensor'),
      ),
      body: Container(
        height: size.height - size.height * 0.08,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.1,
              width: size.width * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blueAccent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Temperature ${status?.temperature ?? '--'} °C',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // SizedBox(height: 10),
                  // Text(
                  //   // '11 °C',
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(height: 25),
            Container(
              height: size.height * 0.1,
              width: size.width * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blueAccent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Humidity ${status?.humidity ?? '--'} %',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // SizedBox(height: 10),
                  // Text(
                  //   '21 %',
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
            ),
            SizedBox(height: 25),
            Text('روشن / خاموش کردن لامپ دستی'),
            Switch(
              value: relayState,
              onChanged: (val) async {
                if (val) {
                  await turnOnRelay();
                } else {
                  await turnOffRelay();
                }

                setState(() {
                  relayState = val;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
