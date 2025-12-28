import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Guide & Instructions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, 'Objective'),
            _buildText(
              'AimCat is a fast-paced aim trainer game. Your goal is to hit as many positive targets as possible while avoiding negative ones within the time limit.',
            ),
            const SizedBox(height: 16),
            
            _buildHeader(context, 'How to Play'),
            _buildListItem(context, Icons.touch_app, 'Tap or click on targets to hit them.'),
            _buildListItem(context, Icons.mouse, 'Your cat paw cursor follows your touch/mouse.'),
            _buildListItem(context, Icons.timer, 'Keep an eye on the countdown at the top.'),
            const SizedBox(height: 16),

            _buildHeader(context, 'Targets'),
            _buildTargetRow(context, Icons.eco, Colors.green, 'Positive Targets', 'Give points and help build combos. Some even give extra time!'),
            _buildTargetRow(context, Icons.pest_control, Colors.red, 'Negative Targets', 'Deduct points, break your combo, and may penalize your time.'),
            const SizedBox(height: 16),

            _buildHeader(context, 'Combo System'),
            _buildText(
              'Hit consecutive positive targets to build a combo! \n'
              '• Every 5 hits adds a progressive bonus (+10, +20, +30...).\n'
              '• Hitting a negative target or letting a positive one expire resets your combo.',
            ),
            const SizedBox(height: 16),

            _buildHeader(context, 'Level Rules'),
            _buildLevelInfo(context, 'Baby', 'Easy Mode. Good targets only, they stay 8x longer. No Clocks/Combos.'),
            _buildLevelInfo(context, 'Toddler', '2x Points for good items. Bad items worth 0. No Clocks/Combos.'),
            _buildLevelInfo(context, 'Grandma', 'Targets are 30% larger. No Clocks/Combos. Reduced points.'),
            _buildLevelInfo(context, 'SpeedRun', 'Quick 10s blitz! targets appear 4x faster.'),
            _buildLevelInfo(context, 'Sayajin', 'High stakes. Start with 100pts. Good=2x, Bad=Damage.'),
            _buildLevelInfo(context, 'Hacker', 'Insane speed. Everything is worth 200pts. 10s only.'),
            const SizedBox(height: 16),

            _buildHeader(context, 'Character Powers'),
            _buildText(
              'Every character has a special ability! Some start with more time, others get massive multipliers for specific items or even convert bad items into points.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
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

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }

  Widget _buildListItem(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Expanded(child: _buildText(text)),
        ],
      ),
    );
  }

  Widget _buildTargetRow(BuildContext context, IconData icon, Color color, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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

  Widget _buildLevelInfo(BuildContext context, String name, String rules) {
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
