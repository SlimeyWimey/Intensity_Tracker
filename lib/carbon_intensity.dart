import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

Future<CarbonIntensity> fetchData() async {
  /*final response = await http.get(Uri.parse(
      'https://api-access.electricitymaps.com/2w97h07rvxvuaa1g/carbon-intensity/latest?zone=FR'));*/
  String token = 'hMowYuqF6AK9Ox6jpaYeb8FFujHaK4a4';
  final response = await http.get(
    Uri.parse('https://api-access.electricitymaps.com/2w97h07rvxvuaa1g/carbon-intensity/latest?zone=FR'),
    // Send authorization headers to the backend.
    headers: {
      'X-BLOBR-KEY' : token
    },
  );
  print(response.statusCode);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return CarbonIntensity.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
}

class CarbonIntensity {
  final String zone;
  final String carbonIntensity;
  final String dateTime;
  final String updatedAt;
  final String createdAt;
  final String emissionFactorType;
  final String isEstimated;
  final String estimationMethod;

  const CarbonIntensity({
    required this.zone,
    required this.carbonIntensity,
    required this.dateTime,
    required this.updatedAt,
    required this.createdAt,
    required this.emissionFactorType,
    required this.isEstimated,
    required this.estimationMethod,
  });

  factory CarbonIntensity.fromJson(Map<String, dynamic> json) {
    return CarbonIntensity(
      zone: json['zone'],
      carbonIntensity: json['carbonIntensity'].toString(),
      dateTime: json['datetime'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      emissionFactorType: json['emissionFactorType'],
      isEstimated: json['isEstimated'].toString(),
      estimationMethod: json['estimationMethod'],
    );
  }
}
