import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pong/settings.dart';
import 'package:pong/square.dart';

class SizeUtil {
  SizeUtil._();

  static late double deviceHeight =
      (window.physicalSize.height / window.devicePixelRatio) -
          (kToolbarHeight * 2);
  static late double deviceWidth =
      window.physicalSize.width / window.devicePixelRatio;

  static List<List<Square>> generateSquares() {
    List<List<Square>> result = [];

    double height = GameSettings.bodySize;
    double width = GameSettings.bodySize;

    int rowItems = deviceWidth ~/ width;

    for (int i = 0; i < deviceHeight ~/ height; i++) {
      List<Square> inner = [];
      for (int j = 0; j < rowItems; j++) {
        inner.add(Square(x: j, y: i));
      }
      result.add(inner);
    }

    return result;
  }
}
