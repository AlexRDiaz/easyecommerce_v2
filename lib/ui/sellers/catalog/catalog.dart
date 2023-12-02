import 'dart:convert';

import 'package:flutter/material.dart';
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
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
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
                          /*
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Bodega',
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
                                    items: warehousesToSelect
                                        .map((item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item == 'TODO'
                                                    ? 'TODO'
                                                    : '${item.split('-')[1]} - ${item.split('-')[2]}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    value: selectedWarehouse,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedWarehouse = value;
                                      });
                                      if (value != 'TODO') {
                                        if (value is String) {
                                          arrayFiltersAnd = [];
                                          arrayFiltersAnd.add({
                                            "warehouse.warehouse_id":
                                                selectedWarehouse
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
                          */
                          const SizedBox(width: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.2,
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
                                        items: categoriesToSelect
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
                                        value: selectedCategory,
                                        onChanged: (value) {
                                          selectedCategory = value;

                                          if (!selectedCategoriesList
                                              .contains(selectedCategory)) {
                                            setState(() {
                                              selectedCategoriesList
                                                  .add(selectedCategory!);
                                            });
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
                                    ])),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
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
                                    childAspectRatio: 1.8,
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

    String description = featuresList
        .where((feature) => feature.containsKey("description"))
        .map((feature) => feature["description"] as String)
        .firstWhere((element) => element.isNotEmpty, orElse: () => '');

    List<Map<String, dynamic>> variables = featuresList
        .where((feature) => feature.containsKey("variables"))
        .expand((feature) => (feature["variables"] as List<dynamic>)
            .cast<Map<String, dynamic>>())
        .toList();

// Construir una cadena de texto con detalles de variables
    String variablesText = variables.map((variable) {
      List<String> variableDetails = [];

      if (variable.containsKey('sku')) {
        variableDetails.add("SKU: ${variable['sku']}");
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
      if (variable.containsKey('price')) {
        variableDetails.add("Precio: ${variable['price']}");
      }

      return variableDetails.join('\n');
    }).join('\n\n');

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
                              child: Image.network(
                                "$generalServer${getFirstImgUrl(product.urlImg)}",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                          Flexible(
                                            child: Text(
                                              "${product.productName}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.grey[800],
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // Puedes ajustar según tus necesidades
                                              softWrap: true,
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
                                            "Precio:",
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
                                            "Existencia:",
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
                                            "Bodega:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
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
                                            product.isvariable == 1
                                                ? "VARIABLE"
                                                : "SIMPLE",
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                          backgroundColor: Colors.indigo[800],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Importar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 5),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
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
