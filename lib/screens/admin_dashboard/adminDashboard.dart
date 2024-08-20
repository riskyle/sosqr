import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:untitled1/screens/account/accountTab.dart';
import 'package:untitled1/screens/admin_dashboard/admin_announcementManager.dart';
import 'package:untitled1/screens/logs/logsTab.dart';
import 'package:untitled1/utils/navigation_utils.dart';
import 'adminDashboard_assignTask.dart';

class AdminDashboard extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String department;
  final String role;
  final String accessKey;
  final String userDocID;
  final String password;

  AdminDashboard({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.pictureURL,
    required this.department,
    required this.role,
    required this.accessKey,
    required this.userDocID,
    required this.password,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

      NavigationUtils.navigateToScreen(context, index,
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
      setState(() {
        _selectedIndex = index;
      });

  }

  List<Widget> _buildBody() {
    return [
      _buildDashboard(),
      LogsTab(
        username: widget.username,
        lastName: widget.lastName,
        firstName: widget.firstName,
        pictureURL: widget.pictureURL,
        accessKey: widget.accessKey,
        userDocID: widget.userDocID,
        password: widget.password,
        department: widget.department,
        role: widget.role,
      ),
      AccountTab(
        username: widget.username,
        lastName: widget.lastName,
        firstName: widget.firstName,
        pictureURL: widget.pictureURL,
        accessKey: widget.accessKey,
        userDocID: widget.userDocID,
        password: widget.password,
        department: widget.department,
        role: widget.role,
      ),
    ];
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin ${widget.firstName} ${widget.lastName}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _buildTotalUsersCard(),
            SizedBox(height: 20),
            _buildAllLogsCard(),
            SizedBox(height: 20),
            _buildUserAndLogStatsGraph(), // Modified Line Chart widget
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminAnnouncementManager(

                      ),
                  ),
                );
              },
              child: Text('Add Announcement'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalUsersCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        int totalUsers = snapshot.data?.docs.length ?? 0;
        return Card(
          child: ListTile(
            leading: Icon(Icons.people, color: Colors.blue),
            title: Text('Total Users'),
            trailing: Text('$totalUsers'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersListScreen(
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                    username: widget.username,
                    pictureURL: widget.pictureURL,
                    department: widget.department,
                    role: widget.role,
                    accessKey: widget.accessKey,
                    userDocID: widget.userDocID,
                    password: widget.password,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAllLogsCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('allLogs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        int totalLogs = snapshot.data?.docs.length ?? 0;
        return Card(
          child: ListTile(
            leading: Icon(Icons.article, color: Colors.orange),
            title: Text('All Logs'),
            trailing: Text('$totalLogs'),
          ),
        );
      },
    );
  }

  Widget _buildUserAndLogStatsGraph() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, usersSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('allLogs').snapshots(),
          builder: (context, logsSnapshot) {
            if (usersSnapshot.connectionState == ConnectionState.waiting ||
                logsSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (usersSnapshot.hasError || logsSnapshot.hasError) {
              return Center(
                  child: Text('Error: ${usersSnapshot.error ?? logsSnapshot.error}'));
            }

            // Extract the total number of users and logs
            final totalUsers = usersSnapshot.data?.docs.length ?? 0;
            final totalLogs = logsSnapshot.data?.docs.length ?? 0;

            // Create two bars: one for total users and one for total logs
            List<BarChartGroupData> barGroups = [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: totalUsers.toDouble(),
                    color: const Color(0xFF50E4FF), // Blue for Users
                    width: 20,
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: totalLogs.toDouble(),
                    color: const Color(0xFFFFA500), // Orange for Logs
                    width: 20,
                  ),
                ],
              ),
            ];

            return Card(
              child: Container(
                height: 300,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          barGroups: barGroups,
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(value.toInt().toString(),
                                      style: TextStyle(color: Colors.black));
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return Text('Total Users');
                                    case 1:
                                      return Text('All Logs');
                                    default:
                                      return Text('');
                                  }
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: const Color(0xff37434d)),
                          ),
                          minY: 0,
                          maxY: (totalUsers > totalLogs ? totalUsers : totalLogs)
                              .toDouble(),
                          barTouchData: BarTouchData(enabled: true),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem('Users', const Color(0xFF50E4FF)), // Blue
                        SizedBox(width: 20),
                        _buildLegendItem('Logs', const Color(0xFFFFA500)), // Orange
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          color: color,
        ),
        SizedBox(width: 5),
        Text(label, style: TextStyle(color: Colors.black)),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.blue[200],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

class ChartData {
  final String label;
  final int value;

  ChartData(this.label, this.value);
}

class UsersListScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String department;
  final String role;
  final String accessKey;
  final String userDocID;
  final String password;


  UsersListScreen({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.pictureURL,
    required this.department,
    required this.role,
    required this.accessKey,
    required this.userDocID,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Users'),
        backgroundColor: Color(0xFF0057FF),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];

              return ListTile(
                title: Text('${user['firstName']} ${user['lastName']}'),
                subtitle: Text(user['role']),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminDashboardAssignTask(
                          firstName: firstName,
                          lastName: lastName,
                          username: username,
                          pictureURL: pictureURL,
                          department: department,
                          role: role,
                          accessKey: accessKey,
                          userDocID: user.id, // Pass the specific userDocID
                          password: password,
                        ),
                      ),
                    );
                  },
                  child: Text('Assign Task'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
