import 'package:flutter/material.dart';
import 'package:vantra_mobile/widgets/task_cards.dart';
import 'package:vantra_mobile/widgets/my_farm.dart';
import 'package:vantra_mobile/components/weather_card.dart';
import 'package:vantra_mobile/components/home/quick_stats.dart';
import 'package:vantra_mobile/components/home/reminders_section.dart';
import 'home_utils.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Weather card
          Transform.translate(
            offset: const Offset(0, -80),
            child: const WeatherCard(),
          ),
          
          // Quick Stats Section
          Transform.translate(
            offset: const Offset(0, -70),
            child: const QuickStats(),
          ),

          SizedBox(height: 20),
          
          // Task cards
          Transform.translate(
            offset: const Offset(0, -60),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: TaskCards(),
            ),
          ),
          
          
          // My Farm section title
          Transform.translate(
            offset: const Offset(0, -30),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Farm',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          
          // My Farm cards grid
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: HomeData.myFarms.map((farm) {
                  return MyFarmCard(
                    title: farm['title'],
                    icon: farm['icon'],
                    details: farm['details'],
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Reminders Section
          Transform.translate(
            offset: const Offset(0, -10),
            child: const RemindersSection(),
          ),
          
          SizedBox(height: 20),
        ],
      ),
    );
  }
}