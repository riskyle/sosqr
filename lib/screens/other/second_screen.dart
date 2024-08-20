import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled1/utils/navigation_utils.dart';

class SecondScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String accessKey;
  final String userDocID;
  final String password;
  final String department;
  final String role;

  SecondScreen(
      {
        required this.firstName,
        required this.lastName,
        required this.username,
        required this.pictureURL,
        required this.accessKey,
        required this.userDocID,
        required this.password,
        required this.department,
        required this.role
      });
  @override
  _SecondScreenState createState() => _SecondScreenState();
}
class _SecondScreenState extends State<SecondScreen> {
  int _selectedIndex = 0;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;
  String? qrNote;
  bool isScanning = false;
  bool isProcessing = false; // Flag to prevent multiple logs
  Future<QuerySnapshot<Map<String, dynamic>>> getUserFuture() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('userDocID', isEqualTo: widget.userDocID)
        .get();
  }

  void _onItemTapped(int index) {
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

  Future<void> _fetchNoteFromQRCode(String? qrCode) async {
    if (qrCode == null || isProcessing) return;
    setState(() {
      isProcessing = true; // Set the flag to true to prevent further processing
    });
    try {
      // Check if the QR code has already been scanned
      final scannedQuery = await FirebaseFirestore.instance
          .collection('allLogs')
          .where('userDocID', isEqualTo: widget.userDocID)
          .where('timestamp', isEqualTo: DateTime.timestamp())
          .get();
      if (scannedQuery.docs.isNotEmpty) {
        setState(() {
          this.qrNote = ', QR code has already been scanned.';
        });
        return;
      }
      final querySnapshot = await FirebaseFirestore.instance
          .collection('QRcode')
          .where('qrCode', isEqualTo: qrCode)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final qrNote = querySnapshot.docs.first['qrNote'];
        setState(() {
          this.qrNote = qrNote;
        });
        // Upload qrNote to Firestore if not "No note found"
        if (qrNote != 'No note found') {
          await _uploadNoteToFirestore(qrCode, qrNote);
        }
      } else {
        setState(() {
          this.qrNote = ', QR code not applicable.';
        });
      }
    } catch (e) {
      setState(() {
        this.qrNote = 'Error fetching note: $e';
      });
    } finally {
      _stopScanning();
    }
  }

  //Upload the user's Name + scanned QR code's note and save it as a new variable 'logText' ands save it in the Firestore database
  // in the allLogs collection alongside userDocID, username, and timestamp
  Future<void> _uploadNoteToFirestore(String qrCode, String qrNote) async {
    try {
      final logMessage = '${widget.firstName} $qrNote';

      await FirebaseFirestore.instance.collection('allLogs').add({
        'userDocID': widget.userDocID,
        'username': widget.username,
        'logText': logMessage,
        'timestamp': Timestamp.now(), // Optionally include timestamp
      });
      print('Log uploaded to Firestore successfully');
    } catch (e) {
      print('Error uploading log to Firestore: $e');
    }
  }
  void _startScanning() {
    setState(() {
      isScanning = true;
      isProcessing = false; // Reset the processing flag
    });
    controller?.resumeCamera();
  }
  void _stopScanning() {
    setState(() {
      isScanning = false;
    });
    controller?.pauseCamera();
  }
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  // Main Screen for the QR Scanner Tab
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Returning false disables the back button
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0057FF),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isScanning
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF0057FF),
                        ),
                        SizedBox(height: 16),
                        Text('Scanning in progress...'),
                      ],
                    )
                        : ElevatedButton(
                      onPressed: _startScanning,
                      child: Text('Start Scanning'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      (qrText != null) ? "" : 'Scan a code',
                    ),
                    SizedBox(height: 20),
                    Text(
                      (qrNote != null)
                          ? 'Note: ${widget.firstName} $qrNote'
                          : 'No note found',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      ),
    );
  }
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      controller.pauseCamera();
    });
    controller.scannedDataStream.listen((scanData) {
      if (isScanning && !isProcessing) {
        setState(() {
          qrText = scanData.code;
        });
        _fetchNoteFromQRCode(qrText);
      }
    });
  }
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}