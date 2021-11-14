import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// providers
import '../providers/providers.dart';

// widgets
import '../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // key for the qr scanner
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');

  // flash icon
  IconData _flashIcon = Icons.flashlight_off;

  // controller for the scanner
  late QRViewController _qrViewController;

  // controller for the text field
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();

    // disposing the controllers
    _qrViewController.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: _qrKey,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.white,
              borderRadius: 10,
              borderLength: 20,
              borderWidth: 8,
            ),
            onQRViewCreated: (controller) {
              _qrViewController = controller;

              // listening for detection
              _qrViewController.scannedDataStream.listen(
                (barcode) async {
                  // pause the scanning
                  await _qrViewController.pauseCamera();

                  // give a feedback to let the user know that there is a detection
                  HapticFeedback.heavyImpact();

                  // getting the captured date
                  final date = DateTime.now().toString();

                  // opening the modal bottom sheet
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
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomContainer(
                            barcode.code!,
                            normalWeight: true,
                            onTap: () async {
                              final bool isLaunched =
                                  await launch(barcode.code!);

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
                                      ClipboardData(text: barcode.code!),
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
                                  'SAVE',
                                  onTap: () {
                                    showModalBottomSheet(
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
                                        return Padding(
                                          padding:
                                              MediaQuery.of(context).viewInsets,
                                          child: TextField(
                                            controller: _textEditingController,
                                            cursorColor: Colors.white70,
                                            autofocus: true,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            decoration: InputDecoration(
                                              fillColor:
                                                  const Color(0xFF616161),
                                              filled: true,
                                              contentPadding:
                                                  const EdgeInsets.all(25),
                                              border: InputBorder.none,
                                              hintText:
                                                  'Enter a title to remember your scan',
                                              hintStyle: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                              suffixIcon: IconButton(
                                                  icon: const Icon(
                                                    Icons.send_rounded,
                                                  ),
                                                  color: Colors.white,
                                                  onPressed: () {
                                                    Provider.of<SavedScansProvider>(
                                                            context,
                                                            listen: false)
                                                        .setData(
                                                      {
                                                        'id': UniqueKey()
                                                            .toString(),
                                                        'title':
                                                            _textEditingController
                                                                .text,
                                                        'code': barcode.code!,
                                                        'date':
                                                            date, // this date is from the first modal bottom sheet
                                                      },
                                                    );

                                                    // clering the value of the controller
                                                    _textEditingController
                                                        .clear();

                                                    // closing the keyboard and popping the current screen
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    Navigator.pop(context);
                                                  }),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                            textInputAction:
                                                TextInputAction.none,
                                          ),
                                        );
                                      },
                                    );
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
                              Share.share(barcode.code!);
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      );
                    },
                  );

                  // once the sheet is closed resume the camera again
                  await _qrViewController.resumeCamera();
                },
              );
            },
          ),
          // this container is for alignment
          SafeArea(
            child: Container(
              width: double.infinity,
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.only(top: 10),
              // this container is for decoration
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_flashIcon),
                      color: Colors.white,
                      onPressed: () async {
                        // turn the lights on
                        await _qrViewController.toggleFlash();

                        // getting the status of the flash
                        final bool? isOn =
                            await _qrViewController.getFlashStatus();

                        // updating the icon
                        if (isOn != null) {
                          if (isOn) {
                            setState(() {
                              _flashIcon = Icons.flashlight_on;
                            });
                          } else {
                            setState(() {
                              _flashIcon = Icons.flashlight_off;
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      icon: const Icon(Icons.flip_camera_android),
                      color: Colors.white,
                      onPressed: () async {
                        // flip the camera
                        await _qrViewController.flipCamera();
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
