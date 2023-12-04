import 'package:flutter/material.dart';
import 'package:forgamers/models/CustomUser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final CustomUser user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic> games = [];

  @override
  void initState() {
    super.initState();
    fetchGames();
  }

  Future<void> fetchGames() async {
    final rawgApiKey = 'a1d2b5d005b84ed8b4869efde5fc99ed';
    final rawgApiUrl = 'https://api.rawg.io/api/games';

    final response = await http.get(Uri.parse('$rawgApiUrl?key=$rawgApiKey'));

    if (response.statusCode == 200) {
      setState(() {
        games = json.decode(response.body)['results'];
      });
    } else {
      // Handle error
      print('Failed to load games: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games Blogs'),
      ),
      body: Container(
        color: Colors.black, // Dark mode background color
        child: ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final gameName = game['name'];
            final gameImage = game['background_image'];
            final gameReleased = game['released'];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(gameImage),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.black.withOpacity(0.7), // Dark overlay
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gameName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Released: $gameReleased',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
