import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/logistic/navigation_provider.dart';
import 'package:frontend/providers/sellers/navigation_provider.dart';
import 'package:frontend/ui/sellers/add_seller_user/add_seller_user.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/cash_withdrawals_sellers.dart';
import 'package:frontend/ui/sellers/catalog/catalog.dart';
import 'package:frontend/ui/sellers/dashboard/dashboard.dart';
import 'package:frontend/ui/sellers/delivery_status/delivery_status.dart';
import 'package:frontend/ui/sellers/guides_sent/table_orders_guides_sent.dart';
import 'package:frontend/ui/sellers/layout/layout_mobile.dart';
import 'package:frontend/ui/sellers/my_integrations/my_integrations.dart';
import 'package:frontend/ui/sellers/my_seller_account/my_seller_account.dart';
import 'package:frontend/ui/sellers/my_wallet/my_wallet.dart';
import 'package:frontend/ui/sellers/order_entry/order_entry.dart';
import 'package:frontend/ui/sellers/print_guides/print_guides.dart';
import 'package:frontend/ui/sellers/printed_guides/printedguides.dart';
import 'package:frontend/ui/sellers/returns_seller/returns_seller.dart';
import 'package:frontend/ui/sellers/sales_report/sales_report.dart';
import 'package:frontend/ui/sellers/transport_stats/transport_stats.dart';
import 'package:frontend/ui/sellers/unwanted_orders_sellers/unwanted_orders_sellers.dart';
import 'package:frontend/ui/sellers/update_password/update_password.dart';
import 'package:frontend/ui/sellers/wallet_sellers/wallet_sellers.dart';
import 'package:frontend/ui/widgets/logistic/layout/navbar_drawer.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LayoutSellersPage extends StatefulWidget {
  const LayoutSellersPage({Key? key}) : super(key: key);

  @override
  State<LayoutSellersPage> createState() => _LayoutSellersPageState();
}

class _LayoutSellersPageState extends State<LayoutSellersPage> {
  bool isSidebarOpen = sharedPrefs!.getBool("sidebarOpen") != null
      ? sharedPrefs!.getBool("sidebarOpen") ?? false
      : false;
  List<String> permissions = sharedPrefs!.getStringList("PERMISOS")!;

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var email = sharedPrefs!.getString("email").toString();
  var username = sharedPrefs!.getString("username").toString();
  Map currentView = Map();
  bool isSelected =
      false; // Variable para controlar si el elemento está seleccionado

  final GlobalKey _menuKey = GlobalKey();
  late NavigationProviderSellers navigation;
  Color colorlabels = Colors.black;
  Color colorDrawer = Colors.white;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    try {
      // navigation = Provider.of<NavigationProviderSellers>(context);
      var currentIndex = sharedPrefs!.getString("index");
      currentView = {
        "page": sharedPrefs!.getString("index") != null
            ? pagesSeller[int.parse(sharedPrefs!.getString("index").toString())]
                ["page"]
            : "Dashboard",
        "view": sharedPrefs!.getString("index") != null
            ? pagesSeller[int.parse(sharedPrefs!.getString("index").toString())]
                ["view"]
            : DashBoardSellers()
      };
      if (sharedPrefs!.getString("index") != null) {
        pagesSeller = List.from(pagesSeller)
          ..[int.parse(sharedPrefs!.getString("index").toString())]
              ['selected'] = true;
      }
    } catch (e) {
      print(e);
      currentView = {"page": "Dashboard", "view": DashBoardSellers()};
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double heigth = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        return responsive(_buildWebLayout(), _buildPhoneLayout(), context);
      },
    );
  }

  Widget _buildPhoneLayout() {
    double screenWidth = MediaQuery.of(context).size.width;
    double textSizeTitle = screenWidth > 600 ? 22 : 14;
    // print(isSidebarOpen);
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        // toolbarHeight: heigth * 0.060,
        leadingWidth: screenWidth * 0.6,
        actions: getActions,
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  _key.currentState!.openDrawer();

                  isSidebarOpen = !isSidebarOpen;
                  sharedPrefs!.setBool("sidebarOpen", isSidebarOpen);
                });
              },
            ),
            // Text(
            //   sharedPrefs!.getString("NameComercialSeller").toString(),
            //   style: TextStyle(color: Colors.white),
            // )
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Material(
          elevation: 5,
          child: Container(
            color: Colors.white,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      //  width: width * 0.11,

                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 40, right: 40, top: 20, bottom: 20),
                        child: Image.asset(images.logoEasyEcommercce,
                            fit: BoxFit.fill),
                      ),
                    ),
                    // Separación entre el encabezado y el menú
                    Divider(),
                    _buildMenu(
                        'Crear', Icon(Icons.person, color: colorlabels), [
                      _buildMenuItem(
                          'Agregar vendedor',
                          'Agregar Usuarios Vendedores',
                          Icon(Icons.person_add, color: colorlabels)),
                    ]),
                    Divider(
                      endIndent: 10,
                      indent: 10,
                    ),
                    _buildMenu(
                        'Reportes', Icon(Icons.report, color: colorlabels), [
                      _buildMenuItem('Ingreso de pedidos', 'Ingreso de Pedidos',
                          Icon(Icons.shopping_cart, color: colorlabels)),
                      _buildMenuItem('DashBoard', 'DashBoard',
                          Icon(Icons.dashboard_customize, color: colorlabels)),
                      _buildMenuItem(
                          'Estado de entregas',
                          'Estado Entregas Pedidos',
                          Icon(Icons.local_shipping, color: colorlabels)),
                      _buildMenuItem(
                          'Pedidos no deseados',
                          'Pedidos No Deseados',
                          Icon(Icons.delete, color: colorlabels)),
                      _buildMenuItem('Devoluciones', 'Devoluciones',
                          Icon(Icons.assignment_return, color: colorlabels)),
                      // _buildMenuItem(
                      //     'Catálogo de Productos',
                      //     'Catálogo de Productos',
                      //     Icon(Icons.shopping_bag_rounded, color: colorlabels)),
                    ]),
                    Divider(
                      endIndent: 10,
                      indent: 10,
                    ),
                    _buildMenu(
                        'Movimientos', Icon(Icons.paid, color: colorlabels), [
                      _buildMenuItem('Billetera', 'Billetera',
                          Icon(Icons.wallet, color: colorlabels)),
                      _buildMenuItem('Mi Billetera', 'Mi Billetera',
                          Icon(Icons.wallet, color: colorlabels)),
                      _buildMenuItem(
                          "Retiros en efectivo",
                          'Retiros en Efectivo',
                          Icon(Icons.account_balance, color: colorlabels)),
                    ]),
                    Divider(
                      endIndent: 10,
                      indent: 10,
                    ),
                    _buildMenu(
                        'Imprimir', Icon(Icons.print, color: colorlabels), [
                      _buildMenuItem('Imprimir guías', 'Imprimir Guías',
                          Icon(Icons.print_outlined, color: colorlabels)),
                      _buildMenuItem('Guías impresas', 'Guías Impresas',
                          Icon(Icons.picture_as_pdf, color: colorlabels)),
                      _buildMenuItem('Guías enviadas', 'Guías Enviadas',
                          Icon(Icons.send, color: colorlabels)),
                      // _buildMenuItem('Mis integraciones', 'Mis integraciones',
                      //     Icon(Icons.settings, color: colorlabels)),
                    ]),
                    const Divider(
                      endIndent: 10,
                      indent: 10,
                    ),
                    _buildMenu('Dropshipping',
                        Icon(Icons.shopping_bag_rounded, color: colorlabels), [
                      _buildMenuItem(
                          'Catálogo de Productos',
                          'Catálogo de Productos',
                          Icon(Icons.shopping_bag_outlined,
                              color: colorlabels)),
                      _buildMenuItem('Mis integraciones', 'Mis integraciones',
                          Icon(Icons.settings, color: colorlabels)),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          currentView["view"],
        ],
      ),
    );
  }

  List<Widget> get getActions {
    return [
      const Icon(
        Icons.account_circle,
        color: Colors.grey,
      ),
      PopupMenuButton<String>(
        padding: EdgeInsets.zero, // Elimina el relleno alrededor del botón
        child: Row(
          children: [
            Text(
              "${email}",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            const Icon(
              Icons
                  .arrow_drop_down, // Icono de flecha hacia abajo para indicar que es un menú
              color: Color.fromARGB(255, 76, 76, 76),
              size: 30,
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MySellerAccount()));
          } else if (value == "password") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdatePasswordSellers()));
          } else if (value == "log_out") {
            showLogoutConfirmationDialog2(context);
          }
        },
      ),
    ];
  }

  Widget _buildWebLayout() {
    double width = MediaQuery.of(context).size.width;
    double heigth = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: heigth * 0.060,
        leadingWidth: width * 0.6,
        actions: getActions,
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                setState(() {
                  isSidebarOpen = !isSidebarOpen;
                  sharedPrefs!.setBool("sidebarOpen", isSidebarOpen);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.store),
              onPressed: () {},
            ),
            Text(
              sharedPrefs!.getString("NameComercialSeller").toString(),
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: 0,
              bottom: 0,
              left: isSidebarOpen ? 260 : 0,
              right: 0,
              child: currentView["view"]),
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.decelerate,
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -260,
            child: Container(
              padding: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorDrawer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0,
                        3), // Cambia la posición de la sombra según tus preferencias
                  ),
                ],
              ),
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    //  width: width * 0.11,

                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 40, right: 40, top: 20, bottom: 20),
                      child: Image.asset(images.logoEasyEcommercce,
                          fit: BoxFit.fill),
                    ),
                  ),
                  // Separación entre el encabezado y el menú
                  Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenu(
                            'Crear', Icon(Icons.person, color: colorlabels), [
                          _buildMenuItem(
                              'Agregar vendedor',
                              'Agregar Usuarios Vendedores',
                              Icon(Icons.person_add, color: colorlabels)),
                        ]),
                        Divider(
                          endIndent: 10,
                          indent: 10,
                        ),
                        _buildMenu('Reportes',
                            Icon(Icons.report, color: colorlabels), [
                          _buildMenuItem(
                              'Ingreso de pedidos',
                              'Ingreso de Pedidos',
                              Icon(Icons.shopping_cart, color: colorlabels)),
                          _buildMenuItem(
                              'DashBoard',
                              'DashBoard',
                              Icon(Icons.dashboard_customize,
                                  color: colorlabels)),
                          _buildMenuItem(
                              'Estado de entregas',
                              'Estado Entregas Pedidos',
                              Icon(Icons.local_shipping, color: colorlabels)),
                          _buildMenuItem(
                              'Pedidos no deseados',
                              'Pedidos No Deseados',
                              Icon(Icons.delete, color: colorlabels)),
                          _buildMenuItem(
                              'Devoluciones',
                              'Devoluciones',
                              Icon(Icons.assignment_return,
                                  color: colorlabels)),
                          // _buildMenuItem(
                          //     'Catálogo de Productos',
                          //     'Catálogo de Productos',
                          //     Icon(Icons.shopping_bag_rounded,
                          //         color: colorlabels)),
                        ]),
                        Divider(
                          endIndent: 10,
                          indent: 10,
                        ),
                        _buildMenu('Movimientos',
                            Icon(Icons.paid, color: colorlabels), [
                          _buildMenuItem('Billetera', 'Billetera',
                              Icon(Icons.wallet, color: colorlabels)),
                          _buildMenuItem('Mi Billetera', 'Mi Billetera',
                              Icon(Icons.wallet, color: colorlabels)),
                          _buildMenuItem(
                              "Retiros en efectivo",
                              'Retiros en Efectivo',
                              Icon(Icons.account_balance, color: colorlabels)),
                        ]),
                        Divider(
                          endIndent: 10,
                          indent: 10,
                        ),
                        _buildMenu(
                            'Imprimir', Icon(Icons.print, color: colorlabels), [
                          _buildMenuItem('Imprimir guías', 'Imprimir Guías',
                              Icon(Icons.print_outlined, color: colorlabels)),
                          _buildMenuItem('Guías impresas', 'Guías Impresas',
                              Icon(Icons.picture_as_pdf, color: colorlabels)),
                          _buildMenuItem('Guías enviadas', 'Guías Enviadas',
                              Icon(Icons.send, color: colorlabels)),
                          // _buildMenuItem(
                          //     'Mis integraciones',
                          //     'Mis integraciones',
                          //     Icon(Icons.settings, color: colorlabels)),
                        ]),
                        Divider(
                          endIndent: 10,
                          indent: 10,
                        ),
                        _buildMenu(
                            'Dropshipping',
                            Icon(Icons.shopping_bag_rounded,
                                color: colorlabels),
                            [
                              _buildMenuItem(
                                  'Catálogo de Productos',
                                  'Catálogo de Productos',
                                  Icon(Icons.shopping_bag_outlined,
                                      color: colorlabels)),
                              _buildMenuItem(
                                  'Mis integraciones',
                                  'Mis integraciones',
                                  Icon(Icons.settings, color: colorlabels)),
                            ]),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _logout() {
  //   return Center(
  //     child: ElevatedButton(
  //       style: const ButtonStyle(
  //           backgroundColor: MaterialStatePropertyAll(Colors.red)),
  //       onPressed: () {
  //         logout();
  //       },
  //       child: const Text("Cerrar sesión"),
  //     ),
  //   );
  // }

  void logout() {
    sharedPrefs?.remove("jwt");
    print("----------------------xxx-----");
    print(sharedPrefs!.getString("jwt"));
    // Redirige al usuario a la página de inicio de sesión
    Get.offAllNamed('/login');
  }

  Future<void> showLogoutConfirmationDialog2(BuildContext context) async {
    return AwesomeDialog(
      width: 500,
      context: context,
      dialogType: DialogType.WARNING,
      animType: AnimType.rightSlide,
      title: 'Cerrar  Sesión',
      desc: '¿Está seguro de que desea cerrar sesión?',
      btnCancelText: 'Cancelar',
      btnCancelOnPress: () {},
      btnOkText: 'Aceptar',
      btnOkColor: colors.colorGreen,
      btnOkOnPress: () {
        // Navigator.of(context).pop();
        // Navigator.pushNamedAndRemoveUntil(
        //     context, '/login', (Route<dynamic> route) => false);
        logout();
      },
    ).show();
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

  Widget _buildMenu(String title, Icon icon, List<Widget> children) {
    final theme = Theme.of(context);

    return ExpansionTile(
      initiallyExpanded: true,
      shape: const Border(),
      title: Row(
        children: [
          icon,
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(color: colorlabels),
            ),
          ),
        ],
      ),
      children: children,
    );
  }

  Widget _buildMenuItem(String label, String title, Icon icon) {
    pagesSeller = pagesSeller;
    final theme = Theme.of(context);
    var betweenSelected =
        pagesSeller.indexWhere((element) => element['selected'] == true);

    var selectedView =
        pagesSeller.firstWhere((element) => element['page'] == title);
    var selectedIndex =
        pagesSeller.indexWhere((element) => element['page'] == title);
    return permissions[0].contains(title)
        ? Container(
            color: selectedView["selected"]
                ? Colors.blue.withOpacity(0.2)
                : Colors.white,
            padding: EdgeInsets.only(left: 20),
            child: ListTile(
              title: Row(
                children: [
                  icon,
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorlabels,
                        // Cambiar el color cuando está seleccionado
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                sharedPrefs!.setString("index", selectedIndex.toString());

                setState(() {
                  currentView = selectedView;
                  if (betweenSelected != -1) {
                    pagesSeller = List.from(pagesSeller)
                      ..[betweenSelected]['selected'] = false;
                  }

                  pagesSeller = List.from(pagesSeller)
                    ..[selectedIndex]['selected'] = true;
                  String cv = currentView['view'].toString();
                  // print(cv);

                  if (cv == "Catalog") {
                    // print("if");
                    isSidebarOpen = false;
                    sharedPrefs!.setBool("sidebarOpen", isSidebarOpen);
                  }
                });

                Provider.of<NavigationProviderSellers>(context, listen: false)
                    .changeIndex(selectedIndex, selectedView['page']);
              },
            ),
          )
        : Container();
  }

  Widget _buildMenuItemSimple(String title, String page, Icon icon) {
    final theme = Theme.of(context);

    var betweenSelected =
        pagesSeller.indexWhere((element) => element['selected'] == true);

    var selectedView =
        pagesSeller.firstWhere((element) => element['page'] == page);
    var selectedIndex =
        pagesSeller.indexWhere((element) => element['page'] == page);

    return Container(
      color: selectedView["selected"]
          ? Colors.blue.withOpacity(0.2)
          : Colors.white,
      padding: const EdgeInsets.only(left: 20),
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorlabels,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          sharedPrefs!.setString("index", selectedIndex.toString());

          setState(() {
            currentView = selectedView;
            if (betweenSelected != -1) {
              pagesSeller = List.from(pagesSeller)
                ..[betweenSelected]['selected'] = false;
            }

            pagesSeller = List.from(pagesSeller)
              ..[selectedIndex]['selected'] = true;
            isSidebarOpen = false;
            sharedPrefs!.setBool("sidebarOpen", isSidebarOpen);
          });
          Provider.of<NavigationProviderSellers>(context, listen: false)
              .changeIndex(selectedIndex, selectedView['page']);
        },
      ),
    );
  }
}
