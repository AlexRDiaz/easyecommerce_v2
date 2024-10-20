import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
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

  // Color colorlabels = Colors.black;
  Color colorlabels = Color(0xFF2E2F39);
  Color colorsection = Color(0xFF96979B);
  Color colorsection2 = Color.fromARGB(255, 84, 85, 86);
  Color colorselected = Color(0xFF008BF1);
  Color colorstore = Color(0xFF002163);
  Color colorbackoption = Color(0xFFF2F4F8);

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

  List<Widget> get getActions {
    return [
      IconButton(
        icon: Icon(
          Icons.storefront,
          color: colorstore,
        ),
        onPressed: () {},
      ),
      Text(
        sharedPrefs!.getString("NameComercialSeller").toString(),
        style: TextStylesSystem()
            .ralewayStyle(16, FontWeight.w600, ColorsSystem().colorStore),
      ),
      SizedBox(
        width: 10,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
        child: VerticalDivider(),
      ),
      SizedBox(
        width: 10,
      ),
      IconButton(
        icon: Icon(
          Icons.notifications_active_outlined,
          color: colorlabels,
        ),
        onPressed: () {},
      ),
      SizedBox(
        width: 10,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
        child: VerticalDivider(),
      ),
      IconButton(
        icon: Icon(
          Icons.settings,
          color: colorlabels,
        ),
        onPressed: () {},
      ),
      SizedBox(
        width: 10,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
        child: VerticalDivider(),
      ),
      SizedBox(
        width: 10,
      ),
      Icon(
        Icons.account_circle_outlined,
        color: colorselected,
      ),
      SizedBox(
        width: 5,
      ),
      PopupMenuButton<String>(
        padding: EdgeInsets.zero, // Elimina el relleno alrededor del botón
        child: Row(
          children: [
            Text(
              username,
              style: TextStylesSystem().ralewayStyle(
                  16, FontWeight.w600, ColorsSystem().colorLabels),
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
      SizedBox(
        width: 10,
      ),
    ];
  }

  List<Widget> get getActionsPhone {
    return [
      PopupMenuButton<String>(
        padding: EdgeInsets.zero, // Elimina el relleno alrededor del botón
        child: Row(
          children: [
            Icon(
              Icons.account_circle_outlined,
              color: colorselected,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              username,
              style: TextStylesSystem().ralewayStyle(
                  16, FontWeight.w600, ColorsSystem().colorLabels),
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
      SizedBox(
        width: 10,
      ),
    ];
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
        actions: getActionsPhone,
        leading: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _key.currentState!.openDrawer();

                  isSidebarOpen = !isSidebarOpen;
                  sharedPrefs!.setBool("sidebarOpen", isSidebarOpen);
                });
              },
              child: Center(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 20, top: 10, bottom: 10),
                  child:
                      Image.asset(images.logoEasyEcommercce, fit: BoxFit.fill),
                ),
              ),
            ),
            // IconButton(
            //   icon: Icon(Icons.menu_rounded),
            //   onPressed: () {
            //     setState(() {
            //       _key.currentState!.openDrawer();

            //       isSidebarOpen = !isSidebarOpen;
            //       sharedPrefs!.setBool("sidebarOpen", isSidebarOpen);
            //     });
            //   },
            // ),

            // Text(
            //   sharedPrefs!.getString("NameComercialSeller").toString(),
            //   style: TextStyle(color: Colors.white),
            // )
          ],
        ),
      ),
      drawer: Container(
        width: screenWidth * 0.57,
        child: Drawer(
          backgroundColor: Colors.white,
          child: Material(
            elevation: 5,
            child: Container(
              color: Colors.white,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMenuPhone(
                        'CREAR', Icon(Icons.person, color: colorsection), [
                      _buildMenuItemPhone(
                          'Agregar vendedor',
                          'Agregar Usuarios Vendedores',
                          Icon(Icons.person_add_alt_1_outlined,
                              color: colorlabels)),
                    ]),
                    // Divider(
                    //   endIndent: 10,
                    //   indent: 10,
                    // ),
                    _buildMenuPhone(
                        'REPORTES', Icon(Icons.report, color: colorlabels), [
                      _buildMenuItemPhone(
                          'Ingreso de pedidos',
                          'Ingreso de Pedidos',
                          Icon(Icons.shopping_cart_outlined,
                              color: colorlabels)),
                      _buildMenuItemPhone(
                          'DashBoard',
                          'DashBoard',
                          Icon(Icons.dashboard_customize_outlined,
                              color: colorlabels)),
                      _buildMenuItemPhone(
                          'Estado de entregas',
                          'Estado Entregas Pedidos',
                          Icon(Icons.local_shipping_outlined,
                              color: colorlabels)),
                      _buildMenuItemPhone(
                          'Pedidos no deseados',
                          'Pedidos No Deseados',
                          Icon(Icons.delete_outlined, color: colorlabels)),
                      _buildMenuItemPhone(
                          'Devoluciones',
                          'Devoluciones',
                          Icon(Icons.assignment_return_outlined,
                              color: colorlabels)),
                      // _buildMenuItem(
                      //     'Catálogo de Productos',
                      //     'Catálogo de Productos',
                      //     Icon(Icons.shopping_bag_rounded, color: colorlabels)),
                    ]),
                    // Divider(
                    //   endIndent: 10,
                    //   indent: 10,
                    // ),
                    _buildMenuPhone(
                        'MOVIMIENTOS', Icon(Icons.paid, color: colorlabels), [
                      _buildMenuItemPhone(
                          'Transacciones Global',
                          'Transacciones Global',
                          Icon(Icons.monetization_on_outlined,
                              color: colorlabels)),
                      _buildMenuItemPhone('Billetera', 'Billetera',
                          Icon(Icons.wallet_outlined, color: colorlabels)),
                      _buildMenuItemPhone('Mi Billetera', 'Mi Billetera',
                          Icon(Icons.wallet_outlined, color: colorlabels)),
                      _buildMenuItemPhone(
                          "Retiros en efectivo",
                          'Retiros en Efectivo',
                          Icon(Icons.account_balance_outlined,
                              color: colorlabels)),
                    ]),
                    // Divider(
                    //   endIndent: 10,
                    //   indent: 10,
                    // ),
                    _buildMenuPhone(
                        'IMPRIMIR', Icon(Icons.print, color: colorlabels), [
                      _buildMenuItemPhone('Imprimir guías', 'Imprimir Guías',
                          Icon(Icons.print_outlined, color: colorlabels)),
                      _buildMenuItemPhone(
                          'Guías impresas',
                          'Guías Impresas',
                          Icon(Icons.picture_as_pdf_outlined,
                              color: colorlabels)),
                      _buildMenuItemPhone('Guías enviadas', 'Guías Enviadas',
                          Icon(Icons.send, color: colorlabels)),
                      // _buildMenuItem('Mis integraciones', 'Mis integraciones',
                      //     Icon(Icons.settings, color: colorlabels)),
                    ]),
                    // const Divider(
                    //   endIndent: 10,
                    //   indent: 10,
                    // ),
                    _buildMenuPhone('DROPSHIPPING',
                        Icon(Icons.shopping_bag_rounded, color: colorlabels), [
                      _buildMenuItemPhone(
                          'Catálogo de Productos',
                          'Catálogo de Productos',
                          Icon(Icons.shopping_bag_outlined,
                              color: colorlabels)),
                      _buildMenuItemPhone(
                          'Mis integraciones',
                          'Mis integraciones',
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
            GestureDetector(
              onTap: () {
                setState(() {
                  isSidebarOpen = !isSidebarOpen;
                  sharedPrefs!.setBool("sidebarOpen", isSidebarOpen);
                });
              },
              child: Center(
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                  child:
                      Image.asset(images.logoEasyEcommercce, fit: BoxFit.fill),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(
                milliseconds: 500), // Aumenta la duración para más suavidad
            curve: Curves.easeInOut, // Usa una curva más suave
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 260 : 0,
            right: 0,
            child: currentView["view"],
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 500), // Ajusta la duración
            curve: Curves.easeInOut, // Usa la misma curva suave
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -260,
            child: Container(
              padding: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorDrawer,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Cambia la posición de la sombra
                  ),
                ],
              ),
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(height: 20),
                        _buildMenu(
                            'Crear', Icon(Icons.person, color: colorlabels), [
                          _buildMenuItem(
                              'Agregar vendedor',
                              'Agregar Usuarios Vendedores',
                              Icon(Icons.person_add_alt_outlined,
                                  color: colorlabels)),
                        ]),
                        SizedBox(height: 20),
                        _buildMenu('Reportes',
                            Icon(Icons.report, color: colorlabels), [
                          _buildMenuItem(
                              'Ingreso de pedidos',
                              'Ingreso de Pedidos',
                              Icon(Icons.shopping_cart_outlined,
                                  color: colorlabels)),
                          _buildMenuItem(
                              'DashBoard',
                              'DashBoard',
                              Icon(Icons.dashboard_customize_outlined,
                                  color: colorlabels)),
                          _buildMenuItem(
                              'Estado de entregas',
                              'Estado Entregas Pedidos',
                              Icon(Icons.local_shipping_outlined,
                                  color: colorlabels)),
                          _buildMenuItem(
                              'Pedidos no deseados',
                              'Pedidos No Deseados',
                              Icon(Icons.delete_outline_rounded,
                                  color: colorlabels)),
                          _buildMenuItem(
                              'Devoluciones',
                              'Devoluciones',
                              Icon(Icons.assignment_return_outlined,
                                  color: colorlabels)),
                          // _buildMenuItem(
                          //     'Catálogo de Productos',
                          //     'Catálogo de Productos',
                          //     Icon(Icons.shopping_bag_rounded,
                          //         color: colorlabels)),
                        ]),
                        SizedBox(height: 20),
                        _buildMenu('Movimientos',
                            Icon(Icons.paid, color: colorlabels), [
                          _buildMenuItem(
                              'Transacciones Global',
                              'Transacciones Global',
                              Icon(Icons.monetization_on_outlined,
                                  color: colorlabels)),
                          _buildMenuItem('Billetera', 'Billetera',
                              Icon(Icons.wallet, color: colorlabels)),
                          _buildMenuItem('Mi Billetera', 'Mi Billetera',
                              Icon(Icons.wallet, color: colorlabels)),
                          _buildMenuItem(
                              "Retiros en efectivo",
                              'Retiros en Efectivo',
                              Icon(Icons.account_balance_outlined,
                                  color: colorlabels)),
                        ]),
                        // Divider(
                        //   endIndent: 10,
                        //   indent: 10,
                        // ),
                        SizedBox(height: 20),
                        _buildMenu(
                            'Imprimir', Icon(Icons.print, color: colorlabels), [
                          _buildMenuItem('Imprimir guías', 'Imprimir Guías',
                              Icon(Icons.print_outlined, color: colorlabels)),
                          _buildMenuItem(
                              'Guías impresas',
                              'Guías Impresas',
                              Icon(Icons.picture_as_pdf_outlined,
                                  color: colorlabels)),
                          _buildMenuItem('Guías enviadas', 'Guías Enviadas',
                              Icon(Icons.send, color: colorlabels)),
                          // _buildMenuItem(
                          //     'Mis integraciones',
                          //     'Mis integraciones',
                          //     Icon(Icons.settings, color: colorlabels)),
                        ]),
                        // Divider(
                        //   endIndent: 10,
                        //   indent: 10,
                        // ),
                        SizedBox(height: 20),
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
      iconColor: colorsection,
      initiallyExpanded: true,
      shape: const Border(),
      title: Row(
        children: [
          // icon,
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              title.toUpperCase(),
              style: TextStylesSystem().ralewayStyle(
                  14, FontWeight.w600, ColorsSystem().colorSection2),
            ),
          ),
        ],
      ),
      children: children,
    );
  }

  Widget _buildMenuPhone(String title, Icon icon, List<Widget> children) {
    final theme = Theme.of(context);

    return ExpansionTile(
      iconColor: colorsection,
      initiallyExpanded: true,
      shape: const Border(),
      title: Row(
        children: [
          // icon,
          Text(
            title.toUpperCase(),
            style: TextStylesSystem()
                .ralewayStyle(12, FontWeight.w600, ColorsSystem().colorSection2),
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
            color: selectedView["selected"] ? colorbackoption : Colors.white,
            padding: EdgeInsets.only(left: 20),
            child: ListTile(
              title: Row(
                children: [
                  Icon(
                    icon.icon,
                    color:
                        selectedView["selected"] ? colorselected : colorlabels,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      label,
                      style: TextStylesSystem().ralewayStyle(
                          14,
                          FontWeight.w700,
                          selectedView["selected"]
                              ? colorselected
                              : colorlabels),
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

  Widget _buildMenuItemPhone(String label, String title, Icon icon) {
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
            color: selectedView["selected"] ? colorbackoption : Colors.white,
            // padding: EdgeInsets.only(left: 10),
            child: ListTile(
              title: Row(
                children: [
                  Icon(
                    icon.icon,
                    size: 14,
                    color:
                        selectedView["selected"] ? colorselected : colorlabels,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      label,
                      style: TextStylesSystem().ralewayStyle(
                          12,
                          FontWeight.w700,
                          selectedView["selected"]
                              ? colorselected
                              : colorlabels),
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
