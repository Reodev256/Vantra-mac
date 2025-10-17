import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Day Tasks')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TaskItem(
                time: '10 AM',
                task: 'Check fruit for insect',
                priority: 'Urgent',
                priorityColor: Colors.red,
              ),
              TaskItem(
                time: '11 AM - 12 PM',
                task: 'Irrigate vegetable field',
                priority: 'Medium',
                priorityColor: Colors.orange,
              ),
              TaskItem(
                time: '12 PM - 1 PM',
                task: 'Irrigate berry',
                priority: 'Normal',
                priorityColor: Colors.green,
              ),
              SizedBox(height: 20),
              Text(
                'Inventory',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              InventoryItem(
                task: 'Regularly changing the engine oil',
                equipment: 'John Deere 6M',
              ),
              InventoryItem(
                task: 'Fire inspection and replacement',
                equipment: 'John Deere T560',
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add task functionality
                  },
                  child: Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Field Reports',
          ),
        ],
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final String time;
  final String task;
  final String priority;
  final Color priorityColor;

  const TaskItem({
    super.key,
    required this.time,
    required this.task,
    required this.priority,
    required this.priorityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(task),
            SizedBox(height: 8),
            Row(
              children: [
                Text('Priority: '),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(priority, style: TextStyle(color: priorityColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryItem extends StatelessWidget {
  final String task;
  final String equipment;

  const InventoryItem({super.key, required this.task, required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(equipment, style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
