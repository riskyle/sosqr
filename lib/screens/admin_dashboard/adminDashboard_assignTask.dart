import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardAssignTask extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String department;
  final String role;
  final String accessKey;
  final String userDocID;
  final String password;

  AdminDashboardAssignTask({
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
  _AdminDashboardAssignTaskState createState() =>
      _AdminDashboardAssignTaskState();
}

class _AdminDashboardAssignTaskState extends State<AdminDashboardAssignTask> {
  final TextEditingController _taskController = TextEditingController();
  String? _selectedUser; // To store the selected username
  String? _selectedUserDocID; // To store the selected user's DocID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: getUsers(), // Fetch users
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No Users Available');
                }

                return DropdownButton<String>(
                  hint: Text('Select User'),
                  value: _selectedUser,
                  isExpanded: true,
                  items: snapshot.data!.map((user) {
                    return DropdownMenuItem<String>(
                      value: user['username'], // Using username as the value
                      child: Text('${user['firstName']} ${user['lastName']}'),
                      onTap: () {
                        // Store the selected user's DocID
                        _selectedUserDocID = user['userDocID'];
                      },
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUser = value;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Task Description',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_selectedUser == null || _selectedUser!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select a user')),
                  );
                  return;
                }
                if (_taskController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a task description')),
                  );
                  return;
                }

                // Proceed with assigning the task
                await FirebaseFirestore.instance.collection('tasks').add({
                  'user': _selectedUser, // Storing the username
                  'userDocID': _selectedUserDocID, // Storing the user's DocID
                  'task': _taskController.text,
                  'assignedAt': Timestamp.now(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Task assigned to $_selectedUser')),
                );

                // Clear the fields after assigning
                setState(() {
                  _selectedUser = null;
                  _selectedUserDocID = null;
                  _taskController.clear();
                });
              },
              child: Text('Assign Task'),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch users from Firestore and include userDocID
  Future<List<Map<String, dynamic>>> getUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) {
      return {
        'username': doc['username'],
        'firstName': doc['firstName'],
        'lastName': doc['lastName'],
        'userDocID': doc.id, // Include the document ID
      };
    }).toList();
  }
}
