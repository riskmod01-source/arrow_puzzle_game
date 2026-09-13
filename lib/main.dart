import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const ArrowPuzzleApp());
}

class ArrowPuzzleApp extends StatelessWidget {
  const ArrowPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arrow Puzzle Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int currentLevel = 1;
  int score = 0;
  int remainingMoves = 5;
  
  int gridSize = 3; 
  late List<String> gridArrows; 
  late List<bool> tappedStatus;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  void _loadLevel() {
    if (currentLevel <= 3) {
      gridSize = 3;
      remainingMoves = 4 + currentLevel;
    } else if (currentLevel <= 6) {
      gridSize = 4;
      remainingMoves = 8 + (currentLevel - 3);
    } else {
      gridSize = 5;
      remainingMoves = 12 + (currentLevel - 6);
    }

    final random = Random();
    const directions = ['UP', 'DOWN', 'LEFT', 'RIGHT'];
    
    gridArrows = List.generate(gridSize * gridSize, (index) => directions[random.nextInt(directions.length)]);
    tappedStatus = List.generate(gridSize * gridSize, (index) => false);
    setState(() {});
  }

  void _onArrowTap(int index) {
    if (tappedStatus[index] || remainingMoves <= 0) return;

    setState(() {
      tappedStatus[index] = true;
      remainingMoves--;
      score += 10;
    });

    if (tappedStatus.every((element) => element)) {
      _showWinDialog();
    } else if (remainingMoves == 0) {
      _showGameOverDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('🎉 લેવલ પૂરું!', style: TextStyle(color: Colors.white)),
        content: Text('શાનદાર! તમે લેવલ $currentLevel સફળતાપૂર્વક પાર કરી લીધું.', style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentLevel++;
              });
              _loadLevel();
            },
            child: const Text('આગળનું લેવલ (Next Level)'),
          ),
        ],
      ),
    );
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('❌ ચાન્સ પૂરા થઈ ગયા!', style: TextStyle(color: Colors.white)),
        content: const Text('તમારા બધા એરો પૂરા થઈ ગયા. ફરી પ્રયાસ કરો!', style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                remainingMoves = 5;
              });
              _loadLevel();
            },
            child: const Text('ફરી ટ્રાય કરો (Retry)'),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String direction) {
    switch (direction) {
      case 'UP': return Icons.arrow_upward;
      case 'DOWN': return Icons.arrow_downward;
      case 'LEFT': return Icons.arrow_back;
      case 'RIGHT': return Icons.arrow_forward;
      default: return Icons.arrow_forward;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Arrow Puzzle - લેવલ $currentLevel', style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoCard('સ્કોર (Score)', '$score', Colors.amber),
                _infoCard('બાકી એરો (Moves)', '$remainingMoves', Colors.cyan),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GridView.builder(
                    itemCount: gridArrows.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      bool isCleared = tappedStatus[index];
                      return GestureDetector(
                        onTap: () => _onArrowTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: isCleared ? Colors.grey.shade800 : const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (!isCleared)
                                const BoxShadow(color: Colors.blueAccent, blurRadius: 6, offset: Offset(0, 3))
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _getIcon(gridArrows[index]),
                              color: isCleared ? Colors.white24 : Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Text(
              'બધા એરો સાફ કરો અને જીતો!',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
