import 'game_screen.dart';
import 'package:flutter/material.dart';
import 'high_score_service.dart';
import 'animation_utils.dart';
import 'start_screen.dart'; // For characters list

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
    description: 'Start w/-100pts. 10s only. EVERYTHING is 200pts. 64x Speed!',
    imagePath: 'assets/modes/hacker.jpg',
    icon: Icons.terminal,
  ),
];

class LevelSelectionScreen extends StatefulWidget {
  final int selectedCat;
  final String username;
  const LevelSelectionScreen({super.key, required this.selectedCat, required this.username});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  Map<String, HighScoreData?> _highScores = {};

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final levels = gameLevels.map((l) => l.name).toList();
    final scores = await HighScoreService.getAllHighScores(levels);
    if (mounted) {
      setState(() {
        _highScores = scores;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      body: SparkleBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isMobile = screenWidth < 600;
              final crossAxisCount = isMobile ? 2 : 4;
              final maxWidth = isMobile ? screenWidth : 900.0;
              final aspectRatio = isMobile ? 0.75 : 0.7;

              return Column(
                children: [
                  // Selected character header
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Hero(
                              tag: 'character_portrait_${characters[widget.selectedCat].name}',
                              child: Image.asset(
                                characters[widget.selectedCat].imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              characters[widget.selectedCat].name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Player: ${widget.username}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                  // Level grid
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                              final data = _highScores[level.name];
                              final score = data?.score ?? 0;
                              return StaggeredEntry(
                                index: index,
                                child: _buildLevelCard(context, level, isMobile, score),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, GameLevelData level, bool isMobile, int highScore) {
    final character = characters[widget.selectedCat];
    
    return _HoverableCard(
      onTap: () {
        Navigator.push(
          context,
          AimCatPageRoute(
            page: GameScreen(
              selectedCat: widget.selectedCat,
              username: widget.username,
              gameLevel: level.name,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image area and High Score Badge
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
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
                  // High Score Badge (if any)
                  if (highScore > 0)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)], // Warm amber gradient
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '$highScore pts',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ),
          // Text area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  level.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
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
                      fontSize: 14,
                      height: 1.4,
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

class _HoverableCardState extends State<_HoverableCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered ? primaryColor.withValues(alpha: 0.5) : Colors.transparent,
              width: 3,
            ),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
