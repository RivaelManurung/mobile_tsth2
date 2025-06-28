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
      // Ambil data barang terlebih dahulu
      final barangData = await _service.getAllBarang();
      barangList.assignAll(barangData);

      // Ambil data BarangGudang dan kelompokkan berdasarkan barangId
      final gudangData = await _service.getAllBarangWithGudangs();
      barangGudangs.assignAll({
        for (var bg in gudangData)
          bg.barangId: (barangGudangs[bg.barangId] ?? [])..add(bg),
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
      // Ambil data barang spesifik
      final barang = await _service.getBarangById(id);
      selectedBarang(barang);

      // Ambil data BarangGudang untuk barang spesifik
      final gudang = await _service.getBarangByIdWithGudangs(id);
      barangGudangs[id] = [gudang];
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }
}