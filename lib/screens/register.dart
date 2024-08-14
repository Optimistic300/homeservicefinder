// import 'package:appinmotion2/readdata/image_picker.dart';
// import 'package:appinmotion2/screens/home.dart';
import 'dart:typed_data';
import 'package:homeservicefinder/components/my_textfield.dart';
import 'package:homeservicefinder/screens/login.dart';
import 'package:homeservicefinder/screens/verify.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Future<void> signUp() async {
    if (passwordConfirmed()) {
      try {
        // Step 1: Create user
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Step 2: Upload the image and get the download URL
        String childName = "profile_images/${userCredential.user!.uid}.jpg";
        String downloadUrl = await uploadImageToStorage(childName, _image!);

        // Step 3: Add user details
        addUserDetails(
          userCredential.user!.uid, // Use the user's UID as the document ID
          _nameController.text.trim(),
          _jobController.text.trim(),
          _cityController.text.trim(),
          _contactController.text.trim(),
          downloadUrl, // Use the selected image URL
          _emailController.text.trim(),
        );
      } catch (e) {
        // Handle any errors that occur during the sign-up process
        print("Error during sign-up: $e");
      }
    }
  }

  Future<void> addUserDetails(
    String userId, // Pass the user's UID as the document ID
    String name,
    String job,
    String city,
    String contact,
    String image,
    String email,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'name': name,
      'job': _selectedJob,
      'city': city,
      'contact': contact,
      'image': image,
      'email': email,
    });
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _jobController.dispose();
    _cityController.dispose();
    _contactController.dispose();
    // _imageController.dispose();
    super.dispose();
  }

  // text editing controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();
  final _cityController = TextEditingController();
  final _contactController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Uint8List? _image;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> selectImage() async {
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

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  String? _selectedJob;

  // List of job options for the dropdown
  final List<String> _jobOptions = [
    "Electrician",
    "Plumber",
    "Carpenter",
    "Mason"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Welcome Back
                const Text(
                  'Register Here',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),

                const SizedBox(height: 10),

                // Stack containing Circular Avatar and Image Icon
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage:
                                AssetImage('lib/images/profileicon.png'),
                            backgroundColor: Colors.white,
                          ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        icon: const Icon(
                          Icons.add_a_photo,
                        ),
                        onPressed: selectImage,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // name textfield
                MyTextField(
                  controller: _nameController,
                  hintText: 'Name. eg. Hatake Kakashi',
                  obsureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // job dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.grey.shade400), // Set border color
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedJob,
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: 'Select your job',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontFamily: 'Montserrat',
                        ),
                        border: InputBorder
                            .none, // Remove the default dropdown border
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedJob = newValue;
                        });
                      },
                      items: _jobOptions.map((job) {
                        return DropdownMenuItem<String>(
                          value: job,
                          child: Text(
                            job,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your job';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // location textfield
                MyTextField(
                  controller: _cityController,
                  hintText: 'City eg. Kumasi',
                  obsureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // Contact textfield
                MyTextField(
                  controller: _contactController,
                  hintText: 'Phone number',
                  obsureText: false,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length != 10) {
                      // Check if the length is not 10 digits
                      return 'Phone number must have exactly 10 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // email textfield
                MyTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  obsureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obsureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // confirm password textfield
                MyTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obsureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // sign up button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: () {
                      // Validate the form when the button is tapped
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, call the signUp function
                        signUp().then(
                          (value) => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VerifyScreen(),
                              )),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already a member?",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LogIn(),
                            ));
                      },
                      child: const Text(
                        " Log In",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
