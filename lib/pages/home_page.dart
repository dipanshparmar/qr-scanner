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
          FlashAndCameraControls(_qrViewController)
        ],
      ),
    );
  }
}
