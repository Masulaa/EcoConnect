import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final double size;
  final Color color;
  
  BackButtonWidget({this.size = 38, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: MediaQuery.of(context).size.width * 0.5 - (size / 2),
      child: IconButton(
        icon: Icon(Icons.arrow_back, size: size, color: color),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

