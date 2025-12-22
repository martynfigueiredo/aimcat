import 'game_screen.dart';
import 'package:flutter/material.dart';

class GameModeScreen extends StatelessWidget {
  final int selectedCat;
  final String username;
  const GameModeScreen({super.key, required this.selectedCat, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Game Mode')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _modeTile('Baby', 'Scores do not matter. 2 minutes.', context),
          _modeTile('Toddler', 'Scores matter. 2 minutes.', context),
          _modeTile('SpeedRun', 'Scores matter. 1 minute.', context),
          _modeTile('Marathon', 'Scores matter. 5 minutes.', context),
          _modeTile('Ultra Marathon', 'Scores matter. 2 hours.', context),
          _modeTile('Sayajin', '2 minutes. Targets disappear very quickly, but possible for fast reflexes.', context),
          _modeTile('Hacker', '2 minutes. Targets blink and disappear faster than human reflexes. (Funny mode)', context),
        ],
      ),
    );
  }

  Widget _modeTile(String mode, String desc, BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(mode, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(
                selectedCat: selectedCat,
                username: username,
                gameMode: mode,
              ),
            ),
          );
        },
      ),
    );
  }
}
