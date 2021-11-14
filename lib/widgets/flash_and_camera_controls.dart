import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class FlashAndCameraControls extends StatefulWidget {
  const FlashAndCameraControls(
    this._qrViewController, {
    Key? key,
  }) : super(key: key);

  // qr view controller to control the flash and the camera
  final QRViewController _qrViewController;

  @override
  State<FlashAndCameraControls> createState() => _FlashAndCameraControlsState();
}

class _FlashAndCameraControlsState extends State<FlashAndCameraControls> {
  // flash icon
  IconData _flashIcon = Icons.flashlight_off;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
    // toggle the flash
    await widget._qrViewController.toggleFlash();

    // getting the status of the flash
    final bool? isOn = await widget._qrViewController.getFlashStatus();

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

  // method to toggle the camera
  Future<void> _toggleCamera() async {
    // flip the camera
    await widget._qrViewController.flipCamera();
  }
}