import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'satuan_form_page.dart';

class SatuanListPage extends StatelessWidget {
  final List<Map<String, dynamic>> _satuans = [
    {
      'id': '1',
      'nama': 'Pieces',
      'keterangan': 'Individual items count',
      'created_at': 'Today, 10:30 AM',
      'color': Color(0xFF6E45E2),
    },
    {
      'id': '2',
      'nama': 'Kilograms',
      'keterangan': 'Weight measurement',
      'created_at': 'Yesterday, 3:45 PM',
      'color': Color(0xFF88D3CE),
    },
    {
      'id': '3',
      'nama': 'Liters',
      'keterangan': 'Liquid volume measurement',
      'created_at': 'Jun 12, 2023',
      'color': Color(0xFFFF9A9E),
    },
    {
      'id': '4',
      'nama': 'Meters',
      'keterangan': 'Length measurement',
      'created_at': 'Jun 5, 2023',
      'color': Color(0xFF4CC9F0),
    },
    {
      'id': '5',
      'nama': 'Boxes',
      'keterangan': 'Packaged items',
      'created_at': 'May 28, 2023',
      'color': Color(0xFFA162E8),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF6E45E2),
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(context, 
            MaterialPageRoute(builder: (context) => SatuanFormPage()))
            .then((_) => HapticFeedback.lightImpact());
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Units', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6E45E2), Color(0xFF88D3CE)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final satuan = _satuans[index];
                  return _buildSatuanCard(context, satuan)
                    .animate()
                    .fadeIn(delay: (100 * index).ms)
                    .slideX(begin: 0.2);
                },
                childCount: _satuans.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatuanCard(BuildContext context, Map<String, dynamic> satuan) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [satuan['color'].withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: satuan['color'].withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.straighten, color: satuan['color']),
          ),
          title: Text(
            satuan['nama'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                satuan['keterangan'],
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                satuan['created_at'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
                value: 'edit',
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
                value: 'delete',
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SatuanFormPage(satuan: satuan),
                  ),
                );
              } else if (value == 'delete') {
                _showDeleteDialog(context, satuan['nama']);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, 
                size: 60, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Delete Unit?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "$name"?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('CANCEL', 
                      style: TextStyle(color: Colors.grey[600])),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"$name" deleted successfully'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: Text('DELETE', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}