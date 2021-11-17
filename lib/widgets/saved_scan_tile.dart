import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// models
import '../models/models.dart';

class SavedScanTile extends StatelessWidget {
  const SavedScanTile(
    this._savedScan, {
    Key? key,
  }) : super(key: key);

  final SavedScan _savedScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF5C5C5C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Text(
            _savedScan.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          // code and the date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _savedScan.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                DateFormat.yMMMd().format(
                  DateTime.parse(_savedScan.date),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
