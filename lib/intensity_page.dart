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

  // Dictionnaire des codes des pays correspondants à leur drapeau
  final Map<String, String> _countryFlags = {
    'FR': '🇫🇷',
    'US': '🇺🇸',
    'GB': '🇬🇧',
    'DE': '🇩🇪',
    'JP': '🇯🇵',
    'BE': '🇧🇪',
    'SE': '🇸🇪'
  };

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

                // Récupérer le drapeau correspondant à la zone
                String zone = snapshot.data!.zone;
                String? flag = _countryFlags[zone.substring(0, 2)];

                // Créer le widget drapeau
                Widget flagWidget = Text(
                  flag ?? '',
                  style: const TextStyle(fontSize: 40),
                );

                // create the progress bar widget
                Widget progressBar = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  // ajustez cette valeur pour ajouter de l'espace autour de la barre de progression
                  child: LinearProgressIndicator(
                    value: value / 1000,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 10,
                  ),
                );

                // create the text widget with the displayed data
/*                String displayedData =
                    "Zone : ${snapshot.data!.zone}\nCarbon Intensity : ${snapshot.data!.carbonIntensity}\nDate Time : ${cleanDate(snapshot.data!.dateTime)}\nUpdated at : ${cleanDate(snapshot.data!.updatedAt)}\nCreated at : ${cleanDate(snapshot.data!.createdAt)}\nEmission Factor Type : ${snapshot.data!.emissionFactorType}\nIs Estimated : ${snapshot.data!.isEstimated}\nEstimation Method : ${snapshot.data!.estimationMethod}";
                Widget dataText = Text(displayedData);*/

                /*
                // create the title widget
                Widget title = const Text(
                  'Carbon Intensity Tracker',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                );
                */

                // create the column with the progress bar and data text widgets
                /*            Widget column = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    flagWidget,
                    const SizedBox(height: 50),
                    Text(snapshot.data!.carbonIntensity, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 50),
                    progressBar,
                    const SizedBox(height: 50),
                    dataText,
                  ],
                );*/
                Widget column = SizedBox(
                  height: 250, // set the height to a smaller value
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start, // set the vertical alignment to start
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      flagWidget,
                      const SizedBox(height: 50),
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text(
                                  "Zone : ${snapshot.data!.zone}\nCarbon Intensity : ${snapshot.data!.carbonIntensity}\nDate Time : ${cleanDate(snapshot.data!.dateTime)}\nUpdated at : ${cleanDate(snapshot.data!.updatedAt)}\nCreated at : ${cleanDate(snapshot.data!.createdAt)}\nEmission Factor Type : ${snapshot.data!.emissionFactorType}\nIs Estimated : ${snapshot.data!.isEstimated}\nEstimation Method : ${snapshot.data!.estimationMethod}",
                                ),
                              );
                            },
                          );
                        },
                        child: Text(
                          snapshot.data!.carbonIntensity,
                          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 50),
                      progressBar,
                    ],
                  ),
                );
// wrap the column with an Expanded widget
                Widget expandedColumn = Expanded(child: column);

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 300,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //title,
                      expandedColumn,
                    ],
                  ),
                );
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

  String cleanDate(String dirtyDate) {
    final date = dirtyDate.split('T');
    final hour = date.last.split('.');
    String cleanedDate = "${date.first} ${hour.first}";
    return cleanedDate;
  }
}
