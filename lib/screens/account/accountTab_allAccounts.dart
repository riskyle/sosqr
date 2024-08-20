import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'accountTab_editProfile.dart';
import 'package:intl/intl.dart';



class AllAccounts extends StatefulWidget {
  @override
  _AllAccountsState createState() => _AllAccountsState();
}

class _AllAccountsState extends State<AllAccounts> {
  DateTimeRange? _selectedDateRange; // Add this to hold the selected date range
  bool _isSearching = false;
  TextEditingController _searchController = TextEditingController();
  String _searchText = "";


  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: !_isSearching
            ? Text('All Accounts',
            style: TextStyle(
                fontFamily: 'Jost',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white))
            : TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
        ),
        backgroundColor: Color(0xFF0057FF),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userDocs = snapshot.data!.docs;
          var filteredDocs = userDocs.where((doc) {
            var userData = doc.data() as Map<String, dynamic>;
            String firstName = userData['firstName'] ?? 'No first name';
            String lastName = userData['lastName'] ?? 'No last name';
            String username = userData['username'] ?? 'No username';

            return firstName.toLowerCase().contains(_searchText) ||
                lastName.toLowerCase().contains(_searchText) ||
                username.toLowerCase().contains(_searchText);
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              var userDoc = filteredDocs[index];
              var userData = userDoc.data() as Map<String, dynamic>;

              // Use null-aware operators to handle missing data
              String firstName = userData['firstName'] ?? 'No first name';
              String lastName = userData['lastName'] ?? 'No last name';
              String username = userData['username'] ?? 'No username';
              String pictureURL = userData['pictureURL'] ??
                  'https://default-image-url.com/default.jpg';
              String accessKey = userData['accessKey'] ?? 'No access key';
              String password = userData['password'] ?? 'No password';
              String userDocID = userData['userDocID'] ?? 'No userDocID';
              String department = userData['department'] ?? '';
              String role = userData['role'] ?? '';

              return Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(pictureURL),
                        ),
                        SizedBox(width: 20),
                        Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$firstName $lastName',
                                style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              Text(
                                username,
                                style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                'Access: $accessKey',
                                style: TextStyle(
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to AllLogs with user data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllLogs(
                            firstName: firstName,
                            lastName: lastName,
                            username: username,
                            userDocID: userDocID,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Logs',
                            style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to EditProfile with user data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(
                            firstName: firstName,
                            lastName: lastName,
                            username: username,
                            password: password,
                            userDocID: userDocID,
                            department: department,
                            role: role,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(
                                fontFamily: 'Jost',
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider()
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class AllLogs extends StatefulWidget {
  final String username;
  final String lastName;
  final String firstName;
  final String userDocID;

  AllLogs({
    required this.username,
    required this.lastName,
    required this.firstName,
    required this.userDocID,
  });

  @override
  _AllLogsState createState() => _AllLogsState();
}

class _AllLogsState extends State<AllLogs> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
  }

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

  Future<void> _exportLogsToPDF() async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date range first')),
      );
      return;
    }

    try {
      final Directory? appDocDir = await getExternalStorageDirectory();
      if (appDocDir != null) {
        final String appDocPath = appDocDir.path;
        final File tempFile = File('$appDocPath/logs_${DateTime.now().toIso8601String()}.pdf');

        // Load the logo image from assets
        final ByteData logoData = await rootBundle.load('assets/SOS-logo.png');
        final Uint8List logoBytes = logoData.buffer.asUint8List();
        final pw.ImageProvider logo = pw.MemoryImage(logoBytes);

        // Fetch logs from Firestore
        QuerySnapshot logsSnapshot = await FirebaseFirestore.instance
            .collection('allLogs')
            .where('userDocID', isEqualTo: widget.userDocID)
            .get();

        final pdf = pw.Document();
        final logEntries = logsSnapshot.docs.map((doc) {
          String logText = doc['logText'] ?? 'No log text available';
          String timestamp = (doc['timestamp'] as Timestamp).toDate().toString();
          return {
            'logText': logText,
            'timestamp': timestamp,
          };
        }).toList();

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  pw.Image(logo, width: 300, height: 300), //Logo image
                  // Header with user's first and last name
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children:[
                      pw.Text(
                      '${widget.firstName} ${widget.lastName} - Logs',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20), // Space between header and logs
                  // Log entries
                  ...logEntries.map((entry) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.symmetric(vertical: 4.0),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            entry['logText'] ?? 'No log text available',
                            style: pw.TextStyle(fontSize: 18, color: PdfColors.black),
                          ),
                          pw.Text(
                            entry['timestamp'] ?? 'No timestamp available',
                            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        );

        // Save PDF locally
        await tempFile.writeAsBytes(await pdf.save());

        // Open the file
        await OpenFile.open(tempFile.path);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File downloaded and opened successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access external storage'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export logs: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF0057FF),
        automaticallyImplyLeading: false,
        title: TextButton(
          onPressed: _selectDateRange,
          child: Text(
            _selectedDateRange == null
                ? 'Select Date Range'
                : '${DateFormat('MM/dd/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd/yyyy').format(_selectedDateRange!.end)}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: _selectedDateRange == null
          ? Center(
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
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No logs found for ${widget.firstName}'));
          }

          var filteredDocs = snapshot.data!.docs.where((doc) {
            var timestamp = (doc['timestamp'] as Timestamp).toDate();
            return timestamp.isAfter(_selectedDateRange!.start) &&
                timestamp.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(child: Text('No logs found for the selected date range.'));
          }

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              var log = filteredDocs[index];
              var logText = log['logText'] ?? 'No log text available';
              var timestamp = log['timestamp']?.toDate().toString() ?? 'No timestamp available';

              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
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
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                      subtitle: Center(
                        child: Text(
                          timestamp,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),
                  ),
                  Divider()
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _exportLogsToPDF();
        },
        child: Icon(Icons.download),
        backgroundColor: Color(0xFF0057FF),
      ),
    );
  }
}


