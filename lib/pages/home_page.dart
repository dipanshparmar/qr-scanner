import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
    return Stack(
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
                        ),
                        const CustomContainer(
                          'COPY',
                        ),
                        const CustomContainer('SHARE'),
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
    );
  }
}
