import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// providers
import '../providers/providers.dart';

// models
import '../models/models.dart';

// widgets
import '../widgets/widgets.dart';

class SavedScansPage extends StatefulWidget {
  const SavedScansPage({Key? key}) : super(key: key);

  @override
  State<SavedScansPage> createState() => _SavedScansPageState();
}

class _SavedScansPageState extends State<SavedScansPage> {
  // future that will hold the future that will load the saved scans
  late Future _future;

  // text editing controller for the update title textfield
  final _textEditingController = TextEditingController();

  // focus node for the edit title text field
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _future = Provider.of<SavedScansProvider>(context, listen: false)
        .fetchSavedScans(); // fetching the data from the db
  }

  @override
  void dispose() {
    super.dispose();

    // disposing the controller
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: const Color(0xFFCFCFCF),
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          // if loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildProgressIndicator();
          } else {
            // if error
            if (snapshot.hasError) {
              return _buildErrorText();
            } else {
              return SafeArea(
                child: Consumer<SavedScansProvider>(
                  builder: (context, obj, child) {
                    // if there is no data then let the user know
                    if (obj.savedScans.isEmpty) {
                      return _buildEmptySavedScansMessage(context);
                    }

                    // if there are saved scans then build them
                    return Column(
                      children: [
                        _buildDeleteAllButton(context, obj),
                        Expanded(
                          child: _buildSavedScans(obj),
                        ),
                      ],
                    );
                  },
                ),
              );
            }
          }
        },
      ),
    );
  }

  // method to build the message when there are no scans
  Center _buildEmptySavedScansMessage(BuildContext context) {
    return Center(
      child: Text(
        'No saved scans!',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 15,
        ),
      ),
    );
  }

  // method to build the scans
  Widget _buildSavedScans(SavedScansProvider obj) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: obj.savedScans.length,
      itemBuilder: (context, index) {
        // current saved scan
        final SavedScan savedScan = obj.savedScans[index];

        return GestureDetector(
          onTap: () async {
            await _buildModalBottomSheet(
              context,
              savedScan,
            );
          },
          child: SavedScanTile(savedScan),
        );
      },
    );
  }

  // method to build the delete all button
  Widget _buildDeleteAllButton(BuildContext context, SavedScansProvider obj) {
    return GestureDetector(
      onTap: () async => _deleteAllScans(obj),
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(
          top: 20,
          right: 20,
          left: 20,
        ),
        alignment: Alignment.center,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Text(
          'DELETE ALL',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }

  // method to delete all the scans
  Future<void> _deleteAllScans(SavedScansProvider obj) async {
    // confirming
    final bool deleteIt = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(
            'Are you sure?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This action is irreversible.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: const Text(
                'No',
              ),
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

    // if delete it
    if (deleteIt) {
      await obj.deleteAll();
    }
  }

  // method to build the error text
  Center _buildErrorText() {
    return const Center(
      child: Text('Something went wrong!'),
    );
  }

  // method to build the progress indicator
  Widget _buildProgressIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.grey,
      ),
    );
  }

  // method to build the modal bottom sheet
  _buildModalBottomSheet(BuildContext context, SavedScan savedScan) async {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      context: context,
      builder: (context) {
        return _buildOptions(savedScan, context);
      },
    );
  }

  // method to build the options
  Widget _buildOptions(SavedScan savedScan, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // title container
        CustomContainer(
          savedScan.title == '' ? 'No title!' : savedScan.title,
          onTap: () async {
            await _buildUpdateTitleBottomSheet(context, savedScan);
          },
        ),

        // code container
        CustomContainer(
          savedScan.code,
          normalWeight: true,
          onTap: () => _launchUrl(savedScan.code),
          maxLines: 10,
        ),

        // buttons' row
        _buildButtonsRow(savedScan, context),

        // delete button
        CustomContainer(
          'DELETE',
          onTap: () async => _deleteScan(savedScan.id),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  // method to build the buttons row
  Widget _buildButtonsRow(SavedScan savedScan, BuildContext context) {
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
                  text: savedScan.code,
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
              Share.share(savedScan.code);
            },
            leftPadding: 10,
          ),
        )
      ],
    );
  }

  // method to delete a scan
  Future<void> _deleteScan(String id) async {
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

  // method to build the update title bottom sheet
  Future<dynamic> _buildUpdateTitleBottomSheet(
      BuildContext context, SavedScan savedScan) {
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
            child: _buildTitleTextField(savedScan, context),
          ),
        );
      },
    );
  }

  // method to build the text field to update the title
  TextField _buildTitleTextField(SavedScan savedScan, BuildContext context) {
    return TextField(
      maxLength: 80,
      focusNode: _focusNode,
      textAlignVertical: TextAlignVertical.center,
      controller: _textEditingController
        ..text = savedScan.title
        ..selection = _focusNode.hasFocus
            ? TextSelection(
                baseOffset: 0,
                extentOffset: savedScan.title.length,
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
          onPressed: () async => _updateTitle(savedScan),
        ),
      ),
      style: const TextStyle(
        color: Colors.white,
      ),
      textInputAction: TextInputAction.none,
    );
  }

  // method to update the scan title
  Future<void> _updateTitle(SavedScan savedScan) async {
    Provider.of<SavedScansProvider>(context, listen: false).update(
      {
        'id': savedScan.id,
        'title': _textEditingController.text,
        'code': savedScan.code,
        'date': savedScan.date,
      },
    );

    // clering the value of the controller
    _textEditingController.clear();

    // closing the keyboard and popping the current screen
    FocusScope.of(context).unfocus();
    Navigator.pop(context);
  }
}
