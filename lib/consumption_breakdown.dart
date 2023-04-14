import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;

import 'location_service.dart';

class NestedObjectBarChart extends StatefulWidget {
  @override
  _NestedObjectBarChart createState() => _NestedObjectBarChart();
}

class _NestedObjectBarChart extends State<NestedObjectBarChart> {
  Map<String, dynamic> _data = {};
  String? lat, long, country, adminArea;


  Future<void> fetchData(String? lat, String? lon) async {
    String token = 'hPEgMAy3Z5f0IVdphzUPRyTaNVYgU1VR';
    final http.Response response;
    if (lat == null || lon == null) {
      response = await http.get(
        Uri.parse(
            'https://api-access.electricitymaps.com/2w97h07rvxvuaa1g/power-breakdown/latest?zone=DE'),
        // Send authorization headers to the backend.
        headers: {'X-BLOBR-KEY': token},
      );
    } else {
      response = await http.get(
        Uri.parse(
            'https://api-access.electricitymaps.com/2w97h07rvxvuaa1g/power-breakdown/latest?lat=$lat&lon=$lon'),
        // Send authorization headers to the backend.
        headers: {'X-BLOBR-KEY': token},
      );
    }
    if (response.statusCode == 200) {
      setState(() {
        _data = jsonDecode(response.body);
        print(_data);
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(lat, long);
  }


  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      final breakdownData = _data['powerConsumptionBreakdown'];
      final seriesList = [
        charts.Series<MapEntry<String, dynamic>, String>(
          displayName: 'Electricity Consumption Breakdown',
          id: 'Power Consumption',
          domainFn: (entry, _) => entry.key,
          measureFn: (entry, _) => entry.value,
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.red),
          data: breakdownData.entries.toList(),
          labelAccessorFn: (entry, _) => '${entry.key}: ${entry.value}',
        ),
      ];

      return Container(
        height: 1000,
        padding: EdgeInsets.all(16),
        child: charts.BarChart(
          seriesList,
          animate: true,
          vertical: false,
          barRendererDecorator: charts.BarLabelDecorator<String>(),
          domainAxis: charts.OrdinalAxisSpec(),
        ),
      );
    }
  }

  void getLocation() async {
    final service = LocationService();
    final locationData = await service.getLocation();

    if (locationData != null) {
      final placeMark = await service.getPlaceMark(locationData: locationData);

      setState(() {
        lat = locationData.latitude!.toStringAsFixed(2);
        long = locationData.longitude!.toStringAsFixed(2);
        country = placeMark?.country ?? 'could not get country';
        adminArea = placeMark?.administrativeArea ?? 'could not get admin area';
      });
      fetchData(lat, long);
    }
  }
}

class BreakdownPage extends StatelessWidget {
  const BreakdownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Intensity Tracker'),
        backgroundColor: const Color(0xffff554e),
      ),
      body: Center(
        child: NestedObjectBarChart(),
      ),
    );
  }
}