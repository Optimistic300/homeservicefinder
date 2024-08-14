import 'package:homeservicefinder/screens/edit_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatelessWidget {
  final User user;

  UserProfilePage({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(user.displayName ?? 'User Profile'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // Handle error if needed
          return Scaffold(
            appBar: AppBar(
              title: Text(user.displayName ?? 'User Profile'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        Map<String, dynamic>? userData = snapshot.data?.data();

        String? job = userData?['job'];
        String? city = userData?['city'];
        String? contact = userData?['contact'];

        return Scaffold(
          appBar: AppBar(
            title: Text(user.displayName ?? 'User Profile'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Navigate to the edit user details screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserProfilePage(user: user),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 72,
                  backgroundImage: NetworkImage(userData!['image']),
                ),
                const SizedBox(height: 16),
                Text(
                  userData['name'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  'Job: ${job ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  'City: ${city ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                  'Contact: ${contact ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
