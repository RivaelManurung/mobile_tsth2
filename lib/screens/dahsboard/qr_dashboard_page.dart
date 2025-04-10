import 'package:flutter/material.dart';
import 'qr_scanner_page.dart';
import 'qr_generator_page.dart';

class QRDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text('QR Tools', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionCard(
              context,
              Icons.qr_code_scanner,
              'Scan QR Code',
              Colors.tealAccent,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerPage()),
              ),
            ),
            SizedBox(height: 30),
            _buildActionCard(
              context,
              Icons.qr_code,
              'Generate QR Code',
              Colors.blueAccent,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRGeneratorPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}