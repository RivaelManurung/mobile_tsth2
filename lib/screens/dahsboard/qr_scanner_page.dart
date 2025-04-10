import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isFlashOn = false;
  bool isCameraFrontFacing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('QR Scanner', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off, 
                     color: Colors.white),
            onPressed: () {
              setState(() {
                isFlashOn = !isFlashOn;
                cameraController.toggleTorch();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () {
              setState(() {
                isCameraFrontFacing = !isCameraFrontFacing;
                cameraController.switchCamera();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                _showResultDialog(barcode.rawValue ?? 'No data found');
              }
            },
          ),
          _buildScannerOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.tealAccent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showResultDialog(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scanned Result'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: data));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied to clipboard')),
                  );
                  Navigator.pop(context);
                },
                child: Text('Copy to Clipboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}