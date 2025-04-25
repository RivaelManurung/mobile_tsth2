import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inventory_tsth2/Model/gudang_model.dart';
import 'package:inventory_tsth2/Model/barang_gudang_model.dart';
import 'package:inventory_tsth2/config/api.dart';
import 'package:inventory_tsth2/services/auth_service.dart';

class GudangService {
  final Dio _dio;
  late final FlutterSecureStorage _storage;
  final AuthService _authService;

  GudangService({
    Dio? dio,
    FlutterSecureStorage? storage,
    AuthService? authService,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              headers: {'Accept': 'application/json'},
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            )),
        _authService = authService ?? AuthService() {
    _storage = storage ?? const FlutterSecureStorage();
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<String?> _getToken() async {
    final token = await _authService.getToken();
    print('Token retrieved in GudangService: $token');
    return token;
  }

  Future<bool> _validateToken(String token) async {
    bool isValid = token.isNotEmpty;
    print('Token valid: $isValid');
    return isValid;
  }

  Future<List<Gudang>> getAllGudang({int retries = 3, Duration delay = const Duration(seconds: 2)}) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    if (!(await _validateToken(token))) throw Exception('Invalid token');

    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        print('Attempt $attempt of $retries: Fetching gudang from API...');
        final response = await _dio.get(
          '/gudangs',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Cache-Control': 'no-cache',
            },
          ),
        );

        print('getAllGudang response: ${response.data}');

        if (response.statusCode == 200) {
          List<dynamic> data = response.data['data'] ?? response.data;
          print('Parsing JSON for gudang list: $data');
          return data.map((json) => Gudang.fromJson(json)).toList();
        } else {
          throw Exception(response.data['message'] ?? 'Gagal memuat daftar gudang');
        }
      } on DioException catch (e) {
        print('DioException in getAllGudang (attempt $attempt): ${e.message}');
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
        if (attempt == retries) {
          throw _handleError(e);
        }
        print('Retrying after $delay...');
        await Future.delayed(delay);
      } catch (e) {
        print('Unexpected error in getAllGudang (attempt $attempt): $e');
        if (attempt == retries) {
          rethrow;
        }
        print('Retrying after $delay...');
        await Future.delayed(delay);
      }
    }
    throw Exception('Gagal memuat daftar gudang setelah $retries percobaan');
  }

  Future<Gudang> getGudangById(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('No token found');
    if (!(await _validateToken(token))) throw Exception('Invalid token');

    try {
      print('Fetching gudang with ID $id');
      final response = await _dio.get(
        '/gudangs/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('getGudangById response: ${response.data}');

      if (response.statusCode == 200) {
        print('Gudang: Parsing JSON: ${response.data['data']}');
        return Gudang.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat detail gudang');
      }
    } on DioException catch (e) {
      print('DioException in getGudangById: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    } catch (e) {
      print('Unexpected error in getGudangById: $e');
      rethrow;
    }
  }


  String _handleError(DioException e) {
    if (e.response?.statusCode == 401) {
      return 'No token found';
    }
    if (e.response?.data != null) {
      if (e.response?.data['message'] != null) {
        return e.response!.data['message'];
      }
      if (e.response?.data['error'] != null) {
        return e.response!.data['error'];
      }
      if (e.response?.data['errors'] != null) {
        final errors = e.response!.data['errors'] as Map<String, dynamic>;
        String errorMessage = '';
        for (var field in errors.keys) {
          if (errors[field] is List && errors[field].isNotEmpty) {
            errorMessage += '${errors[field][0]}\n';
          }
        }
        return errorMessage.trim();
      }
    }
    return e.message ?? 'Terjadi kesalahan jaringan. Pastikan server berjalan dan koneksi stabil.';
  }
}