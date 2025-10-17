import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Weather Card widget
class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Position? _currentPosition;
  String _locationMessage = 'Checking location permissions...';
  bool _isLoading = true;
  bool _showPermissionPrompt = false;
  String _cityName = '';
  String _country = '';
  Map<String, dynamic>? _weatherData;

  // Replace with your OpenWeatherMap API key
  final String _apiKey = '066400583de24e211c6b0ea168f54346';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isLoading = true;
      _locationMessage = 'Checking location permissions...';
    });

    try {
      // Check location service status
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationMessage = 'Location services are disabled. Please enable them in your device settings.';
          _showPermissionPrompt = true;
          _isLoading = false;
        });
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = 'Location permission is required to show weather data';
          _showPermissionPrompt = true;
          _isLoading = false;
        });
        return;
      }

      // If we have permission, get location
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        await _getCurrentLocation();
      }
    } catch (e) {
      setState(() {
        _locationMessage = 'Error checking permissions: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _locationMessage = 'Requesting location permission...';
      _showPermissionPrompt = false;
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = 'Location permission was denied. You can enable it in app settings.';
          _showPermissionPrompt = true;
          _isLoading = false;
        });
      } else if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationMessage = 'Location permission is permanently denied. Please enable it in app settings.';
          _showPermissionPrompt = true;
          _isLoading = false;
        });
        _showPermissionSettingsDialog();
      } else {
        // Permission granted, get location
        await _getCurrentLocation();
      }
    } catch (e) {
      setState(() {
        _locationMessage = 'Error requesting permission: ${e.toString()}';
        _showPermissionPrompt = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationMessage = 'Getting your location...';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      await _getAddressFromLatLng(position);
      await _fetchWeather(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;
        _locationMessage = 'Location fetched successfully!';
        _isLoading = false;
        _showPermissionPrompt = false;
      });
    } catch (e) {
      setState(() {
        _locationMessage = 'Error getting location: ${e.toString()}';
        _isLoading = false;
        _showPermissionPrompt = true;
      });
    }
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location access to provide weather information. '
            'Please enable location permissions in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
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

        // Convert all numeric values to double with null safety
        if (data['main'] != null) {
          data['main']['temp'] = (data['main']['temp'] as num?)?.toDouble();
          data['main']['feels_like'] = (data['main']['feels_like'] as num?)?.toDouble();
          data['main']['temp_min'] = (data['main']['temp_min'] as num?)?.toDouble();
          data['main']['temp_max'] = (data['main']['temp_max'] as num?)?.toDouble();
          data['main']['humidity'] = (data['main']['humidity'] as num?)?.toDouble();
          data['main']['pressure'] = (data['main']['pressure'] as num?)?.toDouble();
        }

        if (data['wind'] != null) {
          data['wind']['speed'] = (data['wind']['speed'] as num?)?.toDouble();
          data['wind']['deg'] = (data['wind']['deg'] as num?)?.toDouble();
        }

        if (data['rain'] != null && data['rain']['1h'] != null) {
          data['rain']['1h'] = (data['rain']['1h'] as num).toDouble();
        }

        if (data['visibility'] != null) {
          data['visibility'] = (data['visibility'] as num).toDouble();
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

  Widget _buildPermissionPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.location_off,
          size: 64,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Text(
          _locationMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _requestLocationPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF41754E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Allow Location'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text('App Settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Location and Temperature
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Location
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_cityName.isNotEmpty)
                  Text(
                    _cityName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (_country.isNotEmpty)
                  Text(
                    _country,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            // Weather Icon and Temperature
            Row(
              children: [
                if (_weatherData != null &&
                    _weatherData!['weather'] != null &&
                    _weatherData!['weather'].isNotEmpty)
                  Image.network(
                    'https://openweathermap.org/img/wn/${_weatherData!['weather'][0]['icon']}@2x.png',
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.wb_sunny, size: 50);
                    },
                  ),
                const SizedBox(width: 1),
                Column(
                  children: [
                    Text(
                      _weatherData != null &&
                              _weatherData!['main'] != null &&
                              _weatherData!['main']['temp'] != null
                          ? '${(_weatherData!['main']['temp'] as double).toStringAsFixed(1)}°C'
                          : '--°C',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _weatherData != null &&
                              _weatherData!['weather'] != null &&
                              _weatherData!['weather'].isNotEmpty
                          ? _weatherData!['weather'][0]['description']
                              .toString()
                              .toUpperCase()
                          : '--',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Weather Details Icons Row
        if (_weatherData != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherIconDetail(
                icon: Icons.opacity,
                value: _weatherData!['main'] != null &&
                        _weatherData!['main']['humidity'] != null
                    ? '${_weatherData!['main']['humidity']}%'
                    : '--%',
                label: 'Humidity',
              ),
              _buildWeatherIconDetail(
                icon: Icons.air,
                value: _weatherData!['wind'] != null &&
                        _weatherData!['wind']['speed'] != null
                    ? '${(_weatherData!['wind']['speed'] as double).toStringAsFixed(1)} m/s'
                    : '-- m/s',
                label: 'Wind',
              ),
              _buildWeatherIconDetail(
                icon: Icons.water_drop,
                value: _weatherData!['rain'] != null &&
                        _weatherData!['rain']['1h'] != null
                    ? '${(_weatherData!['rain']['1h'] as double).toStringAsFixed(1)} mm'
                    : '0 mm',
                label: 'Rain',
              ),
              _buildWeatherIconDetail(
                icon: Icons.speed,
                value: _weatherData!['main'] != null &&
                        _weatherData!['main']['pressure'] != null
                    ? '${_weatherData!['main']['pressure']} hPa'
                    : '-- hPa',
                label: 'Pressure',
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      borderRadius: 30.0,
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 120,
        child: _isLoading
            ? const Center(
                child: SpinKitFadingCircle(
                  color: Color(0xFF41754E),
                  size: 40.0,
                ),
              )
            : _showPermissionPrompt
                ? _buildPermissionPrompt()
                : _buildWeatherContent(),
      ),
    );
  }

  Widget _buildWeatherIconDetail({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}

// Reusable Rounded Card widget
class RoundedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color backgroundColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const RoundedCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.all(0),
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor = Colors.white,
    this.borderRadius = 12.0,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}