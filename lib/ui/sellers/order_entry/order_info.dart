import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/sellers/order_entry/controllers/controllers.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/routes.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/widgets/routes/routes_v2.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderInfo extends StatefulWidget {
  final Map order;
  final int index;
  final String codigo;
  final Function(BuildContext, int) sumarNumero;
  final List data;

  const OrderInfo(
      {super.key,
      required this.order,
      required this.index,
      required this.sumarNumero,
      required this.codigo,
      required this.data});

  @override
  State<OrderInfo> createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  var data = {};
  bool loading = true;
  OrderEntryControllers _controllers = OrderEntryControllers();
  String estadoEntrega = "";
  String estadoLogistic = "";
  String estadoInterno = "";
  String route = "";
  String carrier = "";

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool allowApertura = true;

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  String? comercial = sharedPrefs!.getString("NameComercialSeller");

  String chosenSku = "";
  double priceSuggestedProd = 0;
  double quantity = 1;
  List variantsDetailsList = [];
  double priceWarehouseTotal = 0;
  double costShippingSeller = 0;
  double profit = 0;
  int quantityTotal = 0;

//
  List<String> carriersTypeToSelect = [];
  List<String> transports = [];
  List<String> routes = [];
  String? selectedValueTransport;
  String? selectedValueRoute;

  String? selectedCarrierExternal;
  List<String> provinciasToSelect = [];
  String? selectedProvincia;
  String? selectedCarrierType;
  List<String> carriersExternalsToSelect = [];
  List<String> citiesToSelect = [];

  String? selectedCity;
  bool recaudo = true;
  String _costoEnvioExt = "";
  String _totalRecibirExt = "";

  double priceTotalProduct = 0;
  double taxCostShipping = 0;
  double costEasy = 2.3;
  String prov_city_address = "";
  var responseCarriersGeneral;

  String quantity_variant = "";
  int isvariableFirst = 0;

  //for edit variant and catidad
  Map<String, dynamic> featuresFirstProduct = {};
  List<String> variantsToSelect = [];
  List variantsFirstProduct = [];
  List variantsCurrentList = [];
  String? chosenVariant;
  List<String> variantsCurrentToSelect = [];
  String? chosenCurrentVariant;
  double quantityCurrent = 1;
  bool newVariant = false;
  TextEditingController _quantityCurrent = TextEditingController(text: "");
  TextEditingController _quantitySelectVariant =
      TextEditingController(text: "");
  int idUser = int.parse(sharedPrefs!.getString("id").toString());
  int idMaster =
      int.parse(sharedPrefs!.getString("idComercialMasterSeller").toString());

  double iva = 0.15;
  double totalCost = 0;
  bool isCarrierExternal = false;
  bool isCarrierInternal = false;

  String idCarrierExternal = "";
  String idProvExternal = "";
  String tipoCobertura = "";

  String productPname = "";
  String productFirstId = "";
  String productFirstName = "";
  String productFirstPrice = "";

  bool editProductP = true;

  List<int> idProdUniques = [];
  String allIds = "";
  List<Map<String, dynamic>> variantDetailsUniques = [];
  List variantsListProducts = [];

  @override
  void didChangeDependencies() {
    getRoutes();
    getCarriersExternals();

    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    data = widget.order;
    // print(data);
    _controllers.editControllers(widget.order);
    _controllers.precioTotalEditController.text =
        data['precio_total'].toString();
    setState(() {
      estadoEntrega = data['status'].toString();
      estadoLogistic = data['estado_logistico'].toString();
      estadoInterno = data['estado_interno'].toString();
      productPname = data['producto_p'].toString();
      // route = data['ruta'] != null && data['ruta'].toString() != "[]"
      //     ? data['ruta'][0]['titulo'].toString()
      //     : "";
      // carrier = data['transportadora'] != null &&
      //         data['transportadora'].toString() != "[]"
      //     ? data['transportadora'][0]['nombre'].toString()
      //     : "";
      route = data['ruta'] != null && data['ruta'].toString() != "[]"
          ? data['ruta'][0]['titulo'].toString()
          : data['pedido_carrier'].isNotEmpty
              ? data['pedido_carrier'][0]['city_external']['ciudad'].toString()
              : "";
      carrier =
          data['transportadora'] != null && data['transportadora'].isNotEmpty
              ? data['transportadora'][0]['nombre'].toString()
              : data['pedido_carrier'].isNotEmpty
                  ? data['pedido_carrier'][0]['carrier']['name'].toString()
                  : "";
    });

    isCarrierExternal = data['pedido_carrier'].isNotEmpty ? true : false;
    isCarrierInternal = data['transportadora'].isNotEmpty ? true : false;
    // print("isCarrierExternal: $isCarrierExternal");
    // print("isCarrierInternal: $isCarrierInternal");
    // print("estadoLogistic: $estadoLogistic");
    if (isCarrierExternal) {
      selectedCarrierType = "Externo";
    }

    if (data['id_product'] != null &&
        data['id_product'] != 0 &&
        data['variant_details'] != null &&
        data['variant_details'].toString() != "[]" &&
        data['variant_details'].isNotEmpty) {
      //
      carriersTypeToSelect = ["Interno", "Externo"];

      editProductP = false;
      print("editProductP :$editProductP");

      productFirstId = data['product']['product_id'].toString();
      productFirstName = data['product']['product_name'].toString();
      productFirstPrice = data['product']['price'].toString();

      isvariableFirst = data['product']['isvariable'];

      prov_city_address = getWarehouseAddress(data['product']['warehouses']);

      print("p_c_dir: $prov_city_address");
      print("var: $isvariableFirst");

      featuresFirstProduct = jsonDecode(data['product']["features"]);
      variantsFirstProduct = featuresFirstProduct["variants"];

      List<dynamic> variantDetails = jsonDecode(data['variant_details']);
      variantDetailsUniques = mergeDuplicateSKUs(variantDetails);

      idProdUniques =
          await extractUniqueIds(jsonDecode(data['variant_details']));

      var responseProducts =
          await Connections().getProductsByIds(idProdUniques, []);
      variantsListProducts = responseProducts;
      // print("variantsListProducts: $variantsListProducts");
      allIds = idProdUniques.map((e) => e.toString()).join('; ');
      buildVariantsDetailsToSelect();

      /*
      variantsListOriginal = features["variants"];
      variantsToSelect = [];
      for (var variant in variantsListOriginal) {
        List<String> valuesToConcatenate = [];

        for (var entry in variant.entries) {
          if (entry.key != "id" &&
              entry.key != "sku" &&
              entry.key != "inventory_quantity" &&
              entry.key != "price") {
            // concatenatedValues += '${entry.value}-';
            valuesToConcatenate.add(entry.value.toString());
          }
        }
        String concatenatedValues = valuesToConcatenate.join('/');
        // if (variantsListOriginal.length > 1) {
        //   concatenatedValues =
        //       concatenatedValues.substring(0, concatenatedValues.length - 1);
        // }

        // variantsToSelect.add(concatenatedValues);
        variantsToSelect.add('${variant["sku"]}|$concatenatedValues');
      }
      */
      //
    } else {
      print("no id_p or var_det !!");
      carriersTypeToSelect = ["Interno"];
    }
/*
    var variants = data['variant_details'] != null &&
            data['variant_details'].toString() != "[]" &&
            data['variant_details'].isNotEmpty
        ? data['variant_details'].toString()
        : "";
    List<Map<String, dynamic>> variantDetails = [];

    if (data['id_product'] != null &&
        data['id_product'] != 0 &&
        data['variant_details'] != null &&
        data['variant_details'].toString() != "[]" &&
        data['variant_details'].isNotEmpty) {
      //
      variantDetails = jsonDecode(variants).cast<Map<String, dynamic>>();
      for (var detail in variantDetails) {
        quantity_variant +=
            '${detail['quantity']}*${detail['variant_title']} | ';
        var value = {
          "id": detail['id'],
          "name": detail['name'],
          "quantity": detail['quantity'],
          "price": detail['price'],
          "title": detail['title'],
          "variant_title": detail['variant_title'],
          "sku": detail['sku'],
        };
        variantsCurrentList.add(value);
      }

      // quantity_variant = quantity_variant.trim();
      quantity_variant =
          quantity_variant.substring(0, quantity_variant.length - 3);
      // buildVariantsCurrentToSelect();
    }
    // print("variantsCurrentList: $variantsCurrentList");

    // print("variantsCurrentToSelect: $variantsCurrentToSelect");

    if (data['id_product'] != null && data['id_product'] != 0) {
      carriersTypeToSelect = ["Interno", "Externo"];
      // if (idUser == 2 || idMaster == 188 || idMaster == 189) {
      //   carriersTypeToSelect = ["Interno", "Externo"];
      // } else {
      //   carriersTypeToSelect = ["Interno"];
      // }
    } else {
      carriersTypeToSelect = ["Interno"];
    }
    // recaudo = data['recaudo'].toString() == "1" ? true : false;
*/
    setState(() {
      quantity_variant = quantity_variant;
    });
    setState(() {
      loading = false;
    });
  }

  List<Map<String, dynamic>> mergeDuplicateSKUs(List<dynamic> originalList) {
    Map<String, Map<String, dynamic>> skuMap = {};
    List<Map<String, dynamic>> mergedList = [];
    List<Map<String, dynamic>> nullSKUs = [];

    for (var item in originalList) {
      String? sku = item['sku'];
      if (sku != null) {
        int quantity = item['quantity'] ?? 0;

        if (skuMap.containsKey(sku)) {
          skuMap[sku]!['quantity'] = (skuMap[sku]!['quantity'] ?? 0) + quantity;
        } else {
          skuMap[sku] = Map<String, dynamic>.from(item);
        }
      } else {
        nullSKUs.add(Map<String, dynamic>.from(item));
      }
    }

    mergedList.addAll(skuMap.values);
    mergedList.addAll(nullSKUs);

    return mergedList;
  }

  void buildVariantsDetailsToSelect() {
    variantsCurrentToSelect = [];

    RegExp pattern = RegExp(r'^[a-zA-Z0-9]+C\d+$');
    // print("variantDetailsOriginal: $variantDetailsUniques");
    for (var variant in variantDetailsUniques) {
      String? skuVariant = variant['sku'];
      // String? id = variant['id'];

      if (skuVariant != null &&
          skuVariant != "" &&
          pattern.hasMatch(skuVariant)) {
        int indexOfC = skuVariant.lastIndexOf('C');
        String onlySku = skuVariant.substring(0, indexOfC);
        String onlyId = skuVariant.substring(indexOfC + 1);

        for (var productData in variantsListProducts) {
          String idProd = productData['product_id'].toString();

          if (onlyId == idProd) {
            String productName = productData['product_name'];
            String variable = productData['isvariable'].toString();

            var features = jsonDecode(productData["features"]);
            if (variable == "0") {
              if (onlySku == features["sku"].toString()) {
                variantsCurrentToSelect
                    .add("$skuVariant|$productName|$productName|0");
              }
            } else {
              var featuresVariants = features["variants"];
              // print("featuresVariants: $featuresVariants");
              for (var element in featuresVariants) {
                if (onlySku == element["sku"].toString()) {
                  String elementString = buildVariantTitle(element);
                  // print("onlySku: $onlySku");
                  // print("armar variant/title con:");
                  // print(elementString);
                  variantsCurrentToSelect
                      .add("$skuVariant|$elementString|$productName|1");
                }
              }
            }
            break;
          }
        }
      }
    }

    print("variantsCurrentToSelect: $variantsCurrentToSelect");
  }

  String buildVariantTitle(Map<String, dynamic> element) {
    List<String> excludeKeys = ['id', 'sku', 'inventory_quantity', 'price'];
    List<String> elementDetails = [];

    element.forEach((key, value) {
      if (!excludeKeys.contains(key)) {
        elementDetails.add("$value");
      }
    });

    return elementDetails.join("/");
  }

  List<int> extractUniqueIds(List variant_details) {
    Set<String> uniqueSkus = {};
    RegExp pattern = RegExp(r'^[a-zA-Z0-9]+C\d+$');

    for (var item in variant_details) {
      String? sku = item['sku'];

      if (sku != null && sku != "" && pattern.hasMatch(sku)) {
        uniqueSkus.add(item['sku']);
      }
    }

    List<int> digitsList = [];

    for (var sku in uniqueSkus) {
      int indexOfC = sku.lastIndexOf('C');
      if (indexOfC != -1 && indexOfC + 1 < sku.length) {
        String digits = sku.substring(indexOfC + 1);
        digitsList.add(int.parse(digits));
      }
    }

    return digitsList;
  }

  void buildVariantsToSelect(List<dynamic> variantsProduct) {
    //
    try {
      for (var variant in variantsProduct) {
        String nameVariantTitle = buildVariantTitle(variant);
        variantsToSelect.add('${variant['sku']}|$nameVariantTitle');
      }
      setState(() {});
    } catch (e) {
      print("buildVariantsToSelect $e");
    }
  }

  updateData() async {
    var response = await Connections().getOrdersByIdLaravel(widget.order['id']);
    data = response;
    //print(data);
    _controllers.editControllers(response);
    setState(() {
      estadoInterno = data['estado_interno'].toString();
      estadoEntrega = data['status'].toString();
      estadoLogistic = data['estado_logistico'].toString();
      productPname = data['producto_p'].toString();
      _controllers.precioTotalEditController.text =
          data['precio_total'].toString();
      // route = data['ruta'] != null && data['ruta'].toString() != "[]"
      //     ? data['ruta'][0]['titulo'].toString()
      //     : "";
      // carrier = data['transportadora'] != null &&
      //         data['transportadora'].toString() != "[]"
      //     ? data['transportadora'][0]['nombre'].toString()
      //     : "";
      route = data['ruta'] != null && data['ruta'].toString() != "[]"
          ? data['ruta'][0]['titulo'].toString()
          : data['pedido_carrier'].isNotEmpty
              ? data['pedido_carrier'][0]['city_external']['ciudad'].toString()
              : "";
      carrier =
          data['transportadora'] != null && data['transportadora'].isNotEmpty
              ? data['transportadora'][0]['nombre'].toString()
              : data['pedido_carrier'].isNotEmpty
                  ? data['pedido_carrier'][0]['carrier']['name'].toString()
                  : "";
    });

    setState(() {
      loading = false;
    });
  }

  getRoutes() async {
    try {
      var routesList = await Connections().getRoutesLaravel();
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
        transports
            .add('${transportList[i]['nombre']}-${transportList[i]['id']}');
      }

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {});
    } catch (error) {
      print('Error al cargar rutas: $error');
    }
  }

  getCarriersExternals() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      setState(() {
        carriersExternalsToSelect = [];
        selectedCarrierExternal = null;
      });
      responseCarriersGeneral = await Connections().getCarriersExternal([], "");
      for (var item in responseCarriersGeneral) {
        carriersExternalsToSelect.add("${item['name']}-${item['id']}");
      }
      // print(responseCarriersGeneral.runtimeType);
      // print(responseCarriersGeneral);
      setState(() {
        carriersExternalsToSelect = carriersExternalsToSelect;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (error) {
      print('Error al cargar TranspExter: $error');
    }
  }

  getProvincias() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      setState(() {
        provinciasToSelect = [];
        selectedProvincia = null;
      });
      var provinciasList = [];

      provinciasList = await Connections().getProvincias();
      for (var i = 0; i < provinciasList.length; i++) {
        provinciasToSelect.add('${provinciasList[i]}');
      }
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {});
    } catch (error) {
      print('Error al cargar Provincias: $error');
    }
  }

  getCiudades() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      var dataCities;
      setState(() {
        citiesToSelect = [];
        dataCities = [];
        selectedCity = null;
      });

      var responseCities = await Connections().getCoverageAll(
          150,
          1,
          [],
          [
            {
              "equals/carriers_external_simple.id":
                  selectedCarrierExternal.toString().split("-")[1]
            },
            {
              "equals/coverage_external.dpa_provincia.id":
                  selectedProvincia.toString().split("-")[1]
            }
          ],
          "id:desc",
          "");
      dataCities = [responseCities['data']];
      for (var lista in dataCities) {
        for (Map<String, dynamic> elemento in lista) {
          String ciudad =
              "${elemento['coverage_external']['ciudad']}-${elemento['id_coverage']}-${elemento['type']}-${elemento['id_prov_ref']}-${elemento['id_ciudad_ref']}";
          citiesToSelect.add(ciudad);
        }
      }
      setState(() {});
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (error) {
      print('Error al cargar Ciudades: $error');
    }
  }

  String getWarehouseAddress(dynamic warehouses) {
    String name = "";

    List<WarehouseModel> warehousesList = [];

    for (var warehouseJson in warehouses) {
      if (warehouseJson is Map<String, dynamic>) {
        WarehouseModel warehouse = WarehouseModel.fromJson(warehouseJson);
        warehousesList.add(warehouse);

        if (warehousesList?.length == 1) {
          WarehouseModel firstWarehouse = warehousesList!.first;
          name =
              "${firstWarehouse.id_provincia.toString()}|${firstWarehouse.city.toString()}|${firstWarehouse.address.toString()}";
        } else {
          WarehouseModel lastWarehouse = warehousesList!.last;
          name =
              "${lastWarehouse.id_provincia.toString()}|${lastWarehouse.city.toString()}|${lastWarehouse.address.toString()}";
        }
      } else {
        print('El elemento de la lista no es un mapa válido: $warehouseJson');
      }
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Container(),
        centerTitle: true,
        title: const Text(
          "Información Pedido",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: loading == true
                  ? Container()
                  // : Column(
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: screenWidth * 0.5,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    (estadoInterno == "CONFIRMADO" &&
                                                estadoLogistic !=
                                                    "PENDIENTE") ||
                                            isCarrierExternal
                                        ? Container()
                                        : ElevatedButton(
                                            onPressed: () async {
                                              var response = await Connections()
                                                  .updateOrderInteralStatusLaravel(
                                                      "NO DESEA",
                                                      widget.order["id"]);

                                              widget.sumarNumero(
                                                  context, widget.index);

                                              setState(() {});
                                            },
                                            child: const Text(
                                              "No Desea",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )),
                                    // SizedBox(
                                    //   width: 20,
                                    // ),
                                    // (estadoInterno == "CONFIRMADO" &&
                                    //         estadoLogistic != "PENDIENTE")
                                    //     ? Container()
                                    //     : ElevatedButton(
                                    //         onPressed: () async {
                                    //           await showDialog(
                                    //               context: context,
                                    //               builder: (context) {
                                    //                 return RoutesModalv2(
                                    //                   idOrder:
                                    //                       widget.order["id"],
                                    //                   someOrders: false,
                                    //                   phoneClient: data[
                                    //                           'telefono_shipping']
                                    //                       .toString(),
                                    //                   codigo: widget.codigo,
                                    //                   origin: "",
                                    //                 );
                                    //               });
                                    //           updateData();
                                    //         },
                                    //         child: Text(
                                    //           "Confirmar",
                                    //           style: TextStyle(
                                    //               fontWeight: FontWeight.bold),
                                    //         )),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    ElevatedButton(
                                      onPressed: !isCarrierExternal
                                          ? () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                getLoadingModal(context, false);

                                                //btnGuardar
                                                print("**********************");

                                                String labelProducto = "";
                                                /*
                                                if (data['variant_details'] !=
                                                    null) {
                                                  //
                                                  print(
                                                      "tiene variant_details");

                                                  if (data['id_product'] !=
                                                          null &&
                                                      data['id_product'] != 0) {
                                                    //
                                                    print("tiene id_product");

                                                    List<Map<String, dynamic>>
                                                        groupedProducts =
                                                        groupProducts(
                                                            variantsCurrentList);
                                                    // print(
                                                    //     "groupedProducts: $groupedProducts");

                                                    if (isvariable == 1) {
                                                      print("is variable upt ");
                                                      // print(
                                                      //     "variantsCurrentList: $variantsCurrentList");

                                                      for (var product
                                                          in groupedProducts) {
                                                        labelProducto +=
                                                            '${product['name']} ${product['variants']}; \n';
                                                      }

                                                      labelProducto =
                                                          labelProducto.substring(
                                                              0,
                                                              labelProducto
                                                                      .length -
                                                                  3);
                                                    } else {
                                                      variantsCurrentList[0]
                                                              ['quantity'] =
                                                          int.parse(_controllers
                                                              .cantidadEditController
                                                              .text);

                                                      print(
                                                          "variantsCurrentList: $variantsCurrentList");

                                                      for (var variant
                                                          in variantsCurrentList) {
                                                        labelProducto +=
                                                            '${variant['quantity']}*${variant['title']}; \n';
                                                      }
                                                    }

                                                    if (isvariable == 1) {
                                                      print("is variable upt ");
                                                      // print(
                                                      //     "variantsCurrentList: $variantsCurrentList");
                                                      getTotalQuantity();
                                                    } else {
                                                      variantsCurrentList[0]
                                                              ['quantity'] =
                                                          int.parse(_controllers
                                                              .cantidadEditController
                                                              .text);

                                                      // print(
                                                      //     "variantsCurrentList: $variantsCurrentList");
                                                    }
                                                    var response2 =
                                                        await Connections()
                                                            .updatenueva(
                                                                data['id'], {
                                                      "variant_details":
                                                          variantsCurrentList,
                                                    });
                                                  } else {
                                                    //
                                                    print(
                                                        "NO tiene id_product");
                                                    labelProducto = _controllers
                                                        .productoEditController
                                                        .text;
                                                  }
                                                } else {
                                                  //
                                                  print(
                                                      "NO tiene variants_details");
                                                  labelProducto = _controllers
                                                      .productoEditController
                                                      .text;
                                                }
                                                */

                                                if (data['id_product'] !=
                                                        null &&
                                                    data['id_product'] != 0 &&
                                                    data['variant_details'] !=
                                                        null &&
                                                    data['variant_details']
                                                            .toString() !=
                                                        "[]" &&
                                                    data['variant_details']
                                                        .isNotEmpty) {
                                                  //

                                                  //updt with local names
                                                  renameProductVariantTitle();
                                                  calculateTotalWPrice();
                                                  // print(
                                                  //     "actual variantDetailsUniques: $variantDetailsUniques");

                                                  List<Map<String, dynamic>>
                                                      groupedProducts =
                                                      groupProducts(
                                                          variantDetailsUniques);
                                                  // print(
                                                  //     "groupedProducts: $groupedProducts");
                                                  //

                                                  for (var product
                                                      in groupedProducts) {
                                                    labelProducto +=
                                                        '${product['name']} ${product['variants']}; \n';
                                                  }

                                                  labelProducto =
                                                      labelProducto.substring(
                                                          0,
                                                          labelProducto.length -
                                                              3);

                                                  var response2 =
                                                      await Connections()
                                                          .updatenueva(
                                                              data['id'], {
                                                    "variant_details":
                                                        variantDetailsUniques,
                                                  });
                                                  //
                                                } else {
                                                  print(
                                                      "NO tiene variants_details o productID es 0");
                                                  labelProducto = _controllers
                                                      .productoEditController
                                                      .text;
                                                }

                                                print(
                                                    "labelProducto: $labelProducto");

                                                await _controllers.updateInfo(
                                                    id: widget.order["id"],
                                                    success: () async {
                                                      Navigator.pop(context);
                                                      AwesomeDialog(
                                                        width: 500,
                                                        context: context,
                                                        dialogType:
                                                            DialogType.success,
                                                        animType:
                                                            AnimType.rightSlide,
                                                        title: 'Guardado',
                                                        desc: '',
                                                        btnCancel: Container(),
                                                        btnOkText: "Aceptar",
                                                        btnOkColor:
                                                            colors.colorGreen,
                                                        btnCancelOnPress: () {},
                                                        btnOkOnPress: () {},
                                                      ).show();

                                                      await Connections()
                                                          .updatenueva(
                                                              data['id'], {
                                                        "producto_p":
                                                            labelProducto,
                                                      });
                                                      print(
                                                          "updated producto_p");
                                                      await updateData();
                                                    },
                                                    error: () {
                                                      Navigator.pop(context);

                                                      AwesomeDialog(
                                                        width: 500,
                                                        context: context,
                                                        dialogType:
                                                            DialogType.error,
                                                        animType:
                                                            AnimType.rightSlide,
                                                        title:
                                                            'Data Incorrecta',
                                                        desc:
                                                            'Vuelve a intentarlo',
                                                        btnCancel: Container(),
                                                        btnOkText: "Aceptar",
                                                        btnOkColor:
                                                            colors.colorGreen,
                                                        btnCancelOnPress: () {},
                                                        btnOkOnPress: () {},
                                                      ).show();
                                                    });
                                              }
                                            }
                                          : null,
                                      child: const Text(
                                        "Guardar",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Código: ${sharedPrefs!.getString("NameComercialSeller").toString()}-${data['numero_orden'].toString()}",
                                ),
                                Text(
                                  "Fecha de Ingreso: ${data['marca_t_i'].toString()}",
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller: _controllers.ciudadEditController,
                                  decoration: const InputDecoration(
                                    labelText: "Ciudad",
                                    // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  enabled: !isCarrierExternal,
                                  // readOnly: isCarrierExternal,
                                  // enabled: (isCarrierInternal &&
                                  //         estadoLogistic == "PENDIENTE") ||
                                  //     (!isCarrierExternal &&
                                  //         !isCarrierInternal),
                                  keyboardType: TextInputType.text,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "Campo requerido";
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller: _controllers.nombreEditController,
                                  decoration: const InputDecoration(
                                    labelText: "Nombre Cliente",
                                    // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  // enabled: !isCarrierExternal,
                                  readOnly: isCarrierExternal,
                                  keyboardType: TextInputType.text,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "Campo requerido";
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.direccionEditController,
                                  decoration: const InputDecoration(
                                    labelText: "Dirección",
                                    // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  // enabled: !isCarrierExternal,
                                  readOnly: isCarrierExternal,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "Campo requerido";
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.telefonoEditController,
                                  decoration: const InputDecoration(
                                    labelText: "Teléfono",
                                    // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  // enabled: !isCarrierExternal,
                                  readOnly: isCarrierExternal,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9+]')),
                                  ],
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "Campo requerido";
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                // Text(
                                //   "ID Producto: ${data['id_product'] != null && data['id_product'] != 0 ? data['id_product'].toString() : ""}",
                                // ),
                                //
                                Text(
                                  "ID Producto: $allIds",
                                ),

                                // const SizedBox(height: 10),
                                // const Text(
                                //   "Producto",
                                //   style: TextStyle(
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                // Text(
                                //   productPname,
                                //   style: const TextStyle(
                                //     fontSize: 16,
                                //   ),
                                // ),
                                TextFormField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.productoEditController,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: "Producto",
                                  ),
                                  // enabled: !isCarrierExternal && editProductP,
                                  readOnly: (isCarrierExternal) ||
                                      (!isCarrierExternal && !editProductP),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "Campo requerido";
                                    }
                                  },
                                ),
                                //new
                                Visibility(
                                  visible: (!editProductP &&
                                          isCarrierInternal &&
                                          estadoLogistic == "PENDIENTE") ||
                                      (!editProductP &&
                                          !isCarrierExternal &&
                                          !isCarrierInternal),
                                  child: const SizedBox(height: 15),
                                ),
                                Visibility(
                                  // visible: (isCarrierInternal &&
                                  //         estadoLogistic == "PENDIENTE" &&
                                  //         isvariable == 0) ||
                                  //     (!isCarrierExternal &&
                                  //         !isCarrierInternal &&
                                  //         isvariable == 0),
                                  visible: (!editProductP &&
                                          isCarrierInternal &&
                                          estadoLogistic == "PENDIENTE") ||
                                      (!editProductP &&
                                          !isCarrierExternal &&
                                          !isCarrierInternal),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 270,
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          hint: Text(
                                            'Seleccione Producto Existente',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Theme.of(context).hintColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          items: variantsCurrentToSelect
                                              .map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item.split('|')[1],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          value: chosenCurrentVariant,
                                          onChanged: !isCarrierExternal
                                              ? (value) {
                                                  setState(() {
                                                    chosenCurrentVariant =
                                                        value as String;
                                                    print(chosenCurrentVariant!
                                                        .split('|')[0]
                                                        .toString());
                                                    try {
                                                      _quantityCurrent
                                                          .text = getTotalQuantityBySku(
                                                              variantDetailsUniques,
                                                              chosenCurrentVariant!
                                                                  .split('|')[0]
                                                                  .toString())
                                                          .toString();
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                  });
                                                }
                                              : null,
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
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          controller: _quantityCurrent,
                                          maxLines: null,
                                          decoration: const InputDecoration(
                                            labelText: "Cantidad",
                                            labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: !isCarrierExternal
                                            ? () {
                                                print(chosenCurrentVariant);
                                                if (chosenCurrentVariant !=
                                                        null &&
                                                    _quantityCurrent.text !=
                                                        "") {
                                                  //
                                                  try {
                                                    updateQuantityBySku(
                                                        variantDetailsUniques,
                                                        chosenCurrentVariant!,
                                                        int.parse(
                                                            _quantityCurrent
                                                                .text));

                                                    setState(() {});
                                                  } catch (e) {
                                                    print(e);
                                                  }
                                                }
                                                print(
                                                    "variantDetailsUniques_Utp: $variantDetailsUniques");
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                        ),
                                        child: const Text(
                                          "Editar",
                                          style: TextStyle(
                                            color: Colors.white,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Visibility(
                                        visible: (isCarrierInternal &&
                                                estadoLogistic == "PENDIENTE" &&
                                                isvariableFirst == 1) ||
                                            (!isCarrierExternal &&
                                                !isCarrierInternal &&
                                                isvariableFirst == 1),
                                        child: ElevatedButton(
                                          onPressed: !isCarrierExternal
                                              ? () {
                                                  newVariant = true;
                                                  buildVariantsToSelect(
                                                      variantsFirstProduct);

                                                  setState(() {});
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.indigo.shade300,
                                          ),
                                          child: const Text(
                                            "Nuevo",
                                            style: TextStyle(
                                              color: Colors.white,
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Visibility(
                                  visible: isvariableFirst == 1,
                                  child: const SizedBox(height: 5),
                                ),
                                Visibility(
                                  visible: newVariant,
                                  child: Text("Nuevo"),
                                ),
                                Visibility(
                                  visible: newVariant,
                                  child: Row(
                                    children: [
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: 250,
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          hint: Text(
                                            'Seleccione Variante Nueva',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Theme.of(context).hintColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          items: variantsToSelect.map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item.split('|')[1].toString(),
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
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          controller: _quantitySelectVariant,
                                          maxLines: null,
                                          decoration: const InputDecoration(
                                            labelText: "Cantidad",
                                            labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          chosenSku = chosenVariant!
                                              .split('|')[0]
                                              .toString();
                                          //armar {} y añadir en variantsCurrentToSelect
                                          print(chosenSku);
                                          try {
                                            var variantToUpdate =
                                                variantDetailsUniques
                                                    .firstWhere(
                                              (variant) =>
                                                  variant['sku'] ==
                                                  "${chosenSku}C$productFirstId",
                                              orElse: () => <String, dynamic>{},
                                            );

                                            if (variantToUpdate.isNotEmpty) {
                                              // No es necesario parsear a int
                                              print("Ya existe esta variante");
                                            } else {
                                              var variantResult =
                                                  await generateVariantData(
                                                      chosenSku);
                                              variantDetailsUniques
                                                  .add(variantResult);

                                              print(
                                                  "variantDetailsUniques actual:");
                                              print(variantDetailsUniques);
                                              buildVariantsDetailsToSelect();
                                              getTotalQuantityVariantsUniques();
                                              chosenVariant = null;
                                              _quantitySelectVariant.clear();
                                            }
                                          } catch (e) {
                                            print("Error: $e");
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                        ),
                                        child: const Text(
                                          "Añadir",
                                          style: TextStyle(
                                            color: Colors.white,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: variantDetailsUniques
                                      .map<Widget>((variable) {
                                    String chipLabel =
                                        "${variable['quantity']}*${variable['variant_title'].toString() != "null" && variable['variant_title'].toString() != "" ? variable['variant_title'] : variable['title']}";

                                    return Chip(
                                      label: Text(chipLabel),
                                      onDeleted: (isCarrierInternal &&
                                                  estadoLogistic ==
                                                      "PENDIENTE") ||
                                              (!isCarrierExternal &&
                                                  !isCarrierInternal)
                                          ? () {
                                              if (variantDetailsUniques.length >
                                                  1) {
                                                setState(() {
                                                  variantDetailsUniques
                                                      .remove(variable);
                                                });
                                                print(
                                                    "variantDetailsUniques actual:");
                                                print(variantDetailsUniques);
                                                buildVariantsDetailsToSelect();
                                                getTotalQuantityVariantsUniques();
                                              } else {
                                                print(
                                                    "No se puede eliminar el último elemento.");
                                                showSuccessModal(
                                                    context,
                                                    "Error, No se puede eliminar el último elemento.",
                                                    Icons8.alert);
                                              }
                                            }
                                          : null,
                                    );
                                  }).toList(),
                                ),
                                /*
                                Visibility(
                                  visible: (isCarrierInternal &&
                                          estadoLogistic == "PENDIENTE" &&
                                          isvariableFirst == 1) ||
                                      (!isCarrierExternal &&
                                          !isCarrierInternal &&
                                          isvariableFirst == 1),
                                  child: const SizedBox(height: 10),
                                ),
                                Visibility(
                                  visible: (isCarrierInternal &&
                                          estadoLogistic == "PENDIENTE" &&
                                          isvariableFirst == 1) ||
                                      (!isCarrierExternal &&
                                          !isCarrierInternal &&
                                          isvariableFirst == 1),
                                  // isvariable == 1 && !isCarrierExternal,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 270,
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          hint: Text(
                                            'Seleccione Variante Existente',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Theme.of(context).hintColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          items: variantsCurrentToSelect
                                              .map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item.split('|')[1],
                                                // child: Text(
                                                //   item,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          value: chosenCurrentVariant,
                                          onChanged: !isCarrierExternal
                                              ? (value) {
                                                  setState(() {
                                                    chosenCurrentVariant =
                                                        value as String;

                                                    _quantityCurrent
                                                        .text = getQuantityBySku(
                                                            chosenCurrentVariant!
                                                                .split('|')[0]
                                                                .toString())
                                                        .toString();
                                                  });
                                                }
                                              : null,
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
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          controller: _quantityCurrent,
                                          maxLines: null,
                                          decoration: const InputDecoration(
                                            labelText: "Cantidad",
                                            labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: !isCarrierExternal
                                            ? () {
                                                print(chosenCurrentVariant);
                                                if (chosenCurrentVariant !=
                                                        null &&
                                                    _quantityCurrent.text !=
                                                        "") {
                                                  updateQuantityBySku(
                                                      variantsCurrentList,
                                                      chosenCurrentVariant!
                                                          .split('|')[0],
                                                      int.parse(_quantityCurrent
                                                          .text));

                                                  setState(() {});
                                                }
                                                print(
                                                    "variantsCurrentList_Utp: $variantsCurrentList");
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                        ),
                                        child: const Text(
                                          "Editar",
                                          style: TextStyle(
                                            color: Colors.white,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: !isCarrierExternal
                                            ? () {
                                                newVariant = true;
                                                setState(() {});
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                        ),
                                        child: const Text(
                                          "Nuevo",
                                          style: TextStyle(
                                            color: Colors.white,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: isvariableFirst == 1,
                                  child: const SizedBox(height: 5),
                                ),
                                Visibility(
                                  visible: newVariant,
                                  child: Text("Nuevo"),
                                ),
                                Visibility(
                                  visible: newVariant,
                                  child: Row(
                                    children: [
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: 250,
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          hint: Text(
                                            'Seleccione Variante Nueva',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  Theme.of(context).hintColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          items: variantsToSelect.map((item) {
                                            return DropdownMenuItem(
                                              value: item,
                                              child: Text(
                                                item.split('|')[1].toString(),
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
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          controller: _quantitySelectVariant,
                                          maxLines: null,
                                          decoration: const InputDecoration(
                                            labelText: "Cantidad",
                                            labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          chosenSku = chosenVariant!
                                              .split('|')[0]
                                              .toString();
                                          //armar {} y añadir en variantsCurrentToSelect
                                          print(chosenSku);
                                          try {
                                            var variantToUpdate =
                                                variantsCurrentList.firstWhere(
                                              (variant) =>
                                                  variant['sku'] ==
                                                  "${chosenSku}C$productFirstId",
                                              orElse: () => null,
                                            );

                                            if (variantToUpdate != null) {
                                              // No es necesario parsear a int
                                              print("Ya existe esta variante");
                                            } else {
                                              var variantResult =
                                                  await generateVariantData(
                                                      chosenSku);
                                              variantsCurrentList
                                                  .add(variantResult);

                                              print(
                                                  "variantsCurrentList actual:");
                                              print(variantsCurrentList);
                                              buildVariantsCurrentToSelect();
                                              getTotalQuantity();
                                              chosenVariant = null;
                                              _quantitySelectVariant.clear();
                                            }
                                          } catch (e) {
                                            print("Error: $e");
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                        ),
                                        child: const Text(
                                          "Añadir",
                                          style: TextStyle(
                                            color: Colors.white,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: isvariableFirst == 1,
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: variantsCurrentList
                                        .map<Widget>((variable) {
                                      String chipLabel =
                                          "${variable['quantity']}*${variable['variant_title'].toString() != "null" && variable['variant_title'].toString() != "" ? variable['variant_title'] : variable['title']}";

                                      return Chip(
                                        label: Text(chipLabel),
                                        onDeleted: (isCarrierInternal &&
                                                    estadoLogistic ==
                                                        "PENDIENTE" &&
                                                    isvariableFirst == 1) ||
                                                (!isCarrierExternal &&
                                                    !isCarrierInternal &&
                                                    isvariableFirst == 1)
                                            ? () {
                                                setState(() {
                                                  // Eliminar el elemento de variantsCurrentList
                                                  variantsCurrentList
                                                      .remove(variable);
                                                });
                                                print(
                                                    "variantsCurrentList actual:");
                                                print(variantsCurrentList);
                                                buildVariantsCurrentToSelect();
                                                getTotalQuantity();
                                              }
                                            : null,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                */
                                const SizedBox(height: 10),
                                TextFormField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.cantidadEditController,
                                  enabled: (editProductP &&
                                      isvariableFirst == 0 &&
                                      !isCarrierExternal),
                                  // readOnly:
                                  //     isvariable == 1 && isCarrierExternal,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: "Cantidad",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "Campo requerido";
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                Visibility(
                                  visible: estadoLogistic != "PENDIENTE",
                                  child: TextField(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    controller:
                                        _controllers.precioTotalEditController,
                                    decoration: const InputDecoration(
                                      labelText: "Precio Total",
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // enabled: !isCarrierExternal,
                                    readOnly: isCarrierExternal,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}$')),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: isCarrierInternal &&
                                      estadoLogistic != "PENDIENTE",
                                  child: const SizedBox(height: 10),
                                ),
                                TextField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.productoExtraEditController,
                                  // enabled: !isCarrierExternal,
                                  readOnly: isCarrierExternal,
                                  decoration: const InputDecoration(
                                    labelText: "Producto Extra",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.observacionEditController,
                                  // enabled: !isCarrierExternal,
                                  readOnly: isCarrierExternal,
                                  decoration: const InputDecoration(
                                    labelText: "Observación",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                //estadoEntrega
                                Text(
                                  "Estado Confirmado: $estadoInterno",
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Estado Logístico: $estadoLogistic",
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Estado Entrega: $estadoEntrega",
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Ciudad: $route",
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  // "  Transportadora: ${data['transportadora'] != null && data['transportadora'].isNotEmpty ? data['transportadora'][0]['nombre'].toString() : ''}",
                                  "Transportadora: $carrier",
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        (estadoLogistic != "PENDIENTE")
                            ? Container()
                            : Align(
                                alignment: Alignment.topLeft,
                                child: SingleChildScrollView(
                                  child: _sectionCarriers(context),
                                ),
                              ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Column _sectionCarriers(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TRANSPORTADORA",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: screenWidth > 600 ? 350 : 250,
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                'Tipo',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.bold),
              ),
              items: carriersTypeToSelect
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
              value: selectedCarrierType,
              onChanged: !isCarrierExternal
                  ? (value) async {
                      if (data['id_product'] != null &&
                          data['id_product'] != 0 &&
                          data['variant_details'] != null &&
                          data['variant_details'].toString() != "[]" &&
                          data['variant_details'].isNotEmpty) {
                        renameProductVariantTitle();
                        calculateTotalWPrice();
                      }

                      setState(() {
                        selectedCarrierType = value as String;
                      });
                      if (selectedCarrierType == "Externo") {
                        getCarriersExternals();
                      }
                      // await getTransports();
                    }
                  : null,
            ),
          ),
        ),
        const Row(
          children: [
            Text(
              "Destino:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        //interno
        Visibility(
          visible: selectedCarrierType == "Interno",
          child: SizedBox(
            width: screenWidth > 600 ? 350 : 250,
            child: DropdownButtonHideUnderline(
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
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedValueRoute,
                onChanged: !isCarrierInternal ||
                        (isCarrierInternal && estadoLogistic == "PENDIENTE")
                    ? (value) async {
                        setState(() {
                          selectedValueRoute = value as String;
                          // print(selectedValueRoute);
                          transports.clear();
                          selectedValueTransport = null;
                        });
                        await getTransports();
                      }
                    : null,
              ),
            ),
          ),
        ),
        Visibility(
          visible: selectedCarrierType == "Interno",
          child: SizedBox(
            width: screenWidth > 600 ? 350 : 250,
            child: DropdownButtonHideUnderline(
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
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedValueTransport,
                onChanged: selectedValueRoute == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedValueTransport = value as String;
                          // print(selectedValueTransport);
                        });
                      },
              ),
            ),
          ),
        ),
        //externo
        Visibility(
          visible: selectedCarrierType == "Externo" && !isCarrierExternal,
          child: SizedBox(
            width: screenWidth > 600 ? 350 : 250,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Seleccione Transportadora Externa',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold),
                ),
                items: carriersExternalsToSelect
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.split('-')[0],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedCarrierExternal,
                onChanged: (value) async {
                  setState(() {
                    selectedCarrierExternal = value as String;
                  });
                  await getProvincias();
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: selectedCarrierType == "Externo" && !isCarrierExternal,
          child: SizedBox(
            width: screenWidth > 600 ? 350 : 250,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Provincia',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold),
                ),
                items: provinciasToSelect
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.split('-')[0],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedProvincia,
                onChanged: (value) async {
                  setState(() {
                    selectedProvincia = value as String;
                  });
                  await getCiudades();
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: selectedCarrierType == "Externo" && !isCarrierExternal,
          child: SizedBox(
            width: screenWidth > 600 ? 350 : 250,
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Ciudad',
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.bold),
                ),
                items: citiesToSelect
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item.split('-')[0],
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
                value: selectedCity,
                onChanged: (value) async {
                  setState(() {
                    selectedCity = value as String;
                  });
                  // await getTransports();
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: selectedCarrierType == "Externo" && !isCarrierExternal,
          child: Row(
            children: [
              Checkbox(
                value: recaudo,
                onChanged: (value) {
                  //
                  setState(() {
                    recaudo = value!;
                  });
                  print(recaudo);
                },
                shape: CircleBorder(),
              ),
              Text("Con Recaudo"),
              Checkbox(
                value: !recaudo,
                onChanged: (value) {
                  //
                  setState(() {
                    recaudo = !value!;
                  });
                  print(recaudo);
                  if (!recaudo) {
                    setState(() {
                      // _precioTotal.text = "00";
                    });
                  }
                },
                shape: CircleBorder(),
              ),
              Text("Sin Recaudo"),
            ],
          ),
        ),
        Visibility(
          visible: selectedCarrierType == "Externo" && !isCarrierExternal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text("¿Autoriza la apertura del pedido?"),
              Row(
                children: [
                  Checkbox(
                    value: allowApertura,
                    onChanged: (value) {
                      //
                      setState(() {
                        allowApertura = value!;
                      });
                      print(recaudo);
                    },
                    shape: CircleBorder(),
                  ),
                  const Text("SI"),
                  const SizedBox(width: 20),
                  Checkbox(
                    value: !allowApertura,
                    onChanged: (value) {
                      //
                      setState(() {
                        allowApertura = !value!;
                      });
                      print(allowApertura);
                    },
                    shape: CircleBorder(),
                  ),
                  const Text("NO"),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Text(
              "Precio de venta:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                style: const TextStyle(fontWeight: FontWeight.bold),
                controller: _controllers.precioTotalEditController,
                decoration: const InputDecoration(
                  labelText: "Precio Total",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                enabled: !isCarrierExternal,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                ],
              ),
            ),
            const SizedBox(width: 20),
            /*
            ElevatedButton(
              onPressed: (isCarrierInternal && estadoLogistic == "PENDIENTE") ||
                      (!isCarrierExternal && !isCarrierInternal)
                  // (selectedCarrierType != null) &&
                  //         ((selectedCarrierType == "Externo" &&
                  //                 selectedProvincia != null &&
                  //                 selectedCity != null) ||
                  //             (selectedCarrierType == "Interno" &&
                  //                 selectedValueTransport != null))
                  ? () async {
                      priceTotalProduct = double.parse(
                          _controllers.precioTotalEditController.text);
                      var resTotalProfit;
                      if (selectedCarrierType == "Externo") {
                        resTotalProfit = await calculateProfitCarrierExternal();
                      } else {
                        resTotalProfit = await calculateProfit();
                      }

                      setState(() {
                        profit = double.parse(resTotalProfit.toString());
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.deepPurple,
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            */
            ElevatedButton(
              onPressed: (isCarrierExternal || isCarrierInternal) ||
                      ((selectedCarrierType == "Externo" &&
                              selectedProvincia != null &&
                              selectedCity != null) ||
                          (selectedCarrierType == "Interno" &&
                              selectedValueTransport != null))
                  ? () async {
                      priceTotalProduct = double.parse(
                          _controllers.precioTotalEditController.text);
                      var resTotalProfit;
                      if (selectedCarrierType == "Externo") {
                        if (!isCarrierExternal) {
                          idCarrierExternal =
                              selectedCarrierExternal.toString().split("-")[1];
                          idProvExternal =
                              selectedProvincia.toString().split("-")[1];
                          tipoCobertura = selectedCity.toString().split("-")[2];
                        } else if (isCarrierExternal) {
                          //
                          calculateTotalWPrice();

                          idCarrierExternal = data['pedido_carrier'][0]
                                  ['carrier_id']
                              .toString();
                          idProvExternal = data['pedido_carrier'][0]
                                  ['city_external']['id_provincia']
                              .toString();
                          String idCiudad = data['pedido_carrier'][0]
                                  ['city_external_id']
                              .toString();
                          var responseCities = await Connections().getCoverage([
                            {
                              "equals/carriers_external_simple.id":
                                  idCarrierExternal.toString()
                            },
                            {
                              "equals/coverage_external.dpa_provincia.id":
                                  idProvExternal.toString()
                            },
                            {"equals/id_coverage": idCiudad.toString()}
                          ]);
                          var dataTempCities = responseCities;

                          tipoCobertura = dataTempCities['type'];
                          print("tipoCobertura: $tipoCobertura");
                        }

                        resTotalProfit = await calculateProfitCarrierExternal();
                      } else {
                        resTotalProfit = await calculateProfit();
                      }

                      setState(() {
                        profit = double.parse(resTotalProfit.toString());
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text(
                "Calcular",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Text(
              "Detalle de venta",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              "Precio de venta: \$ ${priceTotalProduct.toString()}",
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              "Precio Bodega: \$ ${priceWarehouseTotal.toString()}",
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              "Costo Transporte: \$ ${costShippingSeller.toString()}",
            ),
          ],
        ),
        // const SizedBox(height: 5),
        // Row(
        //   children: [
        //     Text(
        //       "Iva 15%: \$ ${taxCostShipping.toString()}",
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 5),
        // Row(
        //   children: [
        //     Text(
        //       "Total Flete: \$ ${totalCost.toString()}",
        //     ),
        //   ],
        // ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              "Total a recibir: \$ ${profit.toString()}",
            ),
          ],
        ),
        const SizedBox(height: 20),
        Visibility(
          visible: (isCarrierInternal && estadoLogistic == "PENDIENTE") ||
              (!isCarrierExternal && !isCarrierInternal),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EEE8F4),
                  side: const BorderSide(color: Color(0xFF031749), width: 2),
                ),
                child: const Text(
                  "CANCELAR",
                  style: TextStyle(
                    color: Color(0xFF031749),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  bool readySent = false;
                  if (formKey.currentState!.validate()) {
                    if (selectedCarrierType == null) {
                      showSuccessModal(
                          context,
                          "Por favor, Debe seleccionar un tipo de transportadora.",
                          Icons8.alert);
                    } else {
                      if (selectedCarrierType == "Externo") {
                        //
                        if (selectedCarrierExternal == null ||
                            selectedProvincia == null ||
                            selectedCity == null) {
                          showSuccessModal(
                              context,
                              "Por favor, Debe seleccionar una transportadora, provincia y ciudad.",
                              Icons8.alert);
                        } else {
                          readySent = true;
                        }
                      } else {
                        //
                        if (selectedValueRoute == null ||
                            selectedValueTransport == null) {
                          showSuccessModal(
                              context,
                              "Por favor, Debe seleccionar una ciudad y una transportadora.",
                              Icons8.alert);
                        } else {
                          readySent = true;
                        }
                      }
                    }
                    //btnAceptar
                    //check stock
                    if (readySent) {
                      getLoadingModal(context, false);

                      String labelProducto = "";
                      /*
                      if (data['variant_details'] != null &&
                          data['variant_details'].toString() != "[]" &&
                          data['variant_details'].isNotEmpty) {
                        //
                        print("tiene variant_details");

                        if (data['id_product'] != null &&
                            data['id_product'] != 0) {
                          //
                          print("tiene id_product");

                          List<Map<String, dynamic>> groupedProducts =
                              groupProducts(variantsCurrentList);
                          // print("groupedProducts: $groupedProducts");

                          if (isvariableFirst == 1) {
                            print("is variable upt ");
                            // print("variantsCurrentList: $variantsCurrentList");

                            for (var product in groupedProducts) {
                              labelProducto += labelProducto +=
                                  '${product['name']} ${product['variants']}; \n';
                            }

                            labelProducto = labelProducto.substring(
                                0, labelProducto.length - 3);

                            getTotalQuantity();
                          } else {
                            print("NOT variable upt ");

                            variantsCurrentList[0]['quantity'] = int.parse(
                                _controllers.cantidadEditController.text);

                            // print("variantsCurrentList: $variantsCurrentList");
                            for (var variant in variantsCurrentList) {
                              labelProducto +=
                                  '${variant['quantity']}*${variant['title']}; \n';
                            }
                          }

                          await Connections().updatenueva(data['id'], {
                            "variant_details": variantsCurrentList,
                            "producto_p": labelProducto,
                            "cantidad_total": _controllers
                                .cantidadEditController.text
                                .toString(),
                          });
                        } else {
                          //
                          print("NO tiene id_product");
                          labelProducto =
                              _controllers.productoEditController.text;
                        }
                      } else {
                        //
                        labelProducto =
                            _controllers.productoEditController.text;

                        print("NO tiene variants_details");
                        await Connections().updatenueva(data['id'], {
                          "cantidad_total": _controllers
                              .cantidadEditController.text
                              .toString(),
                        });
                      }
                      */
                      if (data['id_product'] != null &&
                          data['id_product'] != 0 &&
                          data['variant_details'] != null &&
                          data['variant_details'].toString() != "[]" &&
                          data['variant_details'].isNotEmpty) {
                        //

                        //updt with local names
                        // renameProductVariantTitle();
                        // print(
                        //     "actual variantDetailsUniques: $variantDetailsUniques");

                        List<Map<String, dynamic>> groupedProducts =
                            groupProducts(variantDetailsUniques);
                        // print(
                        //     "groupedProducts: $groupedProducts");
                        //

                        for (var product in groupedProducts) {
                          labelProducto +=
                              '${product['name']} ${product['variants']}; \n';
                        }

                        labelProducto = labelProducto.substring(
                            0, labelProducto.length - 3);

                        await Connections().updatenueva(data['id'], {
                          "variant_details": variantDetailsUniques,
                          "producto_p": labelProducto,
                          "cantidad_total": _controllers
                              .cantidadEditController.text
                              .toString(),
                        });

                        //
                      } else {
                        print("NO tiene variants_details o productID es 0");
                        labelProducto =
                            _controllers.productoEditController.text;

                        await Connections().updatenueva(data['id'], {
                          "cantidad_total": _controllers
                              .cantidadEditController.text
                              .toString(),
                        });
                      }
                      // print("${_controllers.precioTotalEditController.text}");
                      await Connections().updatenueva(data['id'], {
                        "precio_total": _controllers
                            .precioTotalEditController.text
                            .toString(),
                      });
                      await updateData();
                      Navigator.pop(context);

                      if (data['id_product'] != null &&
                          data['id_product'] != 0 &&
                          data['variant_details'] != null &&
                          data['variant_details'].toString() != "[]" &&
                          data['variant_details'].isNotEmpty) {
                        getLoadingModal(context, false);

                        var responseCurrentStock = await Connections()
                            .getCurrentStock(
                                sharedPrefs!
                                    .getString("idComercialMasterSeller")
                                    .toString(),
                                variantDetailsUniques);

                        print("$responseCurrentStock");
                        bool $isAllAvailable = true;
                        String $textRes = "";
                        List<int> arrayAvailables = [];

                        if (responseCurrentStock != 1 ||
                            responseCurrentStock != 2) {
                          var listStock = responseCurrentStock;

                          for (String item in listStock) {
                            List<String> parts = item.split('|');
                            String code = parts[0];
                            int available = int.parse(parts[1]);
                            int currentStock = int.parse(parts[2]);
                            int request = int.parse(parts[3]);

                            arrayAvailables.add(available);
                            if (available != 1) {
                              // print("$available");
                              $isAllAvailable = false;
                              if (available == 0 || available == 2) {
                                $textRes +=
                                    "$code; Solicitado: ${request.toString()}; Disponible: ${currentStock.toString()}\n";
                              } else if (available == 3) {
                                $textRes +=
                                    "$code; Este producto no tiene este SKU.\n";
                              } else if (available == 4) {
                                $textRes +=
                                    "$code; Formato incorrecto del SKU.\n";
                              }
                            }
                          }
                          bool case34 = arrayAvailables
                              .any((num) => num == 3 || num == 4);
                          if (case34) {
                            $textRes +=
                                "\nValidar si los SKU ingresados en Shopify son correctos; en caso contrario, crear una nueva guía desde el Catálogo.";
                          }
                        }

                        // print("isAllAvailable: ${$isAllAvailable}");
                        Navigator.pop(context);

                        if (!$isAllAvailable) {
                          readySent = false;

                          // print("${$textRes}}");

                          // ignore: use_build_context_synchronously
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title: "No se puede procesar la solicitud",
                            // "No se puede procesar la solicitud: cantidad insuficiente, SKU incorrecto o SKU no corresponde al producto.",
                            desc: $textRes,
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: Colors.green,
                            btnOkOnPress: () async {},
                            btnCancelOnPress: () async {},
                          ).show();
                        } else {
                          readySent = true;
                        }
                      }
                    }

                    if (readySent) {
                      print("readySent after checkStock");

                      getLoadingModal(context, false);

                      String priceTotal =
                          "${_controllers.precioTotalEditController.text}";

                      String contenidoProd = "";
                      if (data['id_product'] != null &&
                          data['id_product'] != 0 &&
                          data['variant_details'] != null &&
                          data['variant_details'].toString() != "[]" &&
                          data['variant_details'].isNotEmpty) {
                        //
                        contenidoProd =
                            buildVariantsDetailsText(variantDetailsUniques);
                      } else {
                        //
                        contenidoProd +=
                            '${_controllers.cantidadEditController.text}*${_controllers.productoEditController.text}';
                      }
                      print("contenidoProd: $contenidoProd");

                      var responseNewRouteTransp;
                      var responseGintraNew;
                      var responseUpdtRT;
                      var responseGintraUpdt;

                      String remitente_address = "";

                      String remitente_prov_ref = "";
                      String remitente_city_ref = "";
                      String destinatario_prov_ref = "";
                      String destinatario_city_ref = "";
                      var dataIntegration;

                      bool readyDataSend = true;

                      if (selectedCarrierType == "Externo") {
                        bool emojiNombre = containsEmoji(
                            _controllers.nombreEditController.text);
                        bool emojiDireccion = containsEmoji(
                            _controllers.direccionEditController.text);
                        bool emojiContenidoProd = containsEmoji(contenidoProd);
                        bool emojiProductoe = containsEmoji(
                            _controllers.productoExtraEditController.text);
                        bool emojiObservacion = containsEmoji(
                            _controllers.observacionEditController.text);

                        if (emojiNombre ||
                            emojiDireccion ||
                            emojiContenidoProd ||
                            emojiProductoe ||
                            emojiObservacion) {
                          readyDataSend = false;
                        }

                        if (readyDataSend) {
                          remitente_address = prov_city_address.split('|')[2];

                          var responseProvCityRem =
                              await Connections().getCoverage([
                            {
                              "equals/carriers_external_simple.id":
                                  selectedCarrierExternal
                                      .toString()
                                      .split("-")[1]
                            },
                            {
                              "equals/coverage_external.dpa_provincia.id":
                                  prov_city_address.split('|')[0]
                            },
                            {
                              "equals/coverage_external.ciudad":
                                  prov_city_address.split('|')[1]
                            }
                          ]);

                          // print(responseProvCityRem);
                          remitente_prov_ref =
                              responseProvCityRem['id_prov_ref'];
                          remitente_city_ref =
                              responseProvCityRem['id_ciudad_ref'];
                          // print("REMITENTE:");
                          // print(
                          //     "$origen_prov: $remitente_city_ref-${responseProvCityRem['coverage_external']['dpa_provincia']['provincia']}");
                          // print(
                          //     "${widget.product.warehouse!.city.toString()}: $remitente_city_ref");

                          destinatario_prov_ref =
                              selectedCity.toString().split("-")[3];
                          destinatario_city_ref =
                              selectedCity.toString().split("-")[4];

                          // print("DESTINATARIO:");
                          // print(
                          //     "${selectedProvincia.toString().split("-")[0]}: $destinatario_prov_ref");
                          // print(
                          //     "${selectedCity.toString().split("-")[0]}: $destinatario_city_ref");

                          DateTime now = DateTime.now();
                          String formattedDateTime =
                              DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
                          // print(
                          //     "telefono_2: ${sharedPrefs!.getString("seller_telefono")}");
                          dataIntegration = {
                            "remitente": {
                              "nombre":
                                  "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
                              "telefono": "",
                              // "telefono": sharedPrefs!.getString("seller_telefono"),
                              "provincia": remitente_prov_ref,
                              "ciudad": remitente_city_ref,
                              "direccion": remitente_address
                            },
                            "destinatario": {
                              "nombre": _controllers.nombreEditController.text,
                              "telefono":
                                  _controllers.telefonoEditController.text,
                              "provincia": destinatario_prov_ref,
                              "ciudad": destinatario_city_ref,
                              "direccion":
                                  _controllers.direccionEditController.text
                            },
                            "cant_paquetes": "1",
                            "peso_total": "2.00",
                            "documento_venta": "",
                            "contenido":
                                "$contenidoProd${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}",
                            "observacion":
                                _controllers.observacionEditController.text,
                            "fecha": formattedDateTime,
                            "declarado": double.parse(priceTotal).toString(),
                            "con_recaudo": recaudo ? true : false,
                            "apertura": allowApertura ? true : false,
                          };
                          print(dataIntegration);
                        } else {
                          Navigator.pop(context);

                          // ignore: use_build_context_synchronously
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title:
                                "Error: revise los datos, no se permiten emojis.",
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: Colors.green,
                            btnOkOnPress: () async {},
                            btnCancelOnPress: () async {},
                          ).show();
                        }
                      }

                      double costDelivery =
                          double.parse(costShippingSeller.toString()) +
                              double.parse(taxCostShipping.toString());

                      // /*
                      if (data['transportadora'].isEmpty &&
                          data['pedido_carrier'].isEmpty) {
                        //
                        print("Nuevo no tiene ninguna Transport");
                        if (selectedCarrierType == "Interno") {
                          //

                          responseNewRouteTransp = await Connections()
                              .updateOrderRouteAndTransportLaravel(
                                  selectedValueRoute.toString().split("-")[1],
                                  selectedValueTransport
                                      .toString()
                                      .split("-")[1],
                                  data['id']);
                          var response2 = await Connections().updatenueva(
                              data['id'], {
                            "recaudo": 1,
                            "precio_total": priceTotal.toString()
                          });

                          var response3 = await Connections()
                              .updateOrderWithTime(
                                  data['id'],
                                  "estado_interno:CONFIRMADO",
                                  sharedPrefs!.getString("id"),
                                  "",
                                  "");
                          print(
                              "updated estado_interno:CONFIRMADO with others");

                          await updateData();
                          Navigator.pop(context);

                          var _url = Uri.parse(
                            """https://api.whatsapp.com/send?phone=${_controllers.telefonoEditController.text}&text=Hola ${_controllers.nombreEditController.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_controllers.productoEditController.text}${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_controllers.direccionEditController.text}. Es correcto...? ¿Quiere más información del producto?""",
                            // """https://api.whatsapp.com/send?phone=${_controllers.telefonoEditController.text}&text=Hola ${_controllers.nombreEditController.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_controllers.direccionEditController.text}. Es correcto...? ¿Quiere más información del producto?""",
                          );

                          if (!await launchUrl(_url)) {
                            throw Exception('Could not launch $_url');
                          }
                        } else {
                          //

                          print("a Una Externa");
                          // /*
                          if (selectedCarrierExternal
                                  .toString()
                                  .split("-")[1] ==
                              "1") {
                            //send Gintra
                            print("send Gintra");

                            var responseOrderCarrierExt = await Connections()
                                .getOrderCarrierExternal(data['id']);

                            if (responseOrderCarrierExt == 1) {
                              if (dataIntegration != null) {
                                print("enviar a gtm y crear un ordercarrier");

                                responseGintraNew = await Connections()
                                    .postOrdersGintra(dataIntegration);
                                // // print("responseInteg");
                                // print(responseGintraNew);

                                if (responseGintraNew != []) {
                                  bool statusError = responseGintraNew['error'];

                                  if (statusError) {
                                    Navigator.pop(context);

                                    // ignore: use_build_context_synchronously
                                    AwesomeDialog(
                                      width: 500,
                                      context: context,
                                      dialogType: DialogType.info,
                                      animType: AnimType.rightSlide,
                                      title:
                                          "Error en la asignación de la transportadora externa.",
                                      btnCancel: Container(),
                                      btnOkText: "Aceptar",
                                      btnOkColor: Colors.green,
                                      btnOkOnPress: () async {},
                                      btnCancelOnPress: () async {},
                                    ).show();
                                  } else {
                                    await Connections()
                                        .updatenueva(data['id'], {
                                      "id_externo": responseGintraNew['guia'],
                                      "recaudo": recaudo ? 1 : 0,
                                      "apertura": allowApertura ? 1 : 0,
                                      "precio_total": priceTotal.toString()
                                    });

                                    //crear un nuevo pedido_carrier_link
                                    await Connections()
                                        .createUpdateOrderCarrier(
                                            data['id'],
                                            selectedCarrierExternal
                                                .toString()
                                                .split("-")[1],
                                            selectedCity
                                                .toString()
                                                .split("-")[1],
                                            responseGintraNew['guia']);

                                    print("created UpdateOrderCarrier");

                                    var response3 = await Connections()
                                        .updateOrderWithTime(
                                            data['id'],
                                            "estado_interno:CONFIRMADO",
                                            sharedPrefs!.getString("id"),
                                            "",
                                            "");
                                    print(
                                        "updated estado_interno:CONFIRMADO with others");

                                    await updateData();
                                    Navigator.pop(context);

                                    var _url = Uri.parse(
                                      """https://api.whatsapp.com/send?phone=${_controllers.telefonoEditController.text}&text=Hola ${_controllers.nombreEditController.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_controllers.productoEditController.text}${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_controllers.direccionEditController.text}. Es correcto...? ¿Quiere más información del producto?""",
                                      // """https://api.whatsapp.com/send?phone=${_controllers.telefonoEditController.text}&text=Hola ${_controllers.nombreEditController.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_controllers.direccionEditController.text}. Es correcto...? ¿Quiere más información del producto?""",
                                    );

                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }
                                  }
                                }
                              }
                            } else if (responseOrderCarrierExt == 0) {
                              //
                              await updateData();
                              Navigator.pop(context);

                              // ignore: use_build_context_synchronously
                              showSuccessModal(
                                  context,
                                  "Error, Este pedido ya tiene una Transportadora Externa.",
                                  Icons8.alert);
                            }
                          }
                          // */
                          //
                        }
                      } else {
                        print("Actualizar");
                        if (data['transportadora'].isNotEmpty) {
                          print("Actualizar Transport");
                          //

                          if (selectedCarrierType == "Interno") {
                            //
                            print("a otro Transport");

                            responseUpdtRT = await Connections()
                                .updateOrderRouteAndTransportLaravel(
                                    selectedValueRoute.toString().split("-")[1],
                                    selectedValueTransport
                                        .toString()
                                        .split("-")[1],
                                    data['id']);
                            var response2 = await Connections().updatenueva(
                                data['id'], {
                              "recaudo": 1,
                              "precio_total": priceTotal.toString()
                            });

                            var response3 = await Connections()
                                .updateOrderWithTime(
                                    data['id'],
                                    "estado_interno:CONFIRMADO",
                                    sharedPrefs!.getString("id"),
                                    "",
                                    "");
                            print(
                                "updated estado_interno:CONFIRMADO with others");

                            await updateData();
                            Navigator.pop(context);

                            var _url = Uri.parse(
                              """https://api.whatsapp.com/send?phone=${_controllers.telefonoEditController.text}&text=Hola ${_controllers.nombreEditController.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_controllers.productoEditController.text}${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_controllers.direccionEditController.text}. Es correcto...? ¿Quiere más información del producto?""",
                              // """https://api.whatsapp.com/send?phone=${_controllers.telefonoEditController.text}&text=Hola ${_controllers.nombreEditController.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_controllers.direccionEditController.text}. Es correcto...? ¿Quiere más información del producto?""",
                            );

                            if (!await launchUrl(_url)) {
                              throw Exception('Could not launch $_url');
                            }
                          } else {
                            //
                            print("a un Externo");

                            // /*
                            if (selectedCarrierExternal
                                    .toString()
                                    .split("-")[1] ==
                                "1") {
                              //send Gintra
                              print("send Gintra");

                              var responseOrderCarrierExt = await Connections()
                                  .getOrderCarrierExternal(data['id']);

                              if (responseOrderCarrierExt == 1) {
                                if (dataIntegration != null) {
                                  print("enviar a gtm y crear un ordercarrier");

                                  responseGintraNew = await Connections()
                                      .postOrdersGintra(dataIntegration);

                                  if (responseGintraNew != []) {
                                    bool statusError =
                                        responseGintraNew['error'];

                                    if (statusError) {
                                      Navigator.pop(context);

                                      // ignore: use_build_context_synchronously
                                      AwesomeDialog(
                                        width: 500,
                                        context: context,
                                        dialogType: DialogType.info,
                                        animType: AnimType.rightSlide,
                                        title:
                                            "Error en la asignación de la transportadora externa.",
                                        btnCancel: Container(),
                                        btnOkText: "Aceptar",
                                        btnOkColor: Colors.green,
                                        btnOkOnPress: () async {},
                                        btnCancelOnPress: () async {},
                                      ).show();
                                    } else {
                                      await Connections()
                                          .updatenueva(data['id'], {
                                        "id_externo": responseGintraNew['guia'],
                                        "recaudo": recaudo ? 1 : 0,
                                        "apertura": allowApertura ? 1 : 0,
                                        "precio_total": priceTotal.toString()
                                      });

                                      //crear un nuevo pedido_carrier_link
                                      await Connections()
                                          .createUpdateOrderCarrier(
                                              data['id'],
                                              selectedCarrierExternal
                                                  .toString()
                                                  .split("-")[1],
                                              selectedCity
                                                  .toString()
                                                  .split("-")[1],
                                              responseGintraNew['guia']);

                                      print("created UpdateOrderCarrier");

                                      var response3 = await Connections()
                                          .updateOrderWithTime(
                                              data['id'],
                                              "estado_interno:CONFIRMADO",
                                              sharedPrefs!.getString("id"),
                                              "",
                                              "");
                                      print(
                                          "updated estado_interno:CONFIRMADO with others");

                                      await Connections()
                                          .deleteRutaTransportadora(data['id']);

                                      await updateData();
                                      Navigator.pop(context);

                                      var _url = Uri.parse(
                                        """https://api.whatsapp.com/send?phone=${_controllers.telefonoEditController.text}&text=Hola ${_controllers.nombreEditController.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_controllers.productoEditController.text}${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_controllers.direccionEditController.text}. Es correcto...? ¿Quiere más información del producto?""",
                                        // """https://api.whatsapp.com/send?phone=${_controllers.telefonoEditController.text}&text=Hola ${_controllers.nombreEditController.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_controllers.direccionEditController.text}. Es correcto...? ¿Quiere más información del producto?""",
                                      );

                                      if (!await launchUrl(_url)) {
                                        throw Exception(
                                            'Could not launch $_url');
                                      }
                                    }
                                  }
                                }
                              } else if (responseOrderCarrierExt == 0) {
                                //
                                await updateData();
                                Navigator.pop(context);
                                // ignore: use_build_context_synchronously
                                showSuccessModal(
                                    context,
                                    "Error, Este pedido ya tiene una Transportadora Externa.",
                                    Icons8.alert);
                              }
                            }
                            // */
                            //
                          }
                          //
                        } else if (data['pedido_carrier'].isNotEmpty) {
                          //

                          print("Actualizar carrier_external");
                          print("Not yet");
                          Navigator.pop(context);
                          /*
                          if (selectedCarrierType == "Interno") {
                            //
                            print("a Transport Interna");
                            //este caso faltaria notificar a gtm que ya no quiere
                            responseUpdtRT = await Connections()
                                .updateOrderRouteAndTransportLaravel(
                                    selectedValueRoute.toString().split("-")[1],
                                    selectedValueTransport
                                        .toString()
                                        .split("-")[1],
                                    data['id']);

                            var response2 = await Connections().updatenueva(
                                data['id'], {
                              "recaudo": 1,
                              "precio_total": priceTotal.toString()
                            });

                            //eliminar relacion pedido_Carrier_link
                            await Connections()
                                .deleteOrderCarrierExternal(data['id']);

                            var response3 = await Connections()
                                .updateOrderWithTime(
                                    data['id'],
                                    "estado_interno:CONFIRMADO",
                                    sharedPrefs!.getString("id"),
                                    "",
                                    "");
                            print(
                                "updated estado_interno:CONFIRMADO with others");

                            await updateData();
                            Navigator.pop(context);
                          } else {
                            //
                            print("a externa");
                            print("Not yet");
                            Navigator.pop(context);

                            // print(dataIntegration);
                            /*
                          if (data['carrier_external']['id'].toString() !=
                              selectedCarrierExternal
                                  .toString()
                                  .split("-")[1]) {
                            //!! updt de la ciudad no se puede porque no hay endpoint para actualizar algo asi

                          if (selectedCarrierExternal
                                  .toString()
                                  .split("-")[1] ==
                              "1") {
                            //send Gintra
                            print("send Gintra");

                            responseGintraUpdt = await Connections()
                                .postOrdersGintra(dataIntegration);
                            // // print("responseInteg");
                            // // print(responseGintra);

                            if (responseGintraUpdt != []) {
                              await Connections().updatenueva(data['id'], {
                                "id_externo": responseGintraUpdt['guia'],
                                "carrier_external_id": selectedCarrierExternal
                                    .toString()
                                    .split("-")[1],
                                "ciudad_external_id":
                                    selectedCity.toString().split("-")[0],
                                "recaudo": recaudo ? 1 : 0,
                                "costo_envio": costDelivery.toString()
                              });
                            }
                          }

                          }
                          */
                          }
                          */
                        }

                        //
                      }
                      // */
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Color(0xFF031749),
                  ),
                ),
                child: const Text(
                  "ACEPTAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String formatLabelProducto(List<dynamic> variantsList) {
    Map<String, List<String>> products = {};

    for (var variant in variantsList) {
      String title = variant['title'];
      int quantity = variant['quantity'];
      String? variantTitle = variant['variant_title'];

      if (!products.containsKey(title)) {
        products[title] = [];
      }

      if (variantTitle != null && variantTitle.isNotEmpty) {
        products[title]!.add('$quantity*$variantTitle');
      } else {
        products[title]!.add('$quantity');
      }
    }

    List<String> productStrings = [];
    products.forEach((title, variants) {
      productStrings.add('$title ${variants.join("|")}');
    });

    return productStrings.join(' ; ');
  }

  List<Map<String, dynamic>> groupProducts(List<dynamic> variantsList) {
    Map<String, Map<String, dynamic>> groupedProducts = {};

    // Recorre cada variante en la lista
    for (var variant in variantsList) {
      String? sku = variant['sku'];
      String title = variant['title'];
      String name = variant['name'].toString();
      int quantity = variant['quantity'];
      String? variantTitle = variant['variant_title'];

      // Generar una clave única para productos sin SKU
      String uniqueKey = sku ?? name;

      if (sku != null) {
        // Verificar si el SKU contiene 'C'
        if (sku.contains('C')) {
          // Divide el SKU por la última 'C'
          int lastCIndex = sku.lastIndexOf('C');
          String skuRest = sku.substring(lastCIndex + 1); // "1638"
          uniqueKey = skuRest;
        } else {
          uniqueKey = sku;
        }
      }

      // Si la clave única no está en el mapa, se añade
      if (!groupedProducts.containsKey(uniqueKey)) {
        groupedProducts[uniqueKey] = {
          'id': uniqueKey, // Usar uniqueKey como id
          'name': title,
          'variants': []
        };
      }

      // Añade la variante al producto en el formato adecuado solo si variantTitle no es nulo
      if (variantTitle != null && variantTitle.isNotEmpty) {
        groupedProducts[uniqueKey]!['variants']!
            .add('($quantity*$variantTitle)');
      } else {
        groupedProducts[uniqueKey]!['variants']!.add('($quantity)');
      }
    }

    // Convierte el mapa a una lista de productos con el formato deseado
    List<Map<String, dynamic>> productList = [];
    groupedProducts.forEach((skuKey, product) {
      productList.add({
        'id': product['id'],
        'name': product['name'],
        'variants': product['variants'].join(' / ')
      });
    });

    return productList;
  }

  String buildVariantsDetailsText(
      List<Map<String, dynamic>> dataVariantDetailsUniques) {
    List<String> variantTexts = [];

    for (var variant in dataVariantDetailsUniques) {
      int quantity = variant['quantity'] ?? 0;
      String title = variant['title'] ?? '';
      String variantTitle = variant['variant_title'] ?? '';

      String variantText = '${quantity.toString()}*$title';
      if (variantTitle.isNotEmpty) {
        variantText += ' $variantTitle';
      }
      variantTexts.add(variantText);
    }

    String result = variantTexts.join('|');
    return result;
  }

  String buscarTipoPorId(List<dynamic> dataTempCities, String id) {
    try {
      print(dataTempCities);
      var ciudad =
          dataTempCities.firstWhere((item) => item['id_coverage'] == id);
      return ciudad['type'];
    } catch (e) {
      return 'No encontrado';
    }
  }

  void renameProductVariantTitle() {
    print("renameProductVariantTitle");
    RegExp pattern = RegExp(r'^[a-zA-Z0-9]+C\d+$');
    // print("variantDetailsOriginal: $variantDetailsUniques");
    for (var variant in variantDetailsUniques) {
      String? skuVariant = variant['sku'];

      if (skuVariant != null &&
          skuVariant != "" &&
          pattern.hasMatch(skuVariant)) {
        //
        int indexOfC = skuVariant.lastIndexOf('C');
        String onlySku = skuVariant.substring(0, indexOfC);
        String onlyId = skuVariant.substring(indexOfC + 1);

        for (var productData in variantsListProducts) {
          String idProd = productData['product_id'].toString();

          if (onlyId == idProd) {
            String productName = productData['product_name'];
            String variable = productData['isvariable'].toString();
            String price = productData['price'].toString();

            variant['title'] = productName;
            variant['price'] = price;

            var features = jsonDecode(productData["features"]);
            if (variable == "0") {
              if (onlySku == features["sku"].toString()) {
                variant['variant_title'] = null;
              }
            } else {
              var featuresVariants = features["variants"];
              // print("featuresVariants: $featuresVariants");
              for (var element in featuresVariants) {
                if (onlySku == element["sku"].toString()) {
                  String nameVariantTitle = buildVariantTitle(element);
                  variant['variant_title'] = nameVariantTitle;
                }
              }
            }
            break;
          }
        }
      }
    }
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                "$text: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: text,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusColor: Colors.black,
                    iconColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Future<double> calculateProfitCarrierExternal() async {
    String origen_prov = prov_city_address.split('|')[0].toString();

    var costs =
        getCostsByIdCarrier(selectedCarrierExternal.toString().split("-")[1]);
    // print(costs);

    String tipoCobertura = selectedCity.toString().split("-")[2];
    double deliveryPrice = 0;
    if (selectedProvincia.toString().split("-")[1] == origen_prov) {
      print("Provincial");
      // print("${selectedCity.toString()}");
      if (tipoCobertura == "Normal") {
        deliveryPrice = double.parse(costs["normal1"].toString());
        // print("normal1: $deliveryPrice");
      } else {
        deliveryPrice = double.parse(costs["especial1"].toString());
        // print("especial1: $deliveryPrice");
      }
    } else {
      print("Nacional");
      // print("${selectedCity.toString()}");
      if (tipoCobertura == "Normal") {
        deliveryPrice = double.parse(costs["normal2"].toString());
        // print("normal2: $deliveryPrice");
      } else {
        deliveryPrice = double.parse(costs["especial2"].toString());
        // print("especial2: $deliveryPrice");
      }
    }
    deliveryPrice = deliveryPrice + (deliveryPrice * iva);
    deliveryPrice = (deliveryPrice * 100).roundToDouble() / 100;
    // print("after type + iva: $deliveryPrice");

    double costoSeguro =
        (priceTotalProduct * (double.parse(costs["costo_seguro"]))) / 100;
    costoSeguro = (costoSeguro * 100).roundToDouble() / 100;
    costoSeguro = costoSeguro + (costoSeguro * iva);
    costoSeguro = (costoSeguro * 100).roundToDouble() / 100;
    // print("costo_seguro: $costoSeguro");

    deliveryPrice += costoSeguro;
    deliveryPrice = (deliveryPrice * 100).roundToDouble() / 100;
    // print("after costo_seguro: $deliveryPrice");

    var costo_rec = (costs["costo_recaudo"]);
    double costo_recaudo = 0;
    if (recaudo) {
      // print("recaudo?? YES");
      // print("priceTotalProduct: $priceTotalProduct");

      if (priceTotalProduct <= double.parse(costo_rec['max_price'])) {
        double base = double.parse(costo_rec['base']);
        base = base + (base * iva);
        base = (base * 100).roundToDouble() / 100;
        costo_recaudo = base;
        // print("costo_recaudo base: $costo_recaudo");
      } else {
        double incremental =
            (priceTotalProduct * double.parse(costo_rec['incremental'])) / 100;
        incremental = (incremental * 100).roundToDouble() / 100;
        incremental = incremental + (incremental * iva);
        incremental = (incremental * 100).roundToDouble() / 100;
        costo_recaudo = incremental;
        // print("costo_recaudo incremental: $costo_recaudo");
      }
    }

    deliveryPrice += costo_recaudo;

    deliveryPrice = (deliveryPrice * 100).roundToDouble() / 100;
    // print("after costo_recaudo: $deliveryPrice");

    deliveryPrice = costEasy + deliveryPrice;
    // double deliveryPriceTax = deliveryPrice * iva;
    // deliveryPriceTax = (deliveryPriceTax * 100).roundToDouble() / 100;

    // print("costo deliveryPriceSeller: ${deliveryPrice + deliveryPriceTax}");
    // totalCost = deliveryPrice + deliveryPriceTax;
    deliveryPrice = (deliveryPrice * 100).roundToDouble() / 100;
    totalCost = deliveryPrice;

    //
    setState(() {
      costShippingSeller = deliveryPrice;
      // taxCostShipping = deliveryPriceTax;
      totalCost = totalCost;
    });
    // double totalProfit = priceTotalProduct -
    // (priceWarehouseTotal + deliveryPrice + deliveryPriceTax);
    double totalProfit =
        priceTotalProduct - (priceWarehouseTotal + deliveryPrice);

    totalProfit = (totalProfit * 100).roundToDouble() / 100;

    return totalProfit;
  }

  Map<String, dynamic> getCostsByIdCarrier(String id) {
    Map<String, dynamic> costsRes = {};

    for (var carrier in responseCarriersGeneral) {
      if ((carrier['id'].toString()) == id) {
        costsRes = jsonDecode(carrier['costs']);
        return costsRes;
      }
    }

    return {};
  }

  Future<double> calculateProfit() async {
    costShippingSeller =
        double.parse(sharedPrefs!.getString("seller_costo_envio").toString());
    // double deliveryPriceTax = costShippingSeller * iva;
    // deliveryPriceTax = (deliveryPriceTax * 100).roundToDouble() / 100;
    // totalCost = costShippingSeller + deliveryPriceTax;
    totalCost = costShippingSeller;
    setState(() {
      costShippingSeller = costShippingSeller;
      // taxCostShipping = deliveryPriceTax;
      totalCost = (totalCost * 100).roundToDouble() / 100;
    });

    double totalProfit = priceTotalProduct - (priceWarehouseTotal + totalCost);

    totalProfit = (totalProfit * 100).roundToDouble() / 100;

    return totalProfit;
  }

  int getQuantityBySku(String sku) {
    var variantToUpdate = variantsCurrentList.firstWhere(
      (variant) => variant['sku'] == sku,
      orElse: () => null,
    );

    if (variantToUpdate != null) {
      return variantToUpdate['quantity']; // No es necesario parsear a int
    } else {
      print('No se encontró ningún elemento con el SKU $sku en la lista.');
      return 0;
    }
  }

  int getTotalQuantityBySku(List<dynamic> variants, String sku) {
    int totalQuantity = 0;

    for (var variant in variants) {
      if (variant['sku'] == sku) {
        totalQuantity = variant['quantity'];
      }
    }

    return totalQuantity;
  }

  void updateQuantityBySku(
      List variants, String chosenProduct, int newQuantity) {
    // var variantToUpdate = variantsCurrentList
    String sku = chosenProduct.split('|')[0];
    String productName = chosenProduct.split('|')[2];
    String variantTitle = chosenProduct.split('|')[1];
    String prodType = chosenProduct.split('|')[3];

    for (var variant in variants) {
      if (variant['sku'] == sku) {
        variant['quantity'] = newQuantity;
        //
        /*
        if (prodType == "0") {
          variant['title'] = productName;
          variant['variant_title'] = null;
        } else {
          variant['title'] = productName;
          variant['variant_title'] = variantTitle;
        }
        */
      } else {
        print('No se encontró ningún elemento con el SKU $sku en la lista.');
      }
    }

    getTotalQuantityVariantsUniques();
    calculateTotalWPrice();
  }

  void getTotalQuantity() {
    int total_quantity = 0;
    for (Map<String, dynamic> variant in variantsCurrentList) {
      total_quantity += int.parse(variant['quantity'].toString());
    }
    setState(() {
      _controllers.cantidadEditController.text = total_quantity.toString();
    });
  }

  void getTotalQuantityVariantsUniques() {
    int total_quantity = 0;
    for (Map<String, dynamic> variant in variantDetailsUniques) {
      total_quantity += int.parse(variant['quantity'].toString());
    }
    setState(() {
      _controllers.cantidadEditController.text = total_quantity.toString();
    });
  }

  Map<String, dynamic>? findVariantBySku(String sku) {
    Map<String, dynamic>? varianteEncontrada;
    for (var variante in variantsFirstProduct) {
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
    List<String> availableKeys = variantFound?.keys
            .where((key) =>
                !['id', 'sku', 'inventory_quantity', 'price'].contains(key))
            .toList() ??
        [];

    String variantTitle =
        availableKeys.map((key) => variantFound?[key]).join('/');

    double priceT = (int.parse(quantity.toString()) *
        double.parse(productFirstPrice.toString()));

    int idGen = int.parse(generateCombination());

    Map<String, dynamic> variant = {
      "id": idGen,
      "name": productFirstId,
      "quantity": int.parse(_quantitySelectVariant.text),
      "price": priceT,
      "title": productFirstName,
      "variant_title": isvariableFirst == 1 ? variantTitle : null,
      "sku": "${variantFound?['sku']}C$productFirstId",
    };

    return variant;
  }

  String generateCombination() {
    const fixedNumber = 1301;
    final random = Random();
    final randomNumber = random.nextInt(900000000) + 100000000;
    return '$fixedNumber$randomNumber';
  }

  void updateQuantity(
      List<Map<String, dynamic>> variantsList, int id, int newQuantity) {
    for (int i = 0; i < variantsList.length; i++) {
      if (variantsList[i]['id'] == id) {
        variantsList[i]['quantity'] = newQuantity;
        break;
      }
    }
  }

  void calculateTotalWPrice() async {
    double totalPriceWarehouse = 0;
    RegExp pattern = RegExp(r'^[a-zA-Z0-9]+C\d+$');

    for (var detalle in variantDetailsUniques) {
      // print("variantDetailsOriginal: $variantDetailsUniques");
      String? skuVariant = detalle['sku'];

      if (skuVariant != null &&
          skuVariant != "" &&
          pattern.hasMatch(skuVariant)) {
        if (detalle.containsKey('price')) {
          double price = int.parse(detalle['quantity'].toString()) *
              double.parse(detalle['price'].toString());
          totalPriceWarehouse += price;
        }
      }
    }

    totalPriceWarehouse = double.parse(totalPriceWarehouse.toStringAsFixed(2));
    setState(() {
      priceWarehouseTotal = totalPriceWarehouse;
    });
  }
}
