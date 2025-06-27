import 'package:flutter/material.dart';
import 'package:flutter_clima/utilities/constants.dart';
import 'package:flutter_clima/services/weather.dart';
import 'city_screen.dart';

class LocationScreen extends StatefulWidget {
  final dynamic locationWeather;
  const LocationScreen({super.key, this.locationWeather});

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  WeatherModel weatherModel = WeatherModel();
  int? temperature;
  String weatherIcon = '';
  String weatherMessage = 'Weather data not available';
  String city = '';
  bool _isRefreshing = false; // For loading indicator

  @override
  void initState() {
    super.initState();
    updateUI(widget.locationWeather);
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = 'Error';
        weatherMessage = 'Unable to get weather data';
        city = '';
        return;
      }
      double temp = weatherData['main']['temp'];
      temperature = temp.toInt();
      city = weatherData['name'] ?? '';
      weatherIcon = weatherModel.getWeatherIcon(
        weatherData['weather'][0]['id'] ?? 1000,
      );
      if (temperature != null) {
        weatherMessage = weatherModel.getMessage(temperature!);
      }
    });
  }

  // Simple method to show an error dialog directly
  Future<void> _showSimpleErrorDialog(String title, String message) async {
    // No need to check mounted here if this method is ONLY called
    // immediately after a mounted check by its caller.
    // However, for robustness if it were called from elsewhere:
    // if (!mounted) return;

    return showDialog<void>(
      context: context, // Uses LocationScreenState's context
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(message)]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Pops the dialog itself
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchWeatherDataAndShowError() async {
    if (!mounted) return;
    setState(() {
      _isRefreshing = true;
    });

    try {
      var weatherData = await weatherModel.getLocationWeather();
      if (!mounted) return; // Crucial check
      updateUI(weatherData);
    } catch (e) {
      // Catching a generic Exception
      if (!mounted) return; // Crucial check

      // Default error message
      String errorTitle = "Error";
      String errorMessage = "An unknown error occurred.";

      // You can still check for specific exception types if you have them
      // Example:
      // if (e is LocationException) {
      //   errorTitle = "Location Error";
      //   errorMessage = e.message;
      // } else {
      //   errorMessage = "Failed to get weather: ${e.toString()}";
      // }
      // For this very simple example, we'll just use e.toString()
      errorTitle = "Update Failed";
      errorMessage = "Could not get weather data: ${e.toString()}";

      // Show the simple dialog
      await _showSimpleErrorDialog(errorTitle, errorMessage);

      // Optionally, update UI to an error state after dialog is dismissed
      if (!mounted) return;
      updateUI(null); // Show default error messages in the main UI
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/location_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withAlpha((0.8 * 255).round()),
              BlendMode.dstATop,
            ),
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: _isRefreshing
                        ? null
                        : _fetchWeatherDataAndShowError,

                    child: _isRefreshing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.near_me,
                            size: 50.0,
                            color: Colors.white,
                          ),
                  ),
                  TextButton(
                    onPressed: () async {
                      String? typedName = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CityScreen()),
                      );
                      if (typedName != null && typedName.isNotEmpty) {
                        var weatherData = await weatherModel.getCityWeather(
                          typedName,
                        );
                        updateUI(weatherData);
                      }
                    },
                    child: Icon(Icons.location_city, size: 50.0),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Row(
                  children: <Widget>[
                    Text('$temperature°', style: kTempTextStyle),
                    Text(weatherIcon, style: kConditionTextStyle),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  "$weatherMessage in $city!",
                  textAlign: TextAlign.right,
                  style: kMessageTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
