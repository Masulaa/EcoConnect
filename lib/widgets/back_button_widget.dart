import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final double size;
  final Color color;

  const BackButtonWidget({this.size = 38, this.color = Colors.black, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, 
      child: Padding(
        padding: const EdgeInsets.all(16.0), 
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
