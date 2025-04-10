import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SatuanFormPage extends StatefulWidget {
  final Map<String, dynamic>? satuan;

  SatuanFormPage({this.satuan});

  @override
  _SatuanFormPageState createState() => _SatuanFormPageState();
}

class _SatuanFormPageState extends State<SatuanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _keteranganController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.satuan != null) {
      _namaController.text = widget.satuan!['nama'];
      _keteranganController.text = widget.satuan!['keterangan'];
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      setState(() => _isLoading = true);
      
      // Simulate API call
      Future.delayed(Duration(seconds: 2), () {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.satuan == null 
                ? 'Unit added successfully' 
                : 'Unit updated successfully'
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.satuan == null ? 'New Unit' : 'Edit Unit',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF6E45E2),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6E45E2), Color(0xFF88D3CE)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.straighten, size: 60, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Unit Name',
                        floatingLabelStyle: TextStyle(color: Color(0xFF6E45E2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.straighten, color: Colors.grey),
                      ),
                      style: TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter unit name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _keteranganController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        floatingLabelStyle: TextStyle(color: Color(0xFF6E45E2)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.description, color: Colors.grey),
                      ),
                      maxLines: 3,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6E45E2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                                )
                            : Text(
                                widget.satuan == null ? 'CREATE UNIT' : 'UPDATE UNIT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}