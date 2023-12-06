import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/product/product_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';

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
  List populate = ["warehouse"];
  List arrayFiltersOr = ["product_name", "stock", "price"];
  List arrayFiltersAnd = [];
  List outFilter = [];
  var sortFieldDefaultValue = "product_id:DESC";
  TextEditingController _search = TextEditingController(text: "");

  //
  List<String> warehousesToSelect = [];
  List<String> providersToSelect = [];
  String? selectedProvider;

  String? selectedWarehouse;
  List<String> categoriesToSelect = UIUtils.categories();

  List<String> selectedCategoriesList = [];
  String? selectedCategory;
  double _startValue = 0.0;
  double _endValue = 0.0;
  RangeValues _currentRangeValues = const RangeValues(1, 1000);
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  bool isSelectedFavorites = false;
  int total = 0;

  @override
  void initState() {
    super.initState();
    _productController = ProductController();
    _providerController = ProviderController();
    // _warehouseController = WrehouseController();
    getProviders();
    // getWarehouses();
  }

  Future<List<ProductModel>> _getProductModelCatalog() async {
    await _productController.loadProductsCatalog(
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        outFilter,
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

    double textSize = screenWidth > 600 ? 16 : 12;
    double iconSize = screenWidth > 600 ? 70 : 25;
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(6.0),
                  padding:
                      EdgeInsets.symmetric(horizontal: (screenWidth * 0.15)),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.15,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Proveedor',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      'Seleccione una opcion',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    items: providersToSelect
                                        .map((item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item == 'TODO'
                                                    ? 'TODO'
                                                    : '${item.split('-')[1]}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
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
                                            "warehouse.provider.provider_id":
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
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: screenWidth * 0.1,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Categorias',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        hint: Text(
                                          'Seleccione la categoria',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).hintColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        items: ['TODO', ...categoriesToSelect]
                                            .map((item) => DropdownMenuItem(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                  .contains(selectedCategory)) {
                                                setState(() {
                                                  selectedCategoriesList
                                                      .add(selectedCategory!);
                                                });
                                              }

                                              bool priceRangeExists =
                                                  outFilter.any((filter) =>
                                                      filter.containsKey(
                                                          "input_categories"));
                                              if (!priceRangeExists) {
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
                                          //
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
                                      const SizedBox(height: 5),
                                      Wrap(
                                        spacing: 8.0,
                                        runSpacing: 8.0,
                                        children: selectedCategoriesList
                                            .map<Widget>((category) {
                                          return Chip(
                                            label: Text(category),
                                            backgroundColor: Colors.blue[50],
                                            onDeleted: () {
                                              setState(() {
                                                selectedCategoriesList
                                                    .remove(category);
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ])),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.18,
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
                                          const Text('Precio Min:'),
                                          const SizedBox(height: 3),
                                          SizedBox(
                                            width: 100,
                                            child: TextFormField(
                                              controller: _minPriceController,
                                              keyboardType:
                                                  TextInputType.number,
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
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Precio Max:'),
                                          const SizedBox(height: 3),
                                          SizedBox(
                                            width: 100,
                                            child: TextFormField(
                                              controller: _maxPriceController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'^\d+\.?\d{0,2}$')),
                                              ],
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
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (_maxPriceController
                                              .text.isNotEmpty) {
                                            print("No esta vacio");

                                            if (double.parse(
                                                    _maxPriceController.text) >
                                                double.parse(
                                                    _minPriceController.text)) {
                                              print("Añadir al filtro");

                                              // Agregar a filtro
                                              setState(() {
                                                bool priceRangeExists =
                                                    outFilter.any((filter) =>
                                                        filter.containsKey(
                                                            "price_range"));
                                                if (!priceRangeExists) {
                                                  outFilter.add({
                                                    "price_range":
                                                        "${_minPriceController.text}-${_maxPriceController.text}",
                                                  });
                                                }
                                              });
                                            } else {
                                              print("Max < Min");
                                            }
                                          } else {
                                            print("Add en filter solo el min ");
                                          }
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
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ChoiceChip(
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: Icon(
                                            isSelectedFavorites
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.indigo[900],
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        const Text('Seleccionar Favoritos'),
                                      ],
                                    ),
                                    selected: isSelectedFavorites,
                                    onSelected: (selected) {
                                      setState(() {
                                        isSelectedFavorites = selected;
                                      });
                                    },
                                    selectedColor: Colors.indigo[50],
                                    backgroundColor: Colors.white,
                                    shape: const StadiumBorder(
                                      side: BorderSide(
                                          width: 1, color: Colors.indigo),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
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
                          Expanded(child: Container()),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                                      text: "Buscar", controller: _search),
                                ),
                              ],
                            ),
                          ),
                          // Container(
                          //   width: screenWidth * 0.15,
                          //   padding: const EdgeInsets.only(left: 15, right: 5),
                          //   child: Text(
                          //     "Registros encontrados: ${total}",
                          //     style: TextStyle(
                          //         fontWeight: FontWeight.bold,
                          //         color: Colors.grey[500]),
                          //   ),
                          // ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      //
                      Expanded(
                        child: FutureBuilder(
                          future: _getProductModelCatalog(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Error al cargar los productos'));
                            } else {
                              List<ProductModel> products = snapshot.data ?? [];
                              return Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: GridView.builder(
                                  itemCount: products.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    // childAspectRatio: 1.8,
                                  ),
                                  itemBuilder: (context, index) {
                                    ProductModel product = products[index];
                                    return ProductCard(
                                      product: product,
                                      onTapCallback: (context) =>
                                          _showProductInfo(context, product),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      //
                    ],
                  ),
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
    var features = jsonDecode(product.features);

    List<Map<String, dynamic>> featuresList =
        features.cast<Map<String, dynamic>>();

    List<String> categories = featuresList
        .where((feature) => feature.containsKey("categories"))
        .expand((feature) =>
            (feature["categories"] as List<dynamic>).cast<String>())
        .toList();
    String categoriesText = categories.join(', ');

    String guideName = featuresList
        .where((feature) => feature.containsKey("guide_name"))
        .map((feature) => feature["guide_name"] as String)
        .firstWhere((element) => element.isNotEmpty, orElse: () => '');

    String priceSuggested = featuresList
        .where((feature) => feature.containsKey("price_suggested"))
        .map((feature) => feature["price_suggested"] as String)
        .firstWhere((element) => element.isNotEmpty, orElse: () => '');

    String sku = featuresList
        .where((feature) => feature.containsKey("sku"))
        .map((feature) => feature["sku"] as String)
        .firstWhere((element) => element.isNotEmpty, orElse: () => '');

    String description = featuresList
        .where((feature) => feature.containsKey("description"))
        .map((feature) => feature["description"] as String)
        .firstWhere((element) => element.isNotEmpty, orElse: () => '');
    String type = featuresList
        .where((feature) => feature.containsKey("type"))
        .map((feature) => feature["type"] as String)
        .firstWhere((element) => element.isNotEmpty, orElse: () => '');

    String variablesSKU = "";
    String variablesText = "";

    if (product.isvariable == 1) {
      List<Map<String, dynamic>> variables = featuresList
          .where((feature) => feature.containsKey("variables"))
          .expand((feature) => (feature["variables"] as List<dynamic>)
              .cast<Map<String, dynamic>>())
          .toList();

// Construir una cadena de texto con detalles de variables
      variablesText = variables.map((variable) {
        List<String> variableDetails = [];

        // if (variable.containsKey('sku')) {
        //   variableDetails.add("SKU: ${variable['sku']}");
        // }
        if (variable.containsKey('sku')) {
          variablesSKU += "${variable['sku']}\n"; // Acumula las SKU
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
        if (variable.containsKey('inventory')) {
          variableDetails.add("Cantidad: ${variable['inventory']}");
        }
        // if (variable.containsKey('price')) {
        //   variableDetails.add("Precio: ${variable['price']}");
        // }

        return variableDetails.join('\n');
      }).join('\n\n');
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: AppBar(
            title: const Text(
              "Detalles del Producto",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.blue[900],
            leading: Container(),
            centerTitle: true,
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
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: product.urlImg != null &&
                                      product.urlImg.isNotEmpty &&
                                      product.urlImg.toString() != "[]"
                                  ? Image.network(
                                      "$generalServer${getFirstImgUrl(product.urlImg)}",
                                      fit: BoxFit.fill,
                                    )
                                  : Container(), // Contenedor vacío si product.urlImg es nulo o vacío
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
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
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
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
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Nombre a mostrar en la guia de envio:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
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
                                            guideName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
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
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "ID:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            product.productId.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
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
                            const Row(
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
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
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
                                          Expanded(
                                            child: Html(
                                              data: description,
                                              style: {
                                                'p': Style(
                                                    fontSize: FontSize(16),
                                                    color: Colors.grey[800]),
                                              },
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
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "SKU:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            sku,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
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
                            Visibility(
                              visible: product.isvariable == 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Text(
                                              "SKU Variables:",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          variablesSKU,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
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
                                          const Text(
                                            "Precio Bodega:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "\$${product.price}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
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
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "Precio Sugerido:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            priceSuggested.isNotEmpty ||
                                                    priceSuggested != ""
                                                ? '\$$priceSuggested'
                                                : '',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
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
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "Tipo:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            type,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
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
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            "Stock general:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${product.stock}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
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
                            Visibility(
                              visible: product.isvariable == 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Text(
                                              "Variables:",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          variablesText,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
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
                                          const Text(
                                            "Categorias:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            categoriesText,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
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
                            const Row(
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
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
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
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
                                            ),
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
                                          const Text(
                                            "Numero de telefono atención al cliente:",
                                            style: TextStyle(
                                              // fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            product.warehouse!.city.toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[800],
                                            ),
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
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[600],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Agregar a favoritos",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[800],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Adquirir",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
