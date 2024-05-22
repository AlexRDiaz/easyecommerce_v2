import 'dart:convert';

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
  double costEasy = 2;
  String prov_city_address = "";
  var responseCarriersGeneral;

  String quantity_variant = "";
  int isvariable = 0;

  //for edit variant and catidad
  late Map<String, dynamic> features;
  List<String> variantsToSelect = [];
  List variantsListOriginal = [];
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
    setState(() {
      estadoEntrega = data['status'].toString();
      estadoLogistic = data['estado_logistico'].toString();
      estadoInterno = data['estado_interno'].toString();
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

    if (data['id_product'] != null && data['id_product'] != 0) {
      isvariable = data['product']['isvariable'];
      priceWarehouseTotal = double.parse(data['product']['price'].toString());

      prov_city_address = getWarehouseAddress(data['product']['warehouses']);

      print("p_c_dir: $prov_city_address");

      features = jsonDecode(data['product']["features"]);

      variantsListOriginal = features["variants"];
      variantsToSelect = [];
      for (var variant in variantsListOriginal) {
        String concatenatedValues = '';
        for (var entry in variant.entries) {
          if (entry.key != "id" &&
              entry.key != "inventory_quantity" &&
              entry.key != "price") {
            concatenatedValues += '${entry.value}-';
          }
        }
        concatenatedValues = concatenatedValues.substring(
            0, concatenatedValues.length - 1); // Eliminar el último guion
        variantsToSelect.add(concatenatedValues);
      }
      //
    } else {
      print("no id_p");
    }

    var variants = data['variant_details'] != null
        ? data['variant_details'].toString()
        : "";
    List<Map<String, dynamic>> variantDetails = [];

    if (data['id_product'] != null &&
        data['id_product'] != 0 &&
        data['variant_details'] != null) {
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
      buildVariantsCurrentToSelect();
    }
    // print("variantsCurrentList: $variantsCurrentList");

    // print("variantsCurrentToSelect: $variantsCurrentToSelect");

    if (data['id_product'] != null && data['id_product'] != 0) {
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

    setState(() {
      quantity_variant = quantity_variant;
    });
    setState(() {
      loading = false;
    });
  }

  void buildVariantsCurrentToSelect() {
    variantsCurrentToSelect = [];
    for (var variant in variantsCurrentList) {
      String sku = variant['sku'];
      String variantTitle = variant['variant_title'] == null ||
              variant['variant_title'].toString() == "null" ||
              variant['variant_title'].toString() == ""
          ? ""
          : variant['variant_title'];
      // int quantity = variant['quantity'];
      String variantString = '$sku-$variantTitle';
      variantsCurrentToSelect.add(variantString);
    }
    setState(() {
      variantsCurrentToSelect = variantsCurrentToSelect;
    });
  }

  updateData() async {
    var response = await Connections().getOrdersByIdLaravel(widget.order['id']);
    data = response;
    //print(data);
    _controllers.editControllers(response);
    setState(() {
      estadoEntrega = data['status'].toString();
      estadoLogistic = data['estado_logistico'].toString();
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
        title: Text(
          "Información Pedido",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                                            estadoLogistic != "PENDIENTE")
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
                                        onPressed: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            getLoadingModal(context, false);
                                            print("**********************");
                                            if (data['variant_details'] !=
                                                null) {
                                              //
                                              print("tiene variant_details");

                                              if (data['id_product'] != null &&
                                                  data['id_product'] != 0) {
                                                //
                                                print("tiene id_product");

                                                if (isvariable == 1) {
                                                  print("is variable upt ");
                                                  print(
                                                      "variantsCurrentList: $variantsCurrentList");
                                                } else {
                                                  variantsCurrentList[0]
                                                          ['quantity'] =
                                                      int.parse(_controllers
                                                          .cantidadEditController
                                                          .text);

                                                  print(
                                                      "variantsCurrentList: $variantsCurrentList");
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
                                                print("NO tiene id_product");
                                              }
                                            } else {
                                              //
                                              print(
                                                  "NO tiene variants_details");
                                            }

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
                                                    title: 'Data Incorrecta',
                                                    desc: 'Vuelve a intentarlo',
                                                    btnCancel: Container(),
                                                    btnOkText: "Aceptar",
                                                    btnOkColor:
                                                        colors.colorGreen,
                                                    btnCancelOnPress: () {},
                                                    btnOkOnPress: () {},
                                                  ).show();
                                                });
                                          }
                                        },
                                        child: Text(
                                          "Guardar",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                                  ],
                                ),
                                Text(
                                  "Código: ${sharedPrefs!.getString("NameComercialSeller").toString()}-${data['numero_orden'].toString()}",
                                ),
                                Text(
                                  "Fecha Ingreso: ${data['marca_t_i'].toString()}",
                                ),
                                const SizedBox(height: 5),
                                TextFormField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller: _controllers.nombreEditController,
                                  decoration: const InputDecoration(
                                    labelText: "Nombre Cliente",
                                    // labelStyle: TextStyle(fontWeight: FontWeight.bold),
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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.direccionEditController,
                                  decoration: const InputDecoration(
                                    labelText: "Dirección",
                                    // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
                                TextFormField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.productoEditController,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: "Producto",
                                    // labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "Campo requerido";
                                    }
                                  },
                                ),
                                // Visibility(
                                //   visible: isvariable == 1,
                                //   child: Text(
                                //     quantity_variant,
                                //   ),
                                // ),
                                Visibility(
                                  visible: isvariable == 1,
                                  child: Row(
                                    children: [
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: 250,
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          hint: Text(
                                            'Seleccione Variante',
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
                                                item.split('-')[1],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          value: chosenCurrentVariant,
                                          onChanged: (value) {
                                            setState(() {
                                              chosenCurrentVariant =
                                                  value as String;

                                              _quantityCurrent.text =
                                                  getQuantityBySku(
                                                          chosenCurrentVariant!
                                                              .split('-')[0]
                                                              .toString())
                                                      .toString();
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
                                        onPressed: () {
                                          print(chosenCurrentVariant);
                                          if (chosenCurrentVariant != null &&
                                              _quantityCurrent.text != "") {
                                            updateQuantityBySku(
                                                chosenCurrentVariant!
                                                    .split('-')[0],
                                                int.parse(
                                                    _quantityCurrent.text));

                                            setState(() {});
                                          }
                                          print(
                                              "variantsCurrentList_Utp: $variantsCurrentList");
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                        ),
                                        child: const Text(
                                          "Editar",
                                          style: TextStyle(
                                            color: Color(
                                                0xFF031749), // Color del texto
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          newVariant = true;
                                          setState(() {});
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                        ),
                                        child: const Text(
                                          "Nuevo",
                                          style: TextStyle(
                                            color: Color(
                                                0xFF031749), // Color del texto
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
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
                                            'Seleccione Variante',
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
                                                item,
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
                                              .split('-')[0]
                                              .toString();
                                          //armar {} y añadir en variantsCurrentToSelect
                                          print(chosenSku);
                                          var variantToUpdate =
                                              variantsCurrentList.firstWhere(
                                            (variant) =>
                                                variant['sku'] ==
                                                "${chosenSku}C${data['product']['product_id']}",
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
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade300,
                                        ),
                                        child: const Text(
                                          "Añadir",
                                          style: TextStyle(
                                            color: Color(
                                                0xFF031749), // Color del texto
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Visibility(
                                  visible: isvariable == 1,
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    children: variantsCurrentList
                                        .map<Widget>((variable) {
                                      String chipLabel =
                                          "${variable['quantity']}*${variable['variant_title']}";

                                      return Chip(
                                        label: Text(chipLabel),
                                        onDeleted: () {
                                          setState(() {
                                            // Eliminar el elemento de variantsCurrentList
                                            variantsCurrentList
                                                .remove(variable);
                                          });
                                          print("variantsCurrentList actual:");
                                          print(variantsCurrentList);
                                          buildVariantsCurrentToSelect();
                                          getTotalQuantity();
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.cantidadEditController,
                                  enabled: isvariable == 0,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                    labelText: "Cantidad",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "Campo requerido";
                                    }
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  controller:
                                      _controllers.productoExtraEditController,
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
                                  decoration: const InputDecoration(
                                    labelText: "Observación",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Estado Entrega: $estadoEntrega",
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Estado Logístico: $estadoLogistic",
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Ciudad: $route",
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  // "  Transportadora: ${data['transportadora'] != null && data['transportadora'].isNotEmpty ? data['transportadora'][0]['nombre'].toString() : ''}",
                                  "Transportadora: $carrier",
                                ),
                                /* old version
                                Text(
                                  "  Código: ${sharedPrefs!.getString("NameComercialSeller").toString()}-${data['numero_orden'].toString()}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  // "  Fecha: ${data['pedido_fecha'][0]['fecha'].toString()}",
                                  "  Fecha: ${data['marca_t_i'].toString()}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                _modelTextFormField2(
                                    text: "Ciudad",
                                    controller:
                                        _controllers.ciudadEditController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [],
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo requerido";
                                      }
                                      // else if (containsEmoji(value)) {
                                      //   return "No se permiten emojis en este campo";
                                      // }
                                    }),
                                _modelTextFormField2(
                                    text: "Nombre Cliente",
                                    controller:
                                        _controllers.nombreEditController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [],
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo requerido";
                                      }
                                      // else if (containsEmoji(value)) {
                                      //   return "No se permiten emojis en este campo";
                                      // }
                                    }),
                                _modelTextFormField2(
                                    text: "Dirección",
                                    controller:
                                        _controllers.direccionEditController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [],
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo requerido";
                                      }
                                      // else if (containsEmoji(value)) {
                                      //   return "No se permiten emojis en este campo";
                                      // }
                                    }),
                                _modelTextFormField2(
                                    text: "Teléfono",
                                    controller:
                                        _controllers.telefonoEditController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9+]')),
                                    ],
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo requerido";
                                      }
                                    }),
                                _modelTextFormField2(
                                    text: "Cantidad",
                                    controller:
                                        _controllers.cantidadEditController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo requerido";
                                      }
                                    }),
                                _modelTextFormField2(
                                    text: "Producto",
                                    controller:
                                        _controllers.productoEditController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [],
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo requerido";
                                      }
                                      // else if (containsEmoji(value)) {
                                      //   return "No se permiten emojis en este campo";
                                      // }
                                    }),
                                _modelTextField(
                                    text: "Producto Extra",
                                    controller: _controllers
                                        .productoExtraEditController),
                                _modelTextFormField2(
                                    text: "Precio Total",
                                    controller:
                                        _controllers.precioTotalEditController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(
                                          r'^\d+\.?\d{0,2}$')), // "." y hasta 2 decimales
                                    ],
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Campo requerido";
                                      }
                                    }),
                                _modelTextField(
                                    text: "Observacion",
                                    controller:
                                        _controllers.observacionEditController),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "  Confirmado: ${data['estado_interno'].toString()}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "  Estado Entrega: $estadoEntrega",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "  Estado Logístico: $estadoLogistic",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "  Ciudad: ${data['ruta'] != null && data['ruta'].isNotEmpty ? data['ruta'][0]['titulo'].toString() : ''}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  // "  Transportadora: ${data['transportadora'] != null && data['transportadora'].isNotEmpty ? data['transportadora'][0]['nombre'].toString() : ''}",
                                  "  Transportadora: $carrier",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                */
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
                        (estadoInterno == "CONFIRMADO" &&
                                estadoLogistic != "PENDIENTE")
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
                                fontSize: 14, fontWeight: FontWeight.bold),
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
                controller: _controllers.precioTotalEditController,
                decoration: const InputDecoration(
                  labelText: "Precio Total",
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
                ],
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () async {
                priceTotalProduct =
                    double.parse(_controllers.precioTotalEditController.text);
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
              child: const Icon(Icons.check, color: Colors.white, size: 20),
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
                  print(data['id'].toString());

                  if (readySent) {
                    getLoadingModal(context, false);

                    // if (widget.product.isvariable == 1 &&
                    //     chosenVariant == null) {

                    String priceTotal =
                        "${_controllers.precioTotalEditController.text}";

                    // String sku =
                    //     "${chosenSku}C${widget.product.productId}";
                    String idProd = "";
                    if (data['id_product'] != null && data['id_product'] != 0) {
                      idProd = data['id_product'].toString();
                    }

                    String contenidoProd = "";
                    if (data['id_product'] != null && data['id_product'] != 0) {
                      if (isvariable == 1) {
                        for (var variant in variantsCurrentList) {
                          contenidoProd +=
                              '${variant['quantity']}*${_controllers.productoEditController.text} ${variant['variant_title']} | ';
                        }

                        contenidoProd = contenidoProd.substring(
                            0, contenidoProd.length - 3);
                      } else {
                        contenidoProd +=
                            '$quantityTotal*${_controllers.productoEditController.text}';
                      }
                    } else {
                      //
                      contenidoProd +=
                          '${_controllers.cantidadEditController}*${_controllers.productoEditController.text}';
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

                    //falta poner un getLoadingModal y nav para cerrar el mismo al terminar
                    if (selectedCarrierType == "Externo") {
                      remitente_address = prov_city_address.split('-')[2];

                      var responseProvCityRem =
                          await Connections().getCoverage([
                        {
                          "/carriers_external_simple.id":
                              selectedCarrierExternal.toString().split("-")[1]
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
                      remitente_prov_ref = responseProvCityRem['id_prov_ref'];
                      remitente_city_ref = responseProvCityRem['id_ciudad_ref'];
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
                          "nombre":
                              sharedPrefs!.getString("NameComercialSeller"),
                          "telefono": sharedPrefs!.getString("seller_telefono"),
                          "provincia": remitente_prov_ref,
                          "ciudad": remitente_city_ref,
                          "direccion": remitente_address
                        },
                        "destinatario": {
                          "nombre": _controllers.nombreEditController.text,
                          "telefono": _controllers.telefonoEditController.text,
                          "provincia": destinatario_prov_ref,
                          "ciudad": destinatario_city_ref,
                          "direccion": _controllers.direccionEditController.text
                        },
                        "cant_paquetes": "1",
                        "peso_total": "2.00",
                        "documento_venta": "",
                        "contenido":
                            "$contenidoProd${_controllers.productoExtraEditController.text.isNotEmpty ? " | ${_controllers.productoExtraEditController.text}" : ""}",
                        "observacion":
                            _controllers.observacionEditController.text,
                        "fecha": formattedDateTime,
                        "declarado": double.parse(priceTotal),
                        "con_recaudo": recaudo ? true : false
                      };
                    }
                    double costDelivery =
                        double.parse(costShippingSeller.toString()) +
                            double.parse(taxCostShipping.toString());
                    if (data['transportadora'].isEmpty &&
                        data['pedido_carrier'].isEmpty) {
                      //
                      print("Nuevo no tiene ninguna Transport");
                      if (selectedCarrierType == "Interno") {
                        //

                        responseNewRouteTransp = await Connections()
                            .updateOrderRouteAndTransportLaravel(
                                selectedValueRoute.toString().split("-")[1],
                                selectedValueTransport.toString().split("-")[1],
                                data['id']);
                        var response2 = await Connections()
                            .updatenueva(data['id'], {"recaudo": 1});

                        var response3 = await Connections().updateOrderWithTime(
                            data['id'],
                            "estado_interno:CONFIRMADO",
                            sharedPrefs!.getString("id"),
                            "",
                            "");
                        print("updated estado_interno:CONFIRMADO with others");

                        await updateData();
                        Navigator.pop(context);
                      } else {
                        //

                        // print("recaudo: ${recaudo ? 1 : 0}");
                        // print(dataIntegration);
                        print("a Una Externa");

                        if (selectedCarrierExternal.toString().split("-")[1] ==
                            "1") {
                          //send Gintra
                          print("send Gintra");

                          responseGintraNew = await Connections()
                              .postOrdersGintra(dataIntegration);
                          // // print("responseInteg");
                          // print(responseGintraNew);

                          if (responseGintraNew != []) {
                            await Connections().updatenueva(data['id'], {
                              "id_externo": responseGintraNew['guia'],
                              "recaudo": recaudo ? 1 : 0,
                            });

                            //crear un nuevo pedido_carrier_link
                            await Connections().createUpdateOrderCarrier(
                                data['id'],
                                selectedCarrierExternal
                                    .toString()
                                    .split("-")[1],
                                selectedCity.toString().split("-")[1],
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
                          }
                        }

                        //
                      }
                    } else {
                      print("Actualizar");
                      //if exist carrierExternal solo puede actualizarse con otra externa
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

                          await updateData();
                          Navigator.pop(context);
                        } else {
                          //
                          print("a un Externo");
                          //limpiar la relacion con transp_interna actual
                          // print("recaudo: ${recaudo ? 1 : 0}");
                          // print(dataIntegration);

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
                              await Connections().updatenueva(data['id'], {
                                "id_externo": responseGintraNew['guia'],
                                "recaudo": recaudo ? 1 : 0,
                              });

                              //crear un nuevo pedido_carrier_link
                              await Connections().createUpdateOrderCarrier(
                                  data['id'],
                                  selectedCarrierExternal
                                      .toString()
                                      .split("-")[1],
                                  selectedCity.toString().split("-")[1],
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
                            }
                          }

                          //
                        }
                        //
                      } else if (data['pedido_carrier'].isNotEmpty) {
                        //

                        print("Actualizar carrier_external");

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
                      }

                      //
                    }
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
    );
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

  void updateQuantityBySku(String sku, int newQuantity) {
    // Buscar el elemento en la lista con el SKU proporcionado
    var variantToUpdate = variantsCurrentList
        .firstWhere((variant) => variant['sku'] == sku, orElse: () => null);

    if (variantToUpdate != null) {
      variantToUpdate['quantity'] = newQuantity;

      getTotalQuantity();
    } else {
      print('No se encontró ningún elemento con el SKU $sku en la lista.');
    }
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
    // Obtener las claves disponibles en el mapa variantFound
    List<String> availableKeys = variantFound?.keys
            .where((key) =>
                !['id', 'sku', 'inventory_quantity', 'price'].contains(key))
            .toList() ??
        [];

    // Formar el título de la variante utilizando las claves disponibles
    String variantTitle =
        availableKeys.map((key) => variantFound?[key]).join('/');

    double priceT = (int.parse(quantity.toString()) *
        double.parse(data['product']['price'].toString()));

    Map<String, dynamic> variant = {
      "id": data['product']['product_id'],
      "name": 1101,
      "quantity": int.parse(_quantitySelectVariant.text),
      "price": priceT,
      "title": _controllers.productoEditController.text,
      "variant_title": isvariable == 1 ? variantTitle : variantFound?['sku'],
      "sku": "${variantFound?['sku']}C${data['product']['product_id']}",
    };

    return variant;
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

  _modelTextFormField2({
    text,
    controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
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
                child: TextFormField(
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
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  validator: validator,
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
}
