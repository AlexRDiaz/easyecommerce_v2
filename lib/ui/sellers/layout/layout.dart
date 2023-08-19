import 'package:flutter/material.dart';

import 'package:frontend/config/exports.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/sellers/navigation_provider.dart';
import 'package:frontend/ui/sellers/add_seller_user/add_seller_user.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/cash_withdrawals_sellers.dart';
import 'package:frontend/ui/sellers/dashboard/dashboard.dart';
import 'package:frontend/ui/sellers/delivery_status/delivery_status.dart';
import 'package:frontend/ui/sellers/my_cart_sellers/my_cart_sellers.dart';
import 'package:frontend/ui/sellers/my_seller_account/my_seller_account.dart';
import 'package:frontend/ui/sellers/my_stock/my_stock.dart';
import 'package:frontend/ui/sellers/order_entry/order_entry.dart';
import 'package:frontend/ui/sellers/order_history_sellers/order_history_sellers.dart';
import 'package:frontend/ui/sellers/providers_sellers/providers_sellers.dart';
import 'package:frontend/ui/sellers/returns_seller/returns_seller.dart';
import 'package:frontend/ui/sellers/sales_report/sales_report.dart';
import 'package:frontend/ui/sellers/unwanted_orders_sellers/unwanted_orders_sellers.dart';
import 'package:frontend/ui/sellers/update_password/update_password.dart';
import 'package:frontend/ui/sellers/wallet_sellers/wallet_sellers.dart';
import 'package:frontend/ui/welcome/welcome.dart';

import 'package:frontend/ui/widgets/logistic/layout/navbar_drawer.dart';
import 'package:provider/provider.dart';

class LayoutSellersPage extends StatefulWidget {
  const LayoutSellersPage({super.key});

  @override
  State<LayoutSellersPage> createState() => _LayoutSellersPageState();
}

class _LayoutSellersPageState extends State<LayoutSellersPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late NavigationProviderSellers navigation;
  @override
  void didChangeDependencies() {
    navigation = Provider.of<NavigationProviderSellers>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      getOption("DashBoard", DashBoardSellers()),
      getOption(
        "Reporte de Ventas",
        SalesReport(),
      ),
      getOption(
        "Mi Cuenta Vendedor",
        MySellerAccount(),
      ),
      getOption(
        "Agregar Usuarios Vendedores",
        AddSellerUser(),
      ),
      getOption(
        "Ingreso de Pedidos",
        OrderEntry(),
      ),
      getOption(
        "Estado Entregas Pedidos",
        DeliveryStatus(),
      ),
      getOption(
        "Pedidos No Deseados",
        UnwantedOrdersSellers(),
      ),
      getOption(
        "Billetera",
        WalletSellers(),
      ),
      getOption(
        "Devoluciones",
        ReturnsSeller(),
      ),
      getOption(
        "Retiros en Efectivo",
        CashWithdrawalsSellers(),
      ),
      getOption("Cambiar Contraseña", UpdatePasswordSellers()),
    ];
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            _key.currentState!.openDrawer();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImageIcon(
                AssetImage(images.menuIcon),
                size: 35,
              ),
            ],
          ),
        ),
        title: Container(
          width: double.infinity,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                images.logoEasyEcommercce,
                width: 30,
              ),
              SizedBox(
                width: 10,
              ),
              Flexible(
                child: Text(
                  navigation.nameWindow,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: getNavbarDrawerSellers(context),
      ),
      body: SafeArea(child: pages[navigation.index]),
    );
  }

  getOption(name, data) {
    switch (name) {
      case "Mi Cuenta Vendedor":
        return data;
      case "Cambiar Contraseña":
        return data;
      case "Cerrar Sesión":
        return data;
      default:
        if (sharedPrefs!.getStringList("PERMISOS")!.isNotEmpty) {
          if (sharedPrefs!.getStringList("PERMISOS")![0].contains(name)) {
            return data;
          } else {
            return Container();
          }
        } else {
          return Container();
        }
    }
  }
}
