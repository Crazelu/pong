import 'package:flutter/material.dart';
import 'package:pong/board_view_model.dart';
import 'package:pong/reactive_widget.dart';
import 'package:pong/square_widget.dart';

class BoardView extends StatefulWidget {
  final BoardViewModel viewModel;
  const BoardView({Key? key, required this.viewModel}) : super(key: key);

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  late final _focusNode = FocusNode();

  BoardViewModel get viewModel => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: (keyEvent) {
        switch (keyEvent.physicalKey.debugName) {
          case "Arrow Left":
            viewModel.moveBar(Direction.left);
            break;
          case "Arrow Right":
            viewModel.moveBar(Direction.right);
            break;
        }
      },
      child: ReactiveWidget(
        controller: viewModel,
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text("Pong"),
            centerTitle: false,
            actions: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      for (int i = 0; i < viewModel.lives; i++) ...{
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      },
                      for (int i = 0;
                          i < viewModel.maxLives - viewModel.lives;
                          i++)
                        const Icon(Icons.heart_broken)
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    "Score: ${viewModel.score}",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          body: GameWidget(viewModel: viewModel),
        ),
      ),
    );
  }
}

class GameWidget extends StatelessWidget {
  final BoardViewModel viewModel;

  const GameWidget({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!viewModel.gameStarted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Ready to pong?",
              style: Theme.of(context).textTheme.headline6,
            ),
            TextButton(
              onPressed: viewModel.reset,
              child: const Text("Play"),
            ),
          ],
        ),
      );
    }
    if (viewModel.isGameOver) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "You ran out of lives",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              "Your score -> ${viewModel.score}",
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              "Highscore -> ${viewModel.highScore}",
              style: Theme.of(context).textTheme.headline6,
            ),
            TextButton(
              onPressed: viewModel.reset,
              child: const Text("Play again"),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        viewModel.updateBarPosition(details.globalPosition);
      },
      child: Column(
        children: [
          for (var squares in viewModel.squares) ...{
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var square in squares) SquareWidget(square: square),
              ],
            )
          }
        ],
      ),
    );
  }
}
