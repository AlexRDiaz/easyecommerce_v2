import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmCarrier extends StatefulWidget {
  final Map order;

  const ConfirmCarrier({
    super.key,
    required this.order,
  });

  @override
  State<ConfirmCarrier> createState() => _ConfirmCarrierState();
}

class _ConfirmCarrierState extends State<ConfirmCarrier> {
  // TextEditingController _codigo = TextEditingController();
  TextEditingController _nombre = TextEditingController();
  TextEditingController _direccion = TextEditingController();
  // TextEditingController _ciudad = TextEditingController();
  TextEditingController _telefono = TextEditingController();
  TextEditingController _producto = TextEditingController();
  TextEditingController _cantidad = TextEditingController();
  TextEditingController _productoE = TextEditingController();
  TextEditingController _precioTotal = TextEditingController();
  TextEditingController _observacion = TextEditingController();
  String quantity_variant = "";
  int isvariable = 0;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? comercial = sharedPrefs!.getString("NameComercialSeller");

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
  TextEditingController _costoEnvioExt = TextEditingController();
  TextEditingController _totalRecibirExt = TextEditingController();
  String? origen_prov;
  String? origen_city;

  double priceTotalProduct = 0;
  double taxCostShipping = 0;
  double costEasy = 2.3;
  String prov_city_address = "";
  var responseCarriersGeneral;

  var data = {};
  int idUser = int.parse(sharedPrefs!.getString("id").toString());
  int idMaster =
      int.parse(sharedPrefs!.getString("idComercialMasterSeller").toString());

  List<Map<String, dynamic>> variantDetails = [];
  double iva = 0.15;

  double totalCost = 0;
  bool isCarrierExternal = false;
  bool isCarrierInternal = false;

  String estadoLogistic = "";
  String idCarrierExternal = "";
  String idProvExternal = "";
  String tipoCobertura = "";

  bool editProductP = true;
  List variantsListProducts = [];
  List<int> idProdUniques = [];
  List<Map<String, dynamic>> variantDetailsUniques = [];
  bool allowApertura = true;

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
    _nombre.text = data['nombre_shipping'].toString();
    _direccion.text = data['direccion_shipping'].toString();
    _telefono.text = data['telefono_shipping'].toString();
    _producto.text = data['producto_p'].toString();
    _cantidad.text = data['cantidad_total'].toString();
    estadoLogistic = data['estado_logistico'].toString();

    _productoE.text =
        data['producto_extra'] != null && data['producto_extra'] != "null"
            ? data['producto_extra'].toString()
            : "";
    _precioTotal.text = data['precio_total'].toString();
    _observacion.text =
        (data['observacion'] != null && data['observacion'] != "null")
            ? data['observacion'].toString()
            : "";

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
      carriersTypeToSelect = ["Interno", "Externo"];

      prov_city_address = getWarehouseAddress(data['product']['warehouses']);

      editProductP = false;
      print("editProductP :$editProductP");

      List<dynamic> variantDetails = jsonDecode(data['variant_details']);
      variantDetailsUniques = mergeDuplicateSKUs(variantDetails);

      idProdUniques =
          await extractUniqueIds(jsonDecode(data['variant_details']));

      var responseProducts =
          await Connections().getProductsByIds(idProdUniques, []);
      variantsListProducts = responseProducts;

      recaudo = true;
      getTotalQuantityVariantsUniques();
    } else {
      print("no id_p or var_det !!");
      carriersTypeToSelect = ["Interno"];
    }
/*
    if (data['id_product'] != null &&
        data['id_product'] != 0 &&
        data['variant_details'] != null) {
      //
      variantDetails = jsonDecode(variants).cast<Map<String, dynamic>>();
      for (var detail in variantDetails) {
        quantity_variant +=
            '${detail['quantity']}*${detail['variant_title']} | ';
      }

      // quantity_variant = quantity_variant.trim();
      quantity_variant =
          quantity_variant.substring(0, quantity_variant.length - 3);
    }
    if (data['id_product'] != null && data['id_product'] != 0) {
      isvariable = data['product']['isvariable'];
      priceWarehouseTotal = double.parse(data['product']['price'].toString());

      prov_city_address = getWarehouseAddress(data['product']['warehouses']);

      print("p_c_dir: $prov_city_address");
      print("var: $isvariable");
    }

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
    recaudo = data['recaudo'].toString() == "1" ? true : false;
*/
    setState(() {});
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

  void getTotalQuantityVariantsUniques() {
    int total_quantity = 0;
    for (Map<String, dynamic> variant in variantDetailsUniques) {
      total_quantity += int.parse(variant['quantity'].toString());
    }
    setState(() {
      _cantidad.text = total_quantity.toString();
    });
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
              "/carriers_external_simple.id":
                  selectedCarrierExternal.toString().split("-")[1]
            },
            {
              "/coverage_external.dpa_provincia.id":
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
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {});
    } catch (error) {
      print('Error al cargar Ciudades: $error');
    }
  }

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: 450,
      height: screenHeight * 0.9,
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Código: ${sharedPrefs!.getString("NameComercialSeller").toString()}-${data['numero_orden'].toString()}",
              ),
              const SizedBox(height: 5),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ))
                          .toList(),
                      value: selectedValueRoute,
                      onChanged: (value) async {
                        setState(() {
                          selectedValueRoute = value as String;
                          print(selectedValueRoute);
                          transports.clear();
                          selectedValueTransport = null;
                        });
                        await getTransports();
                      },
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
                                print(selectedValueTransport);
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
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
                            _precioTotal.text = "00";
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
                  children: [
                    const Text("¿Autoriza la apertura del pedido?"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                    width: screenWidth > 600 ? 180 : 150,
                    child: TextField(
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      controller: _precioTotal,
                      decoration: const InputDecoration(
                        labelText: "Precio Total",
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      enabled: !isCarrierExternal,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}$')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: (isCarrierExternal || isCarrierInternal) ||
                            ((selectedCarrierType == "Externo" &&
                                    selectedProvincia != null &&
                                    selectedCity != null) ||
                                (selectedCarrierType == "Interno" &&
                                    selectedValueTransport != null))
                        ? () async {
                            priceTotalProduct = double.parse(_precioTotal.text);
                            var resTotalProfit;

                            if (selectedCarrierType == "Externo") {
                              if (!isCarrierExternal) {
                                idCarrierExternal = selectedCarrierExternal
                                    .toString()
                                    .split("-")[1];
                                idProvExternal =
                                    selectedProvincia.toString().split("-")[1];
                                tipoCobertura =
                                    selectedCity.toString().split("-")[2];
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
                                var responseCities =
                                    await Connections().getCoverage([
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

                              resTotalProfit =
                                  await calculateProfitCarrierExternal();
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
                      // shape: const CircleBorder(),
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
                  const Text(
                    "Precio de venta:",
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    // width: 200,
                    width: screenWidth > 600 ? 200 : 150,
                    child: Text(
                      "\$ ${priceTotalProduct.toString()}",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    "Precio Bodega:",
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    // width: 200,
                    width: screenWidth > 600 ? 200 : 150,
                    child: Text(
                      "\$ ${priceWarehouseTotal.toString()}",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    "Costo Transporte:",
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    // width: 200,
                    width: screenWidth > 600 ? 200 : 150,
                    child: Text(
                      '\$ ${costShippingSeller.toString()}',
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 5),
              // Row(
              //   children: [
              //     const Text(
              //       "Iva 15%:",
              //     ),
              //     const SizedBox(width: 10),
              //     SizedBox(
              //       // width: 200,
              //       width: screenWidth > 600 ? 200 : 150,
              //       child: Text(
              //         '\$ ${taxCostShipping.toString()}',
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    "Total a recibir:",
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    // width: 200,
                    width: screenWidth > 600 ? 200 : 150,
                    child: Text(
                      "\$ ${profit.toString()}",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: (isCarrierInternal && estadoLogistic == "PENDIENTE") ||
                    (!isCarrierExternal && !isCarrierInternal),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EEE8F4),
                        // backgroundColor: Colors.transparent,
                        side: const BorderSide(
                            color: Color(0xFF031749),
                            width: 2), // Borde del botón
                      ),
                      child: const Text(
                        "CANCELAR",
                        style: TextStyle(
                          color: Color(0xFF031749), // Color del texto
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            bool readySent = false;
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

                            //rename
                            String labelProducto = "";

                            if (data['id_product'] != null &&
                                data['id_product'] != 0 &&
                                data['variant_details'] != null &&
                                data['variant_details'].toString() != "[]" &&
                                data['variant_details'].isNotEmpty) {
                              //

                              List<Map<String, dynamic>> groupedProducts =
                                  groupProducts(variantDetailsUniques);

                              for (var product in groupedProducts) {
                                labelProducto +=
                                    '${product['name']} ${product['variants']}; \n';
                              }

                              labelProducto = labelProducto.substring(
                                  0, labelProducto.length - 3);

                              await Connections().updatenueva(data['id'], {
                                "variant_details": variantDetailsUniques,
                                "producto_p": labelProducto,
                                "cantidad_total": _cantidad.text.toString(),
                              });

                              //
                            } else {
                              print(
                                  "NO tiene variants_details o productID es 0");
                              labelProducto = _producto.text;

                              await Connections().updatenueva(data['id'], {
                                "cantidad_total": _cantidad.text.toString(),
                              });
                            }

                            //check stock

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

                              // print("$responseCurrentStock");
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
                                  title:
                                      "No existe la cantidad requerida del/los producto(s).",
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

                            if (readySent) {
                              print("readySent after checkStock");

                              getLoadingModal(context, false);

                              String priceTotal = "${_precioTotal.text}";

                              String contenidoProd = "";
                              if (data['id_product'] != null &&
                                  data['id_product'] != 0 &&
                                  data['variant_details'] != null &&
                                  data['variant_details'].toString() != "[]" &&
                                  data['variant_details'].isNotEmpty) {
                                //
                                contenidoProd = buildVariantsDetailsText(
                                    variantDetailsUniques);
                              } else {
                                //
                                contenidoProd +=
                                    '${_cantidad.text}*${_producto.text}';
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
                                bool emojiNombre = containsEmoji(_nombre.text);
                                bool emojiDireccion =
                                    containsEmoji(_direccion.text);
                                bool emojiContenidoProd =
                                    containsEmoji(contenidoProd);
                                bool emojiProductoe =
                                    containsEmoji(_productoE.text);
                                bool emojiObservacion =
                                    containsEmoji(_observacion.text);

                                if (emojiNombre ||
                                    emojiDireccion ||
                                    emojiContenidoProd ||
                                    emojiProductoe ||
                                    emojiObservacion) {
                                  readyDataSend = false;
                                }
                                if (readyDataSend) {
                                  remitente_address =
                                      prov_city_address.split('|')[2];

                                  var responseProvCityRem =
                                      await Connections().getCoverage([
                                    {
                                      "/carriers_external_simple.id":
                                          selectedCarrierExternal
                                              .toString()
                                              .split("-")[1]
                                    },
                                    {
                                      "/coverage_external.dpa_provincia.id":
                                          prov_city_address.split('|')[0]
                                    },
                                    {
                                      "/coverage_external.ciudad":
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
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(now);

                                  dataIntegration = {
                                    "remitente": {
                                      "nombre":
                                          "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
                                      "telefono": "",
                                      // "telefono":
                                      //     sharedPrefs!.getString("seller_telefono"),
                                      "provincia": remitente_prov_ref,
                                      "ciudad": remitente_city_ref,
                                      "direccion": remitente_address
                                    },
                                    "destinatario": {
                                      "nombre": _nombre.text,
                                      "telefono": _telefono.text,
                                      "provincia": destinatario_prov_ref,
                                      "ciudad": destinatario_city_ref,
                                      "direccion": _direccion.text
                                    },
                                    "cant_paquetes": "1",
                                    "peso_total": "2.00",
                                    "documento_venta": "",
                                    "contenido":
                                        "$contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}",
                                    "observacion": _observacion.text,
                                    "fecha": formattedDateTime,
                                    "declarado":
                                        double.parse(priceTotal).toString(),
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
                                    btnOkOnPress: () async {
                                      Navigator.pop(context);
                                    },
                                    btnCancelOnPress: () async {},
                                  ).show();
                                }
                              }

                              // /*
                              if (data['transportadora'].isEmpty &&
                                  data['pedido_carrier'].isEmpty) {
                                //
                                print("Nuevo no tiene ninguna Transport");
                                if (selectedCarrierType == "Interno") {
                                  //

                                  responseNewRouteTransp = await Connections()
                                      .updateOrderRouteAndTransportLaravel(
                                          selectedValueRoute
                                              .toString()
                                              .split("-")[1],
                                          selectedValueTransport
                                              .toString()
                                              .split("-")[1],
                                          data['id']);
                                  var response2 = await Connections()
                                      .updatenueva(data['id'], {
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

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  var _url = Uri.parse(
                                    """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                    // """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
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

                                    var responseOrderCarrierExt =
                                        await Connections()
                                            .getOrderCarrierExternal(
                                                data['id']);

                                    if (responseOrderCarrierExt == 1) {
                                      if (dataIntegration != null) {
                                        print(
                                            "enviar a gtm y crear un ordercarrier");
                                        // /*
                                        responseGintraNew = await Connections()
                                            .postOrdersGintra(dataIntegration);
                                        // // print("responseInteg");
                                        print(responseGintraNew);

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
                                              "id_externo":
                                                  responseGintraNew['guia'],
                                              "recaudo": recaudo ? 1 : 0,
                                              "apertura": allowApertura ? 1 : 0,
                                              "precio_total":
                                                  priceTotal.toString()
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
                                                    sharedPrefs!
                                                        .getString("id"),
                                                    "",
                                                    "");
                                            print(
                                                "updated estado_interno:CONFIRMADO with others");

                                            var _url = Uri.parse(
                                              """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                              // """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                            );

                                            if (!await launchUrl(_url)) {
                                              throw Exception(
                                                  'Could not launch $_url');
                                            }

                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          }
                                        }
                                        // */
                                      }
                                    } else if (responseOrderCarrierExt == 0) {
                                      //

                                      // ignore: use_build_context_synchronously
                                      showSuccessModal(
                                          context,
                                          "Error, Este pedido ya tiene una Transportadora Externa.",
                                          Icons8.alert);

                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  }
                                  // */
                                  //
                                }
                              } else {
                                print("Actualizar");
                                //if exist carrierExternal solo puede actualizarse con otra externa
                                if (data['transportadora'].isNotEmpty) {
                                  //
                                  print("Actualizar Transport");
                                  //

                                  if (selectedCarrierType == "Interno") {
                                    //
                                    print("a otro Transport");

                                    responseUpdtRT = await Connections()
                                        .updateOrderRouteAndTransportLaravel(
                                            selectedValueRoute
                                                .toString()
                                                .split("-")[1],
                                            selectedValueTransport
                                                .toString()
                                                .split("-")[1],
                                            data['id']);
                                    var response2 = await Connections()
                                        .updatenueva(data['id'], {
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

                                    var _url = Uri.parse(
                                      """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                      // """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                    );

                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }

                                    Navigator.pop(context);
                                    Navigator.pop(context);
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
                                      var responseOrderCarrierExt =
                                          await Connections()
                                              .getOrderCarrierExternal(
                                                  data['id']);

                                      if (responseOrderCarrierExt == 1) {
                                        if (dataIntegration != null) {
                                          print(
                                              "enviar a gtm y crear un ordercarrier");
                                          // /*
                                          responseGintraNew =
                                              await Connections()
                                                  .postOrdersGintra(
                                                      dataIntegration);
                                          // // print("responseInteg");
                                          // // print(responseGintra);

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
                                                    "Pedido creado, pero hubo un error en la asignación de la transportadora externa.",
                                                btnCancel: Container(),
                                                btnOkText: "Aceptar",
                                                btnOkColor: Colors.green,
                                                btnOkOnPress: () async {},
                                                btnCancelOnPress: () async {},
                                              ).show();
                                            } else {
                                              await Connections()
                                                  .updatenueva(data['id'], {
                                                "id_externo":
                                                    responseGintraNew['guia'],
                                                "recaudo": recaudo ? 1 : 0,
                                                "apertura":
                                                    allowApertura ? 1 : 0,
                                                "precio_total":
                                                    priceTotal.toString()
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
                                                      responseGintraNew[
                                                          'guia']);

                                              print(
                                                  "created UpdateOrderCarrier");

                                              var response3 = await Connections()
                                                  .updateOrderWithTime(
                                                      data['id'],
                                                      "estado_interno:CONFIRMADO",
                                                      sharedPrefs!
                                                          .getString("id"),
                                                      "",
                                                      "");
                                              print(
                                                  "updated estado_interno:CONFIRMADO with others");

                                              await Connections()
                                                  .deleteRutaTransportadora(
                                                      data['id']);

                                              var _url = Uri.parse(
                                                """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                                // """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                              );

                                              if (!await launchUrl(_url)) {
                                                throw Exception(
                                                    'Could not launch $_url');
                                              }

                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }
                                          }
                                          // */
                                        }
                                      } else if (responseOrderCarrierExt == 0) {
                                        //

                                        // ignore: use_build_context_synchronously
                                        showSuccessModal(
                                            context,
                                            "Error, Este pedido ya tiene una Transportadora Externa.",
                                            Icons8.alert);

                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      }
                                    }
                                    // */
                                    //
                                  }
                                } else if (data['pedido_carrier'].isNotEmpty) {
                                  //

                                  print("Actualizar carrier_external");
                                  print("Not yet");
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  /*
                                  if (selectedCarrierType == "Interno") {
                                    //
                                    print("a Transport Interna");
                                    //este caso faltaria notificar a gtm que ya no quiere
                                    responseUpdtRT = await Connections()
                                        .updateOrderRouteAndTransportLaravel(
                                            selectedValueRoute
                                                .toString()
                                                .split("-")[1],
                                            selectedValueTransport
                                                .toString()
                                                .split("-")[1],
                                            data['id']);

                                    var response2 = await Connections()
                                        .updatenueva(data['id'], {
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

                                    var _url = Uri.parse(
                                      """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                      // """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                    );

                                    if (!await launchUrl(_url)) {
                                      throw Exception('Could not launch $_url');
                                    }

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  } else {
                                    //
                                    print("a externa");
                                    print("Not yet");

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                  */
                                }

                                //
                              }
                              // */
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Color(0xFF031749),
                            ),
                          ),
                          child: const Text(
                            "GUARDAR",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
