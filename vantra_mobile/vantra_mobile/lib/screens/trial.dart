import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  Position? _currentPosition;
  String _locationMessage = 'Fetching location...';
  bool _isLoading = true;
  String _cityName = '';
  String _country = '';
  Map<String, dynamic>? _weatherData;

  // Replace with your OpenWeatherMap API key
  final String _apiKey = '066400583de24e211c6b0ea168f54346';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationMessage = 'Fetching location...';
      _cityName = '';
      _country = '';
      _weatherData = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationMessage = 'Location permissions are denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage =
              'Location permissions are permanently denied, we cannot request permissions.';
          _isLoading = false;
        });
        await openAppSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _getAddressFromLatLng(position);
      await _fetchWeather(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;
        _locationMessage = 'Location fetched successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _cityName =
              place.locality ?? place.subAdministrativeArea ?? 'Unknown city';
          _country = place.country ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _cityName = 'Could not get address';
      });
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Convert all numeric values to double
        if (data['main'] != null) {
          data['main']['temp'] = data['main']['temp']?.toDouble();
          data['main']['feels_like'] = data['main']['feels_like']?.toDouble();
          data['main']['temp_min'] = data['main']['temp_min']?.toDouble();
          data['main']['temp_max'] = data['main']['temp_max']?.toDouble();
          data['main']['humidity'] = data['main']['humidity']?.toDouble();
          data['main']['pressure'] = data['main']['pressure']?.toDouble();
        }

        if (data['wind'] != null) {
          data['wind']['speed'] = data['wind']['speed']?.toDouble();
          data['wind']['deg'] = data['wind']['deg']?.toDouble();
        }

        if (data['rain'] != null && data['rain']['1h'] != null) {
          data['rain']['1h'] = data['rain']['1h'].toDouble();
        }

        if (data['visibility'] != null) {
          data['visibility'] = data['visibility'].toDouble();
        }

        setState(() {
          _weatherData = data;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      setState(() {
        _locationMessage = 'Error fetching weather: ${e.toString()}';
      });
    }
  }

  String _getWindDirection(double? degrees) {
    if (degrees == null) return '';
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather & Location')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_cityName.isNotEmpty || _country.isNotEmpty)
                      Text(
                        '$_cityName, $_country',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    if (_weatherData != null) ...[
                      // Current weather summary
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_weatherData!['weather'] != null)
                            Image.network(
                              'https://openweathermap.org/img/wn/${_weatherData!['weather'][0]['icon']}@2x.png',
                              width: 80,
                              height: 80,
                            ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // In your build method, update the temperature display to:
                              Text(
                                '${(_weatherData!['main']['temp'] as double?)?.toStringAsFixed(1) ?? '--'}°C',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_weatherData!['weather'] != null)
                                Text(
                                  _weatherData!['weather'][0]['main'],
                                  style: const TextStyle(fontSize: 18),
                                ),
                              Text(
                                'Feels like ${_weatherData!['main']['feels_like']?.toStringAsFixed(1) ?? '--'}°C',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Weather details
                      const Text(
                        'Weather Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildWeatherDetail(
                        'Description',
                        _weatherData!['weather'][0]['description'],
                      ),
                      _buildWeatherDetail(
                        'Humidity',
                        '${_weatherData!['main']['humidity']}%',
                      ),
                      _buildWeatherDetail(
                        'Pressure',
                        '${_weatherData!['main']['pressure']} hPa',
                      ),
                      if (_weatherData!['rain'] != null)
                        _buildWeatherDetail(
                          'Precipitation',
                          '${_weatherData!['rain']['1h']} mm',
                        ),
                      if (_weatherData!['wind'] != null)
                        _buildWeatherDetail(
                          'Wind',
                          '${_weatherData!['wind']['speed']} m/s ${_getWindDirection(_weatherData!['wind']['deg'])}',
                        ),
                      _buildWeatherDetail(
                        'Visibility',
                        '${(_weatherData!['visibility'] / 1000).toStringAsFixed(1)} km',
                      ),
                      _buildWeatherDetail(
                        'Dew Point',
                        '${_weatherData!['main']['temp_min']?.toStringAsFixed(1) ?? '--'}°C',
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Location details
                    const Text(
                      'Location Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildWeatherDetail(
                      'Latitude',
                      _currentPosition?.latitude.toStringAsFixed(6) ?? '--',
                    ),
                    _buildWeatherDetail(
                      'Longitude',
                      _currentPosition?.longitude.toStringAsFixed(6) ?? '--',
                    ),
                    _buildWeatherDetail(
                      'Accuracy',
                      '${_currentPosition?.accuracy.toStringAsFixed(2) ?? '--'} meters',
                    ),
                    const SizedBox(height: 30),

                    Center(
                      child: ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: const Text('Refresh Data'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
