import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sick_leave.dart';
import '../providers/leave_provider.dart';

class AddEditLeaveScreen extends StatefulWidget {
  final SickLeave? leave;

  const AddEditLeaveScreen({super.key, this.leave});

  @override
  State<AddEditLeaveScreen> createState() => _AddEditLeaveScreenState();
}

class _AddEditLeaveScreenState extends State<AddEditLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _soldierName;
  late String _militaryNumber;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _reason;
  late String _notes;

  @override
  void initState() {
    super.initState();
    if (widget.leave != null) {
      _soldierName = widget.leave!.soldierName;
      _militaryNumber = widget.leave!.militaryNumber;
      _startDate = widget.leave!.startDate;
      _endDate = widget.leave!.endDate;
      _reason = widget.leave!.reason;
      _notes = widget.leave!.notes;
    } else {
      _soldierName = '';
      _militaryNumber = '';
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
      _reason = '';
      _notes = '';
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 7));
          }
        }
      });
    }
  }

  void _saveLeave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newLeave = SickLeave(
        id: widget.leave?.id,
        soldierName: _soldierName,
        militaryNumber: _militaryNumber,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reason,
        notes: _notes,
      );

      final provider = Provider.of<LeaveProvider>(context, listen: false);

      if (widget.leave == null) {
        provider.addLeave(newLeave);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الإجازة بنجاح')),
        );
      } else {
        provider.updateLeave(newLeave);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعديل الإجازة بنجاح')),
        );
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leave == null ? 'إضافة إجازة مرضية جديدة' : 'تعديل إجازة مرضية'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                initialValue: _soldierName,
                decoration: const InputDecoration(
                  labelText: 'اسم الجندي',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الجندي';
                  }
                  return null;
                },
                onSaved: (value) {
                  _soldierName = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _militaryNumber,
                decoration: const InputDecoration(
                  labelText: 'الرقم العسكري',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الرقم العسكري';
                  }
                  return null;
                },
                onSaved: (value) {
                  _militaryNumber = value!;
                },
              ),
              const SizedBox(height: 16),
              // Start Date Picker
              ListTile(
                title: const Text('تاريخ بداية الإجازة'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 16),
              // End Date Picker
              ListTile(
                title: const Text('تاريخ نهاية الإجازة'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _reason,
                decoration: const InputDecoration(
                  labelText: 'سبب الإجازة',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال سبب الإجازة';
                  }
                  return null;
                },
                onSaved: (value) {
                  _reason = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات إضافية (اختياري)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _notes = value ?? '';
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveLeave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  widget.leave == null ? 'إضافة الإجازة' : 'حفظ التعديلات',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
