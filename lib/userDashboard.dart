import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/screens/other/second_screen.dart';


class UserDashboard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String department;
  final String role;
  final String accessKey;
  final String userDocID;
  final String password;

  UserDashboard({
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

  // Fetch user tasks from Firestore
  Future<List<Map<String, dynamic>>> fetchUserTasks() async {
    final tasksQuery = await FirebaseFirestore.instance
        .collection('tasks')
        .where('user', isEqualTo: userDocID)
        .get();

    return tasksQuery.docs.map((doc) => {
      'id': doc.id,
      'task': doc['task'],
      'assignedAt': (doc['assignedAt'] as Timestamp).toDate(),
      'status': 'Pending' // Default status if you don't store it in Firestore
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(pictureURL),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  '$firstName $lastName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  username,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Divider(),
              ListTile(
                leading: Icon(Icons.business),
                title: Text('Department'),
                subtitle: Text(department),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                onTap: () {
                  // Navigate to notifications screen
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.task),
                title: Text('My Tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserTasksScreen(userDocID: userDocID),
                    ),
                  );
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Navigate to settings screen
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Support'),
                onTap: () {
                  // Navigate to support screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// New screen to display tasks and update their status
class UserTasksScreen extends StatefulWidget {
  final String userDocID;

  UserTasksScreen({required this.userDocID});

  @override
  _UserTasksScreenState createState() => _UserTasksScreenState();
}

class _UserTasksScreenState extends State<UserTasksScreen> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = fetchUserTasks();
  }

  // Fetch user tasks from Firestore
  Future<List<Map<String, dynamic>>> fetchUserTasks() async {
    try {
      print("Fetching tasks for userDocID: ${widget.userDocID}");

      // Fetch tasks from Firestore where user matches the userDocID
      final tasksQuery = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userDocID', isEqualTo: widget.userDocID)
          .get();

      // Map tasks to a list of maps
      return tasksQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'task': data['task'],
          'assignedAt': (data['assignedAt'] as Timestamp).toDate(),
          'status': data['status'] ?? 'Pending',
        };
      }).toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching tasks.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks assigned.'));
          }

          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task['task']),
                subtitle: Text(
                    'Assigned At: ${task['assignedAt']} \nStatus: ${task['status']}'),
              );
            },
          );
        },
      ),
    );
  }
}
