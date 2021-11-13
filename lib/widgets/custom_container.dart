import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer(
    this._text, {
    Key? key,
    this.normalWeight = false,
    this.right = 20,
    this.left = 20,
  }) : super(key: key);

  final String _text;
  final bool normalWeight;

  // margin value
  final double right;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: EdgeInsets.only(
        top: 20,
        right: right,
        left: left,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF616161),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          _text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: normalWeight ? FontWeight.normal : FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
