import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllAccounts extends StatefulWidget {
  @override
  _AllAccountsState createState() => _AllAccountsState();
}

class _AllAccountsState extends State<AllAccounts> {
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

class AllLogs extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String userDocID;

  AllLogs({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.userDocID,
  });

  @override
  Widget build(BuildContext context) {
    // Your AllLogs widget implementation here
    return Container();
  }
}

class EditProfile extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final String userDocID;

  EditProfile({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.userDocID,
  });

  @override
  Widget build(BuildContext context) {
    // Your EditProfile widget implementation here
    return Container();
  }
}