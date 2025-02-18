import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmCarrier extends StatefulWidget {
  final Map order;
  final int isMobile;

  const ConfirmCarrier(
      {super.key, required this.order, required this.isMobile});

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

  //
  bool logecCarrier = false;
  bool gtmCarrier = false;
  bool laarCarrier = false;

  final NumberFormat formatter = NumberFormat("#,##0.00");
  String companyId = sharedPrefs!.getString("companyId").toString();
  double weightTotal = 0;
  List listVariantsProducts = [];

  bool showLogecCarrier = false;
  bool showGtmCarrier = false;
  bool showLaarCarrier = false;
  List<dynamic> cityDestiny = [];
  bool showListProvincias = false;
  String? selectedCityDestiny;
  List<dynamic> dataCities = [];
  bool newCityDestiny = false;
  final TextEditingController _searchselectedProvinciaExt =
      TextEditingController();
  final TextEditingController _searchselectedCityExt = TextEditingController();

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

      if (data['estado_interno'] == "CONFIRMADO") {
        await processCarrierData();
      }
    }

    if (data['city_destiny'] == [] &&
        data['city_destiny'].isEmpty &&
        data['estado_interno'] == "PENDIENTE") {
      showListProvincias = true;
      getProvincias();
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

      if (data['products'].toString() == "[]" && data['products'].isEmpty) {
        print("getProdByIds");
        var responseProducts =
            await Connections().getProductsByIds(idProdUniques, []);
        variantsListProducts = responseProducts;
      }
      if (data['products'] != [] && data['products'].isNotEmpty) {
        print("or_ped_lk");
        listVariantsProducts = transformProducts(data['products']);
      }

      recaudo = true;
      addPriceWeight();
      getTotalQuantityVariantsUniques();

      if (!isCarrierExternal && data['estado_interno'] != "CONFIRMADO") {
        if (data['city_destiny'] != [] || data['city_destiny'].isNotEmpty) {
          cityDestiny = data['city_destiny'];
          // print("cityDestiny: $cityDestiny");

          showLogecCarrier = cityDestiny.any((city) => city['carrier_coverages']
              .any((coverage) =>
                  coverage['id_carrier'] == 6 && coverage['active'] == 1));
          showGtmCarrier = cityDestiny.any((city) => city['carrier_coverages']
              .any((coverage) =>
                  coverage['id_carrier'] == 1 && coverage['active'] == 1));
          showLaarCarrier = cityDestiny.any((city) => city['carrier_coverages']
              .any((coverage) =>
                  coverage['id_carrier'] == 5 && coverage['active'] == 1));

          // print("showgtmCarrier: $showGtmCarrier");
          if (showLogecCarrier) {
            if (data['id_product'] != null &&
                data['id_product'] != 0 &&
                data['variant_details'] != null &&
                data['variant_details'].toString() != "[]" &&
                data['variant_details'].isNotEmpty) {
              renameProductVariantTitle();
              calculateTotalWPrice();
              calculateTotalWeight();
            }

            setState(() {
              logecCarrier = true;
              selectedCarrierType = "Interno";
              gtmCarrier = false;
              laarCarrier = false;
              getCityDestinyCode(6);

              costShippingSeller = 0;
              profit = 0;
            });
          }
          // print("showlaarCarrier: $showLaarCarrier");
        }
        print("showListProvincias: $showListProvincias");
      }
    } else {
      print("no id_p or var_det !!");
      carriersTypeToSelect = ["Interno"];
    }

    setState(() {});
  }

  getCiudadesByProv() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      setState(() {
        citiesToSelect = [];
        dataCities = [];
        selectedCityDestiny = null;
      });

      var responseCities = await Connections()
          .getCiudadesByProv(selectedProvincia.toString().split("-")[1]);

      dataCities = responseCities['data'];
      // print(dataCities);

      for (var city in dataCities) {
        citiesToSelect.add("${city["id"]}-${city["ciudad"]}");
      }

      setState(() {});
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (error) {
      print('Error al cargar Ciudades: $error');
    }
  }

  void updateCarrierFlags(int cityId) {
    bool newShowLogecCarrier = false;
    bool newShowGtmCarrier = false;
    bool newShowLaarCarrier = false;

    for (var city in dataCities) {
      if (city["id"] == cityId) {
        if (city["carrier_coverages"] != null &&
            city["carrier_coverages"].isNotEmpty) {
          // print(city["carrier_coverages"]);
          for (var coverage in city["carrier_coverages"]) {
            if (coverage["id_carrier"] == 6 && coverage["active"] == 1) {
              newShowLogecCarrier = true;
            }
            if (coverage["id_carrier"] == 1 && coverage["active"] == 1) {
              newShowGtmCarrier = true;
            }
            if (coverage["id_carrier"] == 5 && coverage["active"] == 1) {
              newShowLaarCarrier = true;
            }
          }
        }
        break;
      }
    }

    setState(() {
      showLogecCarrier = newShowLogecCarrier;
      showGtmCarrier = newShowGtmCarrier;
      showLaarCarrier = newShowLaarCarrier;
      newCityDestiny = true;
    });

    if (showLogecCarrier) {
      calculateTotalWPrice();
      calculateTotalWeight();

      logecCarrier = true;
      selectedCarrierType = "Interno";
      gtmCarrier = false;
      laarCarrier = false;
      getCityDestinyCode(6);

      costShippingSeller = 0;
      profit = 0;

      setState(() {});
    }
  }

  void getCityDestinyCode(int idCarrierSelected) async {
    print("getCityDestinyCode");
    if (!newCityDestiny) {
      List<dynamic> carrierCoverageSelected = cityDestiny
          .expand((city) => city['carrier_coverages'])
          .where((coverage) => coverage['id_carrier'] == idCarrierSelected)
          .toList();
      // print(carrierCoverageSelected[0]);

      idProvExternal = cityDestiny[0]['id_provincia'].toString();
      String idCiudad = cityDestiny[0]['id'].toString();

      tipoCobertura = carrierCoverageSelected[0]['type'];
      String nameCity = cityDestiny[0]['ciudad'];
      String cityRef = carrierCoverageSelected[0]['id_ciudad_ref'];
      String nameProv = cityDestiny[0]['id_provincia'].toString();
      String provRef = carrierCoverageSelected[0]['id_prov_ref'];

      selectedCity = "$nameCity-$idCiudad-$tipoCobertura-$provRef-$cityRef";
      selectedProvincia = "$nameProv-$idProvExternal";

      idCarrierExternal = idCarrierSelected.toString();

      if (idCarrierExternal == "6") {
        String routeInternal = carrierCoverageSelected.isNotEmpty &&
                carrierCoverageSelected[0]['id_ciudad_ref'] != null
            ? carrierCoverageSelected[0]['id_ciudad_ref'].toString()
            : "1313";

        logecCarrier = true;
        selectedValueRoute = "$nameCity-$routeInternal";
        print("selectedValueRoute: $selectedValueRoute");
        await getTransports();
        print("selectedValueTransport: $selectedValueTransport");
      }
    } else {
      print("newCity");
      cityDestiny = [];
      cityDestiny = dataCities
          .where((city) =>
              city['id'] ==
              int.tryParse(selectedCityDestiny.toString().split("-")[0]))
          .toList();

      List<dynamic> carrierCoverageSelected = cityDestiny
          .expand((city) => city['carrier_coverages'])
          .where((coverage) => coverage['id_carrier'] == idCarrierSelected)
          .toList();

      // print(carrierCoverageSelected[0]);

      idProvExternal = cityDestiny[0]['id_provincia'].toString();
      String idCiudad = cityDestiny[0]['id'].toString();

      tipoCobertura = carrierCoverageSelected[0]['type'];
      String nameCity = cityDestiny[0]['ciudad'];
      String cityRef = carrierCoverageSelected[0]['id_ciudad_ref'];
      String nameProv = cityDestiny[0]['id_provincia'].toString();
      String provRef = carrierCoverageSelected[0]['id_prov_ref'];

      selectedCity = "$nameCity-$idCiudad-$tipoCobertura-$provRef-$cityRef";
      selectedProvincia = selectedProvincia;

      idCarrierExternal = idCarrierSelected.toString();
      if (idCarrierExternal == "6") {
        String routeInternal = carrierCoverageSelected.isNotEmpty &&
                carrierCoverageSelected[0]['id_ciudad_ref'] != null
            ? carrierCoverageSelected[0]['id_ciudad_ref'].toString()
            : "1313";

        logecCarrier = true;
        selectedValueRoute = "$nameCity-$routeInternal";
        print("selectedValueRoute: $selectedValueRoute");
        await getTransports();
        print("selectedValueTransport: $selectedValueTransport");
      }
    }

    if (idCarrierExternal == "1") {
      gtmCarrier = true;
      selectedCarrierExternal = "Gintracom-1";
    }
    if (idCarrierExternal == "5") {
      laarCarrier = true;
      selectedCarrierExternal = "Laarcourier-5";
    }

    print(selectedProvincia);
    print(selectedCity);
  }

  List<Map<String, dynamic>> transformProducts(
      List<dynamic> listOrderProducts) {
    List<Map<String, dynamic>> result = [];

    try {
      for (var item in listOrderProducts) {
        var product = item['product'];
        variantsListProducts.add(product);

        if (item['product']['isvariable'] == 1) {
          int productId = int.tryParse(product['product_id'].toString()) ??
              product['product_id'];
          String productName = product['product_name'].toString();
          String price = product['price'].toString();

          var features = jsonDecode(product["features"]);
          var variants = features["variants"];

          Map<String, dynamic> transformedProduct = {
            'product_id': productId,
            'product_name': productName,
            'price': price,
            'variants': variants
          };

          result.add(transformedProduct);
        }
      }
    } catch (e) {
      print("transformProducts $e");
    }

    return result;
  }

  void addPriceWeight() {
    // RegExp pattern = RegExp(r'^[a-zA-Z0-9]+C\d+$');
    // RegExp pattern = RegExp(r'^(.*[^C])C\d+$');
    RegExp pattern = RegExp(r'^(.*C*)C\d+$');

    // print("variantDetailsOriginal: $variantDetailsUniques");
    for (var variant in variantDetailsUniques) {
      String? skuVariant = variant['sku'];
      // String? id = variant['id'];
      // print(skuVariant);
      if (skuVariant != null &&
          skuVariant != "" &&
          pattern.hasMatch(skuVariant)) {
        // print("pasoo");
        int indexOfC = skuVariant.lastIndexOf('C');
        String onlySku = skuVariant.substring(0, indexOfC);
        String onlyId = skuVariant.substring(indexOfC + 1);

        for (var productData in variantsListProducts) {
          String idProd = productData['product_id'].toString();

          if (onlyId == idProd) {
            String productName = productData['product_name'];
            double productPrice = productData['price'];
            double productWeight = productData['weight'];

            String variable = productData['isvariable'].toString();

            if (variant.containsKey('price_w')) {
              print("El variant tiene 'price_w'");
            } else {
              print("El variant no tiene 'price_w'");
              variant['price_w'] = productPrice.toString();
              double totalPriceVar = variant['quantity'] * productPrice;
              variant['price'] = totalPriceVar.toString(); //totalprice

              variant['weight'] = productWeight.toString();
              double totalWeightVar = variant['quantity'] * productWeight;
              variant['weight_total'] = totalWeightVar.toString(); //totalweight

              // print("Se agregó 'price_w' ");
            }

            break;
          }
        }
      } else {
        // print("NO pasoo");
      }
    }

    // print("variantsCurrentToSelect: $variantsCurrentToSelect");
    // print("variantDetailsUniques: $variantDetailsUniques");
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
      // var routesList = await Connections().getRoutesLaravel();
      // setState(() {
      //   routes = routesList
      //       .where((route) => route['titulo'] != "[Vacio]")
      //       .map<String>((route) => '${route['titulo']}-${route['id']}')
      //       .toList();
      //   //'${route['titulo']}'
      // });

      var routesList = await Connections().getActiveRoutes(companyId);
      routes = List<String>.from(routesList.map((route) => route.toString()));
      setState(() {});
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

      // for (var i = 0; i < transportList.length; i++) {
      //   transports
      //       .add('${transportList[i]['nombre']}-${transportList[i]['id']}');
      // }

      selectedValueTransport =
          '${transportList[0]['nombre']}-${transportList[0]['id']}';

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
        // selectedCarrierExternal = null;
      });
      responseCarriersGeneral = await Connections().getCarriersExternal([], "");
      // for (var item in responseCarriersGeneral) {
      //   carriersExternalsToSelect.add("${item['name']}-${item['id']}");
      // }
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
        selectedCity = null;
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

  Future<void> processCarrierData() async {
    print("processCarrierData");

    calculateTotalWPrice();
    calculateTotalWeight();

    idCarrierExternal = data['pedido_carrier'][0]['carrier_id'].toString();
    idProvExternal =
        data['pedido_carrier'][0]['city_external']['id_provincia'].toString();
    String idCiudad = data['pedido_carrier'][0]['city_external_id'].toString();

    var responseCities = await Connections().getCoverage([
      {"equals/carriers_external_simple.id": idCarrierExternal},
      {"equals/coverage_external.dpa_provincia.id": idProvExternal},
      {"equals/id_coverage": idCiudad}
    ]);

    var dataTempCities = responseCities;

    tipoCobertura = dataTempCities['type'];
    // print("tipoCobertura: $tipoCobertura");
    String nameCity = dataTempCities['coverage_external']['ciudad'].toString();
    String cityRef = dataTempCities['id_ciudad_ref'].toString();
    String nameProv = dataTempCities['coverage_external']['dpa_provincia']
            ['provincia']
        .toString();
    String provRef = dataTempCities['id_prov_ref'].toString();

    selectedCity = "$nameCity-$idCiudad-$tipoCobertura-$provRef-$cityRef";
    selectedProvincia = "$nameProv-$idProvExternal";
    print(selectedCity);
    if (idCarrierExternal == "1") {
      gtmCarrier = true;
      selectedCarrierExternal = "Gintracom-1";
    }
    if (idCarrierExternal == "5") {
      laarCarrier = true;
      selectedCarrierExternal = "Laarcourier-5";
    }

    await calculateProfitCarrierExternal();
  }

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  TableRow _buildTableRowC(String label, String value, isMobile) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 5.0),
          child: Text(
            label,
            style: TextStylesSystem().ralewayStyle(
              isMobile == 0 ? 16 : 12,
              FontWeight.w600,
              ColorsSystem().colorLabels,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 5.0),
          child: Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ColorsSystem().colorLabels,
                fontSize: isMobile == 0 ? 14 : 12),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      width: widget.isMobile == 1
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.25,
      height: widget.isMobile == 1 ? screenHeight * 0.9 : screenHeight * 0.6,
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
              Text(
                "TRANSPORTADORA",
                style: TextStylesSystem().ralewayStyle(
                    14, FontWeight.bold, ColorsSystem().colorLabels),
              ),
              Visibility(
                visible: (showListProvincias) && !isCarrierExternal,
                child: Container(
                  width: screenWidth > 600 ? 350 : 250,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Provincia',
                        style: TextStylesSystem().ralewayStyle(
                            12, FontWeight.w500, ColorsSystem().colorSection2),
                      ),
                      items: provinciasToSelect
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.split('-')[0],
                                  style: TextStylesSystem().ralewayStyle(
                                      14,
                                      FontWeight.w500,
                                      ColorsSystem().colorStore),
                                ),
                              ))
                          .toList(),
                      value: selectedProvincia,
                      dropdownSearchData: DropdownSearchData(
                        searchController: _searchselectedProvinciaExt,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            controller: _searchselectedProvinciaExt,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: 'Buscar provincia...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return (item.value
                              .toString()
                              .toLowerCase()
                              .contains(searchValue.toLowerCase()));
                        },
                      ),
                      onChanged: (value) async {
                        setState(() {
                          selectedProvincia = value as String;

                          showLogecCarrier = false;
                          showGtmCarrier = false;
                          showLaarCarrier = false;
                        });

                        await getCiudadesByProv();
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 140,
                      ),
                      dropdownStyleData: const DropdownStyleData(
                        maxHeight: 200,
                      ),
                      menuItemStyleData: MenuItemStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        customHeights:
                            _getCustomItemsHeights(provinciasToSelect),
                      ),
                      iconStyleData: const IconStyleData(
                        openMenuIcon: Icon(Icons.arrow_drop_up),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: (showListProvincias) && !isCarrierExternal,
                child: Container(
                  width: screenWidth > 600 ? 350 : 250,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Ciudad',
                        style: TextStylesSystem().ralewayStyle(
                            12, FontWeight.w500, ColorsSystem().colorSection2),
                      ),
                      items: citiesToSelect
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  item.split('-')[1],
                                  style: TextStylesSystem().ralewayStyle(
                                      14,
                                      FontWeight.w500,
                                      ColorsSystem().colorStore),
                                ),
                              ))
                          .toList(),
                      value: selectedCityDestiny,
                      dropdownSearchData: DropdownSearchData(
                        searchController: _searchselectedCityExt,
                        searchInnerWidgetHeight: 50,
                        searchInnerWidget: Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 4,
                            right: 8,
                            left: 8,
                          ),
                          child: TextFormField(
                            controller: _searchselectedCityExt,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              hintText: 'Buscar ciudad...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        searchMatchFn: (item, searchValue) {
                          return (item.value
                              .toString()
                              .toLowerCase()
                              .contains(searchValue.toLowerCase()));
                        },
                      ),
                      onMenuStateChange: (isOpen) {
                        if (!isOpen) {
                          _searchselectedCityExt.clear();
                        }
                      },
                      onChanged: (value) async {
                        setState(() {
                          selectedCityDestiny = value as String;
                          logecCarrier = false;
                          gtmCarrier = false;
                          laarCarrier = false;
                        });
                        updateCarrierFlags(int.parse(
                            selectedCityDestiny.toString().split("-")[0]));
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 140,
                      ),
                      dropdownStyleData: const DropdownStyleData(
                        maxHeight: 200,
                      ),
                      menuItemStyleData: MenuItemStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        customHeights: _getCustomItemsHeights(citiesToSelect),
                      ),
                      iconStyleData: const IconStyleData(
                        openMenuIcon: Icon(Icons.arrow_drop_up),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: (showListProvincias) && !isCarrierExternal,
                child: const SizedBox(height: 20),
              ),
              Visibility(
                visible:
                    (showLogecCarrier || showGtmCarrier || showLaarCarrier),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Desactiva el scroll en el GridView
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Dos elementos en la misma fila
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 3,
                  ),
                  itemCount: 3, // Cambia según la cantidad total de cuadros
                  itemBuilder: (context, index) {
                    // btn_logec
                    if (index == 0) {
                      return Visibility(
                          visible: !isCarrierExternal && showLogecCarrier,
                          child: GestureDetector(
                            onTap: () {
                              if (data['id_product'] != null &&
                                  data['id_product'] != 0 &&
                                  data['variant_details'] != null &&
                                  data['variant_details'].toString() != "[]" &&
                                  data['variant_details'].isNotEmpty) {
                                renameProductVariantTitle();
                                calculateTotalWPrice();
                                calculateTotalWeight();
                              }

                              setState(() {
                                logecCarrier = true;
                                selectedCarrierType = "Interno";
                                gtmCarrier = false;
                                laarCarrier = false;
                                getCityDestinyCode(6);

                                costShippingSeller = 0;
                                profit = 0;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: logecCarrier
                                      ? ColorsSystem().colorSelected
                                      : ColorsSystem().colorSection,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset(
                                images.logoLogec2,
                                fit: BoxFit.contain,
                                width: 300,
                                height: 150,
                              ),
                            ),
                          ));
                    }
                    // btn_gtm
                    else if (index == 1) {
                      return Visibility(
                          visible: int.parse(companyId.toString()) == 1 &&
                              !isCarrierExternal &&
                              showGtmCarrier &&
                              (data['id_product'] != null &&
                                  data['id_product'] != 0 &&
                                  data['variant_details'] != null &&
                                  data['variant_details'].toString() != "[]" &&
                                  data['variant_details'].isNotEmpty),
                          child: GestureDetector(
                            onTap: () {
                              if (data['id_product'] != null &&
                                  data['id_product'] != 0 &&
                                  data['variant_details'] != null &&
                                  data['variant_details'].toString() != "[]" &&
                                  data['variant_details'].isNotEmpty) {
                                renameProductVariantTitle();
                                calculateTotalWPrice();
                                calculateTotalWeight();

                                getCityDestinyCode(1);
                                gtmCarrier = true;
                                selectedCarrierExternal = "Gintracom-1";
                                logecCarrier = false;
                                laarCarrier = false;
                                getCarriersExternals();
                                selectedCarrierType = "Externo";

                                costShippingSeller = 0;
                                profit = 0;
                              }

                              setState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: gtmCarrier
                                      ? ColorsSystem().colorSelected
                                      : ColorsSystem().colorSection,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset(
                                images.logoGtm,
                                fit: BoxFit.contain,
                                width: 300,
                                height: 150,
                              ),
                            ),
                          ));
                    }
                    //btn_laar
                    if (index == 2) {
                      return Visibility(
                        visible: int.parse(companyId.toString()) == 1 &&
                            // idMaster == 2 &&
                            !isCarrierExternal &&
                            showLaarCarrier &&
                            (data['id_product'] != null &&
                                data['id_product'] != 0 &&
                                data['variant_details'] != null &&
                                data['variant_details'].toString() != "[]" &&
                                data['variant_details'].isNotEmpty),
                        child: GestureDetector(
                          onTap: () {
                            if (data['id_product'] != null &&
                                data['id_product'] != 0 &&
                                data['variant_details'] != null &&
                                data['variant_details'].toString() != "[]" &&
                                data['variant_details'].isNotEmpty) {
                              renameProductVariantTitle();
                              calculateTotalWPrice();
                              calculateTotalWeight();

                              getCityDestinyCode(5);
                              laarCarrier = true;
                              logecCarrier = false;
                              gtmCarrier = false;
                              selectedCarrierExternal = "Laarcourier-5";
                              selectedCarrierType = "Externo";

                              getCarriersExternals();
                              costShippingSeller = 0;
                              profit = 0;
                            }

                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: laarCarrier
                                    ? ColorsSystem().colorSelected
                                    : ColorsSystem().colorSection,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              images.logoLaar,
                              fit: BoxFit.contain,
                              width: 300,
                              height: 150,
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: (gtmCarrier || laarCarrier) && !isCarrierExternal,
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
                visible: (gtmCarrier || laarCarrier) && !isCarrierExternal,
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
              Row(
                children: [
                  Text(
                    "Precio de venta",
                    style: TextStylesSystem().ralewayStyle(
                        14, FontWeight.bold, ColorsSystem().colorLabels),
                  ),
                ],
              ),
              const SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  Container(
                    width: screenWidth > 600 ? 180 : 120,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5)),
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: widget.isMobile == 0 ? 14 : 12,
                        fontWeight: FontWeight.w500,
                        color: ColorsSystem().colorLabels,
                      ),
                      controller: _precioTotal,
                      decoration: InputDecoration(
                        labelText: "Precio Total",
                        labelStyle: TextStylesSystem().ralewayStyle(
                          widget.isMobile == 0 ? 14 : 12,
                          FontWeight.w500,
                          ColorsSystem().colorSection2,
                        ),
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: ColorsSystem().colorSelected,
                            width: 2.0,
                          ),
                        ),
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

                                resTotalProfit =
                                    await calculateProfitCarrierExternal();
                              } else if (isCarrierExternal) {
                                //
                                // print("isCarrierExternal");
                                await processCarrierData();
                              }
                            } else {
                              resTotalProfit = await calculateProfit();
                            }

                            setState(() {
                              profit = double.parse(resTotalProfit.toString());
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
              Row(
                children: [
                  Text(
                    "Detalle de venta",
                    style: TextStylesSystem().ralewayStyle(
                        14, FontWeight.bold, ColorsSystem().colorLabels),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: widget.isMobile == 1
                        ? MediaQuery.of(context).size.width * 0.6
                        : MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Table(
                      border: TableBorder(
                        horizontalInside:
                            BorderSide(color: Colors.grey[300]!, width: 1),
                        bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                      },
                      children: [
                        _buildTableRowC("Peso total (kg):",
                            " ${formatter.format(weightTotal)}", 1),
                        _buildTableRowC("Precio de venta:",
                            "\$ ${formatter.format(priceTotalProduct)}", 1),
                        _buildTableRowC("Precio Bodega:",
                            "\$ ${formatter.format(priceWarehouseTotal)}", 1),
                        _buildTableRowC("Costo Transporte:",
                            "\$ ${formatter.format(costShippingSeller)}", 1),
                        _buildTableRowC("Total a recibir:",
                            "\$ ${formatter.format(profit)}", 1),
                      ],
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
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.red, width: 2),
                      ),
                      child: const Text(
                        "CANCELAR",
                        style: TextStyle(
                          color: Colors.red,
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
                              widget.isMobile == 0
                                  ? showSuccessModal(
                                      context,
                                      "Por favor, Debe seleccionar un tipo de transportadora.",
                                      Icons8.alert)
                                  : AwesomeDialog(
                                      width: 500,
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      title: 'Error',
                                      desc:
                                          'Por favor, Debe seleccionar un tipo de transportadora.',
                                      btnOkText: "Aceptar",
                                      btnOkColor: colors.colorGreen,
                                      btnOkOnPress: () {},
                                    ).show();
                            } else {
                              if (selectedCarrierType == "Externo") {
                                //
                                if (selectedCarrierExternal == null ||
                                    selectedProvincia == null ||
                                    selectedCity == null) {
                                  widget.isMobile == 0
                                      ? showSuccessModal(
                                          context,
                                          "Por favor, Debe seleccionar una transportadora, provincia y ciudad.",
                                          Icons8.alert)
                                      : AwesomeDialog(
                                          width: 500,
                                          context: context,
                                          dialogType: DialogType.error,
                                          animType: AnimType.rightSlide,
                                          title: 'Error',
                                          desc:
                                              'Por favor, Debe seleccionar una transportadora, provincia y ciudad.',
                                          btnOkText: "Aceptar",
                                          btnOkColor: colors.colorGreen,
                                          btnOkOnPress: () {},
                                        ).show();
                                } else {
                                  readySent = true;
                                }
                              } else {
                                //
                                if (selectedValueRoute == null ||
                                    selectedValueTransport == null) {
                                  widget.isMobile == 0
                                      ? showSuccessModal(
                                          context,
                                          "Por favor, Debe seleccionar una ciudad y una transportadora.",
                                          Icons8.alert)
                                      : AwesomeDialog(
                                          width: 500,
                                          context: context,
                                          dialogType: DialogType.error,
                                          animType: AnimType.rightSlide,
                                          title: 'Error',
                                          desc:
                                              'Por favor, Debe seleccionar una ciudad y una transportadora.',
                                          btnOkText: "Aceptar",
                                          btnOkColor: colors.colorGreen,
                                          btnOkOnPress: () {},
                                        ).show();
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
                                  if (selectedCarrierExternal
                                          .toString()
                                          .split("-")[1] ==
                                      "1") {
                                    dataIntegration = {
                                      "remitente": {
                                        "nombre":
                                            "${sharedPrefs!.getString("NameComercialSeller")}",
                                        // "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
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
                                      "observacion":
                                          "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()} ${_observacion.text}",
                                      "fecha": formattedDateTime,
                                      "declarado":
                                          double.parse(priceTotal).toString(),
                                      "con_recaudo": recaudo ? true : false,
                                      "apertura": allowApertura ? true : false,
                                    };
                                  }

                                  if (selectedCarrierExternal
                                          .toString()
                                          .split("-")[1] ==
                                      "5") {
                                    //
                                    dataIntegration = {
                                      "origen": {
                                        "identificacionO": "",
                                        "ciudadO": remitente_city_ref,
                                        "nombreO":
                                            "${sharedPrefs!.getString("NameComercialSeller")}",
                                        "direccion": remitente_address,
                                        "referencia": "",
                                        "numeroCasa": "",
                                        "postal": "",
                                        "telefono": "",
                                        "celular": "0918000113"
                                      },
                                      "destino": {
                                        "identificacionD": "", //(opcional)
                                        "ciudadD": destinatario_city_ref,
                                        // "ciudadD": "AAAAAAA",
                                        "nombreD": _nombre.text,
                                        "direccion": _direccion.text,
                                        "referencia": "", //(opcional)
                                        "numeroCasa": "",
                                        "postal": "",
                                        "telefono": "", //(opcional)
                                        "celular": _telefono.text
                                      },
                                      // "numeroGuia": numCode, //string (opcional) sin caracteres especiales, ni espacios en blanco
                                      "numeroGuia": "",
                                      "tipoServicio":
                                          "201202002002013", //"codigo": 2012020020091, "nombre": "DELIVERY"
                                      "noPiezas": 1,
                                      "peso": weightTotal,
                                      "valorDeclarado": 0, //(opcional)
                                      "contiene": contenidoProd,
                                      "tamanio": "", //(opcional)
                                      "cod": true, //(opcional)
                                      "costoflete":
                                          0, //”si tiene valor de cod true el campo obligario”
                                      "costoproducto": double.parse(
                                          priceTotal), //”si tiene valor de cod true el campo obligario”
                                      "tipocobro": 0, //(opcional),
                                      "comentario":
                                          "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()} ${_observacion.text}",
                                      "fechaPedido":
                                          "", //",(opcional)”fecha de pedido futuro”
                                      "extras": {
                                        //
                                      },
                                    };
                                  }
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
                                    "precio_total": priceTotal.toString(),
                                    "ciudad_shipping": newCityDestiny
                                        ? selectedCity.toString().split("-")[0]
                                        : data['ciudad_shipping'],
                                  });

                                  if (newCityDestiny) {
                                    await Connections()
                                        .updatenueva(data['id'], {
                                      "provincia_shipping": selectedProvincia
                                          .toString()
                                          .split("-")[0],
                                      "city_id":
                                          selectedCity.toString().split("-")[1]
                                    });
                                  }

                                  // var response3 = await Connections()
                                  //     .updateOrderWithTime(
                                  //         data['id'],
                                  //         "estado_interno:CONFIRMADO",
                                  //         sharedPrefs!.getString("id"),
                                  //         "",
                                  //         "");
                                  var response3 =
                                      await Connections().updateOrderWithTime(
                                    data['id'].toString(),
                                    "estado_interno:CONFIRMADO",
                                    sharedPrefs!.getString("id"),
                                    "",
                                    {
                                      "carrier":
                                          "int:${selectedValueTransport.toString().split("-")[1]}"
                                    },
                                  );

                                  if (response3 == 0) {
                                    print(
                                        "updated estado_interno:CONFIRMADO with others");

                                    //editStock
                                    if (data['id_product'] != null &&
                                        data['id_product'] != 0 &&
                                        data['variant_details'] != null &&
                                        data['variant_details'].toString() !=
                                            "[]" &&
                                        data['variant_details'].isNotEmpty) {
                                      var responsereduceStock =
                                          await Connections()
                                              .updateProductVariantStock(
                                        jsonEncode(variantDetailsUniques),
                                        0,
                                        idMaster.toString(),
                                        data['id'].toString(),
                                        "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
                                        "CONFIRMADO",
                                      );
                                      print(
                                          "responsereduceStock: $responsereduceStock");
                                    }

                                    //enviar email
                                    await Connections()
                                        .sendEmailConfirmedProvider(
                                      data['id'].toString(),
                                    );
                                  }

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  // var _url = Uri.parse(
                                  //   """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                  //   // """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                  // );

                                  // if (!await launchUrl(_url)) {
                                  //   throw Exception('Could not launch $_url');
                                  // }
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
                                                  priceTotal.toString(),
                                              "weight_total":
                                                  weightTotal.toString(),
                                              "ciudad_shipping": newCityDestiny
                                                  ? selectedCity
                                                      .toString()
                                                      .split("-")[0]
                                                  : data['ciudad_shipping'],
                                            });

                                            if (newCityDestiny) {
                                              await Connections()
                                                  .updatenueva(data['id'], {
                                                "provincia_shipping":
                                                    selectedProvincia
                                                        .toString()
                                                        .split("-")[0],
                                                "city_id": selectedCity
                                                    .toString()
                                                    .split("-")[1]
                                              });
                                            }

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

                                            // var response3 = await Connections()
                                            //     .updateOrderWithTime(
                                            //         data['id'],
                                            //         "estado_interno:CONFIRMADO",
                                            //         sharedPrefs!
                                            //             .getString("id"),
                                            //         "",
                                            //         "");
                                            var response3 = await Connections()
                                                .updateOrderWithTime(
                                              data['id'].toString(),
                                              "estado_interno:CONFIRMADO",
                                              sharedPrefs!.getString("id"),
                                              "",
                                              {
                                                "carrier":
                                                    "ext:${selectedCarrierExternal.toString().split("-")[1]}"
                                              },
                                            );

                                            if (response3 == 0) {
                                              print(
                                                  "updated estado_interno:CONFIRMADO with others");

                                              //editStock
                                              if (data['id_product'] != null &&
                                                  data['id_product'] != 0 &&
                                                  data['variant_details'] !=
                                                      null &&
                                                  data['variant_details']
                                                          .toString() !=
                                                      "[]" &&
                                                  data['variant_details']
                                                      .isNotEmpty) {
                                                var responsereduceStock =
                                                    await Connections()
                                                        .updateProductVariantStock(
                                                  jsonEncode(
                                                      variantDetailsUniques),
                                                  0,
                                                  idMaster.toString(),
                                                  data['id'].toString(),
                                                  "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
                                                  "CONFIRMADO",
                                                );
                                                print(
                                                    "responsereduceStock: $responsereduceStock");
                                              }

                                              //enviar email
                                              await Connections()
                                                  .sendEmailConfirmedProvider(
                                                data['id'].toString(),
                                              );
                                            }

                                            // var _url = Uri.parse(
                                            //   """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                            //   // """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                            // );

                                            // if (!await launchUrl(_url)) {
                                            //   throw Exception(
                                            //       'Could not launch $_url');
                                            // }

                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          }
                                        }
                                        // */
                                      }
                                    } else if (responseOrderCarrierExt == 0) {
                                      //

                                      // ignore: use_build_context_synchronously
                                      widget.isMobile == 0
                                          ? showSuccessModal(
                                              context,
                                              "Error, Este pedido ya tiene una Transportadora Externa.",
                                              Icons8.alert)
                                          : AwesomeDialog(
                                              width: 500,
                                              context: context,
                                              dialogType: DialogType.info,
                                              animType: AnimType.rightSlide,
                                              title: "Error",
                                              desc:
                                                  "Este pedido ya tiene una Transportadora Externa.",
                                              btnOkText: "Aceptar",
                                              btnOkColor: Colors.green,
                                              btnOkOnPress: () async {},
                                            ).show();

                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }
                                  }

                                  if (selectedCarrierExternal
                                          .toString()
                                          .split("-")[1] ==
                                      "5") {
                                    //send Laar
                                    print("send Laar");
                                    print(jsonEncode(dataIntegration));

                                    var responseOrderCarrierExt =
                                        await Connections()
                                            .getOrderCarrierExternal(
                                                data['id']);

                                    if (responseOrderCarrierExt == 1) {
                                      if (dataIntegration != null) {
                                        print(
                                            "enviar a Laar y crear un ordercarrier");

                                        var responseLaar = await Connections()
                                            .postOrderLaar(dataIntegration);

                                        print("responseLaar");
                                        print(responseLaar);

                                        if (responseLaar != 1 &&
                                            responseLaar != 2) {
                                          await Connections()
                                              .updatenueva(data['id'], {
                                            "id_externo": responseLaar['guia'],
                                            "recaudo": recaudo ? 1 : 0,
                                            "apertura": allowApertura ? 1 : 0,
                                            "precio_total":
                                                priceTotal.toString(),
                                            "weight_total":
                                                weightTotal.toString(),
                                            "ciudad_shipping": newCityDestiny
                                                ? selectedCity
                                                    .toString()
                                                    .split("-")[0]
                                                : data['ciudad_shipping'],
                                          });

                                          if (newCityDestiny) {
                                            await Connections()
                                                .updatenueva(data['id'], {
                                              "provincia_shipping":
                                                  selectedProvincia
                                                      .toString()
                                                      .split("-")[0],
                                              "city_id": selectedCity
                                                  .toString()
                                                  .split("-")[1]
                                            });
                                          }

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
                                                  responseLaar['guia']);

                                          print("created UpdateOrderCarrier");

                                          var response3 = await Connections()
                                              .updateOrderWithTime(
                                            data['id'].toString(),
                                            "estado_interno:CONFIRMADO",
                                            sharedPrefs!.getString("id"),
                                            "",
                                            {
                                              "carrier":
                                                  "ext:${selectedCarrierExternal.toString().split("-")[1]}"
                                            },
                                          );

                                          if (response3 == 0) {
                                            print(
                                                "updated estado_interno:CONFIRMADO with others");

                                            //editStock
                                            if (data['id_product'] != null &&
                                                data['id_product'] != 0 &&
                                                data['variant_details'] !=
                                                    null &&
                                                data['variant_details']
                                                        .toString() !=
                                                    "[]" &&
                                                data['variant_details']
                                                    .isNotEmpty) {
                                              var responsereduceStock =
                                                  await Connections()
                                                      .updateProductVariantStock(
                                                jsonEncode(
                                                    variantDetailsUniques),
                                                0,
                                                idMaster.toString(),
                                                data['id'].toString(),
                                                "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
                                                "CONFIRMADO",
                                              );
                                              print(
                                                  "responsereduceStock: $responsereduceStock");
                                            }

                                            //enviar email
                                            await Connections()
                                                .sendEmailConfirmedProvider(
                                              data['id'].toString(),
                                            );
                                          }

                                          // var _url = Uri.parse(
                                          //   """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                          // );

                                          // if (!await launchUrl(_url)) {
                                          //   throw Exception(
                                          //       'Could not launch $_url');
                                          // }

                                          if (mounted) {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          }
                                        } else {
                                          if (mounted) {
                                            Navigator.pop(context);
                                          }

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
                                        }
                                      }
                                    } else if (responseOrderCarrierExt == 0) {
                                      //
                                      // ignore: use_build_context_synchronously
                                      widget.isMobile == 0
                                          ? showSuccessModal(
                                              context,
                                              "Error, Este pedido ya tiene una Transportadora Externa.",
                                              Icons8.alert)
                                          : AwesomeDialog(
                                              width: 500,
                                              context: context,
                                              dialogType: DialogType.info,
                                              animType: AnimType.rightSlide,
                                              title: "Error",
                                              desc:
                                                  "Este pedido ya tiene una Transportadora Externa.",
                                              btnOkText: "Aceptar",
                                              btnOkColor: Colors.green,
                                              btnOkOnPress: () async {},
                                            ).show();

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
                                      "precio_total": priceTotal.toString(),
                                      "ciudad_shipping": newCityDestiny
                                          ? selectedCity
                                              .toString()
                                              .split("-")[0]
                                          : data['ciudad_shipping'],
                                    });

                                    if (newCityDestiny) {
                                      await Connections()
                                          .updatenueva(data['id'], {
                                        "provincia_shipping": selectedProvincia
                                            .toString()
                                            .split("-")[0],
                                        "city_id": selectedCity
                                            .toString()
                                            .split("-")[1]
                                      });
                                    }

                                    // var response3 = await Connections()
                                    //     .updateOrderWithTime(
                                    //         data['id'],
                                    //         "estado_interno:CONFIRMADO",
                                    //         sharedPrefs!.getString("id"),
                                    //         "",
                                    //         "");
                                    var response3 =
                                        await Connections().updateOrderWithTime(
                                      data['id'].toString(),
                                      "estado_interno:CONFIRMADO",
                                      sharedPrefs!.getString("id"),
                                      "",
                                      {
                                        "carrier":
                                            "int:${selectedValueTransport.toString().split("-")[1]}"
                                      },
                                    );

                                    if (response3 == 0) {
                                      print(
                                          "updated estado_interno:CONFIRMADO with others");

                                      //editStock
                                      if (data['id_product'] != null &&
                                          data['id_product'] != 0 &&
                                          data['variant_details'] != null &&
                                          data['variant_details'].toString() !=
                                              "[]" &&
                                          data['variant_details'].isNotEmpty) {
                                        var responsereduceStock =
                                            await Connections()
                                                .updateProductVariantStock(
                                          jsonEncode(variantDetailsUniques),
                                          0,
                                          idMaster.toString(),
                                          data['id'].toString(),
                                          "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
                                          "CONFIRMADO",
                                        );
                                        print(
                                            "responsereduceStock: $responsereduceStock");
                                      }

                                      //enviar email
                                      await Connections()
                                          .sendEmailConfirmedProvider(
                                        data['id'].toString(),
                                      );
                                    }

                                    // var _url = Uri.parse(
                                    //   """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                    //   // """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                    // );

                                    // if (!await launchUrl(_url)) {
                                    //   throw Exception('Could not launch $_url');
                                    // }

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
                                                    priceTotal.toString(),
                                                "weight_total":
                                                    weightTotal.toString(),
                                                "ciudad_shipping":
                                                    newCityDestiny
                                                        ? selectedCity
                                                            .toString()
                                                            .split("-")[0]
                                                        : data[
                                                            'ciudad_shipping'],
                                              });

                                              if (newCityDestiny) {
                                                await Connections()
                                                    .updatenueva(data['id'], {
                                                  "provincia_shipping":
                                                      selectedProvincia
                                                          .toString()
                                                          .split("-")[0],
                                                  "city_id": selectedCity
                                                      .toString()
                                                      .split("-")[1]
                                                });
                                              }

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

                                              // var response3 = await Connections()
                                              //     .updateOrderWithTime(
                                              //         data['id'],
                                              //         "estado_interno:CONFIRMADO",
                                              //         sharedPrefs!
                                              //             .getString("id"),
                                              //         "",
                                              //         "");
                                              var response3 =
                                                  await Connections()
                                                      .updateOrderWithTime(
                                                data['id'].toString(),
                                                "estado_interno:CONFIRMADO",
                                                sharedPrefs!.getString("id"),
                                                "",
                                                {
                                                  "carrier":
                                                      "ext:${selectedCarrierExternal.toString().split("-")[1]}"
                                                },
                                              );

                                              if (response3 == 0) {
                                                print(
                                                    "updated estado_interno:CONFIRMADO with others");

                                                //editStock
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
                                                  var responsereduceStock =
                                                      await Connections()
                                                          .updateProductVariantStock(
                                                    jsonEncode(
                                                        variantDetailsUniques),
                                                    0,
                                                    idMaster.toString(),
                                                    data['id'].toString(),
                                                    "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
                                                    "CONFIRMADO",
                                                  );
                                                  print(
                                                      "responsereduceStock: $responsereduceStock");
                                                }

                                                //enviar email
                                                await Connections()
                                                    .sendEmailConfirmedProvider(
                                                  data['id'].toString(),
                                                );
                                              }

                                              await Connections()
                                                  .deleteRutaTransportadora(
                                                      data['id']);

                                              // var _url = Uri.parse(
                                              //   """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                              //   // """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                              // );

                                              // if (!await launchUrl(_url)) {
                                              //   throw Exception(
                                              //       'Could not launch $_url');
                                              // }

                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }
                                          }
                                          // */
                                        }
                                      } else if (responseOrderCarrierExt == 0) {
                                        //

                                        // ignore: use_build_context_synchronously
                                        widget.isMobile == 0
                                            ? showSuccessModal(
                                                context,
                                                "Error, Este pedido ya tiene una Transportadora Externa.",
                                                Icons8.alert)
                                            : AwesomeDialog(
                                                width: 500,
                                                context: context,
                                                dialogType: DialogType.info,
                                                animType: AnimType.rightSlide,
                                                title:
                                                    "Error, Este pedido ya tiene una Transportadora Externa.",
                                                btnCancel: Container(),
                                                btnOkText: "Aceptar",
                                                btnOkColor: Colors.green,
                                                btnOkOnPress: () async {},
                                                btnCancelOnPress: () async {},
                                              ).show();

                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      }
                                    }

                                    if (selectedCarrierExternal
                                            .toString()
                                            .split("-")[1] ==
                                        "5") {
                                      //send Laar
                                      print("send Laar");

                                      var responseOrderCarrierExt =
                                          await Connections()
                                              .getOrderCarrierExternal(
                                                  data['id']);

                                      if (responseOrderCarrierExt == 1) {
                                        if (dataIntegration != null) {
                                          print(
                                              "enviar a Laar y crear un ordercarrier");

                                          var responseLaar = await Connections()
                                              .postOrderLaar(dataIntegration);

                                          print("responseLaar");
                                          print(responseLaar);

                                          if (responseLaar != 1 &&
                                              responseLaar != 2) {
                                            await Connections()
                                                .updatenueva(data['id'], {
                                              "id_externo":
                                                  responseLaar['guia'],
                                              "recaudo": recaudo ? 1 : 0,
                                              "apertura": allowApertura ? 1 : 0,
                                              "precio_total":
                                                  priceTotal.toString(),
                                              "weight_total":
                                                  weightTotal.toString(),
                                              "ciudad_shipping": newCityDestiny
                                                  ? selectedCity
                                                      .toString()
                                                      .split("-")[0]
                                                  : data['ciudad_shipping'],
                                            });

                                            if (newCityDestiny) {
                                              await Connections()
                                                  .updatenueva(data['id'], {
                                                "provincia_shipping":
                                                    selectedProvincia
                                                        .toString()
                                                        .split("-")[0],
                                                "city_id": selectedCity
                                                    .toString()
                                                    .split("-")[1]
                                              });
                                            }

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
                                                    responseLaar['guia']);

                                            print("created UpdateOrderCarrier");

                                            var response3 = await Connections()
                                                .updateOrderWithTime(
                                              data['id'].toString(),
                                              "estado_interno:CONFIRMADO",
                                              sharedPrefs!.getString("id"),
                                              "",
                                              {
                                                "carrier":
                                                    "ext:${selectedCarrierExternal.toString().split("-")[1]}"
                                              },
                                            );

                                            if (response3 == 0) {
                                              print(
                                                  "updated estado_interno:CONFIRMADO with others");

                                              //editStock
                                              if (data['id_product'] != null &&
                                                  data['id_product'] != 0 &&
                                                  data['variant_details'] !=
                                                      null &&
                                                  data['variant_details']
                                                          .toString() !=
                                                      "[]" &&
                                                  data['variant_details']
                                                      .isNotEmpty) {
                                                var responsereduceStock =
                                                    await Connections()
                                                        .updateProductVariantStock(
                                                  jsonEncode(
                                                      variantDetailsUniques),
                                                  0,
                                                  idMaster.toString(),
                                                  data['id'].toString(),
                                                  "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
                                                  "CONFIRMADO",
                                                );
                                                print(
                                                    "responsereduceStock: $responsereduceStock");
                                              }

                                              //enviar email
                                              await Connections()
                                                  .sendEmailConfirmedProvider(
                                                data['id'].toString(),
                                              );
                                            }

                                            await Connections()
                                                .deleteRutaTransportadora(
                                                    data['id']);

                                            // var _url = Uri.parse(
                                            //   """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: ${_producto.text}${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                                            // );

                                            // if (!await launchUrl(_url)) {
                                            //   throw Exception(
                                            //       'Could not launch $_url');
                                            // }

                                            if (mounted) {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            }
                                          } else {
                                            if (mounted) {
                                              Navigator.pop(context);
                                            }

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
                                          }
                                        }
                                      } else if (responseOrderCarrierExt == 0) {
                                        //
                                        // ignore: use_build_context_synchronously
                                        widget.isMobile == 0
                                            ? showSuccessModal(
                                                context,
                                                "Error, Este pedido ya tiene una Transportadora Externa.",
                                                Icons8.alert)
                                            : AwesomeDialog(
                                                width: 500,
                                                context: context,
                                                dialogType: DialogType.info,
                                                animType: AnimType.rightSlide,
                                                title: "Error",
                                                desc:
                                                    "Este pedido ya tiene una Transportadora Externa.",
                                                btnOkText: "Aceptar",
                                                btnOkColor: Colors.green,
                                                btnOkOnPress: () async {},
                                              ).show();

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
          // double price = int.parse(detalle['quantity'].toString()) *
          //     double.parse(detalle['price'].toString());
          // totalPriceWarehouse += price;
          double price = double.parse(detalle['price'].toString());
          totalPriceWarehouse += price;
        }
      }
    }

    totalPriceWarehouse = double.parse(totalPriceWarehouse.toStringAsFixed(2));
    setState(() {
      priceWarehouseTotal = totalPriceWarehouse;
    });
  }

  void calculateTotalWeight() async {
    double totalWeight = 0;

    for (var detalle in variantDetailsUniques) {
      if (detalle.containsKey('weight_total')) {
        double weight = double.parse(detalle['weight_total'].toString());
        totalWeight += weight;
      }
    }

    totalWeight = double.parse(totalWeight.toStringAsFixed(2));
    setState(() {
      weightTotal = totalWeight;
    });
  }

  Future<double> calculateProfitCarrierExternal() async {
    try {
      String origen_prov = prov_city_address.split('|')[0].toString();

      var costs =
          getCostsByIdCarrier(selectedCarrierExternal.toString().split("-")[1]);
      // print(costs);

      String tipoCobertura = selectedCity.toString().split("-")[2];
      double deliveryPrice = 0;
      String tipoDestino = "";

      if (gtmCarrier) {
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
      } else if (laarCarrier) {
        print("laarCarrier");

        var responseProvCityRem = await Connections().getCoverage([
          {
            "equals/carriers_external_simple.id":
                selectedCarrierExternal.toString().split("-")[1]
          },
          {
            "equals/coverage_external.dpa_provincia.id":
                prov_city_address.split('|')[0]
          },
          {"equals/coverage_external.ciudad": prov_city_address.split('|')[1]}
        ]);

        String origenCityRef = responseProvCityRem['id_ciudad_ref'];
        bool isSameCity =
            selectedCity.toString().split("-")[4] == origenCityRef;

        if (isSameCity) {
          deliveryPrice = double.parse(costs["local"].toString());
          tipoDestino = "local";
          print("local $deliveryPrice");
        } else {
          // print("Ciudad no coincidente para cobertura local");

          switch (tipoCobertura) {
            case "TP":
              deliveryPrice = double.parse(costs["principal"].toString());
              tipoDestino = "principal";
              print("principal $deliveryPrice");
              break;
            case "TS":
              deliveryPrice = double.parse(costs["secundario"].toString());
              tipoDestino = "secundario";
              print("secundario $deliveryPrice");
              break;
            case "TE":
              deliveryPrice = double.parse(costs["especial"].toString());
              tipoDestino = "especial";
              print("especial $deliveryPrice");
              break;
            case "TO":
              deliveryPrice = double.parse(costs["oriente"].toString());
              tipoDestino = "oriente";
              print("oriente $deliveryPrice");
              break;
            default:
              deliveryPrice = 0;
              tipoDestino = "local";
              print("Tipo de cobertura desconocido");
              break;
          }
        }
      }
      if (gtmCarrier) {
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
      }

      var costo_rec = (costs["costo_recaudo"]);
      double costo_recaudo = 0;
      if (recaudo) {
        // print("recaudo?? YES");
        // print("priceTotalProduct: $priceTotalProduct");
        if (gtmCarrier) {
          if (priceTotalProduct <= double.parse(costo_rec['max_price'])) {
            double base = double.parse(costo_rec['base']);
            base = base + (base * iva);
            base = (base * 100).roundToDouble() / 100;
            costo_recaudo = base;
            // print("costo_recaudo base: $costo_recaudo");
          } else {
            double incremental =
                (priceTotalProduct * double.parse(costo_rec['incremental'])) /
                    100;
            incremental = (incremental * 100).roundToDouble() / 100;
            incremental = incremental + (incremental * iva);
            incremental = (incremental * 100).roundToDouble() / 100;
            costo_recaudo = incremental;
            // print("costo_recaudo incremental: $costo_recaudo");
          }
        } else if (laarCarrier) {
          List<dynamic> tarifasRango = costo_rec['tarifas_rango'];

          for (var rango in tarifasRango) {
            double min = double.parse(rango['min'].toString());
            double max = double.parse(rango['max'].toString());
            var tarifa = rango['tarifa'];

            if (priceTotalProduct >= min && priceTotalProduct <= max) {
              if (tarifa is String && tarifa.endsWith('%')) {
                double porcentaje =
                    double.parse(tarifa.replaceAll('%', '')) / 100;
                costo_recaudo = priceTotalProduct * porcentaje;
              } else if (tarifa is double) {
                costo_recaudo = tarifa;
              }
              print("COD_laar: $costo_recaudo");
              break;
            }
          }
        }
      }

      deliveryPrice += costo_recaudo;

      deliveryPrice = (deliveryPrice * 100).roundToDouble() / 100;
      // print("after costo_recaudo: $deliveryPrice");

      if (laarCarrier) {
        var pesoRango = costs["peso_rango"];
        double maxKg = double.parse(pesoRango['max_kg'].toString());
        double tarifaBase = double.parse(pesoRango['tarifa_base'].toString());
        double tarifaAdicionalPorKg =
            double.parse(pesoRango['tarifa_adicional'][tipoDestino].toString());

        double costByWeight;
        if (weightTotal <= maxKg) {
          // costByWeight = tarifaBase;
          costByWeight = 0;
          print("costByWeight_base:");
        } else {
          double pesoAdicional = weightTotal - maxKg;
          double pesoRedondeado = pesoAdicional.ceilToDouble();
          // costByWeight = pesoRedondeado * tarifaAdicionalPorKg;
          print("pesoAdicional Red: $pesoRedondeado");
          costByWeight = pesoRedondeado * tarifaAdicionalPorKg;
          print("costByWeight_adicional:");
        }

        costByWeight = (costByWeight * 100).roundToDouble() / 100;
        print(costByWeight);

        deliveryPrice += costByWeight;
        deliveryPrice = (deliveryPrice * 100).roundToDouble() / 100;
      }

      if (laarCarrier) {
        print("total sin iva: $deliveryPrice");

        deliveryPrice = deliveryPrice + (deliveryPrice * iva);
        deliveryPrice = (deliveryPrice * 100).roundToDouble() / 100;
        print("after type + iva: $deliveryPrice");
        print("transp: $deliveryPrice");
      }

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
    } catch (e) {
      print("calculateProfitCarrierExternal: $e");
    }
    return 0;
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

  List<double> _getCustomItemsHeights(List<String> array) {
    final List<double> itemsHeights = [];
    for (int i = 0; i < array.length; i++) {
      itemsHeights.add(40);
    }
    return itemsHeights;
  }
}
