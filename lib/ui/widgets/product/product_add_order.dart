import 'dart:convert';
import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/main.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
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
  String product_name = "";

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
  List<String> carriersTypeToSelect = ["Interno", "Externo"];
  // List<String> carriersTypeToSelect = ["Interno"];
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

  double priceTotalProduct = 0;
  double taxCostShipping = 0;
  double costEasy = 2.3;
  String prov_city_address = "";

  var responseCarriersGeneral;
  double iva = 0.15;
  int idUser = int.parse(sharedPrefs!.getString("id").toString());
  int idMaster =
      int.parse(sharedPrefs!.getString("idComercialMasterSeller").toString());
  double totalCost = 0;

  bool allowApertura = true;

  int storageWarehouse = 0;

  List populate = ["warehouses_s"];
  List arrayFiltersOr = [];
  List arrayFiltersAnd = [
    // {"warehouse.warehouse_id": 1}
  ];
  String sortFieldDefaultValue = "product_id:DESC";

  bool addProduct = false;
  List<dynamic> extraProdList = [];
  List<String> extraProdToSelect = [];
  String? selectedExtraProd;
  bool isVariableExtraProd = false;

  List<String> variantsExtraProdToSelect = [];
  String? chozenVariantExtraProd;
  double quantityExtraProd = 1;
  List<dynamic> multifilter = [];
  final TextEditingController _searchProdExtra = TextEditingController();
  bool editLabelExtraProduct = true;

  String contenidoProd = "";
  String labelProducto = "";

  bool containsEmoji(String text) {
    final emojiPattern = RegExp(
        r'[\u2000-\u3300]|[\uD83C][\uDF00-\uDFFF]|[\uD83D][\uDC00-\uDE4F]'
        r'|[\uD83D][\uDE80-\uDEFF]|[\uD83E][\uDD00-\uDDFF]|[\uD83E][\uDE00-\uDEFF]');
    // r'|[!@#$%^&*()_+{}\[\]:;<>,.?~\\/-]');
    return emojiPattern.hasMatch(text);
  }

  @override
  void didChangeDependencies() {
    // if (idUser == 2 || idMaster == 188 || idMaster == 189) {
    //   carriersTypeToSelect = ["Interno", "Externo"];
    // } else {
    //   carriersTypeToSelect = ["Interno"];
    // }
    getRoutes();
    getCarriersExternals();

    getData();
    super.didChangeDependencies();
  }

  getData() async {
    // numeroOrden = await generateNumeroOrden();
    _producto.text = widget.product.productName!;
    product_name = widget.product.productName!;
    double? priceT = widget.product.price;

    features = jsonDecode(widget.product.features);
    chosenSku = features["sku"];
    priceSuggestedProd = double.parse(features["price_suggested"].toString());

    String priceSuggested = "";
    /*
    priceSuggested = features["price_suggested"].toString();

    if (priceSuggested.contains(".")) {
      var parts = priceSuggested.split('.');
      _precioTotalEnt.text = parts[0];
      _precioTotalDec.text = parts[1];
    } else {
      _precioTotalEnt.text = priceSuggested;
      _precioTotalDec.text = "00";
    }
    */

    _cantidad.text = "1";

    variantsListOriginal = features["variants"];

    if (widget.product.isvariable == 1) {
      // print(variantsListOriginal);

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
    }

    // print(costShippingSeller);
    // origen_prov = widget.product.warehouse?.id_provincia.toString();
    // origen_city = widget.product.warehouse?.city.toString();
    prov_city_address = getWarehouseAddress(widget.product.warehouses);

    print("prov_city_address: $prov_city_address");

    setState(() {});

    //
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
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {});
    } catch (error) {
      print('Error al cargar Ciudades: $error');
    }
  }

  String getWarehouseAddress(dynamic warehouses) {
    String name = "";
    List<WarehouseModel>? warehousesList = warehouses;

    if (warehousesList?.length == 1) {
      WarehouseModel firstWarehouse = warehousesList!.first;
      // print("${firstWarehouse.id}-${firstWarehouse.branchName}");
      name =
          "${firstWarehouse.id_provincia.toString()}|${firstWarehouse.city.toString()}|${firstWarehouse.address.toString()}";
      storageWarehouse = firstWarehouse.id!;
    } else {
      WarehouseModel lastWarehouse = warehousesList!.last;
      // print("${lastWarehouse.id}-${lastWarehouse.branchName}");
      name =
          "${lastWarehouse.id_provincia.toString()}|${lastWarehouse.city.toString()}|${lastWarehouse.address.toString()}";
      storageWarehouse = lastWarehouse.id!;
    }
    return name;
  }

  getProductsByWarehouse() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      extraProdToSelect = [];

      var response = await Connections().getProductsByStorage(
        populate,
        storageWarehouse,
        idMaster,
        widget.product.productId,
      );
      // print(response);
      extraProdList = response;
      var features;

      for (var product in extraProdList) {
        features = jsonDecode(product['features']);
        String skuGen = features['sku'];
        if (widget.product.productId != product['product_id']) {
          extraProdToSelect.add(
              "${product['product_id']}|$skuGen|${product['isvariable']}|${product['product_name']}|${product['price']}|${jsonEncode(features['variants'])}|${features['price_suggested']}");
        }
      }
      setState(() {
        // extraProdToSelect = extraProdToSelect;
      });

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    } catch (error) {
      print('Error al cargar TranspExter: $error');
    }
  }

  void buildVariantsToSelect(String stringVariants) {
    variantsExtraProdToSelect.clear();
    try {
      var variants = jsonDecode(stringVariants);
      // print(variants);

      for (var element in variants) {
        String title = buildVariantTitle(element);
        String skuVariant = element['sku'];
        String priceV = element['price'];

        variantsExtraProdToSelect.add("$skuVariant|$title|$priceV");

        // print("variantsCurrentToSelect: $variantsProdToSelect");
      }
      print("buildVariantsToSelect after for");
      // setState(() {}); // Asegura que se reconstruya el Dropdown
    } catch (e) {
      print("buildVariantsToSelect: $e");
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(20),
      width: screenWidth * 70,
      // color: Colors.amber,
      height: MediaQuery.of(context).size.height,
      child: Form(
        key: formKey,
        child: responsive(
            Row(
              children: [
                Container(
                  width: screenWidth * 0.5,
                  child: _sectionData(context),
                ),
                const SizedBox(
                  width: 20,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: _sectionCarriers(context),
                ),
              ],
            ),
            Column(
              children: [
                _sectionDataMobile(context),
                // _sectionCarriers(context),
              ],
            ),
            context),
      ),
    );
  }

  ListView _sectionData(BuildContext context) {
    //
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      padding: const EdgeInsets.only(right: 20),
      children: [
        const Text(
          "DATOS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          maxLines: null,
          readOnly: true,
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
        //simple
        Visibility(
          visible: widget.product.isvariable == 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                height: 40,
                child: SpinBox(
                  min: 1,
                  max: 100,
                  value: quantity,
                  onChanged: (value) {
                    setState(() {
                      quantity = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buttonAddSimple(context),
            ],
          ),
        ),
        // variant
        Visibility(
          visible: widget.product.isvariable == 1,
          child: const Row(
            children: [
              Text(
                "Variante:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Visibility(
          visible: widget.product.isvariable == 1,
          child: Row(
            children: [
              SizedBox(
                width: screenWidth * 0.3,
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
                    return DropdownMenuItem(
                      value: item,
                      child: Text(
                        item.split('-')[1],
                        // item,
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
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: widget.product.isvariable == 1,
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
          visible: widget.product.isvariable == 1,
          child: Row(
            children: [
              SizedBox(
                width: 150,
                height: 40,
                child: SpinBox(
                  min: 1,
                  max: 100,
                  value: quantity,
                  onChanged: (value) {
                    setState(() {
                      quantity = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buttonAddVariants(context),
            ],
          ),
        ),
        const SizedBox(height: 10),
        //new extraProduct
        Row(
          children: [
            TextButton(
              onPressed: () async {
                var firstId = variantsDetailsList.isEmpty
                    ? 0
                    : variantsDetailsList[0]['name'];
                // print(firstId);

                if (int.parse(widget.product.productId.toString()) != firstId) {
                  //
                  showSuccessModal(
                      context,
                      "Por favor, primero añada el producto principal.",
                      Icons8.warning_1);
                } else {
                  setState(() {
                    addProduct = true;
                  });
                  await getProductsByWarehouse();
                }
              },
              child: const Row(
                children: [
                  Icon(Icons.add),
                  SizedBox(width: 5),
                  Text('Añadir Producto Extra'),
                ],
              ),
            )
          ],
        ),
        Visibility(
          visible: addProduct,
          child: Row(
            children: [
              Container(
                width: screenWidth * 0.35,
                color: Colors.white,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: Text(
                      'Producto',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: extraProdToSelect
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item.split('|')[3],
                                // item,
                                // // "${item.split('|')[0]} ${item.split('|')[2]} ${item.split('|')[3]}",
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                    value: selectedExtraProd,
                    ////
                    dropdownSearchData: DropdownSearchData(
                      searchController: _searchProdExtra,
                      searchInnerWidgetHeight: 50,
                      searchInnerWidget: Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 4,
                          right: 8,
                          left: 8,
                        ),
                        child: TextFormField(
                          controller: _searchProdExtra,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            hintText: 'Buscar producto...',
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
                    //This to clear the search value when you close the dropdown
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        _searchProdExtra.clear();
                      }
                    },
                    /////
                    onChanged: (String? value) {
                      setState(() {
                        selectedExtraProd = value;
                      });
                      // print(selectedExtraProd);
                      try {
                        int typeProd = int.parse(
                            selectedExtraProd!.split('|')[2].toString());
                        // print(typeProd);
                        // print("${selectedExtraProd!.split('|')[5]}");
                        if (typeProd == 1) {
                          //search variants
                          isVariableExtraProd = true;
                          // print(chozenVariantExtraProd);
                          chozenVariantExtraProd = null;

                          buildVariantsToSelect(
                              selectedExtraProd!.split('|')[5]);
                        } else {
                          isVariableExtraProd = false;
                        }
                        setState(() {});
                      } catch (e) {
                        print("$e");
                      }
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
                      customHeights: _getCustomItemsHeights(extraProdToSelect),
                    ),
                    iconStyleData: const IconStyleData(
                      openMenuIcon: Icon(Icons.arrow_drop_up),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Visibility(
          visible: addProduct,
          child: Row(
            children: [
              Visibility(
                visible: addProduct && isVariableExtraProd,
                child: Container(
                  width: screenWidth * 0.2,
                  color: Colors.white,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Variante',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items: variantsExtraProdToSelect
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(
                                  // item,
                                  item.split('|')[1],
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                          .toList(),
                      value: chozenVariantExtraProd,
                      onChanged: (String? value) {
                        setState(() {
                          chozenVariantExtraProd = value;
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        height: 40,
                        width: 140,
                      ),
                      dropdownStyleData: const DropdownStyleData(
                        maxHeight: 200,
                      ),
                      menuItemStyleData: MenuItemStyleData(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        customHeights:
                            _getCustomItemsHeights(variantsExtraProdToSelect),
                      ),
                      iconStyleData: const IconStyleData(
                        openMenuIcon: Icon(Icons.arrow_drop_up),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: isVariableExtraProd,
                child: const SizedBox(width: 10),
              ),
              Column(
                children: [
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: SpinBox(
                      min: 1,
                      max: 100,
                      textAlign: TextAlign.center,
                      value: quantityExtraProd,
                      onChanged: (value) {
                        setState(() {
                          quantityExtraProd = value;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              _buttonAddExtraProd(context)
            ],
          ),
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
                  children: variantsDetailsList.map<Widget>((variant) {
                    String chipLabel = "${variant['title'].toString()} ";

                    chipLabel +=
                        variant['variant_title'].toString() != "null" &&
                                variant['variant_title'].toString() != ""
                            ? "${variant['variant_title']} - "
                            : "";

                    chipLabel += "Cantidad: ${variant['quantity']}";
                    chipLabel += " - Precio Bodega: ${variant['price_w']}";
                    chipLabel += " - Total: \$${variant['price']}";

                    if (screenWidth < 600) {
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
                          if (variant.containsKey('sku')) {
                            variantsDetailsList.remove(variant);
                          }
                          calculateTotalWPrice();
                          calculateTotalQuantity();
                        } else {
                          variantsDetailsList.clear();
                          calculateTotalWPrice();
                          calculateTotalQuantity();
                        }
                        editLabelExtraProduct = checkIfIdMatches(
                            int.parse(widget.product.productId.toString()));

                        fillProdProdExtr();

                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          style: const TextStyle(fontWeight: FontWeight.bold),
          controller: _productoE,
          readOnly: !editLabelExtraProduct,
          maxLines: null,
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
      ],
    );
  }

  List<double> _getCustomItemsHeights(List<String> array) {
    final List<double> itemsHeights = [];
    for (int i = 0; i < array.length; i++) {
      itemsHeights.add(40);
    }
    return itemsHeights;
  }

  Column _sectionCarriers(BuildContext context) {
    //
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TRANSPORTADORA",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 350,
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
                if (variantsDetailsList.isEmpty) {
                  showSuccessModal(
                      context,
                      "Por favor, debe al menos añadir un producto.",
                      Icons8.alert);
                } else {
                  setState(() {
                    selectedCarrierType = value as String;
                  });
                  if (selectedCarrierType == "Externo") {
                    getCarriersExternals();
                  }
                  // await getTransports();
                }
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
            width: 350,
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
            width: 350,
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
            width: 350,
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
            width: 350,
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
            width: 350,
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
              const Text("Con Recaudo"),
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
              const SizedBox(width: 20),
              const Text("Sin Recaudo"),
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
                      _precioTotalEnt.text = "00";
                      _precioTotalDec.text = "00";
                    });
                  }
                },
                shape: CircleBorder(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Visibility(
          visible: selectedCarrierType == "Externo",
          child: const Text("¿Autoriza la apertura del pedido?"),
        ),
        Visibility(
          visible: selectedCarrierType == "Externo",
          child: Row(
            children: [
              const Text("SI"),
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
              const SizedBox(width: 20),
              const Text("NO"),
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
              // width: 100,
              width: screenWidth > 600 ? 100 : 70,
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
              width: screenWidth > 600 ? 100 : 70,
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
                priceTotalProduct = double.parse(
                    "${_precioTotalEnt.text}.${_precioTotalDec.text.replaceAll(',', '')}");
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
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EEE8F4),
                // backgroundColor: Colors.transparent,
                side: const BorderSide(
                    color: Color(0xFF031749), width: 2), // Borde del botón
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
            ElevatedButton(
              onPressed: () async {
                bool readySent = false;
                if (formKey.currentState!.validate()) {
                  if (selectedCarrierType == null) {
                    showSuccessModal(
                        context,
                        "Por favor, Debe seleccionar un tipo de transportadora.",
                        Icons8.warning_1);
                  } else {
                    if (selectedCarrierType == "Externo") {
                      //
                      if (selectedCarrierExternal == null ||
                          selectedProvincia == null ||
                          selectedCity == null) {
                        showSuccessModal(
                            context,
                            "Por favor, Debe seleccionar una transportadora, provincia y ciudad.",
                            Icons8.warning_1);
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
                            Icons8.warning_1);
                      } else {
                        readySent = true;
                      }
                    }
                  }

                  if (readySent) {
                    // if (widget.product.isvariable == 1 &&
                    //     chosenVariant == null) {
                    if (widget.product.isvariable == 1 &&
                        variantsDetailsList.isEmpty) {
                      showSuccessModal(
                          context,
                          "Por favor, Debe al menos seleccionar una variante del producto.",
                          Icons8.warning_1);
                    } else {
                      if (formKey.currentState!.validate()) {
                        // print("$selectedCarrierType");

                        //check stock
                        getLoadingModal(context, false);

                        var responseCurrentStock = await Connections()
                            .getCurrentStock(
                                sharedPrefs!
                                    .getString("idComercialMasterSeller")
                                    .toString(),
                                variantsDetailsList);

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

                        print("isAllAvailable: ${$isAllAvailable}");

                        if (!$isAllAvailable) {
                          // print("${$textRes}}");

                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);

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
                          //
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);

                          getLoadingModal(context, false);

                          String priceTotal =
                              "${_precioTotalEnt.text}.${_precioTotalDec.text}";
/*
                          // String sku =
                          //     "${chosenSku}C${widget.product.productId}";
                          String idProd = widget.product.productId.toString();

                          // String messageVar = "";

                          List<Map<String, dynamic>> groupedProducts =
                              groupProducts(variantsDetailsList);
                          print(groupedProducts);

                          // for (var product in groupedProducts) {
                          //   labelProducto +=
                          //       '${product['name']} ${product['variants']}; \n';
                          // }

                          // labelProducto = labelProducto.substring(
                          //     0, labelProducto.length - 3);

                          labelProducto =
                              '${groupedProducts[0]['name']} ${groupedProducts[0]['variants']}';
                          _producto.text = labelProducto;
                          // Obtener el resto de los elementos
                          List<String> extraProductsList =
                              groupedProducts.sublist(1).map((product) {
                            return '${product['name']} ${product['variants']}';
                          }).toList();
                          _productoE.text = extraProductsList.join('\n');

                          print('productoP: ${_producto.text}');
                          print('productoExtra: ${_productoE.text}');
                          //
                          contenidoProd =
                              buildVariantsDetailsText(variantsDetailsList);
                          print("contenidoProd: $contenidoProd");
*/

                          fillProdProdExtr();

                          String remitente_address =
                              prov_city_address.split('|')[2];

                          String remitente_prov_ref = "";
                          String remitente_city_ref = "";
                          String destinatario_prov_ref = "";
                          String destinatario_city_ref = "";
                          var dataIntegration;

                          if (selectedCarrierType == "Externo") {
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
                          }

                          double costDelivery =
                              double.parse(costShippingSeller.toString()) +
                                  double.parse(taxCostShipping.toString());

                          // print("$labelProducto");
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
                          }
                          if (!readyDataSend) {
                            //
                            // ignore: use_build_context_synchronously
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

                          // /*

                          if (readyDataSend) {
                            var response =
                                await Connections().createOrderProduct(
                              sharedPrefs!.getString("idComercialMasterSeller"),
                              sharedPrefs!.getString("NameComercialSeller"),
                              _nombre.text,
                              _direccion.text,
                              _telefono.text,
                              selectedCarrierType == "Externo"
                                  ? selectedCity.toString().split("-")[0]
                                  : selectedValueRoute.toString().split("-")[0],
                              // _producto.text,
                              labelProducto,
                              _productoE.text,
                              // _cantidad.text,
                              quantityTotal,
                              priceTotal,
                              _observacion.text,
                              // sku,
                              // idProd,
                              variantsDetailsList,
                              recaudo ? 1 : 0, allowApertura ? 1 : 0,
                              selectedCarrierType == "Externo"
                                  ? costDelivery.toString()
                                  : null,
                              selectedCarrierType == "Interno"
                                  ? selectedValueRoute.toString().split("-")[1]
                                  : "0",
                              selectedCarrierType == "Interno"
                                  ? selectedValueTransport
                                      .toString()
                                      .split("-")[1]
                                  : "0",
                              selectedCarrierType == "Externo"
                                  ? selectedCarrierExternal
                                      .toString()
                                      .split("-")[1]
                                  : "0",
                              selectedCarrierType == "Externo"
                                  ? selectedCity.toString().split("-")[1]
                                  : "0",
                            );

                            // print(response);

                            if (selectedCarrierType == "Externo") {
                              if (selectedCarrierExternal
                                      .toString()
                                      .split("-")[1] ==
                                  "1") {
                                if (response != 1 || response != 2) {
                                  DateTime now = DateTime.now();

                                  String formattedDateTime =
                                      DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(now);

                                  dataIntegration = {
                                    "remitente": {
                                      "nombre":
                                          "${sharedPrefs!.getString("NameComercialSeller")}",
                                      // "${sharedPrefs!.getString("NameComercialSeller")}-${data['numero_orden'].toString()}",
                                      "telefono": "",
                                      // "telefono": sharedPrefs!
                                      //     .getString("seller_telefono"),
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
                                    "contenido": contenidoProd,
                                    // "$contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}",
                                    "observacion":
                                        "${sharedPrefs!.getString("NameComercialSeller")}-${response['numero_orden'].toString()} ${_observacion.text}",
                                    "fecha": formattedDateTime,
                                    "declarado":
                                        double.parse(priceTotal).toString(),
                                    "con_recaudo": recaudo ? true : false,
                                    "apertura": allowApertura ? true : false,
                                  };
                                  print(jsonEncode(dataIntegration));

                                  //send Gintra
                                  // /*
                                  print("send Gintra");
                                  var responseGintra = await Connections()
                                      .postOrdersGintra(dataIntegration);
                                  print("responseInteg");
                                  print(responseGintra);

                                  if (responseGintra != [] &&
                                      responseGintra != 2) {
                                    bool statusError = responseGintra['error'];

                                    if (statusError) {
                                      //eliminar relacion de pedidoCarrier
                                      await Connections()
                                          .deleteOrderCarrierExternal(
                                              response['id']);

                                      // ignore: use_build_context_synchronously
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
                                        btnOkOnPress: () async {
                                          Navigator.pop(context);
                                        },
                                        btnCancelOnPress: () async {},
                                      ).show();
                                    } else {
                                      await Connections()
                                          .UpdateOrderCarrierbyOrder(
                                              response['id'], {
                                        "external_id": responseGintra['guia']
                                      });

                                      var responseConf = await Connections()
                                          .updateOrderWithTime(
                                        response['id'].toString(),
                                        "estado_interno:CONFIRMADO",
                                        sharedPrefs!.getString("id"),
                                        "",
                                        {
                                          "carrier":
                                              "ext:${selectedCarrierExternal.toString().split("-")[1]}"
                                        },
                                      );

                                      if (response == 0) {
                                        //enviar email
                                        await Connections()
                                            .sendEmailConfirmedProvider(
                                          response['id'].toString(),
                                        );
                                      }

                                      var _url = Uri.parse(
                                        """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $labelProducto${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
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
                                  //
                                }
                              }
                            } else {
                              if (response != 1 || response != 2) {
                                //enviar email
                                await Connections().sendEmailConfirmedProvider(
                                  response['id'].toString(),
                                );
                              }
                              var _url = Uri.parse(
                                """https://api.whatsapp.com/send?phone=${_telefono.text}&text=Hola ${_nombre.text}, le saludo de la tienda $comercial, Me comunico con usted para confirmar su pedido de compra de: $labelProducto${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}, por un valor total de: \$$priceTotal. Su dirección de entrega será: ${_direccion.text}. Es correcto...? ¿Quiere más información del producto?""",
                              );

                              if (!await launchUrl(_url)) {
                                throw Exception('Could not launch $_url');
                              }

                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          }
                          // */
                        }
                      }
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
                "ACEPTAR",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ListView _sectionDataMobile(BuildContext context) {
    //
    double screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      padding: const EdgeInsets.only(right: 20),
      children: [
        const Text(
          "DATOS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
          maxLines: null,
          readOnly: true,
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
        //simple
        Visibility(
          visible: widget.product.isvariable == 0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                height: 40,
                child: SpinBox(
                  min: 1,
                  max: 100,
                  value: quantity,
                  onChanged: (value) {
                    setState(() {
                      quantity = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buttonAddSimple(context),
            ],
          ),
        ),
        // variant
        const SizedBox(height: 10),
        TextField(
          style: const TextStyle(fontWeight: FontWeight.bold),
          controller: _productoE,
          readOnly: true,
          maxLines: null,
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
      ],
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
        double.parse(widget.product.price.toString()));

    int idGen = int.parse(generateCombination());

    Map<String, dynamic> variant = {
      "id": idGen,
      "name": widget.product.productId,
      "quantity": quantity,
      "price_w": widget.product.price.toString(),
      "price": priceT.toString(),
      "price_sugg": priceSuggestedProd.toString(),
      "title": widget.product.productName,
      "variant_title": widget.product.isvariable == 1 ? variantTitle : null,
      "sku": "${variantFound?['sku']}C${widget.product.productId}",
    };

    return variant;
  }

  Future<Map<String, dynamic>> genVariantDataExtraProd() async {
    //
    int idGen = int.parse(generateCombination());

    //123S|S
    double priceT = (int.parse(quantityExtraProd.toString()) *
        double.parse(selectedExtraProd!.split('|')[4].toString()));

    Map<String, dynamic> variant = {};
    if (isVariableExtraProd) {
      variant = {
        "id": idGen,
        "name": selectedExtraProd!.split('|')[0],
        "quantity": quantityExtraProd,
        "price_w": selectedExtraProd!.split('|')[4].toString(),
        "price": priceT.toString(),
        "price_sugg": chozenVariantExtraProd!.split('|')[2].toString(),
        // "price_sugg": selectedExtraProd!.split('|')[6],
        "title": selectedExtraProd!.split('|')[3],
        "variant_title": chozenVariantExtraProd?.split('|')[1],
        "sku":
            "${chozenVariantExtraProd?.split('|')[0]}C${selectedExtraProd!.split('|')[0]}",
      };
    } else {
      //
      variant = {
        "id": idGen,
        "name": selectedExtraProd!.split('|')[0],
        "quantity": quantityExtraProd,
        "price_w": selectedExtraProd!.split('|')[4].toString(),
        "price": priceT.toString(),
        "price_sugg": selectedExtraProd!.split('|')[6].toString(),
        "title": selectedExtraProd!.split('|')[3],
        "variant_title": null,
        "sku":
            "${selectedExtraProd!.split('|')[1]}C${selectedExtraProd!.split('|')[0]}",
      };
    }

    return variant;
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

  String buildVariantsDetailsText(List<dynamic> dataVariantDetailsUniques) {
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

  String generateCombination() {
    const fixedNumber = 1301;
    final random = Random();
    final randomNumber = random.nextInt(900000000) + 100000000;
    return '$fixedNumber$randomNumber';
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

  void calculateTotalQuantity() async {
    int total = 0;
    double totalPriceSugg = 0;

    for (var detalle in variantsDetailsList) {
      if (detalle.containsKey('quantity') &&
          detalle.containsKey('price_sugg')) {
        int quantity = int.parse(detalle['quantity'].toString());
        double priceSugg = double.parse(detalle['price_sugg'].toString());

        // Calcula el total del precio sugerido
        totalPriceSugg += (quantity * priceSugg);

        // Suma la cantidad total
        total += quantity;
      }
    }

    setState(() {
      quantityTotal = total;

      //upt Precio DropShipping
      // double priceDSTotal = priceSuggestedProd * quantityTotal;
      double priceDSTotal = totalPriceSugg;

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

  ElevatedButton _buttonAddSimple(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        bool existVariant = false;

        for (var variant in variantsDetailsList) {
          String skuV = variant['sku'];
          int lastIndex = skuV.lastIndexOf("C");
          String justsku = skuV.substring(0, lastIndex);

          if (justsku == chosenSku.toString()) {
            existVariant = true;
            break;
          }
        }
        if (!existVariant) {
          // print("NO existVariant");

          var variant = await generateVariantData(chosenSku);
          setState(() {
            variantsDetailsList.add(variant);
          });
        } else {
          //upt
          // print("SI existVariant");

          for (var variant in variantsDetailsList) {
            String skuV = variant['sku'];
            String justsku = skuV.split("C")[0];
            if (justsku == chosenSku.toString()) {
              variant['quantity'] = quantity;
              break;
            }
          }
        }

        calculateTotalWPrice();
        calculateTotalQuantity();

        editLabelExtraProduct =
            checkIfIdMatches(int.parse(widget.product.productId.toString()));
        fillProdProdExtr();

        setState(() {});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Añadir",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  ElevatedButton _buttonAddVariants(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.product.isvariable == 1 && chosenVariant == null
          ? null
          : () async {
              bool existVariant = false;
              for (var variant in variantsDetailsList) {
                String skuV = variant['sku'];
                int lastIndex = skuV.lastIndexOf("C");
                String justsku = skuV.substring(0, lastIndex);

                if (justsku == chosenSku.toString()) {
                  existVariant = true;
                  break;
                }
              }
              if (!existVariant) {
                // print("NO existVariant");

                var variant = await generateVariantData(chosenSku);
                setState(() {
                  variantsDetailsList.add(variant);
                });

                // print("variantsDetailsList");
                // print(variantsDetailsList);
              } else {
                // print("SI existVariant");

                for (var variant in variantsDetailsList) {
                  String skuV = variant['sku'];
                  String justsku = skuV.split("C")[0];
                  if (justsku == chosenSku.toString()) {
                    variant['quantity'] = quantity;
                    break;
                  }
                }
              }
              calculateTotalWPrice();
              calculateTotalQuantity();

              editLabelExtraProduct = checkIfIdMatches(
                  int.parse(widget.product.productId.toString()));
              fillProdProdExtr();

              setState(() {});
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Añadir",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  ElevatedButton _buttonAddExtraProd(BuildContext context) {
    return ElevatedButton(
      onPressed: selectedExtraProd == null ||
              (isVariableExtraProd && chozenVariantExtraProd == null)
          ? null
          : () async {
              // print("$chozenVariantExtraProd");

              try {
                bool existVariant = false;
                for (var variant in variantsDetailsList) {
                  String skuV = variant['sku'];
                  int lastIndex = skuV.lastIndexOf("C");
                  String justsku = skuV.substring(0, lastIndex);

                  if (isVariableExtraProd) {
                    if (justsku ==
                        chozenVariantExtraProd?.split('|')[0].toString()) {
                      existVariant = true;
                      break;
                    }
                  } else {
                    //
                    if (justsku ==
                        selectedExtraProd!.split('|')[1].toString()) {
                      existVariant = true;
                      break;
                    }
                  }
                }
                if (!existVariant) {
                  //
                  var variant = await genVariantDataExtraProd();
                  setState(() {
                    variantsDetailsList.add(variant);
                  });

                  // print("variantsDetailsList");
                  // print(variantsDetailsList);
                } else {
                  // print("SI existVariant");

                  for (var variant in variantsDetailsList) {
                    String skuV = variant['sku'];
                    String justsku = skuV.split("C")[0];
                    double priceT = (int.parse(quantityExtraProd.toString()) *
                        double.parse(
                            selectedExtraProd!.split('|')[4].toString()));
                    if (isVariableExtraProd) {
                      //
                      if (justsku ==
                          chozenVariantExtraProd?.split('|')[0].toString()) {
                        variant['quantity'] = quantityExtraProd;
                        variant['price'] = priceT;
                        break;
                      }
                    } else {
                      //
                      if (justsku ==
                          selectedExtraProd!.split('|')[1].toString()) {
                        variant['quantity'] = quantityExtraProd;
                        variant['price'] = priceT;
                        break;
                      }
                    }
                  }
                }
                calculateTotalWPrice();
                calculateTotalQuantity();

                editLabelExtraProduct = checkIfIdMatches(
                    int.parse(widget.product.productId.toString()));
                fillProdProdExtr();

                setState(() {});
              } catch (e) {
                print("$e");
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
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<dynamic> reorderVariantsDetailsList(int name) {
    print("reorderVariantsDetailsList");
    List<dynamic> sortedList =
        variantsDetailsList.where((item) => item['name'] == name).toList();
    sortedList
        .addAll(variantsDetailsList.where((item) => item['name'] != name));
    return sortedList;
  }

  bool checkIfIdMatches(int id) {
    print("checkIfIdMatches");
    for (var variant in variantsDetailsList) {
      if (int.parse(variant['name'].toString()) != id) {
        print("existinte un prod dif al main");
        return false;
      }
    }
    _productoE.clear();
    print("solo main");
    return true;
  }

  void fillProdProdExtr() async {
    // print(variantsDetailsList);
    // variantsDetailsList = reorderVariantsDetailsList(
    //     int.parse(widget.product.productId.toString()));
    if (variantsDetailsList.isEmpty) {
      _producto.clear();
      _productoE.clear();
      _precioTotalEnt.clear();
      _precioTotalDec.clear();
    } else {
      List<Map<String, dynamic>> groupedProducts =
          groupProducts(variantsDetailsList);
      // print(groupedProducts);

      if (!editLabelExtraProduct) {
        labelProducto =
            '${groupedProducts[0]['name']} ${groupedProducts[0]['variants']}';
        _producto.text = labelProducto;
        // Obtener el resto de los elementos
        List<String> extraProductsList =
            groupedProducts.sublist(1).map((product) {
          return '${product['name']} ${product['variants']}';
        }).toList();
        _productoE.text = extraProductsList.join('\n');

        contenidoProd = buildVariantsDetailsText(variantsDetailsList);
      } else {
        //
        labelProducto =
            '${groupedProducts[0]['name']} ${groupedProducts[0]['variants']}';
        _producto.text = labelProducto;

        contenidoProd = buildVariantsDetailsText(variantsDetailsList);
        contenidoProd =
            "$contenidoProd${_productoE.text.isNotEmpty ? " | ${_productoE.text}" : ""}";
      }

      print('productoP: ${_producto.text}');
      print('productoExtra: ${_productoE.text}');
      //
      print("contenidoProd: $contenidoProd");

      setState(() {});
    }
  }
  //
}
