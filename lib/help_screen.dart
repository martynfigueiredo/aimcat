import 'package:flutter/material.dart';
import 'animation_utils.dart';

class HelpScreen extends StatelessWidget {
  final bool simplified;
  const HelpScreen({super.key, this.simplified = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(simplified ? 'Quick Guide' : 'Game Guide & Instructions')),
      body: SparkleBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StaggeredEntry(index: 0, child: _ObjectiveSection()),
              const StaggeredEntry(index: 1, child: _HowToPlaySection()),
              if (!simplified) ...[
                const StaggeredEntry(index: 2, child: _TargetsSection()),
                const StaggeredEntry(index: 3, child: _ComboSystemSection()),
                const StaggeredEntry(index: 4, child: _LevelRulesSection()),
                const StaggeredEntry(index: 5, child: _CharacterPowersSection()),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  final String text;
  const _SectionText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }
}

class _ListItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ListItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Expanded(child: _SectionText(text)),
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _TargetRow(this.icon, this.color, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelInfo extends StatelessWidget {
  final String name;
  final String rules;
  const _LevelInfo(this.name, this.rules);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(rules),
        dense: true,
      ),
    );
  }
}

class _ObjectiveSection extends StatelessWidget {
  const _ObjectiveSection();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Objective'),
        _SectionText('AimCat is a simple and fun game primarily designed for kids. The goal is easy: just tap or click on the good targets as they appear to score as many points as you can! Try to beat your personal best or just enjoy the process.'),
        SizedBox(height: 16),
      ],
    );
  }
}

class _HowToPlaySection extends StatelessWidget {
  const _HowToPlaySection();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('How to Play'),
        _ListItem(Icons.touch_app, 'Tap or click on targets to hit them.'),
        _ListItem(Icons.mouse, 'Your cat paw cursor follows your touch/mouse.'),
        _ListItem(Icons.timer, 'Keep an eye on the countdown at the top.'),
        SizedBox(height: 16),
      ],
    );
  }
}

class _TargetsSection extends StatelessWidget {
  const _TargetsSection();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Targets'),
        _TargetRow(Icons.eco, Colors.green, 'Positive Targets', 'Give points and help build combos. Some even give extra time!'),
        _TargetRow(Icons.pest_control, Colors.red, 'Negative Targets', 'Deduct points, break your combo, and may penalize your time.'),
        SizedBox(height: 16),
      ],
    );
  }
}

class _ComboSystemSection extends StatelessWidget {
  const _ComboSystemSection();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Combo System'),
        _SectionText(
          'Hit consecutive positive targets to build a combo! \n'
          '• Every 5 hits adds a progressive bonus (+10, +20, +30...).\n'
          '• Hitting a negative target or letting a positive one expire resets your combo.',
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class _LevelRulesSection extends StatelessWidget {
  const _LevelRulesSection();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Level Rules'),
        _LevelInfo('Baby', 'Only good items. They stay longer. Reduced scoring for fun.'),
        _LevelInfo('Toddler', 'Good items stay 2x longer. Balanced points, no bad penalties!'),
        _LevelInfo('Grandma', 'Targets are 30% larger and stay 2x longer. Reduced scoring.'),
        _LevelInfo('SpeedRun', 'Quick 10s blitz! Targets appear 4x faster.'),
        _LevelInfo('Sayajin', 'High stakes. Start with 100pts. Good=2x, Bad=50% penalty.'),
        _LevelInfo('Hacker', 'Madness! Start with -100pts. Instant 64x speed. All hit=200pts.'),
        _LevelInfo('Marathon', 'Standard 90s endurance test.'),
        _LevelInfo('Ultra Marathon', '5-minute ultimate test of focus.'),
        SizedBox(height: 16),
      ],
    );
  }
}

class _CharacterPowersSection extends StatelessWidget {
  const _CharacterPowersSection();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Character Powers'),
        _SectionText('Every character has a special ability! Some start with more time, others get massive multipliers for specific items or even convert bad items into points.'),
      ],
    );
  }
}
