import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Date utility methods
class DateUtils {
  static String getCurrentDayAndDate() {
    final now = DateTime.now();
    final day = _getDayOfWeek(now.weekday);
    final month = _getMonth(now.month);
    final date = '${now.day} $month ${now.year}';
    return '$day, $date';
  }

  static String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  static String _getMonth(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }
}

// Custom Clipper for Curved Bottom
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Sample data
class HomeData {
  static final List<Map<String, dynamic>> myFarms = [
    {
      'title': 'Field A',
      'icon': Icons.landscape,
      'details': {
        'location': 'North Section',
        'size': '2.5 acres',
        'crop': 'Wheat',
        'status': 'Growing',
      },
    },
    {
      'title': 'Field B',
      'icon': Icons.park,
      'details': {
        'location': 'South Section',
        'size': '3.2 acres',
        'crop': 'Corn',
        'status': 'Planted',
      },
    },
    {
      'title': 'Greenhouse',
      'icon': Icons.nature,
      'details': {
        'location': 'East Wing',
        'size': '0.5 acres',
        'crop': 'Tomatoes',
        'status': 'Flowering',
      },
    },
    {
      'title': 'Orchard',
      'icon': Icons.nature,
      'details': {
        'location': 'West Section',
        'size': '5.0 acres',
        'crop': 'Apples',
        'status': 'Fruiting',
      },
    },
  ];
}