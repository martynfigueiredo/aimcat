import 'game_screen.dart';
import 'package:flutter/material.dart';

// Game mode data model
class GameModeData {
  final String name;
  final String description;
  final String imagePath;
  final IconData icon;

  const GameModeData({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.icon,
  });
}

// Available game modes
const List<GameModeData> gameModes = [
  GameModeData(
    name: 'Baby',
    description: 'Scores do not matter. 2 minutes.',
    imagePath: 'assets/modes/baby.png',
    icon: Icons.child_care,
  ),
  GameModeData(
    name: 'Toddler',
    description: 'Scores matter. 2 minutes.',
    imagePath: 'assets/modes/toddler.png',
    icon: Icons.directions_walk,
  ),
  GameModeData(
    name: 'Grandma',
    description: 'Slow and relaxed. 3 minutes.',
    imagePath: 'assets/modes/grandma.png',
    icon: Icons.elderly_woman,
  ),
  GameModeData(
    name: 'SpeedRun',
    description: 'Scores matter. 1 minute.',
    imagePath: 'assets/modes/speedrun.png',
    icon: Icons.speed,
  ),
  GameModeData(
    name: 'Marathon',
    description: 'Scores matter. 5 minutes.',
    imagePath: 'assets/modes/marathon.png',
    icon: Icons.directions_run,
  ),
  GameModeData(
    name: 'Ultra Marathon',
    description: 'Scores matter. 2 hours.',
    imagePath: 'assets/modes/ultramarathon.png',
    icon: Icons.fitness_center,
  ),
  GameModeData(
    name: 'Sayajin',
    description: 'Targets disappear very quickly. 2 min.',
    imagePath: 'assets/modes/sayajin.png',
    icon: Icons.flash_on,
  ),
  GameModeData(
    name: 'Hacker',
    description: 'Impossible speed. Funny mode. 2 min.',
    imagePath: 'assets/modes/hacker.png',
    icon: Icons.terminal,
  ),
];

class GameModeScreen extends StatelessWidget {
  final int selectedCat;
  final String username;
  const GameModeScreen({super.key, required this.selectedCat, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Game Mode')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 600;
            final crossAxisCount = isMobile ? 2 : 4;
            final maxWidth = isMobile ? screenWidth : 900.0;
            final aspectRatio = isMobile ? 0.75 : 0.7;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: aspectRatio,
                    ),
                    itemCount: gameModes.length,
                    itemBuilder: (context, index) {
                      final mode = gameModes[index];
                      return _buildModeCard(context, mode, isMobile);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, GameModeData mode, bool isMobile) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(
                selectedCat: selectedCat,
                username: username,
                gameMode: mode.name,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image area
            Expanded(
              flex: 4,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: Image.asset(
                  mode.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        mode.icon,
                        size: isMobile ? 56 : 72,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Text area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mode.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isMobile) ...[
                    const SizedBox(height: 4),
                    Text(
                      mode.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
