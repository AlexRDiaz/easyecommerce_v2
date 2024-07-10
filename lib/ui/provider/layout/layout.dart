// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:flutter/material.dart';

// import 'package:frontend/config/exports.dart';
// import 'package:frontend/main.dart';
// import 'package:frontend/providers/provider/navigation_provider.dart';
// import 'package:frontend/providers/sellers/navigation_provider.dart';
// import 'package:frontend/ui/provider/add_provider/sub_providers_view.dart';
// import 'package:frontend/ui/provider/layout/welcome_provider_screen.dart';
// import 'package:frontend/ui/provider/guidesgroup/guides_sent/table_orders_guides_sent.dart';
// import 'package:frontend/ui/provider/guidesgroup/print_guides/print_guides.dart';
// import 'package:frontend/ui/provider/guidesgroup/printed_guides/printedguides.dart';
// import 'package:frontend/ui/provider/products/products_view.dart';
// import 'package:frontend/ui/provider/profile/profile_view.dart';
// import 'package:frontend/ui/provider/transactions/transactions_view.dart';
// import 'package:frontend/ui/provider/warehouses/warehouses.dart';
// import 'package:frontend/ui/sellers/add_seller_user/add_seller_user.dart';
// import 'package:frontend/ui/sellers/cash_withdrawals_sellers/cash_withdrawals_sellers.dart';
// import 'package:frontend/ui/sellers/dashboard/dashboard.dart';
// import 'package:frontend/ui/sellers/delivery_status/delivery_status.dart';
// import 'package:frontend/ui/sellers/guides_sent/table_orders_guides_sent.dart';
// import 'package:frontend/ui/sellers/my_cart_sellers/my_cart_sellers.dart';
// import 'package:frontend/ui/sellers/my_seller_account/my_seller_account.dart';
// import 'package:frontend/ui/sellers/my_stock/my_stock.dart';
// import 'package:frontend/ui/sellers/my_wallet/my_wallet.dart';
// import 'package:frontend/ui/sellers/order_entry/order_entry.dart';
// import 'package:frontend/ui/sellers/order_history_sellers/order_history_sellers.dart';
// import 'package:frontend/ui/sellers/print_guides/print_guides.dart';
// import 'package:frontend/ui/sellers/printed_guides/printedguides.dart';
// import 'package:frontend/ui/sellers/providers_sellers/providers_sellers.dart';
// import 'package:frontend/ui/sellers/returns_seller/returns_seller.dart';
// import 'package:frontend/ui/sellers/sales_report/sales_report.dart';
// import 'package:frontend/ui/sellers/unwanted_orders_sellers/unwanted_orders_sellers.dart';
// import 'package:frontend/ui/sellers/update_password/update_password.dart';
// import 'package:frontend/ui/sellers/wallet_sellers/wallet_sellers.dart';
// import 'package:frontend/ui/welcome/welcome.dart';

// import 'package:frontend/ui/widgets/logistic/layout/navbar_drawer.dart';
// import 'package:provider/provider.dart';

// import 'package:frontend/ui/sellers/transport_stats/transport_stats.dart';

// class LayoutProvidersPage extends StatefulWidget {
//   const LayoutProvidersPage({super.key});

//   @override
//   State<LayoutProvidersPage> createState() => _LayoutProvidersPageState();
// }

// class _LayoutProvidersPageState extends State<LayoutProvidersPage> {
//   final GlobalKey<ScaffoldState> _key = GlobalKey();
//   var email = sharedPrefs!.getString("email").toString();
//   var username = sharedPrefs!.getString("username").toString();

//   final GlobalKey _menuKey = GlobalKey();

//   late NavigationProviderProvider navigation;
//   @override
//   void didChangeDependencies() {
//     navigation = Provider.of<NavigationProviderProvider>(context);
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List pages = [
//       getOption(
//         "Home",
//         WelcomeProviderScreen(),
//       ),
//       getOption(
//         "Productos",
//         const ProductsView(),
//       ),
//       getOption(
//         "Bodegas",
//         const WarehousesView(),
//       ),
//       getOption(
//         "Sub Proveedores",
//         SubProviderView(),
//       ),
//       getOption(
//         "Mis Transacciones",
//         const TransactionsView(),
//       ),
//       getOption(
//         "Imprimir Guías",
//         const PrintGuidesProvider(),
//       ),
//       getOption(
//         "Guías Impresas",
//         const PrintedGuidesProvider(),
//       ),
//       getOption("Guías Enviadas", const TableOrdersGuidesSentProvider()),
//     ];
//     return Scaffold(
//       key: _key,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: true,
//         leading: GestureDetector(
//           onTap: () {
//             _key.currentState!.openDrawer();
//           },
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               ImageIcon(
//                 AssetImage(images.menuIcon),
//                 size: 35,
//               ),
//             ],
//           ),
//         ),
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               images.logoEasyEcommercce,
//               width: 30,
//             ),
//             SizedBox(width: 10),
//             Flexible(
//               child: Text(
//                 navigation.nameWindow,
//                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           Container(
//             padding: EdgeInsets.all(10),
//             child: const Icon(
//               size: 40,
//               Icons.account_circle,
//               color: const Color.fromARGB(255, 255, 255, 255),
//             ),
//           ),
//           PopupMenuButton<String>(
//             padding: EdgeInsets.zero, // Elimina el relleno alrededor del botón
//             child: Row(
//               children: [
//                 Text(
//                   "${email}",
//                   style: TextStyle(
//                     color: const Color.fromARGB(255, 255, 255, 255),
//                   ),
//                 ),
//                 const Icon(
//                   Icons
//                       .arrow_drop_down, // Icono de flecha hacia abajo para indicar que es un menú
//                   color: const Color.fromARGB(255, 255, 255, 255),
//                 ),
//               ],
//             ),
//             itemBuilder: (BuildContext context) {
//               return [
//                 PopupMenuItem<String>(
//                   child: Text(
//                     "Hola, ${username}",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   enabled: false,
//                 ),
//                 PopupMenuItem<String>(
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.account_circle,
//                         color: Colors.black,
//                       ),
//                       SizedBox(width: 5),
//                       Text("Mi Cuenta Vendedor"),
//                     ],
//                   ),
//                   value: "my_account",
//                 ),
//                 PopupMenuItem<String>(
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.security,
//                         color: Colors.black,
//                       ),
//                       SizedBox(width: 5),
//                       Text("Cambiar Contraseña"),
//                     ],
//                   ),
//                   value: "password",
//                 ),
//                 PopupMenuItem<String>(
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.logout_sharp,
//                         color: Colors.black,
//                       ),
//                       SizedBox(width: 5),
//                       Text("Cerrar Sesión"),
//                     ],
//                   ),
//                   value: "log_out",
//                 ),
//               ];
//             },
//             onSelected: (value) {
//               if (value == "my_account") {
//                 profileViewModal(context);
//               } else if (value == "password") {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => UpdatePasswordSellers()));
//               } else if (value == "log_out") {
//                 // Navigator.pushNamedAndRemoveUntil(
//                 //     context, '/login', (Route<dynamic> route) => false);
//                 showLogoutConfirmationDialog2(context);
//               }
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         backgroundColor: Colors.white,
//         child: getNavbarDrawerProviders(context),
//       ),
//       body: SafeArea(child: pages[navigation.index]),
//     );
//   }

//   Future<void> showLogoutConfirmationDialog2(BuildContext context) async {
//     return AwesomeDialog(
//       width: 500,
//       context: context,
//       dialogType: DialogType.WARNING,
//       animType: AnimType.rightSlide,
//       title: 'Confirmar Cierre de Sesión',
//       desc: '¿Está seguro de que desea cerrar sesión?',
//       btnCancelText: 'Cancelar',
//       btnCancelOnPress: () {},
//       btnOkText: 'Aceptar',
//       btnOkColor: colors.colorGreen,
//       btnOkOnPress: () {
//         // Navigator.of(context).pop();
//         Navigator.pushNamedAndRemoveUntil(
//             context, '/login', (Route<dynamic> route) => false);
//       },
//     ).show();
//   }

//   Future<dynamic> profileViewModal(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius:
//                 BorderRadius.circular(0.0), // Establece el radio del borde a 0
//           ),
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.7,
//             height: MediaQuery.of(context).size.height * 0.9,
//             child: ProfileView(),
//           ),
//         );
//       },
//     ).then((value) {
//       // Aquí puedes realizar cualquier acción que necesites después de cerrar el diálogo
//       // Por ejemplo, actualizar algún estado
//       // setState(() {
//       //   //_futureProviderData = _loadProviders(); // Actualiza el Future
//       // });
//     });
//   }

//   getOption(name, data) {
//     switch (name) {
//       case "Mi Cuenta Vendedor":
//         return data;
//       case "Cambiar Contraseña":
//         return data;
//       case "Cerrar Sesión":
//         return data;
//       default:
//         if (sharedPrefs!.getStringList("PERMISOS")!.isNotEmpty) {
//           if (sharedPrefs!.getStringList("PERMISOS")![0].contains(name)) {
//             return data;
//           } else {
//             return Container();
//           }
//         } else {
//           return Container();
//         }
//     }
//   }
// }

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/provider/navigation_provider.dart';
import 'package:frontend/ui/provider/add_provider/sub_providers_view.dart';
import 'package:frontend/ui/provider/delivery_status_provider/delivery_status.dart';
import 'package:frontend/ui/provider/guidesgroup/guides_sent/table_orders_guides_sent.dart';
import 'package:frontend/ui/provider/guidesgroup/print_guides/print_guides.dart';
import 'package:frontend/ui/provider/guidesgroup/printed_guides/printedguides.dart';
import 'package:frontend/ui/provider/layout/welcome_provider_screen.dart';
import 'package:frontend/ui/provider/products/products_view.dart';
import 'package:frontend/ui/provider/profile/profile_view.dart';
import 'package:frontend/ui/provider/transactions/transactions_view.dart';
import 'package:frontend/ui/provider/update_password/update_password.dart';
import 'package:frontend/ui/provider/warehouses/warehouses.dart';
import 'package:frontend/ui/sellers/update_password/update_password.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LayoutProvidersPage extends StatefulWidget {
  const LayoutProvidersPage({Key? key}) : super(key: key);

  @override
  State<LayoutProvidersPage> createState() => _LayoutProvidersPageState();
}

class _LayoutProvidersPageState extends State<LayoutProvidersPage> {
  bool isSidebarOpen = true;
  List<String> permissions = sharedPrefs!.getStringList("PERMISOS")!;

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  var email = sharedPrefs!.getString("email").toString();
  var username = sharedPrefs!.getString("username").toString();
  Map currentView = Map();
  bool isSelected =
      false; // Variable para controlar si el elemento está seleccionado

  final GlobalKey _menuKey = GlobalKey();
  late NavigationProviderProvider navigation;
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
      print(".");

      var currentIndex = sharedPrefs!.getString("index");
      print("currentIndex: $currentIndex");
      // print("${pages.length}");
      // currentView = {
      //   "page": sharedPrefs!.getString("index") != null
      //       ? pagesProvider[int.parse(sharedPrefs!.getString("index").toString())]
      //           ["page"]
      //       : "Dashboard",
      //   "view": sharedPrefs!.getString("index") != null
      //       ? pagesProvider[int.parse(sharedPrefs!.getString("index").toString())]
      //           ["view"]
      //       : WelcomeProviderScreen()
      // };
      print("..");
      if (currentIndex != null) {
        if ((int.parse(currentIndex) > pages.length)) {
          print("...");
          currentView = {"page": "Dashboard", "view": WelcomeProviderScreen()};
        } else {
          print("!...");
          // currentView = {"page": "Dashboard", "view": WelcomeProviderScreen()};
          // if (sharedPrefs!.getString("index") != null) {
          //   pages = List.from(pages)
          //     ..[int.parse(sharedPrefs!.getString("index").toString())]
          //         ['selected'] = true;
          // }
          currentView = {
            "page": sharedPrefs!.getString("index") != null
                ? pagesProvider[
                        int.parse(sharedPrefs!.getString("index").toString())]
                    ["page"]
                : "Dashboard",
            "view": sharedPrefs!.getString("index") != null
                ? pagesProvider[
                        int.parse(sharedPrefs!.getString("index").toString())]
                    ["view"]
                : WelcomeProviderScreen()
          };
        }
      } else {
        print(".---- ...--");
        currentView = {"page": "Dashboard", "view": WelcomeProviderScreen()};
      }
    } catch (e) {
      print(">Error: $e");
      currentView = {"page": "Dashboard", "view": WelcomeProviderScreen()};
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

  List<Map<String, dynamic>> pages = [
    {"page": "Home", "view": WelcomeProviderScreen(), "selected": false},
    {"page": "Productos", "view": ProductsView(), "selected": false},
    {"page": "Bodegas", "view": WarehousesView(), "selected": false},
    {"page": "Sub Proveedores", "view": SubProviderView(), "selected": false},
    {
      "page": "Mis Transacciones",
      "view": const TransactionsView(),
      "selected": false
    },
    {
      "page": "Estado de Entregas",
      "view": const DeliveryStatus(),
      "selected": false
    },
    {
      "page": "Imprimir Guías",
      "view": const PrintGuidesProvider(),
      "selected": false
    },
    {
      "page": "Guías Impresas",
      "view": const PrintedGuidesProvider(),
      "selected": false
    },
    {
      "page": "Guías Enviadas",
      "view": const TableOrdersGuidesSentProvider(),
      "selected": false
    },
  ];

  Widget _buildPhoneLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Layout'),
        actions: getActions,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: Text('Change Password'),
              onTap: () {
                // Manejar la selección del cambio de contraseña
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Security Questions'),
              onTap: () {
                // Manejar la selección de las preguntas de seguridad
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Phone Layout',
          style: TextStyle(fontSize: 24),
        ),
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
                style: TextStyle(color: Colors.grey[600]),
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
                  Text("Mi Cuenta Proveedor"),
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
                    builder: (context) => UpdatePasswordProviders()));
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
              sharedPrefs!.getString("NameProvider").toString(),
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
            duration: Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -260,
            child: Container(
              color: colorDrawer,
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    //  width: width * 0.11,

                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.asset(images.logoEasyEcommercce,
                          fit: BoxFit.fill),
                    ),
                  ),
                  SizedBox(
                      height: 20), // Separación entre el encabezado y el menú

                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenu(
                            'Crear', Icon(Icons.person, color: colorlabels), [
                          _buildMenuItem(
                              'Agregar proveedor',
                              'Sub Proveedores',
                              Icon(Icons.supervisor_account,
                                  color: colorlabels)),
                          _buildMenuItem('Agregar bodegas', 'Bodegas',
                              Icon(Icons.warehouse, color: colorlabels)),
                          _buildMenuItem(
                              'Agregar productos',
                              'Productos',
                              Icon(Icons.shopping_bag_rounded,
                                  color: colorlabels)),
                        ]),
                        _buildMenu('Reportes',
                            Icon(Icons.report, color: colorlabels), [
                          _buildMenuItem(
                              'Mis Transacciones',
                              'Mis Transacciones',
                              Icon(Icons.wallet, color: colorlabels)),
                          _buildMenuItem(
                              'Estado de Entregas',
                              'Estado de Entregas',
                              Icon(Icons.emoji_transportation,
                                  color: colorlabels)),
                        ]),
                        _buildMenu(
                            'Imprimir', Icon(Icons.print, color: colorlabels), [
                          _buildMenuItem('Imprimir Guías', 'Imprimir Guías',
                              Icon(Icons.print_outlined, color: colorlabels)),
                          _buildMenuItem('Guías Impresas', 'Guías Impresas',
                              Icon(Icons.picture_as_pdf, color: colorlabels)),
                          _buildMenuItem('Guías Enviadas', 'Guías Enviadas',
                              Icon(Icons.send, color: colorlabels)),
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
      btnOkOnPress: () async {
        // Navigator.of(context).pop();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Borra todos los valores almacenados
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', (Route<dynamic> route) => false);
      },
    ).show();
  }

  getOption(name, data) {
    switch (name) {
      case "Mi Cuenta Proveedor":
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
    pages = pages;
    final theme = Theme.of(context);
    var betweenSelected =
        pages.indexWhere((element) => element['selected'] == true);

    var selectedView = pages.firstWhere((element) => element['page'] == title);
    var selectedIndex = pages.indexWhere((element) => element['page'] == title);
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
                    pages = List.from(pages)
                      ..[betweenSelected]['selected'] = false;
                  }

                  pages = List.from(pages)..[selectedIndex]['selected'] = true;
                });

                Provider.of<NavigationProviderProvider>(context, listen: false)
                    .changeIndex(selectedIndex, selectedView['page']);
              },
            ),
          )
        : Container();
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
    ).then((value) {});
  }
}