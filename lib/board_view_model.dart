import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pong/settings.dart';
import 'package:pong/size_util.dart';
import 'package:pong/square.dart';

enum Direction { right, left }

class BoardViewModel extends ChangeNotifier {
  static const int _maxLives = 3;
  static const int __barLength = 7;
  static const int __collisionGrowth = 5;
  static const int __scorePoints = 2;

  late List<List<Square>> _squares = SizeUtil.generateSquares();
  List<List<Square>> get squares => _squares;

  List<Square> _barBlocks = [];
  List<Square> _blocks = [];

  late int _bulletX = _squares.length ~/ 2;
  late int _bulletY = _squares.first.length ~/ 2;

  int _xVel = 0;
  int _yVel = 0;

  int get maxLives => _maxLives;

  int _lives = _maxLives;
  int get lives => _lives;

  bool _gameStarted = false;
  bool get gameStarted => _gameStarted;

  bool get isGameOver => _lives == 0;

  int _score = 0;
  int get score => _score;
  int _highScore = 0;
  int get highScore => _highScore;

  void play() async {
    _gameStarted = true;
    _createBar();
    _createBlocks();

    while (!isGameOver) {
      try {
        await Future.delayed(Duration(milliseconds: (1000 / 25).ceil()))
            .then((_) => _moveBullet());
      } catch (e, trace) {
        print(e);
        print(trace);
      }
    }
  }

  void _randomizeYVel() {
    final useMin = Random().nextBool();
    _yVel = _yVel == 0 ? 1 : _yVel;
    _yVel = useMin ? min(_yVel, -1) : max(_yVel, -1);
  }

  void _moveBullet() {
    _bulletX += _xVel;
    _bulletY += _yVel;

    if (_bulletX <= 0) {
      _xVel = 1;
      _randomizeYVel();
    }

    if (_bulletX > _squares.length) {
      if (_highScore == 0 || _score > _highScore) {
        _highScore = _score;
      }
      _lives--;
      revive();
      notifyListeners();
      return;
    }

    if (_bulletY <= 0) {
      _yVel = 1;
    }

    if (_bulletY >= _squares.first.length - 1) {
      _yVel = -1;
    }

    _squares = SizeUtil.generateSquares();

    _checkForBarCollision();

    _updateBlocks();
    _checkForBlockCollision();
    _updateBar();
    _updateBullet();
    notifyListeners();
  }

  void revive() {
    _bulletX = _squares.length ~/ 2;
    _bulletY = _squares.first.length ~/ 2;
    _xVel = 1;
    _yVel = 0;
    _collisionGrowth = __collisionGrowth;
  }

  void reset() {
    _gameStarted = true;
    _squares = SizeUtil.generateSquares();
    _barBlocks = [];
    _blocks = [];
    _bulletX = _squares.length ~/ 2;
    _bulletY = _squares.first.length ~/ 2;
    _xVel = 1;
    _yVel = 0;
    _lives = _maxLives;

    _score = 0;

    _collisionGrowth = __collisionGrowth;
    play();
  }

  late int _lastPosition = _squares.first.length ~/ 2;

  void updateBarPosition(double globalYPosition, double globalXPosition) {
    if (globalXPosition < SizeUtil.deviceHeight * .4) return;
    int position = globalYPosition ~/ GameSettings.bodySize;
    if (position > _lastPosition) {
      _moveBarRight();
      _lastPosition = position;
    }
    if (position < _lastPosition) {
      _moveBarLeft();
      _lastPosition = position;
    }
  }

  void _checkForBarCollision() {
    final firstY = _barBlocks.first.y;
    final midY = _barBlocks[3].y;
    final lastY = _barBlocks.last.y;

    for (var bar in _barBlocks) {
      if (bar.x == _bulletX && bar.y == _bulletY) {
        _xVel = -1;
        if (_bulletY == firstY) {
          _yVel = -1;
        } else if (_bulletY == lastY) {
          _yVel = 1;
        } else if (_bulletY == midY) {
          final useMin = Random().nextBool();
          _yVel = useMin ? min(_yVel, 0) : max(_yVel, 0);
        } else {
          _yVel = (bar.y / _squares.first.length).ceil();
        }
      }
    }
  }

  void _updateBullet() {
    _squares[_bulletX][_bulletY] = Square(
      x: _bulletX,
      y: _bulletY,
      piece: Piece.bullet,
    );
  }

  void _createBlocks() {
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < _squares.first.length; j++) {
        _blocks.add(
          Square(
            x: i,
            y: j,
            piece: Piece.block,
          ),
        );
      }
    }
  }

  void _updateBlocks() {
    for (var block in _blocks) {
      _squares[block.x][block.y] = block;
    }
  }

  void _calculateScore() {
    _score += __scorePoints * _collisionGrowth;
    notifyListeners();
  }

  int _collisions = 0;
  int _collisionGrowth = __collisionGrowth;

  void _checkForBlockCollision() {
    if (_squares[_bulletX][_bulletY].piece == Piece.block) {
      _collisions++;
      _blocks
          .removeWhere((block) => block.x == _bulletX && block.y == _bulletY);
      _randomizeYVel();
      _calculateScore();
    }
    if (_collisions >= _collisionGrowth) {
      _collisions = 0;
      _collisionGrowth += 1;
      _xVel = 1;
    }
  }

  void _createBar() {
    List<Square> newBar = [];
    int x = _squares.length - 1;
    int y = (_squares.first.length ~/ 2) + 3;

    for (int i = 0; i < __barLength; i++) {
      newBar.add(
        Square(x: x, y: y - i, piece: Piece.bar),
      );
    }
    _barBlocks = newBar.reversed.toList();
    notifyListeners();
  }

  void _updateBar() {
    for (var bar in _barBlocks) {
      _squares[bar.x][bar.y] = bar;
    }
  }

  void moveBar(Direction direction) {
    if (direction == Direction.left) {
      _moveBarLeft();
    } else {
      _moveBarRight();
    }
  }

  void _moveBarRight() {
    if (_barBlocks.first.y >= _squares.first.length - 1 - __barLength) {
      return;
    }
    List<Square> newBarBlocks = [];

    for (var bar in _barBlocks) {
      newBarBlocks.add(
        Square(x: bar.x, y: bar.y + 1, piece: Piece.bar),
      );
    }
    _barBlocks = newBarBlocks;
    notifyListeners();
  }

  void _moveBarLeft() {
    if (_barBlocks.last.y <= __barLength) {
      return;
    }
    _barBlocks = _barBlocks.reversed.toList();
    List<Square> newBarBlocks = [];

    for (var bar in _barBlocks) {
      newBarBlocks.add(
        Square(x: bar.x, y: bar.y - 1, piece: Piece.bar),
      );
    }
    _barBlocks = newBarBlocks;
    _barBlocks = _barBlocks.reversed.toList();
    notifyListeners();
  }
}
