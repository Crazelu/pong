import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pong/board_view.dart';
import 'package:pong/board_view_model.dart';

void main() {
  runApp(const PongApp());
}

class PongApp extends StatelessWidget {
  const PongApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = ThemeData(
      primarySwatch: Colors.blue,
      backgroundColor: Colors.black,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: 'Pong',
      theme: themeData.copyWith(
        textTheme: GoogleFonts.grapeNutsTextTheme(themeData.textTheme),
      ),
      home: BoardView(viewModel: BoardViewModel()),
    );
  }
}
