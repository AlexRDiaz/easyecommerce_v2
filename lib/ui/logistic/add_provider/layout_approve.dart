import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/providers/logistic/navigation_provider.dart';
import 'package:frontend/providers/sellers/navigation_provider.dart';
import 'package:frontend/ui/logistic/add_provider/approve_products.dart';
import 'package:frontend/ui/logistic/add_provider/approve_warehouses.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/sellers/add_seller_user/add_seller_user.dart';
import 'package:frontend/ui/sellers/cash_withdrawals_sellers/cash_withdrawals_sellers.dart';
import 'package:frontend/ui/sellers/catalog/catalog.dart';
import 'package:frontend/ui/sellers/dashboard/dashboard.dart';
import 'package:frontend/ui/sellers/delivery_status/delivery_status.dart';
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

class LayoutApprovePage extends StatefulWidget {
  final ProviderModel provider;

  const LayoutApprovePage({Key? key, required this.provider}) : super(key: key);

  @override
  State<LayoutApprovePage> createState() => _LayoutApprovePageState();
}

class _LayoutApprovePageState extends State<LayoutApprovePage> {
  late ProviderController _providerController;
  ProviderModel _selectedProvider = ProviderModel();

  bool isSidebarOpen = true;
  List<String> permissions = sharedPrefs!.getStringList("PERMISOS")!;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  Map currentView = Map();
  bool isSelected =
      false; // Variable para controlar si el elemento está seleccionado

  final GlobalKey _menuKey = GlobalKey();
  late NavigationProviderSellers navigation;
  Color colorlabels = Colors.black;
  Color colorDrawer = Colors.white;

  List<Map<String, dynamic>> pages = [];

  @override
  void initState() {
    super.initState();
    _providerController = ProviderController();
    getPages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getPages() {
    _selectedProvider = widget.provider;
    pages = [
      {
        "page": "Bodegas",
        "view": ApproveWarehouse(
          provider: _selectedProvider,
        ),
        "selected": false
      },
      {
        "page": "Productos",
        "view": ApproveProducts(
          provider: widget.provider,
        ),
        "selected": false
      },
    ];
  }

  @override
  void didChangeDependencies() {
    // navigation = Provider.of<NavigationProviderSellers>(context);
    var currentIndex = sharedPrefs!.getString("index");
    currentView = {
      "page": "Bodegas",
      "view": ApproveWarehouse(provider: _selectedProvider),
    };

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Layout'),
        // actions: getActions,
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

  Widget _buildWebLayout() {
    double width = MediaQuery.of(context).size.width;
    double heigth = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: heigth * 0.060,
      //   leadingWidth: width * 0.6,
      //   leading: Row(
      //     children: [
      //       IconButton(
      //         icon: Icon(Icons.menu),
      //         onPressed: () {
      //           setState(() {
      //             isSidebarOpen = !isSidebarOpen;
      //           });
      //         },
      //       ),
      //     ],
      //   ),
      // ),
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
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.asset(images.logoEasyEcommercce,
                          fit: BoxFit.fill),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenuItem('Bodegas',
                            Icon(Icons.store, color: colorlabels), 'Bodegas'),
                        _buildMenuItem(
                            'Productos',
                            Icon(Icons.shopping_bag_rounded,
                                color: colorlabels),
                            'Productos'),
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

  Widget _buildMenuItem(String title, Icon icon, String page) {
    final theme = Theme.of(context);

    var betweenSelected =
        pages.indexWhere((element) => element['selected'] == true);

    var selectedView = pages.firstWhere((element) => element['page'] == page);
    var selectedIndex = pages.indexWhere((element) => element['page'] == page);

    return Container(
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
                title,
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
              pages = List.from(pages)..[betweenSelected]['selected'] = false;
            }

            pages = List.from(pages)..[selectedIndex]['selected'] = true;
          });
          Provider.of<NavigationProviderLogistic>(context, listen: false)
              .changeIndex(selectedIndex, selectedView['page']);
        },
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:frontend/config/exports.dart';
// import 'package:frontend/models/provider_model.dart';
// import 'package:frontend/providers/logistic/navigation_provider.dart';
// import 'package:frontend/providers/operator/navigation_provider.dart';
// import 'package:frontend/ui/logistic/add_provider/approve_products.dart';
// import 'package:frontend/ui/logistic/add_provider/approve_warehouses.dart';
// import 'package:frontend/ui/widgets/logistic/layout/navbar_drawer.dart';
// import 'package:provider/provider.dart';

// class LayoutApprove extends StatefulWidget {
//   final ProviderModel provider;

//   const LayoutApprove({super.key, required this.provider});

//   @override
//   State<LayoutApprove> createState() => _LayoutApproveState();
// }

// class _LayoutApproveState extends State<LayoutApprove> {
//   final GlobalKey<ScaffoldState> _key = GlobalKey();

//   late NavigationProviderOperator navigation;
//   @override
//   void didChangeDependencies() {
//     navigation = Provider.of<NavigationProviderOperator>(context);
//     super.didChangeDependencies();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List pages = [
//       ApproveWarehouse(provider: widget.provider),
//       ApproveProducts(provider: widget.provider),
//       Container(),
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
//         title: Container(
//           width: double.infinity,
//           height: 80,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Image.asset(
//                 images.logoEasyEcommercce,
//                 width: 30,
//               ),
//               SizedBox(
//                 width: 10,
//               ),
//               Flexible(
//                 child: Text(
//                   navigation.nameWindow,
//                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       drawer: Drawer(
//         backgroundColor: Colors.white,
//         child: getNavbarDrawerOperator(context),
//       ),
//       body: SafeArea(child: pages[navigation.index]),
//     );
//   }

// }
