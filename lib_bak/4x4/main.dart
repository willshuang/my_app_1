import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4x4 井字遊戲',
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
  // 4x4 棋盤
  List<List<String>> _board = List.generate(4, (_) => List.filled(4, ''));
  List<List<Color>> _boardColors = List.generate(
    4,
    (_) => List.filled(4, Colors.white),
  );
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
            title: const Text('選擇誰先下'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('玩家'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('電腦'),
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

  void _handleTap(int row, int col) {
    if (_board[row][col] == '' && _winner == null && _currentPlayer == 'X') {
      setState(() {
        _board[row][col] = _currentPlayer;
        _winner = _checkWinner();
        if (_winner == null) {
          _currentPlayer = 'O';
          _makeMove();
        } else {
          _highlightLoser(_winner!);
        }
      });
    }
  }

  void _makeMove() {
    if (_winner == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        var move = _findBestMove();
        setState(() {
          _board[move[0]][move[1]] = _currentPlayer;
          _winner = _checkWinner();
          if (_winner == null) {
            _currentPlayer = 'X';
          } else {
            _highlightLoser(_winner!);
          }
        });
      });
    }
  }

  void _highlightLoser(String winner) {
    setState(() {
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          if (_board[i][j] != winner && _board[i][j] != '') {
            _boardColors[i][j] = Colors.grey;
          }
        }
      }
    });
  }

  String _getWinnerText() {
    if (_winner == '平局') {
      return '平局！';
    } else if (_winner == 'O') {
      return '電腦贏了！';
    } else {
      return '玩家贏了！';
    }
  }

  List<int> _findBestMove() {
    // Check if computer can win in the next move
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (_board[i][j] == '') {
          _board[i][j] = _currentPlayer;
          if (_checkWinner() == _currentPlayer) {
            _board[i][j] = '';
            return [i, j];
          }
          _board[i][j] = '';
        }
      }
    }

    // Check if player can win in the next move and block them
    String opponent = _currentPlayer == 'O' ? 'X' : 'O';
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (_board[i][j] == '') {
          _board[i][j] = opponent;
          if (_checkWinner() == opponent) {
            _board[i][j] = '';
            return [i, j];
          }
          _board[i][j] = '';
        }
      }
    }

    // Take the center if available
    if (_board[1][1] == '') {
      return [1, 1];
    }

    // Take one of the corners if available
    List<List<int>> corners = [
      [0, 0],
      [0, 3],
      [3, 0],
      [3, 3],
    ];
    for (var corner in corners) {
      if (_board[corner[0]][corner[1]] == '') {
        return corner;
      }
    }

    // Take any empty space
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (_board[i][j] == '') {
          return [i, j];
        }
      }
    }

    return [0, 0];
  }

  String? _checkWinner() {
    // Check rows
    for (int i = 0; i < 4; i++) {
      if (_board[i][0] != '' &&
          _board[i][0] == _board[i][1] &&
          _board[i][1] == _board[i][2] &&
          _board[i][2] == _board[i][3]) {
        return _board[i][0];
      }
    }

    // Check columns
    for (int j = 0; j < 4; j++) {
      if (_board[0][j] != '' &&
          _board[0][j] == _board[1][j] &&
          _board[1][j] == _board[2][j] &&
          _board[2][j] == _board[3][j]) {
        return _board[0][j];
      }
    }

    // Check diagonals
    if (_board[0][0] != '' &&
        _board[0][0] == _board[1][1] &&
        _board[1][1] == _board[2][2] &&
        _board[2][2] == _board[3][3]) {
      return _board[0][0];
    }
    if (_board[0][3] != '' &&
        _board[0][3] == _board[1][2] &&
        _board[1][2] == _board[2][1] &&
        _board[2][1] == _board[3][0]) {
      return _board[0][3];
    }

    // Check for a draw
    if (!_board.any((row) => row.contains(''))) {
      return '平局';
    }

    return null;
  }

  void _resetGame() {
    setState(() {
      _board = List.generate(4, (_) => List.filled(4, ''));
      _boardColors = List.generate(4, (_) => List.filled(4, Colors.white));
      _winner = null;
      _dialogShown = false;
    });
    _showStartDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('4x4 井字遊戲')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4x4 棋盤
            ),
            itemCount: 16, // 4x4 = 16 個格子
            itemBuilder: (context, index) {
              int row = index ~/ 4;
              int col = index % 4;
              Color textColor = _boardColors[row][col];
              if (_winner != null && _board[row][col] == _winner) {
                textColor = Colors.red;
              }
              return GestureDetector(
                onTap: () => _handleTap(row, col),
                child: Container(
                  margin: const EdgeInsets.all(4.0),
                  color: Colors.blueAccent,
                  child: Center(
                    child: Text(
                      _board[row][col],
                      style: TextStyle(fontSize: 48.0, color: textColor),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          if (_winner != null)
            Text(_getWinnerText(), style: const TextStyle(fontSize: 24.0)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _resetGame, child: const Text('重新開始')),
        ],
      ),
    );
  }
}