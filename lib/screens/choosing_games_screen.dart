import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forgamers/screens/welcome_screen.dart';

import '../models/CustomUser.dart';

class ChoosingGames extends StatefulWidget {
  final CustomUser user;

  const ChoosingGames({Key? key, required this.user}) : super(key: key);

  @override
  State<ChoosingGames> createState() => _ChoosingGamesState();
}

class _ChoosingGamesState extends State<ChoosingGames> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choosing Games'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${widget.user.fullName}!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Implement the logout functionality
                // For example, using FirebaseAuth.instance.signOut()
                await FirebaseAuth.instance.signOut();

                // Navigate back to the welcome page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
