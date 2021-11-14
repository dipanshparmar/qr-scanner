import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// widgets
import './widgets.dart';

// providers
import '../providers/providers.dart';

class OptionsModalSheet extends StatefulWidget {
  const OptionsModalSheet(
    this._barcode, {
    Key? key,
    required String date,
  })  : _date = date,
        super(key: key);

  // barcode
  final Barcode _barcode;

  // date when the qr code is detected
  final String _date;

  @override
  State<OptionsModalSheet> createState() => _OptionsModalSheetState();
}

class _OptionsModalSheetState extends State<OptionsModalSheet> {
  // controller for the text field
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    // disposing the text editing controller
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // container for the barcode's code display
        CustomContainer(
          widget._barcode.code!,
          maxLines: 10,
          normalWeight: true,
          onTap: () async {
            // checking if the launch was successful or not
            final bool isLaunched = await launch(
              widget._barcode.code!,
            );

            // if isn't launched then show a flushbar
            if (!isLaunched) {
              return Flushbar(
                messageText: const Text(
                  'Error launching URL!',
                  style: TextStyle(color: Colors.red),
                ),
                duration: const Duration(seconds: 3),
                animationDuration: const Duration(
                  milliseconds: 300,
                ),
              ).show(context);
            }
          },
        ),

        // container for the copy and the share button
        _buildRowButtons(context),

        // save button
        CustomContainer(
          'SAVE',
          onTap: () async {
            await getTitleInputSheet(context);
          },
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  // method to build the copy and the share button
  Widget _buildRowButtons(BuildContext context) {
    return Row(
      children: [
        // copy button
        Expanded(
          child: CustomContainer(
            'COPY',
            rightPadding: 10,
            onTap: () async {
              // copy the text
              await Clipboard.setData(
                ClipboardData(text: widget._barcode.code!),
              );

              // give a haptic feedback
              HapticFeedback.heavyImpact();

              // showing the flushbar
              await Flushbar(
                messageText: const Text(
                  'Copied to clipboard!',
                  style: TextStyle(color: Colors.white),
                ),
                duration: const Duration(seconds: 2),
                animationDuration: const Duration(
                  milliseconds: 300,
                ),
              ).show(context);
            },
          ),
        ),
        // save button
        Expanded(
          child: CustomContainer(
            'SHARE',
            onTap: () {
              // giving the haptic feedback
              HapticFeedback.heavyImpact();

              // sharing
              Share.share(widget._barcode.code!);
            },
            leftPadding: 10,
          ),
        )
      ],
    );
  }

  // method to get the title input bottom modal sheet
  Future<dynamic> getTitleInputSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      // without this there are no rounded borderes if filled in text field is true
      clipBehavior: Clip.antiAlias,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          // to make the background of the dynamic padding as same as the color of the text field
          color: const Color(0xFF616161),
          child: Padding(
            // this padding is needed to lift the bottom sheet when the keyboard opens
            padding: MediaQuery.of(context).viewInsets,
            // text field for the title input
            child: _getTitleInputTextField(context),
          ),
        );
      },
    );
  }

  // method to get the title field
  TextField _getTitleInputTextField(BuildContext context) {
    return TextField(
      // properties
      maxLength: 80,
      controller: _textEditingController,
      cursorColor: Colors.white70,
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,

      // decoration
      decoration: InputDecoration(
        counterStyle: const TextStyle(
          color: Colors.white70,
        ),
        fillColor: const Color(0xFF616161),
        filled: true, // needed to make the fillColor work
        contentPadding: const EdgeInsets.all(25),
        border: InputBorder.none,
        hintText: 'Enter a title to remember your scan',
        hintStyle: const TextStyle(
          color: Colors.white70,
        ),
        // icon button to save the scan with the code and the title when clicked
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.send_rounded,
          ),
          color: Colors.white,
          onPressed: () async => await _saveScan(context),
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
      ),
      textInputAction: TextInputAction.none,
    );
  }

  // method to save scan
  Future<void> _saveScan(BuildContext context) async {
// inserting the scan data
    await Provider.of<SavedScansProvider>(context, listen: false).insert(
      {
        'id': UniqueKey().toString(),
        'title': _textEditingController.text,
        'code': widget._barcode.code!,
        'date': widget._date,
      },
    );

    // clearing the value of the controller
    _textEditingController.clear();

    // closing the keyboard and popping the current screen
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }
}
