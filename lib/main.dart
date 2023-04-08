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
    futureCarbonIntensity = fetchData(lat, long);
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
          child: FutureBuilder<CarbonIntensity>(
            future: futureCarbonIntensity,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // set the color based on the carbon intensity value
                Color color = Colors.green;
                double value = double.parse(snapshot.data!.carbonIntensity);
                if (value >= 100 && value < 200) {
                  color = Colors.lightGreen;
                } else if (value >= 200 && value < 500) {
                  color = Colors.yellow;
                } else if (value >= 500 && value < 800) {
                  color = Colors.orange;
                } else if (value >= 800) {
                  color = Colors.black;
                }

                // create the progress bar widget
                Widget progressBar = LinearProgressIndicator(
                  value: value / 1000,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation(color),
                );

                // create the text widget with the displayed data
                String displayedData =
                    "Zone : ${snapshot.data!.zone}\nCarbon Intensity : ${snapshot.data!.carbonIntensity}\nDate Time : ${snapshot.data!.dateTime}\nUpdated at : ${snapshot.data!.updatedAt}\nCreated at : ${snapshot.data!.createdAt}\nEmission Factor Type : ${snapshot.data!.emissionFactorType}\nIs Estimated : ${snapshot.data!.isEstimated}\nEstimation Method : ${snapshot.data!.estimationMethod}";
                Widget dataText = Text(displayedData);

                // create the column with the progress bar and data text widgets
                Widget column = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    progressBar,
                    const SizedBox(height: 10),
                    dataText,
                  ],
                );

                return column;
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
      futureCarbonIntensity = fetchData(lat, long);
    }
  }
}
