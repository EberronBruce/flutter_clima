import 'package:flutter/material.dart';
import 'package:flutter_clima/services/location.dart';
import 'package:flutter_clima/utilities/constants.dart';
import 'package:flutter_clima/services/networking.dart';
import 'location_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  void getLocationData() async {
    Location location = Location();
    await location.getCurrentLocation();

    if (location.latitude != null && location.longitude != null) {
      NetworkHelper networkHelper = NetworkHelper(
        '$baseUrl?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey&units=imperial',
      );
      var weatherData = await networkHelper.getData();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LocationScreen();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
