import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

import 'location_service.dart';


class CarbonHistoryPlot extends StatefulWidget {
  const CarbonHistoryPlot({super.key});

  @override
  State<CarbonHistoryPlot> createState() => _CarbonHistoryPlot();
}

class _CarbonHistoryPlot extends State<CarbonHistoryPlot> {
  List<Color> gradientColors = [
    Color(0xFF50E4FF),
    Color(0xFF2196F3),
  ];

  String? lat, long, country, adminArea;
  List history = [];
  bool isLoading = false;
  bool showAvg = false;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
    getLocation();
    fetchHistory(lat, long);
  }

  fetchHistory(String? lat, String? lon) async {
    setState(() {
      isLoading = true;
    });
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
    if (response.statusCode == 200) {
      var items = json.decode(response.body)['history'];
      setState(() {
        history = items;
        isLoading = false;
      });
    } else {
      history = [];
      isLoading = false;
    }
    //print("history :");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Intensity Tracker',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Intensity Tracker'),
          ),
          body: getPlot(),
        ));
  }

  Widget getPlot(){
    return SafeArea(
        child: Scaffold(
            body: SfCartesianChart(
                title: ChartTitle(text: 'C.I History'),
                legend: Legend(isVisible: true),
                tooltipBehavior: _tooltipBehavior,
                series: <ChartSeries>[
                  LineSeries<dynamic, DateTime>(
                      name: 'Carbon Intensity',
                      dataSource: history,
                      xValueMapper: (history, _) => cleanDate(history['datetime']),
                      yValueMapper: (history, _) => history['carbonIntensity'],
                      dataLabelSettings: DataLabelSettings(isVisible: true),
                      enableTooltip: true)
                ],
                primaryXAxis: DateTimeAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '{value}',
                ))));
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
      fetchHistory(lat, long);
    }
  }

  DateTime cleanDate(String dirtyDate) {
    final date = dirtyDate.split('T');
    final hour = date.last.split('.');
    String cleanedDate = "${date.first} ${hour.first}";
    DateTime time = DateTime.parse(cleanedDate);
    return time;
  }
}