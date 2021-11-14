import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  QRViewController? _qrViewController;

  @override
  void dispose() {
    super.dispose();

    // disposing the controllers
    if (_qrViewController != null) {
      _qrViewController!.dispose();
    }
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
              // assigning the controller
              _qrViewController = controller;

              // listening for detection
              _qrViewController!.scannedDataStream.listen(
                (barcode) async {
                  // pause the scanning
                  await _qrViewController!.pauseCamera();

                  // give a feedback to let the user know that there is a detection
                  HapticFeedback.heavyImpact();

                  // getting the date when the qr is captured
                  final date = DateTime.now().toString();

                  // opening the modal bottom sheet for different options
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
                      return OptionsModalSheet(
                        barcode,
                        date: date,
                      );
                    },
                  );

                  // once the sheet is closed resume the camera again
                  await _qrViewController!.resumeCamera();
                },
              );
            },
          ),
          // flash and camera controls
          SafeArea(
            // this container is for alignment
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
                child: _buildButtons(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // method to build the buttons
  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(_flashIcon),
          color: Colors.white,
          // toggle the flash on click
          onPressed: () async => _toggleFlash(),
        ),
        const SizedBox(
          width: 10,
        ),
        IconButton(
          icon: const Icon(Icons.flip_camera_android),
          color: Colors.white,
          onPressed: () async => _toggleCamera(),
        )
      ],
    );
  }

  // method to toggle flash
  Future<void> _toggleFlash() async {
    // if controller is not null
    if (_qrViewController != null) {
      // toggle the flash
      await _qrViewController!.toggleFlash();

      // getting the status of the flash
      final bool? isOn = await _qrViewController!.getFlashStatus();

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
    }
  }

  // method to toggle the camera
  Future<void> _toggleCamera() async {
    // if controller is not null
    if (_qrViewController != null) {
      // flip the camera
      await _qrViewController!.flipCamera();
    }
  }
}
