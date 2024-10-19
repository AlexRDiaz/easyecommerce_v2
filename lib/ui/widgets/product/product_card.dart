import 'dart:convert';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
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
import 'package:url_launcher/url_launcher.dart';

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

    double textSize = screenWidth > 600 ? 14 : 10;
    double iconSize = screenWidth > 600 ? 25 : 15;
    double imgHeight = screenWidth > 600 ? 260 : 150;

    double containerHeight = screenWidth > 600 ? 40 : 20;
    double containerWidth = screenWidth > 600 ? 80 : 50;
    double containerTickesHeight = screenWidth > 600 ? 30 : 20;
    double containerTickesWidth = screenWidth > 600 ? 35 : 30;

/*
    print("${product.productName.toString()}");
    print("${product.sellerOwnedId.toString()}");

    print("stock: ${product.stock.toString()}");
    print("reserves: ${totalReservas.toString()}");
    */
    return Container(
      // width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap: () => onTapCallback(context),
        // ! se quita el scrol con crossaxis -> strech
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image and Favorite Icon
            Stack(
              // alignment: Alignment.topLeft,
              children: [
                // v3
                Container(
                  width: MediaQuery.of(context).size.width,
                  // padding: EdgeInsets.all(10),
                  height: imgHeight - 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ProductCarousel(
                      urlImages: urlsImgsList, imgHeight: imgHeight),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8), // Ajusta el padding como prefieras
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        containerWidth, // Ajusta el tamaño del contenedor si es necesario
                                    height: containerHeight,
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
                              Positioned.fill(
                                child: Center(
                                  child: Text(
                                    'ID: ${product.productId}', // Muestra el ID del producto
                                    style: TextStyle(
                                        fontSize: textSize,
                                        fontWeight: FontWeight.w600,
                                        color: ColorsSystem().colorStore),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ])),

                // Icon for favorite
                isFavorite == 1
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: screenWidth > 600
                                ? 50
                                : 28), // Ajusta el padding como prefieras
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
                                      containerTickesWidth, // Ajusta el tamaño del contenedor si es necesario
                                  height: containerTickesHeight,
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
                                        offset:
                                            Offset(0, 4), // Sombra hacia abajo
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
                                  size: iconSize,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Spacer(),
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
                                              containerTickesWidth, // Ajusta el tamaño del contenedor si es necesario
                                          height: containerTickesHeight,
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
                                    Positioned.fill(
                                      child: Center(
                                        child: Icon(
                                          Icons.local_offer,
                                          color: getColorForStockStatus(
                                            int.parse(product.stock.toString()),
                                          ), // Color del ícono
                                          size: iconSize, // Tamaño del ícono
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

                Positioned(
                    bottom:
                        8, // Adjust this value as needed for the desired padding
                    right: 16, // Adjust this value for horizontal alignment
                    child: Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                          child: Container(
                            width: containerWidth, // Same width as ID container
                            height: containerHeight,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorsSystem()
                                      .colorBackoption
                                      .withOpacity(0.2),
                                  offset: Offset(0, 4),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            'Stock: ${totalReservas != 0 ? totalReservas : product.stock}', // Display the product stock
                            style: TextStyle(
                              fontSize: textSize,
                              fontWeight: FontWeight.w600,
                              color: ColorsSystem().colorStore,
                            ),
                          ),
                        ),
                      ),
                    ])),
              ],
            ),
            // Text information
            Padding(
              // padding: const EdgeInsets.all(8),
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        // Este widget asegura que el texto no se desborde
                        child: Text(
                          '${product.productName}',
                          style: TextStyle(
                            fontSize: textSize + 1,
                            fontWeight: FontWeight.w600,
                            color: ColorsSystem().colorLabels,
                          ),
                          overflow:
                              TextOverflow.ellipsis, // Cambia fade a ellipsis
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bodega: ',
                        style: TextStylesSystem().ralewayStyle(
                          textSize,
                          FontWeight.w600,
                          ColorsSystem().colorSection2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                      ),
                      Flexible(
                        child: Text(
                          getFirstWarehouseNameModel(product.warehouses),
                          style: TextStylesSystem().ralewayStyle(
                            textSize,
                            FontWeight.w600,
                            ColorsSystem().colorSelected,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              // horizontal: 10, vertical: 5),
                              horizontal: 5),
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
                      SizedBox(width: 5),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
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
                  SizedBox(height: 4),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              sendWhatsAppMessage(
                                context,
                                getProviderPhoneModel(product.warehouses),
                                product.productName.toString(),
                                product.productId.toString(),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: ColorsSystem().colorSelected,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorsSystem()
                                        .colorSelected
                                        .withOpacity(0.2),
                                    offset: Offset(0, 4),
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.perm_phone_msg_outlined,
                                    size: iconSize,
                                    // MediaQuery.of(context).size.width >
                                    //         600
                                    //     ? MediaQuery.of(context).size.width *
                                    //         0.01
                                    //     : MediaQuery.of(context).size.width *
                                    //         0.05,
                                    color: ColorsSystem().colorSelected,
                                    // Image.asset(
                                    //   images.whatsapp_icon_2,
                                    // width: iconSize * 0.3,
                                    // height: iconSize * 0.3,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    // Permite que el texto se ajuste
                                    child: Text(
                                      "Contacto Proveedor",
                                      style: TextStylesSystem().ralewayStyle(
                                        textSize,
                                        FontWeight.w500,
                                        ColorsSystem().colorSelected,
                                      ),
                                      overflow: TextOverflow
                                          .ellipsis, // Recorta el texto si es necesario
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
                  // Center(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Expanded(
                  //         child: Container(
                  //           child: ElevatedButton(
                  //             onPressed: () async {
                  //               sendWhatsAppMessage(
                  //                 context,
                  //                 getProviderPhoneModel(product.warehouses),
                  //                 product.productName.toString(),
                  //                 product.productId.toString(),
                  //               );
                  //             },
                  //             style: ElevatedButton.styleFrom(

                  //               backgroundColor: Colors.white,
                  //               side: BorderSide(
                  //                 color: ColorsSystem()
                  //                     .colorSelected, // Borde con color personalizado
                  //                 width: 2, // Ancho del borde
                  //               ),
                  //               shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(
                  //                     10), // Bordes redondeados
                  //               ),
                  //               padding: const EdgeInsets.symmetric(
                  //                 horizontal: 8.0, // Reduce el padding horizontal
                  //                 vertical: 6.0, // Reduce el padding vertical
                  //               ),
                  //             ),
                  //             child: FittedBox(
                  //               // Asegura que el contenido se ajuste bien en el espacio
                  //               child: Row(
                  //                 mainAxisSize: MainAxisSize.min,
                  //                 children: [
                  //                   Icon(
                  //                     Icons.perm_phone_msg_outlined,
                  //                     size: MediaQuery.of(context).size.width >
                  //                             600
                  //                         ? MediaQuery.of(context).size.width *
                  //                             0.01
                  //                         : MediaQuery.of(context).size.width *
                  //                             0.05, // Ajusta el tamaño del ícono dinámicamente
                  //                     color: ColorsSystem().colorSelected,
                  //                   ),
                  //                   const SizedBox(width: 5),
                  //                   Text(
                  //                     "Contacto Proveedor",
                  //                     style: TextStylesSystem().ralewayStyle(
                  //                       MediaQuery.of(context).size.width > 600
                  //                           ? MediaQuery.of(context).size.width *
                  //                               0.01
                  //                           : MediaQuery.of(context).size.width *
                  //                               0.04,
                  //                       FontWeight.w500,
                  //                       ColorsSystem().colorSelected,
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
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

  String getProviderPhoneModel(dynamic warehouses) {
    String phone = "";
    List<WarehouseModel>? warehousesList = warehouses;
    if (warehousesList != null && warehousesList.isNotEmpty) {
      WarehouseModel firstWarehouse = warehousesList.first;
      phone = "${firstWarehouse.provider?.phone}";
    }
    return phone;
  }

  Future<void> sendWhatsAppMessage(BuildContext context, String phoneNumber,
      String productName, String idProduct) async {
    if (phoneNumber != "") {
      var message =
          "Hola, soy ususario de la paltaforma EasyEcommerce estoy interesado en vender tu producto: $productName-$idProduct";
      var whatsappUrl =
          "https://api.whatsapp.com/send?phone=$phoneNumber&text=${Uri.encodeFull(message)}";

      if (!await launchUrl(Uri.parse(whatsappUrl))) {
        throw Exception('Could not launch $whatsappUrl');
      }
    } else {
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'El Proveedor no posee un número de Contacto Establecido',
        // desc: '',
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        // btnCancelOnPress: () {},
        btnOkOnPress: () async {
          Navigator.pop(context);
        },
      ).show();
    }
  }
}
