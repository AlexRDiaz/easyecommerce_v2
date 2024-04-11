import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/widgets/product/show_img.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductInfo extends StatefulWidget {
  final ProductModel product;

  const ProductInfo({super.key, required this.product});

  @override
  State<ProductInfo> createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // return const Placeholder();
    ProductModel product = widget.product;

    List<String> urlsImgsList = product.urlImg != null &&
            product.urlImg.isNotEmpty &&
            product.urlImg.toString() != "[]"
        ? (jsonDecode(product.urlImg) as List).cast<String>()
        : [];

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

    guideName = features["guide_name"];
    priceSuggested = features["price_suggested"].toString();
    sku = features["sku"];
    description = features["description"];
    type = features["type"];
    categories = features["categories"];
    List<String> categoriesNames =
        categories.map((item) => item["name"].toString()).toList();
    categoriesText = categoriesNames.join(', ');

    String warehouseValue = getFirstWarehouseNameModel(product.warehouses);

    if (product.isvariable == 1) {
      List<Map<String, dynamic>>? variants =
          (features["variants"] as List<dynamic>).cast<Map<String, dynamic>>();

      variablesText = variants!.map((variable) {
        List<String> variableDetails = [];

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

        return variableDetails.join('\n');
      }).join('\n\n');
    }

    TextStyle customTextStyleTitle = GoogleFonts.dmSerifDisplay(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    );

    TextStyle customTextStyleText = GoogleFonts.dmSans(
      fontSize: 17,
      color: Colors.black,
    );

    return Container(
      width: screenWith > 600 ? screenWith : screenWith,
      height: screenHeight * 0.85,
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Visibility(
                visible: urlsImgsList.isNotEmpty,
                replacement: Container(),
                child: ShowImages(urlsImgsList: urlsImgsList),
              ),
            ),
            Expanded(
              flex: 4,
              child: ListView(
                children: [
                  Row(
                    children: [
                      Text(
                        "Producto:",
                        style: customTextStyleTitle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          product.productName.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Nombre a mostrar en la guia de envio:',
                        style: customTextStyleTitle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          guideName,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  Row(
                    children: [
                      Text(
                        "Descripción:",
                        style: customTextStyleTitle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Html(
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  Visibility(
                    visible: product.isvariable == 1,
                    child: Row(
                      children: [
                        Text(
                          "SKU Variables:",
                          style: customTextStyleTitle,
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: product.isvariable == 1,
                    child: Row(
                      children: [
                        Text(
                          variablesSKU,
                          style: customTextStyleText,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
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
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Precio Sugerido:",
                        style: customTextStyleTitle,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        priceSuggested.isNotEmpty || priceSuggested != ""
                            ? '\$$priceSuggested'
                            : '',
                        style: customTextStyleText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  Visibility(
                    visible: product.isvariable == 1,
                    child: Row(
                      children: [
                        Text(
                          variablesText,
                          style: customTextStyleText,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: product.isvariable == 1,
                    child: Row(
                      children: [
                        Text(
                          variablesText,
                          style: customTextStyleText,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Categorias:",
                        style: customTextStyleTitle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        categoriesText,
                        style: customTextStyleText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "Bodega:",
                        style: customTextStyleTitle,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        warehouseValue,
                        // product.warehouse!.branchName
                        //     .toString(),
                        style: customTextStyleText,
                      ),
                    ],
                  ),
                ],
              ),

              /*
                    Container(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: ListView(
                          children: [

                            
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  */
            ),
          ],
        ),
      ),
    );
  }

  String getFirstWarehouseNameModel(dynamic warehouses) {
    String name = "";
    List<WarehouseModel>? warehousesList = warehouses;
    if (warehousesList != null && warehousesList.isNotEmpty) {
      WarehouseModel firstWarehouse = warehousesList.first;
      name = firstWarehouse.branchName.toString();
    }
    return name;
  }
}
