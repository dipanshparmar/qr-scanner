import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: const Color(0xFFCFCFCF),
      child: SafeArea(
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
            await showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              context: context,
              builder: (context) {
                return OptionsModalSheetSaved(savedScan);
              },
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
}
