import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import 'package:frontend/config/exports.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/provider/navigation_provider.dart';
import 'package:frontend/providers/sellers/navigation_provider.dart';
import 'package:frontend/ui/provider/add_provider/sub_providers_view.dart';
import 'package:frontend/ui/provider/layout/welcome_provider_screen.dart';
import 'package:frontend/ui/provider/guidesgroup/guides_sent/table_orders_guides_sent.dart';
import 'package:frontend/ui/provider/guidesgroup/print_guides/print_guides.dart';
import 'package:frontend/ui/provider/guidesgroup/printed_guides/printedguides.dart';
import 'package:frontend/ui/provider/products/products_view.dart';
import 'package:frontend/ui/provider/profile/profile_view.dart';
import 'package:frontend/ui/provider/transactions/transactions_view.dart';
import 'package:frontend/ui/provider/warehouses/warehouses.dart';
import 'package:frontend/ui/sellers/add_seller_user/add_seller_user.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/cash_withdrawals_sellers.dart';
import 'package:frontend/ui/sellers/dashboard/dashboard.dart';
import 'package:frontend/ui/sellers/delivery_status/delivery_status.dart';
import 'package:frontend/ui/sellers/guides_sent/table_orders_guides_sent.dart';
import 'package:frontend/ui/sellers/my_cart_sellers/my_cart_sellers.dart';
import 'package:frontend/ui/sellers/my_seller_account/my_seller_account.dart';
import 'package:frontend/ui/sellers/my_stock/my_stock.dart';
import 'package:frontend/ui/sellers/my_wallet/my_wallet.dart';
import 'package:frontend/ui/sellers/order_entry/order_entry.dart';
import 'package:frontend/ui/sellers/order_history_sellers/order_history_sellers.dart';
import 'package:frontend/ui/sellers/print_guides/print_guides.dart';
import 'package:frontend/ui/sellers/printed_guides/printedguides.dart';
import 'package:frontend/ui/sellers/providers_sellers/providers_sellers.dart';
import 'package:frontend/ui/sellers/returns_seller/returns_seller.dart';
import 'package:frontend/ui/sellers/sales_report/sales_report.dart';
import 'package:frontend/ui/sellers/unwanted_orders_sellers/unwanted_orders_sellers.dart';
import 'package:frontend/ui/sellers/update_password/update_password.dart';
import 'package:frontend/ui/sellers/wallet_sellers/wallet_sellers.dart';
import 'package:frontend/ui/welcome/welcome.dart';

import 'package:frontend/ui/widgets/logistic/layout/navbar_drawer.dart';
import 'package:provider/provider.dart';

import 'package:frontend/ui/sellers/transport_stats/transport_stats.dart';

class LayoutProvidersPage extends StatefulWidget {
  const LayoutProvidersPage({super.key});

  @override
  State<LayoutProvidersPage> createState() => _LayoutProvidersPageState();
}

class _LayoutProvidersPageState extends State<LayoutProvidersPage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var email = sharedPrefs!.getString("email").toString();
  var username = sharedPrefs!.getString("username").toString();

  final GlobalKey _menuKey = GlobalKey();

  late NavigationProviderProvider navigation;
  @override
  void didChangeDependencies() {
    navigation = Provider.of<NavigationProviderProvider>(context);
    super.didChangeDependencies();
  }

//
  @override
  Widget build(BuildContext context) {
    List pages = [
      getOption(
        "Home",
        WelcomeProviderScreen(),
      ),
      getOption(
        "Productos",
        const ProductsView(),
      ),
      getOption(
        "Bodegas",
        const WarehousesView(),
      ),
      getOption(
        "Sub Proveedores",
        SubProviderView(),
      ),
      getOption(
        "Mis Transacciones",
        const TransactionsView(),
      ),
      getOption(
        "Imprimir Guías",
        const PrintGuidesProvider(),
      ),
      getOption(
        "Guías Impresas",
        const PrintedGuidesProvider(),
      ),
      getOption("Guías Enviadas", const TableOrdersGuidesSentProvider()),
    ];
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              images.logoEasyEcommercce,
              width: 30,
            ),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                navigation.nameWindow,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(10),
            child: const Icon(
              size: 40,
              Icons.account_circle,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero, // Elimina el relleno alrededor del botón
            child: Row(
              children: [
                Text(
                  "${email}",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                const Icon(
                  Icons
                      .arrow_drop_down, // Icono de flecha hacia abajo para indicar que es un menú
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ],
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  child: Text(
                    "Hola, ${username}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  enabled: false,
                ),
                PopupMenuItem<String>(
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text("Mi Cuenta Vendedor"),
                    ],
                  ),
                  value: "my_account",
                ),
                PopupMenuItem<String>(
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text("Cambiar Contraseña"),
                    ],
                  ),
                  value: "password",
                ),
                PopupMenuItem<String>(
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_sharp,
                        color: Colors.black,
                      ),
                      SizedBox(width: 5),
                      Text("Cerrar Sesión"),
                    ],
                  ),
                  value: "log_out",
                ),
              ];
            },
            onSelected: (value) {
              if (value == "my_account") {
                profileViewModal(context);
              } else if (value == "password") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UpdatePasswordSellers()));
              } else if (value == "log_out") {
                // Navigator.pushNamedAndRemoveUntil(
                //     context, '/login', (Route<dynamic> route) => false);
                showLogoutConfirmationDialog2(context);
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: getNavbarDrawerProviders(context),
      ),
      body: SafeArea(child: pages[navigation.index]),
    );
  }

  Future<void> showLogoutConfirmationDialog2(BuildContext context) async {
    return AwesomeDialog(
      width: 500,
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.rightSlide,
      title: 'Confirmar Cierre de Sesión',
      desc: '¿Está seguro de que desea cerrar sesión?',
      btnCancelText: 'Cancelar',
      btnCancelOnPress: () {},
      btnOkText: 'Aceptar',
      btnOkColor: colors.colorGreen,
      btnOkOnPress: () {
        // Navigator.of(context).pop();
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', (Route<dynamic> route) => false);
      },
    ).show();
  }

  Future<dynamic> profileViewModal(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(0.0), // Establece el radio del borde a 0
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.9,
            child: ProfileView(),
          ),
        );
      },
    ).then((value) {
      // Aquí puedes realizar cualquier acción que necesites después de cerrar el diálogo
      // Por ejemplo, actualizar algún estado
      // setState(() {
      //   //_futureProviderData = _loadProviders(); // Actualiza el Future
      // });
    });
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
