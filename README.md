# Flutter Game Project

## Overview

This project is a Flutter-based game where players take turns making moves on a grid to complete boxes. The game can be played against another player or against a computer. The goal is to maximize the number of completed boxes.

## Features

- **Two Player Modes**: Play against a friend or the computer.
- **Score Tracking**: Keep track of player scores throughout the game.
- **Undo Functionality**: Players can revert their last move.
- **Dynamic UI**: Interactive and responsive game board.
- **Color-Coded Boxes**: Visual feedback for completed boxes based on players.

## Technologies Used

- Flutter
- Dart

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/prashanr-jadon/dots-and-boxes-using-queue.git
   cd dots-and-boxes-using-queue

## Game Logic
The game is played on a 5x5 grid where players can draw horizontal or vertical lines.
Players take turns, and the game checks for completed boxes after each move.
The player with the most completed boxes at the end wins.

## Data Structure
A queue is used to track move history, enabling the undo functionality:
dart
```
Queue<List<dynamic>> moveHistory = Queue();
```

```
class GameScreen extends StatefulWidget {
final bool isVsComputer;

GameScreen({required this.isVsComputer});

@override
_GameScreenState createState() => _GameScreenState();
}
```

```
Making Moves
void makeMove(int x, int y, bool isHorizontal) {
// Existing logic for making a move
}
```

```
Undo Move Functionality
void undoMove() {
if (moveHistory.isNotEmpty) {
final lastMove = moveHistory.removeLast();
// Logic to revert the last move
}
}
```