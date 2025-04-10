import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class QrcodePage extends StatefulWidget {
  @override
  _QrcodePageState createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          _buildScannerOverlay(),
          Positioned(
            top: 40,
            left: 16,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 16),
                Text(
                  "Scan QRIS",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange, width: 3),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      bottom: 40,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.flash_on, color: Colors.white, size: 30),
            onPressed: () async {
              await controller?.toggleFlash();
            },
          ),
          IconButton(
            icon: Icon(Icons.photo_library, color: Colors.white, size: 30),
            onPressed: () async {
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                // Proses gambar yang dipilih dari galeri
                // Anda bisa menggunakan package qr_code_scanner_plus untuk memproses gambar
                // dan mengekstrak kode QR dari gambar tersebut.
                // Contoh:
                // final File imageFile = File(image.path);
                // final Barcode? barcode = await controller?.scanImage(imageFile);
                // setState(() {
                //   result = barcode;
                // });
              }
            },
          ),
        ],
      ),
    );
  }
}