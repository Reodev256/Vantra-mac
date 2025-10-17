import 'package:flutter/material.dart';
import 'home_app_bar.dart';
import 'home_search_bar.dart';
import 'home_utils.dart' as home_utils;
import 'package:table_calendar/table_calendar.dart';

class HomeHeader extends StatelessWidget {
  final String username;
  final VoidCallback onProfilePressed;
  final VoidCallback onSettingsPressed;

  const HomeHeader({
    super.key,
    required this.username,
    required this.onProfilePressed,
    required this.onSettingsPressed,
  });

  void _showCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 500,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TableCalendar(
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  focusedDay: DateTime.now(),
                  onDaySelected: (selectedDay, focusedDay) {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: home_utils.CurvedBottomClipper(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.33,
        decoration: const BoxDecoration(color: Color(0xFF41754E)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 45),
              // Top Row with greeting and avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting and date section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Hello, ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: username,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 0),
                      // Date with calendar icon
                      Row(
                        children: [
                          Text(
                            home_utils.DateUtils.getCurrentDayAndDate(), // FIXED: Removed extra ) here
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => _showCalendar(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // User avatar with menu
                  HomeAppBar(
                    username: username,
                    onProfilePressed: onProfilePressed,
                    onSettingsPressed: onSettingsPressed,
                  ),
                ],
              ),
              // Search bar
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: HomeSearchBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}