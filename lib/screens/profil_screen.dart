import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forgamers/models/CustomUser.dart';
import 'package:forgamers/screens/choosing_games_screen.dart';
import 'package:forgamers/screens/welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  final CustomUser user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String facebookLink = '';
  late double latitude = 0.0 ;
  late double longitude = 0.0 ;
  late List<String> userGames =[];
  late List<bool> selectedGames = [];

  @override
  void initState() {
    super.initState();

    fetchAdditionalUserData();
  }

  Future<void> fetchAdditionalUserData() async {
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(widget.user.id).get();

      if (userSnapshot.exists) {
        setState(() {
          facebookLink = userSnapshot['fcb_link'] ?? '';
          latitude = userSnapshot['latitude'] ?? 0.0;
          longitude = userSnapshot['longitude'] ?? 0.0;
          userGames = List<String>.from(userSnapshot['games'] ?? []);
        });
      }
    } catch (error) {
      print('Error fetching additional user data: $error');
    }
  }

  Future<List<Map<String, dynamic>>> fetchGamesByNames(List<String> gameNames) async {
    try {
      QuerySnapshot gamesSnapshot = await FirebaseFirestore.instance
          .collection('games')
          .where('name', whereIn: gameNames)
          .get();

      return gamesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (error) {
      print('Error fetching games: $error');
      return [];
    }
  }

  Future<void> editProfile() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController facebookController = TextEditingController();

    nameController.text = widget.user.fullName;
    emailController.text = widget.user.email;
    phoneController.text = '+1234567890';
    facebookController.text = facebookLink;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: facebookController,
                decoration: InputDecoration(labelText: 'Facebook Link'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Save changes to Firestore
                await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
                  'fullName': nameController.text,
                  'email': emailController.text,
                  'fcb_link': facebookController.text,
                });

                // Fetch updated data
                await fetchAdditionalUserData();

                // Close the dialog
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> changeProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Save the new profile photo to Firestore
      File imageFile = File(pickedFile.path);
      String imageUrl = await uploadImage(imageFile, widget.user.id);

      await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
        'image': imageUrl,
      });

      // Fetch updated data
      await fetchAdditionalUserData();
    }
  }


  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference storageReference =
      FirebaseStorage.instance.ref().child('profile_images/$userId.jpg');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Get the download URL when the upload is complete
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (error) {
      print('Error uploading image: $error');
      // Return a placeholder URL or handle the error accordingly
      return 'https://via.placeholder.com/150'; // You can replace this with a valid placeholder URL

    }
  }





  Future<void> removeGame(String gameName) async {
    // Remove the selected game from the user's list and update Firestore
    setState(() {
      userGames.remove(gameName);
    });

    await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
      'games': userGames,
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Mon Profil'),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                editProfile();
              },
            ),
            IconButton(
              icon: Icon(Icons.logout), // Logout icon
              onPressed: () {
                // Implement logout functionality
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()), // Replace WelcomeScreen with your actual welcome screen
                      (Route<dynamic> route) => false,
                );
              },
            ),

          ],

        ),

        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(widget.user.image),
                          ),
                          IconButton(
                            icon: Icon(Icons.add_a_photo),
                            onPressed: () {
                              changeProfilePhoto();
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        '${widget.user.fullName}',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Adresse e-mail'),
              subtitle: Text(widget.user.email),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Numéro de téléphone'),
              subtitle: Text('+1234567890'),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Adresse'),
              subtitle: Text('Latitude: $latitude, Longitude: $longitude'),
            ),
            ListTile(
              leading: Icon(Icons.facebook),
              title: Text('Lien Facebook'),
              subtitle: Text(facebookLink),
            ),
            ListTile(
              leading: Icon(Icons.gamepad),
              title: Row(
                children: [
                  Text('Liste des jeux'),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChoosingGamesScreen(user: widget.user , sourcePage: "profile"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchGamesByNames(userGames),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Map<String, dynamic>> games = snapshot.data ?? [];
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      final gameName = game['name'] as String;
                      final gameImage = game['image'] as String;

                      return Card(
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  gameImage,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(gameName),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    removeGame(gameName);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
