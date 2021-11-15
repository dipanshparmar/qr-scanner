import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// providers
import '../providers/providers.dart';

// widgets
import './widgets.dart';

// models
import '../models/models.dart';

class OptionsModalSheetSaved extends StatefulWidget {
  const OptionsModalSheetSaved(this._savedScan,
      {Key? key, this.fromSearch = false})
      : super(key: key);

  final SavedScan _savedScan;
  final bool fromSearch;

  @override
  State<OptionsModalSheetSaved> createState() => _OptionsModalSheetSavedState();
}

class _OptionsModalSheetSavedState extends State<OptionsModalSheetSaved> {
  // focus node for the title input text field
  final FocusNode _focusNode = FocusNode();

  // text editing controller for the update title textfield
  final _textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // title container
        CustomContainer(
          widget._savedScan.title == '' ? 'No title!' : widget._savedScan.title,
          onTap: !widget.fromSearch
              ? () async {
                  await _buildUpdateTitleBottomSheet(context);
                }
              : null,
        ),

        // code container
        CustomContainer(
          widget._savedScan.code,
          normalWeight: true,
          onTap: () => _launchUrl(widget._savedScan.code),
          maxLines: 10,
        ),

        // buttons' row
        _buildButtonsRow(context),

        // delete button
        CustomContainer(
          'DELETE',
          onTap: () async => _deleteScan(context, widget._savedScan.id),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  // method to build the row buttons
  Widget _buildButtonsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomContainer(
            'COPY',
            rightPadding: 10,
            onTap: () async {
              // copy the text
              await Clipboard.setData(
                ClipboardData(
                  text: widget._savedScan.code,
                ),
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
        Expanded(
          child: CustomContainer(
            'SHARE',
            onTap: () async {
              HapticFeedback.heavyImpact();
              Share.share(widget._savedScan.code);
            },
            leftPadding: 10,
          ),
        )
      ],
    );
  }

  // emthod to delete a scan
  Future<void> _deleteScan(BuildContext context, String id) async {
    // ask the user if he really wants to delete the scan info
    final deleteIt = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            'Are you sure?',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: const Text(
            'This action is irreversible.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );

    if (deleteIt) {
      await Provider.of<SavedScansProvider>(
        context,
        listen: false,
      ).delete(id);

      // pop the bottom sheet
      Navigator.pop(context);
    }
  }

  // method to launch the url
  void _launchUrl(String code) async {
    await launch(code);
  }

  // method to build the sheet that will take the new title input
  Future<dynamic> _buildUpdateTitleBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          color: const Color(0xFF616161),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: _buildTitleTextField(context),
          ),
        );
      },
    );
  }

  // method to build the text field for the title input
  TextField _buildTitleTextField(BuildContext context) {
    return TextField(
      maxLength: 80,
      focusNode: _focusNode,
      textAlignVertical: TextAlignVertical.center,
      controller: _textEditingController
        ..text = widget._savedScan.title
        ..selection = _focusNode.hasFocus
            ? TextSelection(
                baseOffset: 0,
                extentOffset: widget._savedScan.title.length,
              )
            : const TextSelection(
                baseOffset: 0,
                extentOffset: 0,
              ),
      cursorColor: Colors.white70,
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        counterStyle: const TextStyle(
          color: Colors.white70,
        ),
        fillColor: const Color(0xFF616161),
        filled: true,
        contentPadding: const EdgeInsets.all(25),
        border: InputBorder.none,
        hintText: 'Enter a new title',
        hintStyle: const TextStyle(
          color: Colors.white70,
        ),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.send_rounded,
          ),
          color: Colors.white,
          onPressed: () async => _updateTitle(context),
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
      ),
      textInputAction: TextInputAction.none,
    );
  }

  // method to update the title
  Future<void> _updateTitle(BuildContext context) async {
    Provider.of<SavedScansProvider>(context, listen: false).update(
      {
        'id': widget._savedScan.id,
        'title': _textEditingController.text,
        'code': widget._savedScan.code,
        'date': widget._savedScan.date,
      },
    );

    // clering the value of the controller
    _textEditingController.clear();

    // closing the keyboard and popping the current screen
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }
}
