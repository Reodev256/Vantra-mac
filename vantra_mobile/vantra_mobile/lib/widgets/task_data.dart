import 'package:flutter/material.dart';

enum InputType { checkbox, weeklyCheckboxes, numberInput, textInput }

class TaskItem {
  final String label;
  final InputType type;
  final List<String>? options; // For weekly checkboxes
  final String? hintText; // For input fields
  final String? unit; // For amount fields (e.g., "kg", "liters")

  TaskItem({
    required this.label,
    required this.type,
    this.options,
    this.hintText,
    this.unit,
  });
}

class Task {
  final String title;
  final IconData icon;
  final String description;
  final List<String> steps;
  final String category;
  final List<TaskItem> items;

  Task({
    required this.title,
    required this.icon,
    required this.description,
    required this.steps,
    required this.category,
    required this.items,
  });
}

// All farming activities and reminders combined
final List<Task> allTasks = [
  // Vanilla Specific Activities
  Task(
    title: 'Shade\nCheck',
    icon: Icons.shield,
    description: 'Shade Management for Vanilla',
    category: 'Vanilla Care',
    steps: [
      'Check shade coverage (50-60% ideal)',
      'Inspect shade netting for damage',
      'Adjust shade levels if needed',
      'Record shade conditions'
    ],
    items: [
      TaskItem(
        label: 'Shade Coverage (%)',
        type: InputType.numberInput,
        hintText: 'Enter shade percentage',
        unit: '%',
      ),
      TaskItem(
        label: 'Shade Netting Condition',
        type: InputType.textInput,
        hintText: 'Describe netting condition...',
      ),
      TaskItem(
        label: 'Adjustments Made',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Weekly Shade Check',
        type: InputType.weeklyCheckboxes,
        options: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
      ),
    ],
  ),
  Task(
    title: 'Vine\nTraining',
    icon: Icons.arrow_upward,
    description: 'Vanilla Vine Training',
    category: 'Vanilla Care',
    steps: [
      'Inspect vine growth direction',
      'Gently train new growth on supports',
      'Secure vines with soft ties',
      'Remove unwanted side shoots'
    ],
    items: [
      TaskItem(
        label: 'Vines Trained',
        type: InputType.numberInput,
        hintText: 'Number of vines trained',
      ),
      TaskItem(
        label: 'Training Method Used',
        type: InputType.textInput,
        hintText: 'Describe training method...',
      ),
      TaskItem(
        label: 'Support Check',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Side Shoots Removed',
        type: InputType.numberInput,
        hintText: 'Number of shoots removed',
      ),
    ],
  ),
  Task(
    title: 'Pollination\nWatch',
    icon: Icons.nature,
    description: 'Flower Pollination Monitoring',
    category: 'Vanilla Care',
    steps: [
      'Check for flower development',
      'Monitor flowering stage',
      'Prepare for hand pollination',
      'Record flowering patterns'
    ],
    items: [
      TaskItem(
        label: 'Flowers Observed',
        type: InputType.numberInput,
        hintText: 'Number of flowers',
      ),
      TaskItem(
        label: 'Flowering Stage',
        type: InputType.textInput,
        hintText: 'Describe flowering stage...',
      ),
      TaskItem(
        label: 'Ready for Pollination',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Pollination Notes',
        type: InputType.textInput,
        hintText: 'Enter pollination observations...',
      ),
    ],
  ),
  Task(
    title: 'Mulching',
    icon: Icons.grass,
    description: 'Organic Mulching Application',
    category: 'Soil Care',
    steps: [
      'Check existing mulch condition',
      'Apply fresh organic mulch',
      'Maintain 2-3 inch mulch layer',
      'Water thoroughly after mulching'
    ],
    items: [
      TaskItem(
        label: 'Mulch Applied',
        type: InputType.numberInput,
        hintText: 'Amount of mulch applied',
        unit: 'kg',
      ),
      TaskItem(
        label: 'Mulch Depth',
        type: InputType.numberInput,
        hintText: 'Depth of mulch layer',
        unit: 'inches',
      ),
      TaskItem(
        label: 'Mulch Type',
        type: InputType.textInput,
        hintText: 'Type of mulch used...',
      ),
      TaskItem(
        label: 'Watered After Application',
        type: InputType.checkbox,
      ),
    ],
  ),
  Task(
    title: 'Pest\nCheck',
    icon: Icons.bug_report,
    description: 'Pest and Disease Inspection',
    category: 'Plant Health',
    steps: [
      'Inspect leaves for mites',
      'Check for fungal infections',
      'Look for root rot signs',
      'Record any pest findings'
    ],
    items: [
      TaskItem(
        label: 'Weekly Pest Inspection',
        type: InputType.weeklyCheckboxes,
        options: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
      ),
      TaskItem(
        label: 'Pests Found',
        type: InputType.textInput,
        hintText: 'Describe pests found...',
      ),
      TaskItem(
        label: 'Disease Signs Observed',
        type: InputType.textInput,
        hintText: 'Describe disease symptoms...',
      ),
      TaskItem(
        label: 'Vines Checked',
        type: InputType.numberInput,
        hintText: 'Number of vines inspected',
      ),
      TaskItem(
        label: 'Treatment Applied',
        type: InputType.checkbox,
      ),
    ],
  ),
  Task(
    title: 'Irrigation',
    icon: Icons.water_drop,
    description: 'Water Management',
    category: 'Irrigation',
    steps: [
      'Check soil moisture levels',
      'Inspect irrigation system',
      'Adjust watering schedule',
      'Monitor drainage conditions'
    ],
    items: [
      TaskItem(
        label: 'Soil Moisture Level',
        type: InputType.textInput,
        hintText: 'Describe soil moisture...',
      ),
      TaskItem(
        label: 'Water Applied',
        type: InputType.numberInput,
        hintText: 'Amount of water',
        unit: 'liters',
      ),
      TaskItem(
        label: 'Irrigation System Check',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Drainage Assessment',
        type: InputType.textInput,
        hintText: 'Describe drainage conditions...',
      ),
    ],
  ),

  // Planting & Cultivation
  Task(
    title: 'Planting',
    icon: Icons.eco,
    description: 'New Vanilla Planting',
    category: 'Cultivation',
    steps: [
      'Prepare planting area',
      'Select healthy cuttings',
      'Plant with proper spacing',
      'Water and provide support'
    ],
    items: [
      TaskItem(
        label: 'Cuttings Planted',
        type: InputType.numberInput,
        hintText: 'Number of cuttings',
      ),
      TaskItem(
        label: 'Planting Spacing',
        type: InputType.numberInput,
        hintText: 'Spacing between plants',
        unit: 'meters',
      ),
      TaskItem(
        label: 'Area Prepared',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Planting Notes',
        type: InputType.textInput,
        hintText: 'Additional planting details...',
      ),
    ],
  ),
  Task(
    title: 'Weeding',
    icon: Icons.nature_people,
    description: 'Weed Control',
    category: 'Maintenance',
    steps: [
      'Inspect for weeds',
      'Manual weed removal',
      'Apply organic weed control',
      'Dispose of weeds properly'
    ],
    items: [
      TaskItem(
        label: 'Area Weeded',
        type: InputType.numberInput,
        hintText: 'Area in square meters',
        unit: 'm²',
      ),
      TaskItem(
        label: 'Weed Type',
        type: InputType.textInput,
        hintText: 'Types of weeds removed...',
      ),
      TaskItem(
        label: 'Manual Weeding Completed',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Weed Control Applied',
        type: InputType.textInput,
        hintText: 'Weed control method used...',
      ),
    ],
  ),
  Task(
    title: 'Fertilizing',
    icon: Icons.grass,
    description: 'Organic Fertilizer Application',
    category: 'Nutrition',
    steps: [
      'Test soil nutrients',
      'Prepare organic fertilizer',
      'Apply around plant base',
      'Water after application'
    ],
    items: [
      TaskItem(
        label: 'Fertilizer Applied',
        type: InputType.numberInput,
        hintText: 'Amount of fertilizer',
        unit: 'kg',
      ),
      TaskItem(
        label: 'Fertilizer Type',
        type: InputType.textInput,
        hintText: 'Type of fertilizer used...',
      ),
      TaskItem(
        label: 'Application Method',
        type: InputType.textInput,
        hintText: 'How fertilizer was applied...',
      ),
      TaskItem(
        label: 'Watered After Application',
        type: InputType.checkbox,
      ),
    ],
  ),

  // Harvest & Post-Harvest
  Task(
    title: 'Harvest\nPrep',
    icon: Icons.agriculture,
    description: 'Harvest Preparation',
    category: 'Harvest',
    steps: [
      'Monitor bean maturity',
      'Prepare harvesting tools',
      'Plan harvest timing',
      'Arrange labor if needed'
    ],
    items: [
      TaskItem(
        label: 'Beans Ready for Harvest',
        type: InputType.numberInput,
        hintText: 'Number of mature beans',
      ),
      TaskItem(
        label: 'Harvest Tools Prepared',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Harvest Date Planned',
        type: InputType.textInput,
        hintText: 'Planned harvest date...',
      ),
      TaskItem(
        label: 'Labor Arranged',
        type: InputType.checkbox,
      ),
    ],
  ),
  Task(
    title: 'Curing',
    icon: Icons.thermostat,
    description: 'Vanilla Bean Curing',
    category: 'Processing',
    steps: [
      'Prepare curing area',
      'Monitor temperature/humidity',
      'Turn beans regularly',
      'Check curing progress'
    ],
    items: [
      TaskItem(
        label: 'Beans in Curing',
        type: InputType.numberInput,
        hintText: 'Number of beans curing',
      ),
      TaskItem(
        label: 'Temperature',
        type: InputType.numberInput,
        hintText: 'Curing temperature',
        unit: '°C',
      ),
      TaskItem(
        label: 'Humidity Level',
        type: InputType.numberInput,
        hintText: 'Humidity percentage',
        unit: '%',
      ),
      TaskItem(
        label: 'Beans Turned Today',
        type: InputType.checkbox,
      ),
    ],
  ),

  // Reminders & Certifications
  Task(
    title: 'Certification\nRenewal',
    icon: Icons.verified,
    description: 'Organic Certification Renewal',
    category: 'Administrative',
    steps: [
      'Review certification requirements',
      'Gather necessary documents',
      'Submit renewal application',
      'Schedule inspection if needed'
    ],
    items: [
      TaskItem(
        label: 'Requirements Reviewed',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Documents Prepared',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Application Submitted',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Renewal Notes',
        type: InputType.textInput,
        hintText: 'Certification renewal details...',
      ),
    ],
  ),
  Task(
    title: 'Equipment\nService',
    icon: Icons.build,
    description: 'Farm Equipment Maintenance',
    category: 'Maintenance',
    steps: [
      'Check equipment condition',
      'Schedule service appointments',
      'Perform routine maintenance',
      'Record service history'
    ],
    items: [
      TaskItem(
        label: 'Equipment Checked',
        type: InputType.textInput,
        hintText: 'List equipment checked...',
      ),
      TaskItem(
        label: 'Maintenance Performed',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Service Scheduled',
        type: InputType.textInput,
        hintText: 'Service appointment details...',
      ),
      TaskItem(
        label: 'Maintenance Notes',
        type: InputType.textInput,
        hintText: 'Maintenance details...',
      ),
    ],
  ),
  Task(
    title: 'Market\nUpdate',
    icon: Icons.trending_up,
    description: 'Market Price Research',
    category: 'Business',
    steps: [
      'Research current vanilla prices',
      'Check market trends',
      'Update pricing strategy',
      'Contact potential buyers'
    ],
    items: [
      TaskItem(
        label: 'Current Price Researched',
        type: InputType.numberInput,
        hintText: 'Current market price',
        unit: 'per kg',
      ),
      TaskItem(
        label: 'Market Trends Reviewed',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Buyers Contacted',
        type: InputType.numberInput,
        hintText: 'Number of buyers contacted',
      ),
      TaskItem(
        label: 'Market Notes',
        type: InputType.textInput,
        hintText: 'Market research details...',
      ),
    ],
  ),
  Task(
    title: 'Soil\nTesting',
    icon: Icons.science,
    description: 'Soil Quality Testing',
    category: 'Testing',
    steps: [
      'Collect soil samples',
      'Send to lab for analysis',
      'Review test results',
      'Adjust soil management'
    ],
    items: [
      TaskItem(
        label: 'Samples Collected',
        type: InputType.numberInput,
        hintText: 'Number of samples',
      ),
      TaskItem(
        label: 'Samples Sent to Lab',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Results Received',
        type: InputType.checkbox,
      ),
      TaskItem(
        label: 'Soil Test Notes',
        type: InputType.textInput,
        hintText: 'Soil testing details...',
      ),
    ],
  ),
];