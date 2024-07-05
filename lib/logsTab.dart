import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'second_screen.dart';
import 'accountTab.dart';

class LogsTab extends StatefulWidget {
  final String username;
  final String lastName;
  final String firstName;
  final String pictureURL;

  LogsTab({required this.username, required this.lastName, required this.firstName, required this.pictureURL});

  @override
  _LogsTabState createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // QR Scanner selected
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondScreen(username: widget.username, firstName: widget.firstName, lastName: widget.lastName, pictureURL: widget.pictureURL),
        ),
      );
    } else if (index == 1) {
      // Navigate to LogsTab

    } else if (index == 2) {
      // Navigate to AccountTab
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccountTab(username: widget.username, firstName: widget.firstName, lastName: widget.lastName, pictureURL: widget.pictureURL),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00E5E5), Color(0xFF0057FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Center(
              child: Text(
                'Logs',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Colors.transparent, // Make AppBar transparent

            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('allLogs')
            .where('actorUsername',
                isEqualTo:
                    widget.username) // Filter logs where actorUsername matches username
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No logs found for ${widget.firstName}'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var log = snapshot.data!.docs[index];
              var logText = log['logText'] ?? 'No log text available';
              var timestamp = log['timestamp']?.toDate().toString() ??
                  'No timestamp available';

              return Column(
                children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20.0),
                          bottom: Radius.circular(20.0),
                        ),
                        color: Colors.blue[700],
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            logText,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        subtitle: Center(
                          child: Text(
                            timestamp,
                            style: TextStyle(
                                fontSize: 16, fontStyle: FontStyle.italic),
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
      bottomNavigationBar: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue[700],
              unselectedItemColor: Colors.blue[200],
              items: [
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
          Positioned(
            left: MediaQuery.of(context).size.width / 3 * _selectedIndex,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              height: 3,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }
}
