import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void dispose() {
    super.dispose();

    // disposeing the controller
    _qrViewController.dispose();
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

                              // if isn't launched then show a snackbar
                              if (!isLaunched) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Error opening results!',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          CustomContainer(
                            'COPY',
                            onTap: () async {
                              // copy the text
                              await Clipboard.setData(
                                ClipboardData(text: barcode.code!),
                              );

                              // removing snack bar if there is any before showing a new one
                              ScaffoldMessenger.of(context)
                                  .removeCurrentSnackBar();

                              // let the user know
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );

                              // give a haptic feedback
                              HapticFeedback.heavyImpact();
                            },
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
