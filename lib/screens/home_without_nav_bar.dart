import 'package:url_launcher/url_launcher.dart';
import 'package:homeservicefinder/auth/wrapper.dart';
import 'package:homeservicefinder/const.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeWithoutNavBar extends StatefulWidget {
  const HomeWithoutNavBar({Key? key}) : super(key: key);

  @override
  _HomeWithoutNavBarState createState() => _HomeWithoutNavBarState();
}

class _HomeWithoutNavBarState extends State<HomeWithoutNavBar> {
  final User? user = FirebaseAuth.instance.currentUser;
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
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          '  WELCOME',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.person),
            label: const Text(
              'Sign In',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              // Navigate to the sign-in screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Wrapper(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
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
                onChanged: (_) => searchResultList(),
                style: const TextStyle(color: Colors.black), // Set text color
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Set background color
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  hintText: 'Search by job or city',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ), // Set hint text color
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
                                    SizedBox(
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
