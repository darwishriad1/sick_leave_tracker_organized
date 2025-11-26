import 'package:intl/intl.dart';

class SickLeave {
  final int? id;
  final String soldierName;
  final String militaryNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String notes;

  SickLeave({
    this.id,
    required this.soldierName,
    required this.militaryNumber,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.notes = '',
  });

  // Convert a SickLeave object into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'soldierName': soldierName,
      'militaryNumber': militaryNumber,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'notes': notes,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'SickLeave{id: $id, soldierName: $soldierName, militaryNumber: $militaryNumber, startDate: ${DateFormat('yyyy-MM-dd').format(startDate)}, endDate: ${DateFormat('yyyy-MM-dd').format(endDate)}, reason: $reason}';
  }

  // Helper to calculate the duration of the leave in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  // Helper to check if the leave is ending soon (e.g., in the next 3 days)
  bool get isEndingSoon {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.inDays >= 0 && difference.inDays <= 3;
  }

  // Helper to check if the leave is new (e.g., started in the last 24 hours)
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(startDate);
    return difference.inDays == 0 && difference.inHours <= 24;
  }

  // Factory method to create a SickLeave from a Map
  static SickLeave fromMap(Map<String, dynamic> map) {
    return SickLeave(
      id: map['id'] as int?,
      soldierName: map['soldierName'] as String,
      militaryNumber: map['militaryNumber'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      reason: map['reason'] as String,
      notes: map['notes'] as String? ?? '',
    );
  }
}
