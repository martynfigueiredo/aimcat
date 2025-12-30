import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'start_screen.dart';
import 'level_selection_screen.dart';
import 'game_screen.dart';
import 'ranking_screen.dart';
import 'help_screen.dart';
import 'about_screen.dart';
import 'animation_utils.dart';
import 'global_paw_cursor.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const AimCatApp(),
    ),
  );
}

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class AimCatApp extends StatelessWidget {
  const AimCatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Modern Material 3 Theme with a deep primary color.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF673AB7), // Deep Purple
      brightness: Brightness.light,
    );
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF673AB7),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'AimCat',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.flutterThemeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: darkColorScheme.surface,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
      builder: (context, child) {
        return GlobalPawCursor(child: child!);
      },
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AimCat Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == AppThemeMode.light
                  ? Icons.light_mode
                  : themeProvider.themeMode == AppThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.brightness_auto,
            ),
            onPressed: () => _showThemeDialog(context, themeProvider),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.catching_pokemon, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'AimCat Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: const Text('Hall of Fame'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  AimCatPageRoute(page: const RankingScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Guide'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  AimCatPageRoute(page: const HelpScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  AimCatPageRoute(page: const AboutScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: const SparkleBackground(
        child: SafeArea(
          child: _HomeScreenBody(),
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

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 600;
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
                const _FloatingTitle(),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      AimCatPageRoute(
                        page: const StartScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Hero(
                        tag: 'main_cat_image',
                        child: Image.asset(
                          'assets/images/MainScreenCat.png',
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _PulsingPlayButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FloatingTitle extends StatefulWidget {
  const _FloatingTitle();

  @override
  State<_FloatingTitle> createState() => _FloatingTitleState();
}

class _FloatingTitleState extends State<_FloatingTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return SlideTransition(
      position: _animation,
      child: Text(
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
    );
  }
}

class _PulsingPlayButton extends StatefulWidget {
  const _PulsingPlayButton();

  @override
  State<_PulsingPlayButton> createState() => _PulsingPlayButtonState();
}

class _PulsingPlayButtonState extends State<_PulsingPlayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
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
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 48,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          'Click to Play',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
