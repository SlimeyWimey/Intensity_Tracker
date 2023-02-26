import 'package:flutter/material.dart';
import 'carbon_intensity.dart';
import 'location_service.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intensity Tracker',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? lat, long, country, adminArea;
  late Future<CarbonIntensity> futureCarbonIntensity;

  @override
  void initState() {
    super.initState();
    getLocation();
    futureCarbonIntensity = fetchData();
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
        body: Center(
          child:  FutureBuilder<CarbonIntensity>(
            future: futureCarbonIntensity,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String displayedData = "Zone : ${snapshot.data!.zone}\nCarbon Intensity : ${snapshot.data!.carbonIntensity}\nDate Time : ${snapshot.data!.dateTime}\nUpdated at : ${snapshot.data!.updatedAt}\nCreated at : ${snapshot.data!.createdAt}\nEmission Factor Type${snapshot.data!.emissionFactorType}\nIs Estimated : :${snapshot.data!.isEstimated}\nEstimation Method : ${snapshot.data!.estimationMethod}";
                return Text(displayedData);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intensity Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location Info:', style: getStyle(size: 24),),
            const SizedBox(height: 20,),
            Text('Latitude: ${lat ?? 'Loading ...'}', style: getStyle(),),
            const SizedBox(height: 20,),
            Text('Longitude: ${long ?? 'Loading ...'}', style: getStyle(),),
            const SizedBox(height: 20,),
            Text('Country: ${country ?? 'Loading ...'}', style: getStyle(),),
            const SizedBox(height: 20,),
            Text('Admin Area: ${adminArea ?? 'Loading ...'}', style: getStyle(),),
            const SizedBox(height: 20,),
            FutureBuilder<CarbonIntensity>(
              future: carbonIntensity,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!.carbonIntensity as String);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }

                // By default, show a loading spinner.
                return const CircularProgressIndicator();
              },
            )
          ],
        ),
      ),
    );
  }*/

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
    }
  }
}
