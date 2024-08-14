import 'package:url_launcher/url_launcher.dart';
import 'package:homeservicefinder/const.dart';
import 'package:homeservicefinder/screens/user_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser!;

  // document IDs
  List<String> docIDs = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    print(_searchController.text);
    searchResultList();
  }

  List _allResults = [];
  List _resultList = [];

  searchResultList() {
    var showResults = [];
    if (_searchController.text != "") {
      for (var userSnapShot in _allResults) {
        var job = userSnapShot['job'].toString().toLowerCase();
        var city = userSnapShot['city'].toString().toLowerCase();
        var searchText = _searchController.text.toLowerCase();
        if (job.contains(searchText) || city.contains(searchText)) {
          showResults.add(userSnapShot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }
    setState(() {
      _resultList = showResults;
    });
  }

  getUserStream() async {
    var data = await FirebaseFirestore.instance
        .collection('users')
        .orderBy('job')
        .get();
    setState(() {
      _allResults = data.docs;
    });
    searchResultList();
  }

  // get docIDs
  Future<void> getDocId() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    docIDs = querySnapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getUserStream();
    super.didChangeDependencies();
  }

  void _launchURL(String phoneNumber) async {
    final String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          ' WELCOME',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
            child: const Icon(Icons.logout),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HANDS ON DECK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              onTap: () {
                // Navigate to the user profile page and pass the user details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(user: user),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text(
                'About',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              onTap: () {
                // Navigate to the about page
                // Implement the navigation logic here
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "FIND THE BEST HANDSMAN FOR YOU",
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Montserrat',
                  letterSpacing: 0.0005,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) =>
                    searchResultList(), // Call searchResultList on any change in the TextField
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                    color: Colors.grey.shade600,
                  )),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  hintText: 'Search by job or city', // Updated hintText
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FutureBuilder(
                  future: getDocId(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // If data is still loading, show the CircularProgressIndicator
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      // If there's an error while loading data, handle it here
                      return const Center(child: Text('Error loading data.'));
                    } else {
                      // Data has been loaded successfully
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            mainAxisExtent: 270,
                          ),
                          itemCount: _resultList.length,
                          itemBuilder: (context, index) {
                            var userData = _resultList[index].data()
                                as Map<String, dynamic>;
                            double itemHeight =
                                MediaQuery.of(context).size.height * 0.35;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: itemHeight,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        AspectRatio(
                                          aspectRatio:
                                              1, // 1:1 aspect ratio (square)
                                          child: ClipRect(
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              heightFactor: 0.6,
                                              child: Image.network(
                                                userData['image'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  userData['name'],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  userData['job'],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  userData['city'],
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14),
                                                ),
                                                // Text(
                                                //   userData['contact'],
                                                //   textAlign: TextAlign.center,
                                                //   style: const TextStyle(
                                                //       fontFamily: 'Montserrat',
                                                //       fontSize: 14),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 1.0,
                                    ),
                                    // Positioned phone icon at the bottom right
                                    Positioned(
                                      bottom: 3,
                                      right: 3,
                                      child: GestureDetector(
                                        onTap: () {
                                          _launchURL(userData['contact']);
                                        },
                                        child: const Icon(
                                          Icons.phone,
                                          size: 30,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
