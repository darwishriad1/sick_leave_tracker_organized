import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sick_leave.dart';

class LeaveListItem extends StatelessWidget {
  final SickLeave leave;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LeaveListItem({
    super.key,
    required this.leave,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final isEndingSoon = leave.isEndingSoon;
    final isNew = leave.isNew;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEndingSoon
              ? Colors.orange
              : isNew
                  ? Colors.green
                  : Colors.blue,
          child: Text(
            '${leave.durationInDays} ي',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          leave.soldierName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الرقم العسكري: ${leave.militaryNumber}'),
            Text('من: ${dateFormat.format(leave.startDate)} إلى: ${dateFormat.format(leave.endDate)}'),
            Text('السبب: ${leave.reason}'),
            if (isEndingSoon)
              const Text(
                'تنبيه: الإجازة على وشك الانتهاء!',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            if (isNew)
              const Text(
                'جديد: إجازة مسجلة حديثًا',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف إجازة الجندي ${leave.soldierName}؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
