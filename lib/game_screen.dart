import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
  bool _isTouchDevice = false; // Track if using touch input

  late AimCatGame _game;
  
  // Global paw cursor
  OverlayEntry? _pawOverlay;
  Offset _pawPosition = const Offset(0, 0);
  bool _isPawPressed = false; // Track paw press state
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
      onTargetHit: () {
        // Trigger paw press animation when target is hit
        _triggerPawPress();
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
            title: const Text('Reset Game?'),
            content: const Text('Are you sure you want to reset? Your current progress will be lost.'),
            actions: [
              FilledButton.tonal(
                style: const ButtonStyle(
                  mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.none),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: const ButtonStyle(
                  mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.none),
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
                child: const Text('Reset'),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.emoji_events, color: Theme.of(ctx).colorScheme.tertiary, size: 32),
              const SizedBox(width: 12),
              Text('Game Over!', style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(),
              const SizedBox(height: 16),
              _buildStatRow(ctx, Icons.star, 'Final Score', '$finalScore pts'),
              const SizedBox(height: 12),
              _buildStatRow(ctx, Icons.timer, 'Time Used', '${timeUsed}s'),
              const SizedBox(height: 12),
              _buildStatRow(ctx, Icons.speed, 'Points/Second', accuracy.toStringAsFixed(1)),
              const SizedBox(height: 12),
              _buildStatRow(ctx, Icons.sports_esports, 'Game Mode', widget.gameMode),
              const SizedBox(height: 12),
              _buildStatRow(ctx, Icons.person, 'Player', widget.username),
              const SizedBox(height: 20),
              const Divider(),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    style: const ButtonStyle(
                      mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.none),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _removePawOverlay();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Quit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    style: const ButtonStyle(
                      mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.none),
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
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play Again'),
                  ),
                ),
              ],
            ),
          ],
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
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
        Text(value, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
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
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius - borderWidth),
                    child: GestureDetector(
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
                    color: Colors.black.withOpacity(0.4),
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
