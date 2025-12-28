import 'game_screen.dart';
import 'package:flutter/material.dart';

// Game level data model
class GameLevelData {
  final String name;
  final String description;
  final String imagePath;
  final IconData icon;

  const GameLevelData({
    required this.name,
    required this.description,
    required this.imagePath,
    required this.icon,
  });
}

// Available game levels
const List<GameLevelData> gameLevels = [
  GameLevelData(
    name: 'Baby',
    description: 'Easy Mode: Only good targets appear. Targets stay longer. +10 bonus pts!',
    imagePath: 'assets/modes/baby.jpg',
    icon: Icons.child_care,
  ),
  GameLevelData(
    name: 'Toddler',
    description: 'Double Points! Good items 2x score. Bad items do 0 damage.',
    imagePath: 'assets/modes/toddler.jpg',
    icon: Icons.directions_walk,
  ),
  GameLevelData(
    name: 'Grandma',
    description: 'Relaxed: No clocks. Careful aiming needed (points modified).',
    imagePath: 'assets/modes/grandma.jpg',
    icon: Icons.elderly_woman,
  ),
  GameLevelData(
    name: 'SpeedRun',
    description: 'Fast! Only 10 seconds. Targets appear 4x faster.',
    imagePath: 'assets/modes/speedrun.jpg',
    icon: Icons.speed,
  ),
  GameLevelData(
    name: 'Marathon',
    description: 'Endurance: 90 seconds of focus.',
    imagePath: 'assets/modes/marathon.jpg',
    icon: Icons.directions_run,
  ),
  GameLevelData(
    name: 'Ultra Marathon',
    description: 'The Ultimate Test: 5 minutes long!',
    imagePath: 'assets/modes/ultramarathon.jpg',
    icon: Icons.fitness_center,
  ),
  GameLevelData(
    name: 'Sayajin',
    description: 'Start with 100pts! 30s duration. Good=2x, Bad=50% dmg.',
    imagePath: 'assets/modes/sayajin.jpg',
    icon: Icons.flash_on,
  ),
  GameLevelData(
    name: 'Hacker',
    description: 'Start w/-100pts. 10s only. EVERYTHING is 200pts. 8x Speed!',
    imagePath: 'assets/modes/hacker.jpg',
    icon: Icons.terminal,
  ),
];

class LevelSelectionScreen extends StatelessWidget {
  final int selectedCat;
  final String username;
  const LevelSelectionScreen({super.key, required this.selectedCat, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
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
                    itemCount: gameLevels.length,
                    itemBuilder: (context, index) {
                      final level = gameLevels[index];
                      return _buildLevelCard(context, level, isMobile);
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

  Widget _buildLevelCard(BuildContext context, GameLevelData level, bool isMobile) {
    return _HoverableCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              selectedCat: selectedCat,
              username: username,
              gameLevel: level.name,
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
                level.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      level.icon,
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
                  level.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Bigger title
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isMobile) ...[
                  const SizedBox(height: 8),
                  Text(
                    level.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16, // Bigger description
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Hoverable card widget with purple border on hover
class _HoverableCard extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  const _HoverableCard({
    required this.onTap,
    required this.child,
  });

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? primaryColor : Colors.transparent,
              width: 3,
            ),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.child,
        ),
      ),
    );
  }
}
