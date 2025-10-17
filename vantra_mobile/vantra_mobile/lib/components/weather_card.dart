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
    return RoundedCard(
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      borderRadius: 30.0,
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        height: 120, // Increased height to accommodate new layout
        child:
            _isLoading
                ? const Center(
                  child: SpinKitFadingCircle(
                    color: Color(0xFF41754E), // Use your app's green color
                    size: 40.0,
                  ),
                )
                : Column(
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
                            // Text(
                            //   DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            //   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            // ),
                          ],
                        ),
                        // Weather Icon and Temperature
                        Row(
                          children: [
                            if (_weatherData != null &&
                                _weatherData!['weather'] != null)
                              Image.network(
                                'https://openweathermap.org/img/wn/${_weatherData!['weather'][0]['icon']}@2x.png',
                                width: 50,
                                height: 50,
                              ),
                            const SizedBox(width: 1),
                            Column(
                              children: [
                                Text(
                                  _weatherData != null
                                      ? '${(_weatherData!['main']['temp'] as double?)?.toStringAsFixed(1) ?? '--'}°C'
                                      : '--°C',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _weatherData!['weather'][0]['description']
                                      .toString()
                                      .toUpperCase(),
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

                    // Weather Description
                    if (_weatherData != null &&
                        _weatherData!['weather'] != null)
                      // Weather Details Icons Row
                      if (_weatherData != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeatherIconDetail(
                              icon: Icons.opacity,
                              value: '${_weatherData!['main']['humidity']}%',
                              label: 'Humidity',
                            ),
                            _buildWeatherIconDetail(
                              icon: Icons.air,
                              value:
                                  '${_weatherData!['wind']['speed']?.toStringAsFixed(1) ?? '--'} m/s',
                              label: 'Wind',
                            ),
                            if (_weatherData!['rain'] != null)
                              _buildWeatherIconDetail(
                                icon: Icons.water_drop,
                                value:
                                    '${_weatherData!['rain']['1h']?.toStringAsFixed(1) ?? '0'} mm',
                                label: 'Rain',
                              ),
                            _buildWeatherIconDetail(
                              icon: Icons.speed,
                              value: '${_weatherData!['main']['pressure']} hPa',
                              label: 'Pressure',
                            ),
                          ],
                        ),
                    // const SizedBox(height: 16),

                    // Feels Like & Visibility
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     _buildWeatherMiniDetail(
                    //       icon: Icons.thermostat,
                    //       value:
                    //           'Feels ${_weatherData!['main']['feels_like']?.toStringAsFixed(1) ?? '--'}°C',
                    //     ),
                    //     _buildWeatherMiniDetail(
                    //       icon: Icons.visibility,
                    //       value:
                    //           '${(_weatherData!['visibility'] / 1000).toStringAsFixed(1)} km',
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
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

  Widget _buildWeatherMiniDetail({
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
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

  // Helper method to build weather info widgets
  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 30),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
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
        boxShadow:
            boxShadow ??
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
