import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer(
    this._text, {
    Key? key,
    this.normalWeight = false,
    this.onTap,
    this.rightPadding,
    this.leftPadding,
    this.maxLines,
  }) : super(key: key);

  // text to display
  final String _text;

  // wether it is going to be normal weight or the bold weight
  final bool normalWeight;

  // what to do onTap
  final Function()? onTap;

  // right padding
  final double? rightPadding;

  // left padding
  final double? leftPadding;

  // maxlines to show in the container
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.only(
          top: 20,
          right: rightPadding ?? 20,
          left: leftPadding ?? 20,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF616161),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            _text,
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null, // if there is maxLines limit then add the overflow
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
