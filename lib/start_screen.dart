import 'package:flutter/services.dart';

import 'level_selection_screen.dart';
import 'package:flutter/material.dart';

// Formatter to force uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

// Character data model
class CharacterData {
  final String name;
  final String imagePath;
  final int xp; // 1-5 difficulty level
  final String power; // Special ability description
  final String goodAt; // Best target
  final String badAt; // Worst target
  final String description; // Brief character description

  const CharacterData({
    required this.name,
    required this.imagePath,
    required this.xp,
    required this.power,
    required this.goodAt,
    required this.badAt,
    required this.description,
  });
}

// Available characters
const List<CharacterData> characters = [
  CharacterData(
    name: 'Bidoque',
    imagePath: 'assets/profiles/Bidoque.jpg',
    xp: 5,
    power: 'Letter A 10x, Heart 5x',
    goodAt: 'Letter A',
    badAt: 'Fire',
    description: 'Master of letters and love, excels at academics.',
  ),
  CharacterData(
    name: 'Capybara',
    imagePath: 'assets/profiles/Capybara.jpg',
    xp: 2,
    power: 'Water 10x',
    goodAt: 'Water',
    badAt: 'Poison',
    description: 'Aquatic expert who thrives near water.',
  ),
  CharacterData(
    name: 'Cat',
    imagePath: 'assets/profiles/Cat.jpg',
    xp: 2,
    power: 'Bunny 15x',
    goodAt: 'Bunny',
    badAt: 'Rat',
    description: 'Natural hunter with keen instincts.',
  ),
  CharacterData(
    name: 'Devil Cat',
    imagePath: 'assets/profiles/DevilCat.jpg',
    xp: 3,
    power: 'Rat worth +300',
    goodAt: 'Rat',
    badAt: 'Heart',
    description: 'Mischievous feline who loves chaos.',
  ),
  CharacterData(
    name: 'Diplomat',
    imagePath: 'assets/profiles/Diplomat.jpg',
    xp: 3,
    power: 'Diamond 10x',
    goodAt: 'Diamond',
    badAt: 'Bomb',
    description: 'Sophisticated negotiator seeking treasure.',
  ),
  CharacterData(
    name: 'Flying Horse',
    imagePath: 'assets/profiles/FlyingHorse.jpg',
    xp: 2,
    power: 'Star 10x',
    goodAt: 'Star',
    badAt: 'Cancel',
    description: 'Magical creature that reaches for the stars.',
  ),
  CharacterData(
    name: 'Ghost',
    imagePath: 'assets/profiles/Ghost.jpg',
    xp: 2,
    power: 'Start +20s time',
    goodAt: 'Clock',
    badAt: 'Rotten Food',
    description: 'Spectral being with extra time to spare.',
  ),
  CharacterData(
    name: 'Golden Girl',
    imagePath: 'assets/profiles/GoldenGirl.jpg',
    xp: 5,
    power: 'Letter A 10x, Heart 5x',
    goodAt: 'Letter A',
    badAt: 'Fire',
    description: 'Brilliant scholar with a heart of gold.',
  ),
  CharacterData(
    name: 'Grandma',
    imagePath: 'assets/profiles/Grandma.jpg',
    xp: 3,
    power: 'Targets 30% bigger',
    goodAt: 'Apple',
    badAt: 'Thumbtack',
    description: 'Wise elder with enhanced vision.',
  ),

  CharacterData(
    name: 'Mom',
    imagePath: 'assets/profiles/Mom.jpg',
    xp: 4,
    power: 'Fruit 5x, Heart 5x',
    goodAt: 'Apple',
    badAt: 'Cigarette',
    description: 'Caring nurturer who promotes health.',
  ),
  CharacterData(
    name: 'Moustache',
    imagePath: 'assets/profiles/Moustache.jpg',
    xp: 4,
    power: 'Trophy 10x',
    goodAt: 'Trophy',
    badAt: 'Cancel',
    description: 'Competitive champion seeking victory.',
  ),
  CharacterData(
    name: 'Nerdy',
    imagePath: 'assets/profiles/Nerdy.jpg',
    xp: 2,
    power: 'Start +10s time',
    goodAt: 'Clock',
    badAt: 'Bomb',
    description: 'Intelligent thinker who plans ahead.',
  ),
  CharacterData(
    name: 'Nerdy Girl',
    imagePath: 'assets/profiles/NerdyGirl.jpg',
    xp: 4,
    power: 'Start +10s time',
    goodAt: 'Clock',
    badAt: 'Bomb',
    description: 'Smart strategist with time management skills.',
  ),
  CharacterData(
    name: 'Nuken Duke',
    imagePath: 'assets/profiles/NukenDuke.jpg',
    xp: 3,
    power: 'Beer 10x',
    goodAt: 'Beer',
    badAt: 'Rotten Food',
    description: 'Party animal who loves a good time.',
  ),
  CharacterData(
    name: 'Nurse',
    imagePath: 'assets/profiles/Nurse.jpg',
    xp: 4,
    power: 'Heart 10x',
    goodAt: 'Heart',
    badAt: 'Poison',
    description: 'Healthcare hero dedicated to healing.',
  ),
  CharacterData(
    name: 'Punk',
    imagePath: 'assets/profiles/Punk.jpg',
    xp: 1,
    power: 'Beer 10x, Cigarette +100',
    goodAt: 'Beer',
    badAt: 'Heart',
    description: 'Rebellious spirit who breaks the rules.',
  ),
  CharacterData(
    name: 'Roadrunner',
    imagePath: 'assets/profiles/Roadrunner.jpg',
    xp: 5,
    power: 'Start +30s time',
    goodAt: 'Clock',
    badAt: 'Thumbtack',
    description: 'Speed demon with maximum time bonus.',
  ),
  CharacterData(
    name: 'Robson',
    imagePath: 'assets/profiles/Robson.jpg',
    xp: 4,
    power: 'Beer 10x',
    goodAt: 'Beer',
    badAt: 'Rotten Food',
    description: 'Social butterfly who enjoys celebrations.',
  ),
];

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentStep = 0; // 0 = character selection, 1 = username entry
  int selectedCharacter = 0;
  final TextEditingController _controller = TextEditingController();
  String? errorText;

  void _onCharacterSelected(int index) {
    setState(() {
      selectedCharacter = index;
    });
  }

  void _goToUsernameStep() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _goBackToCharacterStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _onStartGame() {
    final username = _controller.text.trim();
    final valid = RegExp(r'^[A-Z0-9]{4}$').hasMatch(username);
    if (!valid) {
      setState(() => errorText = '4 characters: A-Z, 0-9');
      return;
    }
    setState(() => errorText = null);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LevelSelectionScreen(selectedCat: selectedCharacter, username: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentStep == 0 ? 'Choose Character' : 'Enter Name'),
        leading: _currentStep == 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBackToCharacterStep,
              )
            : null,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentStep == 0
            ? _buildCharacterSelectionStep()
            : _buildUsernameStep(),
      ),
    );
  }

  Widget _buildCharacterSelectionStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal grid layout based on screen size
        final screenWidth = constraints.maxWidth;
        final isMobile = screenWidth < 600;
        final maxWidth = isMobile ? screenWidth : 1000.0; // Wider max width for desktop
        // 1 column on mobile for "Big card", 2 on desktop
        final crossAxisCount = isMobile ? 1 : 2; 
        final spacing = isMobile ? 16.0 : 24.0;
        
        // Adjust ratio based on column count
        // Mobile (1 col): Wide flexibility. Desktop (2 col): Needs to fit content.
        // Content height is approx 240px. 
        // Mobile width ~350 -> Ratio 350/240 ~= 1.45
        // Desktop width ~500 -> Ratio 500/240 ~= 2.0
        final childAspectRatio = isMobile ? 1.6 : 2.0;

        return SafeArea(
          child: Column(
            key: const ValueKey('character_step'),
            children: [
              SizedBox(height: isMobile ? 16 : 24),
              // Title - Bigger
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select your character',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Choose a character to represent you',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              // Grid
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: characters.length,
                        itemBuilder: (context, index) {
                          final character = characters[index];
                          final isSelected = selectedCharacter == index;
                          return _CharacterCard(
                            character: character,
                            isSelected: isSelected,
                            onTap: () {
                              _onCharacterSelected(index);
                              _goToUsernameStep();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsernameStep() {
    final character = characters[selectedCharacter];
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final maxWidth = isMobile ? double.infinity : 400.0;
        final characterSize = isMobile ? 120.0 : 140.0;

        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              key: const ValueKey('username_step'),
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // Selected character display
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: characterSize,
                            height: characterSize,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.asset(
                                character.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            character.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          TextButton(
                            onPressed: _goBackToCharacterStep,
                            child: const Text('Change character'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Username input
                    TextField(
                      controller: _controller,
                      maxLength: 4,
                      textCapitalization: TextCapitalization.characters,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        hintText: 'ABCD',
                        errorText: errorText,
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: TextStyle(
                        letterSpacing: isMobile ? 6 : 8,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 20 : 24,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                        UpperCaseTextFormatter(),
                      ],
                      onSubmitted: (_) => _onStartGame(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '4 characters: A-Z or 0-9',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Start button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _onStartGame,
                        child: const Text('Start Game'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Character card widget with hover effect
class _CharacterCard extends StatefulWidget {
  final CharacterData character;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<_CharacterCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Use the primary color for borders/highlights
    final primaryColor = Theme.of(context).colorScheme.primary;
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Reduced padding to use more space for content ("No free space")
          padding: const EdgeInsets.all(8), 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? primaryColor
                  : _isHovered
                  ? primaryColor.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 3,
            ),
            color: colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Image + Name + XP
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bigger Picture
                  Container(
                    width: 100, // Increased from 60
                    height: 100, // Increased from 60
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        widget.character.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and XP
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Vertically center somewhat with the image
                        const SizedBox(height: 4),
                        Text(
                          widget.character.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22, // Bigger Name
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Bigger XP Stars
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              index < widget.character.xp
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 24, // Bigger Stars
                              color: index < widget.character.xp
                                  ? const Color(0xFFFFD700)
                                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Power Section - Bigger
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flash_on, size: 20, color: primaryColor), // Bigger Icon
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.character.power,
                        style: TextStyle(
                          fontSize: 14, // Bigger Text
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Good at / Bad at - Bigger
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.thumb_up, size: 18, color: Color(0xFF4CAF50)), // Bigger Icon
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.character.goodAt,
                            style: const TextStyle(
                              fontSize: 13, // Bigger Text
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.thumb_down, size: 18, color: Color(0xFFE57373)), // Bigger Icon
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.character.badAt,
                            style: const TextStyle(
                              fontSize: 13, // Bigger Text
                              color: Color(0xFFE57373),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Description - Bigger and Expanded to fill space
              Expanded(
                child: Container(
                   alignment: Alignment.topLeft,
                   child: Text(
                    widget.character.description,
                    style: TextStyle(
                      fontSize: 13, // Bigger Text
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
