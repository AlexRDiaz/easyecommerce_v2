import 'dart:convert';
import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/main.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductAddOrder extends StatefulWidget {
  final ProductModel product;

  const ProductAddOrder({super.key, required this.product});

  @override
  State<ProductAddOrder> createState() => _ProductAddOrderState();
}

class _ProductAddOrderState extends State<ProductAddOrder> {
  TextEditingController _cantidad = TextEditingController();
  // TextEditingController _codigo = TextEditingController();
  TextEditingController _nombre = TextEditingController();
  TextEditingController _direccion = TextEditingController();
  // TextEditingController _ciudad = TextEditingController();
  TextEditingController _telefono = TextEditingController();
  TextEditingController _producto = TextEditingController();
  TextEditingController _productoE = TextEditingController();
  TextEditingController _precioTotalEnt = TextEditingController();
  TextEditingController _precioTotalDec = TextEditingController();

  TextEditingController _observacion = TextEditingController();
  bool pendiente = true;
  bool confirmado = false;
  bool noDesea = false;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> routes = [];
  String? selectedValueRoute;
  String numeroOrden = "";
  List<String> transports = [];
  var routesList = [];
  String? selectedValueTransport;
  String? comercial = sharedPrefs!.getString("NameComercialSeller");
  String productp = "";

  late Map<String, dynamic> features;
  List<String> variantsToSelect = [];
  List variantsListOriginal = [];
  String chosenSku = "";
  String? chosenVariant;
  double priceSuggestedProd = 0;
  double quantity = 1;
  List variantsDetailsList = [];
  double priceWarehouseTotal = 0;
  double costShippingSeller = 0;
  double profit = 0;
  int quantityTotal = 0;

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  @override
  void didChangeDependencies() {
    getRoutes();
    getData();
    super.didChangeDependencies();
  }

  getRoutes() async {
    try {
      routesList = await Connections().getRoutesLaravel();
      setState(() {
        routes = routesList
            .where((route) => route['titulo'] != "[Vacio]")
            .map<String>((route) => '${route['titulo']}-${route['id']}')
            .toList();
        //'${route['titulo']}'
      });
    } catch (error) {
      print('Error al cargar rutas: $error');
    }
  }

  getTransports() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      var transportList = [];

      setState(() {
        transports = [];
      });

      transportList = await Connections().getTransportsByRouteLaravel(
          selectedValueRoute.toString().split("-")[1]);

      for (var i = 0; i < transportList.length; i++) {
        setState(() {
          transports
              .add('${transportList[i]['nombre']}-${transportList[i]['id']}');
        });
      }

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {});
    } catch (error) {
      print('Error al cargar rutas: $error');
    }
  }

  getData() async {
    numeroOrden = await generateNumeroOrden();
    _producto.text = widget.product.productName!;
    productp = widget.product.productName!;
    double? priceT = widget.product.price;

    features = jsonDecode(widget.product.features);
    chosenSku = features["sku"];
    priceSuggestedProd = double.parse(features["price_suggested"].toString());

    String priceSuggested = "";
    priceSuggested = features["price_suggested"].toString();

    if (priceSuggested.contains(".")) {
      var parts = priceSuggested.split('.');
      _precioTotalEnt.text = parts[0];
      _precioTotalDec.text = parts[1];
    } else {
      _precioTotalEnt.text = priceSuggested;
      _precioTotalDec.text = "00";
    }

    _cantidad.text = "1";

    variantsListOriginal = features["variants"];
    //  print(variantsListOriginal);

    if (widget.product.isvariable == 1) {
      Set<String> uniqueVariants = <String>{};

      for (var variantData in variantsListOriginal) {
        String sku = variantData["sku"];
        String size = variantData["size"] ?? "";
        String color = variantData["color"] ?? "";
        String dimension = variantData["dimension"] ?? "";

        String variantString =
            "$sku${size.isNotEmpty ? '-$size' : ''}${color.isNotEmpty ? '/$color' : ''}${dimension.isNotEmpty ? '/$dimension' : ''}";

        uniqueVariants.add(variantString);
      }

      variantsToSelect = uniqueVariants.toList();
    }
    costShippingSeller =
        double.parse(sharedPrefs!.getString("seller_costo_envio").toString());

    //
  }

  @override
  Widget build(BuildContext context) {
    double screenWidthDialog = MediaQuery.of(context).size.width;

    double screenWidth =
        screenWidthDialog > 600 ? screenWidthDialog * 0.40 : screenWidthDialog;
    // print(screenWidth);

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(15),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Destino:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Seleccione una Ciudad',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold),
                      ),
                      items: routes
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.split('-')[0],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                      value: selectedValueRoute,
                      onChanged: (value) async {
                        setState(() {
                          selectedValueRoute = value as String;
                          transports.clear();
                          selectedValueTransport = null;
                        });
                        await getTransports();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Seleccione una Transportadora',
                        style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.bold),
                      ),
                      items: transports
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.split('-')[0],
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                      value: selectedValueTransport,
                      onChanged: selectedValueRoute == null
                          ? null
                          : (value) {
                              setState(() {
                                selectedValueTransport = value as String;
                              });
                            },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Numero de Orden:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        numeroOrden,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _nombre,
                    decoration: const InputDecoration(
                      labelText: "Nombre Cliente",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _direccion,
                    decoration: const InputDecoration(
                      labelText: "Dirección",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _telefono,
                    decoration: const InputDecoration(
                      labelText: "Teléfono",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _producto,
                    decoration: const InputDecoration(
                      labelText: "Producto",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Campo requerido";
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  //simple
                  Visibility(
                    visible: widget.product.isvariable == 0,
                    child: const Row(
                      children: [
                        Text(
                          "Cantidad:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: widget.product.isvariable == 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          // width: screenWidth * 0.25,
                          width: screenWidthDialog > 600
                              ? screenWidth * 0.25
                              : screenWidth * 0.35,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: SpinBox(
                                      min: 1,
                                      max: 100,
                                      value: quantity,
                                      onChanged: (value) {
                                        setState(() {
                                          quantity = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          // width: screenWidth * 0.15,
                          width: screenWidthDialog > 600
                              ? screenWidth * 0.15
                              : screenWidth * 0.2,
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  bool existVariant = false;
                                  for (var variant in variantsDetailsList) {
                                    if (variant['sku'].toString() ==
                                        chosenSku.toString()) {
                                      existVariant = true;
                                      break;
                                    }
                                  }
                                  if (!existVariant) {
                                    var variant =
                                        await generateVariantData(chosenSku);
                                    setState(() {
                                      variantsDetailsList.add(variant);
                                    });
                                  } else {
                                    //upt
                                    variantsDetailsList = [];
                                    var variant =
                                        await generateVariantData(chosenSku);
                                    setState(() {
                                      variantsDetailsList.add(variant);
                                    });
                                  }

                                  calculateTotalWPrice();
                                  calculateTotalQuantity();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Añadir",
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
                  ),
                  // var
                  Visibility(
                    visible: widget.product.isvariable == 1,
                    child: responsive(
                        //web,
                        Row(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.40,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Variante:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      hint: Text(
                                        'Seleccione Variante',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).hintColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      items: variantsToSelect.map((item) {
                                        var parts = item.split('-');
                                        var name = parts[1];
                                        return DropdownMenuItem(
                                          value: item,
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      value: chosenVariant,
                                      onChanged: (value) {
                                        setState(() {
                                          chosenVariant = value as String;
                                          var parts = value.split('-');
                                          chosenSku = parts[0];
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
                            const SizedBox(width: 10),
                            SizedBox(
                              child: Column(
                                children: [
                                  const Row(
                                    children: [
                                      Text(
                                        "Cantidad:",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 150,
                                        child: SpinBox(
                                          min: 1,
                                          max: 100,
                                          value: quantity,
                                          onChanged: (value) {
                                            setState(() {
                                              quantity = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: widget.product.isvariable == 1 &&
                                            chosenVariant == null
                                        ? null
                                        : () async {
                                            bool existVariant = false;
                                            for (var variant
                                                in variantsDetailsList) {
                                              if (variant['sku'].toString() ==
                                                  chosenSku.toString()) {
                                                existVariant = true;
                                                break;
                                              }
                                            }
                                            if (!existVariant) {
                                              var variant =
                                                  await generateVariantData(
                                                      chosenSku);
                                              setState(() {
                                                variantsDetailsList
                                                    .add(variant);
                                              });
                                              calculateTotalWPrice();
                                              calculateTotalQuantity();
                                              // print("variantsDetailsList");
                                              // print(variantsDetailsList);
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Añadir",
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
                        //mobile,
                        Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Variante:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.65,
                                      child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        hint: Text(
                                          'Seleccione Variante',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(context).hintColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        items: variantsToSelect.map((item) {
                                          var parts = item.split('-');
                                          var name = parts[1];
                                          return DropdownMenuItem(
                                            value: item,
                                            child: Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        value: chosenVariant,
                                        onChanged: (value) {
                                          setState(() {
                                            chosenVariant = value as String;
                                            var parts = value.split('-');
                                            chosenSku = parts[0];
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
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Cantidad:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: SpinBox(
                                        min: 1,
                                        max: 100,
                                        value: quantity,
                                        onChanged: (value) {
                                          setState(() {
                                            quantity = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      onPressed: widget.product.isvariable ==
                                                  1 &&
                                              chosenVariant == null
                                          ? null
                                          : () async {
                                              bool existVariant = false;
                                              for (var variant
                                                  in variantsDetailsList) {
                                                if (variant['sku'].toString() ==
                                                    chosenSku.toString()) {
                                                  existVariant = true;
                                                  break;
                                                }
                                              }
                                              if (!existVariant) {
                                                var variant =
                                                    await generateVariantData(
                                                        chosenSku);
                                                setState(() {
                                                  variantsDetailsList
                                                      .add(variant);
                                                });
                                                calculateTotalWPrice();
                                                calculateTotalQuantity();
                                                // print("variantsDetailsList");
                                                // print(variantsDetailsList);
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Añadir",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        context),
                  ),
                  //
                  const SizedBox(height: 10),
                  Visibility(
                    visible: true,
                    child: Row(
                      children: [
                        Expanded(
                          // SizedBox(
                          //   // width: screenWidth * 0.80,
                          //   width: screenWidthDialog > 600
                          //       ? screenWidth * 0.90
                          //       : screenWidth * 0.60,
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children:
                                variantsDetailsList.map<Widget>((variant) {
                              String chipLabel = "${variant['variant_title']}";

                              chipLabel +=
                                  " - Cantidad: ${variant['quantity']}";
                              chipLabel +=
                                  " - Precio Bodega: ${widget.product.price.toString()}";
                              chipLabel += " - Total: \$${variant['price']}";

                              if (screenWidthDialog < 600) {
                                chipLabel = "${variant['variant_title']}";

                                chipLabel += "; ${variant['quantity']}";
                                // chipLabel +=
                                //     " - Bodega: \$${widget.product.price.toString()}";
                                chipLabel += " ;Total:\$${variant['price']}";
                              }
                              return Chip(
                                padding: EdgeInsets.all(0),
                                label: Text(chipLabel),
                                onDeleted: () {
                                  if (widget.product.isvariable == 1) {
                                    setState(() async {
                                      if (variant.containsKey('sku')) {
                                        variantsDetailsList.remove(variant);
                                      }
                                      calculateTotalWPrice();
                                      calculateTotalQuantity();
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Text(
                        "Precio Dropshipping:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        // width: 100,
                        width: screenWidthDialog > 600 ? 100 : 70,
                        child: TextFormField(
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          controller: _precioTotalEnt,
                          decoration: const InputDecoration(
                            labelText: "(Entero)",
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Campo requerido";
                            }
                          },
                        ),
                      ),
                      const Text("  .  ", style: TextStyle(fontSize: 35)),
                      SizedBox(
                        // width: 100,
                        width: screenWidthDialog > 600 ? 100 : 70,
                        child: TextFormField(
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          controller: _precioTotalDec,
                          decoration: const InputDecoration(
                            labelText: "(Decimal)",
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          var resTotalProfit = await calculateProfit();

                          setState(() {
                            profit = double.parse(resTotalProfit.toString());
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calculate, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        "Precio Bodega:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        // width: 200,
                        width: screenWidthDialog > 600 ? 200 : 150,
                        child: Text(
                          priceWarehouseTotal.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text(
                        "Costo Envio:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        // width: 200,
                        width: screenWidthDialog > 600 ? 200 : 150,
                        child: Text(
                          '\$${costShippingSeller.toString()}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text(
                        "Utilidad:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        // width: 200,
                        width: screenWidthDialog > 600 ? 200 : 150,
                        child: Text(
                          profit.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _productoE,
                    decoration: const InputDecoration(
                      labelText: "Producto Extra",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    controller: _observacion,
                    decoration: const InputDecoration(
                      labelText: "Observación",
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "CANCELAR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (selectedValueRoute == null ||
                                selectedValueTransport == null) {
                              showSuccessModal(
                                  context,
                                  "Por favor, Debe seleccionar una ciudad y una transportadora.",
                                  Icons8.alert);
                            } else {
                              // if (widget.product.isvariable == 1 &&
                              //     chosenVariant == null) {
                              if (widget.product.isvariable == 1 &&
                                  variantsDetailsList.isEmpty) {
                                showSuccessModal(
                                    context,
                                    "Por favor, Debe al menos seleccionar una variante del producto.",
                                    Icons8.alert);
                              } else {
                                if (formKey.currentState!.validate()) {
                                  getLoadingModal(context, false);

                                  String priceTotal =
                                      "${_precioTotalEnt.text}.${_precioTotalDec.text}";

                                  // String sku =
                                  //     "${chosenSku}C${widget.product.productId}";
                                  String idProd =
                                      widget.product.productId.toString();

                                  var response =
                                      await Connections().createOrderProduct(
                                    sharedPrefs!
                                        .getString("idComercialMasterSeller"),
                                    numeroOrden,
                                    _nombre.text,
                                    _direccion.text,
                                    _telefono.text,
                                    selectedValueRoute.toString().split("-")[0],
                                    _producto.text,
                                    _productoE.text,
                                    // _cantidad.text,
                                    quantityTotal,
                                    priceTotal,
                                    _observacion.text,
                                    // sku,
                                    idProd,
                                    variantsDetailsList,
                                  );

                                  var resUpdateRT = await Connections()
                                      .updateOrderRouteAndTransportLaravel(
                                    selectedValueRoute.toString().split("-")[1],
                                    selectedValueTransport
                                        .toString()
                                        .split("-")[1],
                                    response['id'],
                                  );

                                  var response3 =
                                      await Connections().updateOrderWithTime(
                                    response['id'].toString(),
                                    "estado_interno:CONFIRMADO",
                                    sharedPrefs!.getString("id"),
                                    "",
                                    "",
                                  );

                                  String messageVar = "";
                                  if (widget.product.isvariable == 1) {
                                    messageVar = " (";
                                    for (var variant in variantsDetailsList) {
                                      messageVar +=
                                          "${variant['quantity']} de ${variant['variant_title']}; ";
                                    }
                                    messageVar += ") ";
                                  }

                                  var _url = Uri.parse(
                                    """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda ${comercial}, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${messageVar}${_productoE.text.isNotEmpty ? ' y ${_productoE.text}' : ''}, por un valor total de: \$${priceTotal}. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                  );

                                  if (!await launchUrl(_url)) {
                                    throw Exception('Could not launch $_url');
                                  }

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              }
                            }
                          },
                          child: const Text(
                            "GUARDAR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String> generateNumeroOrden() async {
    final random = Random();
    int numeroAleatorio = random.nextInt(900000) + 100000;
    String codeRandom = "E${numeroAleatorio.toString()}";
    return codeRandom;
  }

  Map<String, dynamic>? findVariantBySku(String sku) {
    Map<String, dynamic>? varianteEncontrada;
    for (var variante in variantsListOriginal) {
      if (variante['sku'] == sku) {
        varianteEncontrada = variante;
        break;
      }
    }

    if (varianteEncontrada == null) {
      print('Variante con SKU $sku no encontrada.');
    } else {
      // print('Variante encontrada: $varianteEncontrada');
    }

    return varianteEncontrada;
  }

  Future<Map<String, dynamic>> generateVariantData(String sku) async {
    Map<String, dynamic>? variantFound = findVariantBySku(sku);
    //{id: 7611503, sku: CMS20LAMARILLO, size: L, color: amarillo, inventory_quantity: 10, price: 20}
    var nameChosenVariant = chosenVariant?.split('-');
    double priceT = (int.parse(quantity.toString()) *
        double.parse(widget.product.price.toString()));

    Map<String, dynamic> variant = {
      "id": widget.product.productId,
      "name": 1101,
      "quantity": quantity,
      "price": priceT,
      "title": _producto.text,
      "variant_title": widget.product.isvariable == 1
          ? "${nameChosenVariant?[1]}"
          : variantFound?['sku'],
      "sku": variantFound?['sku'],
    };

    return variant;
  }

  void updatePriceBySku(String sku, double newPrice) {
    for (var variant in variantsDetailsList) {
      if (variant['sku'] == sku) {
        variant['price'] = newPrice.toString();
        break;
      }
    }
  }

  void calculateTotalWPrice() async {
    double totalPriceWarehouse = 0;

    for (var detalle in variantsDetailsList) {
      if (detalle.containsKey('price')) {
        double price = double.parse(detalle['price'].toString());
        totalPriceWarehouse += price;
      }
    }

    totalPriceWarehouse = double.parse(totalPriceWarehouse.toStringAsFixed(2));
    setState(() {
      priceWarehouseTotal = totalPriceWarehouse;
    });
  }

  Future<double> calculateProfit() async {
    double priceDSTotal = double.parse(
        "${_precioTotalEnt.text}.${_precioTotalDec.text.replaceAll(',', '')}");
    double totalProfit =
        priceDSTotal - (priceWarehouseTotal + costShippingSeller);

    totalProfit = double.parse(totalProfit.toStringAsFixed(2));

    return totalProfit;
  }

  void calculateTotalQuantity() async {
    int total = 0;

    for (var detalle in variantsDetailsList) {
      if (detalle.containsKey('quantity')) {
        int quantity = int.parse(detalle['quantity'].toString());
        total += quantity;
      }
    }
    setState(() {
      quantityTotal = total;

      //upt Precio DropShipping
      double priceDSTotal = priceSuggestedProd * quantityTotal;
      String priceSuggested = "";
      priceSuggested = priceDSTotal.toString();

      if (priceSuggested.contains(".")) {
        var parts = priceSuggested.split('.');
        _precioTotalEnt.text = parts[0];
        _precioTotalDec.text = parts[1];
      } else {
        _precioTotalEnt.text = priceSuggested;
        _precioTotalDec.text = "00";
      }
    });
  }
}
