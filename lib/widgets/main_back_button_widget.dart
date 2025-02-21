import 'package:flutter/material.dart';

class MainBackButtonWidget extends StatelessWidget {
  final double size;
  final Color color;

  MainBackButtonWidget({this.size = 38, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,  // Position at the top-left
      child: Padding(
        padding: const EdgeInsets.all(16.0),  // Adds padding to keep it from the edges
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
