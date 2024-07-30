import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:blurry_modal_progress_hud/blurry_modal_progress_hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/product_seller.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/reserve_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/sellers/catalog/product_report.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/product/product_add_order.dart';
import 'package:frontend/ui/widgets/product/product_card.dart';
import 'package:frontend/ui/widgets/product/product_carousel.dart';
import 'package:frontend/ui/widgets/product/show_img.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

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
  int currentPage = 1;
  int pageSize = 1500;
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
  var sortFieldDefaultValue = "product_id:asc";
  TextEditingController _search = TextEditingController(text: "");

  //
  List<String> warehousesToSelect = [];
  List<String> providersToSelect = [];
  String? selectedProvider;

  String? selectedWarehouse;
  // List<String> categoriesToSelect = UIUtils.categories();
  List<String> categoriesToSelect = [];

  List<String> selectedCategoriesList = [];
  String? selectedCategory;
  double _startValue = 0.0;
  double _endValue = 0.0;
  RangeValues _currentRangeValues = const RangeValues(1, 1000);
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  bool isSelectedFavorites = false;
  bool isSelectedOnSale = false;
  List<String> selectedKeyList = [];

  int total = 0;
  var getReport = ProductReport();

  bool isSelectedOwn = false;
  int idUser = int.parse(sharedPrefs!.getString("id").toString());

  List<String> typeToSelect = ["TODO", "SIMPLE", "VARIABLE"];
  String? selectedType;

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
      isLoading = false;
    });
    // return _productController.products;
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    // print(screenWidth);

    double textSize = screenWidth > 600 ? 16 : 12;
    double iconSize = screenWidth > 600 ? 70 : 25;

    return Scaffold(
        body: Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: [
              responsive(
                  // web,
                  Container(
                    width: screenWidth,
                    height: screenHeight,
                    // color: Colors.green,
                    child: Row(
                      children: [
                        _filtersWeb(screenWidth, context),
                        _catalog(screenWidth, screenHeight),
                      ],
                    ),
                  ),
                  // mobile,
                  // Text("mobile Version "),
                  Column(
                    children: [
                      _filtersMovil(screenWidth, screenHeight),
                      _catalogMovil(screenWidth, screenHeight)
                    ],
                  ),
                  context),
            ],
          ),
        )
      ],
    ));
  }

  Expanded _catalog(double screenWidth, double screenHeight) {
    return Expanded(
      flex: 8,
      // flex: screenWidth > 600 ? 8 : 10,
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          // color: Colors.deepPurple[300],
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                width: screenWidth * 0.4,
                color: Colors.white,
                padding: const EdgeInsets.all(0),
                child: Row(
                  children: [
                    Expanded(
                      child: _modelTextField(
                        text: "Buscar",
                        controller: _search,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text("Registros: ${products.length.toString()}"),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                  // color: Colors.indigo[300],
                  color: Colors.white,
                  padding: const EdgeInsets.all(10.0),
                  child: CustomProgressModal(
                    isLoading: isLoading,
                    content: SizedBox(
                      height: screenHeight * 0.75,
                      child: GridView.builder(
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 7 / 10,
                        ),
                        itemBuilder: (context, index) {
                          ProductModel product = products[index];
                          return ProductCard(
                            product: product,
                            onTapCallback: (context) => _showProductInfo(
                              context,
                              product,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _catalogMovil(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth,
      // color: Colors.deepPurple[300],
      color: Colors.white,
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _modelTextField(
                  text: "Buscar",
                  controller: _search,
                ),
              ),
              const SizedBox(width: 20),
              Text("Registros: ${products.length.toString()}"),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: screenWidth * 0.95,
                height: screenHeight * 0.50,
                color: Colors.white,
                // padding: const EdgeInsets.all(10.0),
                child: CustomProgressModal(
                  isLoading: isLoading,
                  content: SizedBox(
                    height: screenHeight * 0.75,
                    child: SizedBox(
                      height: screenHeight * 0.6,
                      child: GridView.builder(
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 6 / 10,
                        ),
                        itemBuilder: (context, index) {
                          ProductModel product = products[index];
                          return ProductCard(
                            product: product,
                            onTapCallback: (context) => _showProductInfo(
                              context,
                              product,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container _filtersWeb(double screenWidth, BuildContext context) {
    return Container(
      width: screenWidth * 0.20,
      // color: Colors.lightBlue[100],
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.010),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: GoogleFonts.robotoCondensed(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).hintColor,
              ),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _resetFilter();
                  _getProductModelCatalog();
                });
              },
              child: const Row(
                children: [
                  Icon(Icons.clear),
                  SizedBox(width: 5),
                  Text('Limpiar Filtros'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            //
            Text(
              // 'Proveedor',
              'Bodega',
              style: GoogleFonts.robotoCondensed(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            // _selectProvider(),
            _selectWarehosues(),
            //
            const SizedBox(height: 20),
            //
            Text(
              'Categorias',
              style: GoogleFonts.robotoCondensed(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            _selectCategories(),
            const SizedBox(height: 5),
            Wrap(
              spacing: 5.0,
              runSpacing: 5.0,
              children: selectedCategoriesList.map<Widget>((category) {
                return Chip(
                  label: Text(category),
                  backgroundColor: Colors.blue[50],
                  onDeleted: () {
                    setState(() {
                      selectedCategoriesList.remove(category);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 5),
            Text(
              'Tipo',
              style: GoogleFonts.robotoCondensed(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            _selectType(),
            //
            const SizedBox(height: 20),
            //
            Text(
              "Precios",
              style: GoogleFonts.robotoCondensed(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mínimo:',
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}$')),
                          ],
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Máximo:',
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}$')),
                          ],
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        bool priceRangeExists = outFilter
                            .any((filter) => filter.containsKey("price_range"));
                        if (_minPriceController.text.isEmpty &&
                            _maxPriceController.text.isEmpty) {
                          // print(
                          //     "Ambos están vacíos.");
                          // Agrega un filtro vacío con la clave "price_range"
                          outFilter.add({"price_range": ""});
                        } else if (_minPriceController.text.isNotEmpty &&
                            _maxPriceController.text.isEmpty) {
                          if (double.parse(_minPriceController.text) > 0) {
                            // print(
                            //     "Añadir al filtro solo el mínimo");
                            if (priceRangeExists) {
                              // Elimina el filtro existente con la clave "price_range"
                              outFilter.removeWhere((filter) =>
                                  filter.containsKey("price_range"));
                            }

                            outFilter.add({
                              "price_range": "${_minPriceController.text}-"
                            });
                          } else {
                            if (priceRangeExists) {
                              outFilter.removeWhere((filter) =>
                                  filter.containsKey("price_range"));
                            }
                            // print(
                            //     "Error, es menor a 0");
                          }
                          //
                        } else if (_minPriceController.text.isEmpty &&
                            _maxPriceController.text.isNotEmpty) {
                          if (double.parse(_maxPriceController.text) > 0) {
                            // print(
                            //     "Añadir al filtro solo el máximo");
                            if (priceRangeExists) {
                              outFilter.removeWhere((filter) =>
                                  filter.containsKey("price_range"));
                            }

                            // Agrega el nuevo filtro con la clave "price_range"
                            outFilter.add({
                              "price_range": "-${_maxPriceController.text}"
                            });
                          } else {
                            if (priceRangeExists) {
                              outFilter.removeWhere((filter) =>
                                  filter.containsKey("price_range"));
                            }
                            // print(
                            //     "Error, es menor a 0");
                          }
                        } else if (_minPriceController.text.isNotEmpty &&
                            _maxPriceController.text.isNotEmpty) {
                          //
                          if (double.parse(_maxPriceController.text) >
                              double.parse(_minPriceController.text)) {
                            // print(
                            //     "Añadir ambos");
                            if (priceRangeExists) {
                              outFilter.removeWhere((filter) =>
                                  filter.containsKey("price_range"));
                            }

                            // Agrega el nuevo filtro con la clave "price_range"
                            outFilter.add({
                              "price_range":
                                  "${_minPriceController.text}-${_maxPriceController.text}"
                            });
                          } else {
                            if (priceRangeExists) {
                              outFilter.removeWhere((filter) =>
                                  filter.containsKey("price_range"));
                            }
                            // print(
                            //     "Error, el max es < a min");
                          }
                        }
                        //
                        _getProductModelCatalog();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[800],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Filtrar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            //
            const SizedBox(height: 30),
            //
            _buttonFavorites(),
            const SizedBox(height: 20),
            _buttonOnSale(),
            const SizedBox(height: 20),
            _buttonOwnProducts(),
            const SizedBox(height: 20),
            //
          ],
        ),
      ),
    );
  }

  Container _filtersMovil(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth,
      // color: Colors.blueGrey,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.020),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Filtros',
                style: GoogleFonts.robotoCondensed(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(width: 30),
              TextButton(
                onPressed: () async {
                  setState(() {
                    _resetFilter();
                    _getProductModelCatalog();
                  });
                },
                child: const Row(
                  children: [
                    Icon(Icons.clear),
                    SizedBox(width: 5),
                    Text('Limpiar Filtros'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // 'Proveedor',
                      'Bodega',
                      style: GoogleFonts.robotoCondensed(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // _selectProvider()
                    _selectWarehosues()
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categorias',
                      style: GoogleFonts.robotoCondensed(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _selectCategories()
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 5.0,
                      runSpacing: 5.0,
                      children: selectedCategoriesList.map<Widget>((category) {
                        return Chip(
                          label: Text(category),
                          backgroundColor: Colors.blue[50],
                          onDeleted: () {
                            setState(() {
                              selectedCategoriesList.remove(category);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // _priceRange(),
          Row(
            children: [
              _buttonFavorites(),
              const SizedBox(width: 10),
              _buttonOnSale(),
              const SizedBox(width: 10),
              _buttonOwnProducts()
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  DropdownButtonFormField _selectProvider() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      hint: Text(
        'Seleccione una opción',
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).hintColor,
        ),
      ),
      items: providersToSelect
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item == 'TODO' ? 'TODO' : '${item.split('-')[1]}',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ))
          .toList(),
      value: selectedProvider,
      onChanged: (value) {
        setState(() {
          selectedProvider = value;
        });
        if (value != 'TODO') {
          if (value is String) {
            arrayFiltersAnd = [];
            //{"/warehouses.provider_id": idProv}
            arrayFiltersAnd.add({
              "/warehouses.provider_id":
                  selectedProvider.toString().split("-")[0].toString()
            });
          }
        } else {
          arrayFiltersAnd = [];
        }
        setState(() {
          _getProductModelCatalog();
        });
      },
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  DropdownButtonFormField _selectWarehosues() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      hint: Text(
        'Seleccione una opción',
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).hintColor,
        ),
      ),
      items: warehousesToSelect
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item == 'TODO' ? 'TODO' : item.split('|')[1],
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ))
          .toList(),
      value: selectedWarehouse,
      onChanged: (value) {
        setState(() {
          selectedWarehouse = value;
        });

        // Si el valor es "TODO", eliminar todas las entradas "equals/warehouse_id"
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
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  DropdownButtonFormField _selectCategories() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      hint: Text(
        'Seleccione una categoria',
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).hintColor,
        ),
      ),
      items: categoriesToSelect
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item == 'TODO' ? 'TODO' : item.split('-')[0],
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ))
          .toList(),
      value: selectedCategory ?? 'TODO',
      onChanged: (value) {
        setState(() {
          selectedCategory = value;

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
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  DropdownButtonFormField _selectType() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      hint: Text(
        'Seleccione un Tipo',
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).hintColor,
        ),
      ),
      items: typeToSelect
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item == 'TODO' ? 'TODO' : item,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ))
          .toList(),
      value: selectedType ?? 'TODO',
      onChanged: (value) {
        setState(() {
          selectedType = value;

          if (value == 'TODO') {
            arrayFiltersAnd.removeWhere(
                (filter) => filter.containsKey("equals/isvariable"));
          } else {
            arrayFiltersAnd.removeWhere(
                (filter) => filter.containsKey("equals/isvariable"));
            arrayFiltersAnd
                .add({"equals/isvariable": selectedType == "SIMPLE" ? 0 : 1});
          }
          _getProductModelCatalog();
        });
      },
      decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
    );
  }

  Row _priceRange() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mínimo:',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}$')),
                  ],
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Máximo:',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}$')),
                  ],
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                bool priceRangeExists = outFilter
                    .any((filter) => filter.containsKey("price_range"));
                if (_minPriceController.text.isEmpty &&
                    _maxPriceController.text.isEmpty) {
                  // print(
                  //     "Ambos están vacíos.");
                  // Agrega un filtro vacío con la clave "price_range"
                  outFilter.add({"price_range": ""});
                } else if (_minPriceController.text.isNotEmpty &&
                    _maxPriceController.text.isEmpty) {
                  if (double.parse(_minPriceController.text) > 0) {
                    // print(
                    //     "Añadir al filtro solo el mínimo");
                    if (priceRangeExists) {
                      // Elimina el filtro existente con la clave "price_range"
                      outFilter.removeWhere(
                          (filter) => filter.containsKey("price_range"));
                    }

                    outFilter
                        .add({"price_range": "${_minPriceController.text}-"});
                  } else {
                    if (priceRangeExists) {
                      outFilter.removeWhere(
                          (filter) => filter.containsKey("price_range"));
                    }
                    // print(
                    //     "Error, es menor a 0");
                  }
                  //
                } else if (_minPriceController.text.isEmpty &&
                    _maxPriceController.text.isNotEmpty) {
                  if (double.parse(_maxPriceController.text) > 0) {
                    // print(
                    //     "Añadir al filtro solo el máximo");
                    if (priceRangeExists) {
                      outFilter.removeWhere(
                          (filter) => filter.containsKey("price_range"));
                    }

                    // Agrega el nuevo filtro con la clave "price_range"
                    outFilter
                        .add({"price_range": "-${_maxPriceController.text}"});
                  } else {
                    if (priceRangeExists) {
                      outFilter.removeWhere(
                          (filter) => filter.containsKey("price_range"));
                    }
                    // print(
                    //     "Error, es menor a 0");
                  }
                } else if (_minPriceController.text.isNotEmpty &&
                    _maxPriceController.text.isNotEmpty) {
                  //
                  if (double.parse(_maxPriceController.text) >
                      double.parse(_minPriceController.text)) {
                    // print(
                    //     "Añadir ambos");
                    if (priceRangeExists) {
                      outFilter.removeWhere(
                          (filter) => filter.containsKey("price_range"));
                    }

                    // Agrega el nuevo filtro con la clave "price_range"
                    outFilter.add({
                      "price_range":
                          "${_minPriceController.text}-${_maxPriceController.text}"
                    });
                  } else {
                    if (priceRangeExists) {
                      outFilter.removeWhere(
                          (filter) => filter.containsKey("price_range"));
                    }
                    // print(
                    //     "Error, el max es < a min");
                  }
                }
                //
                _getProductModelCatalog();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[800],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Filtrar",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ElevatedButton _buttonFavorites() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            isSelectedFavorites = !isSelectedFavorites;

            if (isSelectedFavorites) {
              selectedKeyList.add("favorite");
            } else {
              selectedKeyList.remove("favorite");
            }

            filterps.add({
              "id_master": int.parse(
                  sharedPrefs!.getString("idComercialMasterSeller").toString())
            });

            filterps.add({"key": selectedKeyList});
            _getProductModelCatalog();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelectedFavorites ? Colors.indigo[50] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(
              width: 1,
              color: Colors.indigo,
            ),
          ),
        ),
        child: responsive(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isSelectedFavorites ? Colors.indigo[50] : Colors.white,
                  ),
                  child: Icon(
                    isSelectedFavorites
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.indigo[900],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Favoritos',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              'Favoritos',
              style: GoogleFonts.robotoCondensed(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            context));
  }

  ElevatedButton _buttonOnSale() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            isSelectedOnSale = !isSelectedOnSale;
            if (isSelectedOnSale) {
              selectedKeyList.add("onsale");
            } else {
              selectedKeyList.remove("onsale");
            }

            filterps.add({
              "id_master": int.parse(
                  sharedPrefs!.getString("idComercialMasterSeller").toString())
            });

            filterps.add({"key": selectedKeyList});
            _getProductModelCatalog();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelectedOnSale ? Colors.indigo[50] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(
              width: 1,
              color: Colors.indigo,
            ),
          ),
        ),
        child: responsive(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelectedOnSale ? Colors.indigo[50] : Colors.white,
                  ),
                  child: Icon(
                    isSelectedOnSale
                        ? Icons.local_offer
                        : Icons.local_offer_outlined,
                    color: Colors.indigo[900],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'En Venta',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              'En Venta',
              style: GoogleFonts.robotoCondensed(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            context));
  }

  ElevatedButton _buttonOwnProducts() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            isSelectedOwn = !isSelectedOwn;
            // print("$isSelectedOwn");
            if (isSelectedOwn) {
              var idMaster =
                  sharedPrefs!.getString("idComercialMasterSeller").toString();
              print("add seller_owned");
              arrayFiltersAnd.removeWhere(
                  (filter) => filter.containsKey("equals/seller_owned"));
              arrayFiltersAnd.add({"equals/seller_owned": idMaster});
              setState(() {
                _getProductModelCatalog();
              });
            } else {
              print("remove seller_owned");

              arrayFiltersAnd.removeWhere(
                  (filter) => filter.containsKey("equals/seller_owned"));
              arrayFiltersAnd.add({"equals/seller_owned": null});
              setState(() {
                _getProductModelCatalog();
              });
            }
            // print(arrayFiltersAnd);
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelectedOwn ? Colors.indigo[50] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(
              width: 1,
              color: Colors.indigo,
            ),
          ),
        ),
        child: responsive(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelectedOwn ? Colors.indigo[50] : Colors.white,
                  ),
                  child: Icon(
                    isSelectedOwn ? Icons.home : Icons.home_outlined,
                    color: Colors.indigo[900],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Mis Productos',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              'Mis Productos',
              style: GoogleFonts.robotoCondensed(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            context));
  }

  _resetFilter() {
    selectedProvider = 'TODO';
    selectedWarehouse = "TODO";
    selectedCategory = 'TODO';
    selectedType = 'TODO';
    selectedCategoriesList = [];
    arrayFiltersAnd = [
      {"equals/seller_owned": null}
    ];
    outFilter = [];
    _minPriceController.clear();
    _maxPriceController.clear();
    isSelectedFavorites = false;
    isSelectedOnSale = false;
    isSelectedOwn = false;
    filterps = [];
  }

  Text _textTitle(String label) {
    TextStyle customTextStyleTitle = GoogleFonts.dmSerifDisplay(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    );

    return Text(
      label,
      style: customTextStyleTitle,
    );
  }

  Text _text(String label) {
    TextStyle customTextStyleText = GoogleFonts.dmSans(
      fontSize: 17,
      color: Colors.black,
    );
    return Text(
      label,
      style: customTextStyleText,
    );
  }

  String getFirstImgUrl(dynamic urlImgData) {
    List<String> urlsImgsList = (jsonDecode(urlImgData) as List).cast<String>();
    String url = urlsImgsList[0];
    return url;
  }

  void _showProductInfo(BuildContext context, ProductModel product) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<String> urlsImgsList = product.urlImg != null &&
            product.urlImg.isNotEmpty &&
            product.urlImg.toString() != "[]"
        ? (jsonDecode(product.urlImg) as List).cast<String>()
        : [];

    String selectedImage = urlsImgsList[0];

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
          UserModel? userSeller = reserve.user;
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

    print("G: ${product.stock.toString()}");
    print("R: ${reserveStock.toString()}");

    // print("isFavorite: $isFavorite");
    // print("isOnSale: $isOnSale");

    TextStyle customTextStyleTitle = GoogleFonts.dmSerifDisplay(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    );

    TextStyle customTextStyleText = GoogleFonts.dmSans(
      fontSize: 17,
      color: Colors.black,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          contentPadding: EdgeInsets.all(0),
          content: Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: int.parse(product.stock.toString()) > 0 ||
                            reserveStock > 0,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              ColorsSystem().colorPrincipalBrand,
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

                              Clipboard.setData(
                                  ClipboardData(text: variablesSkuId));

                              Get.snackbar(
                                'SKUs COPIADOS',
                                'Copiado al Clipboard',
                              );
                            } else {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      "${sku}C${product.productId.toString()}"));

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
                              Text(
                                product.isvariable == 1
                                    ? "Copiar SKUs"
                                    : "Copiar SKU",
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.copy_rounded),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Visibility(
                        visible: int.parse(product.stock.toString()) > 0 ||
                            reserveStock > 0,
                        child: Tooltip(
                          message: 'Descargar archivo CSV',
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Colors.green,
                              ),
                            ),
                            onPressed: () async {
                              getLoadingModal(context, true);
                              try {
                                // await getReport.generateExcelFileWithData(product);
                                if (product.isvariable == 1) {
                                  await getReport
                                      .generateCsvFileProductVariant(product);
                                } else {
                                  await getReport
                                      .generateCsvFileProductSimple(product);
                                }
                                Navigator.of(context).pop();
                              } catch (e) {
                                Navigator.of(context).pop();
                                print("error: $e");
                                SnackBarHelper.showErrorSnackBar(context,
                                    "Ha ocurrido un error al generar el reporte");
                              }
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.file_download_sharp),
                                SizedBox(width: 8),
                                Text(''),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                            child: Container(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: ListView(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _textTitle("Producto:"),
                                        const SizedBox(height: 5),
                                        RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: product.productName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey[800],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _textTitle(
                                            "Nombre a mostrar en la guia de envio:"),
                                        RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: guideName,
                                                style: customTextStyleText,
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _textTitle("ID:"),
                                            const SizedBox(width: 10),
                                            Text(
                                              product.productId.toString(),
                                              style: customTextStyleText,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _textTitle("SKU:"),
                                            const SizedBox(width: 10),
                                            Text(
                                              sku,
                                              style: customTextStyleText,
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
                                                        _textTitle(
                                                            "SKU Variables:"),
                                                      ],
                                                    ),
                                                    Text(
                                                      variablesSKU,
                                                      style:
                                                          customTextStyleText,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            _textTitle("Precio Bodega:"),
                                            const SizedBox(width: 10),
                                            Text(
                                              "\$${product.price}",
                                              style: customTextStyleText,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _textTitle("Precio Sugerido:"),
                                            const SizedBox(width: 10),
                                            _text(priceSuggested.isNotEmpty ||
                                                    priceSuggested != ""
                                                ? '\$$priceSuggested'
                                                : '')
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _textTitle("Tipo:"),
                                            const SizedBox(width: 10),
                                            _text(type)
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _textTitle("Stock general:"),
                                            const SizedBox(width: 10),
                                            _text("${product.stock}")
                                          ],
                                        ),
                                        Visibility(
                                          visible: reservesText != "",
                                          child: Row(
                                            children: [
                                              _textTitle("Mis Reservas:")
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: reservesText != "",
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [_text(reservesText)],
                                          ),
                                        ),
                                        Visibility(
                                          visible: product.isvariable == 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 10),
                                              _textTitle("Variables:"),
                                              Text(
                                                variablesQuantityText,
                                                style: customTextStyleText,
                                              ),
                                            ],
                                          ),
                                        ),
                                        _textTitle("Categorias:"),
                                        Text(
                                          categoriesText,
                                          style: customTextStyleText,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            _textTitle("Bodega:"),
                                            const SizedBox(width: 10),
                                            Flexible(
                                              child: _text(
                                                  getFirstWarehouseNameModel(
                                                          product.warehouses)
                                                      .split('-')[0]
                                                  // product.warehouse!.branchName
                                                  //   .toString()
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            _textTitle("Atención al cliente:"),
                                            const SizedBox(width: 10),
                                            _text(getFirstWarehouseNameModel(
                                                        product.warehouses)
                                                    .split('-')[1]
                                                // product.warehouse!
                                                //           .customerphoneNumber !=
                                                //       null
                                                //   ? product.warehouse!
                                                //       .customerphoneNumber
                                                //       .toString()
                                                //   : ""
                                                )
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        _textTitle("Descripción:"),
                                        Container(
                                          // width: 500,
                                          // color: Colors.purple.shade100,
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 15),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 1.0,
                                            ),
                                          ),
                                          height: 400,
                                          child: ListView(
                                            children: [
                                              Html(
                                                data: description,
                                                style: {
                                                  'p': Style(
                                                    fontSize: FontSize(16),
                                                    color: Colors.grey[800],
                                                    margin:
                                                        Margins.only(bottom: 0),
                                                  ),
                                                  'li': Style(
                                                    margin:
                                                        Margins.only(bottom: 0),
                                                  ),
                                                  'ol': Style(
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
                                const Text(
                                  "Producto:",
                                ),
                                Text(
                                  '${product.productName}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Nombre-guia de envio:',
                                ),
                                Text(
                                  guideName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text(
                                      "ID:",
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      product.productId.toString(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Descripción:",
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Html(
                                            data: description,
                                            style: {
                                              'p': Style(
                                                fontSize: FontSize(12),
                                                color: Colors.grey[800],
                                                margin: Margins.only(bottom: 0),
                                              ),
                                              'li': Style(
                                                margin: Margins.only(bottom: 0),
                                              ),
                                              'ol': Style(
                                                margin: Margins.only(bottom: 0),
                                              ),
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text(
                                      "SKU:",
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      sku,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Visibility(
                                  visible: product.isvariable == 1,
                                  child: const Row(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "SKU Variables:",
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: product.isvariable == 1,
                                  child: Row(
                                    children: [
                                      Text(
                                        variablesSKU,
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Precio Bodega:",
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "\$${product.price}",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text(
                                      "Precio Sugerido:",
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      priceSuggested.isNotEmpty ||
                                              priceSuggested != ""
                                          ? '\$$priceSuggested'
                                          : '',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text(
                                      "Tipo:",
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      type,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Text(
                                      "Stock general:",
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "${product.stock}",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Visibility(
                                  visible: reservesText != "",
                                  child: const Row(
                                    children: [
                                      Text(
                                        "Mis Reservas:",
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: reservesText != "",
                                  child: Row(
                                    children: [
                                      Text(
                                        reservesText,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Visibility(
                                  visible: product.isvariable == 1,
                                  child: const Row(
                                    children: [
                                      Text(
                                        "Variables:",
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: product.isvariable == 1,
                                  child: Row(
                                    children: [
                                      Text(
                                        variablesQuantityText,
                                      ),
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                                const Text(
                                  "Categorias:",
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  categoriesText,
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Bodega:",
                                ),
                                Text(getFirstWarehouseNameModel(
                                            product.warehouses)
                                        .split('-')[0]
                                    // product.warehouse!.branchName.toString(),
                                    ),
                                Row(
                                  children: [
                                    const Text(
                                      "Atención al cliente:",
                                    ),
                                    const SizedBox(width: 5),
                                    Text(getFirstWarehouseNameModel(
                                                product.warehouses)
                                            .split('-')[1]
                                        // product.warehouse!.customerphoneNumber !=
                                        //         null
                                        //     ? product
                                        //         .warehouse!.customerphoneNumber
                                        //         .toString()
                                        //     : "",
                                        ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      context),
                  const SizedBox(height: 20),
                  responsive(
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Visibility(
                            visible:
                                // (idUser == 2 || idUser == 188) &&
                                (int.parse(product.stock.toString()) > 0 ||
                                    reserveStock > 0),
                            child: _buttonCreateGuide(product, context),
                          ),
                          const SizedBox(width: 30),
                          _buttonAddFavorite(
                              product, isFavorite, labelIsFavorite, context),
                          const SizedBox(width: 30),
                          _buttonAddOnsale(
                              product, isOnSale, labelIsOnSale, context)
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Row(
                          //   children: [_buttonCreateGuide(product, context)],
                          // ),
                          // const SizedBox(height: 20),
                          Row(
                            children: [
                              _buttonAddFavorite(
                                  product, isFavorite, labelIsFavorite, context)
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buttonAddOnsale(
                                  product, isOnSale, labelIsOnSale, context)
                            ],
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
      String variantText = '$variantTitle\nCantidad: $inventoryQuantity\n';
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

  // Future<dynamic> showInfoProduct(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           //
  //           // return const AlertDialog(
  //           //   // shape: RoundedRectangleBorder(
  //           //   //     borderRadius: BorderRadius.all(Radius.circular(20.0))),
  //           //   contentPadding: EdgeInsets.all(0),
  //           //   content: AddOrderSellersLaravel(),
  //           // );
  //         },
  //       );
  //     },
  //   ).then((value) => setState(() {
  //         _getProductModelCatalog();
  //       }));
  // }

  addOrderDialog(ProductModel product) {
    double screenWidthDialog = MediaQuery.of(context).size.width;

    double screenWidth =
        screenWidthDialog > 600 ? screenWidthDialog * 0.40 : screenWidthDialog;

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return AlertDialog(
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: ProductAddOrder(
                product: product,
              ),
            );
          },
        );
        /*
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Container(
            // padding: EdgeInsets.all(20),
            width: screenWidth,
            child: ProductAddOrder(
              product: product,
            ),
          ),
        );
        */
      },
    ).then((value) {});
  }

  ElevatedButton _buttonCreateGuide(
      ProductModel product, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // var userId = sharedPrefs!.getString("id");
        addOrderDialog(product);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo[600],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Crear Guia",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          // const SizedBox(width: 5),
          // Icon(
          //   isFavorite == 1
          //       ? Icons.favorite
          //       : Icons.favorite_border,
          //   size: 24,
          //   color: Colors.white,
          // ),
        ],
      ),
    );
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
            showSuccessModal(context,
                "Ha ocurrido un error al actualizar favoritos.", Icons8.alert);
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
        backgroundColor: Colors.indigo[600],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelIsFavorite,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            isFavorite == 1 ? Icons.favorite : Icons.favorite_border,
            size: 24,
            color: Colors.white,
          ),
        ],
      ),
    );
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
        backgroundColor: Colors.indigo[800],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelIsOnSale,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 5),
          const Icon(
            Icons.copy_rounded,
            size: 24,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  _modelTextField({text, controller}) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          setState(() {
            _search.text = value;
          });
          _getProductModelCatalog();
        },
        decoration: InputDecoration(
          labelText: 'Buscar producto',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _search.clear();
                    });

                    _getProductModelCatalog();
                  },
                  child: const Icon(Icons.close))
              : null,
          hintText: text,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }
}
