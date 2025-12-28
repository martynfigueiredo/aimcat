import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flame/game.dart';
import 'package:share_plus/share_plus.dart';
import 'aimcat_game.dart';
import 'start_screen.dart';

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
  bool _isTouchDevice = false; // Track if using touch input

  late AimCatGame _game;
  
  // Global paw cursor
  OverlayEntry? _pawOverlay;
  Offset _pawPosition = const Offset(0, 0);
  final GlobalKey<_AnimatedPawState> _pawKey = GlobalKey<_AnimatedPawState>();

  void _updatePawPosition(Offset position) {
    _pawPosition = position;
    _pawOverlay?.markNeedsBuild();
  }

  void _triggerPawPress() {
    _pawKey.currentState?.triggerPress();
  }

  void _showPawOverlay() {
    // Don't show paw on touch devices
    if (_isTouchDevice) return;
    
    _removePawOverlay();
    _pawOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: _pawPosition.dx - 32,
        top: _pawPosition.dy - 32,
        child: IgnorePointer(
          child: _AnimatedPaw(key: _pawKey),
        ),
      ),
    );
    Overlay.of(context).insert(_pawOverlay!);
  }

  void _setTouchMode(bool isTouch) {
    if (isTouch && !_isTouchDevice) {
      _isTouchDevice = true;
      _removePawOverlay();
    } else if (!isTouch && _isTouchDevice) {
      _isTouchDevice = false;
      _showPawOverlay();
    }
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
      case 'Grandma':
        duration = 180;
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
          score = 0;
          timeLeft = 60;
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
          title: Row(
            children: [
              Image.asset(
                'assets/images/MainScreenCat.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Text('AimCat the game!', style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 24),
              const SizedBox(height: 12),
              _buildStatRow(ctx, Icons.star, 'Final Score', '$finalScore pts'),
              const SizedBox(height: 16),
              _buildStatRow(ctx, Icons.timer, 'Time Used', '${timeUsed}s'),
              const SizedBox(height: 16),
              _buildStatRow(ctx, Icons.speed, 'Points/Second', accuracy.toStringAsFixed(1)),
              const SizedBox(height: 16),
              _buildStatRow(ctx, Icons.sports_esports, 'Game Mode', widget.gameMode),
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
                // Home button - circular like game buttons
                _buildCircularButton(
                  ctx,
                  icon: Icons.home,
                  color: const Color(0xFF78909C),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _removePawOverlay();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
                const SizedBox(width: 20),
                // Share button - circular
                _buildCircularButton(
                  ctx,
                  icon: Icons.share,
                  color: const Color(0xFF5E35B1),
                  onPressed: () {
                    final shareText = '🎯 AimCat Score!\n\n'
                        '🏆 Score: $finalScore pts\n'
                        '⏱️ Time: ${timeUsed}s\n'
                        '📊 Points/sec: ${accuracy.toStringAsFixed(1)}\n'
                        '🎮 Mode: ${widget.gameMode}\n'
                        '😺 Player: ${widget.username}\n\n'
                        'Can you beat my score? Play AimCat now! 🐱';
                    Share.share(shareText);
                  },
                ),
                const SizedBox(width: 20),
                // Play again button - circular, highlighted
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
        ),
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
    return MouseRegion(
      cursor: SystemMouseCursors.none,
      child: GestureDetector(
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
      ),
    );
  }

  Widget _buildStatRow(BuildContext ctx, IconData icon, String label, String value) {
    final colorScheme = Theme.of(ctx).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 18)),
          ],
        ),
        Text(value, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20)),
      ],
    );
  }

  int _getDuration() {
    switch (widget.gameMode) {
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

  String _getBackgroundPath() {
    // Get character name and normalize it (remove spaces, lowercase)
    final characterName = characters[widget.selectedCat].name
        .replaceAll(' ', '')
        .toLowerCase();
    
    // Normalize game mode (remove spaces, lowercase)
    final gameMode = widget.gameMode
        .replaceAll(' ', '')
        .toLowerCase();
    
    return 'assets/background/bg-$characterName-$gameMode.jpg';
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Level Selection',
        ),
        title: Text('AimCat - ${widget.gameMode}'),
        centerTitle: true,
      ),
      body: Listener(
        onPointerDown: (event) {
          // Detect touch vs mouse
          if (event.kind == PointerDeviceKind.touch) {
            _setTouchMode(true);
          } else {
            _setTouchMode(false);
            // Trigger paw press animation on mouse click
            _triggerPawPress();
          }
        },
        onPointerHover: (event) {
          _setTouchMode(false); // Hover means mouse
          _updatePawPosition(event.position);
        },
        onPointerMove: (event) {
          _updatePawPosition(event.position);
        },
        child: MouseRegion(
          cursor: _isTouchDevice ? SystemMouseCursors.basic : SystemMouseCursors.none,
          child: SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Detect if mobile (portrait or small screen)
                  final bool isMobile = constraints.maxWidth < 600;
                  final bool isPortrait = constraints.maxHeight > constraints.maxWidth;
                  
                  // Use different aspect ratios based on device
                  // Mobile portrait: 3:4 (more vertical space)
                  // Mobile landscape/tablet: 4:3 (balanced)
                  // Desktop: 16:9 (widescreen)
                  double aspectRatio;
                  if (isMobile && isPortrait) {
                    aspectRatio = 3 / 4; // Portrait mobile - more vertical
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
                        // Background image
                        Image.asset(
                          _getBackgroundPath(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to solid color if image not found
                            return Container(color: colorScheme.surface);
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
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        ),
      ),
    );
  }
}

// Animated paw widget with press animation - focused on movement
class _AnimatedPaw extends StatefulWidget {
  const _AnimatedPaw({super.key});

  @override
  State<_AnimatedPaw> createState() => _AnimatedPawState();
}

class _AnimatedPawState extends State<_AnimatedPaw> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _translateYAnimation;

  @override
  void initState() {
    super.initState();
    
    // Press animation controller
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Scale: press down then bounce back
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.15).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(_pressController);

    // Rotation: quick tilt like a paw hitting
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.25).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.25, end: 0.12).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.12, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_pressController);
    
    // Vertical movement: push down then return
    _translateYAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 8.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 8.0, end: -4.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -4.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_pressController);
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void triggerPress() {
    _pressController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateYAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Icon(
                Icons.pets,
                size: 64,
                color: const Color(0xFFFFC107),
                shadows: [
                  // Drop shadow for depth
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
