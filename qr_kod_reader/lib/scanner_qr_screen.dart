import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScannerScreen extends StatefulWidget {
  ScannerScreen({Key? key}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String scannerQrCode = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR scanner"),
      ),
    );
  }

  Future<void> scanQR() async {
    try {
      scannerQrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Çıkış',
        true,
        ScanMode.QR,
      );
      // Get.snackbar(
      //   'Result',
      //   'QR code ' + scannerQrCode,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
    } on PlatformException {}
  }
}
