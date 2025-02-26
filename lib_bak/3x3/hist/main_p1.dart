import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TicTacToe(),
    );
  }
}

class TicTacToe extends StatefulWidget {
  const TicTacToe({super.key});

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String? _winner;
  bool _isPlayerFirst = true;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dialogShown) {
      _showStartDialog();
      _dialogShown = true;
    }
  }

  void _showStartDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Choose who goes first'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Player'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Computer'),
              ),
            ],
          );
        },
      ).then((isPlayerFirst) {
        if (isPlayerFirst != null) {
          setState(() {
            _isPlayerFirst = isPlayerFirst;
            _currentPlayer = isPlayerFirst ? 'X' : 'O';
            if (!isPlayerFirst) {
              _makeMove();
            }
          });
        }
      });
    });
  }

  void _handleTap(int index) {
    if (_board[index] == '' && _winner == null && _currentPlayer == 'X') {
      setState(() {
        _board[index] = _currentPlayer;
        _winner = _checkWinner();
        if (_winner == null) {
          _currentPlayer = 'O';
          _makeMove();
        }
      });
    }
  }

  void _makeMove() {
    if (_winner == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        int index = _findBestMove();
        setState(() {
          _board[index] = _currentPlayer;
          _winner = _checkWinner();
          if (_winner == null) {
            _currentPlayer = 'X';
          }
        });
      });
    }
  }

  int _findBestMove() {
    // Check if computer can win in the next move
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        _board[i] = _currentPlayer;
        if (_checkWinner() == _currentPlayer) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }

    // Check if player can win in the next move and block them
    String opponent = _currentPlayer == 'O' ? 'X' : 'O';
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        _board[i] = opponent;
        if (_checkWinner() == opponent) {
          _board[i] = '';
          return i;
        }
        _board[i] = '';
      }
    }

    // Take the center if available
    if (_board[4] == '') {
      return 4;
    }

    // Take one of the corners if available
    List<int> corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (_board[corner] == '') {
        return corner;
      }
    }

    // Take any empty space
    for (int i = 0; i < 9; i++) {
      if (_board[i] == '') {
        return i;
      }
    }

    return 0;
  }

  String? _checkWinner() {
    const List<List<int>> lines = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var line in lines) {
      if (_board[line[0]] != '' &&
          _board[line[0]] == _board[line[1]] &&
          _board[line[1]] == _board[line[2]]) {
        return _board[line[0]];
      }
    }

    if (!_board.contains('')) {
      return 'Draw';
    }

    return null;
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _winner = null;
      _dialogShown = false;
    });
    _showStartDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tic Tac Toe')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  color: Colors.blueAccent,
                  child: Center(
                    child: Text(
                      _board[index],
                      style: const TextStyle(
                        fontSize: 32.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          if (_winner != null)
            Text(
              _winner == 'Draw' ? 'It\'s a Draw!' : 'Player $_winner Wins!',
              style: const TextStyle(fontSize: 24.0),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetGame,
            child: const Text('Restart Game'),
          ),
        ],
      ),
    );
  }
}
