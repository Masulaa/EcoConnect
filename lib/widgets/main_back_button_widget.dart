import 'package:flutter/material.dart';

class MainBackButtonWidget extends StatelessWidget {
  final double size;
  final Color color;

  MainBackButtonWidget({this.size = 38, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: IconButton(
          icon: Icon(Icons.arrow_back, size: size, color: color),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

