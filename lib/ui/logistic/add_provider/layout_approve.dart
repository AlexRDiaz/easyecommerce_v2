import 'package:flutter/material.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/providers/sellers/navigation_provider.dart';
import 'package:frontend/ui/logistic/add_provider/approve_products.dart';
import 'package:frontend/ui/logistic/add_provider/approve_warehouses.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:badges/badges.dart' as badges;
import 'package:google_fonts/google_fonts.dart';

class LayoutApprovePage extends StatefulWidget {
  final ProviderModel provider;
  final String currentV;

  const LayoutApprovePage(
      {Key? key, required this.provider, required this.currentV})
      : super(key: key);

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

  late NavigationProviderSellers navigation;
  Color colorlabels = Colors.black;
  Color colorDrawer = Colors.white;

  List<Map<String, dynamic>> pages = [];
  late WrehouseController _warehouseController;
  List<WarehouseModel> warehousesList = [];

  late ProductController _productController;
  List<ProductModel> productsList = [];

  int numApprovWarehouse = 0;
  int numApprovProduct = 0;

  @override
  void initState() {
    super.initState();
    _providerController = ProviderController();
    getPages();

    _warehouseController = WrehouseController();
    _productController = ProductController();

    getNumApprove();
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

  Future<List<WarehouseModel>> _getWarehouseModelData() async {
    await _warehouseController.loadWarehouses(widget.provider.id.toString());
    List<WarehouseModel> filteredWarehouses = _warehouseController.warehouses
        .where((warehouse) => warehouse.active == 1 && warehouse.approved == 2)
        .toList();
    return filteredWarehouses;
  }

  Future<List<ProductModel>> _getProductModelData() async {
    await _productController.loadProductsByProvider(
        widget.provider.id.toString(),
        [],
        1000,
        1,
        [],
        [],
        "product_id:DESC",
        "",
        "approve");
    List<ProductModel> filteredProducts = _productController.products
        .where((warehouse) => warehouse.approved == 2)
        .toList();
    return filteredProducts;
  }

  getNumApprove() async {
    var responseWarehouses = await _getWarehouseModelData();
    warehousesList = responseWarehouses;
    var responseProducts = await _getProductModelData();
    productsList = responseProducts;
    setState(() {
      numApprovWarehouse = warehousesList.length;
      numApprovProduct = productsList.length;
    });
  }

  @override
  void didChangeDependencies() {
    // navigation = Provider.of<NavigationProviderSellers>(context);
    var currentIndex = sharedPrefs!.getString("index");
    var currentVi = widget.currentV;
    if (currentVi == "Bodegas") {
      currentView = {
        "page": "Bodegas",
        "view": ApproveWarehouse(provider: _selectedProvider),
      };
    } else if (currentVi == "Productos") {
      currentView = {
        "page": "Productos",
        "view": ApproveProducts(provider: _selectedProvider),
      };
    } else {
      currentView = {
        "page": "Bodegas",
        "view": ApproveWarehouse(provider: _selectedProvider),
      };
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Aprobaciones",
                          style: GoogleFonts.dmSerifDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        )),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildMenuItem(
                            'Bodegas',
                            Icon(Icons.store, color: colorlabels),
                            'Bodegas',
                            numApprovWarehouse),
                        _buildMenuItem(
                            'Productos',
                            Icon(Icons.shopping_bag_rounded,
                                color: colorlabels),
                            'Productos',
                            numApprovProduct),
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

  Widget _buildMenuItem(String title, Icon icon, String page, int numApprov) {
    final theme = Theme.of(context);

    var betweenSelected =
        pages.indexWhere((element) => element['selected'] == true);

    var selectedView = pages.firstWhere((element) => element['page'] == page);
    var selectedIndex = pages.indexWhere((element) => element['page'] == page);

    return Container(
      color: selectedView["selected"]
          ? Colors.blue.withOpacity(0.2)
          : Colors.white,
      padding: const EdgeInsets.only(left: 20),
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            badges.Badge(
              badgeContent: Text(
                numApprov == 0 ? '' : numApprov.toString(),
                style: TextStyle(color: Colors.white), // Color del texto
              ),
              position: badges.BadgePosition.topEnd(),
              showBadge: numApprov == 0 ? false : true,
              child: icon,
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.red,
                elevation: 0,
              ),
            ),
            const SizedBox(width: 10),
            // icon,
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
              pages = List.from(pages)..[betweenSelected]['selected'] = false;
            }

            pages = List.from(pages)..[selectedIndex]['selected'] = true;
          });
        },
      ),
    );
  }
}
