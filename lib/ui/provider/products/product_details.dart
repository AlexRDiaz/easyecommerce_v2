import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
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
  var type;
  var descripcion;
  var categories;
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
      // Future.delayed(const Duration(milliseconds: 500), ()
      // Navigator.pop(context);
      // });
      // SnackBarHelper.showErrorSnackBar(context, "Error al guardar los datos");
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
    // _descriptionController.text = data['direccion_shipping'].toString();
    // var type = data['ciudad_shipping'].toString();
    // img_url = data['url_img'].toString();

    img_url = data['url_img'].toString();
    if (img_url == "null" || img_url == "") {
      img_url = "";
    }
    // print("img incoming: ${img_url.toString()}");

    List<dynamic> dataFeatures = json.decode(data['features']);
    type = findValue(dataFeatures, 'type')?.toString();
    descripcion = findValue(dataFeatures, 'description')?.toString();
    categories =
        findValue(dataFeatures, 'categories')?.cast<String>() ?? <String>[];
    _typeController.text = type;
    _descriptionController.text = descripcion;
    // print("type: $type");
    // print("descripcion: $descripcion");
    // print("categories: $categories");

    setState(() {});
  }

  dynamic findValue(List<dynamic> dataFeatures, String featureName) {
    var feature = dataFeatures.firstWhere(
      (dataFeature) => dataFeature['feature_name'] == featureName,
      orElse: () => null,
    );

    return feature != null ? feature['value'] : null;
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
                  // _modelText("Código", codigo),
                  // _modelText("Creado", createdAt),
                  // _modelTextField("Producto", _nameController),
                  // _modelTextField("Stock", _stockController),
                  // _modelTextField("Precio Total", _priceController),
                  // _modelTextField("Tipo", _typeController),

                  Column(
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
                      const Text(
                        "Stock",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _stockController,
                        maxLines: null,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Precio Total",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _priceController,
                        maxLines: null,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Tipo",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      DropdownButton<String>(
                        hint: const Text("Seleccione un tipo"),
                        value: type,
                        onChanged: (value) {
                          setState(() {
                            type = value ?? "";
                          });
                        },
                        items: types.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Descripción",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: null,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
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
                      )
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
                                  {"feature_name": "type", "value": type},
                                  {
                                    "feature_name": "categories",
                                    "value": categories
                                  },
                                  {
                                    "feature_name": "description",
                                    "value": _descriptionController.text
                                  },
                                ];

                                var responseUpt =
                                    await Connections().updateProduct(codigo, {
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
