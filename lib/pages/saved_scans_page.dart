import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _future = Provider.of<SavedScansProvider>(context, listen: false)
        .fetchSavedScans(); // fetching the data from the db
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9E9E9E),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          // if loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            );
          } else {
            // if error
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong!'),
              );
            } else {
              return SafeArea(
                child: Consumer<SavedScansProvider>(
                  builder: (context, obj, child) {
                    // if there is no data then let the user know
                    if (obj.savedScans.isEmpty) {
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

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // confirming
                            final bool deleteIt = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
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
                          },
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
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 20),
                            physics: const BouncingScrollPhysics(),
                            itemCount: obj.savedScans.length,
                            itemBuilder: (context, index) {
                              // current saved scan
                              final SavedScan savedScan = obj.savedScans[index];

                              return GestureDetector(
                                onTap: () async {
                                  await _buildModalBottomSheet(
                                      context, savedScan);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                    bottom: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF878787),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // title
                                      Text(
                                        savedScan.title == ''
                                            ? 'No title!'
                                            : savedScan.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(
                                        height: 5,
                                      ),

                                      // code and the date
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            savedScan.code,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            DateFormat.yMMMd().format(
                                              DateTime.parse(savedScan.date),
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
                                ),
                              );
                            },
                          ),
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomContainer(
              savedScan.code,
              normalWeight: true,
              onTap: () async {
                final bool isLaunched = await launch(savedScan.code);

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
            Row(
              children: [
                Expanded(
                  child: CustomContainer(
                    'COPY',
                    right: 10,
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
                    'DELETE',
                    onTap: () async {
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
                        await Provider.of<SavedScansProvider>(context,
                                listen: false)
                            .delete(savedScan.id);

                        // pop the bottom sheet
                        Navigator.pop(context);
                      }
                    },
                    left: 10,
                  ),
                )
              ],
            ),
            CustomContainer(
              'SHARE',
              onTap: () {
                HapticFeedback.heavyImpact();
                Share.share(savedScan.code);
              },
            ),
            const SizedBox(
              height: 20,
            )
          ],
        );
      },
    );
  }
}
