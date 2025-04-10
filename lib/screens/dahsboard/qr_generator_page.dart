import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorPage extends StatefulWidget {
  @override
  _QRGeneratorPageState createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _controller = TextEditingController();
  String qrData = 'https://example.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('QR Generator', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter data for QR code',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.tealAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.tealAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.tealAccent, width: 2),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  setState(() {
                    qrData = _controller.text;
                  });
                }
              },
              child: Text('Generate QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}