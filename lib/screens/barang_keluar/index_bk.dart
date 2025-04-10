// import 'package:flutter/material.dart';
// import 'package:inventory_tsth2/controller/Barang/BarangController.dart';
// import 'package:inventory_tsth2/widget/custom_button.dart';
// import 'package:inventory_tsth2/widget/custom_formfield.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class BarangKeluarPage extends StatefulWidget {
//   @override
//   _BarangKeluarPageState createState() => _BarangKeluarPageState();
// }

// class _BarangKeluarPageState extends State<BarangKeluarPage> {
//   final BarangController _controller = BarangController();
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => isLoading = true);
//     await _controller.getAllBarang();
//     setState(() => isLoading = false);
//   }

//   void _showFormDialog({Map<String, dynamic>? data}) async {
//     final List<Map<String, dynamic>> barangList =
//         await _controller.getAllBarang();
//     Map<String, dynamic>? selectedBarang = barangList.firstWhere(
//       (item) => item['id'] == data?['id'],
//       orElse: () => {},
//     );

//     final TextEditingController jumlahController =
//         TextEditingController(text: data?['jumlah']?.toString() ?? '');

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//           title: Text(
//             data == null ? 'Tambah Barang Keluar' : 'Edit Barang Keluar',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: StatefulBuilder(
//             builder: (context, setDialogState) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   DropdownSearch<Map<String, dynamic>>(
//                     asyncItems: (String filter) async {
//                       return await _controller.getAllBarang();
//                     },
//                     itemAsString: (item) => item['nama'],
//                     onChanged: (value) {
//                       setDialogState(() {
//                         selectedBarang = value;
//                       });
//                     },
//                     selectedItem:
//                         selectedBarang.isNotEmpty ? selectedBarang : null,
//                     dropdownDecoratorProps: DropDownDecoratorProps(
//                       baseStyle: TextStyle(fontSize: 16),
//                       dropdownSearchDecoration: InputDecoration(
//                         labelText: "Pilih Barang",
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   CustomFormField(
//                     headingText: "Jumlah",
//                     hintText: "Masukkan jumlah",
//                     obsecureText: false,
//                     controller: jumlahController,
//                     suffixIcon: const SizedBox(),
//                     textInputType: TextInputType.number,
//                     textInputAction: TextInputAction.done,
//                     maxLines: 1,
//                   ),
//                   if (selectedBarang.isNotEmpty) ...[
//                     SizedBox(height: 20),
//                     QrImage(
//                       data: selectedBarang!['id'].toString(),
//                       size: 100,
//                     ),
//                   ]
//                 ],
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Batal", style: TextStyle(color: Colors.red)),
//             ),
//             CustomButton(
//               text: data == null ? 'Tambah' : 'Update',
//               onTap: () async {
//                 if (selectedBarang.isEmpty || jumlahController.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Semua field harus diisi")),
//                   );
//                   return;
//                 }

//                 int jumlah;
//                 try {
//                   jumlah = int.parse(jumlahController.text.trim());
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Jumlah harus berupa angka")),
//                   );
//                   return;
//                 }

//                 final barang = {
//                   'id': selectedBarang!['id'],
//                   'nama': selectedBarang!['nama'],
//                   'jumlah': jumlah,
//                 };

//                 if (data == null) {
//                   await _controller.addBarang(barang);
//                 } else {
//                   await _controller.updateBarang(data['id'], barang);
//                 }
//                 Navigator.pop(context);
//                 _loadData();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Barang Keluar"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : FutureBuilder<List<Map<String, dynamic>>>(
//               future: _controller.getAllBarang(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text("Terjadi kesalahan"));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text("Tidak ada barang keluar"));
//                 }
//                 final barangList = snapshot.data!;
//                 return ListView.builder(
//                   padding: EdgeInsets.all(10),
//                   itemCount: barangList.length,
//                   itemBuilder: (context, index) {
//                     final barang = barangList[index];
//                     return Card(
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15)),
//                       elevation: 5,
//                       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
//                       child: ListTile(
//                         contentPadding: EdgeInsets.all(15),
//                         title: Text(barang['nama'],
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         subtitle: Text("Jumlah: ${barang['jumlah']}",
//                             style: TextStyle(
//                                 fontSize: 14, color: Colors.grey[700])),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.edit, color: Colors.blue),
//                               onPressed: () => _showFormDialog(data: barang),
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.delete, color: Colors.red),
//                               onPressed: () async {
//                                 await _controller.deleteBarang(barang['id']);
//                                 _loadData();
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.blueAccent,
//         child: Icon(Icons.add, color: Colors.white),
//         onPressed: () => _showFormDialog(),
//       ),
//     );
//   }
// }
