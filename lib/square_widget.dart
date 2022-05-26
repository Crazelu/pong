import 'package:flutter/material.dart';
import 'package:pong/settings.dart';
import 'package:pong/square.dart';

class SquareWidget extends StatelessWidget {
  final Square square;
  const SquareWidget({
    Key? key,
    required this.square,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: GameSettings.bodySize,
      width: GameSettings.bodySize,
      decoration: BoxDecoration(
        border: square.piece == Piece.block
            ? const Border(
                top: BorderSide(color: Colors.black),
                bottom: BorderSide(color: Colors.black),
                left: BorderSide(color: Colors.black),
                right: BorderSide(color: Colors.black),
              )
            : null,
        color: square.piece == Piece.bar || square.piece == Piece.bullet
            ? Colors.white
            : square.piece == Piece.block
                ? Colors.grey[200]
                : Colors.transparent,
      ),
    );
  }
}
