import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/product_seller.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Function(BuildContext) onTapCallback;

  ProductCard({required this.product, required this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    // Decodificar el JSON
    Map<String, dynamic> features = jsonDecode(product.features);
    String priceSuggested = "";
    priceSuggested = features["price_suggested"].toString();
    //1 true, 0 false, 2 no existe registro
    int isFavorite = 2;
    int isOnSale = 2;

    //
    List<ProductSellerModel>? productsellerList = product.productseller;
    if (productsellerList != null) {
      for (ProductSellerModel productSeller in productsellerList) {
        if (productSeller.idMaster.toString() ==
            sharedPrefs!.getString("idComercialMasterSeller")) {
          // print(
          //     'ID: ${productSeller.id}, id_Product: ${productSeller.productId}, Id_Master: ${productSeller.idMaster}, favorite: ${productSeller.favorite}, onsale: ${productSeller.onsale}');
          if (productSeller.favorite != null && productSeller.favorite == 1) {
            isFavorite = 1;
          }

          if (productSeller.onsale != null && productSeller.onsale == 1) {
            isOnSale = 1;
          }
        } else {
          // print("Si esta en la productSeller pero no esta tienda");
        }
      }
    }
    // print(isFavorite);
    // print(isOnSale);
    // print(".......");

    double screenWidth = MediaQuery.of(context).size.width;
    double textSize = screenWidth > 600 ? 14 : 12;
    double iconSize = screenWidth > 600 ? 70 : 25;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 10,
      color: Colors.white,
      child: InkWell(
        onTap: () => onTapCallback(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image and Favorite Icon
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 160,
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
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
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
                  // Icon for favorite
                  isFavorite == 1
                      ? Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.indigo[900],
                              size: 20,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),

                  // Icon for on sale
                  isOnSale == 1
                      ? Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.local_offer,
                              // color: Colors.green,
                              color: getColorForStockStatus(int.parse(product
                                  .stock
                                  .toString())), // Utiliza una función para determinar el color
                              size: 25,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              // Text information
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    // const SizedBox(height: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

/*
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
                        fit: BoxFit.contain,
                        // width: double.infinity,
                        // height: double.infinity,
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
            // Icon for favorite
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.all(4), // Espaciado alrededor del icono
                decoration: BoxDecoration(
                  color: product.isvariable == 1
                      ? Colors.white // Color de fondo cuando approved es 1
                      : Colors
                          .transparent, // Fondo transparente cuando approved no es 1
                  borderRadius: BorderRadius.circular(
                      10), // Bordes redondeados, ajusta según sea necesario
                ),
                child: product.isvariable == 1
                    ? Icon(
                        Icons.favorite,
                        color: Colors.indigo[900], // Color del icono
                        size: 20,
                      )
                    : const SizedBox.shrink(),
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
    */
  }

  String getFirstImgUrl(dynamic urlImgData) {
    List<String> urlsImgsList = (jsonDecode(urlImgData) as List).cast<String>();
    String url = urlsImgsList[0];
    return url;
  }

  Color getColorForStockStatus(int stock) {
    if (stock > 20) {
      return Colors.green;
    } else if (stock >= 10 && stock <= 20) {
      return Colors.orange;
    } else if (stock >= 0 && stock <= 3) {
      return Colors.red;
    } else {
      return Colors.purple;
    }
  }
}
