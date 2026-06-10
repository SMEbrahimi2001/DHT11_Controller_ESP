import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class DeviceStatus {
  final bool relay;
  final double temperature;
  final double humidity;

  DeviceStatus({
    required this.relay,
    required this.temperature,
    required this.humidity,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      relay: json['relay'] ?? '',
      temperature: (json['temperature'] ?? '00' as num).toDouble(),
      humidity: (json['humidity'] ?? '00' as num).toDouble(),
    );
  }
}

class EspService {
  static const String baseUrl = 'http://10.72.163.246';

  Future<DeviceStatus> getStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/status'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('status is succes');
      return DeviceStatus.fromJson(data);
    }

    throw Exception('Failed to get status');
  }
}
