import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Function(BuildContext) onTapCallback;

  ProductCard({required this.product, required this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    var features = jsonDecode(product.features);

    List<Map<String, dynamic>> featuresList =
        features.cast<Map<String, dynamic>>();

    String priceSuggested = featuresList
        .where((feature) => feature.containsKey("price_suggested"))
        .map((feature) => feature["price_suggested"] as String)
        .firstWhere((element) => element.isNotEmpty, orElse: () => '');

    double screenWidth = MediaQuery.of(context).size.width;
    double textSize = screenWidth > 600 ? 16 : 12;
    double iconSize = screenWidth > 600 ? 70 : 25;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      color: ColorsSystem().colorBlack,
      child: InkWell(
        onTap: () => onTapCallback(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: product.urlImg != null &&
                      product.urlImg.isNotEmpty &&
                      product.urlImg.toString() != "[]"
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        "$generalServer${getFirstImgUrl(product.urlImg)}",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                              ),
                            );
                          }
                        },
                      ),
                    )
                  : Container(
                      color: Colors.white,
                      // child: Icon(Icons.shopping_bag,
                      //     size: iconSize, color: Colors.deepPurple[800]),
                    ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Producto:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: textSize,
                            fontFamily: 'Arial',
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Expanded(
                          child: Text(
                            '${product.productName}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: textSize,
                              fontFamily: 'Arial',
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: textSize,
                            fontFamily: 'Arial',
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          '\$${product.price}',
                          style: TextStyle(
                            color: Colors.indigo[900],
                            fontSize: textSize,
                            fontFamily: 'Arial',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio Sugerido:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: textSize,
                            fontFamily: 'Arial',
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          '\$$priceSuggested',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: textSize,
                            fontFamily: 'Arial',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: textSize,
                            fontFamily: 'Arial',
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          '${product.stock}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: textSize,
                            fontFamily: 'Arial',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bodega:',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: textSize,
                            fontFamily: 'Arial',
                          ),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        Text(
                          product.warehouse!.branchName.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: textSize,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFirstImgUrl(dynamic urlImgData) {
    List<String> urlsImgsList = (jsonDecode(urlImgData) as List).cast<String>();
    String url = urlsImgsList[0];
    return url;
  }
}
