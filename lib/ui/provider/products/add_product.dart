import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/html_editor.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';

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

  List<String> warehouses = [];
  List warehouseList = [];

  String? selectedWarehouse;
  List<String> categories = UIUtils.categories();

  String? selectedCategory;
  List<String> selectedCategories = [];

  List<String> features = [];
  String? img_url;

  List<String> types = UIUtils.typesProduct();
  String? selectedType;
  List<String> typesVariables = UIUtils.typesVariables();

  String? selectedVariable;
  String? chosenColor;
  String? chosenSize;
  String? chosenDimension;
  List<String> selectedColores = [];
  List<String> selectedTallas = [];
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

  late ProductController _productController;

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  @override
  void initState() {
    loadData();
    _productController = ProductController();
    super.initState();
  }

  loadData() async {
    var responseBodegas = await Connections().getWarehousesProvider0(
        int.parse(sharedPrefs!.getString("idProvider").toString()));
    warehouseList = responseBodegas;
    if (warehouseList != null) {
      warehouseList.forEach((warehouse) {
        setState(() {
          warehouses
              .add('${warehouse["branch_name"]}-${warehouse["warehouse_id"]}');
        });
      });
    }

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
          width: MediaQuery.of(context).size.width,
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
                              const Text('Precio'),
                              const SizedBox(height: 3),
                              TextFormField(
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
                                    selectedType = value;
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Visibility(
                          visible: selectedType == 'VARIABLE',
                          child: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Datos'),
                                const SizedBox(height: 3),
                                Visibility(
                                  visible: selectedType == 'VARIABLE',
                                  child: TextFormField(
                                    controller: _showVariantsController,
                                    maxLines: null,
                                    readOnly: true,
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
                                      if (value != null) {
                                        selectedVariable = value;
                                        selectedVariablesList
                                            .add(selectedVariable.toString());
                                        print(selectedVariablesList);
                                        _priceUnitController.text =
                                            _priceController.text;
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
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text('Cantidad'),
                                      const SizedBox(height: 3),
                                      TextField(
                                        controller: _inventaryController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Cantidad',
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text('Precio'),
                                      const SizedBox(height: 3),
                                      TextField(
                                        controller: _priceUnitController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}$')),
                                        ],
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Precio',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (int.parse(_inventaryController.text) <
                                        1) {
                                      showSuccessModal(
                                          context,
                                          "Por favor, ingrese una Cantidad válida.",
                                          Icons8.alert);
                                    } else {
                                      // if (selectedVariable == "Colores") {
                                      //   selectedColores.add(chosenColor!);
                                      //   var variant = {
                                      //     "color": "$chosenColor",
                                      //     "inventory": _stockUntController.text
                                      //   };
                                      //   variantsList.add(variant);
                                      //   print(variant);
                                      //   //
                                      // } else if (selectedVariable == "Tallas") {
                                      //   selectedTallas.add(chosenSize!);
                                      //   var variant = {
                                      //     "talla": "$chosenSize",
                                      //     "inventory": _stockUntController.text
                                      //   };
                                      //   variantsList.add(variant);
                                      //   //
                                      // } else if (selectedVariable ==
                                      //     "Tamaños") {
                                      //   selectedDimensions
                                      //       .add(chosenDimension!);
                                      //   var variant = {
                                      //     "dimension": "$chosenDimension",
                                      //     "inventory": _stockUntController.text
                                      //   };
                                      //   variantsList.add(variant);
                                      //   //
                                      // }
                                      var variant;
                                      if (selectedVariablesList
                                              .contains("Tallas") &&
                                          selectedVariablesList
                                              .contains("Colores")) {
                                        variant = {
                                          "sku": "123Test",
                                          "name_guide": "name for guide",
                                          "size": "$chosenSize",
                                          "color": "$chosenColor",
                                          "inventory":
                                              _inventaryController.text,
                                          "price": _priceUnitController.text
                                        };
                                        selectedTallas.add(chosenSize!);
                                        selectedColores.add(chosenColor!);
                                      } else if (selectedVariablesList
                                          .contains("Tallas")) {
                                        variant = {
                                          "sku": "123Test",
                                          "name_guide": "name for guide",
                                          "size": "$chosenSize",
                                          "inventory":
                                              _inventaryController.text,
                                          "price": _priceUnitController.text
                                        };
                                        selectedTallas.add(chosenSize!);
                                      } else if (selectedVariablesList
                                          .contains("Colores")) {
                                        variant = {
                                          "sku": "123Test",
                                          "name_guide": "name for guide",
                                          "color": "$chosenColor",
                                          "inventory":
                                              _inventaryController.text,
                                          "price": _priceUnitController.text
                                        };
                                        selectedColores.add(chosenColor!);
                                      } else if (selectedVariablesList
                                          .contains("Tamaños")) {
                                        variant = {
                                          "sku": "123Test",
                                          "name_guide": "name for guide",
                                          "dimension": "$chosenDimension",
                                          "inventory":
                                              _inventaryController.text,
                                          "price": _priceUnitController.text
                                        };
                                        selectedDimensions
                                            .add(chosenDimension!);
                                      }

                                      variablesList.add(variant);
                                      // print(variantsList);
                                      //

                                      showVariants(variablesList);

                                      calcuateStockTotal(
                                          _inventaryController.text);

                                      _priceUnitController.text =
                                          _priceController.text;
                                      _inventaryController.clear();
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
                                items: warehouses
                                    .map((item) => DropdownMenuItem(
                                          value: item,
                                          child: Text(
                                            item.split('-')[0],
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
                    ]),
                    const SizedBox(height: 10),
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
                                  final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery);

                                  if (image != null && image.path.isNotEmpty) {
                                    var responseI =
                                        await Connections().postDoc(image);
                                    // print("ImgSaveStrapi: $responseI");

                                    setState(() {
                                      img_url = responseI[1];
                                    });
                                    urlsImgsList.add(img_url!);
                                    // Navigator.pop(context);
                                    // Navigator.pop(context);
                                  } else {
                                    print("No img");
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              img_url != null
                                  ? SizedBox(
                                      width: 300,
                                      height: 400,
                                      child: Image.network(
                                        "$generalServer$img_url",
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                                          var colores = {
                                            "colors": selectedColores
                                          };
                                          variablesTypes.add(colores);
                                        }

                                        if (selectedTallas.isNotEmpty) {
                                          var tallas = {
                                            "sizes": selectedTallas
                                          };
                                          variablesTypes.add(tallas);
                                        }

                                        if (selectedDimensions.isNotEmpty) {
                                          var dimensions = {
                                            "dimensions": selectedDimensions
                                          };
                                          variablesTypes.add(dimensions);
                                        }
                                      }

                                      var featuresToSend = [
                                        {"type": selectedType},
                                        {"categories": selectedCategories},
                                        {
                                          "description":
                                              _descriptionController.text
                                        },
                                        {"variables_types": variablesTypes},
                                        {"variables": variablesList}
                                      ];

                                      print("featuresToSend: $featuresToSend");

                                      print(urlsImgsList);

                                      // await Connections().createProduct0(
                                      //     _nameController.text,
                                      //     _stockController.text,
                                      //     featuresToSend,
                                      //     _priceController.text,
                                      //     urlsImgsList,
                                      //     isVariable,
                                      //     selectedWarehouse
                                      //         .toString()
                                      //         .split("-")[1]
                                      //         .toString());

                                      _productController
                                          .addProduct(ProductModel(
                                        productName: _nameController.text,
                                        stock: int.parse(_stockController.text),
                                        price:
                                            double.parse(_priceController.text),
                                        urlImg: urlsImgsList,
                                        isvariable: isVariable,
                                        features: featuresToSend,
                                        warehouseId: int.parse(selectedWarehouse
                                            .toString()
                                            .split("-")[1]
                                            .toString()),
                                      ));

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
}
