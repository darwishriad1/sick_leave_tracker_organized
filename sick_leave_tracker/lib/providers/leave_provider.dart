import 'package:flutter/material.dart';
import '../models/sick_leave.dart';
import '../database/database_helper.dart';

class LeaveProvider with ChangeNotifier {
  List<SickLeave> _leaves = [];
  List<SickLeave> _filteredLeaves = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<SickLeave> get leaves => _filteredLeaves;

  LeaveProvider() {
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    _leaves = await _dbHelper.getLeaves();
    _filteredLeaves = _leaves;
    notifyListeners();
  }

  Future<void> addLeave(SickLeave leave) async {
    final id = await _dbHelper.insertLeave(leave);
    final newLeave = SickLeave(
      id: id,
      soldierName: leave.soldierName,
      militaryNumber: leave.militaryNumber,
      startDate: leave.startDate,
      endDate: leave.endDate,
      reason: leave.reason,
      notes: leave.notes,
    );
    _leaves.add(newLeave);
    _filteredLeaves = _leaves; // Reset filter after adding
    notifyListeners();
  }

  Future<void> updateLeave(SickLeave leave) async {
    await _dbHelper.updateLeave(leave);
    final index = _leaves.indexWhere((l) => l.id == leave.id);
    if (index != -1) {
      _leaves[index] = leave;
      _filteredLeaves = _leaves; // Reset filter after updating
      notifyListeners();
    }
  }

  Future<void> deleteLeave(int id) async {
    await _dbHelper.deleteLeave(id);
    _leaves.removeWhere((l) => l.id == id);
    _filteredLeaves = _leaves; // Reset filter after deleting
    notifyListeners();
  }

  Future<void> searchLeaves(String query) async {
    if (query.isEmpty) {
      _filteredLeaves = _leaves;
    } else {
      _filteredLeaves = await _dbHelper.searchLeaves(query);
    }
    notifyListeners();
  }

  // Get leaves that are ending soon (for notifications)
  List<SickLeave> get leavesEndingSoon {
    return _leaves.where((leave) => leave.isEndingSoon).toList();
  }

  // Get new leaves (for notifications)
  List<SickLeave> get newLeaves {
    return _leaves.where((leave) => leave.isNew).toList();
  }
}
