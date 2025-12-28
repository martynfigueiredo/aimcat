import 'package:flutter/material.dart';
import 'high_score_service.dart';
import 'level_selection_screen.dart'; // To get gameLevels list

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  Map<String, int> _highScores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final levels = gameLevels.map((l) => l.name).toList();
    final scores = await HighScoreService.getAllHighScores(levels);
    if (mounted) {
      setState(() {
        _highScores = scores;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Hall of Fame'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _highScores.values.every((score) => score == 0)
              ? _buildEmptyState()
              : _buildScoresList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'No scores recorded yet!',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Play a level to see your name here!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildScoresList() {
    // Sort levels by score (highest first)
    final sortedLevels = gameLevels.toList()
      ..sort((a, b) => (_highScores[b.name] ?? 0).compareTo(_highScores[a.name] ?? 0));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedLevels.length,
      itemBuilder: (context, index) {
        final level = sortedLevels[index];
        final score = _highScores[level.name] ?? 0;
        
        if (score == 0) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(level.icon, color: Theme.of(context).colorScheme.primary),
            ),
            title: Text(
              level.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            trailing: Text(
              '$score pts',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}

