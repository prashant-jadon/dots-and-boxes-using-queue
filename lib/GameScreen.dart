import 'dart:math';
import 'dart:collection'; // Import the collection library for using Queue
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final bool isVsComputer;

  GameScreen({required this.isVsComputer});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final int gridSize = 5; // Defines a 5x5 grid
  late List<List<bool>> horizontalLines;
  late List<List<bool>> verticalLines;
  late List<List<int>> boxes; // 0: empty, 1: player 1, 2: player 2 (or AI)
  bool isPlayerOneTurn = true;
  int player1Score = 0;
  int player2Score = 0;

  // Queue to store move history
  Queue<List<dynamic>> moveHistory = Queue();

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    horizontalLines = List.generate(gridSize, (_) => List.filled(gridSize - 1, false));
    verticalLines = List.generate(gridSize - 1, (_) => List.filled(gridSize, false));
    boxes = List.generate(gridSize - 1, (_) => List.filled(gridSize - 1, 0));
    isPlayerOneTurn = true;
    player1Score = 0;
    player2Score = 0;
    moveHistory.clear(); // Clear the move history
  }

  void makeMove(int x, int y, bool isHorizontal) {
    setState(() {
      if (isHorizontal) {
        horizontalLines[x][y] = true;
      } else {
        verticalLines[x][y] = true;
      }

      // Add the move to the history queue
      moveHistory.add([x, y, isHorizontal, isPlayerOneTurn ? 1 : 2]);

      int completedBoxes = checkForBoxes();
      if (completedBoxes == 0) {
        isPlayerOneTurn = !isPlayerOneTurn;
        if (!isPlayerOneTurn && widget.isVsComputer) {
          makeComputerMove();
        }
      } else {
        if (player1Score + player2Score == (gridSize - 1) * (gridSize - 1)) {
          _showWinnerDialog();
        }
      }
    });
  }

  int checkForBoxes() {
    int completedBoxes = 0;
    for (int i = 0; i < gridSize - 1; i++) {
      for (int j = 0; j < gridSize - 1; j++) {
        if (boxes[i][j] == 0 &&
            horizontalLines[i][j] &&
            horizontalLines[i + 1][j] &&
            verticalLines[i][j] &&
            verticalLines[i][j + 1]) {
          boxes[i][j] = isPlayerOneTurn ? 1 : 2;
          completedBoxes++;
          if (isPlayerOneTurn) {
            player1Score++;
          } else {
            player2Score++;
          }
        }
      }
    }
    return completedBoxes;
  }

  void makeComputerMove() {
    List<List<int>> availableMoves = [];

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize - 1; j++) {
        if (!horizontalLines[i][j]) availableMoves.add([i, j, 1]);
      }
    }
    for (int i = 0; i < gridSize - 1; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (!verticalLines[i][j]) availableMoves.add([i, j, 0]);
      }
    }

    if (availableMoves.isNotEmpty) {
      final move = availableMoves[Random().nextInt(availableMoves.length)];
      makeMove(move[0], move[1], move[2] == 1);
    }
  }

  void undoMove() {
    if (moveHistory.isNotEmpty) {
      setState(() {
        // Retrieve and remove the last move
        final lastMove = moveHistory.removeLast();
        int x = lastMove[0];
        int y = lastMove[1];
        bool isHorizontal = lastMove[2];
        int player = lastMove[3];

        // Revert the line based on the move's details
        if (isHorizontal) {
          horizontalLines[x][y] = false;
        } else {
          verticalLines[x][y] = false;
        }

        // Adjust the boxes and scores accordingly
        if (checkForBoxes() == 0) {
          // If no boxes were completed, switch turns back
          isPlayerOneTurn = (player == 1);
        } else {
          // If boxes were completed, adjust scores
          if (player == 1) {
            player1Score--;
          } else {
            player2Score--;
          }
        }
      });
    }
  }

  Widget buildDot() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget buildHorizontalLine(int x, int y) {
    return GestureDetector(
      onTap: () {
        if (!horizontalLines[x][y]) makeMove(x, y, true);
      },
      child: Container(
        width: 60,
        height: 20,
        color: horizontalLines[x][y] ? Colors.blue : Colors.grey[300],
      ),
    );
  }

  Widget buildVerticalLine(int x, int y) {
    return GestureDetector(
      onTap: () {
        if (!verticalLines[x][y]) makeMove(x, y, false);
      },
      child: Container(
        width: 20,
        height: 60,
        color: verticalLines[x][y] ? Colors.blue : Colors.grey[300],
      ),
    );
  }

  Widget buildBox(int x, int y) {
    return Container(
      width: 60,
      height: 60,
      color: boxes[x][y] == 0
          ? Colors.white
          : boxes[x][y] == 1
          ? Colors.red
          : Colors.green,
      child: Center(
        child: Text(
          boxes[x][y] == 1 ? 'P1' : boxes[x][y] == 2 ? (widget.isVsComputer ? 'AI' : 'P2') : '',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showWinnerDialog() {
    String winnerMessage;
    if (player1Score > player2Score) {
      winnerMessage = 'Player 1 Wins!';
    } else if (player2Score > player1Score) {
      winnerMessage = widget.isVsComputer ? 'Computer Wins!' : 'Player 2 Wins!';
    } else {
      winnerMessage = 'It\'s a Tie!';
    }

    // Show a Snackbar to announce the winner
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          winnerMessage,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _restartGame() {
    setState(() {
      initializeBoard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'images/newimage.jpg', // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Game Board
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Player 1 Score: $player1Score',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.isVsComputer ? 'Computer Score: $player2Score' : 'Player 2 Score: $player2Score',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(gridSize * 2 - 1, (i) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(gridSize * 2 - 1, (j) {
                          if (i % 2 == 0 && j % 2 == 0) {
                            return buildDot();
                          } else if (i % 2 == 0) {
                            return buildHorizontalLine(i ~/ 2, j ~/ 2);
                          } else if (j % 2 == 0) {
                            return buildVerticalLine(i ~/ 2, j ~/ 2);
                          } else {
                            return buildBox(i ~/ 2, j ~/ 2);
                          }
                        }),
                      );
                    }),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: undoMove,
                    child: Text('Undo Last Move'),
                  ),
                  ElevatedButton(
                    onPressed: _restartGame,
                    child: Text('Restart Game'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
