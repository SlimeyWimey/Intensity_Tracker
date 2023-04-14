import 'package:flutter/material.dart';
import 'package:boxicons/boxicons.dart';
import 'package:flutter/services.dart';
import 'package:intensity_tracker/carbon_history_plot.dart';
import 'package:intensity_tracker/forecast_plot.dart';

import 'consumption_breakdown.dart';
import 'intensity_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color.fromARGB(0, 255, 255, 255)));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intensity Tracker',
      home: BottomTabBar(),
    );
  }
}

class BottomTabBar extends StatefulWidget {
  BottomTabBar({Key? key}) : super(key: key);

  @override
  State<BottomTabBar> createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  int _index = 0;
  final screens = [
    IntensityPage(),
    BreakdownPage(),
    CarbonHistoryPlot(),
    ForecastPlot(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: screens[_index],
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _index,
            onTap: (value) {
              setState(() {
                _index = value;
              });
            },
            backgroundColor: Color.fromARGB(255, 227, 227, 227),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Boxicons.bx_home_circle),
                label: 'Latest C.I',
              ),
              BottomNavigationBarItem(
                icon: Icon(Boxicons.bx_bar_chart),
                label: 'Origin Breakdown',
              ),
              BottomNavigationBarItem(
              icon: Icon(Boxicons.bx_line_chart),
              label: 'History Plot',
              ),
              BottomNavigationBarItem(
                icon: Icon(Boxicons.bx_chart),
                label: 'C.I Forecast',
              ),
            ]));
  }
}
