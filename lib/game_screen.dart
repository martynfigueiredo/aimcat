import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'aimcat_game.dart';

class GameScreen extends StatefulWidget {
  final int selectedCat;
  final String username;
  final String gameMode;
  const GameScreen({super.key, required this.selectedCat, required this.username, required this.gameMode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int score = 0;
  double timeLeft = 60;
  bool finished = false;

  late AimCatGame _game;

  void _startGame() {
    int duration = 60;
    switch (widget.gameMode) {
      case 'Baby':
      case 'Toddler':
        duration = 120;
        break;
      case 'SpeedRun':
        duration = 60;
        break;
      case 'Marathon':
        duration = 300;
        break;
      case 'Ultra Marathon':
        duration = 7200;
        break;
      case 'Sayajin':
      case 'Hacker':
        duration = 120;
        break;
    }
    _game = AimCatGame(
      gameDuration: duration,
      onGameUpdate: (s, t, f) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                score = s;
                timeLeft = t;
                finished = f;
              });
            }
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    Widget gameWidget = GameWidget(game: _game);
    // Show paw as mouse cursor on web/windows
    // (SystemMouseCursors.none hides the default, custom cursor is the paw sprite)
    // On touch, paw follows finger by Flame's PanDetector
    return Scaffold(
      // No appBar for full-screen gameplay
      body: Stack(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.none,
            child: gameWidget,
          ),
          // Floating back button (top left)
          Positioned(
            top: 16,
            left: 16,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'back_btn',
              backgroundColor: Colors.white70,
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.black),
              tooltip: 'Back to Level Selection',
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              color: Colors.white70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Player: ${widget.username}'),
                    Text('Score: $score'),
                    Text('Time: ${timeLeft.toInt()}s'),
                  ],
                ),
              ),
            ),
          ),
          if (!finished)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurple.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          finished = true;
                        });
                        _game.endGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text('Finish'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          finished = false;
                          score = 0;
                          timeLeft = 60;
                        });
                        _startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        elevation: 0,
                      ),
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              ),
            ),
          // (No custom overlay for paw; paw is rendered by Flame and UI overlays are always above)
          if (finished)
            Center(
              child: Card(
                color: const Color(0xFF22223B),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Game Over', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 16),
                      Text('Final Score: $score', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                finished = false;
                                score = 0;
                                timeLeft = 60;
                              });
                              _startGame();
                            },
                            child: const Text('Restart'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to Level Selection'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
