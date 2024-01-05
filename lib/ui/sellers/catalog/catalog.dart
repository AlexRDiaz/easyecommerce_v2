import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/product_seller.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/reserve_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/product/product_card.dart';
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
  int pageSize = 70;
  int pageCount = 100;
  bool isLoading = false;
  bool isFirst = false;
  List populate = ["warehouse", "productseller", "reserve.seller"];
  List arrayFiltersOr = ["product_name", "stock", "price"];
  List arrayFiltersAnd = [];
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

  @override
  void initState() {
    super.initState();
    _productController = ProductController();
    _providerController = ProviderController();
    // _warehouseController = WrehouseController();
    getProviders();
    // getWarehouses();
    getCategories();
  }

  Future<List<ProductModel>> _getProductModelCatalog() async {
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
    return _productController.products;
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
      setState(() {
        providersToSelect.add('${provider.id}-${provider.name}');
      });
    }
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
          warehousesToSelect
              .add('${warehouse.id}-${warehouse.branchName}-${warehouse.city}');
        });
      }
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
            child: Container(
              color: Colors.grey[50],
              child: Container(
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.010,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'Filtros',
                                  style: GoogleFonts.robotoCondensed(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      selectedProvider = 'TODO';
                                      selectedCategory = 'TODO';
                                      selectedCategoriesList = [];
                                      arrayFiltersAnd = [];
                                      outFilter = [];
                                      _minPriceController.clear();
                                      _maxPriceController.clear();
                                      isSelectedFavorites = false;
                                      isSelectedOnSale = false;
                                      filterps = [];
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
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Proveedor',
                                            style: GoogleFonts.robotoCondensed(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            hint: Text(
                                              'Seleccione una opción',
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            ),
                                            items: providersToSelect
                                                .map((item) => DropdownMenuItem(
                                                      value: item,
                                                      child: Text(
                                                        item == 'TODO'
                                                            ? 'TODO'
                                                            : '${item.split('-')[1]}',
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
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
                                                  arrayFiltersAnd.add({
                                                    "warehouse.provider_id":
                                                        selectedProvider
                                                            .toString()
                                                            .split("-")[0]
                                                            .toString()
                                                  });
                                                }
                                              } else {
                                                arrayFiltersAnd = [];
                                              }
                                            },
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            hint: Text(
                                              'Seleccione una categoria',
                                              style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            ),
                                            items: categoriesToSelect
                                                .map((item) => DropdownMenuItem(
                                                      value: item,
                                                      child: Text(
                                                        item == 'TODO'
                                                            ? 'TODO'
                                                            : item
                                                                .split('-')[0],
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color:
                                                              Theme.of(context)
                                                                  .hintColor,
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
                                                      .contains(selectedCategory
                                                          ?.split('-')[0])) {
                                                    setState(() {
                                                      selectedCategoriesList
                                                          .add(selectedCategory!
                                                              .split('-')[0]
                                                              .toString());
                                                    });
                                                  }

                                                  bool categoryRangeExists =
                                                      outFilter.any((filter) =>
                                                          filter.containsKey(
                                                              "input_categories"));
                                                  if (!categoryRangeExists) {
                                                    outFilter.add({
                                                      "input_categories":
                                                          selectedCategoriesList
                                                    });
                                                  }
                                                } else {
                                                  outFilter.removeWhere((filter) =>
                                                      filter.containsKey(
                                                          "input_categories"));
                                                }
                                              });
                                            },
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                            ),
                                          ),
                                          /*
                                            DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              hint: Text(
                                                'Seleccione la categoria',
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                ),
                                              ),
                                              items: [
                                                'TODO',
                                                ...categoriesToSelect
                                              ]
                                                  .map((item) =>
                                                      DropdownMenuItem(
                                                        value: item,
                                                        child: Text(
                                                          item,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            color: Theme.of(
                                                                    context)
                                                                .hintColor,
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
                                                        .contains(
                                                            selectedCategory)) {
                                                      setState(() {
                                                        selectedCategoriesList.add(
                                                            selectedCategory!);
                                                      });
                                                    }

                                                    bool categoryRangeExists =
                                                        outFilter.any((filter) =>
                                                            filter.containsKey(
                                                                "input_categories"));
                                                    if (!categoryRangeExists) {
                                                      outFilter.add({
                                                        "input_categories":
                                                            selectedCategoriesList
                                                      });
                                                    }
                                                  } else {
                                                    outFilter.removeWhere(
                                                        (filter) =>
                                                            filter.containsKey(
                                                                "input_categories"));
                                                  }
                                                });
                                                //
                                              },
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                            ),
                                            */
                                          const SizedBox(height: 5),
                                          Wrap(
                                            spacing: 5.0,
                                            runSpacing: 5.0,
                                            children: selectedCategoriesList
                                                .map<Widget>((category) {
                                              return Chip(
                                                label: Text(category),
                                                backgroundColor:
                                                    Colors.blue[50],
                                                onDeleted: () {
                                                  setState(() {
                                                    selectedCategoriesList
                                                        .remove(category);
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
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.18,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Precios",
                                                        style: GoogleFonts
                                                            .robotoCondensed(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                        ),
                                                      )
                                                    ]),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Mínimo:',
                                                            style: GoogleFonts
                                                                .robotoCondensed(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 3),
                                                          SizedBox(
                                                            width: 100,
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  _minPriceController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              inputFormatters: <TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .allow(RegExp(
                                                                        r'^\d+\.?\d{0,2}$')),
                                                              ],
                                                              /*
                                                                inputFormatters: <TextInputFormatter>[
                                                                    FilteringTextInputFormatter.digitsOnly,
                                                                  ],
                                                                */
                                                              decoration:
                                                                  InputDecoration(
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
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
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Máximo:',
                                                            style: GoogleFonts
                                                                .robotoCondensed(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 3),
                                                          SizedBox(
                                                            width: 100,
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  _maxPriceController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              inputFormatters: <TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .allow(RegExp(
                                                                        r'^\d+\.?\d{0,2}$')),
                                                              ],
                                                              decoration:
                                                                  InputDecoration(
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                filled: true,
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
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
                                                            bool
                                                                priceRangeExists =
                                                                outFilter.any(
                                                                    (filter) =>
                                                                        filter.containsKey(
                                                                            "price_range"));
                                                            if (_minPriceController
                                                                    .text
                                                                    .isEmpty &&
                                                                _maxPriceController
                                                                    .text
                                                                    .isEmpty) {
                                                              // print(
                                                              //     "Ambos están vacíos.");
                                                              // Agrega un filtro vacío con la clave "price_range"
                                                              outFilter.add({
                                                                "price_range":
                                                                    ""
                                                              });
                                                            } else if (_minPriceController
                                                                    .text
                                                                    .isNotEmpty &&
                                                                _maxPriceController
                                                                    .text
                                                                    .isEmpty) {
                                                              if (double.parse(
                                                                      _minPriceController
                                                                          .text) >
                                                                  0) {
                                                                // print(
                                                                //     "Añadir al filtro solo el mínimo");
                                                                if (priceRangeExists) {
                                                                  // Elimina el filtro existente con la clave "price_range"
                                                                  outFilter.removeWhere(
                                                                      (filter) =>
                                                                          filter
                                                                              .containsKey("price_range"));
                                                                }

                                                                outFilter.add({
                                                                  "price_range":
                                                                      "${_minPriceController.text}-"
                                                                });
                                                              } else {
                                                                if (priceRangeExists) {
                                                                  outFilter.removeWhere(
                                                                      (filter) =>
                                                                          filter
                                                                              .containsKey("price_range"));
                                                                }
                                                                // print(
                                                                //     "Error, es menor a 0");
                                                              }
                                                              //
                                                            } else if (_minPriceController
                                                                    .text
                                                                    .isEmpty &&
                                                                _maxPriceController
                                                                    .text
                                                                    .isNotEmpty) {
                                                              if (double.parse(
                                                                      _maxPriceController
                                                                          .text) >
                                                                  0) {
                                                                // print(
                                                                //     "Añadir al filtro solo el máximo");
                                                                if (priceRangeExists) {
                                                                  outFilter.removeWhere(
                                                                      (filter) =>
                                                                          filter
                                                                              .containsKey("price_range"));
                                                                }

                                                                // Agrega el nuevo filtro con la clave "price_range"
                                                                outFilter.add({
                                                                  "price_range":
                                                                      "-${_maxPriceController.text}"
                                                                });
                                                              } else {
                                                                if (priceRangeExists) {
                                                                  outFilter.removeWhere(
                                                                      (filter) =>
                                                                          filter
                                                                              .containsKey("price_range"));
                                                                }
                                                                // print(
                                                                //     "Error, es menor a 0");
                                                              }
                                                            } else if (_minPriceController
                                                                    .text
                                                                    .isNotEmpty &&
                                                                _maxPriceController
                                                                    .text
                                                                    .isNotEmpty) {
                                                              //
                                                              if (double.parse(
                                                                      _maxPriceController
                                                                          .text) >
                                                                  double.parse(
                                                                      _minPriceController
                                                                          .text)) {
                                                                // print(
                                                                //     "Añadir ambos");
                                                                if (priceRangeExists) {
                                                                  outFilter.removeWhere(
                                                                      (filter) =>
                                                                          filter
                                                                              .containsKey("price_range"));
                                                                }

                                                                // Agrega el nuevo filtro con la clave "price_range"
                                                                outFilter.add({
                                                                  "price_range":
                                                                      "${_minPriceController.text}-${_maxPriceController.text}"
                                                                });
                                                              } else {
                                                                if (priceRangeExists) {
                                                                  outFilter.removeWhere(
                                                                      (filter) =>
                                                                          filter
                                                                              .containsKey("price_range"));
                                                                }
                                                                // print(
                                                                //     "Error, el max es < a min");
                                                              }
                                                            }
                                                            //
                                                          });
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors
                                                                  .indigo[800],
                                                        ),
                                                        child: const Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "Filtrar",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
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
                                    )
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isSelectedFavorites =
                                                    !isSelectedFavorites;

                                                if (isSelectedFavorites) {
                                                  selectedKeyList
                                                      .add("favorite");
                                                } else {
                                                  selectedKeyList
                                                      .remove("favorite");
                                                }

                                                filterps.add({
                                                  "id_master": int.parse(
                                                      sharedPrefs!
                                                          .getString(
                                                              "idComercialMasterSeller")
                                                          .toString())
                                                });

                                                filterps.add(
                                                    {"key": selectedKeyList});
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  isSelectedFavorites
                                                      ? Colors.indigo[50]
                                                      : Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                side: const BorderSide(
                                                  width: 1,
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isSelectedFavorites
                                                        ? Colors.indigo[50]
                                                        : Colors.white,
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
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          /*
                                            ChoiceChip(
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                    child: Icon(
                                                      isSelectedFavorites
                                                          ? Icons.favorite
                                                          : Icons
                                                              .favorite_border,
                                                      color: Colors.indigo[900],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'Seleccionar Favoritos',
                                                    style: GoogleFonts
                                                        .robotoCondensed(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              selected: isSelectedFavorites,
                                              onSelected: (selected) {
                                                setState(() {
ra                                                  // print("clck Favoritos");
                                                  isSelectedFavorites =
                                                      selected;

                                                  if (isSelectedOnSale) {
                                                    selectedKeyList
                                                        .add("onsale");
                                                  } else {
                                                    selectedKeyList
                                                        .remove("onsale");
                                                  }

                                                  if (isSelectedFavorites) {
                                                    selectedKeyList
                                                        .add("favorite");
                                                  } else {
                                                    selectedKeyList
                                                        .remove("favorite");
                                                  }
                                                  filterps.add({
                                                    "id_master": int.parse(
                                                        sharedPrefs!
                                                            .getString(
                                                                "idComercialMasterSeller")
                                                            .toString())
                                                  });

                                                  filterps.add(
                                                      {"key": selectedKeyList});
                                                  //
                                                });
                                              },
                                              selectedColor: Colors.indigo[50],
                                              backgroundColor: Colors.white,
                                              shape: const StadiumBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: Colors.indigo),
                                              ),
                                            ),
                                            */
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                isSelectedOnSale =
                                                    !isSelectedOnSale;
                                                if (isSelectedOnSale) {
                                                  selectedKeyList.add("onsale");
                                                } else {
                                                  selectedKeyList
                                                      .remove("onsale");
                                                }

                                                filterps.add({
                                                  "id_master": int.parse(
                                                      sharedPrefs!
                                                          .getString(
                                                              "idComercialMasterSeller")
                                                          .toString())
                                                });

                                                filterps.add(
                                                    {"key": selectedKeyList});
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isSelectedOnSale
                                                  ? Colors.indigo[50]
                                                  : Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                side: const BorderSide(
                                                  width: 1,
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isSelectedOnSale
                                                        ? Colors.indigo[50]
                                                        : Colors.white,
                                                  ),
                                                  child: Icon(
                                                    isSelectedOnSale
                                                        ? Icons.local_offer
                                                        : Icons
                                                            .local_offer_outlined,
                                                    color: Colors.indigo[900],
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'En Venta',
                                                  style: GoogleFonts
                                                      .robotoCondensed(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
/*
                                            ChoiceChip(
                                              label: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                    child: Icon(
                                                      isSelectedOnSale
                                                          ? Icons.local_offer
                                                          : Icons
                                                              .local_offer_outlined,
                                                      color: Colors.indigo[900],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    'Seleccionar En Venta',
                                                    style: GoogleFonts
                                                        .robotoCondensed(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              selected: isSelectedOnSale,
                                              onSelected: (selected) {
                                                setState(() {
                                                  filterps = [];
                                                  // print("clck Favoritos");
                                                  isSelectedOnSale = selected;
                                                  //

                                                  if (isSelectedOnSale) {
                                                    selectedKeyList
                                                        .add("onsale");
                                                  } else {
                                                    selectedKeyList
                                                        .remove("onsale");
                                                  }

                                                  if (isSelectedFavorites) {
                                                    selectedKeyList
                                                        .add("favorite");
                                                  } else {
                                                    selectedKeyList
                                                        .remove("favorite");
                                                  }
                                                  filterps.add({
                                                    "id_master": int.parse(
                                                        sharedPrefs!
                                                            .getString(
                                                                "idComercialMasterSeller")
                                                            .toString())
                                                  });

                                                  filterps.add(
                                                      {"key": selectedKeyList});
                                                  //
                                                });

                                                //
                                              },
                                              selectedColor: Colors.indigo[50],
                                              backgroundColor: Colors.white,
                                              shape: const StadiumBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: Colors.indigo),
                                              ),
                                            ),
                                            */
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 50),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 8,
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Row(
                                  children: [
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
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Container(
                                    width: screenWidth * 0.78,
                                    color: Colors.white,
                                    padding: const EdgeInsets.all(10.0),
                                    child: FutureBuilder(
                                      future: _getProductModelCatalog(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                                'Error al cargar los productos'),
                                          );
                                        } else {
                                          List<ProductModel> products =
                                              snapshot.data ?? [];
                                          return SizedBox(
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
                                                ProductModel product =
                                                    products[index];
                                                return ProductCard(
                                                  product: product,
                                                  onTapCallback: (context) =>
                                                      _showProductInfo(
                                                    context,
                                                    product,
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
          if (i < reservesList.length - 1) {
            reservesText += "\n\n";
          }
        } else {
          print("Existen reservas pero NO de este userMaster");
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

    if (product.isvariable == 1) {
      List<Map<String, dynamic>>? variants =
          (features["variants"] as List<dynamic>).cast<Map<String, dynamic>>();

      variablesText = variants!.map((variable) {
        List<String> variableDetails = [];

        // if (variable.containsKey('sku')) {
        //   variableDetails.add("SKU: ${variable['sku']}");
        // }
        if (variable.containsKey('sku')) {
          variablesSKU += "${variable['sku']}\n";
        }
        if (variable.containsKey('color')) {
          variableDetails.add("Color: ${variable['color']}");
        }
        if (variable.containsKey('size')) {
          variableDetails.add("Talla: ${variable['size']}");
        }
        if (variable.containsKey('dimension')) {
          variableDetails.add("Tamaño: ${variable['dimension']}");
        }
        if (variable.containsKey('inventory_quantity')) {
          variableDetails.add("Cantidad: ${variable['inventory_quantity']}");
        }
        // if (variable.containsKey('price')) {
        //   variableDetails.add("Precio: ${variable['price']}");
        // }

        return variableDetails.join('\n');
      }).join('\n\n');
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
          // title: AppBar(
          //   title: const Text(
          //     "Detalles del Producto",
          //     style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 16,
          //     ),
          //   ),
          //   backgroundColor: Colors.blue[900],
          //   leading: Container(),
          //   centerTitle: true,
          // ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(0.0), // Establece el radio del borde a 0
          ),
          content: Container(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: ShowImages(urlsImgsList: urlsImgsList),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Producto:",
                                            style: customTextStyleTitle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Nombre a mostrar en la guia de envio:',
                                            style: customTextStyleTitle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "ID:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            product.productId.toString(),
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Descripción:",
                                            style: customTextStyleTitle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                            fontSize: FontSize(16),
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
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "SKU:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            sku,
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                              "SKU Variables:",
                                              style: customTextStyleTitle,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          variablesSKU,
                                          style: customTextStyleText,
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Precio Bodega:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "\$${product.price}",
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Precio Sugerido:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            priceSuggested.isNotEmpty ||
                                                    priceSuggested != ""
                                                ? '\$$priceSuggested'
                                                : '',
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Tipo:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            type,
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Stock general:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${product.stock}",
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Visibility(
                              visible: reservesText != "",
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              "Mis Reservas:",
                                              style: customTextStyleTitle,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: reservesText != "",
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
                                              reservesText,
                                              style: customTextStyleText,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                                              "Variables:",
                                              style: customTextStyleTitle,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          variablesText,
                                          style: customTextStyleText,
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Categorias:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            categoriesText,
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Bodega:",
                                            style: customTextStyleTitle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            product.warehouse!.branchName
                                                .toString(),
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Atención al cliente:",
                                            style: customTextStyleText,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            product.warehouse!
                                                        .customerphoneNumber !=
                                                    null
                                                ? product.warehouse!
                                                    .customerphoneNumber
                                                    .toString()
                                                : "",
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
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
                                int.parse(
                                    userIdComercialMasterSeller.toString()));

                            print(response['id']);

                            var responseUpt = await Connections()
                                .updateProductSeller(response['id'], {
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
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ).show();
                            }
                            //
                          } else {
                            //create new
                            var responseNew = await Connections()
                                .createProductSeller(
                                    int.parse(product.productId.toString()),
                                    int.parse(
                                        userIdComercialMasterSeller.toString()),
                                    "favorite");
                            print("responseNew: $responseNew");
                            if (responseNew == 1 || responseNew == 2) {
                              print('Error Created new');
                              // ignore: use_build_context_synchronously
                              showSuccessModal(
                                  context,
                                  "Ha ocurrido un error al agregar a favoritos.",
                                  Icons8.alert);
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
                                  setState(() {});
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
                              isFavorite == 1
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 24,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      ElevatedButton(
                        onPressed: () async {
                          //Onsale
                          // var userId = sharedPrefs!.getString("id");
                          // print(userId);
                          var userIdComercialMasterSeller =
                              sharedPrefs!.getString("idComercialMasterSeller");

                          if (isFavorite != 3) {
                            //existe el registro, need upt
                            //update
                            var response = await Connections().getProductSeller(
                                int.parse(product.productId.toString()),
                                int.parse(
                                    userIdComercialMasterSeller.toString()));

                            print(response['id']);

                            var responseUpt = await Connections()
                                .updateProductSeller(response['id'], {
                              "onsale": isOnSale == 1 ? 0 : 1,
                            });

                            // print(responseUpt);

                            if (responseUpt == 1 || responseUpt == 2) {
                              print('Error update new');
                              // ignore: use_build_context_synchronously
                              showSuccessModal(
                                  context,
                                  "Ha ocurrido un error al actualizar En venta.",
                                  Icons8.alert);
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
                                    Clipboard.setData(ClipboardData(
                                        text: "${product.productId}"));

                                    Get.snackbar(
                                      'COPIADO',
                                      'Copiado al Clipboard',
                                    );
                                  }
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ).show();
                              // Clipboard.setData(
                              //     ClipboardData(text: "${product.productId}"));

                              // Get.snackbar(
                              //   'COPIADO',
                              //   'Copiado al Clipboard',
                              // );

                              // // ignore: use_build_context_synchronously
                              // return showDialog(
                              //     context: context,
                              //     builder: (context) {
                              //       return AlertDialog(
                              //         content: SizedBox(
                              //           width: screenWidth * 0.25,
                              //           height: screenHeight * 0.20,
                              //           child: Expanded(
                              //               child: Column(
                              //             children: [
                              //               const Text(
                              //                 "Información",
                              //                 style: TextStyle(
                              //                   fontSize: 20,
                              //                   color: Colors.black,
                              //                   fontWeight: FontWeight.bold,
                              //                 ),
                              //               ),
                              //               const SizedBox(height: 10),
                              //               RichText(
                              //                 text: TextSpan(
                              //                   children: <TextSpan>[
                              //                     TextSpan(
                              //                       text:
                              //                           'El ID: "${product.productId}" del producto "${product.productName}" ha sido copiado con éxito. Péguelo en EasyShop para importar los productos a su tienda en Shopify.',
                              //                       style: const TextStyle(
                              //                         fontSize: 18,
                              //                         color: Colors.black,
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ],
                              //           )),
                              //         ),
                              //       );
                              //     }).then((value) => setState(() {
                              //       _getProductModelCatalog(); // Actualiza el Future
                              //     }));
                            }
                            //
                          } else {
                            //create new
                            var responseNew = await Connections()
                                .createProductSeller(
                                    int.parse(product.productId.toString()),
                                    int.parse(
                                        userIdComercialMasterSeller.toString()),
                                    "onsale");
                            print("responseNew: $responseNew");
                            if (responseNew == 1 || responseNew == 2) {
                              print('Error Created new');
                              // ignore: use_build_context_synchronously
                              showSuccessModal(
                                  context,
                                  "Ha ocurrido un error al agregar a En venta.",
                                  Icons8.alert);
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
                                    Clipboard.setData(ClipboardData(
                                        text: "${product.productId}"));

                                    Get.snackbar(
                                      'COPIADO',
                                      'Copiado al Clipboard',
                                    );
                                  }
                                  setState(() {});
                                  Navigator.pop(context);
                                },
                              ).show();

                              // Clipboard.setData(
                              //     ClipboardData(text: "${product.productId}"));

                              // Get.snackbar(
                              //   'COPIADO',
                              //   'Copiado al Clipboard',
                              // );

                              // // ignore: use_build_context_synchronously
                              // return showDialog(
                              //     context: context,
                              //     builder: (context) {
                              //       return AlertDialog(
                              //         content: SizedBox(
                              //           width: screenWidth * 0.25,
                              //           height: screenHeight * 0.20,
                              //           child: Expanded(
                              //               child: Column(
                              //             children: [
                              //               const Text(
                              //                 "Información",
                              //                 style: TextStyle(
                              //                   fontSize: 20,
                              //                   color: Colors.black,
                              //                   fontWeight: FontWeight.bold,
                              //                 ),
                              //               ),
                              //               const SizedBox(height: 10),
                              //               RichText(
                              //                 text: TextSpan(
                              //                   children: <TextSpan>[
                              //                     TextSpan(
                              //                       text:
                              //                           'El ID: "${product.productId}" del producto "${product.productName}" ha sido copiado con éxito. Péguelo en EasyShop para importar los productos a su tienda en Shopify.',
                              //                       style: const TextStyle(
                              //                         fontSize: 18,
                              //                         color: Colors.black,
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ],
                              //           )),
                              //         ),
                              //       );
                              //     }).then((value) => setState(() {
                              //       _getProductModelCatalog(); // Actualiza el Future
                              //     }));
                            }
                          }
                          //
                          // var userIdComercialMasterSeller =
                          //     sharedPrefs!.getString("idComercialMasterSeller");
                          // print(userIdComercialMasterSeller);
                          // print(product.productId);
/*
                          var response = await Connections().getProductSeller(
                              int.parse(product.productId.toString()),
                              int.parse(
                                  userIdComercialMasterSeller.toString()));
                          print("response: $response");

                          if (response == 1 || response['onsale'] == null) {
                            print('No existe');
                            //create new
                            var responseNew = await Connections()
                                .createProductSeller(
                                    int.parse(product.productId.toString()),
                                    int.parse(
                                        userIdComercialMasterSeller.toString()),
                                    "onsale");
                            print("responseNew: $responseNew");
                            if (responseNew == 1 || responseNew == 2) {
                              print('Error Created new');
                              // ignore: use_build_context_synchronously
                              showSuccessModal(
                                  context,
                                  "Ha ocurrido un error al agregar a favoritos.",
                                  Icons8.alert);
                            } else {
                              Clipboard.setData(
                                  ClipboardData(text: "${product.productId}"));

                              Get.snackbar(
                                'COPIADO',
                                'Copiado al Clipboard',
                              );

                              // ignore: use_build_context_synchronously
                              return showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: SizedBox(
                                        width: screenWidth * 0.25,
                                        height: screenHeight * 0.20,
                                        child: Expanded(
                                            child: Column(
                                          children: [
                                            const Text(
                                              "Información",
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        'El ID: "${product.productId}" del producto "${product.productName}" ha sido copiado con éxito. Péguelo en EasyShop para importar los productos a su tienda en Shopify.',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )),
                                      ),
                                    );
                                  }).then((value) => setState(() {
                                    _getProductModelCatalog(); // Actualiza el Future
                                  }));
                              print('Created new');
                            }
                          } else if (response == 2) {
                            print('Error: Status Code 2');
                            //maybe show succesful dialog
                          } else {
                            //update
                            var responseUpt = await Connections()
                                .updateProductSeller(response['id'], {
                              "favorite": 1,
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
                              showSuccessModal(
                                  context,
                                  "Se ha agregado actualizado correctamente",
                                  Icons8.alert);
                              print('Updated ');
                            }
                          }
                          */
                          //
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -5);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
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
        },
        decoration: InputDecoration(
          labelText: 'Buscar producto',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _search.clear();
                      arrayFiltersAnd = [];
                    });
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
