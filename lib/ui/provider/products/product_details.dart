import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:frontend/ui/widgets/html_editor.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProductDetails extends StatefulWidget {
  final Map data;
  final Function function;
  // final List? data;

  const ProductDetails({super.key, required this.function, required this.data});
  // const ProductDetails({super.key});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
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
  List<String> categories = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  var data = {};
  List<dynamic> dataL = [];
  List<Map<String, dynamic>> listaProduct = [];
  List<String> listCategories = UIUtils.categories();

  var selectedCat;
  var dataFeatures = [];
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

  @override
  void initState() {
    super.initState();
    _productController = ProductController();
    _warehouseController = WrehouseController();
    loadTextEdtingControllers(widget.data);
    getWarehouses();
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

  loadTextEdtingControllers(newData) {
    ProductModel product = ProductModel.fromJson(newData);
    codigo = product.productId.toString();
    _nameController.text = product.productName.toString();
    createdAt = formatDate(product.createdAt.toString());
    approved = product.approved!;
    _stockController.text = product.stock.toString();
    isVariable = int.parse(product.isvariable.toString());
    typeValue = product.isvariable == 1 ? "VARIABLE" : "SIMPLE";
    _priceController.text = product.price.toString();
    warehouseValue =
        '${product.warehouse!.id.toString()}-${product.warehouse!.branchName.toString()}-${product.warehouse!.city.toString()}';

    urlsImgsList = product.urlImg != null &&
            product.urlImg.isNotEmpty &&
            product.urlImg.toString() != "[]"
        ? (jsonDecode(product.urlImg) as List).cast<String>()
        : [];
    print(product.urlImg);
    //
    dataFeatures = jsonDecode(product.features);
    _nameGuideController.text = findValue(dataFeatures, 'guide_name') ?? "";

    categories = findCategories(dataFeatures);

    // // print("img incoming: ${img_url.toString()}");
    if (product.isvariable == 1) {
      List<Map<String, dynamic>> variables = dataFeatures
          .where((feature) => feature.containsKey("variables"))
          .expand((feature) => (feature["variables"] as List<dynamic>)
              .cast<Map<String, dynamic>>())
          .toList();

      variablesText = variables.map((variable) {
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

        return variableDetails.join('; ');
      }).join('\n');
    }

    setState(() {});
  }

  dynamic findValue(List<dynamic> dataFeatures, String featureName) {
    for (var feature in dataFeatures) {
      if (feature.containsKey(featureName)) {
        return feature[featureName];
      }
    }
    return null; // Valor predeterminado si no se encuentra la característica
  }

  List<String> findCategories(List<dynamic> dataFeatures) {
    var categoriesFeature = dataFeatures.firstWhere(
      (feature) => feature.containsKey('categories'),
      orElse: () => null,
    );

    return categoriesFeature != null
        ? List<String>.from(categoriesFeature['categories'] ?? [])
        : [];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
          width: MediaQuery.of(context).size.width * 0.75,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      codigo,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Creado:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      createdAt,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Aprobado:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    approved == 1
                                        ? const Icon(Icons.check,
                                            color: Colors.green)
                                        : approved == 2
                                            ? const Icon(Icons.access_time,
                                                color: Colors.blue)
                                            : const Icon(Icons.close,
                                                color: Colors.red)
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
                                const Text('Producto'),
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
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                    'Nombre para mostrar en la guia de envio:'),
                                const SizedBox(height: 3),
                                TextFormField(
                                  controller: _nameGuideController,
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
                      Row(children: [
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
                                        const Text(
                                          "Tipo: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
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
                                            variablesText,
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
                      ]),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Existencia",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 150,
                                      child: TextFormField(
                                        controller: _stockController,
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
                                    const Text(
                                      "Precio Total",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 150,
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
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Categorias",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: categories.map<Widget>((category) {
                                    return Chip(
                                      label: Text(category),
                                      onDeleted: () {
                                        setState(() {
                                          categories.remove(category);
                                          // print("catAct: $categories");
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                DropdownButton<String>(
                                  hint: const Text("Seleccione una categoría"),
                                  value: selectedCat,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCat = value;
                                      if (value != null) {
                                        categories.add(value);
                                      }
                                    });
                                  },
                                  items: listCategories.map((String category) {
                                    return DropdownMenuItem<String>(
                                      value: category,
                                      child: Text(category),
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
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item,
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
                                    description: findValue(
                                            dataFeatures, 'description') ??
                                        "",
                                    getValue: getValue,
                                  ),
                                ),
                              ]))
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.green,
                            width: 1.0, // Ancho del borde
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
                                      Text('Cambiar Imagen/es'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (imgsTemporales
                                    .isEmpty) // Mostrar solo si imgsTemporales está vacío
                                  for (String imageUrl in urlsImgsList)
                                    if (imageUrl.isNotEmpty &&
                                        imageUrl != "" &&
                                        imageUrl.toString() != "[]")
                                      Container(
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        child: SizedBox(
                                          width: 250,
                                          height: 300,
                                          child: Image.network(
                                            "$generalServer${imageUrl.toString()}",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                            SizedBox(
                              height: 300,
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
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    getLoadingModal(context, false);
                                    // print(img_url);

                                    var featuresToSend = [
                                      {"guide_name": _nameGuideController.text},
                                      {
                                        "feature_name": "type",
                                        "value": typeValue
                                      },
                                      {
                                        "feature_name": "categories",
                                        "value": categories
                                      },
                                      {
                                        "feature_name": "description",
                                        "value": _descriptionController.text
                                      },
                                    ];

                                    // var responseUpt = await Connections()
                                    //     .updateProduct0(codigo, {
                                    //   "product_name":
                                    //       _nameController.text.toString(),
                                    //   "stock": int.parse(
                                    //       _stockController.text.toString()),
                                    //   "features": featuresToSend,
                                    //   "price": double.parse(
                                    //       _priceController.text.toString()),
                                    //   "url_img": img_url.toString(),
                                    //   "warehouse_id": warehouseValue
                                    //       .toString()
                                    //       .split("-")[1]
                                    //       .toString()
                                    // });

                                    // _productController.editProduct(ProductModel(
                                    //   productName: _nameController.text,
                                    //   stock: int.parse(_stockController.text),
                                    //   price:
                                    //       double.parse(_priceController.text),
                                    //   urlImg: urlsImgsList,
                                    //   isvariable: isVariable,
                                    //   features: featuresToSend,
                                    //   warehouseId: int.parse(warehouseValue
                                    //       .toString()
                                    //       .split("-")[0]
                                    //       .toString()),
                                    // ));

                                    Navigator.pop(context);
                                    Navigator.pop(context);

                                    //  await loadData();
                                    await widget.function();
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

  formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -5);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
  }
}

//class

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
