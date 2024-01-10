import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Match Your Card',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MemoryGame(),
    );
  }
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final int rows = 4;
  final int columns = 4;
  List<int> randomNumbers = [];
  List<bool> cardFlipped = [];
  List<String> cardImagePaths = [];
  bool commonCardFlipped = false;
  int firstFlippedCardIndex = -1;
  int secondFlippedCardIndex = -1;
  int matchedCount = 0; // Track the number of matched cards

  @override
  void initState() {
    super.initState();
    generateRandomNumbers();
  }

  void generateRandomNumbers() {
    randomNumbers = List.generate(16, (index) => (index % 8) + 1);
    randomNumbers.shuffle();
    cardFlipped = List.generate(16, (index) => false);
    cardImagePaths = List.generate(16, (index) => 'assets/card_front.jpg');
  }

  void flipCard(int index) {
    if (!cardFlipped[index] && !commonCardFlipped) {
      setState(() {
        cardFlipped[index] = true;
        if (firstFlippedCardIndex == -1) {
          firstFlippedCardIndex = index;
        } else {
          if (randomNumbers[firstFlippedCardIndex] == randomNumbers[index]) {
            // Cards match, keep them face-up
            firstFlippedCardIndex = -1;
            matchedCount++;
            if (matchedCount == 8) {
              // All cards matched
              showVictoryDialog(context);
            }
          } else {
            // Cards don't match, flip them back
            secondFlippedCardIndex = index;
            commonCardFlipped = true;

            Future.delayed(const Duration(seconds: 1), () {
              if (randomNumbers[firstFlippedCardIndex] !=
                  randomNumbers[secondFlippedCardIndex]) {
                cardFlipped[firstFlippedCardIndex] = false;
                cardFlipped[secondFlippedCardIndex] = false;
              }
              firstFlippedCardIndex = -1;
              secondFlippedCardIndex = -1;
              commonCardFlipped = false;
            });
          }
        }
      });
    }
  }

  void showVictoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            title: Text('Congratulations! You won!!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'OK',
                  style:
                      TextStyle(color: Colors.white, fontSize: 16 // Text color
                          ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      Colors.black), // Background color
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match the Card!'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: randomNumbers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              flipCard(index);
            },
            child: Container(
              width: 100, // Set your desired width
              height: 250,
              child: AnimatedCard(
                imagePath: cardFlipped[index]
                    ? 'assets/card_${randomNumbers[index]}.jpg'
                    : 'assets/card_front.jpg',
                isFlipped: cardFlipped[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final String imagePath;
  final bool isFlipped;

  AnimatedCard({required this.imagePath, required this.isFlipped});

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8),
      child: Image.asset(
        widget.imagePath,
        fit: BoxFit.fill,
      ),
    );
  }
}
