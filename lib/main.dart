import 'start_screen.dart';
import 'theme_provider.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      ),
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
        title: const Text('AimCat'),
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
            // Image takes up to 50% of screen height, max 400px
            final imageSize = (screenHeight * 0.5).clamp(200.0, isMobile ? 350.0 : 400.0);
            
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // Clickable cat image to start the game
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StartScreen()),
                        );
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
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
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                'Tap to Play',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
