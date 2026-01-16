import 'package:flutter/material.dart';
import 'animation_utils.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About AimCat')),
      body: const SparkleBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StaggeredEntry(
                index: 0,
                child: Hero(
                  tag: 'main_cat_image',
                  child: Image(
                    image: AssetImage('assets/images/MainScreenCat.png'),
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              SizedBox(height: 24),
              StaggeredEntry(
                index: 1,
                child: Text(
                  'AimCat',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              StaggeredEntry(
                index: 2,
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 32),
              StaggeredEntry(
                index: 3,
                child: _AboutSection(
                  title: 'The Mission',
                  content: 'AimCat was created as a loving homage to my children, designed to be a safe, simple, and fun experience for kids. It\'s a simple game where you tap good targets to score high and test your accuracy. This project also serves as a key piece of my professional portfolio.',
                ),
              ),
              SizedBox(height: 24),
              StaggeredEntry(
                index: 4,
                child: _AboutSection(
                  title: 'Tech Stack',
                  content: 'Built with Flutter & Flame Engine for seamless cross-platform performance. Powered by catnip and late-night coding sessions.',
                ),
              ),
              SizedBox(height: 48),
              StaggeredEntry(
                index: 5,
                child: Text(
                  'Made with 🐾 by the AimCat Team',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final String title;
  final String content;

  const _AboutSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
