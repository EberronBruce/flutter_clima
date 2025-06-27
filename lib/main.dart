import 'package:flutter/material.dart';
import 'package:flutter_clima/screens/loading_screen.dart';
import 'package:flutter_clima/utilities/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
    String? apiKeyFromEnv = dotenv.env['OPENWEATHERMAP_API_KEY'];
    if (apiKeyFromEnv == null || apiKeyFromEnv.isEmpty) {
      throw Exception(
        "CRITICAL ERROR: OPENWEATHERMAP_API_KEY is missing or empty in .env file. Application cannot start.",
      );
    }
    apiKey = apiKeyFromEnv;
    runApp(MyApp());
  } catch (e) {
    debugPrint('Error during app initialization: $e');
    runApp(ErrorApp(message: "Application could not initialize. Error: $e"));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData.dark(), home: LoadingScreen());
  }
}

class ErrorApp extends StatelessWidget {
  final String message;
  const ErrorApp({super.key, required this.message});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[100],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Initialization Failed:\n$message",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
