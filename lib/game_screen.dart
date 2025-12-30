import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/game.dart';
import 'package:share_plus/share_plus.dart';
import 'aimcat_game.dart';
import 'start_screen.dart';
import 'high_score_service.dart';
import 'global_paw_cursor.dart';

class GameScreen extends StatefulWidget {
  final int selectedCat;
  final String username;
  final String gameLevel;
  const GameScreen({super.key, required this.selectedCat, required this.username, required this.gameLevel});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int score = 0;
  double timeLeft = 60;
  bool finished = false;
  int highScore = 0;
  bool _isTouchDevice = false; // Track if using touch input

  late AimCatGame _game;
  
  // Background animation
  late AnimationController _bgController;
  late Animation<double> _bgScale;
  late Animation<Offset> _bgOffset;

  void _triggerPawPress() {
    GlobalPawCursor.of(context)?.triggerPulse();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _startGame() {
    int duration = 60;
    int initialScore = 0;
    
    switch (widget.gameLevel) {
      case 'Baby':
      case 'Toddler':
      case 'Grandma':
        duration = 30; // User requested 30 seconds
        break;
      case 'SpeedRun':
      case 'Hacker':
        duration = 10;
        break;
      case 'Marathon':
        duration = 90; // User requested 90s
        break;
      case 'Ultra Marathon':
        duration = 300; // 5 minutes
        break;
      case 'Sayajin':
        duration = 30;
        initialScore = 100;
        break;
    }
    
    if (widget.gameLevel == 'Hacker') {
      initialScore = -100;
    }

    _game = AimCatGame(
      gameDuration: duration,
      selectedCharacter: widget.selectedCat,
      gameLevel: widget.gameLevel,
      onGameUpdate: (s, t, f) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                score = s;
                timeLeft = t < 0 ? 0 : t;
                finished = f;
              });
              if (f) {
                _showFinishModal(s, timeLeft);
              }
            }
          });
        }
      },
      onResetRequest: () {
        // Reset directly without confirmation
        setState(() {
          finished = false;
          score = initialScore;
          timeLeft = duration.toDouble();
        });
        _startGame();
      },
      onFinishRequest: (finalScore, remainingTime) {
        _showFinishModal(finalScore, remainingTime);
      },
      onTargetHit: () {
        // Trigger paw press animation when target is hit
        _triggerPawPress();
      },
    );
    
    // Load high score for this level
    HighScoreService.getHighScore(widget.gameLevel).then((val) {
      if (mounted) {
        setState(() {
          highScore = val;
        });
      }
    });
    
    // Set initial score in state
    setState(() {
      score = initialScore;
      timeLeft = duration.toDouble();
    });
  }

  void _showFinishModal(int finalScore, double remainingTime) async {
    // Save score and check if it's a new record
    final bool isNewRecord = await HighScoreService.saveScore(widget.gameLevel, finalScore);
    if (isNewRecord) {
      highScore = finalScore;
    }

    final int timeUsed = (_getDuration() - remainingTime.toInt()).clamp(0, _getDuration());
    final double accuracy = finalScore > 0 ? (finalScore / (timeUsed > 0 ? timeUsed : 1)).clamp(0, 100) : 0;
    
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
        title: Row(
          children: [
            Hero(
              tag: 'main_cat_image',
              child: Image.asset(
                'assets/images/MainScreenCat.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Text('AimCat the game!',
                style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 24),
            const SizedBox(height: 12),
            _buildStatRow(ctx, Icons.star, 'Final Score', '$finalScore pts'),
            if (highScore > 0) ...[
              const SizedBox(height: 8),
              _buildStatRow(
                ctx,
                Icons.emoji_events,
                'Personal Best',
                '$highScore pts',
                isHighlighted: finalScore >= highScore && finalScore > 0,
              ),
            ],
            const SizedBox(height: 16),
            _buildStatRow(ctx, Icons.timer, 'Time Used', '${timeUsed}s'),
            const SizedBox(height: 16),
            _buildStatRow(ctx, Icons.speed, 'Points/Second', accuracy.toStringAsFixed(1)),
            const SizedBox(height: 16),
            _buildStatRow(ctx, Icons.sports_esports, 'Level', widget.gameLevel),
            const SizedBox(height: 16),
            _buildStatRow(ctx, Icons.person, 'Player', widget.username),
            const SizedBox(height: 24),
            const Divider(height: 24),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(32, 8, 32, 28),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCircularButton(
                ctx,
                icon: Icons.home,
                color: const Color(0xFF78909C),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              const SizedBox(width: 20),
              _buildCircularButton(
                ctx,
                icon: Icons.share,
                color: const Color(0xFF5E35B1),
                onPressed: () {
                  final shareText = '🎯 AimCat Score!\n\n'
                      '🏆 Score: $finalScore pts\n'
                      '⏱️ Time: ${timeUsed}s\n'
                      '📊 Points/sec: ${accuracy.toStringAsFixed(1)}\n'
                      '🎮 Level: ${widget.gameLevel}\n'
                      '😺 Player: ${widget.username}\n\n'
                      'Can you beat my score? Play AimCat now! 🐱';
                  Share.share(shareText);
                },
              ),
              const SizedBox(width: 20),
              _buildCircularButton(
                ctx,
                icon: Icons.play_arrow,
                color: const Color(0xFF4CAF50),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    finished = false;
                    score = 0;
                    timeLeft = 60;
                  });
                  _startGame();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(
    BuildContext ctx, {
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    const double buttonSize = 64;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext ctx, IconData icon, String label, String value, {bool isHighlighted = false}) {
    final colorScheme = Theme.of(ctx).colorScheme;
    final textColor = isHighlighted ? Colors.orangeAccent : colorScheme.primary;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: isHighlighted ? Colors.orangeAccent : colorScheme.primary, size: 32), // Bigger Icon
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 22)), // Bigger Label
          ],
        ),
        Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 26)), // Bigger Value
      ],
    );
  }

  int _getDuration() {
    switch (widget.gameLevel) {
      case 'Baby':
      case 'Toddler':
        return 120;
      case 'Grandma':
        return 180;
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

  String _getBackgroundPath({bool mobile = false}) {
    // Get character name and normalize it (remove spaces, lowercase)
    String characterName = characters[widget.selectedCat].name
        .replaceAll(' ', '')
        .toLowerCase();
    
    // Normalize game level (remove spaces, lowercase)
    String gameLevel = widget.gameLevel
        .replaceAll(' ', '')
        .toLowerCase();
    
    // Handle known asset typos
    if (!mobile && characterName == 'flyinghorse' && gameLevel == 'marathon') {
      characterName = 'flyinghose'; // Fixed typo in desktop asset: assets/background/bg-flyinghose-marathon.jpg
    }
    if (mobile && characterName == 'roadrunner' && gameLevel == 'speedrun') {
      gameLevel = 'speeddrun'; // Fixed typo in mobile asset: assets/background/mobile/bg-m-roadrunner-speeddrun.jpg
    }
    
    if (mobile) {
      return 'assets/background/mobile/bg-m-$characterName-$gameLevel.jpg';
    }
    return 'assets/background/bg-$characterName-$gameLevel.jpg';
  }

  @override
  void initState() {
    super.initState();
    
    // Background floating animation
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    
    _bgScale = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );
    
    _bgOffset = Tween<Offset>(
      begin: const Offset(-0.01, -0.01),
      end: const Offset(0.01, 0.01),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    Widget gameWidget = GameWidget(game: _game);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Level Selection',
        ),
        title: Text('AimCat - ${widget.gameLevel}'),
        centerTitle: true,
      ),
      body: SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Detect if mobile (portrait or small screen)
                  final bool isMobile = constraints.maxWidth < 600;
                  final bool isPortrait = constraints.maxHeight > constraints.maxWidth;
                  
                  // Use different aspect ratios based on device
                  // Mobile portrait: 9:16 (vertical mobile)
                  // Mobile landscape/tablet: 4:3 (balanced)
                  // Desktop: 16:9 (widescreen)
                  double aspectRatio;
                  if (isMobile && isPortrait) {
                    aspectRatio = 9 / 16; // Portrait mobile - matching assets
                  } else if (isMobile) {
                    aspectRatio = 4 / 3; // Landscape mobile
                  } else {
                    aspectRatio = 16 / 9; // Desktop
                  }
                  
                  // Use more screen space on mobile (98%), less on desktop (95%)
                final double screenUsage = isMobile ? 0.98 : 0.95;
                double panelWidth = constraints.maxWidth * screenUsage;
                double panelHeight = constraints.maxHeight * screenUsage;
                
                // Constrain to aspect ratio
                if (panelWidth / panelHeight > aspectRatio) {
                  panelWidth = panelHeight * aspectRatio;
                } else {
                  panelHeight = panelWidth / aspectRatio;
                }
                
                // Dynamic max size based on device
                final double maxWidth = isMobile ? constraints.maxWidth : 1200;
                final double maxHeight = isMobile ? constraints.maxHeight : 800;
                
                // Apply constraints - smaller min for mobile
                panelWidth = panelWidth.clamp(280, maxWidth);
                panelHeight = panelHeight.clamp(200, maxHeight);
                
                // Smaller border radius on mobile
                final double borderRadius = isMobile ? 8 : 16;
                final double borderWidth = isMobile ? 2 : 3;
                
                return Container(
                  width: panelWidth,
                  height: panelHeight,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: borderWidth,
                    ),
                    boxShadow: isMobile ? null : [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius - borderWidth),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image with subtle floating/breathing effect
                        AnimatedBuilder(
                          animation: _bgController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                _bgOffset.value.dx * constraints.maxWidth,
                                _bgOffset.value.dy * constraints.maxHeight,
                              ),
                              child: Transform.scale(
                                scale: _bgScale.value,
                                child: Image.asset(
                                  _getBackgroundPath(mobile: isMobile && isPortrait),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    if (isMobile && isPortrait) {
                                      // Fallback to desktop version if mobile bg is missing
                                      return Image.asset(
                                        _getBackgroundPath(mobile: false),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(color: colorScheme.surface);
                                        },
                                      );
                                    }
                                    // Fallback to solid color if image not found
                                    return Container(color: colorScheme.surface);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        // Game layer
                        GestureDetector(
                          // Handle touch drag for hitting targets
                          onPanStart: (details) {
                            _game.updatePawPosition(
                              details.localPosition.dx,
                              details.localPosition.dy,
                            );
                          },
                          onPanUpdate: (details) {
                            _game.updatePawPosition(
                              details.localPosition.dx,
                              details.localPosition.dy,
                            );
                          },
                          child: gameWidget,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ),
    );
  }
}

