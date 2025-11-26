import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/leave_provider.dart';
import '../models/sick_leave.dart';
import 'add_edit_leave_screen.dart';
import '../utils/export_helper.dart';
import 'notification_screen.dart';
import '../widgets/leave_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load leaves when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeaveProvider>(context, listen: false).searchLeaves('');
    });
  }

  void _navigateToEditScreen(SickLeave leave) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditLeaveScreen(leave: leave),
      ),
    );
  }

  void _deleteLeave(int id) {
    Provider.of<LeaveProvider>(context, listen: false).deleteLeave(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف الإجازة بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الإجازات المرضية'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search bar
              showSearch(
                context: context,
                delegate: LeaveSearchDelegate(
                  Provider.of<LeaveProvider>(context, listen: false),
                ),
              );
            },
          ),
                    PopupMenuButton<String>(
            onSelected: (String result) async {
              final provider = Provider.of<LeaveProvider>(context, listen: false);
              final leaves = provider.leaves;
              if (leaves.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا توجد بيانات للتصدير')),
                );
                return;
              }

              String? filePath;
              String fileType = '';
              try {
                if (result == 'pdf') {
                  filePath = await ExportHelper.exportToPdf(leaves);
                  fileType = 'PDF';
                } else if (result == 'excel') {
                  filePath = await ExportHelper.exportToExcel(leaves);
                  fileType = 'Excel';
                }

                if (filePath != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تصدير البيانات بنجاح إلى ملف $fileType'),
                      action: SnackBarAction(
                        label: 'فتح',
                        onPressed: () {
                          // In a real app, you would use a package like open_filex
                          // to open the file. Here we just show the path.
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('تم التصدير إلى $fileType'),
                              content: SelectableText('المسار: $filePath'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('حسناً'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('فشل التصدير: $e')),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'pdf',
                child: Text('تصدير إلى PDF'),
              ),
              const PopupMenuItem<String>(
                value: 'excel',
                child: Text('تصدير إلى Excel'),
              ),
            ],
            icon: const Icon(Icons.file_download),
          ),
        ],
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, provider, child) {
          if (provider.leaves.isEmpty) {
            return const Center(
              child: Text('لا توجد إجازات مسجلة حاليًا.'),
            );
          }
          return ListView.builder(
            itemCount: provider.leaves.length,
            itemBuilder: (context, index) {
              final leave = provider.leaves[index];
              return LeaveListItem(
                leave: leave,
                onEdit: () => _navigateToEditScreen(leave),
                onDelete: () => _deleteLeave(leave.id!),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditLeaveScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Simple search delegate for in-app search
class LeaveSearchDelegate extends SearchDelegate<SickLeave?> {
  final LeaveProvider provider;

  LeaveSearchDelegate(this.provider);

  @override
  String get searchFieldLabel => 'البحث بالاسم أو الرقم العسكري';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          provider.searchLeaves('');
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      provider.searchLeaves(query);
    }
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      provider.searchLeaves(query);
    } else {
      provider.searchLeaves('');
    }

    return Consumer<LeaveProvider>(
      builder: (context, provider, child) {
        if (provider.leaves.isEmpty && query.isNotEmpty) {
          return Center(
            child: Text('لا توجد نتائج للبحث عن "$query"'),
          );
        }
        return ListView.builder(
          itemCount: provider.leaves.length,
          itemBuilder: (context, index) {
            final leave = provider.leaves[index];
            return LeaveListItem(
              leave: leave,
              onEdit: () {
                close(context, leave);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditLeaveScreen(leave: leave),
                  ),
                );
              },
              onDelete: () {
                provider.deleteLeave(leave.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف الإجازة بنجاح')),
                );
                // Rebuild suggestions after deletion
                provider.searchLeaves(query);
              },
            );
          },
        );
      },
    );
  }
}
