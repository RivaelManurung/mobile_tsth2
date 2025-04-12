import 'package:flutter/material.dart';
import 'package:inventory_tsth2/core/routes/routes_name.dart';
import 'package:inventory_tsth2/screens/auth/login.dart' as auth;
import 'package:inventory_tsth2/screens/barang/barang_page.dart';
import 'package:inventory_tsth2/screens/dahsboard/dashboard.dart';
import 'package:inventory_tsth2/screens/dahsboard/qr_dashboard_page.dart';
import 'package:inventory_tsth2/screens/profile/profile_page.dart';
import 'package:inventory_tsth2/screens/satuan/satuan_list_page.dart';
import 'package:inventory_tsth2/screens/satuan/satuan_detail_page.dart';
import 'package:inventory_tsth2/screens/gudang/gudang_list_page.dart';
import 'package:inventory_tsth2/screens/jenis_barang/jenis_barang_list_page.dart';
import 'package:inventory_tsth2/screens/barang_category/barang_category_list_page.dart';
import 'package:inventory_tsth2/screens/transaction_type/transaction_type_list_page.dart';
import 'package:inventory_tsth2/screens/barang/barang_detail_page.dart';
import 'package:inventory_tsth2/screens/barang_category/barang_category_detail_page.dart';
import 'package:inventory_tsth2/screens/jenis_barang/jenis_barang_detail_page.dart';
import 'package:inventory_tsth2/screens/gudang/gudang_detail_page.dart';

class Routes {
  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    debugPrint("Navigating to route: ${routeSettings.name}"); // Debug log
    switch (routeSettings.name) {
      case RoutesName.login:
        return MaterialPageRoute(builder: (context) => auth.LoginPage());
      case RoutesName.main:
      case RoutesName.dashboard:
        return MaterialPageRoute(builder: (context) => DashboardPage());
      case RoutesName.profile:
        return MaterialPageRoute(builder: (context) => ProfilePage());
      case RoutesName.qrTools:
        return MaterialPageRoute(builder: (context) => QRDashboardPage());
      case RoutesName.units:
      case RoutesName.satuanList:
        return MaterialPageRoute(builder: (context) => SatuanListPage());
      case RoutesName.barangList:
        return MaterialPageRoute(builder: (context) => BarangListPage());
      case RoutesName.gudangList:
        return MaterialPageRoute(builder: (context) => GudangListPage());
      case RoutesName.jenisBarangList:
        return MaterialPageRoute(builder: (context) => JenisBarangListPage());
      case RoutesName.barangCategoryList:
        return MaterialPageRoute(builder: (context) => BarangCategoryListPage());
      case RoutesName.transactionTypeList:
        return MaterialPageRoute(builder: (context) => TransactionTypeListPage());
      case RoutesName.satuanDetail:
        return MaterialPageRoute(builder: (context) => SatuanDetailPage());
      case RoutesName.barangCategoryDetail:
        return MaterialPageRoute(builder: (context) => BarangCategoryDetailPage());
      case RoutesName.jenisBarangDetail:
        return MaterialPageRoute(builder: (context) => JenisBarangDetailPage());
      case RoutesName.gudangDetail:
        return MaterialPageRoute(builder: (context) => GudangDetailPage());
      case RoutesName.barangDetail:
        return MaterialPageRoute(builder: (context) => BarangDetailPage());
      default:
        debugPrint("Route not found: ${routeSettings.name}");
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text("No route found for this path")),
          ),
        );
    }
  }
}