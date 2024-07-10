import 'dart:convert';
import 'dart:math';

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
import 'package:frontend/models/reserve_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/html_editor.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProduct extends StatefulWidget {
  final Map data;
  final bool specialOwn;
  // final Function function;
  final Function(dynamic) hasEdited;
  // final List? data;

  const EditProduct(
      {super.key,
      required this.hasEdited,
      required this.data,
      required this.specialOwn});
  // const ProductDetails({super.key});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  String codigo = "";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameGuideController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String createdAt = "";
  String warehouseValue = "";
  String img_url = "";
  var typeValue;
  var descripcion;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _inventaryController = TextEditingController();
  var data = {};
  List<dynamic> dataL = [];
  List<Map<String, dynamic>> listaProduct = [];
  // List<String> listCategories = UIUtils.categories();
  List<String> listCategories = [];

  var selectedCat;
  late Map<String, dynamic> dataFeatures;
  late ProductController _productController;

  List<String> urlsImgsList = [];
  int isVariable = 0;
  int approved = 0;
  late WrehouseController _warehouseController;
  List<WarehouseModel> warehousesList = [];
  List<String> warehousesToSelect = [];
  String variablesText = "";
  //multi img show temp
  List<XFile> imgsTemporales = [];
  String stock = "";
  final TextEditingController _priceSuggestedController =
      TextEditingController();
  String skuOriginal = "";
  List<String> selectedCategories = [];
  List optionsTypesOriginal = [];
  List variantsListOriginal = [];
//
  List<String> types = UIUtils.typesProduct();
  List<String> typesVariables = UIUtils.typesVariables();
  String? selectedType;
  String? selectedVariable;
  String? chosenColor;
  String? chosenSize;
  String? chosenDimension;
  List<String> sizesToSelect = [];
  List<String> colorsToSelect = [];
  List<String> dimensionToSelect = [];
  List<String> urlsImgsListSaved = [];
  List<String> selectedColores = [];
  List<String> selectedSizes = [];
  List<String> selectedDimensions = [];
  List optionsTypesSend = [];
  List variantsListSend = [];
  List<String> selectedVariablesList = [];
  final TextEditingController _skuController = TextEditingController();
  int showStockTotal = 0;
  List<Map<String, List<String>>> optionsList = UIUtils.variablesToSelect();
  bool showToResetType = false;
  late List<dynamic> categoriesOriginal;
  List<Map<String, String>> selectedCategoriesMap = [];

  //edit variant stock
  bool showToEditStock = false;

  List<String> variantsToSelect = [];
  String? chosenVariant;
  final TextEditingController _inventoryVariantController =
      TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> variantsStockToUpt = [];
  List variantsListCopy = [];
  String variablesTextEdit = "";
  int stockOriginal = 0;

  String warehouseValueOriginal = "";

  String idProvUser = sharedPrefs!.getString("idProviderUserMaster").toString();
  String idUser = sharedPrefs!.getString("id").toString();
  int provType = 0;
  String specialProv = sharedPrefs!.getString("special").toString() == "null"
      ? "0"
      : sharedPrefs!.getString("special").toString();

  bool multiWarehouse = false;
  bool isown = false;
  int seller_owned = 0;
  List variantsListNoChanges = [];
  List<String> variantOriginLabels = [];

  String selectedImage = "";
  bool selectedTemp = false;

  @override
  void initState() {
    super.initState();
    _productController = ProductController();
    _warehouseController = WrehouseController();
    if (idProvUser == idUser) {
      provType = 1; //prov principal
    } else if (idProvUser != idUser) {
      provType = 2; //subprov
    }
    loadTextEdtingControllers(widget.data);

    getCategories();
    getWarehouses();
  }

  getWarehouses() async {
    await _warehouseController
        .loadWarehouses(sharedPrefs!.getString("idProvider").toString());
    warehousesList = _warehouseController.warehouses;
    for (var warehouse in warehousesList) {
      if (warehouse.approved == 1 && warehouse.active == 1) {
        warehousesToSelect
            .add('${warehouse.id}-${warehouse.branchName}-${warehouse.city}');
      }
    }

    // print("warehouseValue: $warehouseValue");
    // print("warehousesToSelect: $warehousesToSelect");
    setState(() {});
  }

  getCategories() async {
    List<dynamic> data = [];
    String jsonData = await rootBundle.loadString('assets/taxonomy3.json');
    data = json.decode(jsonData);

    for (var item in data) {
      var lastKey = item.keys.last;
      String menuItemLabel = "${item[lastKey]}-${item['id']}";
      listCategories.add(menuItemLabel);
    }
  }

  loadTextEdtingControllers(newData) {
    // print(newData);
    isown = widget.specialOwn;
    // print("isown: $isown");
    ProductModel product = ProductModel.fromJson(newData);
    codigo = product.productId.toString();
    _nameController.text = product.productName.toString();
    createdAt = UIUtils.formatDate(product.createdAt.toString());
    approved = product.approved!;
    _stockController.text = product.stock.toString();
    stockOriginal = int.parse(product.stock.toString());
    stock = product.stock.toString();
    isVariable = int.parse(product.isvariable.toString());
    typeValue = product.isvariable == 1 ? "VARIABLE" : "SIMPLE";
    _priceController.text = product.price.toString();
    seller_owned = product.sellerOwnedId ?? 0;

    // warehouseValue =
    //     '${product.warehouse!.id.toString()}-${product.warehouse!.branchName.toString()}-${product.warehouse!.city.toString()}';
    warehouseValue = getWarehouseNameModel(product.warehouses);
    warehouseValueOriginal = warehouseValue;

    urlsImgsList = product.urlImg != null &&
            product.urlImg.isNotEmpty &&
            product.urlImg.toString() != "[]"
        ? (jsonDecode(product.urlImg) as List).cast<String>()
        : [];
    //
    dataFeatures = jsonDecode(product.features);
    _nameGuideController.text = dataFeatures["guide_name"];
    _priceSuggestedController.text = dataFeatures["price_suggested"].toString();
    skuOriginal = dataFeatures["sku"];
    _skuController.text = dataFeatures["sku"];
    _descriptionController.text = dataFeatures["description"];
    categoriesOriginal = dataFeatures["categories"];

    // print(categoriesOriginal);

    categoriesOriginal = dataFeatures["categories"];

    selectedCategories = categoriesOriginal.map<String>((category) {
      return "${category['name']}-${category['id']}";
    }).toList();

    for (var selectedCat in selectedCategories) {
      List<String> parts = selectedCat.split('-');

      if (!selectedCategoriesMap
          .any((category) => category["id"] == parts[1])) {
        setState(() {
          selectedCategoriesMap.add({
            "id": parts[1],
            "name": parts[0],
          });
        });
      }
    }

    // print(selectedCategoriesMap);
    //no cambia si no cambia variables
    variantsListOriginal = dataFeatures["variants"];

    if (product.isvariable == 1) {
      optionsTypesOriginal = dataFeatures["options"];
      variantsListCopy = dataFeatures["variants"];
      // print(variantsListOriginal);
/*
      for (var variant in variantsListOriginal) {
        if (variant.containsKey('color')) {
          variantsToSelect.add('${variant["sku"]}-${variant["color"]}');
        }
        if (variant.containsKey('size')) {
          variantsToSelect.add('${variant["sku"]}-${variant["size"]}');
        }
        if (variant.containsKey('dimension')) {
          variantsToSelect.add('${variant["sku"]}-${variant["dimension"]}');
        }
        if (variant.containsKey('color') && variant.containsKey('size')) {
          variantsToSelect
              .add('${variant["sku"]}-${variant["size"]}-${variant["color"]}');
        }
        if (variant.containsKey('color') && variant.containsKey('dimension')) {
          variantsToSelect.add(
              '${variant["sku"]}-${variant["dimension"]}-${variant["color"]}');
        }
        // .add(
        //     '${variant["sku"]}-${variant["color"]}-${variant["inventory_quantity:"]}');
      }

      List<Map<String, dynamic>>? variants =
          (dataFeatures["variants"] as List<dynamic>)
              .cast<Map<String, dynamic>>();

      variablesText = variants.map((variable) {
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
        if (variable.containsKey('inventory_quantity')) {
          variableDetails.add("Cantidad: ${variable['inventory_quantity']}");
        }
        // if (variable.containsKey('price')) {
        //   variableDetails.add("Precio: ${variable['price']}");
        // }

        return variableDetails.join(';  ');
      }).join('\n');
*/
      //new version
      variantOriginLabels = [];

      for (var variant in variantsListOriginal) {
        List<String> valuesToConcatenate = [];

        // Agregar todos los valores excepto "id,sku,inventory_quantity,price"
        for (var entry in variant.entries) {
          if (entry.key != "id" &&
              entry.key != "sku" &&
              entry.key != "inventory_quantity" &&
              entry.key != "price") {
            valuesToConcatenate.add(entry.value.toString());
          }
        }

        // Unir los valores con /
        String concatenatedValues = valuesToConcatenate.join('/');

        variantOriginLabels.add(
            "${variant['sku']}; $concatenatedValues; Cantidad:${variant['inventory_quantity']}");

        variantsToSelect.add('${variant["sku"]}|$concatenatedValues');
      }

      variablesText = variantOriginLabels.join('\n');
    }

    sizesToSelect = optionsList[0]["sizes"]!;
    colorsToSelect = optionsList[1]["colors"]!;
    dimensionToSelect = optionsList[2]["dimensions"]!;
    // print("specialProv: $specialProv");
    // print("provType: $provType");
    // print("multiWarehouse: $multiWarehouse");

    print("variantsToSelect: $variablesText");

    if (seller_owned != 0) {
      print("IS seller_owned");
      int reserveStock = 0;
      List<ReserveModel>? reservesList = product.reserves;
      if (reservesList != null) {
        for (int i = 0; i < reservesList.length; i++) {
          ReserveModel reserve = reservesList[i];
          //
          reserveStock += int.parse(reserve.stock.toString());
          if (product.isvariable == 1) {
            for (int j = 0; j < variantOriginLabels.length; j++) {
              String skuV = variantOriginLabels[j].split(";")[0];
              String variantsV = variantOriginLabels[j].split(";")[1];
              // String quantityV = variantOriginLabels[j].split(";")[2];
              if (skuV == reserve.sku.toString()) {
                int newQuantity = int.parse(reserve.stock.toString());
                String updatedVariant =
                    "$skuV; $variantsV; Cantidad:${newQuantity.toString()}";
                variantOriginLabels[j] = updatedVariant;
                break;
              }
            }
            variablesText = variantOriginLabels.join('\n');

            for (var element in variantsListCopy) {
              if (element['sku'] == reserve.sku.toString()) {
                //
                element['inventory_quantity'] = (reserve.stock.toString());
              }
            }
          }
          //
        }
      }

      // print("reserveStock: $reserveStock");
      // print("variantsListCopy: $variantsListCopy");

      _stockController.text = reserveStock.toString();
      stockOriginal = int.parse(reserveStock.toString());
      stock = reserveStock.toString();
    }

    selectedImage = (urlsImgsList.isNotEmpty ? urlsImgsList[0] : null)!;
    setState(() {});
  }

  String getInventory(String sku) {
    String currentStock;
    for (var variant in variantsListOriginal) {
      if (variant["sku"] == sku) {
        currentStock = variant["inventory_quantity"];
        print('Stock act para SKU $sku: $currentStock unidades');
        return currentStock;
      }
    }
    print('SKU $sku no encontrado en la lista de variantes');
    return "0";
  }

  void updateInventory(String sku, String newStock) {
    for (var variant in variantsListOriginal) {
      if (variant["sku"] == sku) {
        variant["inventory_quantity"] = newStock;
        print('Stock upt para SKU $sku: $newStock unidades');
        return; // Terminar la función después de encontrar y actualizar la variante
      }
    }
    print('SKU $sku no encontrado en la lista de variantes');
  }

  String getWarehouseNameModel(dynamic warehouses) {
    String name = "";
    List<WarehouseModel>? warehousesList = warehouses;
    if (warehousesList!.length > 1) {
      multiWarehouse = true;
    }
    if (multiWarehouse && int.parse(specialProv.toString()) == 1) {
      WarehouseModel lastWarehouse = warehousesList.last;
      name =
          "${lastWarehouse.id.toString()}-${lastWarehouse.branchName.toString()}-${lastWarehouse.city.toString()}";
    } else {
      WarehouseModel firstWarehouse = warehousesList.first;
      name =
          "${firstWarehouse.id.toString()}-${firstWarehouse.branchName.toString()}-${firstWarehouse.city.toString()}";
    }

    return name;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.50;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeTitle = 16;
    double fontSizeText = 14;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(0.0), // Establece el radio del borde a 0
      ),
      title: AppBar(
        title: const Text(
          "Editar Producto",
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
          width: screenWidth,
          // width: 700,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            children: [
              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "ID:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeTitle,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: Text(
                              codigo,
                              style: TextStyle(
                                  fontSize: fontSizeText,
                                  color: Colors.grey[800]),
                            ),
                          ),
                          Text(
                            "Creado:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeTitle,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 200,
                            child: Text(createdAt,
                                style: TextStyle(
                                    fontSize: fontSizeText,
                                    color: Colors.grey[800])),
                          ),
                          Text(
                            "Aprobado:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeTitle,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: approved == 1
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Colors.green)
                                : approved == 2
                                    ? const Icon(Icons.hourglass_bottom_sharp,
                                        color: Colors.indigo)
                                    : const Icon(Icons.cancel_rounded,
                                        color: Colors.red),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Producto',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSizeTitle,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                TextFormField(
                                  controller: _nameController,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nombre para mostrar en la guia de envio:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSizeTitle,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                TextFormField(
                                  controller: _nameGuideController,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Precio Bodega",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSizeTitle,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 120,
                                      child: TextFormField(
                                        controller: _priceController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Precio Sugerido",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSizeTitle,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 120,
                                      child: TextFormField(
                                        controller: _priceSuggestedController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
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
                      const SizedBox(height: 20),
                      Visibility(
                        visible: !showToResetType,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: Row(
                                          children: [
                                            Text(
                                              "Tipo: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: fontSizeTitle,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              isVariable == 1
                                                  ? "VARIABLE"
                                                  : "SIMPLE",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Visibility(
                                        visible: isVariable == 1,
                                        child: Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text('Variables'),
                                              const SizedBox(height: 3),
                                              Text(
                                                variantsStockToUpt.isEmpty
                                                    ? variablesText
                                                    : variablesTextEdit,
                                                style: const TextStyle(
                                                  color: Colors.black,
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
                      ),
                      Visibility(
                        visible: (int.parse(specialProv.toString()) == 1 &&
                                multiWarehouse) ||
                            (int.parse(specialProv.toString()) != 1 &&
                                !multiWarehouse) ||
                            (int.parse(specialProv.toString()) == 1 && isown),
                        // visible: true,
                        child: Row(
                          children: [
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                //
                                setState(() {
                                  showToEditStock = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[300],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Editar Stock",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        // visible: typeValue == "VARIABLE",
                        visible: showToEditStock && typeValue == "VARIABLE",
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Variantes'),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    width: (screenWidth / 2) - 10,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      hint: Text(
                                        'Seleccione Variante',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      items: variantsToSelect.map((item) {
                                        return DropdownMenuItem(
                                          value: item,
                                          child: Text(
                                            item.split('|')[1].toString(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: chosenVariant,
                                      onChanged: (value) {
                                        setState(() {
                                          chosenVariant = value as String;
                                          // _inventoryVariantController
                                          //     .text = getInventory(
                                          //         chosenVariant!.split('-')[0])
                                          //     .toString();
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Visibility(
                        // visible:
                        //     typeValue == "VARIABLE" && chosenVariant != null,
                        visible: showToEditStock,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 125,
                              child: TextFieldWithIcon(
                                controller: _inventoryVariantController,
                                labelText: 'Unidades',
                                icon: Icons.numbers,
                                inputType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 350,
                              child: TextFieldWithIcon(
                                controller: _commentController,
                                labelText: 'Motivo',
                                maxLines: null,
                                icon: Icons.notes,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        // visible:
                        //     typeValue == "VARIABLE" && chosenVariant != null,
                        visible: showToEditStock,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                //
                                if (_inventoryVariantController.text == "" ||
                                    _commentController.text == "") {
                                  showSuccessModal(
                                      context,
                                      "Por favor, ingrese las unidades y el motivo.",
                                      Icons8.warning_1);
                                } else {
                                  if (isVariable == 1) {
                                    String skuVariant =
                                        chosenVariant.toString().split("|")[0];
                                    if (!variantsStockToUpt.any((category) =>
                                        category["sku"] == skuVariant)) {
                                      variantsStockToUpt.add({
                                        "sku": skuVariant,
                                        "units":
                                            _inventoryVariantController.text,
                                        "description": _commentController.text,
                                        "type": 1
                                      });

                                      updateInventoryBySku(
                                          skuVariant,
                                          int.parse(
                                              _inventoryVariantController.text),
                                          1);

                                      _inventoryVariantController.text = "";
                                      _commentController.text = "";
                                    } else {
                                      print(
                                          "ya existe este sku en list to upt");
                                    }
                                    calcuateStockTotalEsditVariants();
                                  } else {
                                    if (!variantsStockToUpt.any((category) =>
                                        category["sku"] == skuOriginal)) {
                                      variantsStockToUpt.add({
                                        "sku": skuOriginal,
                                        "units":
                                            _inventoryVariantController.text,
                                        "description": _commentController.text,
                                        "type": 1
                                      });
                                      int unitsN = int.parse(
                                          _inventoryVariantController.text);
                                      showStockTotal =
                                          int.parse(_stockController.text);
                                      showStockTotal += unitsN;
                                      print("showStockTotal: $showStockTotal");
                                      _stockController.text =
                                          showStockTotal.toString();

                                      _inventoryVariantController.text = "";
                                      _commentController.text = "";
                                    } else {
                                      print(
                                          "ya existe este sku en list to upt");
                                    }
                                  }

                                  // print(
                                  //     "variantsStockToUpt: $variantsStockToUpt");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF274965),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Agregar",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                //
                                if (_inventoryVariantController.text == "" ||
                                    _commentController.text == "") {
                                  showSuccessModal(
                                      context,
                                      "Por favor, ingrese las unidades y el motivo.",
                                      Icons8.warning_1);
                                } else {
                                  if (isVariable == 1) {
                                    String skuVariant =
                                        chosenVariant.toString().split("|")[0];
                                    if (!variantsStockToUpt.any((category) =>
                                        category["sku"] == skuVariant)) {
                                      variantsStockToUpt.add({
                                        "sku": skuVariant,
                                        "units":
                                            _inventoryVariantController.text,
                                        "description": _commentController.text,
                                        "type": 0
                                      });

                                      updateInventoryBySku(
                                          skuVariant,
                                          int.parse(
                                              _inventoryVariantController.text),
                                          0);

                                      _inventoryVariantController.text = "";
                                      _commentController.text = "";
                                    } else {
                                      print(
                                          "ya existe este sku en list to upt");
                                    }
                                    calcuateStockTotalEsditVariants();
                                  } else {
                                    if (!variantsStockToUpt.any((category) =>
                                        category["sku"] == skuOriginal)) {
                                      variantsStockToUpt.add({
                                        "sku": skuOriginal,
                                        "units":
                                            _inventoryVariantController.text,
                                        "description": _commentController.text,
                                        "type": 0
                                      });

                                      int unitsN = int.parse(
                                          _inventoryVariantController.text);

                                      showStockTotal =
                                          int.parse(_stockController.text);

                                      showStockTotal -= unitsN;
                                      print("showStockTotal: $showStockTotal");
                                      _stockController.text =
                                          showStockTotal.toString();

                                      _inventoryVariantController.text = "";
                                      _commentController.text = "";
                                    } else {
                                      print(
                                          "ya existe este sku en list to upt");
                                    }
                                  }

                                  print(
                                      "variantsStockToUpt: $variantsStockToUpt");
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Quitar",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Stock General:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSizeTitle,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 150,
                                      child: TextFormField(
                                        controller: _stockController,
                                        // enabled: isVariable == 0,
                                        enabled: false,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Categorias",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSizeTitle,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: (screenWidth / 1.5) - 10,
                                  child: DropdownButtonFormField<String>(
                                    hint:
                                        const Text("Seleccione una categoría"),
                                    value: selectedCat,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCat = value;
                                        List<String> parts =
                                            selectedCat!.split('-');

                                        if (!selectedCategoriesMap.any(
                                            (category) =>
                                                category["id"] == parts[1])) {
                                          setState(() {
                                            selectedCategoriesMap.add({
                                              "id": parts[1],
                                              "name": parts[0],
                                            });
                                          });
                                        }
                                      });
                                    },
                                    items:
                                        listCategories.map((String category) {
                                      var parts = category.split('-');
                                      var name = parts[0];
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(name),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                    ),
                                  ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: List.generate(
                                      selectedCategoriesMap.length, (index) {
                                    String categoryName =
                                        selectedCategoriesMap[index]["name"] ??
                                            "";

                                    return Chip(
                                      label: Text(categoryName),
                                      onDeleted: () {
                                        setState(() {
                                          selectedCategoriesMap.removeAt(index);
                                          // print("catAct: $selectedCategoriesMap");
                                        });
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Bodega:'),
                      Row(
                        children: [
                          SizedBox(
                            width: (screenWidth / 2) - 10,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              hint: Text(
                                'Seleccione Bodega',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              items: warehousesToSelect.map((item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    "${item.split('-')[1]}-${item.split('-')[2]}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                              value: warehouseValue,
                              onChanged: (value) {
                                setState(() {
                                  warehouseValue = value as String;
                                });
                                // print("warehouseValue: $warehouseValue");
                                // print(
                                //     "warehouseValueOriginal: $warehouseValueOriginal");
                              },
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                const Text('Descripción'),
                                const SizedBox(height: 5),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  padding: const EdgeInsets.all(8.0),
                                  height: 250,
                                  //  width: 600,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(color: Colors.black)),
                                  child: HtmlEditor(
                                    description: _descriptionController.text,
                                    getValue: getValue,
                                  ),
                                ),
                              ]))
                        ],
                      ),
                      const SizedBox(height: 15),
                      /*
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.green,
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final ImagePicker picker = ImagePicker();
                                    imgsTemporales = [];
                                    List<XFile>? imagenes =
                                        await picker.pickMultiImage();

                                    if (imagenes != null &&
                                        imagenes.isNotEmpty) {
                                      if (imagenes.length > 4) {
                                        // ignore: use_build_context_synchronously
                                        AwesomeDialog(
                                          width: 500,
                                          context: context,
                                          dialogType: DialogType.error,
                                          animType: AnimType.rightSlide,
                                          title: 'Error de selección',
                                          desc: 'Seleccione maximo 4 imagenes.',
                                          btnCancel: Container(),
                                          btnOkText: "Aceptar",
                                          btnOkColor: colors.colorGreen,
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () {},
                                        ).show();
                                        // print(
                                        //     "Error, Seleccione maximo 4 imagenes");
                                      } else {
                                        setState(() {
                                          imgsTemporales.addAll(imagenes);
                                        });
                                      }
                                    }
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.image),
                                      SizedBox(width: 10),
                                      Text('Subir Imagen/es'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              height: 300,
                              child: GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1,
                                ),
                                itemCount: urlsImgsList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Image.network(
                                    "$generalServer${urlsImgsList[index].toString()}",
                                    fit: BoxFit.fill,
                                  );
                                },
                              ),
                            ),
                            Visibility(
                              visible: imgsTemporales.isNotEmpty,
                              child: SizedBox(
                                height: 300,
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: imgsTemporales.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Image.network(
                                      (imgsTemporales[index].path),
                                      fit: BoxFit.fill,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      */
                      Container(
                        padding: const EdgeInsets.all(10),
                        height: screenHeight * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.green,
                            width: 1.0,
                          ),
                        ),
                        child: ListView(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        // imgsTemporales = [];
                                        List<XFile>? imagenes =
                                            await picker.pickMultiImage();

                                        int totalImgs = urlsImgsList.length +
                                            imagenes.length;
                                        if (imagenes != null &&
                                            imagenes.isNotEmpty) {
                                          if (totalImgs > 4) {
                                            // ignore: use_build_context_synchronously
                                            AwesomeDialog(
                                              width: 500,
                                              context: context,
                                              dialogType: DialogType.error,
                                              animType: AnimType.rightSlide,
                                              title: 'Error',
                                              desc:
                                                  'El número máximo de imagenes es 4.',
                                              btnCancel: Container(),
                                              btnOkText: "Aceptar",
                                              btnOkColor: colors.colorGreen,
                                              btnCancelOnPress: () {},
                                              btnOkOnPress: () {},
                                            ).show();
                                            // print(
                                            //     "Error, Seleccione maximo 4 imagenes");
                                          } else {
                                            setState(() {
                                              imgsTemporales.addAll(imagenes);
                                            });
                                          }
                                        }
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.image),
                                          SizedBox(width: 10),
                                          Text('Subir Imagen/es'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        // Agrega las imágenes permanentes
                                        for (int i = 0;
                                            i < urlsImgsList.length;
                                            i++)
                                          Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedTemp = false;
                                                    selectedImage =
                                                        urlsImgsList[i];
                                                  });
                                                },
                                                child: Container(
                                                  width: screenWidth * 0.08,
                                                  height: screenHeight * 0.10,
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  child: Image.network(
                                                    "$generalServer${urlsImgsList[i]}",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    //
                                                    int totalImgs = urlsImgsList
                                                            .length +
                                                        imgsTemporales.length;
                                                    print(
                                                        "Total images before delete: $totalImgs"); // Línea de depuración

                                                    if (totalImgs == 1) {
                                                      print(
                                                          "Should show modal for last image"); // Línea de depuración
                                                      showSuccessModal(
                                                          context,
                                                          "Error, El producto tiene que tener al menos una imagen",
                                                          Icons8.warning_1);
                                                    } else {
                                                      AwesomeDialog(
                                                        width: 500,
                                                        context: context,
                                                        dialogType:
                                                            DialogType.info,
                                                        animType:
                                                            AnimType.rightSlide,
                                                        title:
                                                            '¿Está seguro de eliminar la imagen?',
                                                        btnOkText: "Confirmar",
                                                        btnCancelText:
                                                            "Cancelar",
                                                        btnOkColor:
                                                            Colors.blueAccent,
                                                        btnCancelOnPress: () {},
                                                        btnOkOnPress: () {
                                                          urlsImgsList
                                                              .removeAt(i);

                                                          // print(
                                                          //     "urlsImgsList: $urlsImgsList");
                                                          // print(
                                                          //     "imgsTemporales: $imgsTemporales");
                                                          if (!selectedTemp &&
                                                              urlsImgsList
                                                                  .isNotEmpty) {
                                                            selectedImage =
                                                                urlsImgsList[0];
                                                          }
                                                          if (urlsImgsList
                                                              .isEmpty) {
                                                            selectedTemp = true;
                                                            selectedImage =
                                                                imgsTemporales[
                                                                        0]
                                                                    .path;
                                                          }
                                                          setState(() {});
                                                        },
                                                      ).show();
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.red,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                        // Agrega las imágenes temporales
                                        for (int i = 0;
                                            i < imgsTemporales.length;
                                            i++)
                                          Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    selectedTemp = true;
                                                    selectedImage =
                                                        imgsTemporales[i].path;
                                                  });
                                                },
                                                child: Container(
                                                  width: screenWidth * 0.08,
                                                  height: screenHeight * 0.10,
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  child: Image.network(
                                                    imgsTemporales[i].path,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    int totalImgs = urlsImgsList
                                                            .length +
                                                        imgsTemporales.length;

                                                    if (totalImgs == 1) {
                                                      showSuccessModal(
                                                          context,
                                                          "Error, El producto tiene que tener al menos una imagen",
                                                          Icons8.warning_1);
                                                    } else {
                                                      AwesomeDialog(
                                                        width: 500,
                                                        context: context,
                                                        dialogType:
                                                            DialogType.info,
                                                        animType:
                                                            AnimType.rightSlide,
                                                        title:
                                                            '¿Está seguro de eliminar la imagen?',
                                                        btnOkText: "Confirmar",
                                                        btnCancelText:
                                                            "Cancelar",
                                                        btnOkColor:
                                                            Colors.blueAccent,
                                                        btnCancelOnPress: () {},
                                                        btnOkOnPress: () {
                                                          imgsTemporales
                                                              .removeAt(i);

                                                          // print(
                                                          //     "urlsImgsList: $urlsImgsList");
                                                          // print(
                                                          //     "imgsTemporales: $imgsTemporales");
                                                          if (urlsImgsList
                                                              .isEmpty) {
                                                            selectedTemp = true;
                                                            selectedImage =
                                                                imgsTemporales[
                                                                        0]
                                                                    .path;
                                                          }
                                                          setState(() {});
                                                        },
                                                      ).show();
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.red,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 30),
                                    Visibility(
                                      visible: !selectedTemp,
                                      child: SizedBox(
                                        width: screenWidth * 0.37,
                                        height: screenHeight * 0.40,
                                        child: selectedImage != ""
                                            ? Image.network(
                                                "$generalServer$selectedImage",
                                                fit: BoxFit.fill,
                                              )
                                            : Container(),
                                      ),
                                    ),
                                    Visibility(
                                      visible: selectedTemp,
                                      child: SizedBox(
                                        width: screenWidth * 0.37,
                                        height: screenHeight * 0.40,
                                        child: selectedImage != ""
                                            ? Image.network(
                                                selectedImage,
                                                fit: BoxFit.fill,
                                              )
                                            : Container(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      //
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    getLoadingModal(context, false);
                                    if (showToResetType) {
                                      typeValue = selectedType;
                                    }
                                    if (typeValue == "SIMPLE") {
                                      isVariable = 0;
                                      optionsTypesOriginal = [];
                                      optionsTypesSend = [];
                                      variantsListSend = [];
                                    } else {
                                      isVariable = 1;
                                      if (selectedColores.isNotEmpty) {
                                        Set<String> uniqueColores =
                                            Set.from(selectedColores);
                                        var colores = {
                                          "name": "color",
                                          "values": uniqueColores.toList()
                                        };
                                        optionsTypesSend.add(colores);
                                      }

                                      if (selectedSizes.isNotEmpty) {
                                        Set<String> uniqueSizes =
                                            Set.from(selectedSizes);
                                        var tallas = {
                                          "name": "size",
                                          "values": uniqueSizes.toList()
                                        };
                                        optionsTypesSend.add(tallas);
                                      }

                                      if (selectedDimensions.isNotEmpty) {
                                        Set<String> uniqueDimensions =
                                            Set.from(selectedDimensions);
                                        var dimensions = {
                                          "name": "dimension",
                                          "values": uniqueDimensions.toList()
                                        };
                                        optionsTypesSend.add(dimensions);
                                      }
                                    }
                                    var urlsImgsListToSend;
                                    if (imgsTemporales.isNotEmpty) {
                                      urlsImgsListToSend =
                                          await saveImages(imgsTemporales);
                                    }

                                    // print("variantsListOriginal");
                                    // print(variantsListOriginal);
                                    // print("seller_owned: $seller_owned");
                                    var feat =
                                        jsonDecode(widget.data['features']);
                                    variantsListNoChanges = feat["variants"];
                                    // print(
                                    //     "variantsListNoChanges: $variantsListNoChanges");

                                    var featuresToSend = {
                                      "guide_name": _nameGuideController.text,
                                      "price_suggested":
                                          _priceSuggestedController.text,
                                      "sku": showToResetType
                                          ? _skuController.text.toUpperCase()
                                          : skuOriginal.toUpperCase(),
                                      "categories": selectedCategoriesMap,
                                      "description":
                                          _descriptionController.text,
                                      "type": typeValue,
                                      // "variants": seller_owned != 0
                                      //     ? variantsListNoChanges
                                      //     : variantsListOriginal,
                                      "variants": variantsListNoChanges,
                                      "options": optionsTypesOriginal
                                    };

                                    List<String> totalUrlsImgsList = [];

                                    if (imgsTemporales.isNotEmpty) {
                                      totalUrlsImgsList = [
                                        ...urlsImgsList,
                                        ...urlsImgsListToSend
                                      ];
                                    } else {
                                      totalUrlsImgsList = urlsImgsList;
                                    }

                                    _productController.editProduct(ProductModel(
                                      productId: widget.data['product_id'],
                                      productName: _nameController.text,
                                      stock: seller_owned != 0
                                          ? widget.data['stock']
                                          : stockOriginal,
                                      price:
                                          double.parse(_priceController.text),
                                      // urlImg: imgsTemporales.isNotEmpty
                                      //     ? urlsImgsListToSend
                                      //     : urlsImgsList,
                                      urlImg: urlsImgsList,
                                      isvariable: isVariable,
                                      features: featuresToSend,
                                      // warehouseId: int.parse(warehouseValue
                                      //     .toString()
                                      //     .split("-")[0]
                                      //     .toString()),
                                    ));

                                    // print("variantsStockToUpt can:");
                                    // print(variantsStockToUpt.length);

                                    if (variantsStockToUpt.isNotEmpty) {
                                      print("need to upt variantsStockToUpt:");
                                      print(variantsStockToUpt.length);
                                      // print(variantsStockToUpt);

                                      if (seller_owned != 0) {
                                        print("is seller_owned");

                                        for (var variant
                                            in variantsStockToUpt) {
                                          var response = await Connections()
                                              .createStockHistoryReserve(
                                                  codigo,
                                                  variant['sku'],
                                                  variant['units'],
                                                  seller_owned.toString(),
                                                  variant['description'],
                                                  variant['type'].toString());
                                          if (response == 0) {
                                            print("successful");
                                          } else {
                                            print("error");
                                          }
                                        }
                                        //
                                      } else {
                                        for (var variant
                                            in variantsStockToUpt) {
                                          var response = await Connections()
                                              .createStockHistory(
                                                  codigo,
                                                  variant['sku'],
                                                  variant['units'],
                                                  variant['description'],
                                                  variant['type'].toString());
                                          if (response == 0) {
                                            print("successful");
                                          } else {
                                            print("error");
                                          }
                                        }
                                        //
                                      }
                                    } else {
                                      print(
                                          "NO need to upt variantsStockToUpt");
                                    }

                                    if (warehouseValueOriginal
                                            .toString()
                                            .split("-")[0]
                                            .toString() !=
                                        warehouseValue
                                            .toString()
                                            .split("-")[0]
                                            .toString()) {
                                      //
                                      print(
                                          "Cambios de Bodega!! Need update ProductWarehouseLink");
                                      // print(
                                      //     "${warehouseValueOriginal.toString().split("-")[0].toString()}");
                                      // print(
                                      //     "${warehouseValue.toString().split("-")[0].toString()}");
                                      var responseUptPW = await Connections()
                                          .updateProductWarehouse(
                                              widget.data['product_id'],
                                              warehouseValueOriginal
                                                  .toString()
                                                  .split("-")[0]
                                                  .toString(),
                                              warehouseValue
                                                  .toString()
                                                  .split("-")[0]
                                                  .toString());

                                      if (responseUptPW == null) {
                                        print("Error,update Bodega");
                                      }
                                    } else {
                                      print("No hubo cambios de Bodega");
                                    }
                                    widget.hasEdited(true);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[400],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.save_rounded,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Guardar",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  getValue(value) {
    _descriptionController.text = value;
    return value;
  }

  Future<List<String>> saveImages(List<XFile> imgsTemporales) async {
    var c = 0;
    for (var imagen in imgsTemporales) {
      await _saveImage(imagen);
    }
    // print("final urlsImgs: $urlsImgsList");
    return urlsImgsList;
  }

  Future<void> _saveImage(XFile imagen) async {
    try {
      if (imagen != null && imagen.path.isNotEmpty) {
        var responseI = await Connections().postDoc(imagen);
        var imgUrl = responseI[1];
        urlsImgsList.add(imgUrl!);
      } else {
        print("No img");
      }
    } catch (error) {
      print("Error al guardar la imagen: $error");
    }
  }

  calcuateStockTotal(String valor) {
    int val = int.parse(valor);
    showStockTotal = showStockTotal + val;
    _stockController.text = showStockTotal.toString();
  }

  updateInventoryBySku(String sku, int newInventory, int type) {
    for (int i = 0; i < variantsListCopy.length; i++) {
      Map<String, dynamic> variant = variantsListCopy[i];
      if (variant.containsKey("sku") && variant["sku"] == sku) {
        int inventory_current =
            int.parse(variantsListCopy[i]["inventory_quantity"]);
        if (type == 1) {
          inventory_current += newInventory;
        } else if (type == 0) {
          inventory_current -= newInventory;
        }
        variantsListCopy[i]["inventory_quantity"] =
            inventory_current.toString();
        break;
      }
    }
  }

  calcuateStockTotalEsditVariants() {
    int showStockTotal = 0;
    for (Map<String, dynamic> variant in variantsListCopy) {
      if (variant.containsKey("inventory_quantity")) {
        int inventory = int.parse(variant["inventory_quantity"]);
        showStockTotal += inventory;
      }
    }
    _stockController.text = showStockTotal.toString();

    List<Map<String, dynamic>>? variantsEdit =
        (variantsListCopy as List<dynamic>).cast<Map<String, dynamic>>();

//new version
    List<String> variantOriginLabelsEdit = [];

    for (var variant in variantsEdit) {
      List<String> valuesToConcatenate = [];

      // Agregar todos los valores excepto "id", "sku", "inventory_quantity" y "price"
      for (var entry in variant.entries) {
        if (entry.key != "id" &&
            entry.key != "sku" &&
            entry.key != "inventory_quantity" &&
            entry.key != "price") {
          valuesToConcatenate.add(entry.value.toString());
        }
      }

      // Unir los valores con "/"
      String concatenatedValues = valuesToConcatenate.join('/');

      // Agregar la etiqueta de la variante a la lista
      variantOriginLabelsEdit.add(
          "${variant['sku']}; $concatenatedValues; Cantidad:${variant['inventory_quantity'].toString()}");
    }
    setState(() {
      variablesTextEdit = variantOriginLabelsEdit.join('\n');
    });
    setState(() {
      /*
      variablesTextEdit = variantsEdit.map((variable) {
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
        if (variable.containsKey('inventory_quantity')) {
          variableDetails.add("Cantidad: ${variable['inventory_quantity']}");
        }

        return variableDetails.join(';  ');
      }).join('\n');
      */
    });
  }

  bool varianteExistente(
      List<dynamic> lista, Map<String, dynamic> variante, List<String> claves) {
    return lista.any((existingVariant) {
      return claves.every((clave) =>
          existingVariant.containsKey(clave) &&
          existingVariant[clave] == variante[clave]);
    });
  }

  Container _modelText(String text, String data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            data,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Container _modelTextField(String text, TextEditingController controller) {
    return Container(
      // width: 500,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey[400]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

//class

class TextFieldWithIcon extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool applyValidator;
  final int? maxLines;

  const TextFieldWithIcon({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.inputType,
    this.inputFormatters,
    this.enabled = true,
    this.applyValidator = true,
    this.maxLines = 1, // Valor por defecto es 1
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: ColorsSystem().colorSelectMenu),
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 14.0,
          ),
        ),
        style: const TextStyle(
          color: Colors.black,
        ),
        validator: applyValidator
            ? (value) {
                if (value!.isEmpty) {
                  return 'Por favor, ingrese ${labelText.toLowerCase()}';
                }
                return null;
              }
            : null,
      ),
    );
  }
}
