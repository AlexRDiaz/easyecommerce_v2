import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/html_editor.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _inventaryController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceUnitController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _nameGuideController = TextEditingController();
  final TextEditingController _priceSuggestedController =
      TextEditingController();

  List<String> warehouses = [];
  List warehouseList = [];

  String? selectedWarehouse;
  List<String> categories = UIUtils.categories();

  String? selectedCategory;
  List<String> selectedCategories = [];

  List<String> features = [];
  List<String> types = UIUtils.typesProduct();
  String? selectedType;
  List<String> typesVariables = UIUtils.typesVariables();

  String? selectedVariable;
  String? chosenColor;
  String? chosenSize;
  String? chosenDimension;
  List<String> selectedColores = [];
  List<String> selectedSizes = [];
  List<String> selectedDimensions = [];

  List variablesTypes = [];
  List variablesList = [];
  final TextEditingController _showVariantsController = TextEditingController();
  int showStockTotal = 0;

  List<String> selectedVariablesList = [];

  List<Map<String, List<String>>> optionsList = UIUtils.variablesToSelect();

  List<String> sizesToSelect = [];
  List<String> colorsToSelect = [];
  List<String> dimensionToSelect = [];
  List<String> urlsImgsList = [];
  int isVariable = 0;

  //multi img show temp
  List<XFile> imgsTemporales = [];

  late ProductController _productController;
  late WrehouseController _warehouseController;
  List<WarehouseModel> warehousesList = [];
  List<String> warehousesToSelect = [];

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  @override
  void initState() {
    super.initState();
    _productController = ProductController();
    _warehouseController = WrehouseController();
    getWarehouses();
    loadData();
  }

  Future<List<WarehouseModel>> _getWarehousesData() async {
    await _warehouseController.loadWarehouses(); //byprovider loged
    return _warehouseController.warehouses;
  }

  getWarehouses() async {
    var responseBodegas = await _getWarehousesData();
    warehousesList = responseBodegas;
    for (var warehouse in warehousesList) {
      if (warehouse.approved == 1 && warehouse.active == 1) {
        setState(() {
          warehousesToSelect
              .add('${warehouse.id}-${warehouse.branchName}-${warehouse.city}');
        });
      }
    }
  }

  loadData() async {
    sizesToSelect = optionsList[0]["sizes"]!;
    colorsToSelect = optionsList[1]["colors"]!;
    dimensionToSelect = optionsList[2]["dimensions"]!;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppBar(
        title: const Text(
          "Añadir Nuevo Producto",
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
        // decoration: BoxDecoration(
        //   border: Border.all(color: Colors.blue.shade900, width: 2.0),
        // ),
        // padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.60,
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                Column(
                  children: [
                    //
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nombre del producto'),
                              const SizedBox(height: 3),
                              TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.text,
                                maxLines: null,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  // contentPadding: const EdgeInsets.symmetric(
                                  //     vertical: 10.0, horizontal: 15.0),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, ingrese el nombre del producto';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nombre para mostrar en la guía'),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _nameGuideController,
                                keyboardType: TextInputType.number,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '',
                                ),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SKU'),
                              const SizedBox(height: 3),
                              SizedBox(
                                width: 200,
                                child: TextFormField(
                                  controller: _skuController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Z0-9]'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Por favor, ingrese el SKU del producto';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Precio Bodega'),
                              const SizedBox(height: 3),
                              SizedBox(
                                width: 120,
                                child: TextFormField(
                                  controller: _priceController,
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
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Por favor, ingrese el precio del producto';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Precio Sugerido'),
                              const SizedBox(height: 3),
                              SizedBox(
                                width: 120,
                                child: TextFormField(
                                  controller: _priceSuggestedController,
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
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Por favor, ingrese el precio del producto';
                                    }
                                    return null;
                                  },
                                ),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tipo'),
                              const SizedBox(height: 3),
                              SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    'Seleccione',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  items: types
                                      .map((item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedType,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedColores = [];
                                      selectedSizes = [];
                                      selectedDimensions = [];
                                      variablesTypes = [];
                                      variablesList = [];
                                      _stockController.clear();
                                      _showVariantsController.clear();
                                      selectedVariablesList.clear();
                                      if (value != null) {
                                        selectedType = value;
                                      }
                                    });
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
                        ),
                        const SizedBox(width: 20),
                        // Visibility(
                        //   visible: selectedType == 'VARIABLE',
                        //   child: Expanded(
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         const Text('Variables'),
                        //         const SizedBox(height: 3),
                        //         Visibility(
                        //           visible: selectedType == 'VARIABLE',
                        //           child: TextFormField(
                        //             controller: _showVariantsController,
                        //             maxLines: null,
                        //             readOnly: true,
                        //             decoration: InputDecoration(
                        //               fillColor: Colors.white,
                        //               filled: true,
                        //               border: OutlineInputBorder(
                        //                 borderRadius:
                        //                     BorderRadius.circular(5.0),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Visibility(
                          visible: selectedType == 'VARIABLE',
                          child: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Variables'),
                                const SizedBox(height: 3),
                                Visibility(
                                  visible: selectedType == 'VARIABLE',
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children:
                                        variablesList.map<Widget>((variable) {
                                      String chipLabel =
                                          "SKU: ${variable['sku']}";
                                      if (variable.containsKey('size')) {
                                        chipLabel +=
                                            " - Talla: ${variable['size']}";
                                      }
                                      if (variable.containsKey('color')) {
                                        chipLabel +=
                                            " - Color: ${variable['color']}";
                                      }
                                      if (variable.containsKey('dimension')) {
                                        chipLabel +=
                                            " - Tamaño: ${variable['dimension']}";
                                      }
                                      // chipLabel +=
                                      //     " - Precio: \$${variable['price']}";
                                      chipLabel +=
                                          " - Cantidad: ${variable['inventory_quantity']}";

                                      return Chip(
                                        label: Text(chipLabel),
                                        onDeleted: () {
                                          setState(() {
                                            // Verificar la propiedad y realizar la eliminación en selectedColores o selectedSizes
                                            if (variable.containsKey('color')) {
                                              String color = variable['color'];
                                              selectedColores.remove(color);
                                            }

                                            if (variable.containsKey('size')) {
                                              String size = variable['size'];
                                              selectedSizes.remove(size);
                                            }

                                            if (variable
                                                .containsKey('dimension')) {
                                              String dimension =
                                                  variable['dimension'];
                                              selectedDimensions
                                                  .remove(dimension);
                                            }

                                            variablesList.remove(variable);
                                          });
                                          // print("variablesList act:");
                                          // print(variablesList);

                                          // print("selectedColores act:");
                                          // print(selectedColores);
                                          // print("selectedSizes act:");
                                          // print(selectedSizes);
                                          // print("selectedDimensions act:");
                                          // print(selectedDimensions);

                                          // print("variablesTypes act:");
                                          // print(variablesTypes);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    //
                    Visibility(
                      visible: selectedType == 'VARIABLE',
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  hint: Text(
                                    'Seleccione Variable',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  items: typesVariables
                                      .map((item) => DropdownMenuItem(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedVariable,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedVariable = value;
                                      if (!(selectedVariablesList
                                          .contains(selectedVariable))) {
                                        if (value != null) {
                                          if (((selectedVariablesList
                                                      .contains("Tallas")) &&
                                                  selectedVariable ==
                                                      "Tamaños") ||
                                              ((selectedVariablesList
                                                      .contains("Tamaños")) &&
                                                  selectedVariable ==
                                                      "Tallas")) {
                                            print(
                                                "No se puede realizar esta combinacion");
                                          } else {
                                            selectedVariable = value;

                                            selectedVariablesList.add(
                                                selectedVariable.toString());
                                            print(selectedVariablesList);
                                          }

                                          _priceUnitController.text =
                                              _priceController.text;
                                        }
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: selectedVariablesList
                                      .map<Widget>((variable) {
                                    return Chip(
                                      label: Text(variable),
                                      onDeleted: () {
                                        setState(() {
                                          selectedVariablesList
                                              .remove(variable);
                                          // print("catAct: $selectedCategories");
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible:
                                      selectedVariablesList.contains("Tallas"),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      'Seleccione Talla',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    items: sizesToSelect
                                        .map((item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    value: chosenSize,
                                    onChanged: (value) {
                                      setState(() {
                                        chosenSize = value;
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
                                const SizedBox(width: 10),
                                Visibility(
                                  visible:
                                      selectedVariablesList.contains("Colores"),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      'Seleccione Color',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    items: colorsToSelect
                                        .map((item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    value: chosenColor,
                                    onChanged: (value) {
                                      setState(() {
                                        chosenColor = value;
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
                                const SizedBox(width: 5),
                                Visibility(
                                  visible:
                                      selectedVariablesList.contains("Tamaños"),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    hint: Text(
                                      'Seleccione Tamaño',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    items: dimensionToSelect
                                        .map((item) => DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    value: chosenDimension,
                                    onChanged: (value) {
                                      setState(() {
                                        chosenDimension = value;
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
                          const SizedBox(width: 20),
                          // Visibility(
                          //   visible: selectedSizes.isNotEmpty ||
                          //       selectedColores.isNotEmpty ||
                          //       selectedDimensions.isNotEmpty,
                          Visibility(
                            visible: selectedVariablesList.isNotEmpty,
                            child: Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextFieldWithIcon(
                                                    controller:
                                                        _inventaryController,
                                                    labelText: 'Cantidad',
                                                    icon: Icons.numbers,
                                                    inputType:
                                                        TextInputType.number,
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
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
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // print(
                                      //     _inventaryController.text.toString());
                                      // print(
                                      //     _priceUnitController.text.toString());
                                      // print(_skuController.text.toString());

                                      if (((int.parse(_inventaryController
                                                      .text) <
                                                  1) ||
                                              (_inventaryController
                                                  .text.isEmpty) ||
                                              (_inventaryController.text ==
                                                  "")) &&
                                          (_skuController.text != "" ||
                                              _skuController.text.isEmpty)) {
                                        showSuccessModal(
                                            context,
                                            "Por favor, ingrese una Cantidad y SKU válida.",
                                            Icons8.alert);
                                      } else {
                                        //
                                        var variant;
                                        int idRandom =
                                            Random().nextInt(9000000) + 1000000;

                                        if (selectedVariablesList
                                                .contains("Tallas") &&
                                            selectedVariablesList
                                                .contains("Colores")) {
                                          variant = {
                                            "id": idRandom,
                                            "sku":
                                                "${_skuController.text}${chosenSize}${chosenColor?.toUpperCase()}",
                                            "size": "$chosenSize",
                                            "color": "$chosenColor",
                                            "inventory_quantity":
                                                _inventaryController.text,
                                          };
                                          //
                                          List<String> claves = [
                                            "size",
                                            "color"
                                          ];
                                          if (varianteExistente(
                                              variablesList, variant, claves)) {
                                            print(
                                                "Ya existe una variante con talla: $chosenSize y color: $chosenColor");
                                          } else {
                                            variablesList.add(variant);
                                            selectedSizes.add(chosenSize!);
                                            selectedColores.add(chosenColor!);

                                            calcuateStockTotal(
                                                _inventaryController.text);
                                          }
                                          //
                                        } else if (selectedVariablesList
                                                .contains("Tamaño") &&
                                            selectedVariablesList
                                                .contains("Colores")) {
                                          variant = {
                                            "id": idRandom,
                                            "sku":
                                                "${_skuController.text}${chosenDimension?.isNotEmpty == true ? chosenDimension![0].toUpperCase() : ""}${chosenColor?.toUpperCase()}",
                                            "dimension": "$chosenDimension",
                                            "color": "$chosenColor",
                                            "inventory_quantity":
                                                _inventaryController.text,
                                          };
                                          //
                                          List<String> claves = [
                                            "dimension",
                                            "color"
                                          ];
                                          if (varianteExistente(
                                              variablesList, variant, claves)) {
                                            print(
                                                "Ya existe una variante con tamaño: $chosenDimension y color: $chosenColor");
                                          } else {
                                            variablesList.add(variant);
                                            selectedDimensions
                                                .add(chosenDimension!);
                                            selectedColores.add(chosenColor!);

                                            calcuateStockTotal(
                                                _inventaryController.text);
                                          }
                                          //
                                        } else if (selectedVariablesList
                                            .contains("Tallas")) {
                                          variant = {
                                            "id": idRandom,
                                            "sku":
                                                "${_skuController.text}${chosenSize}",
                                            "size": "$chosenSize",
                                            "inventory_quantity":
                                                _inventaryController.text,
                                          };
                                          //
                                          List<String> claves = ["size"];
                                          if (varianteExistente(
                                              variablesList, variant, claves)) {
                                            print(
                                                "Ya existe una variante con talla: $chosenSize");
                                          } else {
                                            variablesList.add(variant);
                                            selectedSizes.add(chosenSize!);

                                            calcuateStockTotal(
                                                _inventaryController.text);
                                          }
                                          //
                                        } else if (selectedVariablesList
                                            .contains("Colores")) {
                                          variant = {
                                            "id": idRandom,
                                            "sku":
                                                "${_skuController.text}${chosenColor?.toUpperCase()}",
                                            "color": "$chosenColor",
                                            "inventory_quantity":
                                                _inventaryController.text,
                                          };
                                          //
                                          List<String> claves = ["color"];
                                          if (varianteExistente(
                                              variablesList, variant, claves)) {
                                            print(
                                                "Ya existe una variante con color: $chosenColor");
                                          } else {
                                            variablesList.add(variant);
                                            selectedColores.add(chosenColor!);

                                            calcuateStockTotal(
                                                _inventaryController.text);
                                          }
                                          //
                                        } else if (selectedVariablesList
                                            .contains("Tamaños")) {
                                          variant = {
                                            "id": idRandom,
                                            "sku":
                                                "${_skuController.text}${chosenDimension?.isNotEmpty == true ? chosenDimension![0].toUpperCase() : ""}",
                                            "dimension": "$chosenDimension",
                                            "inventory_quantity":
                                                _inventaryController.text,
                                          };
                                          //
                                          List<String> claves = ["dimension"];
                                          if (varianteExistente(
                                              variablesList, variant, claves)) {
                                            print(
                                                "Ya existe una variante con tamaño: $chosenDimension");
                                          } else {
                                            variablesList.add(variant);
                                            selectedDimensions
                                                .add(chosenDimension!);

                                            calcuateStockTotal(
                                                _inventaryController.text);
                                          }
                                          //
                                        }

                                        // variablesList.add(variant);
                                        // print(variantsList);
                                        //

                                        // print(variablesList);
                                        // print("selectedColores act:");
                                        // print(selectedColores);
                                        // print("selectedSizes act:");
                                        // print(selectedSizes);
                                        // print("selectedDimensions act:");
                                        // print(selectedDimensions);

                                        _priceUnitController.text =
                                            _priceController.text;
                                        _inventaryController.clear();

                                        setState(() {});

                                        // print(selectedColores);
                                        // print(selectedTallas);
                                        // print(selectedDimensions);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[400],
                                    ),
                                    child: const Text(
                                      "Añadir",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                              const Text('Cantidad en Stock'),
                              const SizedBox(height: 3),
                              TextFormField(
                                controller: _stockController,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Por favor, ingrese la cantidad en stock del producto';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Bodega:'),
                              const SizedBox(height: 3),
                              DropdownButtonFormField<String>(
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
                                  var parts = item.split('-');
                                  var branchName = parts[1];
                                  var city = parts[2];
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      '$branchName - $city',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                value: selectedWarehouse,
                                onChanged: (value) {
                                  setState(() {
                                    selectedWarehouse = value as String;
                                  });
                                },
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
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Categoría'),
                              const SizedBox(height: 3),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Seleccione',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                items: categories
                                    .map((item) => DropdownMenuItem(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: selectedCategories.isNotEmpty
                                    ? selectedCategories.first
                                    : null,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategory = value;
                                    if (value != null) {
                                      selectedCategories.add(value);
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                              ),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children:
                                    selectedCategories.map<Widget>((category) {
                                  return Chip(
                                    label: Text(category),
                                    onDeleted: () {
                                      setState(() {
                                        selectedCategories.remove(category);
                                        // print("catAct: $selectedCategories");
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
                    const SizedBox(height: 30),
                    Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text('Descripción'),
                            const SizedBox(height: 5),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              padding: const EdgeInsets.all(8.0),
                              height: 200,
                              //  width: 600,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.black)),
                              child: HtmlEditor(
                                description: "",
                                getValue: getValue,
                              ),
                            ),
                          ]))
                    ]),
                    const SizedBox(height: 10),

                    //
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

                                  if (imagenes != null && imagenes.isNotEmpty) {
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
                                    Text('Seleccionar Imagen'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Mostrar hasta 4 imágenes
                          SizedBox(
                            height: 250,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: imgsTemporales.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Image.network(
                                  (imgsTemporales[index].path),
                                  fit: BoxFit.fill,
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
//

                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Productos Privados ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 14),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Correo Electrónico'),
                              const SizedBox(height: 3),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                onChanged: (email) {
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cantidad'),
                              const SizedBox(height: 3),
                              TextFormField(
                                controller: _quantityController,
                                enabled: _emailController.text.isNotEmpty,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (_emailController.text.isNotEmpty &&
                                      value!.isEmpty) {
                                    return 'Por favor, ingresa la cantidad de los productos privados';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    //btn
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    getLoadingModal(context, false);

                                    if (selectedType == null ||
                                        selectedCategories.isEmpty ||
                                        selectedWarehouse == null) {
                                      AwesomeDialog(
                                        width: 500,
                                        context: context,
                                        dialogType: DialogType.error,
                                        animType: AnimType.rightSlide,
                                        title: 'Error de selección',
                                        desc:
                                            'Es necesario que seleccione el Tipo, Categoría/as y Bodega.',
                                        btnCancel: Container(),
                                        btnOkText: "Aceptar",
                                        btnOkColor: colors.colorGreen,
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () {},
                                      ).show();

                                      // showSuccessModal(
                                      //     context,
                                      //     "Por favor, Es necesario que seleccione el Tipo, Categoría/as y Bodega.",
                                      //     Icons8.alert);
                                    } else {
                                      if (_emailController.text.isNotEmpty) {
                                        if (!_emailController.text
                                            .contains('@')) {
                                          showSuccessModal(
                                              context,
                                              "Por favor, ingrese un correo electrónico válido.",
                                              Icons8.alert);
                                        } else {
                                          int? stock = int.tryParse(
                                              _stockController.text);
                                          int? cantidadPriv = int.tryParse(
                                              _quantityController.text);

                                          if ((cantidadPriv! > stock!) ||
                                              (cantidadPriv == 0)) {
                                            showSuccessModal(
                                                context,
                                                "Por favor, revise la cantidad de los productos privados.",
                                                Icons8.alert);
                                          }
                                        }
                                      }

                                      if (selectedType == "SIMPLE") {
                                        variablesTypes = [];
                                        variablesList = [];
                                      } else {
                                        isVariable = 1;
                                        if (selectedColores.isNotEmpty) {
                                          Set<String> uniqueColores =
                                              Set.from(selectedColores);
                                          var colores = {
                                            "name": "color",
                                            "values": uniqueColores.toList()
                                          };
                                          variablesTypes.add(colores);
                                        }

                                        if (selectedSizes.isNotEmpty) {
                                          Set<String> uniqueSizes =
                                              Set.from(selectedSizes);
                                          var tallas = {
                                            "name": "size",
                                            "values": uniqueSizes.toList()
                                          };
                                          variablesTypes.add(tallas);
                                        }

                                        if (selectedDimensions.isNotEmpty) {
                                          Set<String> uniqueDimensions =
                                              Set.from(selectedDimensions);
                                          var dimensions = {
                                            "name": "dimension",
                                            "values": uniqueDimensions.toList()
                                          };
                                          variablesTypes.add(dimensions);
                                        }
                                      }

                                      var urlsImgsListToSend =
                                          await saveImages(imgsTemporales);

                                      var featuresToSend = {
                                        "guide_name": _nameGuideController.text,
                                        "price_suggested":
                                            _priceSuggestedController.text,
                                        "sku": _skuController.text,
                                        "categories": selectedCategories,
                                        "description":
                                            _descriptionController.text,
                                        "type": selectedType,
                                        "variants": variablesList,
                                        "options": variablesTypes
                                      };

                                      // print("featuresToSend: $featuresToSend");

                                      var response = _productController
                                          .addProduct(ProductModel(
                                        productName: _nameController.text,
                                        stock: int.parse(_stockController.text),
                                        price:
                                            double.parse(_priceController.text),
                                        urlImg: urlsImgsListToSend,
                                        isvariable: isVariable,
                                        features: featuresToSend,
                                        warehouseId: int.parse(selectedWarehouse
                                            .toString()
                                            .split("-")[0]
                                            .toString()),
                                      ));

                                      // print(response);

                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  }
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
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),

                    //
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> saveImages(List<XFile> imgsTemporales) async {
    var c = 0;
    for (var imagen in imgsTemporales) {
      await _saveImage(imagen);
    }
    print("final urlsImgs: $urlsImgsList");
    return urlsImgsList;
  }

  Future<void> _saveImage(XFile imagen) async {
    try {
      if (imagen != null && imagen.path.isNotEmpty) {
        var responseI = await Connections().postDoc(imagen);
        // print("ImgSaveStrapi: $responseI");

        var imgUrl = responseI[1];
        urlsImgsList.add(imgUrl!);
      } else {
        print("No img");
      }
    } catch (error) {
      print("Error al guardar la imagen: $error");
    }
  }

  getValue(value) {
    _descriptionController.text = value;
    return value;
  }

  showVariants(variantsList) {
    String variantText =
        variantsList.map((variant) => variant.values.join(';  ')).join('\n');
    _showVariantsController.text = variantText;
  }

  calcuateStockTotal(String valor) {
    int val = int.parse(valor);
    showStockTotal = showStockTotal + val;
    _stockController.text = showStockTotal.toString();
  }

  bool varianteExistente(
      List<dynamic> lista, Map<String, dynamic> variante, List<String> claves) {
    return lista.any((existingVariant) {
      return claves.every((clave) =>
          existingVariant.containsKey(clave) &&
          existingVariant[clave] == variante[clave]);
    });
  }

//
}

class TextFieldWithIcon extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final TextInputType inputType;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldWithIcon({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.icon,
    required this.inputType,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: ColorsSystem().colorSelectMenu),
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }
}
