import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/leave_provider.dart';
import '../models/sick_leave.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LeaveProvider>(context);
    final leavesEndingSoon = provider.leavesEndingSoon;
    final newLeaves = provider.newLeaves;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Leaves Ending Soon Section
          Text(
            'إجازات على وشك الانتهاء (${leavesEndingSoon.length})',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.orange),
            textAlign: TextAlign.right,
          ),
          const Divider(),
          if (leavesEndingSoon.isEmpty)
            const Center(child: Text('لا توجد إجازات على وشك الانتهاء.')),
          ...leavesEndingSoon.map((leave) => _buildNotificationCard(context, leave, isEndingSoon: true)).toList(),

          const SizedBox(height: 30),

          // New Leaves Section
          Text(
            'إجازات جديدة مسجلة (${newLeaves.length})',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.green),
            textAlign: TextAlign.right,
          ),
          const Divider(),
          if (newLeaves.isEmpty)
            const Center(child: Text('لا توجد إجازات جديدة مسجلة.')),
          ...newLeaves.map((leave) => _buildNotificationCard(context, leave, isEndingSoon: false)).toList(),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, SickLeave leave, {required bool isEndingSoon}) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Card(
      color: isEndingSoon ? Colors.orange.shade50 : Colors.green.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          isEndingSoon ? Icons.warning : Icons.fiber_new,
          color: isEndingSoon ? Colors.orange : Colors.green,
        ),
        title: Text(
          isEndingSoon ? 'إجازة ${leave.soldierName} على وشك الانتهاء' : 'إجازة جديدة للجندي ${leave.soldierName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.right,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرقم العسكري: ${leave.militaryNumber}', textAlign: TextAlign.right),
            Text('تاريخ النهاية: ${dateFormat.format(leave.endDate)}', textAlign: TextAlign.right),
            if (isEndingSoon)
              Text(
                'تنتهي بعد ${leave.endDate.difference(DateTime.now()).inDays + 1} أيام',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.right,
              ),
          ],
        ),
        onTap: () {
          // Optionally navigate to the edit screen
        },
      ),
    );
  }
}
