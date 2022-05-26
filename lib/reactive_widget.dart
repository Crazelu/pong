import 'package:flutter/material.dart';

class ReactiveWidget extends AnimatedWidget {
  const ReactiveWidget({
    Key? key,
    required this.controller,
    required this.builder,
  }) : super(
          key: key,
          listenable: controller,
        );

  ///A controller that the UI listens to for changes.
  final Listenable controller;

  /// Called every time the controller notifies the UI
  /// to rebuild.
  final Widget Function(BuildContext) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
