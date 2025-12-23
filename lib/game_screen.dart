import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
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
  
  // Global paw cursor
  OverlayEntry? _pawOverlay;
  Offset _pawPosition = const Offset(0, 0);

  void _updatePawPosition(Offset position) {
    _pawPosition = position;
    _pawOverlay?.markNeedsBuild();
  }

  void _showPawOverlay() {
    _removePawOverlay();
    _pawOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: _pawPosition.dx - 32,
        top: _pawPosition.dy - 32,
        child: IgnorePointer(
          child: Image.asset(
            'assets/images/paw.png',
            width: 64,
            height: 64,
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_pawOverlay!);
  }

  void _removePawOverlay() {
    _pawOverlay?.remove();
    _pawOverlay = null;
  }

  @override
  void dispose() {
    _removePawOverlay();
    super.dispose();
  }

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
              if (f) {
                _showFinishModal(s, t);
              }
            }
          });
        }
      },
      onResetRequest: () {
        _showResetConfirmation();
      },
      onFinishRequest: (finalScore, remainingTime) {
        _showFinishModal(finalScore, remainingTime);
      },
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Listener(
        onPointerHover: (event) => _updatePawPosition(event.position),
        onPointerMove: (event) => _updatePawPosition(event.position),
        child: MouseRegion(
          cursor: SystemMouseCursors.none,
          child: AlertDialog(
            backgroundColor: const Color(0xFF16213e),
            title: const Text('Reset Game?', style: TextStyle(color: Colors.white)),
            content: const Text('Are you sure you want to reset? Your current progress will be lost.', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                style: ButtonStyle(
                  mouseCursor: WidgetStateProperty.all(SystemMouseCursors.none),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color(0xFFFFB300)),
                  mouseCursor: WidgetStateProperty.all(SystemMouseCursors.none),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    finished = false;
                    score = 0;
                    timeLeft = 60;
                  });
                  _startGame();
                },
                child: const Text('Reset', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFinishModal(int finalScore, double remainingTime) {
    final int timeUsed = (_getDuration() - remainingTime.toInt()).clamp(0, _getDuration());
    final double accuracy = finalScore > 0 ? (finalScore / (timeUsed > 0 ? timeUsed : 1)).clamp(0, 100) : 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => Listener(
        onPointerHover: (event) => _updatePawPosition(event.position),
        onPointerMove: (event) => _updatePawPosition(event.position),
        child: MouseRegion(
          cursor: SystemMouseCursors.none,
          child: AlertDialog(
          backgroundColor: const Color(0xFF16213e),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              const Text('Game Over!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              _buildStatRow(Icons.star, 'Final Score', '$finalScore pts', Colors.amber),
              const SizedBox(height: 12),
              _buildStatRow(Icons.timer, 'Time Used', '${timeUsed}s', Colors.cyan),
              const SizedBox(height: 12),
              _buildStatRow(Icons.speed, 'Points/Second', accuracy.toStringAsFixed(1), Colors.greenAccent),
              const SizedBox(height: 12),
              _buildStatRow(Icons.sports_esports, 'Game Mode', widget.gameMode, Colors.purpleAccent),
              const SizedBox(height: 12),
              _buildStatRow(Icons.person, 'Player', widget.username, Colors.orangeAccent),
              const SizedBox(height: 20),
              const Divider(color: Colors.white24),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.redAccent),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                mouseCursor: WidgetStateProperty.all(SystemMouseCursors.none),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _removePawOverlay();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home, color: Colors.white),
              label: const Text('Quit', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(const Color(0xFF4CAF50)),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                mouseCursor: WidgetStateProperty.all(SystemMouseCursors.none),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  finished = false;
                  score = 0;
                  timeLeft = 60;
                });
                _startGame();
              },
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text('Play Again', style: TextStyle(color: Colors.white)),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  int _getDuration() {
    switch (widget.gameMode) {
      case 'Baby':
      case 'Toddler':
        return 120;
      case 'SpeedRun':
        return 60;
      case 'Marathon':
        return 300;
      case 'Ultra Marathon':
        return 7200;
      case 'Sayajin':
      case 'Hacker':
        return 120;
      default:
        return 60;
    }
  }

  @override
  void initState() {
    super.initState();
    _startGame();
    // Show paw overlay after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPawOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget gameWidget = GameWidget(game: _game);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Level Selection',
        ),
        title: Text(
          'AimCat - ${widget.gameMode}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Listener(
        onPointerHover: (event) {
          _updatePawPosition(event.position);
        },
        onPointerMove: (event) {
          _updatePawPosition(event.position);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.none,
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate panel size based on screen size
                // Use 16:9 aspect ratio, max 1200x675, min 320x180
                double maxWidth = 1200;
                double maxHeight = 675;
                double aspectRatio = 16 / 9;
                
                double panelWidth = constraints.maxWidth * 0.95;
                double panelHeight = constraints.maxHeight * 0.95;
                
                // Constrain to aspect ratio
                if (panelWidth / panelHeight > aspectRatio) {
                  panelWidth = panelHeight * aspectRatio;
                } else {
                  panelHeight = panelWidth / aspectRatio;
                }
                
                // Apply max/min constraints
                panelWidth = panelWidth.clamp(320, maxWidth);
                panelHeight = panelHeight.clamp(180, maxHeight);
                
                return Container(
                  width: panelWidth,
                  height: panelHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f3460),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFe94560),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFe94560).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: MouseRegion(
                      onHover: (event) {
                        // Update game paw position relative to game panel
                        _game.updatePawPosition(
                          event.localPosition.dx,
                          event.localPosition.dy,
                        );
                      },
                      child: gameWidget,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
