import 'package:flutter/material.dart';

class SizableCircularProgresIndicator extends StatelessWidget {
  const SizableCircularProgresIndicator({required this.size, Key? key})
      : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        backgroundColor: Colors.blue[600],
        color: Colors.white,
        semanticsLabel: 'Linear progress indicator',
      ),
    );
  }
}
