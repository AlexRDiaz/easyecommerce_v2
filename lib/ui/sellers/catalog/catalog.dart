import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/product_seller.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/reserve_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/sellers/catalog/product_report.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/product/product_add_order.dart';
import 'package:frontend/ui/widgets/product/product_card.dart';
import 'package:frontend/ui/widgets/product/product_carousel.dart';
import 'package:frontend/ui/widgets/product/show_img.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:url_launcher/url_launcher.dart';

class Catalog extends StatefulWidget {
  const Catalog({super.key});

  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  late ProductController _productController;
  List<ProductModel> products = [];
  late WrehouseController _warehouseController;
  List<WarehouseModel> warehousesList = [];
  late ProviderController _providerController;
  List<ProviderModel> providersList = [];
  //
  NumberPaginatorController paginatorController = NumberPaginatorController();
  int currentPage = 1;
  // int pageSize = 1500;
  int pageSize = 100;
  int pageCount = 100;

  bool isLoading = false;
  bool isFirst = false;
  // List populate = ["warehouse", "productseller", "reserve.seller"];
  List populate = ["warehouses.provider", "productseller", "reserve.seller"];

  List arrayFiltersOr = ["product_id", "product_name", "stock", "price"];
  List arrayFiltersAnd = [
    {"equals/seller_owned": null}
  ];
  List outFilter = [];
  List filterps = [];
  // var sortFieldDefaultValue = "product_id:asc";
  var sortFieldDefaultValue = "";
  TextEditingController _search = TextEditingController(text: "");

  double screenWidth = 0.0;
  double screenHeight = 0.0;
  double textSize = 0.0;
  double iconSize = 0.0;
  String selectedOption = "Todo";
  //
  List<String> warehousesToSelect = [];
  List<String> providersToSelect = [];
  String? selectedProvider;

  String? selectedWarehouse;
  // List<String> categoriesToSelect = UIUtils.categories();
  List<String> categoriesToSelect = [];

  List<String> selectedCategoriesList = [];
  String? selectedCategory;
  RangeValues _currentRangeValues = const RangeValues(1, 100);
  RangeValues _defautRangeValues = const RangeValues(1, 100);
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  bool isSelectedFavorites = false;
  bool isSelectedOnSale = false;
  List<String> selectedKeyList = [];

  // int total = 0;
  String total = "";
  String from = "";
  String to = "";

  var getReport = ProductReport();

  bool isSelectedOwn = false;
  int idUser = int.parse(sharedPrefs!.getString("id").toString());

  List<String> typeToSelect = ["TODO", "SIMPLE", "VARIABLE"];
  String? selectedType;

  // ! checkobox
  bool _isCheckedFavorites = false;
  bool _isCheckedAll = true;
  bool _isCheckedinSell = false;
  bool _isCheckedMiProducts = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController warehouseController =
      TextEditingController(text: "TODO");
  TextEditingController typeController = TextEditingController(text: "TODO");
  TextEditingController categoryController =
      TextEditingController(text: "TODO");

  @override
  void initState() {
    super.initState();
    _productController = ProductController();
    // _providerController = ProviderController();
    _warehouseController = WrehouseController();
    // getProviders();
    getWarehouses();
    getCategories();
    _getProductModelCatalog();
  }

  _getProductModelCatalog() async {
    setState(() {
      isLoading = true;
    });

    await _productController.loadProductsCatalog(
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        outFilter,
        filterps,
        sortFieldDefaultValue,
        _search.text);

    setState(() {
      products = _productController.products;
      total = _productController.total;
      from = _productController.from;
      to = _productController.to;
      pageCount = int.parse(_productController.lastPage);

      isLoading = false;
    });
    // return _productController.products;
  }

  _paginateProductModelCatalog() async {
    setState(() {
      isLoading = true;
    });

    await _productController.loadProductsCatalog(
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        outFilter,
        filterps,
        sortFieldDefaultValue,
        _search.text);

    setState(() {
      products = _productController.products;
      total = _productController.total;
      from = _productController.from;
      to = _productController.to;
      pageCount = int.parse(_productController.lastPage);

      isLoading = false;
    });
  }

  Future<List<WarehouseModel>> _getWarehousesData() async {
    await _warehouseController.loadWarehousesAll();
    return _warehouseController.warehouses;
  }

  Future<List<ProviderModel>> _getProviderData() async {
    await _providerController.loadProvidersAll();
    return _providerController.providers;
  }

  getProviders() async {
    var responseProviders = await _getProviderData();
    providersList = responseProviders;
    providersToSelect.insert(0, 'TODO');
    for (var provider in providersList) {
      if (provider.special != 1) {
        providersToSelect.add('${provider.id}-${provider.name}');
      }
    }
    setState(() {});
  }

  getCategories() async {
    List<dynamic> data = [];
    String jsonData = await rootBundle.loadString('assets/taxonomy3.json');
    data = json.decode(jsonData);
    categoriesToSelect.insert(0, 'TODO');

    for (var item in data) {
      var lastKey = item.keys.last;
      String menuItemLabel = "${item[lastKey]}-${item['id']}";
      categoriesToSelect.add(menuItemLabel);
    }
  }

  getWarehouses() async {
    var responseBodegas = await _getWarehousesData();
    warehousesList = responseBodegas;
    warehousesToSelect.insert(0, 'TODO');
    for (var warehouse in warehousesList) {
      if (warehouse.approved == 1 && warehouse.active == 1) {
        setState(() {
          warehousesToSelect.add(
              '${warehouse.id}|${warehouse.provider?.name}/${warehouse.branchName}');
        });
      }
    }
  }

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        arrayFiltersAnd = [
          {"equals/seller_owned": null}
        ];
      });
    }
  }

  DropdownButton<int> dropdownPagination() {
    return DropdownButton<int>(
      value:
          pageSize, // Valor actual seleccionado (cantidad de registros por página)
      items: [
        DropdownMenuItem<int>(
            value: 100,
            child: Text('100',
                style: TextStyle(
                    color: ColorsSystem().colorLabels, fontSize: 12))),
        DropdownMenuItem<int>(
            value: 200,
            child: Text('200',
                style: TextStyle(
                    color: ColorsSystem().colorLabels, fontSize: 12))),
        DropdownMenuItem<int>(
            value: 1000,
            child: Text('1000',
                style: TextStyle(
                    color: ColorsSystem().colorLabels, fontSize: 12))),
      ],
      onChanged: (newValue) {
        setState(() {
          pageSize = newValue!;
          _paginateProductModelCatalog(); // Llama a la función de paginación con la nueva cantidad
        });
      },
      style: TextStyle(fontSize: 12, color: ColorsSystem().colorLabels),
      dropdownColor: Colors.white,
      underline: SizedBox(), // Eliminar la línea subyacente
      // isExpanded: true, // Asegura que el dropdown ocupe el ancho completo
      icon: Padding(
        padding: const EdgeInsets.only(left: 8.0), // Espaciado del icono
        child: Icon(Icons.arrow_drop_down),
      ),
      // Cambia el método de cómo se despliega
      selectedItemBuilder: (BuildContext context) {
        return [
          DropdownMenuItem<int>(value: 100, child: Text('100')),
          DropdownMenuItem<int>(value: 200, child: Text('200')),
          DropdownMenuItem<int>(value: 1000, child: Text('1000')),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    textSize = screenWidth > 600 ? 16 : 12;
    iconSize = screenWidth > 600 ? 70 : 25;

    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        key: _scaffoldKey,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: responsive(
              webMainContainer(context), mobileMainContainer(context), context),
        ),
      ),
    );
  }

  // ! nuevo
  Stack mobileMainContainer(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 120,
              color: ColorsSystem()
                  .colorInitialContainer, // Cambia a tu color deseado
            ),
          ],
        ),
        Positioned(
          top: 8,
          left: 20,
          right: 20,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Row(
                children: [
                  searchBarOnlyMobile(context, 40),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: ColorsSystem()
                            .colorInitialContainer, // Color de fondo del Container
                        borderRadius:
                            BorderRadius.circular(5), // Bordes redondeados
                        boxShadow: [
                          BoxShadow(
                            color: ColorsSystem()
                                .colorInitialContainer
                                .withOpacity(0.1), // Color de la sombra
                            spreadRadius:
                                5, // Qué tan lejos se extiende la sombra
                            blurRadius: 10, // Suavidad de la sombra
                            offset: Offset(
                                5, 0), // Desplazamiento de la sombr (x, y)
                          ),
                        ],
                      ),
                      child: Tooltip(
                        message: "Filtros",
                        child: ElevatedButton(
                          onPressed: () async {
                            filtersDialog(context);
                          }, // Ícono de filtro
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsSystem()
                                .colorInitialContainer, // Color del botón
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  5), // Bordes redondeados
                            ),
                          ),
                          child: Icon(Icons.filter_alt_outlined,
                              color: ColorsSystem().colorStore, size: 14),
                        ),
                      )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  GestureDetector(
                    child: Column(
                      children: [
                        Center(
                          child: Text("Todo",
                              style: TextStylesSystem().ralewayStyle(10,
                                  FontWeight.w400, ColorsSystem().colorLabels)),
                        ),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width * 0.22,
                          decoration: BoxDecoration(
                              color: selectedOption == "Todo"
                                  ? ColorsSystem().colorSelected
                                  : ColorsSystem().colorSection,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomLeft: Radius.circular(5))),
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedOption = "Todo";
                        selectFilter('all');
                      });
                    },
                  ),
                  GestureDetector(
                    child: Column(
                      children: [
                        Center(
                          child: Text("Favoritos",
                              style: TextStylesSystem().ralewayStyle(10,
                                  FontWeight.w400, ColorsSystem().colorLabels)),
                        ),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width * 0.22,
                          decoration: BoxDecoration(
                            color: selectedOption == "Favoritos"
                                ? ColorsSystem().colorSelected
                                : ColorsSystem().colorSection,
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedOption = "Favoritos";
                        selectFilter('favorites');
                      });
                    },
                  ),
                  GestureDetector(
                    child: Column(
                      children: [
                        Center(
                          child: Text("En venta",
                              style: TextStylesSystem().ralewayStyle(10,
                                  FontWeight.w400, ColorsSystem().colorLabels)),
                        ),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width * 0.22,
                          decoration: BoxDecoration(
                            color: selectedOption == "En venta"
                                ? ColorsSystem().colorSelected
                                : ColorsSystem().colorSection,
                          ),
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedOption = "En venta";
                        selectFilter('onsale');
                      });
                    },
                  ),
                  GestureDetector(
                    child: Column(
                      children: [
                        Center(
                          child: Text("Mis Productos",
                              style: TextStylesSystem().ralewayStyle(10,
                                  FontWeight.w400, ColorsSystem().colorLabels)),
                        ),
                        Container(
                          height: 10,
                          width: MediaQuery.of(context).size.width * 0.22,
                          decoration: BoxDecoration(
                              color: selectedOption == "Mis Productos"
                                  ? ColorsSystem().colorSelected
                                  : ColorsSystem().colorSection,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5))),
                        )
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        selectedOption = "Mis Productos";
                        selectFilter('myProducts');
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  dropdownPagination(),
                ],
              ),
              Expanded(
                flex: 4,
                child: products.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: GridView.builder(
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Número de columnas
                            crossAxisSpacing: 10, // Espaciado entre columnas
                            mainAxisSpacing: 10, // Espaciado entre filas
                            childAspectRatio:
                                calculateMobileAspectRatio(context),
                          ),
                          itemBuilder: (context, index) {
                            var item = products[index];
                            return ProductCard(
                              product: item,
                              onTapCallback: (context) => _showProductInfo(
                                context,
                                item,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(child: Text("Sin datos")),
              ),
              SizedBox(
                  height: MediaQuery.of(context).size.height <= 640
                      ? MediaQuery.of(context).size.height * 0.01
                      : MediaQuery.of(context).size.height * 0.03),
              Flexible(
                  child: products.isNotEmpty
                      ? Container(
                          height: 30,
                          child: paginationPhoneComplete(),
                        )
                      : Container()),
            ],
          ),
        )
      ],
    );
  }

  Row paginationPhoneComplete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Distribuir los elementos
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: numberPaginator()),
      ],
    );
  }

  Stack webMainContainer(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Container(
            height: 230,
            color: ColorsSystem()
                .colorInitialContainer, // Cambia a tu color deseado
          ),
        ],
      ),
      Positioned(
        top: 20,
        left: 20,
        right: 20,
        height: MediaQuery.of(context).size.height * 0.95,
        child: LayoutBuilder(builder: ((context, constraints) {
          return Container(
            height: 100,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                // color: Colors.orange,
                height: 200,
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catálogo de Productos',
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: ColorsSystem().colorStore,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Para separar el último item
                      children: [
                        Expanded(
                          flex: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Buscar",
                                      style: TextStylesSystem().ralewayStyle(
                                        18,
                                        FontWeight.w700,
                                        ColorsSystem().colorLabels,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    searchBarOnly(context, 40),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width: 10), // Menor espacio entre columnas
                              Flexible(
                                flex: 8,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Bodega",
                                      style: TextStylesSystem().ralewayStyle(
                                        18,
                                        FontWeight.w700,
                                        ColorsSystem().colorLabels,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    _selectWarehosues(context, 0),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                flex: 7,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Categorías",
                                      style: TextStylesSystem().ralewayStyle(
                                        18,
                                        FontWeight.w700,
                                        ColorsSystem().colorLabels,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    _selectCategories(context, 0),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tipo",
                                      style: TextStylesSystem().ralewayStyle(
                                        18,
                                        FontWeight.w700,
                                        ColorsSystem().colorLabels,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    _selectType(context, 0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Registros: ",
                                style: TextStylesSystem().ralewayStyle(
                                  18,
                                  FontWeight.w700,
                                  ColorsSystem().colorStore,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "$total",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: ColorsSystem().colorStore,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Para separar el último item
                      children: [
                        Expanded(
                          flex: 9,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Rango de Precio",
                                      style: TextStylesSystem().ralewayStyle(
                                        14,
                                        FontWeight.bold,
                                        ColorsSystem().colorLabels,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width *
                                          0.16,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: RangeSlider(
                                        values: _currentRangeValues,
                                        min: 0,
                                        max: 100,
                                        divisions: 10,
                                        labels: RangeLabels(
                                          '\$${_currentRangeValues.start.round().toString()}',
                                          '\$${_currentRangeValues.end.round().toString()}',
                                        ),
                                        onChanged: (RangeValues values) {
                                          setState(() {
                                            _currentRangeValues = values;
                                            _minPriceController.text =
                                                _currentRangeValues.start
                                                    .round()
                                                    .toString();
                                            _maxPriceController.text =
                                                _currentRangeValues.end
                                                    .round()
                                                    .toString();
                                          });
                                        },
                                        activeColor:
                                            ColorsSystem().colorSelected,
                                        inactiveColor: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width: 50), //  Menor espacio entre columnas
                              Flexible(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 30),
                                    Row(
                                      children: [
                                        _buildCircularCheckbox(_isCheckedAll,
                                            (value) {
                                          if (value) selectFilter('all');
                                        }),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Todo',
                                          style:
                                              TextStylesSystem().ralewayStyle(
                                            18,
                                            FontWeight.bold,
                                            _isCheckedAll
                                                ? ColorsSystem().colorSelected
                                                : ColorsSystem().colorLabels,
                                          ),
                                        ),
                                        const SizedBox(width: 30),
                                        _buildCircularCheckbox(
                                            _isCheckedFavorites, (value) {
                                          if (value) selectFilter('favorites');
                                        }),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Favoritos',
                                          style:
                                              TextStylesSystem().ralewayStyle(
                                            18,
                                            FontWeight.bold,
                                            _isCheckedFavorites
                                                ? ColorsSystem().colorSelected
                                                : ColorsSystem().colorLabels,
                                          ),
                                        ),
                                        const SizedBox(width: 30),
                                        _buildCircularCheckbox(_isCheckedinSell,
                                            (value) {
                                          if (value) selectFilter('onsale');
                                        }),
                                        const SizedBox(width: 10),
                                        Text(
                                          'En Venta',
                                          style:
                                              TextStylesSystem().ralewayStyle(
                                            18,
                                            FontWeight.bold,
                                            _isCheckedinSell
                                                ? ColorsSystem().colorSelected
                                                : ColorsSystem().colorLabels,
                                          ),
                                        ),
                                        const SizedBox(width: 30),
                                        _buildCircularCheckbox(
                                            _isCheckedMiProducts, (value) {
                                          if (value) selectFilter('myProducts');
                                        }),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Mis Productos',
                                          style:
                                              TextStylesSystem().ralewayStyle(
                                            18,
                                            FontWeight.bold,
                                            _isCheckedMiProducts
                                                ? ColorsSystem().colorSelected
                                                : ColorsSystem().colorLabels,
                                          ),
                                        ),
                                      ],
                                    ),
                                    //  SizedBox(height: 30),
                                    // Row(
                                    //   children: [
                                    //     _buildCircularCheckbox(_isCheckedFavorites,
                                    //         (value) {
                                    //       if (value) selectFilter('favorites');
                                    //     }),
                                    //     const SizedBox(width: 10),
                                    //     Text(
                                    //       'Favoritos',
                                    //       style: TextStylesSystem().ralewayStyle(
                                    //         18,
                                    //         FontWeight.bold,
                                    //         _isCheckedFavorites
                                    //             ? ColorsSystem().colorSelected
                                    //             : ColorsSystem().colorLabels,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                              // SizedBox(width: 10),
                              // Flexible(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       SizedBox(height: 30),
                              //       Row(
                              //         children: [
                              //           _buildCircularCheckbox(_isCheckedFavorites,
                              //               (value) {
                              //             if (value) selectFilter('favorites');
                              //           }),
                              //           const SizedBox(width: 10),
                              //           Text(
                              //             'Favoritos',
                              //             style: TextStylesSystem().ralewayStyle(
                              //               18,
                              //               FontWeight.bold,
                              //               _isCheckedFavorites
                              //                   ? ColorsSystem().colorSelected
                              //                   : ColorsSystem().colorLabels,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),

                              // SizedBox(width: 10),
                              // Flexible(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       SizedBox(height: 30),
                              //       Row(
                              //         children: [
                              //           _buildCircularCheckbox(_isCheckedinSell,
                              //               (value) {
                              //             if (value) selectFilter('onsale');
                              //           }),
                              //           const SizedBox(width: 10),
                              //           Text(
                              //             'En Venta',
                              //             style: TextStylesSystem().ralewayStyle(
                              //               18,
                              //               FontWeight.bold,
                              //               _isCheckedinSell
                              //                   ? ColorsSystem().colorSelected
                              //                   : ColorsSystem().colorLabels,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(width: 10),
                              // Flexible(
                              //   flex: 1,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       SizedBox(height: 30),
                              //       Row(
                              //         children: [
                              //           _buildCircularCheckbox(_isCheckedMiProducts,
                              //               (value) {
                              //             if (value) selectFilter('myProducts');
                              //           }),
                              //           const SizedBox(width: 10),
                              //           Text(
                              //             'Mis Productos',
                              //             style: TextStylesSystem().ralewayStyle(
                              //               18,
                              //               FontWeight.bold,
                              //               _isCheckedMiProducts
                              //                   ? ColorsSystem().colorSelected
                              //                   : ColorsSystem().colorLabels,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        // Botones de aplicar y quitar filtros a la derecha
                        Flexible(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Tooltip(
                                    message: 'Aplicar Filtros',
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        _getProductModelCatalog();
                                      },
                                      icon: Icon(Icons.filter_alt_outlined,
                                          color: ColorsSystem().colorStore),
                                      label: Text(""),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorsSystem()
                                            .colorInitialContainer,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Tooltip(
                                    message: 'Quitar Filtros',
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _resetFilter();
                                        _getProductModelCatalog();
                                      },
                                      icon: Icon(Icons.filter_alt_off_outlined,
                                          color: ColorsSystem().colorStore),
                                      label: Text(""),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorsSystem()
                                            .colorInitialContainer,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              _catalog(MediaQuery.of(context).size.width * 0.80,
                  MediaQuery.of(context).size.height * 0.99),
              // paginationComplete(),
              Flexible(
                  child: products.isNotEmpty
                      ? Container(
                          height: 30,
                          child: paginationComplete(),
                        )
                      : Container()),
              SizedBox(
                height: 10,
              )
            ]),
          );
        }
            // child:

            )),
      )
    ]);

    // ],);
  }

  void selectFilter(String filterType) {
    setState(() {
      // Reinicia todos los checkboxes a 'false'
      _isCheckedAll = false;
      _isCheckedFavorites = false;
      _isCheckedinSell = false;
      _isCheckedMiProducts = false;

      // Verifica cuál checkbox ha sido seleccionado y actualiza su estado
      if (filterType == 'all') {
        arrayFiltersAnd.clear();
        arrayFiltersAnd.add({"equals/seller_owned": null});

        _isCheckedAll = true;
        filterps.clear();

        selectedWarehouse = "TODO";
        selectedCategory = 'TODO';
        selectedType = 'TODO';
        warehouseController.text = "TODO";
        categoryController.text = "TODO";
        typeController.text = "TODO";

        _minPriceController.clear();
        _maxPriceController.clear();
        _search.clear();
        outFilter.clear();

        _getProductModelCatalog(); // Aplicar el filtro de 'Todo'
      } else if (filterType == 'favorites') {
        arrayFiltersAnd.clear();
        arrayFiltersAnd.add({"equals/seller_owned": null});
        _isCheckedFavorites = true;
        filterps.clear();
        selectedKeyList.clear();
        selectedKeyList.add("favorite");

        selectedWarehouse = "TODO";
        selectedCategory = 'TODO';
        selectedType = 'TODO';
        warehouseController.text = "TODO";
        categoryController.text = "TODO";
        typeController.text = "TODO";

        _minPriceController.clear();
        _maxPriceController.clear();
        _search.clear();
        outFilter.clear();

        filterps.add({
          "id_master": int.parse(
            sharedPrefs!.getString("idComercialMasterSeller").toString(),
          ),
        });
        filterps.add({"key": selectedKeyList});
        _getProductModelCatalog();
      } else if (filterType == 'onsale') {
        arrayFiltersAnd.clear();
        arrayFiltersAnd.add({"equals/seller_owned": null});
        _isCheckedinSell = true;
        filterps.clear();
        selectedKeyList.clear();
        selectedKeyList.add("onsale");

        selectedWarehouse = "TODO";
        selectedCategory = 'TODO';
        selectedType = 'TODO';
        warehouseController.text = "TODO";
        categoryController.text = "TODO";
        typeController.text = "TODO";

        _minPriceController.clear();
        _maxPriceController.clear();
        _search.clear();
        outFilter.clear();

        filterps.add({
          "id_master": int.parse(
            sharedPrefs!.getString("idComercialMasterSeller").toString(),
          ),
        });
        filterps.add({"key": selectedKeyList});
        _getProductModelCatalog();
      } else if (filterType == 'myProducts') {
        arrayFiltersAnd.clear();
        filterps.clear();
        selectedKeyList.clear();
        _isCheckedMiProducts = true;

        selectedWarehouse = "TODO";
        selectedCategory = 'TODO';
        selectedType = 'TODO';
        _minPriceController.clear();
        _maxPriceController.clear();
        _search.clear();
        outFilter.clear();

        // Agrega lógica para el filtro de 'myProducts'
        var idMaster =
            sharedPrefs!.getString("idComercialMasterSeller").toString();

        // Elimina el filtro de "seller_owned" si existe
        arrayFiltersAnd
            .removeWhere((filter) => filter.containsKey("equals/seller_owned"));

        // Añade el filtro de "seller_owned" si el checkbox de 'myProducts' está seleccionado
        arrayFiltersAnd.add({"equals/seller_owned": idMaster});
        // arrayFiltersAnd.add({"equals/seller_owned": null});

        // Actualiza los productos filtrados
        _getProductModelCatalog();
      }
    });
  }

  Row paginationComplete() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Distribuir los elementos
      children: [
        // Sección de resultados a la izquierda
        Text(
          '$from - $to de $total resultados',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        Center(child: Container(width: 400, child: numberPaginator())),
        // Text("aqui va el dropdown"),
        // Dropdown a la derecha
        dropdownPagination()
      ],
    );
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
          // buttonSize: Size(30, 30), // Ajusta el tamaño del botón
          // buttonSelectedForegroundColor: Colors.white,
          buttonUnselectedForegroundColor: ColorsSystem().colorSection2,
          buttonSelectedBackgroundColor: ColorsSystem().colorStore,
          buttonUnselectedBackgroundColor: Colors.white,
          buttonShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          // height: 100,
          // contentPadding: EdgeInsets.only(bottom: 10),
          mainAxisAlignment: MainAxisAlignment.center,
          mode: ContentDisplayMode.numbers),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      onPageChange: (index) async {
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          await _paginateProductModelCatalog();
        }
      },
    );
  }

  Widget _buildCircularCheckbox(bool isChecked, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () {
        onChanged(!isChecked); // Llama a la función para cambiar el estado
      },
      child: Container(
        width: 24, // Ancho del contenedor
        height: 24, // Alto del contenedor
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Hacemos el contenedor circular
          color: isChecked
              ? ColorsSystem().colorSelected
              : Colors.white, // Color cuando está seleccionado o no
          // border: Border.all(color: Colors.red), // Bordes rojos
        ),
        child: isChecked
            ? Icon(Icons.check,
                color: Colors.white, size: 18) // Marca el checkbox con un ícono
            : null, // Sin ícono si no está marcado
      ),
    );
  }

  Container searchBarOnly(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      height: height,
      width: MediaQuery.of(context).size.width * 0.20,
      child: _modelTextField(
        text: "Buscar",
        controller: _search,
      ),
    );
  }

  Container searchBarOnlyMobile(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      height: height,
      width: MediaQuery.of(context).size.width * 0.65,
      child: _modelTextField(
        text: "Buscar",
        controller: _search,
      ),
    );
  }

  // ! old
  Column _catalog(double screenWidth, double screenHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final gridWidth = constraints.maxWidth;
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(10),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (constraints.maxWidth ~/ 300)
                              .clamp(4, 10), // Número de columnas dinámico
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 30,
                          // childAspectRatio: (constraints.maxWidth > 800)? 0.8: 1, // Proporción dinámica

                          childAspectRatio: calculateResolutions(gridWidth)),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          ProductModel product = products[index];
                          return ProductCard(
                            product: product,
                            onTapCallback: (context) => _showProductInfo(
                              context,
                              product,
                            ),
                          );
                        },
                        childCount: products.length, // Número de elementos
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  double calculateResolutions(double gridWidth) {
    if (gridWidth <= 1065) {
      return 0.57; // Resolución mínima
    } else if (gridWidth > 1065 && gridWidth <= 1300) {
      // Ajustar la altura para el rango hasta 1300
      return 0.70 + ((gridWidth - 1065) / (1300 - 1065)) * (0.70 - 0.65);
    } else if (gridWidth > 1300 && gridWidth <= 1400) {
      // Reducir manualmente la altura en este rango
      return 0.80; // Proporción más baja para evitar tarjetas muy altas
    } else if (gridWidth > 1400 && gridWidth <= 1880) {
      // Interpolación suave en este rango
      return 0.85 + ((gridWidth - 1400) / (1880 - 1400)) * (0.81 - 0.85);
    } else if (gridWidth > 1880 && gridWidth <= 2360) {
      return 0.81; // Mantener esta resolución estable
    } else if (gridWidth > 2360 && gridWidth <= 2840) {
      return 0.77 + ((gridWidth - 2360) / (2840 - 2360)) * (0.80 - 0.77);
    } else if (gridWidth > 2840 && gridWidth <= 3540) {
      return 0.80 + ((gridWidth - 2840) / (3540 - 2840)) * (0.90 - 0.80);
    } else if (gridWidth > 3540 && gridWidth <= 3800) {
      return 0.89;
    } else {
      return 1.4; // Resolución máxima
    }
  }

  double calculateMobileAspectRatio(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Ajusta el aspecto en función de la altura y el ancho de la pantalla
    if (screenWidth <= 389) {
      return 2 / 2.9; // Proporción para pantallas pequeñas
    } else if (screenWidth > 389 && screenWidth < 412) {
      return 2 / 2.8; // Proporción para pantallas pequeñas
    } else if (screenWidth == 414 || screenWidth == 412) {
      return 2 / 2.5; // Proporción para pantallas pequeñas
    } else if (screenWidth > 414 && screenWidth <= 430) {
      return 2 / 2.3; // Proporción para pantallas pequeñas
    } else if (screenWidth > 430 && screenWidth <= 600) {
      return 3 / 3.8; // Ajuste para pantallas medianas
    } else {
      return screenHeight > 700
          ? 4 / 5 // Para pantallas más grandes con mayor altura
          : 2 / 3;
    }
  }

  // ! new
  Container _selectWarehosues(BuildContext context, isMobile) {
    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: warehousesToSelect
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item == 'TODO' ? 'TODO' : item.split('|')[1],
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: selectedWarehouse,
          onChanged: (String? value) {
            setState(() {
              selectedWarehouse = value ?? "";
            });

            if (value == 'TODO') {
              arrayFiltersAnd.removeWhere(
                  (filter) => filter.containsKey("equals/warehouse_id"));
            } else {
              arrayFiltersAnd.removeWhere(
                  (filter) => filter.containsKey("equals/warehouse_id"));
              arrayFiltersAnd.add({
                "equals/warehouse_id":
                    selectedWarehouse.toString().split("-")[0].toString()
              });
            }

            setState(() {
              _getProductModelCatalog();
            });
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  Container _selectWarehosuesMobile(BuildContext context, isMobile, setState) {
    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 12,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: warehousesToSelect
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item == 'TODO' ? 'TODO' : item.split('|')[1],
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 12,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: warehouseController.text,
          onChanged: (String? value) {
            setState(() {
              warehouseController.text = value ?? "";
            });

            if (value == 'TODO') {
              arrayFiltersAnd.removeWhere(
                  (filter) => filter.containsKey("equals/warehouse_id"));
            } else {
              arrayFiltersAnd.removeWhere(
                  (filter) => filter.containsKey("equals/warehouse_id"));
              arrayFiltersAnd.add({
                "equals/warehouse_id":
                    warehouseController.text.toString().split("-")[0].toString()
              });
            }

            // setState(() {
            //   _getProductModelCatalog();
            // });
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  // ! new
  Container _selectCategories(BuildContext context, isMobile) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: categoriesToSelect
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item == 'TODO' ? 'TODO' : item.split('-')[0],
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: selectedCategory,
          onChanged: (String? value) {
            setState(() {
              selectedCategory = value ?? "";

              if (value != 'TODO') {
                if (!selectedCategoriesList
                    .contains(selectedCategory?.split('-')[0])) {
                  setState(() {
                    selectedCategoriesList
                        .add(selectedCategory!.split('-')[0].toString());
                  });
                }

                bool categoryRangeExists = outFilter
                    .any((filter) => filter.containsKey("input_categories"));
                if (!categoryRangeExists) {
                  outFilter.add({"input_categories": selectedCategoriesList});
                }
              } else {
                outFilter.removeWhere(
                    (filter) => filter.containsKey("input_categories"));
              }
              _getProductModelCatalog();
            });
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  // ! mobile
  Container _selectCategoriesMobile(BuildContext context, isMobile, setState) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 12,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: categoriesToSelect
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item == 'TODO' ? 'TODO' : item.split('-')[0],
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 12,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: categoryController.text,
          onChanged: (String? value) {
            setState(() {
              categoryController.text = value ?? "";

              if (value != 'TODO') {
                if (!selectedCategoriesList
                    .contains(categoryController.text.split('-')[0])) {
                  setState(() {
                    selectedCategoriesList
                        .add(categoryController.text.split('-')[0].toString());
                  });
                }

                bool categoryRangeExists = outFilter
                    .any((filter) => filter.containsKey("input_categories"));
                if (!categoryRangeExists) {
                  outFilter.add({"input_categories": selectedCategoriesList});
                }
              } else {
                outFilter.removeWhere(
                    (filter) => filter.containsKey("input_categories"));
              }
              // _getProductModelCatalog();
            });
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  // ! new
  Container _selectType(BuildContext context, isMobile) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: typeToSelect
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item == 'TODO' ? 'TODO' : item,
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: selectedType,
          onChanged: (String? value) {
            setState(() {
              selectedType = value ?? "";
              if (value == 'TODO') {
                arrayFiltersAnd.removeWhere(
                    (filter) => filter.containsKey("equals/isvariable"));
              } else {
                arrayFiltersAnd.removeWhere(
                    (filter) => filter.containsKey("equals/isvariable"));
                arrayFiltersAnd.add(
                    {"equals/isvariable": selectedType == "SIMPLE" ? 0 : 1});
              }
              _getProductModelCatalog();
            });
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  // ! mobile
  Container _selectTypeMobile(BuildContext context, isMobile, setState) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'Seleccionar',
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 12,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: typeToSelect
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item == 'TODO' ? 'TODO' : item,
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 12,
                        FontWeight.w500,
                        ColorsSystem().colorStore),
                  ),
                ),
              )
              .toList(),
          value: typeController.text,
          onChanged: (String? value) {
            setState(() {
              typeController.text = value ?? "";
              if (value == 'TODO') {
                arrayFiltersAnd.removeWhere(
                    (filter) => filter.containsKey("equals/isvariable"));
              } else {
                arrayFiltersAnd.removeWhere(
                    (filter) => filter.containsKey("equals/isvariable"));
                arrayFiltersAnd.add({
                  "equals/isvariable": typeController.text == "SIMPLE" ? 0 : 1
                });
              }
              // _getProductModelCatalog();
            });
          },
          buttonStyleData: ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco del menú desplegable
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          iconStyleData: const IconStyleData(
            openMenuIcon: Icon(Icons.arrow_drop_up),
            icon: Icon(Icons.arrow_drop_down), // Icono para desplegar el menú
          ),
        ),
      ),
    );
  }

  _resetFilter() {
    setState(() {
      _currentRangeValues = _defautRangeValues;
      _minPriceController.text = _defautRangeValues.start.round().toString();
      _maxPriceController.text = _defautRangeValues.end.round().toString();
      outFilter.removeWhere((filter) => filter.containsKey("price_range"));
    });
    _search.clear();
    selectedProvider = 'TODO';
    selectedWarehouse = "TODO";
    selectedCategory = 'TODO';
    selectedType = 'TODO';

    warehouseController.text = "TODO";
    categoryController.text = "TODO";
    typeController.text = "TODO";

    _minPriceController.clear();
    _maxPriceController.clear();
    selectedCategoriesList = [];
    arrayFiltersAnd = [
      {"equals/seller_owned": null}
    ];
    outFilter = [];
    _currentRangeValues = _currentRangeValues;
    _isCheckedFavorites = false;
    _isCheckedinSell = false;
    _isCheckedMiProducts = false;
    _isCheckedAll = true;
    filterps = [];
  }

  String getFirstImgUrl(dynamic urlImgData) {
    List<String> urlsImgsList = (jsonDecode(urlImgData) as List).cast<String>();
    String url = urlsImgsList[0];
    return url;
  }

  void _showProductInfo(BuildContext context, ProductModel product) {
    List<String> urlsImgsList = product.urlImg != null &&
            product.urlImg.isNotEmpty &&
            product.urlImg.toString() != "[]"
        ? (jsonDecode(product.urlImg) as List).cast<String>()
        : [];

    // Decodificar el JSON
    Map<String, dynamic> features = jsonDecode(product.features);

    String guideName = "";
    String priceSuggested = "";
    String sku = "";
    String description = "";
    String type = "";
    String variablesSKU = "";
    String variablesText = "";
    String categoriesText = "";
    List<dynamic> categories;

    String reservesText = "";
    int reserveStock = 0;
    List<ReserveModel>? reservesList = product.reserves;
    if (reservesList != null) {
      for (int i = 0; i < reservesList.length; i++) {
        var idMaster =
            sharedPrefs!.getString("idComercialMasterSeller").toString();
        ReserveModel reserve = reservesList[i];
        //
        if (int.parse(idMaster) == int.parse(reserve.idComercial.toString())) {
          reservesText += "SKU: ${reserve.sku}\nCantidad: ${reserve.stock}";
          reserveStock += int.parse(reserve.stock.toString());
          if (i < reservesList.length - 1) {
            reservesText += "\n\n";
          }
        } else {
          // print("Existen reservas pero NO de este userMaster");
        }
      }
    }

    guideName = features["guide_name"];
    priceSuggested = features["price_suggested"].toString();
    sku = features["sku"];
    description = features["description"];
    type = features["type"];
    categories = features["categories"];
    List<String> categoriesNames =
        categories.map((item) => item["name"].toString()).toList();
    categoriesText = categoriesNames.join(', ');

    List<dynamic> variantsList;
    String variablesQuantityText = "";

    if (product.isvariable == 1) {
      variantsList = features["variants"];
      variablesQuantityText = generateLabelVariantsQuantity(variantsList);

      for (var variant in variantsList) {
        variablesSKU += "${variant['sku']}\n";
      }
    }

    int isFavorite = 3; //2:null
    int isOnSale = 3;
    String labelIsFavorite = "Agregar a favoritos";
    String labelIsOnSale = "Adquirir";

    //

    List<ProductSellerModel>? productsellerList = product.productseller;

    if (productsellerList != null) {
      for (ProductSellerModel productSeller in productsellerList) {
        if (productSeller.idMaster.toString() ==
            sharedPrefs!.getString("idComercialMasterSeller")) {
          // print(
          //     'ID: ${productSeller.id}, id_Product: ${productSeller.productId}, Id_Master: ${productSeller.idMaster}, favorite: ${productSeller.favorite}, onsale: ${productSeller.onsale}');
          if (productSeller.favorite != null) {
            isFavorite = int.parse(productSeller.favorite.toString());
          } else {
            isFavorite = 2; //2:null
          }
          if (productSeller.onsale != null) {
            isOnSale = int.parse(productSeller.onsale.toString());
          } else {
            isOnSale = 2; //2:null
          }
        } else {
          // print("Si esta en la productSeller pero no esta tienda");
        }
      }
    }

    if (isFavorite == 1) {
      labelIsFavorite = "Quitar de favoritos";
    }
    if (isOnSale == 1) {
      labelIsOnSale = "Dejar de vender";
    }

    // print("G: ${product.stock.toString()}");
    // print("R: ${reserveStock.toString()}");

    // print("isFavorite: $isFavorite");
    // print("isOnSale: $isOnSale");

    showDialog(
      context: context,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        double imgHeight = screenWidth > 600 ? 260 : 150;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          contentPadding: EdgeInsets.all(0),
          content: Container(
            // width: MediaQuery.of(context).size.width < 1000 ? MediaQuery.of(context).size.width * 1.5 : MediaQuery.of(context).size.width, // Ancho receptivo
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height == 600
                  ? 450
                  : MediaQuery.of(context).size.height == 800
                      ? 650
                      : MediaQuery.of(context).size.height * 0.8,
              // width: 900,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  responsive(
                      Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: ShowImages(urlsImgsList: urlsImgsList),
                          ),
                          Expanded(
                            flex: 4,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: ListView(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 15),
                                              decoration: BoxDecoration(
                                                color: ColorsSystem()
                                                    .colorBackoption,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: ColorsSystem()
                                                        .colorInitialContainer
                                                        .withOpacity(
                                                            0.1), // Color de la sombra
                                                    spreadRadius:
                                                        5, // Qué tan lejos se extiende la sombra
                                                    blurRadius:
                                                        10, // Suavidad de la sombra
                                                    offset: Offset(5,
                                                        0), // Desplazamiento de la sombra (x, y)
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                  "ID: ${product.productId.toString()}",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: ColorsSystem()
                                                          .colorStore)),
                                            )
                                          ]),
                                      // _textTitle("Producto:"),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              product.productName.toString(),
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    ColorsSystem().colorLabels,
                                              ),
                                              softWrap:
                                                  true, // Permite que el texto haga un salto de línea
                                              overflow: TextOverflow
                                                  .visible, // Evita el desbordamiento
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Text(
                                            "SKU: ",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    ColorsSystem().colorLabels),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            sku,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    ColorsSystem().colorLabels),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Visibility(
                                        visible: product.isvariable == 1,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "SKU Variables",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 16,
                                                            color: ColorsSystem()
                                                                .colorSection2),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(variablesSKU,
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: ColorsSystem()
                                                              .colorLabels)),
                                                ],
                                              ),
                                            ),
                                            // const SizedBox(height: 10),
                                          ],
                                        ),
                                      ),
                                      // const SizedBox(height: 10),
                                      Row(
                                          // mainAxisAlignment:
                                          // MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Categoría: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      14,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            const SizedBox(width: 5),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10, horizontal: 15),
                                              decoration: BoxDecoration(
                                                color: ColorsSystem()
                                                    .colorBackoption,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: ColorsSystem()
                                                        .colorInitialContainer
                                                        .withOpacity(
                                                            0.1), // Color de la sombra
                                                    spreadRadius:
                                                        5, // Qué tan lejos se extiende la sombra
                                                    blurRadius:
                                                        10, // Suavidad de la sombra
                                                    offset: Offset(5,
                                                        0), // Desplazamiento de la sombra (x, y)
                                                  ),
                                                ],
                                              ),
                                              child: Text(categoriesText,
                                                  style: TextStylesSystem()
                                                      .ralewayStyle(
                                                          18,
                                                          FontWeight.bold,
                                                          ColorsSystem()
                                                              .colorStore)),
                                            )
                                          ]),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Text(
                                            "Tipo de Producto: ",
                                            style: TextStylesSystem()
                                                .ralewayStyle(
                                                    14,
                                                    FontWeight.w500,
                                                    ColorsSystem()
                                                        .colorSection2),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            type,
                                            style: TextStylesSystem()
                                                .ralewayStyle(
                                                    18,
                                                    FontWeight.w600,
                                                    ColorsSystem().colorLabels),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 30, top: 8, bottom: 8),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                            decoration: BoxDecoration(
                                                color: ColorsSystem()
                                                    .colorBackoption,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        topLeft:
                                                            Radius.circular(
                                                                10))),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Precio Bodega",
                                                    style: TextStylesSystem()
                                                        .ralewayStyle(
                                                            18,
                                                            FontWeight.w500,
                                                            ColorsSystem()
                                                                .colorSection2),
                                                  ),
                                                  Text(
                                                    "\$ ${product.price}",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: ColorsSystem()
                                                            .colorStore),
                                                  )
                                                ]),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                left: 15, top: 8, bottom: 8),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                            decoration: BoxDecoration(
                                                color: ColorsSystem()
                                                    .colorBackoption,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        bottomRight:
                                                            Radius.circular(10),
                                                        topRight:
                                                            Radius.circular(
                                                                10))),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Precio Sugerido",
                                                    style: TextStylesSystem()
                                                        .ralewayStyle(
                                                            18,
                                                            FontWeight.w500,
                                                            ColorsSystem()
                                                                .colorSection2),
                                                  ),
                                                  Text(
                                                    priceSuggested.isNotEmpty ||
                                                            priceSuggested != ""
                                                        ? '\$$priceSuggested'
                                                        : '',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: ColorsSystem()
                                                            .colorStore),
                                                  )
                                                ]),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        children: [
                                          Text(
                                            "Stock General: ",
                                            style: TextStylesSystem()
                                                .ralewayStyle(
                                                    14,
                                                    FontWeight.w500,
                                                    ColorsSystem()
                                                        .colorSection2),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${product.stock}",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: ColorsSystem()
                                                    .colorGreenNew),
                                          ),
                                        ],
                                      ),

                                      Visibility(
                                        visible: reservesText != "",
                                        child: Row(
                                          children: [
                                            Text(
                                              "Mis Reservas:",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      16,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            )
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: reservesText != "",
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              reservesText,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: ColorsSystem()
                                                      .colorLabels),
                                            )
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: product.isvariable == 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text("Variables",
                                                style: TextStylesSystem()
                                                    .ralewayStyle(
                                                        14,
                                                        FontWeight.w500,
                                                        ColorsSystem()
                                                            .colorLabels)),
                                            Text(
                                              variablesQuantityText,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: ColorsSystem()
                                                      .colorSection2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: screenWidth * 0.30,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 30),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: ColorsSystem()
                                                      .colorSection),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade200,
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Bodega:",
                                                      style: TextStylesSystem()
                                                          .ralewayStyle(
                                                        14,
                                                        FontWeight.w500,
                                                        ColorsSystem()
                                                            .colorSection2,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      getFirstWarehouseNameModel(
                                                              product
                                                                  .warehouses)
                                                          .split('-')[0],
                                                      style: TextStylesSystem()
                                                          .ralewayStyle(
                                                        16,
                                                        FontWeight.w500,
                                                        ColorsSystem()
                                                            .colorSelected,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                    height:
                                                        10), // Adjust spacing between the rows
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Atención al cliente:",
                                                      style: TextStylesSystem()
                                                          .ralewayStyle(
                                                        14,
                                                        FontWeight.w500,
                                                        ColorsSystem()
                                                            .colorSection2,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    GestureDetector(
                                                      onTap: () {
                                                        // Acción al hacer clic en el número de teléfono
                                                        sendWhatsAppMessage(
                                                          context,
                                                          getProviderPhoneModel(
                                                              product
                                                                  .warehouses),
                                                          product.productName
                                                              .toString(),
                                                          product.productId
                                                              .toString(),
                                                        );
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Image.asset(
                                                            images
                                                                .whatsapp_icon_2,
                                                            width:
                                                                iconSize * 0.3,
                                                            height:
                                                                iconSize * 0.3,
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                                  5), // Adjust space between icon and text
                                                          Text(
                                                            getProviderPhoneModel(
                                                                product
                                                                    .warehouses),
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: ColorsSystem()
                                                                  .colorSelected,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(children: [
                                        Expanded(
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                        horizontal: 30),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      _buttonCreateGuide(
                                                          product, context),
                                                      SizedBox(width: 10),
                                                      _buttonAddOnsale(
                                                          product,
                                                          isOnSale,
                                                          labelIsOnSale,
                                                          context),
                                                      SizedBox(width: 10),
                                                      Visibility(
                                                        visible: int.parse(product
                                                                    .stock
                                                                    .toString()) >
                                                                0 ||
                                                            reserveStock > 0,
                                                        child: Tooltip(
                                                          message:
                                                              'Descargar archivo CSV',
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              side: BorderSide(
                                                                color: ColorsSystem()
                                                                    .colorStore,
                                                                width: 2,
                                                              ),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              // Tu lógica para descargar archivo CSV
                                                              getLoadingModal(
                                                                  context,
                                                                  true);
                                                              try {
                                                                // await getReport.generateExcelFileWithData(product);
                                                                if (product
                                                                        .isvariable ==
                                                                    1) {
                                                                  await getReport
                                                                      .generateCsvFileProductVariant(
                                                                          product);
                                                                } else {
                                                                  await getReport
                                                                      .generateCsvFileProductSimple(
                                                                          product);
                                                                }
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              } catch (e) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                print(
                                                                    "error: $e");
                                                                SnackBarHelper
                                                                    .showErrorSnackBar(
                                                                        context,
                                                                        "Ha ocurrido un error al generar el reporte");
                                                              }
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .file_download_outlined,
                                                                      color: ColorsSystem()
                                                                          .colorStore),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Tooltip(
                                                        message: isFavorite == 1
                                                            ? 'Quitar de Favoritos'
                                                            : 'Agregar a Favoritos',
                                                        child:
                                                            _buttonAddFavorite(
                                                                product,
                                                                isFavorite,
                                                                labelIsFavorite,
                                                                context),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Visibility(
                                                        visible: int.parse(product
                                                                    .stock
                                                                    .toString()) >
                                                                0 ||
                                                            reserveStock > 0,
                                                        child: Tooltip(
                                                          message:
                                                              "Copiar SKU / SKUs",
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              side: BorderSide(
                                                                color: ColorsSystem()
                                                                    .colorStore,
                                                                width: 2,
                                                              ),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              getLoadingModal(
                                                                  context,
                                                                  true);

                                                              if (product
                                                                      .isvariable ==
                                                                  1) {
                                                                String
                                                                    variablesSkuId =
                                                                    "";

                                                                List<
                                                                    Map<String,
                                                                        dynamic>>? variants = (features[
                                                                            "variants"]
                                                                        as List<
                                                                            dynamic>)
                                                                    .cast<
                                                                        Map<String,
                                                                            dynamic>>();

                                                                variablesText =
                                                                    variants!.map(
                                                                        (variable) {
                                                                  if (variable
                                                                      .containsKey(
                                                                          'sku')) {
                                                                    variablesSkuId +=
                                                                        "${variable['sku']}C${product.productId.toString()}\n";
                                                                  }
                                                                }).join('\n\n');

                                                                Clipboard.setData(
                                                                    ClipboardData(
                                                                        text:
                                                                            variablesSkuId));

                                                                Get.snackbar(
                                                                  'SKUs COPIADOS',
                                                                  'Copiado al Clipboard',
                                                                );
                                                              } else {
                                                                Clipboard.setData(
                                                                    ClipboardData(
                                                                        text:
                                                                            "${sku}C${product.productId.toString()}"));

                                                                Get.snackbar(
                                                                  'SKU COPIADO',
                                                                  'Copiado al Clipboard',
                                                                );
                                                              }
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Icon(
                                                                      Icons
                                                                          .copy_rounded,
                                                                      color: ColorsSystem()
                                                                          .colorStore),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )))
                                      ]),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            "Detalles",
                                            style: TextStylesSystem()
                                                .ralewayStyle(
                                                    14,
                                                    FontWeight.w500,
                                                    ColorsSystem()
                                                        .colorSection2),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        // width: 500,
                                        // color: Colors.purple.shade100,
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 15),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: ColorsSystem().colorSection,
                                            width: 1.0,
                                          ),
                                        ),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.25,
                                        child: ListView(
                                          children: [
                                            Html(
                                              data: description,
                                              style: {
                                                'h1': Style(
                                                  fontSize: FontSize(14),
                                                  fontFamily: 'Raleway',
                                                  color:
                                                      ColorsSystem().colorText,
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                                'h2': Style(
                                                  fontSize: FontSize(14),
                                                  fontFamily: 'Raleway',
                                                  color:
                                                      ColorsSystem().colorText,
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                                'p': Style(
                                                  fontSize: FontSize(18),
                                                  fontFamily: 'Raleway',
                                                  color:
                                                      ColorsSystem().colorText,
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                                'li': Style(
                                                  fontFamily: 'Raleway',
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                                'ol': Style(
                                                  fontFamily: 'Raleway',
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      //mobile
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: ColorsSystem().colorBackoption,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: ColorsSystem()
                                                  .colorInitialContainer
                                                  .withOpacity(
                                                      0.1), // Color de la sombra
                                              spreadRadius:
                                                  5, // Qué tan lejos se extiende la sombra
                                              blurRadius:
                                                  10, // Suavidad de la sombra
                                              offset: Offset(5,
                                                  0), // Desplazamiento de la sombra (x, y)
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                            "ID: ${product.productId.toString()}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    ColorsSystem().colorStore)),
                                      )
                                    ]),
                                const SizedBox(height: 10),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  // padding: EdgeInsets.all(10),
                                  height: imgHeight - 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: ProductCarousel(
                                      urlImages: urlsImgsList,
                                      imgHeight: imgHeight),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        product.productName.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorLabels,
                                        ),
                                        softWrap:
                                            true, // Permite que el texto haga un salto de línea
                                        overflow: TextOverflow
                                            .visible, // Evita el desbordamiento
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Nombre-guia de envio:',
                                  style: TextStylesSystem().ralewayStyle(
                                      12,
                                      FontWeight.w600,
                                      ColorsSystem().colorSelected),
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        guideName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: ColorsSystem().colorSelected,
                                        ),
                                        softWrap:
                                            true, // Permite que el texto haga un salto de línea
                                        overflow: TextOverflow
                                            .visible, // Evita el desbordamiento
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      "SKU: ",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorLabels),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      sku,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorLabels),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Visibility(
                                  visible: product.isvariable == 1,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "SKU Variables",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: ColorsSystem()
                                                          .colorSection2),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Text(variablesSKU,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: ColorsSystem()
                                                        .colorLabels)),
                                          ],
                                        ),
                                      ),
                                      // const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                                // const SizedBox(height: 10),
                                Text(
                                  "Categoría: ",
                                  style: TextStylesSystem().ralewayStyle(
                                      12,
                                      FontWeight.w600,
                                      ColorsSystem().colorStore),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: ColorsSystem().colorBackoption,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ColorsSystem()
                                            .colorInitialContainer
                                            .withOpacity(
                                                0.1), // Color de la sombra
                                        spreadRadius:
                                            5, // Qué tan lejos se extiende la sombra
                                        blurRadius: 10, // Suavidad de la sombra
                                        offset: Offset(5,
                                            0), // Desplazamiento de la sombra (x, y)
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    categoriesText,
                                    style: TextStylesSystem().ralewayStyle(
                                        12,
                                        FontWeight.bold,
                                        ColorsSystem().colorStore),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Text(
                                      "Tipo de Producto: ",
                                      style: TextStylesSystem().ralewayStyle(
                                          10,
                                          FontWeight.w500,
                                          ColorsSystem().colorSection2),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      type,
                                      style: TextStylesSystem().ralewayStyle(
                                          12,
                                          FontWeight.w600,
                                          ColorsSystem().colorLabels),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 8, bottom: 8),
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      decoration: BoxDecoration(
                                          color: ColorsSystem().colorBackoption,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              topLeft: Radius.circular(10))),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Precio Bodega",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w500,
                                                      ColorsSystem()
                                                          .colorSection2),
                                            ),
                                            Text(
                                              "\$ ${product.price}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorsSystem()
                                                      .colorStore),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 15, top: 8, bottom: 8),
                                      // width: MediaQuery.of(context).size.width * 0.9,
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      decoration: BoxDecoration(
                                          color: ColorsSystem().colorBackoption,
                                          borderRadius: const BorderRadius.only(
                                              bottomRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10))),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Precio Sugerido",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w500,
                                                      ColorsSystem()
                                                          .colorSection2),
                                            ),
                                            Text(
                                              priceSuggested.isNotEmpty ||
                                                      priceSuggested != ""
                                                  ? '\$ $priceSuggested'
                                                  : '',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorsSystem()
                                                      .colorStore),
                                            )
                                          ]),
                                    )
                                  ],
                                ),

                                Visibility(
                                  visible: reservesText != "",
                                  child: Row(
                                    children: [
                                      Text(
                                        "Mis Reservas:",
                                        style: TextStylesSystem().ralewayStyle(
                                            10,
                                            FontWeight.w600,
                                            ColorsSystem().colorStore),
                                      )
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: reservesText != "",
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reservesText,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: ColorsSystem().colorLabels),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text(
                                      "Stock General: ",
                                      style: TextStylesSystem().ralewayStyle(
                                          10,
                                          FontWeight.w500,
                                          ColorsSystem().colorSection2),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${product.stock}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: ColorsSystem().colorGreenNew),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: product.isvariable == 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text("Variables",
                                          style: TextStylesSystem()
                                              .ralewayStyle(10, FontWeight.w500,
                                                  ColorsSystem().colorLabels)),
                                      Text(
                                        variablesQuantityText,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                ColorsSystem().colorSection2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),

                                Text(
                                  "Bodega:",
                                  style: TextStylesSystem().ralewayStyle(
                                    10,
                                    FontWeight.w500,
                                    ColorsSystem().colorSection2,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  getFirstWarehouseNameModel(product.warehouses)
                                      .split('-')[0],
                                  style: TextStylesSystem().ralewayStyle(
                                    12,
                                    FontWeight.w500,
                                    ColorsSystem().colorSelected,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  softWrap: true,
                                ),
                                const SizedBox(
                                    height:
                                        10), // Adjust spacing between the rows
                                Text(
                                  "Atención al cliente:",
                                  style: TextStylesSystem().ralewayStyle(
                                    10,
                                    FontWeight.w500,
                                    ColorsSystem().colorSection2,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        // Acción al hacer clic en el número de teléfono
                                        sendWhatsAppMessage(
                                          context,
                                          getProviderPhoneModel(
                                              product.warehouses),
                                          product.productName.toString(),
                                          product.productId.toString(),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          // Image.asset(
                                          //   images.whatsapp_icon_2,
                                          //   width: iconSize * 0.3,
                                          //   height: iconSize * 0.3,
                                          // ),
                                          // const SizedBox(
                                          //     width:
                                          //         5), // Adjust space between icon and text
                                          Text(
                                            getProviderPhoneModel(
                                                product.warehouses),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  ColorsSystem().colorSelected,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Descripción:",
                                  style: TextStylesSystem().ralewayStyle(
                                      12,
                                      FontWeight.w600,
                                      ColorsSystem().colorStore),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    ColorsSystem().colorSection,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Html(
                                              data: description,
                                              style: {
                                                'h1': Style(
                                                  fontSize: FontSize(14),
                                                  fontFamily: 'Raleway',
                                                  color:
                                                      ColorsSystem().colorText,
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                                'h2': Style(
                                                  fontSize: FontSize(12),
                                                  fontFamily: 'Raleway',
                                                  color:
                                                      ColorsSystem().colorText,
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                                'p': Style(
                                                  fontSize: FontSize(10),
                                                  fontFamily: 'Raleway',
                                                  color:
                                                      ColorsSystem().colorText,
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                                'li': Style(
                                                  fontFamily: 'Raleway',
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                                'ol': Style(
                                                  fontFamily: 'Raleway',
                                                  margin:
                                                      Margins.only(bottom: 0),
                                                ),
                                                // 'img': Style(
                                                //   width: Width(
                                                //       100), // Especifica el ancho de la imagen
                                                //   height: Height
                                                //       .auto(), // Mantén la proporción de altura automática
                                                //   margin: Margins.symmetric(
                                                //       horizontal:
                                                //           5), // Agrega márgenes si lo deseas
                                                //   display: Display
                                                //       .block, // Asegura que la imagen no se solape con otros elementos
                                                // ),
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buttonCreateGuideMobile(product, context),
                                    _buttonAddOnsaleMobile(product, isOnSale,
                                        labelIsOnSale, context),
                                    // SizedBox(width: 10),
                                    // visibilityDownloadCSVbuttton(
                                    //     product, reserveStock),
                                    // SizedBox(width: 10),
                                    // toolTipFavoriteMobile(isFavorite, product,
                                    //     labelIsFavorite, context),
                                    // SizedBox(width: 10),
                                    // visibilitySku(product, reserveStock,
                                    //     context, features, variablesText, sku)
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    visibilityDownloadCSVbuttton(
                                        product, reserveStock),
                                    // SizedBox(width: 32),
                                    toolTipFavoriteMobile(isFavorite, product,
                                        labelIsFavorite, context),
                                    // SizedBox(width: 32),
                                    visibilitySku(product, reserveStock,
                                        context, features, variablesText, sku)
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Visibility visibilitySku(
      ProductModel product,
      int reserveStock,
      BuildContext context,
      Map<String, dynamic> features,
      String variablesText,
      String sku) {
    return Visibility(
      visible: int.parse(product.stock.toString()) > 0 || reserveStock > 0,
      child: Tooltip(
        message: "Copiar SKU / SKUs",
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(
                color: ColorsSystem().colorStore,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              getLoadingModal(context, true);

              if (product.isvariable == 1) {
                String variablesSkuId = "";

                List<Map<String, dynamic>>? variants =
                    (features["variants"] as List<dynamic>)
                        .cast<Map<String, dynamic>>();

                variablesText = variants!.map((variable) {
                  if (variable.containsKey('sku')) {
                    variablesSkuId +=
                        "${variable['sku']}C${product.productId.toString()}\n";
                  }
                }).join('\n\n');

                Clipboard.setData(ClipboardData(text: variablesSkuId));

                Get.snackbar(
                  'SKUs COPIADOS',
                  'Copiado al Clipboard',
                );
              } else {
                Clipboard.setData(ClipboardData(
                    text: "${sku}C${product.productId.toString()}"));

                Get.snackbar(
                  'SKU COPIADO',
                  'Copiado al Clipboard',
                );
              }
              Navigator.of(context).pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.copy_rounded,
                  color: ColorsSystem().colorStore,
                  size: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Tooltip toolTipFavoriteMobile(int isFavorite, ProductModel product,
      String labelIsFavorite, BuildContext context) {
    return Tooltip(
      message: isFavorite == 1 ? 'Quitar de Favoritos' : 'Agregar a Favoritos',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: _buttonAddFavoriteMobile(
            product, isFavorite, labelIsFavorite, context),
      ),
    );
  }

  Visibility visibilityDownloadCSVbuttton(
      ProductModel product, int reserveStock) {
    return Visibility(
      visible: int.parse(product.stock.toString()) > 0 || reserveStock > 0,
      child: Tooltip(
        message: 'Descargar archivo CSV',
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: ColorsSystem().colorStore,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                // Tu lógica para descargar archivo CSV
                getLoadingModal(context, true);
                try {
                  // await getReport.generateExcelFileWithData(product);
                  if (product.isvariable == 1) {
                    await getReport.generateCsvFileProductVariant(product);
                  } else {
                    await getReport.generateCsvFileProductSimple(product);
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();
                  print("error: $e");
                  SnackBarHelper.showErrorSnackBar(
                      context, "Ha ocurrido un error al generar el reporte");
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_download_outlined,
                      color: ColorsSystem().colorStore, size: 12),
                ],
              ),
            )),
      ),
    );
  }

  String getFirstWarehouseNameModel(dynamic warehouses) {
    String name = "";
    List<WarehouseModel>? warehousesList = warehouses;
    if (warehousesList != null && warehousesList.isNotEmpty) {
      WarehouseModel firstWarehouse = warehousesList.first;
      // print(firstWarehouse.provider?.name);

      name =
          "${firstWarehouse.provider?.name}/${firstWarehouse.branchName.toString()}-${firstWarehouse.customerphoneNumber != null ? firstWarehouse.customerphoneNumber.toString() : ""}";
    }
    return name;
  }

  String generateLabelVariantsQuantity(List<dynamic> variantsList) {
    List<String> variantTexts = [];

    for (var variant in variantsList) {
      String variantTitle = buildVariantTitle(variant);
      int inventoryQuantity =
          int.parse(variant['inventory_quantity'].toString()) ?? 0;
      String variantText = 'Stock $variantTitle: $inventoryQuantity';
      variantTexts.add(variantText);
    }

    String result = variantTexts.join("\n");
    return result;
  }

  String buildVariantTitle(Map<String, dynamic> element) {
    List<String> excludeKeys = ['id', 'sku', 'inventory_quantity', 'price'];
    List<String> elementDetails = [];

    element.forEach((key, value) {
      if (!excludeKeys.contains(key)) {
        elementDetails.add("$value");
      }
    });

    return elementDetails.join("/");
  }

  // addOrderDialog(ProductModel product) {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             contentPadding: EdgeInsets.all(0),
  //             content: ProductAddOrder(
  //               product: product,
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  addOrderDialog(ProductModel product) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 400,
                    minWidth: 300,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: ProductAddOrder(
                    product: product,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  ElevatedButton _buttonCreateGuide(
      ProductModel product, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // var userId = sharedPrefs!.getString("id");
        addOrderDialog(product);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsSystem().colorSelected,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(color: Colors.white, Icons.file_download_outlined),
            SizedBox(
              width: 5,
            ),
            Text(
              "Crear Guía",
              style: TextStylesSystem()
                  .ralewayStyle(16, FontWeight.w500, Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ! mobile
  Container _buttonCreateGuideMobile(
      ProductModel product, BuildContext context) {
    return Container(
        height: 40,
        width: 110,
        child: ElevatedButton(
          onPressed: () async {
            addOrderDialog(product);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsSystem().colorSelected,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(color: Colors.white, Icons.file_download_outlined, size: 12),
              SizedBox(width: 3),
              Text(
                "Crear Guía",
                style: TextStylesSystem()
                    .ralewayStyle(10, FontWeight.w500, Colors.white),
              ),
            ],
          ),
        ));
  }

  ElevatedButton _buttonAddFavorite(ProductModel product, int isFavorite,
      String labelIsFavorite, BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          // var userId = sharedPrefs!.getString("id");
          // print(userId);
          var userIdComercialMasterSeller =
              sharedPrefs!.getString("idComercialMasterSeller");

          if (isFavorite != 3) {
            //existe el registro, need upt
            //update
            var response = await Connections().getProductSeller(
                int.parse(product.productId.toString()),
                int.parse(userIdComercialMasterSeller.toString()));

            // print(response['id']);

            var responseUpt =
                await Connections().updateProductSeller(response['id'], {
              "favorite": isFavorite == 1 ? 0 : 1,
            });

            // print(responseUpt);

            if (responseUpt == 1 || responseUpt == 2) {
              print('Error update new');
              // ignore: use_build_context_synchronously
              showSuccessModal(
                  context,
                  "Ha ocurrido un error al actualizar favoritos.",
                  Icons8.alert);
            } else {
              // ignore: use_build_context_synchronously
              AwesomeDialog(
                width: 500,
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.rightSlide,
                title: 'Info',
                desc: isFavorite == 1
                    ? "Se ha quitado de favoritos"
                    : "Se ha agregado a favoritos",
                btnCancel: Container(),
                btnOkText: "Aceptar",
                btnOkColor: colors.colorGreen,
                btnCancelOnPress: () {},
                btnOkOnPress: () {
                  _getProductModelCatalog();
                  Navigator.pop(context);
                },
              ).show();
            }
            //
          } else {
            //create new
            var responseNew = await Connections().createProductSeller(
                int.parse(product.productId.toString()),
                int.parse(userIdComercialMasterSeller.toString()),
                "favorite");
            // print("responseNew: $responseNew");
            if (responseNew == 1 || responseNew == 2) {
              print('Error Created new');
              // ignore: use_build_context_synchronously
              showSuccessModal(context,
                  "Ha ocurrido un error al agregar a favoritos.", Icons8.alert);
            } else {
              // ignore: use_build_context_synchronously
              AwesomeDialog(
                width: 500,
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.rightSlide,
                title: 'Info',
                desc: "Se ha agregado exitosamente a favoritos",
                btnCancel: Container(),
                btnOkText: "Aceptar",
                btnOkColor: colors.colorGreen,
                btnCancelOnPress: () {},
                btnOkOnPress: () {
                  _getProductModelCatalog();
                  Navigator.pop(context);
                },
              ).show();
            }
          }
          //
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: ColorsSystem().colorStore, // Borde con color personalizado
            width: 2, // Ancho del borde
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Opcional: Bordes redondeados
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text(
              //   labelIsFavorite,
              //   style: const TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 16,
              //   ),
              // ),
              // const SizedBox(width: 5),
              Icon(
                isFavorite == 1 ? Icons.favorite : Icons.favorite_outline,
                size: 24,
                color: isFavorite == 1
                    ? ColorsSystem().colorStore
                    : ColorsSystem().colorStore,
              ),
            ],
          ),
        ));
  }

  ElevatedButton _buttonAddFavoriteMobile(ProductModel product, int isFavorite,
      String labelIsFavorite, BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var userIdComercialMasterSeller =
              sharedPrefs!.getString("idComercialMasterSeller");

          if (isFavorite != 3) {
            //existe el registro, need upt
            //update
            var response = await Connections().getProductSeller(
                int.parse(product.productId.toString()),
                int.parse(userIdComercialMasterSeller.toString()));

            var responseUpt =
                await Connections().updateProductSeller(response['id'], {
              "favorite": isFavorite == 1 ? 0 : 1,
            });

            if (responseUpt == 1 || responseUpt == 2) {
              print('Error update new');
              // ignore: use_build_context_synchronously
              showSuccessModal(
                  context,
                  "Ha ocurrido un error al actualizar favoritos.",
                  Icons8.alert);
            } else {
              // ignore: use_build_context_synchronously
              AwesomeDialog(
                width: 500,
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.rightSlide,
                title: 'Info',
                desc: isFavorite == 1
                    ? "Se ha quitado de favoritos"
                    : "Se ha agregado a favoritos",
                btnCancel: Container(),
                btnOkText: "Aceptar",
                btnOkColor: colors.colorGreen,
                btnCancelOnPress: () {},
                btnOkOnPress: () {
                  _getProductModelCatalog();
                  Navigator.pop(context);
                },
              ).show();
            }
            //
          } else {
            //create new
            var responseNew = await Connections().createProductSeller(
                int.parse(product.productId.toString()),
                int.parse(userIdComercialMasterSeller.toString()),
                "favorite");
            // print("responseNew: $responseNew");
            if (responseNew == 1 || responseNew == 2) {
              print('Error Created new');
              // ignore: use_build_context_synchronously
              showSuccessModal(context,
                  "Ha ocurrido un error al agregar a favoritos.", Icons8.alert);
            } else {
              // ignore: use_build_context_synchronously
              AwesomeDialog(
                width: 500,
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.rightSlide,
                title: 'Info',
                desc: "Se ha agregado exitosamente a favoritos",
                btnCancel: Container(),
                btnOkText: "Aceptar",
                btnOkColor: colors.colorGreen,
                btnCancelOnPress: () {},
                btnOkOnPress: () {
                  _getProductModelCatalog();
                  Navigator.pop(context);
                },
              ).show();
            }
          }
          //
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: ColorsSystem().colorStore, // Borde con color personalizado
            width: 2, // Ancho del borde
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Opcional: Bordes redondeados
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFavorite == 1 ? Icons.favorite : Icons.favorite_outline,
              size: 12,
              color: isFavorite == 1
                  ? ColorsSystem().colorStore
                  : ColorsSystem().colorStore,
            ),
          ],
        ));
  }

  ElevatedButton _buttonAddOnsale(ProductModel product, int isOnSale,
      String labelIsOnSale, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        //Onsale
        // var userId = sharedPrefs!.getString("id");
        // print(userId);
        var userIdComercialMasterSeller =
            sharedPrefs!.getString("idComercialMasterSeller");

        if (isOnSale != 3) {
          //existe el registro, need upt
          //update
          var response = await Connections().getProductSeller(
              int.parse(product.productId.toString()),
              int.parse(userIdComercialMasterSeller.toString()));

          // print(response['id']);

          var responseUpt =
              await Connections().updateProductSeller(response['id'], {
            "onsale": isOnSale == 1 ? 0 : 1,
          });

          // print(responseUpt);

          if (responseUpt == 1 || responseUpt == 2) {
            print('Error update new');
            // ignore: use_build_context_synchronously
            showSuccessModal(context,
                "Ha ocurrido un error al actualizar En venta.", Icons8.alert);
          } else {
            // ignore: use_build_context_synchronously
            AwesomeDialog(
              width: 500,
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              title: 'Información',
              desc: isOnSale == 1
                  ? "Se ha quitado de En venta"
                  : "El ID: ${product.productId} del producto ${product.productName} ha sido copiado con éxito. Péguelo en EasyShop para importar los productos a su tienda en Shopify.",
              btnCancel: Container(),
              btnOkText: "Aceptar",
              btnOkColor: colors.colorGreen,
              btnCancelOnPress: () {},
              btnOkOnPress: () {
                if (isOnSale != 1) {
                  Clipboard.setData(
                      ClipboardData(text: "${product.productId}"));

                  Get.snackbar(
                    'COPIADO',
                    'Copiado al Clipboard',
                  );
                }
                _getProductModelCatalog();
                Navigator.pop(context);
              },
            ).show();
          }
          //
        } else {
          //create new
          var responseNew = await Connections().createProductSeller(
              int.parse(product.productId.toString()),
              int.parse(userIdComercialMasterSeller.toString()),
              "onsale");
          // print("responseNew: $responseNew");
          if (responseNew == 1 || responseNew == 2) {
            print('Error Created new');
            // ignore: use_build_context_synchronously
            showSuccessModal(context,
                "Ha ocurrido un error al agregar a En venta.", Icons8.alert);
          } else {
            // ignore: use_build_context_synchronously
            AwesomeDialog(
              width: 500,
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.rightSlide,
              title: 'Información',
              desc:
                  "El ID: ${product.productId} del producto ${product.productName} ha sido copiado con éxito. Péguelo en EasyShop para importar los productos a su tienda en Shopify.",
              btnCancel: Container(),
              btnOkText: "Aceptar",
              btnOkColor: colors.colorGreen,
              btnCancelOnPress: () {},
              btnOkOnPress: () {
                if (isOnSale != 1) {
                  Clipboard.setData(
                      ClipboardData(text: "${product.productId}"));

                  Get.snackbar(
                    'COPIADO',
                    'Copiado al Clipboard',
                  );
                }
                setState(() {});
                Navigator.pop(context);
              },
            ).show();
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(
          color: ColorsSystem().colorSelected, // Borde con color personalizado
          width: 2, // Ancho del borde
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10), // Opcional: Bordes redondeados
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.file_download_outlined,
              size: 24,
              color: ColorsSystem().colorSelected,
            ),
            const SizedBox(width: 5),
            Text(
              labelIsOnSale,
              style: TextStylesSystem().ralewayStyle(
                  16, FontWeight.w500, ColorsSystem().colorSelected),
            ),
          ],
        ),
      ),
    );
  }

  // ! mobile onSaleButton

  Container _buttonAddOnsaleMobile(ProductModel product, int isOnSale,
      String labelIsOnSale, BuildContext context) {
    return Container(
      height: 40,
      width: 132,
      child: ElevatedButton(
        onPressed: () async {
          var userIdComercialMasterSeller =
              sharedPrefs!.getString("idComercialMasterSeller");

          if (isOnSale != 3) {
            var response = await Connections().getProductSeller(
                int.parse(product.productId.toString()),
                int.parse(userIdComercialMasterSeller.toString()));
            var responseUpt =
                await Connections().updateProductSeller(response['id'], {
              "onsale": isOnSale == 1 ? 0 : 1,
            });

            if (responseUpt == 1 || responseUpt == 2) {
              print('Error update new');
              // ignore: use_build_context_synchronously
              showSuccessModal(context,
                  "Ha ocurrido un error al actualizar En venta.", Icons8.alert);
            } else {
              // ignore: use_build_context_synchronously
              AwesomeDialog(
                width: 500,
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.rightSlide,
                title: 'Información',
                desc: isOnSale == 1
                    ? "Se ha quitado de En venta"
                    : "El ID: ${product.productId} del producto ${product.productName} ha sido copiado con éxito. Péguelo en EasyShop para importar los productos a su tienda en Shopify.",
                btnCancel: Container(),
                btnOkText: "Aceptar",
                btnOkColor: colors.colorGreen,
                btnCancelOnPress: () {},
                btnOkOnPress: () {
                  if (isOnSale != 1) {
                    Clipboard.setData(
                        ClipboardData(text: "${product.productId}"));

                    Get.snackbar(
                      'COPIADO',
                      'Copiado al Clipboard',
                    );
                  }
                  _getProductModelCatalog();
                  Navigator.pop(context);
                },
              ).show();
            }
            //
          } else {
            //create new
            var responseNew = await Connections().createProductSeller(
                int.parse(product.productId.toString()),
                int.parse(userIdComercialMasterSeller.toString()),
                "onsale");
            // print("responseNew: $responseNew");
            if (responseNew == 1 || responseNew == 2) {
              print('Error Created new');
              // ignore: use_build_context_synchronously
              showSuccessModal(context,
                  "Ha ocurrido un error al agregar a En venta.", Icons8.alert);
            } else {
              // ignore: use_build_context_synchronously
              AwesomeDialog(
                width: 500,
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.rightSlide,
                title: 'Información',
                desc:
                    "El ID: ${product.productId} del producto ${product.productName} ha sido copiado con éxito. Péguelo en EasyShop para importar los productos a su tienda en Shopify.",
                btnCancel: Container(),
                btnOkText: "Aceptar",
                btnOkColor: colors.colorGreen,
                btnCancelOnPress: () {},
                btnOkOnPress: () {
                  if (isOnSale != 1) {
                    Clipboard.setData(
                        ClipboardData(text: "${product.productId}"));

                    Get.snackbar(
                      'COPIADO',
                      'Copiado al Clipboard',
                    );
                  }
                  setState(() {});
                  Navigator.pop(context);
                },
              ).show();
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color:
                ColorsSystem().colorSelected, // Borde con color personalizado
            width: 2, // Ancho del borde
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Opcional: Bordes redondeados
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.file_download_outlined,
              size: 12,
              color: ColorsSystem().colorSelected,
            ),
            const SizedBox(width: 3),
            Text(
              labelIsOnSale,
              style: TextStylesSystem().ralewayStyle(
                  10, FontWeight.w500, ColorsSystem().colorSelected),
            ),
          ],
        ),
      ),
    );
  }

  // ! new

  _modelTextField({text, controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Color de fondo
        borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
      ),
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // loadData();
          _getProductModelCatalog();
        },
        style: TextStylesSystem()
            .ralewayStyle(14, FontWeight.w500, ColorsSystem().colorSection2),
        textAlign: TextAlign.left, // Centra el texto
        decoration: InputDecoration(
          fillColor: Colors.white, // Color de fondo del campo
          // filled: true, // Asegura que el color de fondo se aplique
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.clear();
                      // loadData();
                    });
                    _getProductModelCatalog();
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          // focusColor: Color(0xFFE8DEF8),
          iconColor: ColorsSystem().colorSection2,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Esquinas redondeadas
            borderSide: BorderSide.none, // Elimina los bordes
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Sin borde
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Sin borde al estar enfocado
          ),
        ),
      ),
    );
  }

  // ! old

  String getProviderPhoneModel(dynamic warehouses) {
    String phone = "";
    List<WarehouseModel>? warehousesList = warehouses;
    if (warehousesList != null && warehousesList.isNotEmpty) {
      WarehouseModel firstWarehouse = warehousesList.first;
      phone = "${firstWarehouse.provider?.phone}";
    }
    return phone;
  }

  Future<void> sendWhatsAppMessage(BuildContext context, String phoneNumber,
      String productName, String idProduct) async {
    if (phoneNumber != "") {
      var message =
          "Hola, soy ususario de la paltaforma EasyEcommerce estoy interesado en vender tu producto: $productName-$idProduct";
      var whatsappUrl =
          "https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeFull(message)}";

      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        throw Exception('Could not launch $whatsappUrl');
      }
    } else {
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'El Proveedor no posee un número de Contacto Establecido',
        // desc: '',
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        // btnCancelOnPress: () {},
        btnOkOnPress: () async {
          Navigator.pop(context);
        },
      ).show();
    }
  }

  Future<dynamic> filtersDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Outer dialog rounding
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return ClipRRect(
                // Ensure clipping of child elements to the border
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  // padding: EdgeInsets.all(16.0), // Add padding
                  width: MediaQuery.of(context).size.width * 0.50,
                  height: MediaQuery.of(context).size.height < 800
                      ? MediaQuery.of(context).size.height * 0.60
                      : MediaQuery.of(context).size.height * 0.45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: _leftWidgetMobile(context, setState),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _leftWidgetMobile(BuildContext context, setState) {
    return Column(
      children: [
        AppBar(
          title: Text(
            "Filtros",
            style: TextStylesSystem().ralewayStyle(
              14,
              FontWeight.bold,
              ColorsSystem().colorLabels,
            ),
          ),
          iconTheme: IconThemeData(
            color: ColorsSystem().colorLabels,
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        Expanded(
          child: ClipRRect(
            // Clip the internal sections as well
            // borderRadius: BorderRadius.circular(20.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorsSystem().colorInitialContainer,
                          // borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0),topRight: Radius.circular(20.0) ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                            color: ColorsSystem().colorSection,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0))),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: 8,
                  right: 8,
                  height: MediaQuery.of(context).size.height == 600
                      ? MediaQuery.of(context).size.height * 0.65
                      : MediaQuery.of(context).size.height * 0.55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bodega",
                        style: TextStylesSystem().ralewayStyle(
                          12,
                          FontWeight.w700,
                          ColorsSystem().colorLabels,
                        ),
                      ),
                      SizedBox(height: 10),
                      _selectWarehosuesMobile(context, 0, setState),
                      SizedBox(height: 10),
                      Text(
                        "Categorías",
                        style: TextStylesSystem().ralewayStyle(
                          12,
                          FontWeight.w700,
                          ColorsSystem().colorLabels,
                        ),
                      ),
                      SizedBox(height: 10),
                      _selectCategoriesMobile(context, 0, setState),
                      SizedBox(height: 10),
                      Text(
                        "Tipo",
                        style: TextStylesSystem().ralewayStyle(
                          12,
                          FontWeight.w700,
                          ColorsSystem().colorLabels,
                        ),
                      ),
                      SizedBox(height: 10),
                      _selectTypeMobile(context, 0, setState),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _getProductModelCatalog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorsSystem()
                                    .colorSelected, // Color del botón
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      5), // Bordes redondeados
                                ),
                              ),
                              child: Text("Agregar Filtros",
                                  style: TextStylesSystem().ralewayStyle(
                                      12, FontWeight.w500, Colors.white))),
                          ElevatedButton(
                              onPressed: () {
                                _resetFilter();
                                Navigator.pop(context);
                                _getProductModelCatalog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.red[400], // Color del botón
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      5), // Bordes redondeados
                                ),
                              ),
                              child: Text("Quitar Filtros",
                                  style: TextStylesSystem().ralewayStyle(
                                      12, FontWeight.w500, Colors.white)))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
