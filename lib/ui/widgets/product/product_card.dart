import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/product_seller.dart';
import 'package:frontend/models/reserve_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/widgets/product/product_carousel.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Function(BuildContext) onTapCallback;

  ProductCard({required this.product, required this.onTapCallback});

  @override
  Widget build(BuildContext context) {
    //
    List<String> urlsImgsList = product.urlImg != null &&
            product.urlImg.isNotEmpty &&
            product.urlImg.toString() != "[]"
        ? (jsonDecode(product.urlImg) as List).cast<String>()
        : [];

    // Decodificar el JSON
    Map<String, dynamic> features = jsonDecode(product.features);
    String priceSuggested = "";
    priceSuggested = features["price_suggested"].toString();
    //1 true, 0 false, 2 no existe registro
    int isFavorite = 2;
    int isOnSale = 2;

    int totalReservas = 0;
    String sku = features["sku"];

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

    if (product.sellerOwnedId != 0 || product.sellerOwnedId != null) {
      List<ReserveModel>? reservesList = product.reserves;
      if (reservesList != null) {
        for (var reserva in reservesList) {
          var idMaster =
              sharedPrefs!.getString("idComercialMasterSeller").toString();
          ReserveModel reserve = reserva;
          if (idMaster == reserve.idComercial.toString()) {
            totalReservas += reserve.stock!;
          } else {
            // print("Existen reservas pero NO de este userMaster");
          }
        }
      }
    }
    // print(isFavorite);
    // print(isOnSale);
    // print(".......");

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.width;

    double textSize = screenWidth > 600 ? 14 : 12;
    double iconSize = screenWidth > 600 ? 70 : 25;
    double imgHeight = screenWidth > 600 ? 260 : 200;

/*
    print("${product.productName.toString()}");
    print("${product.sellerOwnedId.toString()}");

    print("stock: ${product.stock.toString()}");
    print("reserves: ${totalReservas.toString()}");
    */
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: () => onTapCallback(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image and Favorite Icon
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  // v3
                  Container(
                    width: MediaQuery.of(context).size.width,
                    // padding: EdgeInsets.all(10),
                    height: imgHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ProductCarousel(
                        urlImages: urlsImgsList, imgHeight: imgHeight),
                  ),

                  //v2
                  /*
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(10),
                    height: imgHeight - 10,
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
*/
                  // Icon for favorite
                  isFavorite == 1
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8), // Ajusta el padding como prefieras
                          child: Stack(
                            children: [
                              // Fondo desenfocado
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 1.0,
                                      sigmaY:
                                          1.0), // Ajusta la intensidad del blur
                                  child: Container(
                                    width:
                                        40, // Ajusta el tamaño del contenedor si es necesario
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(
                                          0.2), // Un color semi-transparente para ver el efecto blur
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColorsSystem()
                                              .colorBackoption
                                              .withOpacity(
                                                  0.2), // Color de la sombra con opacidad
                                          offset: Offset(
                                              0, 4), // Sombra hacia abajo
                                          blurRadius:
                                              3, // Difuminado de la sombra
                                          spreadRadius:
                                              1, // Extensión de la sombra
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Ícono en primer plano, sin desenfoque
                              Positioned.fill(
                                child: Center(
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.indigo[900],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),

                  // Icon for on sale
                  isOnSale == 1
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical:
                                      8), // Ajusta el padding como prefieras
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Reemplaza el ícono con el texto "ID: {productId}"
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 1.0,
                                              sigmaY:
                                                  1.0), // Ajusta la intensidad del blur
                                          child: Container(
                                            width:
                                                80, // Ajusta el tamaño del contenedor si es necesario
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                  0.2), // Un color semi-transparente para ver el efecto blur
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: ColorsSystem()
                                                      .colorBackoption
                                                      .withOpacity(
                                                          0.2), // Color de la sombra con opacidad
                                                  offset: Offset(0,
                                                      4), // Sombra hacia abajo
                                                  blurRadius:
                                                      3, // Difuminado de la sombra
                                                  spreadRadius:
                                                      1, // Extensión de la sombra
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Text(
                                            'ID: ${product.productId}', // Muestra el ID del producto
                                            style: TextStyle(
                                                fontSize: textSize,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    ColorsSystem().colorStore),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Ícono original con efecto blur
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 1.0,
                                              sigmaY:
                                                  1.0), // Ajusta la intensidad del blur
                                          child: Container(
                                            width:
                                                40, // Ajusta el tamaño del contenedor si es necesario
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                  0.2), // Un color semi-transparente para ver el efecto blur
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                                  boxShadow: [
                                                BoxShadow(
                                                  color: ColorsSystem()
                                                      .colorBackoption
                                                      .withOpacity(
                                                          0.2), // Color de la sombra con opacidad
                                                  offset: Offset(0,
                                                      4), // Sombra hacia abajo
                                                  blurRadius:
                                                      3, // Difuminado de la sombra
                                                  spreadRadius:
                                                      1, // Extensión de la sombra
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Icon(
                                            Icons.local_offer,
                                            color: getColorForStockStatus(
                                              int.parse(
                                                  product.stock.toString()),
                                            ), // Color del ícono
                                            size: 25, // Tamaño del ícono
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              // Text information
              Padding(
                // padding: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'Producto: ',
                        //   style: GoogleFonts.dmSerifDisplay(
                        //     // fontWeight: FontWeight.bold,
                        //     fontSize: textSize,
                        //     color: Colors.grey[600],
                        //   ),
                        // ),
                        Flexible(
                          child: Text(
                            '${product.productName}',
                            style: TextStyle(
                              fontSize: textSize + 1,
                              fontWeight: FontWeight.w600,
                              color: ColorsSystem().colorLabels,
                            ),

                            // TextStylesSystem().ralewayStyle(textSize,
                            // FontWeight.w600, ColorsSystem().colorLabels),
                            // GoogleFonts.dmSans(
                            //   fontSize: textSize,
                            //   color: Colors.black,
                            // ),
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
                          'Bodega: ',
                          style: TextStylesSystem().ralewayStyle(textSize,
                              FontWeight.w600, ColorsSystem().colorSection2),
                        ),
                        Flexible(
                          child: Text(
                              getFirstWarehouseNameModel(product.warehouses),
                              // product.warehouse!.branchName.toString(),
                              style: TextStylesSystem().ralewayStyle(
                                  textSize,
                                  FontWeight.w600,
                                  ColorsSystem().colorSelected)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: ColorsSystem().colorBackoption,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Precio Bodega",
                                  style: TextStylesSystem().ralewayStyle(
                                    textSize - 0.5,
                                    FontWeight.w600,
                                    ColorsSystem().colorSection2,
                                  ),
                                ),
                                Text(
                                  '\$ ${product.price}',
                                  style: TextStyle(
                                    fontSize: textSize + 1,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: ColorsSystem().colorBackoption,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Precio Sugerido",
                                  style: TextStylesSystem().ralewayStyle(
                                    textSize - 0.5,
                                    FontWeight.w600,
                                    ColorsSystem().colorSection2,
                                  ),
                                ),
                                Text(
                                  '\$ $priceSuggested',
                                  style: TextStyle(
                                    fontSize: textSize + 1,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centrar el botón
                        children: [
                          Expanded(
                            // Para que ocupe todo el ancho
                            child: InkWell(
                              onTap: () {
                                // getLoadingModal(context, true);

                                if (product.isvariable == 1) {
                                  String variablesSkuId = "";

                                  // Asegúrate de que features["variants"] tenga valores válidos
                                  List<Map<String, dynamic>>? variants =
                                      (features["variants"] as List<dynamic>)
                                          .cast<Map<String, dynamic>>();

                                  // Concatena los SKUs en una cadena
                                  variants!.forEach((variable) {
                                    if (variable.containsKey('sku')) {
                                      variablesSkuId +=
                                          "${variable['sku']}C${product.productId.toString()}\n\n";
                                    }
                                  });

                                  // Copia los SKUs al portapapeles
                                  Clipboard.setData(
                                      ClipboardData(text: variablesSkuId));

                                  Get.snackbar(
                                    'SKUs COPIADOS',
                                    'Copiado al Clipboard',
                                  );
                                } else {
                                  // Copia solo un SKU
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          "${sku}C${product.productId.toString()}"));

                                  Get.snackbar(
                                    'SKU COPIADO',
                                    'Copiado al Clipboard',
                                  );
                                }

                                // Navigator.of(context).pop();
                              }, // Función para manejar el clic
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white, // Fondo del botón
                                  borderRadius: BorderRadius.circular(
                                      12), // Borde redondeado
                                  border: Border.all(
                                    color: ColorsSystem()
                                        .colorSelected, // Color y grosor del borde
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorsSystem()
                                          .colorSelected
                                          .withOpacity(
                                              0.2), // Color de la sombra con opacidad
                                      offset:
                                          Offset(0, 4), // Sombra hacia abajo
                                      blurRadius: 3, // Difuminado de la sombra
                                      spreadRadius: 1, // Extensión de la sombra
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Centrar contenido dentro del botón
                                  children: [
                                    Icon(
                                      Icons.copy, // El icono que quieras
                                      color: ColorsSystem()
                                          .colorSelected, // Color del icono
                                      size: iconSize *
                                          0.2, // Tamaño del icono dependiente de la resolución
                                    ),
                                    SizedBox(
                                        width:
                                            8), // Espacio entre icono y texto
                                    Text(
                                      "Sku", // El texto que desees
                                      style: TextStylesSystem().ralewayStyle(
                                        textSize, // Tamaño del texto dependiente de la resolución
                                        FontWeight
                                            .bold, // Para un texto más fuerte
                                        ColorsSystem()
                                            .colorSelected, // Color del texto
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getFirstImgUrl(dynamic urlImgData) {
    List<String> urlsImgsList = (jsonDecode(urlImgData) as List).cast<String>();
    String url = urlsImgsList[0];
    return url;
  }

  Color getColorForStockStatus(int stock) {
    if (stock > 20) {
      return Colors.green;
    } else if (stock >= 11 && stock <= 20) {
      return Colors.orange;
    } else if (stock >= 0 && stock <= 10) {
      return Colors.red;
    } else {
      return Colors.purple;
    }
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
