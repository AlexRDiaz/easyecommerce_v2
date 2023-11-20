import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
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
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String createdAt = "";
  String warehouse = "";
  String img_url = "";
  var typeValue;
  var descripcion;
  List<String> categories = [];
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  var data = {};
  List<dynamic> dataL = [];
  List<Map<String, dynamic>> listaProduct = [];
  List<String> listCategories = [
    "Hogar",
    "Mascota",
    "Moda",
    "Tecnología",
    "Cocina",
    "Belleza"
  ];

  List<String> types = ["SIMPLE", "VARIABLE"];

  var selectedCat;
  List<dynamic> dataFeatures = [];
  @override
  void initState() {
    super.initState();
    loadTextEdtingControllers(widget.data);
  }

  loadData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      // print("data incoming:");
      // print(widget.data);
      // var response =
      //     await Connections().getProductByID(widget.data['id'], 'warehouse');

      // print("res: $response");
      // dataL = widget.dataL!;

      // var productoEspecifico = dataL.firstWhere(
      //   (producto) => producto['id'].toString() == widget.data['id'].toString(),
      //   orElse: () => null,
      // );

      // listaProduct.add(productoEspecifico);

      // if (mounted) {
      //   setState(() {
      //     data = response;
      //     loadTextEdtingControllers(data);
      //   });
      // }
      // print("data> $data");

      // Future.delayed(const Duration(milliseconds: 500), () {
      // Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      // });
      setState(() {});
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(context, "Error al guardar los datos");
    }
  }

  loadTextEdtingControllers(newData) {
    data = newData;
    codigo = data['product_id'].toString();
    _nameController.text = data['product_name'];
    createdAt = formatDate(data['created_at'].toString());
    _stockController.text = data['stock'].toString();
    _priceController.text = data['price'].toString();
    warehouse = data['warehouse']['branch_name'].toString();

    img_url = data['url_img'].toString();
    if (img_url == "null" || img_url == "") {
      img_url = "";
    }

    // print("img incoming: ${img_url.toString()}");

    dataFeatures = json.decode(data['features']);
    print(dataFeatures);
    // type = findValue(dataFeatures, 'type')?.toString();
    typeValue = findValue(dataFeatures, 'type');
    _typeController.text = typeValue;
    descripcion = findValue(dataFeatures, 'description');
    _descriptionController.text = descripcion;
    // Acceder a las categorías
    // Acceder a las categorías
    categories = findCategories(dataFeatures);
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
          // width: MediaQuery.of(context).size.width,
          width: 700,
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
                                      "Código:",
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Producto",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
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
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Text(
                            "Tipo",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 20),
                          DropdownButton<String>(
                            hint: const Text("Seleccione un tipo"),
                            value: typeValue,
                            onChanged: (value) {
                              setState(() {
                                typeValue = value ?? "";
                              });
                            },
                            items: types.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
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
                                    const Text(
                                      "Stock",
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Bodega",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  warehouse,
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
                                ElevatedButton(
                                  onPressed: () async {
                                    final ImagePicker picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(
                                        source: ImageSource.gallery);

                                    if (image != null &&
                                        image.path.isNotEmpty) {
                                      var responseI =
                                          await Connections().postDoc(image);
                                      // print("ImgSaveStrapi: $responseI");

                                      setState(() {
                                        img_url = responseI[1];
                                      });

                                      // Navigator.pop(context);
                                      // Navigator.pop(context);
                                    } else {
                                      print("No img");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[300],
                                  ),
                                  child: const Text(
                                    "Agregar imagen",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                img_url.isNotEmpty || img_url != ""
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

                                    var responseUpt = await Connections()
                                        .updateProduct(codigo, {
                                      "product_name":
                                          _nameController.text.toString(),
                                      "stock": int.parse(
                                          _stockController.text.toString()),
                                      "features": featuresToSend,
                                      "price": double.parse(
                                          _priceController.text.toString()),
                                      "url_img": img_url.toString()
                                    });

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
