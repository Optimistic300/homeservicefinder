import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditUserProfilePage extends StatefulWidget {
  final User user;

  EditUserProfilePage({required this.user});

  @override
  _EditUserProfilePageState createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Uint8List? _image;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? _selectedJob;
  List<String> _jobOptions = ["Electrician", "Plumber", "Carpenter", "Mason"];

  @override
  void initState() {
    super.initState();
    // Fetch user details from Firestore and populate the text fields
    _fetchUserDetails();
  }

  void _fetchUserDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      Map<String, dynamic>? userData = snapshot.data();
      setState(() {
        _nameController.text = userData?['name'] ?? '';
        _jobController.text = userData?['job'] ?? '';
        _cityController.text = userData?['city'] ?? '';
        _contactController.text = userData?['contact'] ?? '';
        _selectedJob = userData?['job'];
      });
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload the selected image to Firebase Storage
      final img = await pickedFile.readAsBytes();
      setState(() {
        _image = img; // Update the state with the selected image
      });
    }
  }

  Future<String> _uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _updateUserDetails() async {
    try {
      String imageUrl = '';
      if (_image != null) {
        // Upload the new profile image and get the download URL
        String childName = "profile_images/${widget.user.uid}.jpg";
        imageUrl = await _uploadImageToStorage(childName, _image!);
      } else {
        // If no new image is selected, retain the previous image URL
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.user.uid)
                .get();
        Map<String, dynamic>? userData = snapshot.data();
        imageUrl = userData?['image'] ?? '';
      }

      // Update user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'name': _nameController.text.trim(),
        'job': _selectedJob,
        'city': _cityController.text.trim(),
        'contact': _contactController.text.trim(),
        'image': imageUrl,
      });

      // Navigate back to the UserProfilePage after updating details
      Navigator.pop(context);
    } catch (e) {
      print("Error updating user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile image
                Center(
                  child: GestureDetector(
                    onTap: _selectImage,
                    child: _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                                widget.user.photoURL ?? 'default_image_url'),
                          ),
                  ),
                ),
                SizedBox(height: 16),
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Job dropdown
                DropdownButtonFormField<String>(
                  value: _selectedJob ?? _jobOptions[0],
                  onChanged: (newValue) {
                    setState(() {
                      _selectedJob = newValue;
                    });
                  },
                  items: _jobOptions.map((job) {
                    return DropdownMenuItem<String>(
                      value: job,
                      child: Text(job),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Job',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your job';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // City
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(labelText: 'City'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Contact
                TextFormField(
                  controller: _contactController,
                  decoration: InputDecoration(labelText: 'Phone number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Save button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, update the user details
                      _updateUserDetails();
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
