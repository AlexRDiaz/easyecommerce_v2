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
  int idUser = int.parse(sharedPrefs!.getString("id").toString());
  int idMaster =
      int.parse(sharedPrefs!.getString("idComercialMasterSeller").toString());

  List<Map<String, dynamic>> variantDetails = [];
  double iva = 0.15;

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
    variantDetails = [];

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
      if (idUser == 2 || idMaster == 188 || idMaster == 189) {
        carriersTypeToSelect = ["Interno", "Externo"];
      } else {
        carriersTypeToSelect = ["Interno"];
      }
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

                            String contenidoProd = "";
                            if (data['id_product'] != null &&
                                data['id_product'] != 0) {
                              if (isvariable == 1) {
                                for (var variant in variantDetails) {
                                  contenidoProd +=
                                      '${variant['quantity']}*${_producto.text} ${variant['variant_title']} | ';
                                }

                                contenidoProd = contenidoProd.substring(
                                    0, contenidoProd.length - 3);
                              } else {
                                contenidoProd +=
                                    '$quantityTotal*${_producto.text}';
                              }
                            } else {
                              //
                              contenidoProd += '${_cantidad}*${_producto.text}';
                            }

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
                                    "$contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}",
                                "observacion": _observacion.text,
                                "fecha": formattedDateTime,
                                "declarado": double.parse(priceTotal),
                                "con_recaudo": recaudo ? true : false
                              };
                            }

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
                                    .updatenueva(data['id'], {"recaudo": 1});

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
                              } else {
                                //

                                // print("recaudo: ${recaudo ? 1 : 0}");
                                // print(dataIntegration);
                                print("a Una Externa");

                                if (selectedCarrierExternal
                                        .toString()
                                        .split("-")[1] ==
                                    "1") {
                                  //send Gintra
                                  print("send Gintra");

                                  responseGintraNew = await Connections()
                                      .postOrdersGintra(dataIntegration);
                                  // // print("responseInteg");
                                  print(responseGintraNew);

                                  if (responseGintraNew != []) {
                                    await Connections()
                                        .updatenueva(data['id'], {
                                      "id_externo": responseGintraNew['guia'],
                                      "recaudo": recaudo ? 1 : 0,
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

                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                }

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
                                      .updatenueva(data['id'], {"recaudo": 1});

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
                                } else {
                                  //
                                  print("a un Externo");
                                  //limpiar la relacion con transp_interna actual
                                  // print("recaudo: ${recaudo ? 1 : 0}");
                                  print(dataIntegration);

                                  if (selectedCarrierExternal
                                          .toString()
                                          .split("-")[1] ==
                                      "1") {
                                    //send Gintra
                                    print("send Gintra");

                                    responseGintraNew = await Connections()
                                        .postOrdersGintra(dataIntegration);
                                    // // print("responseInteg");
                                    // // print(responseGintra);

                                    if (responseGintraNew != []) {
                                      await Connections()
                                          .updatenueva(data['id'], {
                                        "id_externo": responseGintraNew['guia'],
                                        "recaudo": recaudo ? 1 : 0,
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

                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  }

                                  //
                                }
                              } else if (data['pedido_carrier'].isNotEmpty) {
                                //

                                print("Actualizar carrier_external");

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
                                      .updatenueva(data['id'], {"recaudo": 1});

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

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } else {
                                  //
                                  print("a externa");
                                  print("Not yet");

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              }

                              //
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
    String origen_prov = prov_city_address.split('-')[0].toString();

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
    // print("costo entrega after recaudo: $deliveryPrice");

    deliveryPrice = costEasy + deliveryPrice;
    double deliveryPriceTax = deliveryPrice * iva;
    deliveryPriceTax = (deliveryPriceTax * 100).roundToDouble() / 100;

    // print("costo deliveryPriceSeller: ${deliveryPrice + deliveryPriceTax}");

    //
    setState(() {
      costShippingSeller = deliveryPrice;
      taxCostShipping = deliveryPriceTax;
    });
    double totalProfit = priceTotalProduct -
        (priceWarehouseTotal + deliveryPrice + deliveryPriceTax);

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
    double deliveryPriceTax = costShippingSeller * iva;
    deliveryPriceTax = (deliveryPriceTax * 100).roundToDouble() / 100;

    setState(() {
      costShippingSeller = costShippingSeller;
      taxCostShipping = deliveryPriceTax;
    });

    double totalProfit =
        priceTotalProduct - (priceWarehouseTotal + costShippingSeller + iva);

    totalProfit = (totalProfit * 100).roundToDouble() / 100;

    return totalProfit;
  }
}
