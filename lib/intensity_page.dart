import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'carbon_intensity.dart';
import 'location_service.dart';


class IntensityPage extends StatefulWidget {
  IntensityPage({Key? key}) : super(key: key);

  @override
  State<IntensityPage> createState() => _IntensityPageState();
}

class _IntensityPageState extends State<IntensityPage> {
  String? lat, long, country, adminArea;
  late Future<CarbonIntensity> futureCarbonIntensity;

  @override
  void initState() {
    super.initState();
    getLocation();
    //futureCarbonIntensity = fetchData(lat, long);
    //futureCarbonHistory = fetchHistoryData(lat, long);
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
            //future: futureCarbonHistory,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String displayedData =
                    "Zone : ${snapshot.data!.zone}\nCarbon Intensity : ${snapshot.data!.carbonIntensity}\nDate Time : ${cleanDate(snapshot.data!.dateTime)}\nUpdated at : ${cleanDate(snapshot.data!.updatedAt)}\nCreated at : ${cleanDate(snapshot.data!.createdAt)}\nEmission Factor Type : ${snapshot.data!.emissionFactorType}\nIs Estimated : ${snapshot.data!.isEstimated}\nEstimation Method : ${snapshot.data!.estimationMethod?.replaceAll('_', ' ')}";
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
      //futureCarbonHistory = fetchHistoryData(lat, long);
    }
  }

  String cleanDate(String dirtyDate) {
    String cleanDate = '';
    final date = dirtyDate.split('T');
    final hour = date.last.split('.');
    print(cleanDate);
    return cleanDate = "${date.first} ${hour.first}";
  }
}