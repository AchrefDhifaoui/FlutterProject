import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forgamers/models/CustomUser.dart';
import 'package:forgamers/screens/home_screen.dart';
import 'package:forgamers/screens/profil_screen.dart';

class ChoosingGamesScreen extends StatefulWidget {
  final CustomUser user;
  final String sourcePage;

  const ChoosingGamesScreen({Key? key, required this.user, required this.sourcePage}) : super(key: key);

  @override
  _ChoosingGamesScreenState createState() => _ChoosingGamesScreenState();
}

class _ChoosingGamesScreenState extends State<ChoosingGamesScreen> {
  late TextEditingController searchController;
  late List<bool> selectedGames;
  late List<DocumentSnapshot> games;
  late List<DocumentSnapshot> filteredGames = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    selectedGames = List.generate(10, (index) => false); // Initialize with false values
    fetchGames(); // Await the fetchGames method here
  }

  Future<void> fetchGames() async {
    final snapshot = await FirebaseFirestore.instance.collection('games').get();
    setState(() {
      games = snapshot.docs;
      filteredGames = games;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Choose Games'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    filteredGames = games.where((game) {
                      final gameName = game['name'] as String;
                      return gameName.toLowerCase().contains(value.toLowerCase());
                    }).toList();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search for games',
                  labelStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: filteredGames.length,
                itemBuilder: (context, index) {
                  final game = filteredGames[index].data() as Map<String, dynamic>;
                  final gameName = game['name'] as String;
                  final gameImage = game['image'] as String;

                  return Card(
                    color: Colors.grey[900],
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedGames[index] = !selectedGames[index];
                            });
                          },
                          child: Image.network(
                            gameImage,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: selectedGames[index]
                              ? Icon(
                            Icons.check_box,
                            color: Colors.white,
                          )
                              : Icon(
                            Icons.check_box_outline_blank,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final selectedGameNames = filteredGames
                    .whereIndexed((index, game) => selectedGames[index])
                    .map((game) => game['name'] as String)
                    .toList();

                await FirebaseFirestore.instance.collection('users').doc(widget.user.id).update({
                  'games': selectedGameNames,
                });

                if (widget.sourcePage == "profile") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(user: widget.user),
                    ),
                  );
                } else if (widget.sourcePage == "pickPhoto") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(user: widget.user),
                    ),
                  );
                }
              },
              child: Text('Next'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension IterableExtensions<T> on Iterable<T> {
  Iterable<U> mapIndexed<U>(U Function(int index, T item) f) sync* {
    var index = 0;
    for (final item in this) {
      yield f(index, item);
      index++;
    }
  }

  Iterable<T> whereIndexed(bool Function(int index, T item) test) sync* {
    var index = 0;
    for (final item in this) {
      if (test(index, item)) {
        yield item;
      }
      index++;
    }
  }
}
