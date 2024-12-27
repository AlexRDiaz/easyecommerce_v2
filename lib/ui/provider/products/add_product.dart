import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/glogal_step_form.dart';
import 'package:frontend/ui/widgets/html_editor.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/product/search_menu.dart';
import 'package:frontend/ui/widgets/text_field_icon.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'package:remove_diacritic/remove_diacritic.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _inventaryController = TextEditingController();

  final TextEditingController _priceWarehouseController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _quantityReserveController =
      TextEditingController();
  final TextEditingController _priceUnitController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();
  final TextEditingController _nameGuideController = TextEditingController();
  final TextEditingController _priceSuggestedController =
      TextEditingController();

  List<String> warehouses = [];
  List warehouseList = [];

  String? selectedWarehouse;
  List<String> categoriesToSelect = [];
  // = UIUtils.categories();

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

  List optionsTypes = [];
  List variantsList = [];
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
  String? idCategoryFirstCat;
  final TextEditingController _searchCategoryController =
      TextEditingController();
  List<String> _filteredCategoryes = [];
  Timer? _timer;

  List<Map<String, String>> selectedCategoriesMap = [];

  //reservas
  List<String> variantsToSelect = [];
  List<Map<String, dynamic>> reservasToSend = [];
  String? chosenVariantToReserv;

  //input variants
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _dimensionController = TextEditingController();

  //
  bool sellerOwner = false;
  final TextEditingController _emailSellerOwnerController =
      TextEditingController();
  ScrollController _scrollController = ScrollController();

  final TextEditingController _weightController = TextEditingController();

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
    await _warehouseController.loadWarehouses(
        sharedPrefs!.getString("idProvider").toString()); //byprovider loged
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

    List<dynamic> data = [];
    String jsonData = await rootBundle.loadString('assets/taxonomy3.json');
    data = json.decode(jsonData);

    for (var item in data) {
      var lastKey = item.keys.last;
      String menuItemLabel = "${item[lastKey]}-${item['id']}";
      categoriesToSelect.add(menuItemLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    // double MediaQuery.of(context).size.width = MediaQuery.of(context).size.width * 0.50;
    // double screenHeight = MediaQuery.of(context).size.height;
    return responsive(
      webContainer(MediaQuery.of(context).size.width * 0.4, context),
      webContainer(MediaQuery.of(context).size.width * 0.5, context),
      context,
    );

    // AlertDialog(
    //   title: AppBar(
    //     title: const Text(
    //       "Añadir Nuevo Producto",
    //       style: TextStyle(
    //         fontWeight: FontWeight.bold,
    //         fontSize: 16,
    //       ),
    //     ),
    //     backgroundColor: Colors.blue[900],
    //     leading: Container(),
    //     centerTitle: true,
    //   ),
    //   content: Container(
    //     // decoration: BoxDecoration(
    //     //   border: Border.all(color: Colors.blue.shade900, width: 2.0),
    //     // ),
    //     // padding: const EdgeInsets.all(20.0),
    //     child: SizedBox(
    //       width: MediaQuery.of(context).size.width,
    //       height: screenHeight,
    //       child: Form(
    //         key: formKey,
    //         child: ListView(
    //           controller: _scrollController,
    //           children: [
    //             Column(
    //               children: [
    //                 //
    //                 const SizedBox(height: 10),
    //                 Row(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Expanded(
    //                       child: TextFieldIcon(
    //                         controller: _nameController,
    //                         labelText: 'Nombre del producto',
    //                         icon: Icons.local_mall_rounded,
    //                         maxLines: null,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 10),
    //                 Row(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Expanded(
    //                       child: TextFieldIcon(
    //                         controller: _nameGuideController,
    //                         labelText: 'Nombre para mostrar en la guía',
    //                         icon: Icons.local_offer_outlined,
    //                         maxLines: null,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 10),
    //                 Row(
    //                   children: [
    //                     SizedBox(
    //                       width: 250,
    //                       child: TextFieldIcon(
    //                         controller: _skuController,
    //                         labelText: 'SKU',
    //                         icon: Icons.numbers,
    //                         inputFormatters: [
    //                           FilteringTextInputFormatter.allow(
    //                             RegExp(r'[a-zA-Z0-9]'),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     const SizedBox(width: 20),
    //                     SizedBox(
    //                       width: 250,
    //                       child: TextFieldIcon(
    //                         controller: _weightController,
    //                         labelText: 'Peso (kg)',
    //                         icon: Icons.monitor_weight,
    //                         inputType: TextInputType.number,
    //                         inputFormatters: <TextInputFormatter>[
    //                           FilteringTextInputFormatter.allow(
    //                               RegExp(r'^\d+\.?\d{0,2}$')),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 10),
    //                 Row(
    //                   children: [
    //                     SizedBox(
    //                       width: 250,
    //                       child: TextFieldIcon(
    //                         controller: _priceWarehouseController,
    //                         labelText: 'Precio Bodega',
    //                         icon: Icons.monetization_on,
    //                         inputType: TextInputType.number,
    //                         inputFormatters: <TextInputFormatter>[
    //                           FilteringTextInputFormatter.allow(
    //                               RegExp(r'^\d+\.?\d{0,2}$')),
    //                         ],
    //                       ),
    //                     ),
    //                     const SizedBox(width: 20),
    //                     SizedBox(
    //                       width: 250,
    //                       child: TextFieldIcon(
    //                         controller: _priceSuggestedController,
    //                         labelText: 'Precio Sugerido',
    //                         icon: Icons.monetization_on,
    //                         inputType: TextInputType.number,
    //                         inputFormatters: <TextInputFormatter>[
    //                           FilteringTextInputFormatter.allow(
    //                               RegExp(r'^\d+\.?\d{0,2}$')),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 10),
    //                 Row(
    //                   children: [
    //                     Column(
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         const Text('Tipo'),
    //                         const SizedBox(height: 3),
    //                         SizedBox(
    //                           width: 150,
    //                           child: DropdownButtonFormField<String>(
    //                             isExpanded: true,
    //                             hint: Text(
    //                               'Seleccione',
    //                               style: TextStyle(
    //                                 fontSize: 14,
    //                                 color: Theme.of(context).hintColor,
    //                                 fontWeight: FontWeight.bold,
    //                               ),
    //                             ),
    //                             items: types
    //                                 .map((item) => DropdownMenuItem(
    //                                       value: item,
    //                                       child: Text(
    //                                         item,
    //                                         style: const TextStyle(
    //                                           fontSize: 14,
    //                                           fontWeight: FontWeight.bold,
    //                                         ),
    //                                       ),
    //                                     ))
    //                                 .toList(),
    //                             value: selectedType,
    //                             onChanged: (value) {
    //                               if (_skuController.text.isEmpty ||
    //                                   _priceWarehouseController.text.isEmpty ||
    //                                   _priceSuggestedController.text.isEmpty) {
    //                                 showSuccessModal(
    //                                     context,
    //                                     "Por favor, ingrese el SKU, Precio Bodega y el Precio sugerido del producto",
    //                                     Icons8.warning_1);
    //                               } else {
    //                                 if (double.parse(_priceWarehouseController
    //                                             .text) <=
    //                                         0 &&
    //                                     double.parse(_priceSuggestedController
    //                                             .text) <=
    //                                         0) {
    //                                   showSuccessModal(
    //                                       context,
    //                                       "Por favor, ingrese el precio Bodega y el sugerido de los productos validos",
    //                                       Icons8.warning_1);
    //                                 } else {
    //                                   setState(() {
    //                                     selectedColores = [];
    //                                     selectedSizes = [];
    //                                     selectedDimensions = [];
    //                                     optionsTypes = [];
    //                                     variantsList = [];
    //                                     _stockController.clear();
    //                                     selectedVariablesList.clear();
    //                                     if (value != null) {
    //                                       selectedType = value;
    //                                     }
    //                                     // print("selectedType: $selectedType");
    //                                   });
    //                                 }
    //                               }
    //                             },
    //                             decoration: InputDecoration(
    //                               fillColor: Colors.white,
    //                               filled: true,
    //                               border: OutlineInputBorder(
    //                                 borderRadius: BorderRadius.circular(5.0),
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                     const SizedBox(width: 10),
    //                     Visibility(
    //                       visible: selectedType == 'VARIABLE',
    //                       child: Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             const Text('Variables'),
    //                             const SizedBox(height: 3),
    //                             Visibility(
    //                               visible: selectedType == 'VARIABLE',
    //                               child: Wrap(
    //                                 spacing: 8.0,
    //                                 runSpacing: 8.0,
    //                                 children:
    //                                     variantsList.map<Widget>((variable) {
    //                                   String chipLabel =
    //                                       "SKU: ${variable['sku']}";
    //                                   if (variable.containsKey('size')) {
    //                                     chipLabel +=
    //                                         " - Talla: ${variable['size']}";
    //                                   }
    //                                   if (variable.containsKey('color')) {
    //                                     chipLabel +=
    //                                         " - Color: ${variable['color']}";
    //                                   }
    //                                   if (variable.containsKey('dimension')) {
    //                                     chipLabel +=
    //                                         " - Tamaño: ${variable['dimension']}";
    //                                   }
    //                                   // chipLabel +=
    //                                   //     " - Precio: \$${variable['price']}";
    //                                   chipLabel +=
    //                                       " - Cantidad: ${variable['inventory_quantity']}";

    //                                   String skuVar = variable['sku'];
    //                                   if (!variantsToSelect.contains(skuVar)) {
    //                                     variantsToSelect.add(skuVar);
    //                                   } else {
    //                                     // print(
    //                                     //     'El SKU ya está presente en la lista.');
    //                                   }

    //                                   return Chip(
    //                                     label: Text(chipLabel),
    //                                     onDeleted: () {
    //                                       setState(() {
    //                                         // Verificar la propiedad y realizar la eliminación en selectedColores o selectedSizes
    //                                         if (variable.containsKey('color')) {
    //                                           String color = variable['color'];
    //                                           selectedColores.remove(color);
    //                                         }

    //                                         if (variable.containsKey('size')) {
    //                                           String size = variable['size'];
    //                                           selectedSizes.remove(size);
    //                                         }

    //                                         if (variable
    //                                             .containsKey('dimension')) {
    //                                           String dimension =
    //                                               variable['dimension'];
    //                                           selectedDimensions
    //                                               .remove(dimension);
    //                                         }

    //                                         variantsList.remove(variable);

    //                                         if (variable.containsKey('sku')) {
    //                                           variantsToSelect.remove(variable);
    //                                         }
    //                                       });
    //                                       // print("variablesList act:");
    //                                       // print(variablesList);

    //                                       // print("selectedColores act:");
    //                                       // print(selectedColores);
    //                                       // print("selectedSizes act:");
    //                                       // print(selectedSizes);
    //                                       // print("selectedDimensions act:");
    //                                       // print(selectedDimensions);

    //                                       // print("variablesTypes act:");
    //                                       // print(variablesTypes);
    //                                     },
    //                                   );
    //                                 }).toList(),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 10),
    //                 //
    //                 Visibility(
    //                   visible: selectedType == 'VARIABLE',
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             SizedBox(
    //                               width: (MediaQuery.of(context).size.width / 3) - 10,
    //                               child: DropdownButtonFormField<String>(
    //                                 isExpanded: true,
    //                                 hint: Text(
    //                                   'Seleccione Variable',
    //                                   style: TextStyle(
    //                                     fontSize: 14,
    //                                     color: Theme.of(context).hintColor,
    //                                     fontWeight: FontWeight.bold,
    //                                   ),
    //                                 ),
    //                                 items: typesVariables
    //                                     .map((item) => DropdownMenuItem(
    //                                           value: item,
    //                                           child: Text(
    //                                             item,
    //                                             style: const TextStyle(
    //                                               fontSize: 14,
    //                                               fontWeight: FontWeight.bold,
    //                                             ),
    //                                           ),
    //                                         ))
    //                                     .toList(),
    //                                 value: selectedVariable,
    //                                 onChanged: (value) {
    //                                   setState(() {
    //                                     selectedVariable = value;
    //                                     if (!(selectedVariablesList
    //                                         .contains(selectedVariable))) {
    //                                       if (value != null) {
    //                                         if (((selectedVariablesList
    //                                                     .contains("Tallas")) &&
    //                                                 selectedVariable ==
    //                                                     "Tamaños") ||
    //                                             ((selectedVariablesList
    //                                                     .contains("Tamaños")) &&
    //                                                 selectedVariable ==
    //                                                     "Tallas")) {
    //                                           // print(
    //                                           //     "No se puede realizar esta combinacion");
    //                                         } else {
    //                                           selectedVariable = value;

    //                                           selectedVariablesList.add(
    //                                               selectedVariable.toString());
    //                                           // print(selectedVariablesList);
    //                                         }

    //                                         _priceUnitController.text =
    //                                             _priceWarehouseController.text;
    //                                       }
    //                                     }
    //                                   });
    //                                 },
    //                                 decoration: InputDecoration(
    //                                   fillColor: Colors.white,
    //                                   filled: true,
    //                                   border: OutlineInputBorder(
    //                                     borderRadius:
    //                                         BorderRadius.circular(5.0),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 const SizedBox(width: 5),

    //                 Visibility(
    //                   visible: selectedType == 'VARIABLE',
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Wrap(
    //                               spacing: 8.0,
    //                               runSpacing: 8.0,
    //                               children: selectedVariablesList
    //                                   .map<Widget>((variable) {
    //                                 return Chip(
    //                                   label: Text(variable),
    //                                   onDeleted: () {
    //                                     setState(() {
    //                                       selectedVariablesList
    //                                           .remove(variable);
    //                                     });
    //                                   },
    //                                 );
    //                               }).toList(),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 const SizedBox(height: 10),
    //                 //**** */
    //                 Visibility(
    //                   visible: selectedType == 'VARIABLE',
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Visibility(
    //                               visible:
    //                                   selectedVariablesList.contains("Tallas"),
    //                               child: Column(
    //                                 children: [
    //                                   TextFieldIcon(
    //                                     controller: _sizeController,
    //                                     labelText: 'Ingrese Talla',
    //                                     icon: Icons.numbers,
    //                                     applyValidator: false,
    //                                     inputFormatters: [
    //                                       FilteringTextInputFormatter.deny(
    //                                         RegExp(r'\|'),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                   const SizedBox(height: 10),
    //                                 ],
    //                               ),
    //                             ),
    //                             Visibility(
    //                               visible:
    //                                   selectedVariablesList.contains("Colores"),
    //                               child: Column(
    //                                 children: [
    //                                   TextFieldIcon(
    //                                     controller: _colorController,
    //                                     labelText: 'Ingrese Color',
    //                                     icon: Icons.color_lens,
    //                                     applyValidator: false,
    //                                     inputFormatters: [
    //                                       FilteringTextInputFormatter.deny(
    //                                         RegExp(r'\|'),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                   const SizedBox(height: 10),
    //                                 ],
    //                               ),
    //                             ),
    //                             Visibility(
    //                               visible:
    //                                   selectedVariablesList.contains("Tamaños"),
    //                               child: TextFieldIcon(
    //                                 controller: _dimensionController,
    //                                 labelText: 'Ingrese Tamaño',
    //                                 icon: Icons.numbers,
    //                                 applyValidator: false,
    //                                 inputFormatters: [
    //                                   FilteringTextInputFormatter.deny(
    //                                     RegExp(r'\|'),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                       const SizedBox(width: 20),
    //                       Visibility(
    //                         visible: selectedVariablesList.isNotEmpty,
    //                         child: Expanded(
    //                           child: Row(
    //                             children: [
    //                               Expanded(
    //                                 child: Column(
    //                                   crossAxisAlignment:
    //                                       CrossAxisAlignment.start,
    //                                   children: [
    //                                     Row(
    //                                       children: [
    //                                         Expanded(
    //                                           child: Column(
    //                                             crossAxisAlignment:
    //                                                 CrossAxisAlignment.start,
    //                                             children: [
    //                                               TextFieldIcon(
    //                                                 controller:
    //                                                     _inventaryController,
    //                                                 labelText: 'Cantidad',
    //                                                 icon: Icons.numbers,
    //                                                 inputType:
    //                                                     TextInputType.number,
    //                                                 inputFormatters: <TextInputFormatter>[
    //                                                   FilteringTextInputFormatter
    //                                                       .digitsOnly
    //                                                 ],
    //                                                 applyValidator: false,
    //                                               ),
    //                                             ],
    //                                           ),
    //                                         ),
    //                                       ],
    //                                     ),
    //                                   ],
    //                                 ),
    //                               ),
    //                               const SizedBox(width: 10),
    //                               _buttonAdd(context),
    //                               /*
    //                               ElevatedButton(
    //                                 onPressed: () async {
    //                                   // print(
    //                                   //     _inventaryController.text.toString());
    //                                   // print(
    //                                   //     _priceUnitController.text.toString());
    //                                   // print(_skuController.text.toString());
    //                                   // print(chosenSize);
    //                                   // print(chosenColor);
    //                                   // print(chosenDimension);
    //                                   if (_skuController.text.isEmpty) {
    //                                     showSuccessModal(
    //                                         context,
    //                                         "Por favor, ingrese un SKU.",
    //                                         Icons8.warning_1);
    //                                   } else {
    //                                     bool readyAdd = true;
    //                                     String mess = "";

    //                                     if (selectedVariablesList
    //                                             .contains("Tallas") &&
    //                                         _sizeController.text.isEmpty) {
    //                                       readyAdd = false;
    //                                       mess =
    //                                           "Por favor, ingrese una talla.";
    //                                     }
    //                                     if (selectedVariablesList
    //                                             .contains("Colores") &&
    //                                         _colorController.text.isEmpty) {
    //                                       readyAdd = false;
    //                                       mess = "Por favor, ingrese un Color.";
    //                                     }
    //                                     if (selectedVariablesList
    //                                             .contains("Tamaños") &&
    //                                         _dimensionController.text.isEmpty) {
    //                                       readyAdd = false;
    //                                       mess =
    //                                           "Por favor, ingrese un Tamaño.";
    //                                     }
    //                                     if (!readyAdd) {
    //                                       showSuccessModal(
    //                                           context, mess, Icons8.warning_1);
    //                                     } else {
    //                                       if (_inventaryController
    //                                               .text.isEmpty ||
    //                                           (int.tryParse(_inventaryController
    //                                                       .text) !=
    //                                                   null &&
    //                                               int.parse(_inventaryController
    //                                                       .text) <
    //                                                   1)) {
    //                                         showSuccessModal(
    //                                           context,
    //                                           "Por favor, ingrese una Cantidad válida.",
    //                                           Icons8.warning_1,
    //                                         );
    //                                       } else {
    //                                         //
    //                                         var variant;
    //                                         int idRandom =
    //                                             Random().nextInt(9000000) +
    //                                                 1000000;

    //                                         String sizeN = _sizeController.text
    //                                             .replaceAll(" ", "");
    //                                         String colorN = _colorController
    //                                             .text
    //                                             .replaceAll(" ", "");
    //                                         String dimensionN =
    //                                             _dimensionController.text
    //                                                 .replaceAll(" ", "");
    //                                         if (selectedVariablesList
    //                                                 .contains("Tallas") &&
    //                                             selectedVariablesList
    //                                                 .contains("Colores")) {
    //                                           variant = {
    //                                             "id": idRandom,
    //                                             "sku":
    //                                                 "${_skuController.text.toUpperCase()}${sizeN.toUpperCase()}${colorN.toUpperCase()}",
    //                                             // "${_skuController.text.toUpperCase()}${chosenSize}${chosenColor?.toUpperCase()}",
    //                                             "size": "$sizeN",
    //                                             "color": "$colorN",
    //                                             "inventory_quantity":
    //                                                 _inventaryController.text,
    //                                             "price":
    //                                                 _priceSuggestedController
    //                                                     .text,
    //                                           };
    //                                           //
    //                                           List<String> claves = [
    //                                             "size",
    //                                             "color"
    //                                           ];
    //                                           if (varianteExistente(
    //                                               variantsList,
    //                                               variant,
    //                                               claves)) {
    //                                             // print(
    //                                             //     "Ya existe una variante con talla: $chosenSize y color: $chosenColor");
    //                                           } else {
    //                                             variantsList.add(variant);
    //                                             selectedSizes.add(sizeN);
    //                                             selectedColores.add(colorN);

    //                                             calcuateStockTotal(
    //                                                 _inventaryController.text);
    //                                           }
    //                                           //
    //                                         } else if (selectedVariablesList
    //                                                 .contains("Tamaños") &&
    //                                             selectedVariablesList
    //                                                 .contains("Colores")) {
    //                                           variant = {
    //                                             "id": idRandom,
    //                                             "sku":
    //                                                 "${_skuController.text.toUpperCase()}${dimensionN.toUpperCase()}${colorN.toUpperCase()}",
    //                                             "dimension": "$dimensionN",
    //                                             "color": "$colorN",
    //                                             "inventory_quantity":
    //                                                 _inventaryController.text,
    //                                             "price":
    //                                                 _priceSuggestedController
    //                                                     .text,
    //                                           };
    //                                           //
    //                                           List<String> claves = [
    //                                             "dimension",
    //                                             "color"
    //                                           ];
    //                                           if (varianteExistente(
    //                                               variantsList,
    //                                               variant,
    //                                               claves)) {
    //                                             // print(
    //                                             //     "Ya existe una variante con tamaño: $chosenDimension y color: $chosenColor");
    //                                           } else {
    //                                             variantsList.add(variant);
    //                                             selectedDimensions
    //                                                 .add(dimensionN);
    //                                             selectedColores.add(colorN);

    //                                             calcuateStockTotal(
    //                                                 _inventaryController.text);
    //                                           }
    //                                           //
    //                                         } else if (selectedVariablesList
    //                                             .contains("Tallas")) {
    //                                           variant = {
    //                                             "id": idRandom,
    //                                             "sku":
    //                                                 "${_skuController.text.toUpperCase()}${sizeN.toUpperCase()}",
    //                                             "size": "$sizeN",
    //                                             "inventory_quantity":
    //                                                 _inventaryController.text,
    //                                             "price":
    //                                                 _priceSuggestedController
    //                                                     .text,
    //                                           };
    //                                           //
    //                                           List<String> claves = ["size"];
    //                                           if (varianteExistente(
    //                                               variantsList,
    //                                               variant,
    //                                               claves)) {
    //                                             // print(
    //                                             //     "Ya existe una variante con talla: $chosenSize");
    //                                           } else {
    //                                             variantsList.add(variant);
    //                                             selectedSizes.add(sizeN);

    //                                             calcuateStockTotal(
    //                                                 _inventaryController.text);
    //                                           }
    //                                           //
    //                                         } else if (selectedVariablesList
    //                                             .contains("Colores")) {
    //                                           variant = {
    //                                             "id": idRandom,
    //                                             "sku":
    //                                                 "${_skuController.text.toUpperCase()}${colorN.toUpperCase()}",
    //                                             "color": "$colorN",
    //                                             "inventory_quantity":
    //                                                 _inventaryController.text,
    //                                             "price":
    //                                                 _priceSuggestedController
    //                                                     .text,
    //                                           };
    //                                           //
    //                                           List<String> claves = ["color"];
    //                                           if (varianteExistente(
    //                                               variantsList,
    //                                               variant,
    //                                               claves)) {
    //                                             // print(
    //                                             //     "Ya existe una variante con color: $chosenColor");
    //                                           } else {
    //                                             variantsList.add(variant);
    //                                             selectedColores.add(colorN);

    //                                             calcuateStockTotal(
    //                                                 _inventaryController.text);
    //                                           }
    //                                           //
    //                                         } else if (selectedVariablesList
    //                                             .contains("Tamaños")) {
    //                                           variant = {
    //                                             "id": idRandom,
    //                                             "sku":
    //                                                 "${_skuController.text.toUpperCase()}${dimensionN.toUpperCase()}",
    //                                             "dimension": "$dimensionN",
    //                                             "inventory_quantity":
    //                                                 _inventaryController.text,
    //                                             "price":
    //                                                 _priceSuggestedController
    //                                                     .text,
    //                                           };
    //                                           //
    //                                           List<String> claves = [
    //                                             "dimension"
    //                                           ];
    //                                           if (varianteExistente(
    //                                               variantsList,
    //                                               variant,
    //                                               claves)) {
    //                                             // print(
    //                                             //     "Ya existe una variante con tamaño: $chosenDimension");
    //                                           } else {
    //                                             variantsList.add(variant);
    //                                             selectedDimensions
    //                                                 .add(dimensionN);

    //                                             calcuateStockTotal(
    //                                                 _inventaryController.text);
    //                                           }
    //                                           //
    //                                         }

    //                                         // variablesList.add(variant);
    //                                         // print(variantsList);
    //                                         //

    //                                         // print(variablesList);
    //                                         // print("selectedColores act:");
    //                                         // print(selectedColores);
    //                                         // print("selectedSizes act:");
    //                                         // print(selectedSizes);
    //                                         // print("selectedDimensions act:");
    //                                         // print(selectedDimensions);

    //                                         _priceUnitController.text =
    //                                             _priceWarehouseController.text;
    //                                         _inventaryController.clear();

    //                                         setState(() {});

    //                                         // print(selectedColores);
    //                                         // print(selectedTallas);
    //                                         // print(selectedDimensions);
    //                                       }
    //                                     }
    //                                   }
    //                                 },
    //                                 style: ElevatedButton.styleFrom(
    //                                   backgroundColor: Colors.green[400],
    //                                 ),
    //                                 child: const Text(
    //                                   "Añadir",
    //                                   style: TextStyle(
    //                                     fontWeight: FontWeight.bold,
    //                                   ),
    //                                 ),
    //                               ),
    //                             */
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 //
    //                 const SizedBox(height: 20),
    //                 Row(
    //                   children: [
    //                     Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           SizedBox(
    //                             width: (MediaQuery.of(context).size.width / 3) - 10,
    //                             child: TextFieldIcon(
    //                               controller: _stockController,
    //                               labelText: 'Cantidad Stock',
    //                               icon: Icons.numbers,
    //                               inputType: TextInputType.number,
    //                               inputFormatters: <TextInputFormatter>[
    //                                 FilteringTextInputFormatter.digitsOnly
    //                               ],
    //                               enabled:
    //                                   selectedType == 'SIMPLE' ? true : false,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 10),
    //                 Row(
    //                   children: [
    //                     Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           const Text('Bodega:'),
    //                           const SizedBox(height: 3),
    //                           SizedBox(
    //                             width: (MediaQuery.of(context).size.width / 2) - 10,
    //                             child: DropdownButtonFormField<String>(
    //                               isExpanded: true,
    //                               hint: Text(
    //                                 'Seleccione Bodega',
    //                                 style: TextStyle(
    //                                   fontSize: 14,
    //                                   color: Theme.of(context).hintColor,
    //                                   fontWeight: FontWeight.bold,
    //                                 ),
    //                               ),
    //                               items: warehousesToSelect.map((item) {
    //                                 var parts = item.split('-');
    //                                 var branchName = parts[1];
    //                                 var city = parts[2];
    //                                 return DropdownMenuItem(
    //                                   value: item,
    //                                   child: Text(
    //                                     '$branchName - $city',
    //                                     style: const TextStyle(
    //                                       fontSize: 14,
    //                                       fontWeight: FontWeight.bold,
    //                                     ),
    //                                   ),
    //                                 );
    //                               }).toList(),
    //                               value: selectedWarehouse,
    //                               onChanged: (value) {
    //                                 setState(() {
    //                                   selectedWarehouse = value as String;
    //                                 });
    //                               },
    //                               decoration: InputDecoration(
    //                                 fillColor: Colors.white,
    //                                 filled: true,
    //                                 border: OutlineInputBorder(
    //                                   borderRadius: BorderRadius.circular(5.0),
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(height: 10),
    //                 const Row(
    //                   children: [
    //                     Expanded(child: Text('Categoría')),
    //                   ],
    //                 ),
    //                 Row(
    //                   children: [
    //                     Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           SizedBox(
    //                             width: (MediaQuery.of(context).size.width / 2) - 10,
    //                             child: DropdownButtonFormField<String>(
    //                               isExpanded: true,
    //                               hint: Text(
    //                                 'Seleccione Categoria',
    //                                 style: TextStyle(
    //                                   fontSize: 14,
    //                                   color: Theme.of(context).hintColor,
    //                                   fontWeight: FontWeight.bold,
    //                                 ),
    //                               ),
    //                               items: categoriesToSelect.map((item) {
    //                                 var parts = item.split('-');
    //                                 var name = parts[0];
    //                                 return DropdownMenuItem(
    //                                   value: item,
    //                                   child: Text(
    //                                     '$name',
    //                                     style: const TextStyle(
    //                                       fontSize: 14,
    //                                       fontWeight: FontWeight.bold,
    //                                     ),
    //                                   ),
    //                                 );
    //                               }).toList(),
    //                               value: selectedCategory,
    //                               onChanged: (value) {
    //                                 selectedCategory = value;
    //                                 List<String> parts =
    //                                     selectedCategory!.split('-');

    //                                 if (!selectedCategoriesMap.any((category) =>
    //                                     category["id"] == parts[1])) {
    //                                   setState(() {
    //                                     selectedCategoriesMap.add({
    //                                       "id": parts[1],
    //                                       "name": parts[0],
    //                                     });
    //                                   });
    //                                 }
    //                               },
    //                               decoration: InputDecoration(
    //                                 fillColor: Colors.white,
    //                                 filled: true,
    //                                 border: OutlineInputBorder(
    //                                   borderRadius: BorderRadius.circular(5.0),
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 Row(
    //                   children: [
    //                     // const Expanded(
    //                     //     child: Column(
    //                     //         crossAxisAlignment: CrossAxisAlignment.start,
    //                     //         children: [])),
    //                     // const SizedBox(width: 20),
    //                     Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Wrap(
    //                             spacing: 8.0,
    //                             runSpacing: 8.0,
    //                             children: List.generate(
    //                                 selectedCategoriesMap.length, (index) {
    //                               String categoryName =
    //                                   selectedCategoriesMap[index]["name"] ??
    //                                       "";

    //                               return Chip(
    //                                 label: Text(categoryName),
    //                                 onDeleted: () {
    //                                   setState(() {
    //                                     selectedCategoriesMap.removeAt(index);
    //                                     // print("catAct: $selectedCategoriesMap");
    //                                   });
    //                                 },
    //                               );
    //                             }),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),

    //                 const SizedBox(height: 30),
    //                 Row(
    //                   children: [
    //                     Expanded(
    //                         child: Column(
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: [
    //                           const Text('Descripción'),
    //                           const SizedBox(height: 5),
    //                           Container(
    //                             margin:
    //                                 const EdgeInsets.symmetric(vertical: 10.0),
    //                             padding: const EdgeInsets.all(8.0),
    //                             height: 250,
    //                             //  width: 600,
    //                             decoration: BoxDecoration(
    //                                 color: Colors.white,
    //                                 borderRadius: BorderRadius.circular(10.0),
    //                                 border: Border.all(color: Colors.black)),
    //                             child: HtmlEditor(
    //                               description: "",
    //                               getValue: getValue,
    //                             ),
    //                           ),
    //                         ]))
    //                   ],
    //                 ),
    //                 const SizedBox(height: 10),

    //                 //
    //                 Container(
    //                   margin: const EdgeInsets.symmetric(vertical: 10),
    //                   padding: const EdgeInsets.all(10),
    //                   decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(10),
    //                     border: Border.all(
    //                       color: Colors.green,
    //                       width: 1.0,
    //                     ),
    //                   ),
    //                   child: Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Row(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         children: [
    //                           TextButton(
    //                             onPressed: () async {
    //                               final ImagePicker picker = ImagePicker();
    //                               imgsTemporales = [];
    //                               List<XFile>? imagenes =
    //                                   await picker.pickMultiImage();

    //                               if (imagenes != null && imagenes.isNotEmpty) {
    //                                 if (imagenes.length > 4) {
    //                                   // ignore: use_build_context_synchronously
    //                                   AwesomeDialog(
    //                                     width: 500,
    //                                     context: context,
    //                                     dialogType: DialogType.error,
    //                                     animType: AnimType.rightSlide,
    //                                     title: 'Error de selección',
    //                                     desc: 'Seleccione máximo 4 imágenes.',
    //                                     btnCancel: Container(),
    //                                     btnOkText: "Aceptar",
    //                                     btnOkColor: colors.colorGreen,
    //                                     btnCancelOnPress: () {},
    //                                     btnOkOnPress: () {},
    //                                   ).show();
    //                                 } else {
    //                                   setState(() {
    //                                     imgsTemporales.addAll(imagenes);
    //                                   });
    //                                 }
    //                               }
    //                             },
    //                             child: const Row(
    //                               children: [
    //                                 Icon(Icons.image),
    //                                 SizedBox(width: 10),
    //                                 Text('Seleccionar Imagen'),
    //                               ],
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                       const SizedBox(height: 15),
    //                       SizedBox(
    //                         height: 300,
    //                         child: GridView.builder(
    //                           gridDelegate:
    //                               const SliverGridDelegateWithFixedCrossAxisCount(
    //                             crossAxisCount: 2,
    //                             crossAxisSpacing: 10,
    //                             mainAxisSpacing: 10,
    //                             childAspectRatio: 1,
    //                           ),
    //                           itemCount: imgsTemporales.length,
    //                           itemBuilder: (BuildContext context, int index) {
    //                             return Stack(
    //                               children: [
    //                                 Image.network(
    //                                   imgsTemporales[index].path,
    //                                   fit: BoxFit.cover,
    //                                   width: double.infinity,
    //                                 ),
    //                                 Positioned(
    //                                   top: 5,
    //                                   right: 5,
    //                                   child: GestureDetector(
    //                                     onTap: () {
    //                                       setState(() {
    //                                         imgsTemporales.removeAt(index);
    //                                       });
    //                                     },
    //                                     child: const CircleAvatar(
    //                                       radius: 15,
    //                                       backgroundColor: Colors.red,
    //                                       child: Icon(
    //                                         Icons.close,
    //                                         size: 18,
    //                                         color: Colors.white,
    //                                       ),
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ],
    //                             );
    //                           },
    //                         ),
    //                       )
    //                     ],
    //                   ),
    //                 ),
    //                 //Priv
    //                 const SizedBox(height: 20),
    //                 Row(
    //                   children: [
    //                     const Text(
    //                       'Productos con dueño externo?',
    //                       style: TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                           color: Colors.black,
    //                           fontSize: 14),
    //                     ),
    //                     Checkbox(
    //                       value: sellerOwner,
    //                       onChanged: (value) {
    //                         //
    //                         setState(() {
    //                           sellerOwner = value!;
    //                         });
    //                         print(sellerOwner);
    //                       },
    //                       shape: CircleBorder(),
    //                     ),
    //                   ],
    //                 ),
    //                 Visibility(
    //                   visible: sellerOwner,
    //                   child: const Row(
    //                     children: [
    //                       Text(
    //                           'Ingrese el correo electrónico del propietario de la mercaderia'),
    //                     ],
    //                   ),
    //                 ),
    //                 const SizedBox(height: 3),
    //                 Visibility(
    //                   visible: sellerOwner,
    //                   child: TextFormField(
    //                     controller: _emailSellerOwnerController,
    //                     keyboardType: TextInputType.emailAddress,
    //                     decoration: InputDecoration(
    //                       fillColor: Colors.white,
    //                       filled: true,
    //                       border: OutlineInputBorder(
    //                         borderRadius: BorderRadius.circular(5.0),
    //                       ),
    //                     ),
    //                     onChanged: (email) {
    //                       setState(() {});
    //                     },
    //                   ),
    //                 ),
    //                 const SizedBox(height: 20),
    //                 Visibility(
    //                   visible: !sellerOwner,
    //                   child: const Row(
    //                     children: [
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             Text(
    //                               'Productos Privados ',
    //                               style: TextStyle(
    //                                   fontWeight: FontWeight.bold,
    //                                   color: Colors.black,
    //                                   fontSize: 14),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 const SizedBox(height: 10),
    //                 Visibility(
    //                   visible: !sellerOwner,
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             const Text('Correo Electrónico'),
    //                             const SizedBox(height: 3),
    //                             TextFormField(
    //                               controller: _emailController,
    //                               keyboardType: TextInputType.emailAddress,
    //                               decoration: InputDecoration(
    //                                 fillColor: Colors.white,
    //                                 filled: true,
    //                                 border: OutlineInputBorder(
    //                                   borderRadius: BorderRadius.circular(5.0),
    //                                 ),
    //                               ),
    //                               onChanged: (email) {
    //                                 setState(() {});
    //                               },
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 const SizedBox(height: 10),
    //                 Visibility(
    //                   visible: !sellerOwner,
    //                   child: Row(
    //                     children: [
    //                       Visibility(
    //                         visible: selectedType == "VARIABLE",
    //                         child: Expanded(
    //                           child: Column(
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: [
    //                               const Text('Variable'),
    //                               const SizedBox(height: 3),
    //                               SizedBox(
    //                                 width: (MediaQuery.of(context).size.width / 2) - 10,
    //                                 child: DropdownButtonFormField<String>(
    //                                   isExpanded: true,
    //                                   hint: Text(
    //                                     'Seleccione Variante',
    //                                     style: TextStyle(
    //                                       fontSize: 14,
    //                                       color: Theme.of(context).hintColor,
    //                                       fontWeight: FontWeight.bold,
    //                                     ),
    //                                   ),
    //                                   items: variantsToSelect.map((item) {
    //                                     return DropdownMenuItem(
    //                                       value: item,
    //                                       child: Text(
    //                                         item,
    //                                         style: const TextStyle(
    //                                           fontSize: 14,
    //                                           fontWeight: FontWeight.bold,
    //                                         ),
    //                                       ),
    //                                     );
    //                                   }).toList(),
    //                                   value: chosenVariantToReserv,
    //                                   onChanged: (value) {
    //                                     setState(() {
    //                                       chosenVariantToReserv =
    //                                           value as String;
    //                                       // _inventoryVariantController
    //                                       //     .text = getInventory(
    //                                       //         chosenVariant!.split('-')[0])
    //                                       //     .toString();
    //                                     });
    //                                   },
    //                                   decoration: InputDecoration(
    //                                     fillColor: Colors.white,
    //                                     filled: true,
    //                                     border: OutlineInputBorder(
    //                                       borderRadius:
    //                                           BorderRadius.circular(5.0),
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ),
    //                               const SizedBox(width: 20),
    //                             ],
    //                           ),
    //                         ),
    //                       ),
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             const Text('Cantidad'),
    //                             const SizedBox(height: 3),
    //                             TextFormField(
    //                               controller: _quantityReserveController,
    //                               // enabled: _emailController.text.isNotEmpty,
    //                               // enabled: chosenVariantToReserv != null,
    //                               enabled: selectedType == "VARIABLE"
    //                                   ? chosenVariantToReserv != null
    //                                   : _emailController.text.isNotEmpty,
    //                               keyboardType: TextInputType.number,
    //                               inputFormatters: <TextInputFormatter>[
    //                                 FilteringTextInputFormatter.digitsOnly
    //                               ],
    //                               decoration: InputDecoration(
    //                                 fillColor: Colors.white,
    //                                 filled: true,
    //                                 border: OutlineInputBorder(
    //                                   borderRadius: BorderRadius.circular(5.0),
    //                                 ),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                       const SizedBox(width: 20),
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             ElevatedButton(
    //                               onPressed: () async {
    //                                 if (_emailController.text.isNotEmpty) {
    //                                   if (!_emailController.text
    //                                       .contains('@')) {
    //                                     showSuccessModal(
    //                                         context,
    //                                         "Por favor, ingrese un correo electrónico válido.",
    //                                         Icons8.warning_1);
    //                                   } else {
    //                                     int? stock =
    //                                         int.tryParse(_stockController.text);
    //                                     int? cantidadPriv = int.tryParse(
    //                                         _quantityReserveController.text);

    //                                     if ((cantidadPriv! > stock!) ||
    //                                         (cantidadPriv == 0)) {
    //                                       showSuccessModal(
    //                                           context,
    //                                           "Por favor, revise la cantidad de los productos privados.",
    //                                           Icons8.warning_1);
    //                                     } else {
    //                                       print("Add en reservasToSend");

    //                                       String id_comercial = "";

    //                                       var response = await Connections()
    //                                           .getPersonalInfoAccountByEmail(
    //                                               _emailController.text
    //                                                   .toString());
    //                                       if (response != 1 || response != 2) {
    //                                         id_comercial =
    //                                             response['vendedores'][0]
    //                                                 ['id_master'];

    //                                         if (selectedType == "VARIABLE") {
    //                                           String skuVariant =
    //                                               chosenVariantToReserv
    //                                                   .toString();
    //                                           if (reservasToSend.any(
    //                                               (reserva) =>
    //                                                   reserva["sku"] ==
    //                                                       skuVariant &&
    //                                                   reserva["id_comercial"] ==
    //                                                       id_comercial)) {
    //                                             print(
    //                                                 "Ya existe este SKU en la lista para actualizar.");
    //                                           } else {
    //                                             int currentStockVariant =
    //                                                 getInventoryBySku(
    //                                                     skuVariant);
    //                                             if (int.parse(
    //                                                     _quantityReserveController
    //                                                         .text) >
    //                                                 currentStockVariant) {
    //                                               // ignore: use_build_context_synchronously
    //                                               showSuccessModal(
    //                                                   context,
    //                                                   "Revise la cantidad de los productos privados no pueden ser mayor a la existencia ",
    //                                                   Icons8.warning_1);
    //                                             } else {
    //                                               setState(() {
    //                                                 reservasToSend.add({
    //                                                   "sku": skuVariant
    //                                                       .toUpperCase(),
    //                                                   "stock":
    //                                                       _quantityReserveController
    //                                                           .text,
    //                                                   "email":
    //                                                       _emailController.text,
    //                                                   "id_comercial":
    //                                                       id_comercial,
    //                                                   "priceW":
    //                                                       _priceWarehouseController
    //                                                           .text,
    //                                                 });
    //                                               });

    //                                               _quantityReserveController
    //                                                   .text = "";
    //                                               // _emailController.text = "";
    //                                             }
    //                                           }
    //                                         } else {
    //                                           print("add selectedType SIMPLE");
    //                                           if (reservasToSend.any(
    //                                               (reserva) =>
    //                                                   reserva["sku"] ==
    //                                                       _skuController.text &&
    //                                                   reserva["id_comercial"] ==
    //                                                       id_comercial)) {
    //                                             print(
    //                                                 "ya existe este sku en list to upt");
    //                                           } else {
    //                                             if (int.parse(
    //                                                     _quantityReserveController
    //                                                         .text) >
    //                                                 int.parse(_stockController
    //                                                     .text)) {
    //                                               // ignore: use_build_context_synchronously
    //                                               showSuccessModal(
    //                                                   context,
    //                                                   "Revise la cantidad de los productos privados no pueden ser mayor a la existencia ",
    //                                                   Icons8.warning_1);
    //                                             } else {
    //                                               setState(() {
    //                                                 reservasToSend.add({
    //                                                   "sku": _skuController.text
    //                                                       .toUpperCase(),
    //                                                   "stock":
    //                                                       _quantityReserveController
    //                                                           .text,
    //                                                   "email":
    //                                                       _emailController.text,
    //                                                   "id_comercial":
    //                                                       id_comercial,
    //                                                   "priceW":
    //                                                       _priceWarehouseController
    //                                                           .text,
    //                                                 });
    //                                               });

    //                                               _quantityReserveController
    //                                                   .text = "";
    //                                               // _emailController.text = "";
    //                                             }
    //                                           }
    //                                         }
    //                                       } else if (response == []) {
    //                                         print(
    //                                             "Error no existe este email o no tiene una tienda relacionada");
    //                                       }
    //                                       //

    //                                       print("act reservasToSend");
    //                                       print(reservasToSend);
    //                                     }
    //                                   }
    //                                 }
    //                               },
    //                               style: ElevatedButton.styleFrom(
    //                                 backgroundColor: Colors.indigo[400],
    //                               ),
    //                               child: const Row(
    //                                 mainAxisSize: MainAxisSize.min,
    //                                 children: [
    //                                   Text(
    //                                     "Añadir",
    //                                     style: TextStyle(
    //                                         fontWeight: FontWeight.bold),
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //                 const SizedBox(height: 5),
    //                 Visibility(
    //                   visible: !sellerOwner,
    //                   child: Row(
    //                     children: [
    //                       Expanded(
    //                         child: Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           children: [
    //                             const Text('Reservas'),
    //                             const SizedBox(height: 3),
    //                             Visibility(
    //                               visible: true,
    //                               child: Wrap(
    //                                 spacing: 8.0,
    //                                 runSpacing: 8.0,
    //                                 children:
    //                                     reservasToSend.map<Widget>((reserva) {
    //                                   String chipLabel =
    //                                       "SKU: ${reserva['sku']}";

    //                                   // Asegúrate de que la clave 'email' exista en el mapa antes de intentar acceder
    //                                   if (reserva.containsKey('email')) {
    //                                     chipLabel +=
    //                                         " - Correo: ${reserva['email']}";
    //                                   }
    //                                   if (reserva.containsKey('stock')) {
    //                                     chipLabel +=
    //                                         " - Cantidad: ${reserva['stock']}";
    //                                   }

    //                                   return Chip(
    //                                     label: Text(chipLabel),
    //                                     onDeleted: () {
    //                                       setState(() {
    //                                         reservasToSend.remove(reserva);
    //                                       });
    //                                       print("reservasToSend actualizado:");
    //                                       print(reservasToSend);
    //                                     },
    //                                   );
    //                                 }).toList(),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    // ! esto hace el boton guargar
    //                 //
    //                 //btnGuardar
    //                 const SizedBox(height: 20),
    //                 Row(
    //                   children: [
    //                     Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.end,
    //                         children: [
    //                           ElevatedButton(
    //                             onPressed: () async {
    //                               if (formKey.currentState!.validate()) {
    //                                 getLoadingModal(context, false);

    //                                 bool ready = true;
    //                                 if (selectedType == null ||
    //                                     // selectedCategories.isEmpty ||
    //                                     // selectedCategory == null ||
    //                                     selectedCategoriesMap.isEmpty ||
    //                                     selectedWarehouse == null ||
    //                                     imgsTemporales.isEmpty) {
    //                                   Navigator.pop(context);

    //                                   // ignore: use_build_context_synchronously
    //                                   showSuccessModal(
    //                                       context,
    //                                       "Por favor, es necesario que seleccione el Tipo, Categoría/s, Bodega y cargue al menos una imagen.",
    //                                       Icons8.warning_1);
    //                                 } else {
    //                                   //
    //                                   String id_comercial = "";

    //                                   if (sellerOwner) {
    //                                     print("Add en reservasToSend");

    //                                     var response = await Connections()
    //                                         .getPersonalInfoAccountByEmail(
    //                                             _emailSellerOwnerController.text
    //                                                 .toString());

    //                                     if (response == 1 || response == 2) {
    //                                       Navigator.pop(context);
    //                                       // ignore: use_build_context_synchronously
    //                                       showSuccessModal(
    //                                           context,
    //                                           "Error, Este correo no se encuentra registrado.",
    //                                           Icons8.warning_1);
    //                                     } else {
    //                                       if (response['vendedores']
    //                                               .toString() !=
    //                                           "[]") {
    //                                         id_comercial =
    //                                             response['vendedores'][0]
    //                                                 ['id_master'];
    //                                         if (selectedType == "VARIABLE") {
    //                                           //
    //                                           // print(variantsList);
    //                                           for (var variant
    //                                               in variantsList) {
    //                                             var reserva = {
    //                                               "sku": variant['sku'],
    //                                               "stock": variant[
    //                                                   'inventory_quantity'],
    //                                               "email":
    //                                                   _emailSellerOwnerController
    //                                                       .text,
    //                                               "id_comercial": id_comercial,
    //                                               "priceW":
    //                                                   _priceWarehouseController
    //                                                       .text,
    //                                             };
    //                                             reservasToSend.add(reserva);
    //                                           }
    //                                         } else {
    //                                           setState(() {
    //                                             var reserva = {
    //                                               "sku": _skuController.text
    //                                                   .toUpperCase(),
    //                                               "stock":
    //                                                   _stockController.text,
    //                                               "email":
    //                                                   _emailSellerOwnerController
    //                                                       .text,
    //                                               "id_comercial": id_comercial,
    //                                               "priceW":
    //                                                   _priceWarehouseController
    //                                                       .text,
    //                                             };
    //                                             reservasToSend.add(reserva);
    //                                           });
    //                                         }
    //                                       } else {
    //                                         //
    //                                         Navigator.pop(context);
    //                                         // ignore: use_build_context_synchronously
    //                                         showSuccessModal(
    //                                             context,
    //                                             "Error, Este correo no tiene una tienda relacionada.",
    //                                             Icons8.warning_1);
    //                                       }
    //                                     }
    //                                   }

    //                                   if (double.tryParse(_weightController.text
    //                                               .trim()) ==
    //                                           null ||
    //                                       double.parse(_weightController.text
    //                                               .trim()) <=
    //                                           0) {
    //                                     ready = false;

    //                                     if (mounted) {
    //                                       Navigator.pop(context);
    //                                     }
    //                                     if (mounted) {
    //                                       showSuccessModal(
    //                                           context,
    //                                           "Error: El peso debe ser mayor a 0.",
    //                                           Icons8.warning_1);
    //                                     }
    //                                   }

    //                                   // print(reservasToSend);
    //                                   if (ready) {
    //                                     // /*
    //                                     if (selectedType == "SIMPLE") {
    //                                       optionsTypes = [];
    //                                       variantsList = [];
    //                                       int idRandom =
    //                                           Random().nextInt(9000000) +
    //                                               1000000;
    //                                       var variant = {
    //                                         "id": idRandom,
    //                                         "sku": _skuController.text
    //                                             .toUpperCase(),
    //                                         "price":
    //                                             _priceSuggestedController.text,
    //                                       };
    //                                       variantsList.add(variant);
    //                                     } else {
    //                                       isVariable = 1;
    //                                       if (selectedColores.isNotEmpty) {
    //                                         Set<String> uniqueColores =
    //                                             Set.from(selectedColores);
    //                                         var colores = {
    //                                           "name": "color",
    //                                           "values": uniqueColores.toList()
    //                                         };
    //                                         optionsTypes.add(colores);
    //                                       }

    //                                       if (selectedSizes.isNotEmpty) {
    //                                         Set<String> uniqueSizes =
    //                                             Set.from(selectedSizes);
    //                                         var tallas = {
    //                                           "name": "size",
    //                                           "values": uniqueSizes.toList()
    //                                         };
    //                                         optionsTypes.add(tallas);
    //                                       }

    //                                       if (selectedDimensions.isNotEmpty) {
    //                                         Set<String> uniqueDimensions =
    //                                             Set.from(selectedDimensions);
    //                                         var dimensions = {
    //                                           "name": "dimension",
    //                                           "values":
    //                                               uniqueDimensions.toList()
    //                                         };
    //                                         optionsTypes.add(dimensions);
    //                                       }
    //                                     }

    //                                     var urlsImgsListToSend =
    //                                         await saveImages(imgsTemporales);

    //                                     var featuresToSend = {
    //                                       "guide_name":
    //                                           _nameGuideController.text,
    //                                       "price_suggested":
    //                                           _priceSuggestedController.text,
    //                                       "sku":
    //                                           _skuController.text.toUpperCase(),
    //                                       "categories": selectedCategoriesMap,
    //                                       "description":
    //                                           _descriptionController.text,
    //                                       "type": selectedType,
    //                                       "variants": variantsList,
    //                                       "options": optionsTypes
    //                                     };

    //                                     // print("featuresToSend: $featuresToSend");
    //                                     if (urlsImgsListToSend.isNotEmpty) {
    //                                       //cuando ya se haya guardado las img en el servidor
    //                                       var response =
    //                                           await _productController
    //                                               .addProduct(ProductModel(
    //                                         productName: _nameController.text,
    //                                         stock: int.parse(
    //                                             _stockController.text),
    //                                         price: double.parse(
    //                                             _priceWarehouseController.text),
    //                                         weight: double.parse(
    //                                             _weightController.text),
    //                                         urlImg: urlsImgsListToSend,
    //                                         isvariable: isVariable,
    //                                         features: featuresToSend,
    //                                         warehouseId: int.parse(
    //                                             selectedWarehouse
    //                                                 .toString()
    //                                                 .split("-")[0]
    //                                                 .toString()),
    //                                         sellerOwnedId: sellerOwner
    //                                             ? int.parse(
    //                                                 id_comercial.toString())
    //                                             : null,
    //                                       ));
    //                                       var dataProductNew;

    //                                       if (response == []) {
    //                                         Navigator.pop(context);

    //                                         // ignore: use_build_context_synchronously
    //                                         AwesomeDialog(
    //                                           width: 500,
    //                                           context: context,
    //                                           dialogType: DialogType.error,
    //                                           animType: AnimType.rightSlide,
    //                                           title:
    //                                               'Se ha producido un error al crear el producto.',
    //                                           desc: '',
    //                                           btnCancelText: "Cancelar",
    //                                           btnOkText: "Aceptar",
    //                                           btnOkColor: Colors.green,
    //                                           btnOkOnPress: () async {},
    //                                           btnCancelOnPress: () async {},
    //                                         ).show();
    //                                         //
    //                                       } else {
    //                                         dataProductNew = response;

    //                                         String productId =
    //                                             response["product_id"]
    //                                                 .toString();

    //                                         Navigator.pop(context);

    //                                         // ignore: use_build_context_synchronously
    //                                         AwesomeDialog(
    //                                           width: 500,
    //                                           context: context,
    //                                           dialogType: DialogType.success,
    //                                           animType: AnimType.rightSlide,
    //                                           title:
    //                                               'Producto creado con éxito.',
    //                                           desc: '',
    //                                           btnOkText: "Aceptar",
    //                                           btnOkColor: Colors.green,
    //                                           btnOkOnPress: () async {
    //                                             Navigator.pop(context);
    //                                           },
    //                                         ).show();

    //                                         if (reservasToSend.isNotEmpty) {
    //                                           print(
    //                                               "need to send reservasToSend");
    //                                           print(reservasToSend);
    //                                           for (var reserva
    //                                               in reservasToSend) {
    //                                             var response =
    //                                                 await Connections()
    //                                                     .createReserve(
    //                                               productId,
    //                                               reserva['sku'],
    //                                               reserva['stock'],
    //                                               reserva['id_comercial'],
    //                                               reserva['priceW'],
    //                                             );
    //                                             if (response == 0) {
    //                                               print("successful reservar");
    //                                             } else {
    //                                               print("error al reservar");

    //                                               // ignore: use_build_context_synchronously
    //                                               AwesomeDialog(
    //                                                 width: 500,
    //                                                 context: context,
    //                                                 dialogType:
    //                                                     DialogType.error,
    //                                                 animType:
    //                                                     AnimType.rightSlide,
    //                                                 title:
    //                                                     'Se ha producido un error al reservar el producto.',
    //                                                 desc: '',
    //                                                 btnCancelText: "Cancelar",
    //                                                 btnOkText: "Aceptar",
    //                                                 btnOkColor: Colors.green,
    //                                                 btnOkOnPress: () async {},
    //                                                 btnCancelOnPress:
    //                                                     () async {},
    //                                               ).show();
    //                                             }
    //                                           }
    //                                         } else {
    //                                           print("NO hay reservasToSend");
    //                                         }
    //                                         // print(response);
    //                                       }
    //                                     } else {
    //                                       Navigator.pop(context);

    //                                       // ignore: use_build_context_synchronously
    //                                       showSuccessModal(
    //                                           context,
    //                                           "Se ha producido un error al crear el producto. No fue posible guardar la/s imágenes.",
    //                                           Icons8.warning_1);
    //                                     }
    //                                     // */
    //                                   }
    //                                   //
    //                                 }
    //                               } else {
    //                                 // ignore: use_build_context_synchronously
    //                                 showSuccessModal(
    //                                     context,
    //                                     "Existen campos vacíos.",
    //                                     Icons8.warning_1);

    //                                 // Posición a desplazarte (en este caso, el inicio, que es 0.0)
    //                                 // Duración de la animación
    //                                 // Curva de animación
    //                                 _scrollController.animateTo(
    //                                   0.0,
    //                                   duration:
    //                                       const Duration(milliseconds: 500),
    //                                   curve: Curves.easeInOut,
    //                                 );
    //                               }
    //                             },
    //                             style: ElevatedButton.styleFrom(
    //                               backgroundColor: Colors.green[400],
    //                             ),
    //                             child: const Row(
    //                               mainAxisSize: MainAxisSize.min,
    //                               children: [
    //                                 Icon(
    //                                   Icons.save_rounded,
    //                                   size: 24,
    //                                   color: Colors.white,
    //                                 ),
    //                                 Text(
    //                                   "Guardar",
    //                                   style: TextStyle(
    //                                       fontWeight: FontWeight.bold),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           const SizedBox(height: 10),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),

    //                 //
    //               ],
    //             )
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  Container webContainer(double screenWidth, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        height: screenHeight * 0.7, // Ajusta el alto a un 50% de la pantalla
        width: screenWidth * 0.8, // Ajusta el ancho a un 80% del valor pasado
        child: StepFormGlobal(
          numSteps: 3,
          contentstep1:
              ContainerStep1(MediaQuery.of(context).size.width, context),
          contentstep2:
              containerStep2(MediaQuery.of(context).size.width, context),
          // contentstep2: Text("2"),
          contentstep3:
              containerStep3(MediaQuery.of(context).size.width, context),
          onFinish: () async {
            // print("all good!");
            getLoadingModal(context, false);

            bool ready = true;
            if (selectedType == null ||
                // selectedCategories.isEmpty ||
                // selectedCategory == null ||
                selectedCategoriesMap.isEmpty ||
                selectedWarehouse == null ||
                imgsTemporales.isEmpty) {
              Navigator.pop(context);

              // ignore: use_build_context_synchronously
              showSuccessModal(
                  context,
                  "Por favor, es necesario que seleccione el Tipo, Categoría/s, Bodega y cargue al menos una imagen.",
                  Icons8.warning_1);
            } else {
              //
              String id_comercial = "";

              if (sellerOwner) {
                print("Add en reservasToSend");

                var response = await Connections()
                    .getPersonalInfoAccountByEmail(
                        _emailSellerOwnerController.text.toString());

                if (response == 1 || response == 2) {
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  showSuccessModal(
                      context,
                      "Error, Este correo no se encuentra registrado.",
                      Icons8.warning_1);
                } else {
                  if (response['vendedores'].toString() != "[]") {
                    id_comercial = response['vendedores'][0]['id_master'];
                    if (selectedType == "VARIABLE") {
                      //
                      // print(variantsList);
                      for (var variant in variantsList) {
                        var reserva = {
                          "sku": variant['sku'],
                          "stock": variant['inventory_quantity'],
                          "email": _emailSellerOwnerController.text,
                          "id_comercial": id_comercial,
                          "priceW": _priceWarehouseController.text,
                        };
                        reservasToSend.add(reserva);
                      }
                    } else {
                      setState(() {
                        var reserva = {
                          "sku": _skuController.text.toUpperCase(),
                          "stock": _stockController.text,
                          "email": _emailSellerOwnerController.text,
                          "id_comercial": id_comercial,
                          "priceW": _priceWarehouseController.text,
                        };
                        reservasToSend.add(reserva);
                      });
                    }
                  } else {
                    //
                    Navigator.pop(context);
                    // ignore: use_build_context_synchronously
                    showSuccessModal(
                        context,
                        "Error, Este correo no tiene una tienda relacionada.",
                        Icons8.warning_1);
                  }
                }
              }

              if (double.tryParse(_weightController.text.trim()) == null ||
                  double.parse(_weightController.text.trim()) <= 0) {
                ready = false;

                if (mounted) {
                  Navigator.pop(context);
                }
                if (mounted) {
                  showSuccessModal(context,
                      "Error: El peso debe ser mayor a 0.", Icons8.warning_1);
                }
              }

              // print(reservasToSend);
              if (ready) {
                // /*
                if (selectedType == "SIMPLE") {
                  optionsTypes = [];
                  variantsList = [];
                  int idRandom = Random().nextInt(9000000) + 1000000;
                  var variant = {
                    "id": idRandom,
                    "sku": _skuController.text.toUpperCase(),
                    "price": _priceSuggestedController.text,
                  };
                  variantsList.add(variant);
                } else {
                  isVariable = 1;
                  if (selectedColores.isNotEmpty) {
                    Set<String> uniqueColores = Set.from(selectedColores);
                    var colores = {
                      "name": "color",
                      "values": uniqueColores.toList()
                    };
                    optionsTypes.add(colores);
                  }

                  if (selectedSizes.isNotEmpty) {
                    Set<String> uniqueSizes = Set.from(selectedSizes);
                    var tallas = {
                      "name": "size",
                      "values": uniqueSizes.toList()
                    };
                    optionsTypes.add(tallas);
                  }

                  if (selectedDimensions.isNotEmpty) {
                    Set<String> uniqueDimensions = Set.from(selectedDimensions);
                    var dimensions = {
                      "name": "dimension",
                      "values": uniqueDimensions.toList()
                    };
                    optionsTypes.add(dimensions);
                  }
                }

                var urlsImgsListToSend = await saveImages(imgsTemporales);

                var featuresToSend = {
                  "guide_name": _nameGuideController.text,
                  "price_suggested": _priceSuggestedController.text,
                  "sku": _skuController.text.toUpperCase(),
                  "categories": selectedCategoriesMap,
                  "description": _descriptionController.text,
                  "type": selectedType,
                  "variants": variantsList,
                  "options": optionsTypes
                };

                // print("featuresToSend: $featuresToSend");
                if (urlsImgsListToSend.isNotEmpty) {
                  //cuando ya se haya guardado las img en el servidor
                  var response =
                      await _productController.addProduct(ProductModel(
                    productName: _nameController.text,
                    stock: int.parse(_stockController.text),
                    price: double.parse(_priceWarehouseController.text),
                    weight: double.parse(_weightController.text),
                    urlImg: urlsImgsListToSend,
                    isvariable: isVariable,
                    features: featuresToSend,
                    warehouseId: int.parse(
                        selectedWarehouse.toString().split("-")[0].toString()),
                    sellerOwnedId:
                        sellerOwner ? int.parse(id_comercial.toString()) : null,
                  ));
                  var dataProductNew;

                  if (response == []) {
                    Navigator.pop(context);

                    // ignore: use_build_context_synchronously
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.error,
                      animType: AnimType.rightSlide,
                      title: 'Se ha producido un error al crear el producto.',
                      desc: '',
                      btnCancelText: "Cancelar",
                      btnOkText: "Aceptar",
                      btnOkColor: Colors.green,
                      btnOkOnPress: () async {},
                      btnCancelOnPress: () async {},
                    ).show();
                    //
                  } else {
                    dataProductNew = response;

                    String productId = response["product_id"].toString();

                    Navigator.pop(context);

                    // ignore: use_build_context_synchronously
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Producto creado con éxito.',
                      desc: '',
                      btnOkText: "Aceptar",
                      btnOkColor: Colors.green,
                      btnOkOnPress: () async {
                        Navigator.pop(context);
                      },
                    ).show();

                    if (reservasToSend.isNotEmpty) {
                      print("need to send reservasToSend");
                      print(reservasToSend);
                      for (var reserva in reservasToSend) {
                        var response = await Connections().createReserve(
                          productId,
                          reserva['sku'],
                          reserva['stock'],
                          reserva['id_comercial'],
                          reserva['priceW'],
                        );
                        if (response == 0) {
                          print("successful reservar");
                        } else {
                          print("error al reservar");

                          // ignore: use_build_context_synchronously
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title:
                                'Se ha producido un error al reservar el producto.',
                            desc: '',
                            btnCancelText: "Cancelar",
                            btnOkText: "Aceptar",
                            btnOkColor: Colors.green,
                            btnOkOnPress: () async {},
                            btnCancelOnPress: () async {},
                          ).show();
                        }
                      }
                    } else {
                      print("NO hay reservasToSend");
                    }
                    // print(response);
                  }
                } else {
                  Navigator.pop(context);

                  // ignore: use_build_context_synchronously
                  showSuccessModal(
                      context,
                      "Se ha producido un error al crear el producto. No fue posible guardar la/s imágenes.",
                      Icons8.warning_1);
                }
                // */
              }
              //
            }
          },
          onFinishOptionElse: () {
            // ignore: use_build_context_synchronously
            showSuccessModal(
                context, "Existen campos vacíos.", Icons8.warning_1);

            // Posición a desplazarte (en este caso, el inicio, que es 0.0)
            // Duración de la animación
            // Curva de animación
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
        ));
  }

  Container customDropdownType(
      BuildContext context, isMobile, labelText, controller, isExpanded) {
    return Container(
      height: 40,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Fondo gris
        // color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: isExpanded,
          hint: Text(
            labelText,
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: types
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStylesSystem().ralewayStyle(
                        isMobile == 1 ? 11 : 14,
                        FontWeight.w500,
                        ColorsSystem().colorLabels),
                  ),
                ),
              )
              .toList(),
          value: controller,
          onChanged: (String? value) {
            if (_skuController.text.isEmpty ||
                _priceWarehouseController.text.isEmpty ||
                _priceSuggestedController.text.isEmpty) {
              showSuccessModal(
                  context,
                  "Por favor, ingrese el SKU, Precio Bodega y el Precio sugerido del producto",
                  Icons8.warning_1);
            } else {
              if (double.parse(_priceWarehouseController.text) <= 0 &&
                  double.parse(_priceSuggestedController.text) <= 0) {
                showSuccessModal(
                    context,
                    "Por favor, ingrese el precio Bodega y el sugerido de los productos validos",
                    Icons8.warning_1);
              } else {
                setState(() {
                  selectedColores = [];
                  selectedSizes = [];
                  selectedDimensions = [];
                  optionsTypes = [];
                  variantsList = [];
                  _stockController.clear();
                  selectedVariablesList.clear();
                  if (value != null) {
                    selectedType = value;
                  }
                  // print("selectedType: $selectedType");
                });
              }
            }
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Fondo blanco del menú desplegable
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

  Container customDropdownWarehouse(
      BuildContext context, isMobile, labelText, controller, isExpanded) {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Fondo gris
        // color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: isExpanded,
          hint: Text(
            labelText,
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: warehousesToSelect.map((item) {
            var parts = item.split('-');
            var branchName = parts[1];
            var city = parts[2];
            return DropdownMenuItem(
              value: item,
              child: Text(
                '$branchName - $city',
                style: TextStylesSystem().ralewayStyle(
                    14, FontWeight.w500, ColorsSystem().colorLabels),
              ),
            );
          }).toList(),
          value: selectedWarehouse,
          onChanged: (value) {
            setState(() {
              selectedWarehouse = value as String;
            });
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Fondo blanco del menú desplegable
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

  Container customDropdownCategory(
      BuildContext context, isMobile, labelText, controller, isExpanded) {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Fondo gris
        // color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: isExpanded,
          hint: Text(
            labelText,
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
          ),
          items: categoriesToSelect.map((item) {
            var parts = item.split('-');
            var name = parts[0];
            return DropdownMenuItem(
              value: item,
              child: Text(
                '$name',
                style: TextStylesSystem().ralewayStyle(
                    14, FontWeight.w500, ColorsSystem().colorLabels),
              ),
            );
          }).toList(),
          value: selectedCategory,
          onChanged: (value) {
            selectedCategory = value;
            List<String> parts = selectedCategory!.split('-');

            if (!selectedCategoriesMap
                .any((category) => category["id"] == parts[1])) {
              setState(() {
                selectedCategoriesMap.add({
                  "id": parts[1],
                  "name": parts[0],
                });
              });
            }
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Fondo blanco del menú desplegable
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

  Container customDropdownTypeNV(
      BuildContext context, isMobile, labelText, controller, isExpanded) {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Fondo gris
        // color: Colors.white, // Fondo blanco para el botón
        borderRadius:
            BorderRadius.circular(isMobile == 1 ? 5 : 10), // Bordes redondeados
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: isExpanded,
          hint: Text(
            labelText,
            style: TextStylesSystem().ralewayStyle(isMobile == 1 ? 11 : 14,
                FontWeight.w500, ColorsSystem().colorSection2),
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
            if (_skuController.text.isEmpty ||
                _priceWarehouseController.text.isEmpty ||
                _priceSuggestedController.text.isEmpty) {
              showSuccessModal(
                  context,
                  "Por favor, ingrese el SKU, Precio Bodega y el Precio sugerido del producto",
                  Icons8.warning_1);
            } else {
              if (double.parse(_priceWarehouseController.text) <= 0 &&
                  double.parse(_priceSuggestedController.text) <= 0) {
                showSuccessModal(
                    context,
                    "Por favor, ingrese el precio Bodega y el sugerido de los productos validos",
                    Icons8.warning_1);
              } else {
                setState(() {
                  selectedColores = [];
                  selectedSizes = [];
                  selectedDimensions = [];
                  optionsTypes = [];
                  variantsList = [];
                  _stockController.clear();
                  selectedVariablesList.clear();
                  if (value != null) {
                    selectedType = value;
                  }
                  // print("selectedType: $selectedType");
                });
              }
            }
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: isMobile == 1 ? 20 : 40,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Fondo blanco del botón
              borderRadius: BorderRadius.circular(
                  isMobile == 1 ? 5 : 10), // Bordes redondeados
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200, // Fondo blanco del menú desplegable
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

  Container CustomTextFormComplete(
      height,
      controller,
      maxLines,
      readOnly,
      inputDecorationLabel,
      validator,
      inputFormatter,
      enabled,
      TextInputType keyboardType,
      style) {
    return Container(
        height: height != 0 ? height : 30,
        child: TextFormField(
          style: style == 1
              ? TextStylesSystem().ralewayStyle(
                  12, // Tamaño de la fuente
                  FontWeight.w500, // Peso de la fuente medio
                  ColorsSystem().colorLabels, // Color del label
                )
              : TextStylesSystem().montserratStyle(
                  14, // Tamaño de la fuente
                  FontWeight.w500, // Peso de la fuente medio
                  ColorsSystem().colorLabels, // Color del label
                ),
          controller: controller,
          maxLines: null,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: inputDecorationLabel,
            labelStyle:
                // style ==  1 ?
                TextStylesSystem().ralewayStyle(
              14, // Tamaño de la fuente
              FontWeight.w500, // Peso de la fuente medio
              ColorsSystem().colorSection2, // Color del label
            ),
            // : TextStylesSystem().montserratStyle(
            //   14, // Tamaño de la fuente
            //   FontWeight.w500, // Peso de la fuente medio
            //   ColorsSystem().colorSection2, // Color del label
            // ) ,
            filled: true,
            fillColor: Colors.grey.shade200, // Fondo gris
            contentPadding:
                const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0), // Bordes circulares
              borderSide: BorderSide.none, // Sin borde visible
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(
                color: ColorsSystem()
                    .colorSelected, // Color del borde cuando está enfocado
                width: 2.0, // Grosor del borde
              ),
            ),
          ),
          validator: validator,
          inputFormatters: inputFormatter,
          enabled: enabled,
        ));
  }

  Column ContainerStep1(double screenWidth, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomLabelRow("Nombre del Producto"),
      CustomTextFormComplete(40, _nameController, null, false,
          "Nombre del Producto", null, null, true, TextInputType.text, 1),
      SizedBox(
        height: 10,
      ),
      CustomLabelRow("Nombre Para Visualización"),
      CustomTextFormComplete(40, _nameGuideController, null, false,
          "Nombre Para Visualización", null, null, true, TextInputType.text, 1),
      SizedBox(
        height: 10,
      ),
      CustomLabelRow("SKU"),
      CustomTextFormComplete(
          40,
          _skuController,
          null,
          false,
          "SKU",
          null,
          [
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z0-9]'),
            ),
          ],
          true,
          TextInputType.text,
          0),
      SizedBox(
        height: 10,
      ),
      CustomLabelRow("Peso (kg)"),
      CustomTextFormComplete(
          40,
          _weightController,
          null,
          false,
          "Peso (kg)",
          null,
          <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
          ],
          true,
          TextInputType.text,
          0),
      SizedBox(
        height: 10,
      ),
      CustomLabelRow("Precio Bodega"),
      CustomTextFormComplete(
          40,
          _priceWarehouseController,
          null,
          false,
          "Precio Bodega",
          null,
          <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
          ],
          true,
          TextInputType.text,
          0),
      SizedBox(
        height: 10,
      ),
      CustomLabelRow("Precio Sugerido"),
      CustomTextFormComplete(
          40,
          _priceSuggestedController,
          null,
          false,
          "Precio Sugerido",
          null,
          <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
          ],
          true,
          TextInputType.text,
          0),

      // customDropdownTypeNV(context, 0, "Tipo", selectedType, true)
    ]);
  }

  Column containerStep2(double screenWidth, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        // children: [
        Row(
          children: [
            Expanded(
              flex: 2, // Ajusta el espacio proporcional para este widget
              child: customDropdownType(context, 0, "Tipo", selectedType, true),
            ),
            SizedBox(width: 10), // Espaciado entre los widgets
            Expanded(
              flex: 1, // Ajusta el espacio proporcional para este widget
              child: CustomTextFormComplete(
                  40,
                  _stockController,
                  null,
                  false,
                  "Cantidad Stock",
                  null,
                  <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                  selectedType == 'SIMPLE',
                  TextInputType.number,
                  0),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Visibility(
          visible: selectedType == 'VARIABLE',
          // visible: true,
          child: Container(
            constraints: BoxConstraints(maxHeight: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Variables',
                    style: TextStylesSystem().ralewayStyle(
                        14, FontWeight.w500, ColorsSystem().colorLabels),
                  ),
                ),
                const SizedBox(height: 3),
                Visibility(
                  visible: selectedType == 'VARIABLE',
                  // visible: true,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: variantsList.map<Widget>((variable) {
                      String chipLabel = "SKU: ${variable['sku']}";
                      if (variable.containsKey('size')) {
                        chipLabel += " - Talla: ${variable['size']}";
                      }
                      if (variable.containsKey('color')) {
                        chipLabel += " - Color: ${variable['color']}";
                      }
                      if (variable.containsKey('dimension')) {
                        chipLabel += " - Tamaño: ${variable['dimension']}";
                      }
                      // chipLabel +=
                      //     " - Precio: \$${variable['price']}";
                      chipLabel +=
                          " - Cantidad: ${variable['inventory_quantity']}";

                      String skuVar = variable['sku'];
                      if (!variantsToSelect.contains(skuVar)) {
                        variantsToSelect.add(skuVar);
                      } else {
                        // print(
                        //     'El SKU ya está presente en la lista.');
                      }

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

                            if (variable.containsKey('dimension')) {
                              String dimension = variable['dimension'];
                              selectedDimensions.remove(dimension);
                            }

                            variantsList.remove(variable);

                            if (variable.containsKey('sku')) {
                              variantsToSelect.remove(variable);
                            }
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

        // ! todo esto es lo ultimo ultimo que estoy analizando
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
                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 3) - 10,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200, // Fondo gris
                          borderRadius:
                              BorderRadius.circular(5), // Bordes redondeados
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Seleccione Variable',
                              style: TextStylesSystem().ralewayStyle(14,
                                  FontWeight.w500, ColorsSystem().colorLabels),
                            ),
                            items: typesVariables
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: TextStylesSystem().ralewayStyle(
                                            14,
                                            FontWeight.w500,
                                            ColorsSystem().colorLabels),
                                      ),
                                    ))
                                .toList(),
                            value: selectedVariable,
                            onChanged: (String? value) {
                              setState(() {
                                selectedVariable = value;
                                if (!(selectedVariablesList
                                    .contains(selectedVariable))) {
                                  if (value != null) {
                                    if (((selectedVariablesList
                                                .contains("Tallas")) &&
                                            selectedVariable == "Tamaños") ||
                                        ((selectedVariablesList
                                                .contains("Tamaños")) &&
                                            selectedVariable == "Tallas")) {
                                      // Restricción para combinaciones no permitidas
                                    } else {
                                      selectedVariable = value;
                                      selectedVariablesList
                                          .add(selectedVariable.toString());
                                    }
                                    _priceUnitController.text =
                                        _priceWarehouseController.text;
                                  }
                                }
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                            iconStyleData: const IconStyleData(
                              openMenuIcon: Icon(Icons.arrow_drop_up),
                              icon: Icon(Icons
                                  .arrow_drop_down), // Icono para desplegar el menú
                            ),
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
        const SizedBox(height: 5),
        Visibility(
          visible: selectedType == 'VARIABLE',
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: selectedVariablesList.map<Widget>((variable) {
                        return Chip(
                          label: Text(
                            variable,
                            style: TextStylesSystem().montserratStyle(12,
                                FontWeight.w500, ColorsSystem().colorLabels),
                          ),
                          onDeleted: () {
                            setState(() {
                              selectedVariablesList.remove(variable);
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
        ),
        const SizedBox(height: 20),
        //**** */
        Visibility(
          visible: selectedType == 'VARIABLE',
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: selectedVariablesList.contains("Tallas"),
                      child: Column(
                        children: [
                          CustomTextFormComplete(
                              40,
                              _sizeController,
                              null,
                              false,
                              "Ingrese Tallas",
                              null,
                              [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'\|'),
                                ),
                              ],
                              true,
                              TextInputType.text,
                              0),
                          // TextFieldIcon(
                          //   controller: _sizeController,
                          //   labelText: 'Ingrese Talla',
                          //   icon: Icons.numbers,
                          //   applyValidator: false,
                          //   inputFormatters: [
                          //     FilteringTextInputFormatter.deny(
                          //       RegExp(r'\|'),
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: selectedVariablesList.contains("Colores"),
                      child: Column(
                        children: [
                          CustomTextFormComplete(
                              40,
                              _colorController,
                              null,
                              false,
                              "Ingrese Color",
                              null,
                              [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'\|'),
                                ),
                              ],
                              true,
                              TextInputType.text,
                              0),
                          // TextFieldIcon(
                          //   controller: _colorController,
                          //   labelText: 'Ingrese Color',
                          //   icon: Icons.color_lens,
                          //   applyValidator: false,
                          //   inputFormatters: [
                          //     FilteringTextInputFormatter.deny(
                          //       RegExp(r'\|'),
                          //     ),
                          //   ],
                          // ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: selectedVariablesList.contains("Tamaños"),
                      child: CustomTextFormComplete(
                          40,
                          _dimensionController,
                          null,
                          false,
                          "Ingrese Tamaño",
                          null,
                          [
                            FilteringTextInputFormatter.deny(
                              RegExp(r'\|'),
                            ),
                          ],
                          true,
                          TextInputType.text,
                          0),

                      // TextFieldIcon(
                      //   controller: _dimensionController,
                      //   labelText: 'Ingrese Tamaño',
                      //   icon: Icons.numbers,
                      //   applyValidator: false,
                      //   inputFormatters: [
                      //     FilteringTextInputFormatter.deny(
                      //       RegExp(r'\|'),
                      //     ),
                      //   ],
                      // ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Visibility(
                visible: selectedVariablesList.isNotEmpty,
                child: Expanded(
                  child: Row(
                    children: [
                      Expanded(
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
                                      CustomTextFormComplete(
                                          40,
                                          _inventaryController,
                                          null,
                                          false,
                                          "Catidad",
                                          null,
                                          <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          true,
                                          TextInputType.number,
                                          0),
                                      // TextFieldIcon(
                                      //   controller: _inventaryController,
                                      //   labelText: 'Cantidad',
                                      //   icon: Icons.numbers,
                                      //   inputType: TextInputType.number,
                                      //   inputFormatters: <TextInputFormatter>[
                                      //     FilteringTextInputFormatter.digitsOnly
                                      //   ],
                                      //   applyValidator: false,
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buttonAdd(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ! **************************************************

        SizedBox(
          height: 10,
        ),
        CustomLabelRow("Bodega"),
        customDropdownWarehouse(context, 0, "Bodega", selectedWarehouse, true),
        const SizedBox(
          height: 10,
        ),
        CustomLabelRow("Categoría"),
        customDropdownCategory(context, 0, "Categoría", selectedCategory, true),
        const SizedBox(
          height: 10,
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
                    children:
                        List.generate(selectedCategoriesMap.length, (index) {
                      String categoryName =
                          selectedCategoriesMap[index]["name"] ?? "";

                      return Chip(
                        color: MaterialStatePropertyAll(
                            ColorsSystem().colorInitialContainer),
                        label: Text(
                          categoryName,
                          style: TextStylesSystem().ralewayStyle(
                              14, FontWeight.w500, ColorsSystem().colorLabels),
                        ),
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
        const SizedBox(
          height: 10,
        ),
        CustomLabelRow("Descripción"),
        Row(
          children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    padding: const EdgeInsets.all(8.0),
                    height: 250,
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
          ],
        ),
      ],
    );
  }

  Column containerStep3(double screenWidth, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomLabelRow("Carga de Imágenes"),
      containerImages(),
      const SizedBox(height: 10),
      rowPrivateProduct(),
      Visibility(
        visible: sellerOwner,
        child: Row(
          children: [
            Text(
              'Ingrese el correo electrónico del propietario de la mercaderia',
              style: TextStylesSystem().ralewayStyle(
                  14, FontWeight.w500, ColorsSystem().colorLabels),
            ),
          ],
        ),
      ),
      const SizedBox(height: 5),
      Visibility(
        visible: sellerOwner,
        child: CustomTextFormComplete(40, _emailSellerOwnerController, null,
            false, "Email", null, null, true, TextInputType.emailAddress, 0),
        // TextFormField(
        //   controller: _emailSellerOwnerController,
        //   keyboardType: TextInputType.emailAddress,
        //   decoration: InputDecoration(
        //     fillColor: Colors.white,
        //     filled: true,
        //     border: OutlineInputBorder(
        //       borderRadius: BorderRadius.circular(5.0),
        //     ),
        //   ),
        //   onChanged: (email) {
        //     setState(() {});
        //   },
        // ),
      ),

      // ! option 2 "privatizar productos"
      const SizedBox(height: 20),
      Visibility(
        visible: !sellerOwner,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Productos Privados ',
                    style: TextStylesSystem().ralewayStyle(
                        14, FontWeight.w500, ColorsSystem().colorLabels),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Visibility(
        visible: !sellerOwner,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correo Electrónico',
                    style: TextStylesSystem().ralewayStyle(
                        14, FontWeight.w500, ColorsSystem().colorLabels),
                  ),
                  const SizedBox(height: 3),
                  CustomTextFormComplete(40, _emailController, null, false,
                      "Email", null, null, true, TextInputType.emailAddress, 0),

                  // TextFormField(
                  //   controller: _emailController,
                  //   keyboardType: TextInputType.emailAddress,
                  //   decoration: InputDecoration(
                  //     fillColor: Colors.white,
                  //     filled: true,
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(5.0),
                  //     ),
                  //   ),
                  //   onChanged: (email) {
                  //     setState(() {});
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
      // ! esta parte se descomento y es la que estoy evaluando
      const SizedBox(height: 10),
      Visibility(
        visible: !sellerOwner,
        child: Row(
          children: [
            Visibility(
              visible: selectedType == "VARIABLE",
              // visible: true,
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Variable',
                      style: TextStylesSystem().ralewayStyle(
                          14, FontWeight.w500, ColorsSystem().colorLabels),
                    ),
                    const SizedBox(height: 3),
                    Container(
                        height: 40,
                        // width: MediaQuery.of(context).size.width,
                        // width: (MediaQuery.of(context).size.width / 2) - 10,
                        // width: (MediaQuery.of(context).size.width ) - 10,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200, // Fondo gris
                          // color: Colors.white, // Fondo blanco para el botón
                          borderRadius:
                              BorderRadius.circular(10), // Bordes redondeados
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Seleccione Variante',
                              style: TextStylesSystem().ralewayStyle(14,
                                  FontWeight.w500, ColorsSystem().colorLabels),
                            ),
                            items: variantsToSelect.map((item) {
                              return DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item,
                                  style: TextStylesSystem().ralewayStyle(
                                      14,
                                      FontWeight.w500,
                                      ColorsSystem().colorLabels),
                                ),
                              );
                            }).toList(),
                            value: chosenVariantToReserv,
                            onChanged: (value) {
                              setState(() {
                                chosenVariantToReserv = value as String;
                                // _inventoryVariantController
                                //     .text = getInventory(
                                //         chosenVariant!.split('-')[0])
                                //     .toString();
                              });
                            },
                            // decoration: InputDecoration(
                            //   fillColor: Colors.white,
                            //   filled: true,
                            //   border: OutlineInputBorder(
                            //     borderRadius: BorderRadius.circular(5.0),
                            //   ),
                            // ),
                            buttonStyleData: ButtonStyleData(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              // height: 40,
                              // width: 140,
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey.shade200, // Fondo blanco del botón
                                borderRadius: BorderRadius.circular(
                                    10), // Bordes redondeados
                              ),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey
                                    .shade200, // Fondo blanco del menú desplegable
                                borderRadius: BorderRadius.circular(
                                    10), // Bordes redondeados
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                            iconStyleData: const IconStyleData(
                              openMenuIcon: Icon(Icons.arrow_drop_up),
                              icon: Icon(Icons
                                  .arrow_drop_down), // Icono para desplegar el menú
                            ),
                          ),
                        )),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cantidad',
                      style: TextStylesSystem().ralewayStyle(
                          14, FontWeight.w500, ColorsSystem().colorLabels)),
                  const SizedBox(height: 3),
                  CustomTextFormComplete(
                      40,
                      _quantityReserveController,
                      null,
                      false,
                      "Cantidad",
                      null,
                      <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      selectedType == "VARIABLE"
                          ? chosenVariantToReserv != null
                          : _emailController.text.isNotEmpty,
                      TextInputType.number,
                      0),
                  // TextFormField(
                  //   controller: _quantityReserveController,
                  //   // enabled: _emailController.text.isNotEmpty,
                  //   // enabled: chosenVariantToReserv != null,
                  //   enabled: selectedType == "VARIABLE"
                  //       ? chosenVariantToReserv != null
                  //       : _emailController.text.isNotEmpty,
                  //   keyboardType: TextInputType.number,
                  //   inputFormatters: <TextInputFormatter>[
                  //     FilteringTextInputFormatter.digitsOnly
                  //   ],
                  //   decoration: InputDecoration(
                  //     fillColor: Colors.white,
                  //     filled: true,
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(5.0),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(""),
                  Container(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_emailController.text.isNotEmpty) {
                          if (!_emailController.text.contains('@')) {
                            showSuccessModal(
                                context,
                                "Por favor, ingrese un correo electrónico válido.",
                                Icons8.warning_1);
                          } else {
                            int? stock = int.tryParse(_stockController.text);
                            int? cantidadPriv =
                                int.tryParse(_quantityReserveController.text);

                            if ((cantidadPriv! > stock!) ||
                                (cantidadPriv == 0)) {
                              showSuccessModal(
                                  context,
                                  "Por favor, revise la cantidad de los productos privados.",
                                  Icons8.warning_1);
                            } else {
                              print("Add en reservasToSend");

                              String id_comercial = "";

                              var response = await Connections()
                                  .getPersonalInfoAccountByEmail(
                                      _emailController.text.toString());
                              if (response != 1 || response != 2) {
                                id_comercial =
                                    response['vendedores'][0]['id_master'];

                                if (selectedType == "VARIABLE") {
                                  String skuVariant =
                                      chosenVariantToReserv.toString();
                                  if (reservasToSend.any((reserva) =>
                                      reserva["sku"] == skuVariant &&
                                      reserva["id_comercial"] ==
                                          id_comercial)) {
                                    print(
                                        "Ya existe este SKU en la lista para actualizar.");
                                  } else {
                                    int currentStockVariant =
                                        getInventoryBySku(skuVariant);
                                    if (int.parse(
                                            _quantityReserveController.text) >
                                        currentStockVariant) {
                                      // ignore: use_build_context_synchronously
                                      showSuccessModal(
                                          context,
                                          "Revise la cantidad de los productos privados no pueden ser mayor a la existencia ",
                                          Icons8.warning_1);
                                    } else {
                                      setState(() {
                                        reservasToSend.add({
                                          "sku": skuVariant.toUpperCase(),
                                          "stock":
                                              _quantityReserveController.text,
                                          "email": _emailController.text,
                                          "id_comercial": id_comercial,
                                          "priceW":
                                              _priceWarehouseController.text,
                                        });
                                      });

                                      _quantityReserveController.text = "";
                                      // _emailController.text = "";
                                    }
                                  }
                                } else {
                                  print("add selectedType SIMPLE");
                                  if (reservasToSend.any((reserva) =>
                                      reserva["sku"] == _skuController.text &&
                                      reserva["id_comercial"] ==
                                          id_comercial)) {
                                    print("ya existe este sku en list to upt");
                                  } else {
                                    if (int.parse(
                                            _quantityReserveController.text) >
                                        int.parse(_stockController.text)) {
                                      // ignore: use_build_context_synchronously
                                      showSuccessModal(
                                          context,
                                          "Revise la cantidad de los productos privados no pueden ser mayor a la existencia ",
                                          Icons8.warning_1);
                                    } else {
                                      setState(() {
                                        reservasToSend.add({
                                          "sku":
                                              _skuController.text.toUpperCase(),
                                          "stock":
                                              _quantityReserveController.text,
                                          "email": _emailController.text,
                                          "id_comercial": id_comercial,
                                          "priceW":
                                              _priceWarehouseController.text,
                                        });
                                      });

                                      _quantityReserveController.text = "";
                                      // _emailController.text = "";
                                    }
                                  }
                                }
                              } else if (response == []) {
                                print(
                                    "Error no existe este email o no tiene una tienda relacionada");
                              }
                              //

                              print("act reservasToSend");
                              print(reservasToSend);
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Añadir",
                            style: TextStylesSystem().ralewayStyle(
                                14, FontWeight.w600, Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 5),
      Visibility(
        visible: !sellerOwner,
        // visible: true,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reservas'),
                  const SizedBox(height: 3),
                  Visibility(
                    visible: true,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: reservasToSend.map<Widget>((reserva) {
                        String chipLabel = "SKU: ${reserva['sku']}";

                        // Asegúrate de que la clave 'email' exista en el mapa antes de intentar acceder
                        if (reserva.containsKey('email')) {
                          chipLabel += " - Correo: ${reserva['email']}";
                        }
                        if (reserva.containsKey('stock')) {
                          chipLabel += " - Cantidad: ${reserva['stock']}";
                        }

                        return Chip(
                          label: Text(chipLabel),
                          onDeleted: () {
                            setState(() {
                              reservasToSend.remove(reserva);
                            });
                            print("reservasToSend actualizado:");
                            print(reservasToSend);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Row rowPrivateProduct() {
    return Row(
      children: [
        Text(
          'Producto Privado?',
          style: TextStylesSystem()
              .ralewayStyle(14, FontWeight.w600, ColorsSystem().colorLabels),
        ),
        Checkbox(
          value: sellerOwner,
          onChanged: (value) {
            //
            setState(() {
              sellerOwner = value!;
            });
            print(sellerOwner);
          },
          shape: CircleBorder(),
        ),
      ],
    );
  }

  Container containerImages() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ColorsSystem().colorLabels,
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
                  List<XFile>? imagenes = await picker.pickMultiImage();

                  if (imagenes != null && imagenes.isNotEmpty) {
                    if (imagenes.length > 4) {
                      // ignore: use_build_context_synchronously
                      AwesomeDialog(
                        width: 500,
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error de selección',
                        desc: 'Seleccione máximo 4 imágenes.',
                        btnCancel: Container(),
                        btnOkText: "Aceptar",
                        btnOkColor: colors.colorGreen,
                        btnCancelOnPress: () {},
                        btnOkOnPress: () {},
                      ).show();
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
          SizedBox(
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: imgsTemporales.length,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    Image.network(
                      imgsTemporales[index].path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            imgsTemporales.removeAt(index);
                          });
                        },
                        child: const CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Row CustomLabelRow(text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            text,
            style: TextStylesSystem().ralewayStyle(
              14, // Tamaño de la fuente
              FontWeight.w500, // Peso de la fuente medio
              ColorsSystem().colorLabels, // Color del label
            ),
          ),
        )
      ],
    );
  }

  ElevatedButton _buttonAdd(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // print(
        //     _inventaryController.text.toString());
        // print(
        //     _priceUnitController.text.toString());
        // print(_skuController.text.toString());
        // print(chosenSize);
        // print(chosenColor);
        // print(chosenDimension);
        if (_skuController.text.isEmpty) {
          showSuccessModal(
              context, "Por favor, ingrese un SKU.", Icons8.warning_1);
        } else {
          bool readyAdd = true;
          String mess = "";

          if (selectedVariablesList.contains("Tallas") &&
              _sizeController.text.isEmpty) {
            readyAdd = false;
            mess = "Por favor, ingrese una talla.";
          }
          if (selectedVariablesList.contains("Colores") &&
              _colorController.text.isEmpty) {
            readyAdd = false;
            mess = "Por favor, ingrese un Color.";
          }
          if (selectedVariablesList.contains("Tamaños") &&
              _dimensionController.text.isEmpty) {
            readyAdd = false;
            mess = "Por favor, ingrese un Tamaño.";
          }
          if (!readyAdd) {
            showSuccessModal(context, mess, Icons8.warning_1);
          } else {
            if (_inventaryController.text.isEmpty ||
                (int.tryParse(_inventaryController.text) != null &&
                    int.parse(_inventaryController.text) < 1)) {
              showSuccessModal(
                context,
                "Por favor, ingrese una Cantidad válida.",
                Icons8.warning_1,
              );
            } else {
              //
              var variant;
              int idRandom = Random().nextInt(9000000) + 1000000;

              String sizeN = _sizeController.text.replaceAll(" ", "");
              String colorN = _colorController.text.replaceAll(" ", "");
              String dimensionN = _dimensionController.text.replaceAll(" ", "");
              if (selectedVariablesList.contains("Tallas") &&
                  selectedVariablesList.contains("Colores")) {
                variant = {
                  "id": idRandom,
                  "sku":
                      "${_skuController.text.toUpperCase()}${sizeN.toUpperCase()}${colorN.toUpperCase()}",
                  // "${_skuController.text.toUpperCase()}${chosenSize}${chosenColor?.toUpperCase()}",
                  "size": "$sizeN",
                  "color": "$colorN",
                  "inventory_quantity": _inventaryController.text,
                  "price": _priceSuggestedController.text,
                };
                //
                List<String> claves = ["size", "color"];
                if (varianteExistente(variantsList, variant, claves)) {
                  // print(
                  //     "Ya existe una variante con talla: $chosenSize y color: $chosenColor");
                } else {
                  variantsList.add(variant);
                  selectedSizes.add(sizeN);
                  selectedColores.add(colorN);

                  calcuateStockTotal(_inventaryController.text);
                }
                //
              } else if (selectedVariablesList.contains("Tamaños") &&
                  selectedVariablesList.contains("Colores")) {
                variant = {
                  "id": idRandom,
                  "sku":
                      "${_skuController.text.toUpperCase()}${dimensionN.toUpperCase()}${colorN.toUpperCase()}",
                  "dimension": "$dimensionN",
                  "color": "$colorN",
                  "inventory_quantity": _inventaryController.text,
                  "price": _priceSuggestedController.text,
                };
                //
                List<String> claves = ["dimension", "color"];
                if (varianteExistente(variantsList, variant, claves)) {
                  // print(
                  //     "Ya existe una variante con tamaño: $chosenDimension y color: $chosenColor");
                } else {
                  variantsList.add(variant);
                  selectedDimensions.add(dimensionN);
                  selectedColores.add(colorN);

                  calcuateStockTotal(_inventaryController.text);
                }
                //
              } else if (selectedVariablesList.contains("Tallas")) {
                variant = {
                  "id": idRandom,
                  "sku":
                      "${_skuController.text.toUpperCase()}${sizeN.toUpperCase()}",
                  "size": "$sizeN",
                  "inventory_quantity": _inventaryController.text,
                  "price": _priceSuggestedController.text,
                };
                //
                List<String> claves = ["size"];
                if (varianteExistente(variantsList, variant, claves)) {
                  // print(
                  //     "Ya existe una variante con talla: $chosenSize");
                } else {
                  variantsList.add(variant);
                  selectedSizes.add(sizeN);

                  calcuateStockTotal(_inventaryController.text);
                }
                //
              } else if (selectedVariablesList.contains("Colores")) {
                variant = {
                  "id": idRandom,
                  "sku":
                      "${_skuController.text.toUpperCase()}${colorN.toUpperCase()}",
                  "color": "$colorN",
                  "inventory_quantity": _inventaryController.text,
                  "price": _priceSuggestedController.text,
                };
                //
                List<String> claves = ["color"];
                if (varianteExistente(variantsList, variant, claves)) {
                  // print(
                  //     "Ya existe una variante con color: $chosenColor");
                } else {
                  variantsList.add(variant);
                  selectedColores.add(colorN);

                  calcuateStockTotal(_inventaryController.text);
                }
                //
              } else if (selectedVariablesList.contains("Tamaños")) {
                variant = {
                  "id": idRandom,
                  "sku":
                      "${_skuController.text.toUpperCase()}${dimensionN.toUpperCase()}",
                  "dimension": "$dimensionN",
                  "inventory_quantity": _inventaryController.text,
                  "price": _priceSuggestedController.text,
                };
                //
                List<String> claves = ["dimension"];
                if (varianteExistente(variantsList, variant, claves)) {
                  // print(
                  //     "Ya existe una variante con tamaño: $chosenDimension");
                } else {
                  variantsList.add(variant);
                  selectedDimensions.add(dimensionN);

                  calcuateStockTotal(_inventaryController.text);
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

              _priceUnitController.text = _priceWarehouseController.text;
              _inventaryController.clear();

              setState(() {});

              // print(selectedColores);
              // print(selectedTallas);
              // print(selectedDimensions);
            }
          }
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
    );
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

  getValue(value) {
    _descriptionController.text = value;
    return value;
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

  int getInventoryBySku(String sku) {
    for (Map<String, dynamic> variant in variantsList) {
      if (variant.containsKey("sku") && variant["sku"] == sku) {
        int inventory_quantity = int.parse(variant["inventory_quantity"]);
        return inventory_quantity;
      }
    }
    return 0; // O cualquier otro valor que represente "no encontrado"
  }

//
}

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
      padding: const EdgeInsets.only(bottom: 10),
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

//
class MenuCategories extends StatelessWidget {
  final Function(String) onItemSelected;

  const MenuCategories({Key? key, required this.onItemSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchMenu(onItemSelected: onItemSelected);
  }
}
