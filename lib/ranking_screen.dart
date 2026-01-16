import 'package:flutter/material.dart';
import 'high_score_service.dart';
import 'level_selection_screen.dart'; // To get gameLevels list
import 'animation_utils.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  Map<String, HighScoreData?> _highScores = {};
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
      body: SparkleBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _highScores.values.every((data) => data == null || data.score == 0)
                ? _buildEmptyState()
                : _buildScoresList(),
      ),
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
      ..sort((a, b) => (_highScores[b.name]?.score ?? 0).compareTo(_highScores[a.name]?.score ?? 0));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedLevels.length,
      itemBuilder: (context, index) {
        final level = sortedLevels[index];
        final data = _highScores[level.name];
        
        if (data == null || data.score == 0) return const SizedBox.shrink();

        return StaggeredEntry(
          index: index,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header: Level Info and Score
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(level.icon, color: Theme.of(context).colorScheme.primary, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              '${data.characterName == "Unknown" ? "Player" : data.characterName}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${data.score}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                            ),
                          ),
                          Text(
                            'pts',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context, 
                        Icons.timer, 
                        '${data.timeUsed}s', 
                        'Time',
                      ),
                      _buildStatItem(
                        context, 
                        Icons.speed, 
                        '${data.accuracy.toStringAsFixed(1)} p/s', 
                        'Pace',
                      ),
                      _buildStatItem(
                        context, 
                        Icons.calendar_today, 
                        _formatDate(data.date), 
                        'Date',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.tertiary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    // Simple date formatting without external dependencies
    return '${date.day}/${date.month}/${date.year}';
  }
}

