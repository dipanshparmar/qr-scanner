import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer(
    this._text, {
    Key? key,
    this.normalWeight = false,
    this.onTap,
    this.right,
    this.left,
    this.maxLines,
  }) : super(key: key);

  final String _text;
  final bool normalWeight;
  final Function()? onTap;
  final double? right;
  final double? left;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.only(
          top: 20,
          right: right ?? 20,
          left: left ?? 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF616161),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            _text,
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
            style: TextStyle(
              color: Colors.white,
              fontWeight: normalWeight ? FontWeight.normal : FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
