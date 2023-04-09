import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intensity_tracker/carbon_intensity.dart';

Future<CarbonHistory> fetchHistoryData(String? lat, String? lon) async {
  String token = 'hPEgMAy3Z5f0IVdphzUPRyTaNVYgU1VR';
  final http.Response response;
  if (lat == null || lon == null) {
    response = await http.get(
      Uri.parse(
          'https://api-access.electricitymaps.com/2w97h07rvxvuaa1g/carbon-intensity/history?zone=DE'),
      // Send authorization headers to the backend.
      headers: {'X-BLOBR-KEY': token},
    );
  } else {
    response = await http.get(
      Uri.parse(
          'https://api-access.electricitymaps.com/2w97h07rvxvuaa1g/carbon-intensity/history?lat=$lat&lon=$lon'),
      // Send authorization headers to the backend.
      headers: {'X-BLOBR-KEY': token},
    );
  }
  //print(response.statusCode);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
      print(response.body);
      return CarbonHistory.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data. You probably are located in an unsupported area.');
  }
}

class CarbonHistory {
  final List<dynamic> history;
  /*final String zone;
  final String carbonIntensity;
  final String dateTime;
  final String updatedAt;
  final String createdAt;
  final String emissionFactorType;
  final String isEstimated;
  final String? estimationMethod;*/

  const CarbonHistory({
    required this.history,
    /*required this.zone,
    required this.carbonIntensity,
    required this.dateTime,
    required this.updatedAt,
    required this.createdAt,
    required this.emissionFactorType,
    required this.isEstimated,
    required this.estimationMethod,*/
  });

  factory CarbonHistory.fromJson(Map<String, dynamic> json) {
    return CarbonHistory(
      history : json['history'],
      /*zone: json['zone'],
      carbonIntensity: json['carbonIntensity'].toString(),
      dateTime: json['datetime'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      emissionFactorType: json['emissionFactorType'],
      isEstimated: json['isEstimated'].toString(),
      estimationMethod: json['estimationMethod'],*/
    );
  }
}
