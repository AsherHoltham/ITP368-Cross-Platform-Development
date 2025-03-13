import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String info = 'Press the button to get weather info';

  Future<void> getWeatherData() async {
    final url =
        'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/Charlotte?unitGroup=us&key=4KPV92NR3XE9DFJ4QPFPWV2QK&contentType=json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = json.decode(response.body);

        // Extract useful information from the JSON response
        final current = data['currentConditions'];
        final resolvedAddress = data['resolvedAddress'];
        final currentTemp = current['temp'];
        final conditions = current['conditions'];

        // Update the state to display the weather info
        setState(() {
          info = 'Location: $resolvedAddress\n'
              'Temperature: $currentTemp°F\n'
              'Conditions: $conditions';
        });
      } else {
        setState(() {
          info = 'Error fetching weather: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        info = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Info')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                info,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: getWeatherData,
                child: const Text('Get Weather Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
