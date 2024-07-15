import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

class ChangePicture extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String username;
  final String pictureURL;
  final String accessKey;
  final String userDocID;

  ChangePicture(
      {required this.firstName,
        required this.lastName,
        required this.username,
        required this.pictureURL,
        required this.accessKey,
        required this.userDocID});

  @override
  _ChangePictureState createState() => _ChangePictureState();
}

class _ChangePictureState extends State<ChangePicture> {
  XFile? _image = null;
  String imageURL = '';

  // For opening the camera to take a picture
  Future takePhoto() async {
    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
      print(_image?.path);
    });
  }

  // For selecting a photo at the user's gallery
  Future selectPhoto() async {
    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print(_image?.path);
    });
  }



  Future<void> updatePicture() async {
    // Show the progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0057FF)),
              ),
              SizedBox(height: 10),
              Text(
                'Updating...',
                style: TextStyle(
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
              ),
            ],
          ),
        );
      },
    );

    try {
      // If an image is taken from camera or gallery
      if (_image != null) {
        // Create a reference to the location you want to upload to in Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('users/${widget.username}.jpg');

        // Upload the file to Firebase Storage
        final uploadTask = storageRef.putFile(File(_image!.path));

        // Get the download URL
        final snapshot = await uploadTask;
        final url = await snapshot.ref.getDownloadURL();

        // Store the URL in Firestore
        setState(() {
          imageURL = url;
        });

        // Query Firestore to find the document with the matching username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: widget.username)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Get the document ID of the first matching document
          String docId = querySnapshot.docs.first.id;

          // Update Firestore with the imageURL
          await FirebaseFirestore.instance
              .collection('users')
              .doc(docId)
              .update({'pictureURL': imageURL});

          print('Image uploaded: $imageURL');
        } else {
          print('No user found with username: ${widget.username}');
        }
      }

    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      // Dismiss the progress dialog
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    imageURL = widget.pictureURL;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 150, // Container width (radius * 2)
                    height: 150, // Container height (radius * 2)
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4.0, // Border width
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Shadow color
                          spreadRadius: 5, // Spread radius
                          blurRadius: 7, // Blur radius
                          offset:
                          Offset(0, 3), // Offset in the x and y directions
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: _image == null
                          ? NetworkImage(imageURL) as ImageProvider
                          : null,
                      child: _image == null
                          ? null
                          : ClipOval(
                        child: Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.camera_alt,
                            size: 20.0,
                            color:
                            Colors.white), // Adjust size and color as needed
                        onPressed: () {
                          // Dialog Box for uploading
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              contentPadding: EdgeInsets.zero,
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Icon(Icons.close,
                                              color: Colors.black, size: 20),
                                        )
                                      ],
                                    ),
                                  ),

                                  // Taking photo
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      takePhoto().then((_) {
                                        setState(() {
                                          Navigator.of(context).pop();
                                        });
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.pressed)) {
                                            // return light blue when pressed
                                            return Colors.blue[200]!;
                                          }
                                          // return blue when not pressed
                                          return Color(0xFF1F5EBD);
                                        },
                                      ),
                                      minimumSize:
                                      MaterialStateProperty.all<Size>(
                                          Size(200, 50)),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                    icon: Icon(Icons.camera_alt,
                                        color: Colors.white, size: 30),
                                    label: Text(
                                      'Take a photo',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Jost',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Center(
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                          fontFamily: 'Jost',
                                          fontSize: 16,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                  SizedBox(height: 10),

                                  //
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      selectPhoto().then((_) {
                                        setState(() {
                                          Navigator.of(context).pop();
                                        });
                                      });
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                          if (states
                                              .contains(MaterialState.pressed)) {
                                            // return light blue when pressed
                                            return Colors.blue[200]!;
                                          }
                                          // return blue when not pressed
                                          return Color(0xFF1F5EBD);
                                        },
                                      ),
                                      minimumSize:
                                      MaterialStateProperty.all<Size>(
                                          Size(200, 50)),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust the radius as needed
                                        ),
                                      ),
                                    ),
                                    icon: Icon(Icons.cloud_download_sharp,
                                        color: Colors.white, size: 30),
                                    label: Text(
                                      'Upload a photo',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Jost',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: 30)
                                ],
                              ),
                            ),
                          );
                        },
                        padding: EdgeInsets.all(0), // To remove extra padding
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.only(top: 60, left: 40, right: 40, bottom: 60),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (_image == null) {
                      String message = 'No changes were made.';
                      showDialog(
                        context: context,
                        builder: (context) => UpdatePictureDialog(message: message),
                      );
                    } else {
                      updatePicture();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {

                        if (_image == null) {
                          return Colors.grey;
                        } else if (states.contains(MaterialState.pressed)) {
                          return Colors.blue[200]!;
                        }
                        return Color(0xFF1F5EBD);
                      },
                    ),
                    minimumSize: MaterialStateProperty.all<Size>(Size(200, 60)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: Text(
                    'UPDATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Jost',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          ]
      ),
    );
  }
}

class UpdatePictureDialog extends StatelessWidget {
  final String message;

  const UpdatePictureDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Customize the border radius here
      ),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300, // Set the maximum width
            maxHeight: 150, // Set the maximum height
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ensure the column takes only necessary space
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00E5E5), Color(0xFF0057FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10.0),
                    bottom: Radius.zero,
                  ),
                ),
                height: 60,
                child: Center(
                  child: Icon(Icons.error_outline_sharp, color: Colors.white, size: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Jost',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "OK",
            style: TextStyle(
              color: Color(0xFF1F5EBD),
            ),
          ),
        ),
      ],
    );
  }
}