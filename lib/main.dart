import 'start_screen.dart';
import 'theme_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
// import 'firebase_options.dart';
import 'ranking_screen.dart';
import 'about_screen.dart';
import 'help_screen.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProviderWidget(
      themeProvider: _themeProvider,
      child: MaterialApp(
        title: 'AimCat',
        theme: ThemeProvider.lightTheme,
        darkTheme: ThemeProvider.darkTheme,
        themeMode: _themeProvider.materialThemeMode,
        home: const HomeScreen(),
        builder: (context, child) {
          // Wrap all routes with GlobalPawCursor
          return GlobalPawCursor(child: child ?? const SizedBox());
        },
      ),
    );
  }
}

// Global paw cursor that works across all screens
class GlobalPawCursor extends StatefulWidget {
  final Widget child;
  const GlobalPawCursor({super.key, required this.child});

  @override
  State<GlobalPawCursor> createState() => _GlobalPawCursorState();
}

class _GlobalPawCursorState extends State<GlobalPawCursor>
    with TickerProviderStateMixin {
  Offset _pawPosition = const Offset(-100, -100);
  bool _isTouchDevice = false;
  final GlobalKey<_GlobalAnimatedPawState> _pawKey =
      GlobalKey<_GlobalAnimatedPawState>();

  // Trail effect with object pooling
  static const int _maxTrailLength = 20;
  static const int _poolSize = 30; // Pool size slightly larger than max trail
  final List<_TrailParticle> _trailParticles = [];
  final List<_TrailParticle> _particlePool = [];
  late AnimationController _trailController;
  bool _needsRebuild = false;

  // Pre-allocate pool on init
  void _initParticlePool() {
    for (int i = 0; i < _poolSize; i++) {
      _particlePool.add(_TrailParticle(position: Offset.zero, opacity: 0, scale: 0));
    }
  }

  _TrailParticle _acquireParticle(Offset position, double opacity, double scale) {
    if (_particlePool.isNotEmpty) {
      final particle = _particlePool.removeLast();
      particle.position = position;
      particle.opacity = opacity;
      particle.scale = scale;
      return particle;
    }
    // Fallback: create new if pool exhausted
    return _TrailParticle(position: position, opacity: opacity, scale: scale);
  }

  void _releaseParticle(_TrailParticle particle) {
    if (_particlePool.length < _poolSize) {
      particle.opacity = 0;
      _particlePool.add(particle);
    }
  }

  @override
  void initState() {
    super.initState();
    _initParticlePool();
    _trailController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 16), // ~60fps
          )
          ..addListener(_updateTrail)
          ..repeat();
  }

  @override
  void dispose() {
    _trailController.dispose();
    _trailParticles.clear();
    _particlePool.clear();
    super.dispose();
  }

  void _updateTrail() {
    bool hasChanges = false;
    
    // Process particles in reverse to safely remove
    for (int i = _trailParticles.length - 1; i >= 0; i--) {
      final particle = _trailParticles[i];
      particle.opacity -= 0.06;
      particle.scale *= 0.96;
      if (particle.opacity <= 0) {
        _trailParticles.removeAt(i);
        _releaseParticle(particle);
      }
      hasChanges = true;
    }
    
    // Only rebuild if there are particles or changes
    if (hasChanges || _needsRebuild) {
      _needsRebuild = false;
      setState(() {});
    }
  }

  void _updatePawPosition(Offset position) {
    // Add trail particle at current position using object pool
    if (!_isTouchDevice && (_pawPosition - position).distanceSquared > 9) { // Use squared distance
      _trailParticles.add(_acquireParticle(_pawPosition, 0.7, 0.6));
      // Limit trail length - release excess to pool
      while (_trailParticles.length > _maxTrailLength) {
        _releaseParticle(_trailParticles.removeAt(0));
      }
    }

    _pawPosition = position;
    _needsRebuild = true;
  }

  void _triggerPawPress() {
    _pawKey.currentState?.triggerPress();
    // Add burst of particles on click using pool
    for (int i = 0; i < 8; i++) {
      final offset = Offset(
        _pawPosition.dx + 20 * (i % 2 == 0 ? 1 : -1) * (0.5 + (i / 16)),
        _pawPosition.dy + 20 * (i % 3 == 0 ? 1 : -1) * (0.5 + (i / 16)),
      );
      _trailParticles.add(_acquireParticle(offset, 1.0, 0.4 + (i % 3) * 0.1));
    }
    _needsRebuild = true;
  }

  void _setTouchMode(bool isTouch) {
    if (isTouch != _isTouchDevice) {
      setState(() {
        _isTouchDevice = isTouch;
        if (isTouch) _trailParticles.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.touch) {
          _setTouchMode(true);
        } else {
          _setTouchMode(false);
          _triggerPawPress();
        }
      },
      onPointerHover: (event) {
        _setTouchMode(false);
        _updatePawPosition(event.position);
      },
      onPointerMove: (event) {
        _updatePawPosition(event.position);
      },
      child: MouseRegion(
        cursor: _isTouchDevice
            ? SystemMouseCursors.basic
            : SystemMouseCursors.none,
        child: Stack(
          children: [
            // Main app content
            widget.child,
            // Trail particles (only on non-touch devices) - wrapped in RepaintBoundary for performance
            if (!_isTouchDevice)
              RepaintBoundary(
                child: Stack(
                  children: _trailParticles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final particle = entry.value;
                    // Scale from 0.4 (oldest) to 0.9 (newest) based on position in list
                    final progressiveScale =
                        0.4 + (index / _trailParticles.length) * 0.5;
                    final finalScale = progressiveScale * particle.scale;
                    return Positioned(
                      left: particle.position.dx - 16 * finalScale,
                      top: particle.position.dy - 16 * finalScale,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: particle.opacity.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: finalScale,
                            child: Icon(
                              Icons.pets,
                              size: 32,
                              color: Color.lerp(
                                const Color(0xFFFFC107),
                                const Color(0xFFFF9800),
                                1 - particle.opacity,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            // Paw cursor overlay (only on non-touch devices)
            if (!_isTouchDevice)
              Positioned(
                left: _pawPosition.dx - 32,
                top: _pawPosition.dy - 32,
                child: IgnorePointer(child: _GlobalAnimatedPaw(key: _pawKey)),
              ),
          ],
        ),
      ),
    );
  }
}

// Trail particle data class
class _TrailParticle {
  Offset position;
  double opacity;
  double scale;

  _TrailParticle({
    required this.position,
    required this.opacity,
    required this.scale,
  });
}

// Animated paw widget for global cursor
class _GlobalAnimatedPaw extends StatefulWidget {
  const _GlobalAnimatedPaw({super.key});

  @override
  State<_GlobalAnimatedPaw> createState() => _GlobalAnimatedPawState();
}

class _GlobalAnimatedPawState extends State<_GlobalAnimatedPaw>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _translateYAnimation;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.7,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.7,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(_pressController);

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -0.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.25,
          end: 0.12,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.12,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_pressController);

    _translateYAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 8.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 8.0,
          end: -4.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -4.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProviderWidget.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(), // Remove title text
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeIcon),
            tooltip: 'Theme: ${themeProvider.themeLabel}',
            onPressed: () {
              _showThemeDialog(context, themeProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Ranking',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RankingScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 600;
            // Image takes up to 80% of screen height, max 700px
            final imageSize = (screenHeight * 0.8).clamp(
              350.0,
              isMobile ? 600.0 : 700.0,
            );

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    // AimCat title
                    Text(
                      'AimCat',
                      style: TextStyle(
                        fontSize: isMobile ? 48 : 64,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                        shadows: [
                          Shadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Clickable cat image to start the game
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StartScreen(),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/MainScreenCat.png',
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Text(
                              'Click to Play',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System Default'),
              selected: themeProvider.themeMode == AppThemeMode.system,
              onTap: () {
                themeProvider.setThemeMode(AppThemeMode.system);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Mode'),
              selected: themeProvider.themeMode == AppThemeMode.light,
              onTap: () {
                themeProvider.setThemeMode(AppThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              selected: themeProvider.themeMode == AppThemeMode.dark,
              onTap: () {
                themeProvider.setThemeMode(AppThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
