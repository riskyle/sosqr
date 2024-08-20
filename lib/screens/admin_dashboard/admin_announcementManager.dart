import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class AdminAnnouncementManager extends StatefulWidget {
  @override
  _AdminAnnouncementManagerState createState() => _AdminAnnouncementManagerState();
}

class _AdminAnnouncementManagerState extends State<AdminAnnouncementManager> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  dynamic _selectedImage;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future<void> _uploadAnnouncement(BuildContext context, String title, String description, image) async {
    if (_imageFile == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a title and select an image.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image to Firebase Storage
      String fileName = path.basename(_imageFile!.path);
      Reference storageRef = FirebaseStorage.instance.ref().child('announcements/$fileName');
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Save announcement details to Firestore
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': downloadURL,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Announcement uploaded successfully!')),
      );

      setState(() {
        _imageFile = null;
        _titleController.clear();
        _descriptionController.clear();
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload announcement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Announcement Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            _selectedImage != null
                ? (kIsWeb
                ? Image.network(_selectedImage.path) // Display image using path
                : Image.file(io.File(_selectedImage.path)))
                : Text('No image selected.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = _titleController.text;
                final description = _descriptionController.text;
                final image = _selectedImage;

                if (title.isNotEmpty && description.isNotEmpty && image != null) {
                  _uploadAnnouncement(context, title, description, image);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please provide all required fields and select an image.')),
                  );
                }
              },
              child: Text('Upload Announcement'),
            ),
          ],
        ),
      ),
    );
  }
}
