import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intensity_tracker/carbon_history.dart';
import 'package:intensity_tracker/carbon_intensity.dart';

import 'location_service.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? lat, long, country, adminArea;
  late Future<CarbonHistory> futureCarbonHistory;
  List history = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getLocation();
    fetchHistory();
  }

  fetchHistory() async {
    setState(() {
      isLoading = true;
    });
    String token = 'hPEgMAy3Z5f0IVdphzUPRyTaNVYgU1VR';
    final http.Response response;
    if (lat == null || long == null) {
      response = await http.get(
        Uri.parse(
            'https://api-access.electricitymaps.com/2w97h07rvxvuaa1g/carbon-intensity/history?zone=DE'),
        // Send authorization headers to the backend.
        headers: {'X-BLOBR-KEY': token},
      );
    } else {
      response = await http.get(
        Uri.parse(
            'https://api-access.electricitymaps.com/2w97h07rvxvuaa1g/carbon-intensity/history?lat=$lat&lon=$long'),
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
      print("history :");
      print(history);
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
      body: getBody(),
    ));
  }

  Widget getBody() {
    if (history.contains(null) || history.length < 0 || isLoading) {
      return const Center(
          child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ));
    }
    return ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          return getCard(history[index]);
        });
  }

  Widget getCard(item) {
    var zone = item['zone'];
    var carbonIntensity = item['carbonIntensity'].toString();
    var dateTime = item['datetime'];
    var updatedAt = item['updatedAt'];
    var createdAt = item['createdAt'];
    var emissionFactorType = item['emissionFactorType'];
    var isEstimated = item['isEstimated'];
    var estimationMethod = item['estimationMethod'];
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 140,
                      child: Text(
                        zone + " : " + carbonIntensity,
                        style: const TextStyle(fontSize: 17),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    cleanDate(dateTime),
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  TextStyle getStyle({double size = 20}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.bold);

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
      futureCarbonHistory = fetchHistoryData(lat, long);
    }
  }

  String cleanDate(String dirtyDate) {
    String cleanDate;
    final date = dirtyDate.split('T');
    final hour = date.last.split('.');
    return cleanDate = "${date.first} ${hour.first}";
  }
}
