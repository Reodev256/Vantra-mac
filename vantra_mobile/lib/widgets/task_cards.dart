import 'package:flutter/material.dart';
import 'task_data.dart';
import 'task_detail_page.dart';

class TaskCards extends StatelessWidget {
  const TaskCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Vanilla Farming Activities',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Spacer(),
            if (allTasks.length > 3)
              Row(
                children: [
                  Text(
                    '${allTasks.length} activities',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),
        
        // Horizontal scrollable cards using ListView
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allTasks.length,
            itemBuilder: (context, index) {
              final task = allTasks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailPage(task: task),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12.0),
                  child: TinyTaskCard(
                    title: task.title,
                    icon: task.icon,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TinyTaskCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const TinyTaskCard({
    super.key, 
    required this.title, 
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: const Color(0xFF41754E),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}