import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers/logistic/navigation_provider.dart';
import 'package:frontend/providers/sellers/navigation_provider.dart';
import 'package:frontend/ui/logistic/delivery_status/delivery_status.dart';
import 'package:frontend/ui/sellers/add_seller_user/add_seller_user.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/cash_withdrawals_sellers.dart';
import 'package:frontend/ui/sellers/catalog/catalog.dart';
import 'package:frontend/ui/sellers/dashboard/dashboard.dart';
import 'package:frontend/ui/sellers/guides_sent/table_orders_guides_sent.dart';
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
import 'package:provider/provider.dart';

class LayoutSellersPage extends StatefulWidget {
  const LayoutSellersPage({Key? key}) : super(key: key);

  @override
  State<LayoutSellersPage> createState() => _LayoutSellersPageState();
}

class _LayoutSellersPageState extends State<LayoutSellersPage> {
  bool isSidebarOpen = true;
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
      pages = List.from(pages)
        ..[int.parse(sharedPrefs!.getString("index").toString())]['selected'] =
            true;
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
    {"page": "DashBoard", "view": DashBoardSellers(), "selected": false},
    {"page": "Reporte de Ventas", "view": SalesReport(), "selected": false},
    {
      "page": "Agregar Usuarios Vendedores",
      "view": AddSellerUser(),
      "selected": false
    },
    {"page": "Ingreso de Pedidos", "view": OrderEntry(), "selected": false},
    {
      "page": "Estado Entregas Pedidos",
      "view": DeliveryStatus(),
      "selected": false
    },
    {
      "page": "Pedidos No Deseados",
      "view": UnwantedOrdersSellers(),
      "selected": false
    },
    {"page": "Billetera", "view": WalletSellers(), "selected": false},
    {"page": "Mi Billetera", "view": MyWallet(), "selected": false},
    {"page": "Devoluciones", "view": ReturnsSeller(), "selected": false},
    {
      "page": "Retiros en Efectivo",
      "view": CashWithdrawalsSellers(),
      "selected": false
    },
    {
      "page": "Conoce a tu Transporte",
      "view": tansportStats(),
      "selected": false
    },
    {"page": "Imprimir Guías", "view": PrintGuidesSeller(), "selected": false},
    {
      "page": "Guías Impresas",
      "view": PrintedGuidesSeller(),
      "selected": false
    },
    {
      "page": "Guías Enviadas",
      "view": TableOrdersGuidesSentSeller(),
      "selected": false
    },
    {"page": "Mis integraciones", "view": MyIntegrations(), "selected": false},
    {"page": "Catálogo de Productos", "view": Catalog(), "selected": false},
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
                color: Colors.black,
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
                              'Agregar vendedor',
                              'Agregar Usuarios Vendedores',
                              Icon(Icons.person_add, color: colorlabels)),
                        ]),
                        _buildMenu('Reportes',
                            Icon(Icons.report, color: colorlabels), [
                          _buildMenuItem(
                              'Ingreso de pedidos',
                              'Ingreso de Pedidos',
                              Icon(Icons.shopping_cart, color: colorlabels)),
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
                          _buildMenuItem(
                              'Catálogo de Productos',
                              'Catálogo de Productos',
                              Icon(Icons.send, color: colorlabels)),
                        ]),
                        _buildMenu('Movimientos',
                            Icon(Icons.paid, color: colorlabels), [
                          _buildMenuItem('Billetera', 'Billetera',
                              Icon(Icons.wallet, color: colorlabels)),
                          _buildMenuItem('Mi bileltera', 'Mi Billetera',
                              Icon(Icons.wallet, color: colorlabels)),
                          _buildMenuItem(
                              "Retiros en efectivo",
                              'Retiros en Efectivo',
                              Icon(Icons.account_balance, color: colorlabels)),
                        ]),
                        _buildMenu(
                            'Imprimir', Icon(Icons.print, color: colorlabels), [
                          _buildMenuItem('Imprimir guías', 'Imprimir Guías',
                              Icon(Icons.print_outlined, color: colorlabels)),
                          _buildMenuItem('Guías impresas', 'Guías Impresas',
                              Icon(Icons.print_disabled, color: colorlabels)),
                          _buildMenuItem('Guías enviadas', 'Guías Enviadas',
                              Icon(Icons.send, color: colorlabels)),
                          _buildMenuItem(
                              'Mis integraciones',
                              'Mis integraciones',
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
      btnOkOnPress: () {
        // Navigator.of(context).pop();
        Navigator.pushNamedAndRemoveUntil(
            context, '/login', (Route<dynamic> route) => false);
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
                Provider.of<NavigationProviderLogistic>(context, listen: false)
                    .changeIndex(selectedIndex, selectedView['page']);
              },
            ),
          )
        : Container();
  }
}
