import 'dart:convert';

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
  double costEasy = 2;
  String prov_city_address = "";
  var responseCarriersGeneral;

  var data = {};

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
    _productoE.text =
        data['producto_extra'] != null && data['producto_extra'] != "null"
            ? data['producto_extra'].toString()
            : "";
    _precioTotal.text = data['precio_total'].toString();
    _observacion.text =
        (data['observacion'] != null && data['observacion'] != "null")
            ? data['observacion'].toString()
            : "";
    var variants = data['variant_details'] != null
        ? data['variant_details'].toString()
        : "";
    List<Map<String, dynamic>> variantDetails = [];

    if (data['variant_details'] != null) {
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
    if (data['id_product'] != null) {
      isvariable = data['product']['isvariable'];
      priceWarehouseTotal = double.parse(data['product']['price'].toString());

      prov_city_address = getWarehouseAddress(data['product']['warehouses']);

      // print("prov_city_address: $prov_city_address");
    }

    if (data['id_product'] != null) {
      // carriersTypeToSelect = ["Interno", "Externo"];
      carriersTypeToSelect = ["Interno"];
    } else {
      carriersTypeToSelect = ["Interno"];
    }
    recaudo = data['recaudo'].toString() == "1" ? true : false;

    setState(() {});
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
              "${firstWarehouse.id_provincia.toString()}-${firstWarehouse.city.toString()}-${firstWarehouse.address.toString()}";
        } else {
          WarehouseModel lastWarehouse = warehousesList!.last;
          name =
              "${lastWarehouse.id_provincia.toString()}-${lastWarehouse.city.toString()}-${lastWarehouse.address.toString()}";
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
    } catch (error) {
      print('Error al cargar ciudades: $error');
    }
  }

  getProvincias() async {
    try {
      setState(() {
        provinciasToSelect = [];
        selectedProvincia = null;
      });
      var provinciasList = [];

      provinciasList = await Connections().getProvincias();
      for (var i = 0; i < provinciasList.length; i++) {
        provinciasToSelect.add('${provinciasList[i]}');
      }
      setState(() {});
    } catch (error) {
      print('Error al cargar Provincias: $error');
    }
  }

  getCiudades() async {
    try {
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
      setState(() {});
    } catch (error) {
      print('Error al cargar Provincias: $error');
    }
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
              // const Text(
              //   "DATOS",
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 10),
              Text(
                "Código: ${sharedPrefs!.getString("NameComercialSeller").toString()}-${data['numero_orden'].toString()}",
              ),
              const SizedBox(height: 5),
              // Text(
              //   "Nombre Cliente: ${data['nombre_shipping'].toString()}",
              // ),
              // const SizedBox(height: 5),
              // Text(
              //   "Producto: ${data['producto_p'].toString()}",
              // ),
              // Visibility(
              //   visible: isvariable == 1,
              //   child: Text(
              //     quantity_variant,
              //   ),
              // ),
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
                    onChanged: (value) async {
                      setState(() {
                        selectedCarrierType = value as String;
                      });
                      if (selectedCarrierType == "Externo") {
                        getCarriersExternals();
                      }
                      // await getTransports();
                    },
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
                visible: selectedCarrierType == "Externo",
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
                visible: selectedCarrierType == "Externo",
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
                visible: selectedCarrierType == "Externo",
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
                visible: selectedCarrierType == "Externo",
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
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}$')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      priceTotalProduct = double.parse(_precioTotal.text);
                      var resTotalProfit;
                      if (selectedCarrierType == "Externo") {
                        resTotalProfit = await calculateProfitCarrierExternal();
                      } else {
                        resTotalProfit = await calculateProfit();
                      }

                      setState(() {
                        profit = double.parse(resTotalProfit.toString());
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.deepPurple,
                      shape: const CircleBorder(),
                    ),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 20),
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
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    "Iva 15%:",
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    // width: 200,
                    width: screenWidth > 600 ? 200 : 150,
                    child: Text(
                      '\$ ${taxCostShipping.toString()}',
                    ),
                  ),
                ],
              ),
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
              Row(
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

                          if (readySent) {
                            getLoadingModal(context, false);

                            // if (widget.product.isvariable == 1 &&
                            //     chosenVariant == null) {

                            String priceTotal = "${_precioTotal.text}";

                            // String sku =
                            //     "${chosenSku}C${widget.product.productId}";
                            String idProd = "";
                            if (data['id_product'] != null) {
                              idProd = data['id_product'].toString();
                            }

                            String messageVar = "";

                            if (quantity_variant != "") {
                              messageVar = " (";
                              messageVar += quantity_variant;
                              messageVar += ") ";
                            }

                            print(messageVar);

                            //if exist transportadora so need to update relacion
                            //if exist carrierExternal solo puede actualizarse con otra externa
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

//falta poner un getLoadingModal y nav para cerrar el mismo al terminar
                            if (selectedCarrierType == "Externo") {
                              remitente_address =
                                  prov_city_address.split('-')[2];

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
                                      prov_city_address.split('-')[0]
                                },
                                {
                                  "/coverage_external.ciudad":
                                      prov_city_address.split('-')[1]
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

                              dataIntegration = {
                                "remitente": {
                                  "nombre": sharedPrefs!
                                      .getString("NameComercialSeller"),
                                  "telefono":
                                      sharedPrefs!.getString("seller_telefono"),
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
                                    "${quantityTotal};${_producto.text}${isvariable == 1 ? messageVar : ""};${_productoE.text}", //agregar cantidad;producto;(variantes);(producto_extra) 1;Impresora termica; azul ;Envio Prioritario
                                "observacion": _observacion.text,
                                "fecha": formattedDateTime,
                                "declarado": double.parse(priceTotal),
                                "con_recaudo": recaudo ? true : false
                              };
                            }

                            if (data['transportadora'].isEmpty &&
                                data['carrier_external'] == null) {
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
                                var response2 = await Connections().updatenueva(
                                    data['id'], {
                                  "carrier_external_id": null,
                                  "ciudad_external_id": null,
                                  "recaudo": 1
                                });
                              } else {
                                //

                                // print("recaudo: ${recaudo ? 1 : 0}");
                                // print(dataIntegration);

                                if (selectedCarrierExternal
                                        .toString()
                                        .split("-")[1] ==
                                    "1") {
                                  //send Gintra
                                  print("send Gintra");
                                  // responseGintraNew = await Connections()
                                  //     .postOrdersGintra(dataIntegration);
                                  // // print("responseInteg");
                                  // // print(responseGintra);

                                  // if (responseGintraNew != []) {
                                  //   await Connections()
                                  //       .updatenueva(data['id'], {
                                  //     "id_externo": responseGintraNew['guia'],
                                  //     "carrier_external_id":
                                  //         selectedCarrierExternal
                                  //             .toString()
                                  //             .split("-")[1],
                                  //     "ciudad_external_id": selectedCity
                                  //         .toString()
                                  //         .split("-")[0],
                                  //     "recaudo": recaudo ? 1 : 0
                                  //   });
                                  // }
                                }

                                //
                              }
                            } else {
                              print("Actualizar");
                              //if exist carrierExternal solo puede actualizarse con otra externa
                              if (data['transportadora'].isNotEmpty) {
                                //
                                print("Actualizar Transport");
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
                                    .updatenueva(data['id'], {"recaudo": 1});
                              } else if (data['carrier_external'] != null) {
                                //
                                //si eligio interno ahora impiar  carrier_external_id y ciudad_external_id y avisar a transportadora externa
                                //si eligio externo solo actualizar y enviar updt si es un nuevo carrier_external_id
                                print("Actualizar carrier_external");
                                if (data['carrier_external']['id'].toString() !=
                                    selectedCarrierExternal
                                        .toString()
                                        .split("-")[1]) {
                                  //

                                  print("cambiar de externa a externa");
                                  print(dataIntegration);

                                  if (selectedCarrierExternal
                                          .toString()
                                          .split("-")[1] ==
                                      "1") {
                                    //send Gintra
                                    // print("send Gintra");
                                    // responseGintraUpdt = await Connections()
                                    //     .postOrdersGintra(dataIntegration);
                                    // // print("responseInteg");
                                    // // print(responseGintra);

                                    // if (responseGintraUpdt != []) {
                                    //   await Connections()
                                    //       .updatenueva(data['id'], {
                                    //     "id_externo":
                                    //         responseGintraUpdt['guia'],
                                    //     "carrier_external_id":
                                    //         selectedCarrierExternal
                                    //             .toString()
                                    //             .split("-")[1],
                                    //     "ciudad_external_id": selectedCity
                                    //         .toString()
                                    //         .split("-")[0],
                                    //     "recaudo": recaudo ? 1 : 0
                                    //   });
                                    // }
                                  }
                                }
                              }

                              //
                            }

                            if (responseNewRouteTransp != [] ||
                                responseGintraNew != [] ||
                                responseUpdtRT != [] ||
                                responseGintraUpdt != []) {
                              //
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
                            }
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
            ],
          ),
        ),
      ),
    );
  }

  Future<double> calculateProfitCarrierExternal() async {
    var costs =
        getCostsByIdCarrier(selectedCarrierExternal.toString().split("-")[1]);
    // print(costs);

    // print(destino_prov);
    // print(destino_city);
    // print("${selectedProvincia.toString().split("-")[1]}");
    // print("${selectedCity.toString().split("-")[1]}");
    String tipoCobertura = selectedCity.toString().split("-")[2];
    double deliveryPrice = 0;
    if (selectedProvincia.toString().split("-")[1] == origen_prov) {
      print("Provincial");
      // print("${selectedCity.toString()}");
      if (tipoCobertura == "Normal") {
        //
        deliveryPrice = double.parse(costs["normal1"].toString());
      } else {
        //
        deliveryPrice = double.parse(costs["especial1"].toString());
      }
    } else {
      print("Nacional");
      // print("${selectedCity.toString()}");
      if (tipoCobertura == "Normal") {
        //
        deliveryPrice = double.parse(costs["normal2"].toString());
      } else {
        //
        deliveryPrice = double.parse(costs["especial2"].toString());
      }
    }
    // print("after type: $deliveryPrice");

    double costo_seguro =
        (priceTotalProduct * (double.parse(costs["costo_seguro"]))) / 100;
    costo_seguro = double.parse(costo_seguro.toStringAsFixed(2));
    deliveryPrice += costo_seguro;
    // print("after costo_seguro: $deliveryPrice");

    var costo_rec = (costs["costo_recaudo"]);

    if (recaudo) {
      // print("recaudo?? YES");
      // print("priceTotalProduct: $priceTotalProduct");

      if (priceTotalProduct < double.parse(costo_rec['max_price'])) {
        double base = double.parse(costo_rec['base']);
        base = double.parse(base.toStringAsFixed(2));

        deliveryPrice += base;
      } else {
        double incremental =
            (priceTotalProduct * double.parse(costo_rec['incremental'])) / 100;
        incremental = double.parse(incremental.toStringAsFixed(2));

        deliveryPrice += incremental;
      }
    }
    // print("after recaudo: $deliveryPrice");
    deliveryPrice = double.parse(deliveryPrice.toStringAsFixed(2));

    double iva = deliveryPrice * (15 / 100);
    deliveryPrice = costEasy + deliveryPrice;
    iva = double.parse(iva.toStringAsFixed(2));
    //falta iva
    setState(() {
      costShippingSeller = deliveryPrice;
      taxCostShipping = iva;
    });
    double totalProfit =
        priceTotalProduct - (priceWarehouseTotal + deliveryPrice + iva);

    totalProfit = double.parse(totalProfit.toStringAsFixed(2));

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

    double iva = costShippingSeller * (15 / 100);
    iva = double.parse(iva.toStringAsFixed(2));

    setState(() {
      costShippingSeller = costShippingSeller;
      taxCostShipping = iva;
    });

    double totalProfit =
        priceTotalProduct - (priceWarehouseTotal + costShippingSeller + iva);

    totalProfit = double.parse(totalProfit.toStringAsFixed(2));

    return totalProfit;
  }
}
