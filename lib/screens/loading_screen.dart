import 'package:flutter/material.dart';
import 'package:flutter_clima/services/location.dart';
import 'location_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_clima/services/weather.dart';

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
    try {
      var weatherData = await WeatherModel().getLocationWeather();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return LocationScreen(locationWeather: weatherData);
          },
        ),
      );
    } on LocationException catch (e) {
      if (!mounted) return;
      showErrorDialog(
        context: context, // Pass the current context
        title: 'Location Error',
        message: e.message,
        showOpenSettingsButton:
            e.message.toLowerCase().contains("settings") ||
            e.message.toLowerCase().contains("denied forever"),
        onOkPressed: () {
          // Custom action for OK if needed, e.g., navigate to error screen
          Navigator.of(context).pop(); // Dismiss the dialog first
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const LocationScreen(locationWeather: null),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      // Use the global dialog utility
      showErrorDialog(
        context: context,
        title: 'Unexpected Error',
        message: 'An error occurred: ${e.toString()}',
        onOkPressed: () {
          Navigator.of(context).pop(); // Dismiss the dialog
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const LocationScreen(locationWeather: null),
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitDoubleBounce(color: Colors.white, size: 100.0),
      ),
    );
  }
}
