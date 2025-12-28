import 'package:flutter/services.dart';
import 'game_mode_screen.dart';
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

  const CharacterData({required this.name, required this.imagePath});
}

// Available characters
const List<CharacterData> characters = [
  CharacterData(name: 'Bidoque', imagePath: 'assets/profiles/Bidoque.png'),
  CharacterData(name: 'Capybara', imagePath: 'assets/profiles/Capybara.png'),
  CharacterData(name: 'Cat', imagePath: 'assets/profiles/Cat.png'),
  CharacterData(name: 'Devil Cat', imagePath: 'assets/profiles/DevilCat.png'),
  CharacterData(name: 'Diplomat', imagePath: 'assets/profiles/Diplomat.png'),
  CharacterData(
    name: 'Flying Horse',
    imagePath: 'assets/profiles/FlyingHorse.png',
  ),
  CharacterData(name: 'Ghost', imagePath: 'assets/profiles/Ghost.png'),
  CharacterData(name: 'Golden Girl', imagePath: 'assets/profiles/GoldenGirl.png'),
  CharacterData(name: 'Grandma', imagePath: 'assets/profiles/Grandma.png'),
  CharacterData(name: 'Koi', imagePath: 'assets/profiles/Koi.png'),
  CharacterData(name: 'Librarian', imagePath: 'assets/profiles/Librarian.png'),
  CharacterData(name: 'Mom', imagePath: 'assets/profiles/Mom.png'),
  CharacterData(name: 'Moustache', imagePath: 'assets/profiles/Moustache.png'),
  CharacterData(name: 'Nerdy', imagePath: 'assets/profiles/Nerdy.png'),
  CharacterData(name: 'Nerdy Girl', imagePath: 'assets/profiles/NerdyGirl.png'),
  CharacterData(name: 'Nuken Duke', imagePath: 'assets/profiles/NukenDuke.png'),
  CharacterData(name: 'Nurse', imagePath: 'assets/profiles/Nurse.png'),
  CharacterData(name: 'Punk', imagePath: 'assets/profiles/Punk.png'),
  CharacterData(name: 'Roadrunner', imagePath: 'assets/profiles/Roadrunner.png'),
  CharacterData(name: 'Robson', imagePath: 'assets/profiles/Robson.png'),
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
            GameModeScreen(selectedCat: selectedCharacter, username: username),
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
        final maxWidth = isMobile ? screenWidth : 600.0;
        final crossAxisCount = isMobile ? 3 : 4;
        final spacing = isMobile ? 10.0 : 16.0;

        return SafeArea(
          child: Column(
            key: const ValueKey('character_step'),
            children: [
              SizedBox(height: isMobile ? 16 : 24),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select your character',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isMobile ? 4 : 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Choose a character to represent you',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        horizontal: isMobile ? 12 : 16,
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: isMobile ? 0.85 : 0.8,
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? primaryColor
                  : _isHovered
                  ? primaryColor.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 3,
            ),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      widget.character.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                child: Text(
                  widget.character.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: widget.isSelected || _isHovered
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
