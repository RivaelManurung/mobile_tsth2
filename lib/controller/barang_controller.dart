import 'package:get/get.dart';
import 'package:inventory_tsth2/Model/barang_gudang_model.dart';
import 'package:inventory_tsth2/Model/barang_model.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/services/barang_service.dart';

class BarangController extends GetxController {
  final BarangService _service;

  // Reactive state variables
  final RxList<Barang> barangList = <Barang>[].obs;
  final Rx<Barang?> selectedBarang = Rx<Barang?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<int, List<BarangGudang>> barangGudangs = <int, List<BarangGudang>>{}.obs;

  BarangController({BarangService? service})
      : _service = service ?? BarangService();

  @override
  void onInit() {
    super.onInit();
    getAllBarang();
  }

  Future<void> getAllBarang() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await _service.getAllBarangWithGudangs();
      barangList.assignAll(response.map((item) => Barang.fromJson(item)).toList());
      barangGudangs.assignAll({
        for (var item in response)
          item['id'] as int: (item['gudangs'] as List<dynamic>)
              .map((g) => BarangGudang.fromJson({
                    ...g,
                    'barang_id': item['id'], // Tambahkan barang_id untuk BarangGudang
                    'gudang_id': g['id'], // Pastikan gudang_id diambil dari gudang
                  }))
              .toList(),
      });
    } catch (e) {
      errorMessage(e.toString());
      if (errorMessage.value.contains('Unauthenticated')) {
        Get.offAllNamed(RoutesName.login);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> getBarangById(int id) async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await _service.getBarangByIdWithGudangs(id);
      selectedBarang(Barang.fromJson(response));
      barangGudangs[id] = (response['gudangs'] as List<dynamic>)
          .map((g) => BarangGudang.fromJson({
                ...g,
                'barang_id': id,
                'gudang_id': g['id'],
              }))
          .toList();
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }
}