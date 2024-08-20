import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Add this for date formatting
import 'package:untitled1/utils/navigation_utils.dart';

class LogsTab extends StatefulWidget {
  final String username, lastName, firstName, pictureURL, accessKey, userDocID, password, department, role;

  const LogsTab({
    required this.username,
    required this.lastName,
    required this.firstName,
    required this.pictureURL,
    required this.accessKey,
    required this.userDocID,
    required this.password,
    required this.department,
    required this.role,
  });

  @override
  _LogsTabState createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> {
  DateTimeRange? _selectedDateRange; // Add this to hold the selected date range
  int _selectedIndex = 1; // Default to LogsTab

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        NavigationUtils.navigateToScreen(
          context,
          index,
          username: widget.username,
          firstName: widget.firstName,
          lastName: widget.lastName,
          pictureURL: widget.pictureURL,
          accessKey: widget.accessKey,
          userDocID: widget.userDocID,
          password: widget.password,
          department: widget.department,
          role: widget.role,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF0057FF),
          automaticallyImplyLeading: false,
          title: TextButton(
            onPressed: _selectDateRange,
            child: Text(
              _selectedDateRange == null
                  ? 'Select Date Range'
                  : '${DateFormat('MM/dd/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd/yyyy').format(_selectedDateRange!.end)}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: _selectedDateRange == null
            ? const Center(
          child: Text(
            'Please select a date range to view logs',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        )
            : StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('allLogs')
              .where('username', isEqualTo: widget.username)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                  child: Text('No logs found for ${widget.firstName}'));
            }

            var filteredDocs = snapshot.data!.docs.where((doc) {
              var timestamp = (doc['timestamp'] as Timestamp).toDate();
              return timestamp.isAfter(_selectedDateRange!.start) &&
                  timestamp.isBefore(
                      _selectedDateRange!.end.add(const Duration(days: 1)));
            }).toList();

            if (filteredDocs.isEmpty) {
              return const Center(
                  child: Text('No logs found for the selected date range.'));
            }

            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                var log = filteredDocs[index];
                var logText = log['logText'] ?? 'No log text available';
                var timestamp = log['timestamp']?.toDate().toString() ??
                    'No timestamp available';

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.0),
                          bottom: Radius.circular(20.0),
                        ),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            logText,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                        ),
                        subtitle: Center(
                          child: Text(
                            timestamp,
                            style: const TextStyle(
                                fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.blue[200],
          items: widget.accessKey == 'admin' ?
          const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ]
          : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'QR Scanner',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note_alt),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
