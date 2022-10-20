import 'dart:ui';

import 'package:flutter/material.dart';

class BlurBg extends StatelessWidget {
  const BlurBg({required this.onTap, Key? key}) : super(key: key);

  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: Container(
          color: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }
}
