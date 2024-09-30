import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/reserve_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/text_field_icon.dart';

class ReserveStockAdmin extends StatefulWidget {
  final String prodId;
  final String prodName;
  final int stockPublic;
  final List reserves;
  final List variants;
  final int type;
  final double priceW;
  final String skuGen;

  const ReserveStockAdmin({
    super.key,
    required this.prodId,
    required this.prodName,
    required this.stockPublic,
    required this.reserves,
    required this.variants,
    required this.type,
    required this.priceW,
    required this.skuGen,
  });

  @override
  State<ReserveStockAdmin> createState() => _ReserveStockAdminState();
}

class _ReserveStockAdminState extends State<ReserveStockAdmin> {
  //
  List reservesList = [];
  List variantsList = [];
  int stockPublic = 0;
  int type = 0;
  String? skuGeneral;
  int totalReserves = 0;
  int totalStock = 0;
  double priceW = 0;

  TextEditingController _description = TextEditingController(text: "");

  bool showEdit = false;
  int actionType = 0;
  TextEditingController _quantity = TextEditingController(text: "");
  String? variantToEdit;
  String? sellerNameToEdit;
  String? skuToEdit;
  String? sellerIdToEdit;

  bool showNew = false;
  List<String> variantsToSelect = [];
  String? chosenVariantToReserve;
  TextEditingController _emailNew = TextEditingController(text: "");
  TextEditingController _quantityNew = TextEditingController(text: "");
  List<Map<String, dynamic>> reservasToSend = [];

  @override
  void didChangeDependencies() {
    // Es mejor usar initState para cargar datos si no dependen del contexto
    super.didChangeDependencies();
    loadData(); // Mantener la carga de datos aquí solo si dependen de las dependencias del contexto
  }

  Future<void> loadData() async {
    try {
      // Inicializar variables o cargar datos
      type = widget.type;
      priceW = widget.priceW;
      skuGeneral = widget.skuGen;
      stockPublic = widget.stockPublic;
      reservesList = widget.reserves;
      totalReserves = getTotalReserves(reservesList);
      totalStock = stockPublic + totalReserves;
      variantsList = widget.variants;

      // print(reservesList);
      // print(variantsList);
      // showEdit = true;
      setState(() {});
    } catch (e) {
      print("Error!!!: $e");

      // Si es necesario, asegurarse de que el contexto sigue siendo válido antes de usarlo
      if (mounted) {
        // Mostrar un mensaje de error si algo falla
        SnackBarHelper.showErrorSnackBar(context, "Ha ocurrido un error");
      }
    }
  }

  int getTotalReserves(dynamic reserves) {
    int reserveStock = 0;

    // List<ReserveModel>? reservesList = reserves;
    List<ReserveModel> reservesList = (reserves as List)
        .map(
            (reserve) => ReserveModel.fromJson(reserve as Map<String, dynamic>))
        .toList();
    if (reservesList != null) {
      for (int i = 0; i < reservesList.length; i++) {
        ReserveModel reserve = reservesList[i];

        reserveStock += int.parse(reserve.stock.toString());
      }
    }
    return reserveStock;
  }

  updateData() async {
    print("updateData");
    var response = await Connections().getProductByID(
      widget.prodId.toString(),
      ["reserve.seller"],
    );
    var data = response;
    // print(data);
    priceW = data['price'];
    skuGeneral = getValue(jsonDecode(data['features']), "sku");
    // print(skuGeneral);

    stockPublic = data['stock'];
    reservesList = data['reserve'];
    totalReserves = getTotalReserves(reservesList);
    totalStock = stockPublic + totalReserves;
    variantsList = getValue(jsonDecode(data['features']), "variants");

    setState(() {});
  }

  dynamic getValue(Map<String, dynamic> features, String key) {
    try {
      dynamic value = features[key];

      return value;
    } catch (e) {
      print("Error al obtener '$key': $e");
      return null;
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.65,
            color: Colors.white,
            child: Column(
              children: [
                Center(
                  child: Text(
                    "${widget.prodId} ${widget.prodName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Stock Total: ${totalStock.toString()}    Stock Reserva: ${totalReserves.toString()}    Stock Público: ${stockPublic.toString()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Container(
                    width: screenWidth * 0.70,
                    height: screenHeight * 0.20,
                    child: DataTable2(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      dataRowColor: MaterialStateColor.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.blue.withOpacity(0.5);
                        } else if (states.contains(MaterialState.hovered)) {
                          return const Color.fromARGB(255, 234, 241, 251);
                        }
                        return const Color.fromARGB(0, 173, 233, 231);
                      }),
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                      dataTextStyle: const TextStyle(color: Colors.black),
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 800,
                      columns: getColumns(),
                      rows: buildDataRows(reservesList),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (showEdit)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: screenWidth * 0.50,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: screenWidth * 0.4,
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () {
                                    showEdit = false;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                            Center(
                              child: Text("$variantToEdit - $sellerNameToEdit"),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: TextFieldIcon(
                                    controller: _quantity,
                                    labelText: "Cantidad",
                                    inputType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    icon: Icons.numbers,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFieldIcon(
                                    controller: _description,
                                    labelText: "Descripción",
                                    maxLines: 2,
                                    icon: Icons.description,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  //btn_Agregar_Quitar
                                  onPressed: () async {
                                    //

                                    bool ready = true;

                                    if (_quantity.text.isEmpty) {
                                      ready = false;
                                      showSuccessModal(
                                          context,
                                          "Por favor, ingrese una cantidad",
                                          Icons8.warning_1);
                                    }
                                    if (_description.text.isEmpty) {
                                      ready = false;
                                      showSuccessModal(
                                          context,
                                          "Por favor, ingrese una descripción",
                                          Icons8.warning_1);
                                    }
                                    if (ready) {
                                      //
                                      getLoadingModal(context, false);

                                      if (actionType == 1) {
                                        print("_add");

                                        var response = await Connections()
                                            .adminReserveStockHistory(
                                          widget.prodId.toString(), //prodId
                                          skuToEdit.toString(), //sku
                                          _quantity.text.toString(), //units
                                          sellerIdToEdit
                                              .toString(), //id_SellerMaster
                                          _description.text, //description
                                          "1",
                                        );

                                        if (mounted) {
                                          Navigator.pop(context);
                                        }

                                        if (response == 0) {
                                          print("successful");
                                          _quantity.clear();
                                          _description.clear();
                                          showEdit = false;
                                          await updateData();

                                          setState(() {});
                                        } else if (response == 3) {
                                          if (mounted) {
                                            showSuccessModal(
                                                context,
                                                "Error en la solicitud. Stock insuficiente",
                                                Icons8.warning_1);
                                          }
                                        } else {
                                          print("error");

                                          if (mounted) {
                                            showSuccessModal(
                                                context,
                                                "Error en la solicitud.",
                                                Icons8.warning_1);
                                          }
                                        }
                                      } else if (actionType == 0) {
                                        print("_remove");
                                        var response = await Connections()
                                            .adminReserveStockHistory(
                                          widget.prodId.toString(), //prodId
                                          skuToEdit.toString(), //sku
                                          _quantity.text.toString(), //units
                                          sellerIdToEdit
                                              .toString(), //id_SellerMaster
                                          _description.text, //description
                                          "0",
                                        );

                                        if (mounted) {
                                          Navigator.pop(context);
                                        }

                                        if (response == 0) {
                                          print("successful");
                                          _quantity.clear();
                                          _description.clear();
                                          showEdit = false;
                                          await updateData();

                                          setState(() {});
                                        } else {
                                          print("error");

                                          if (mounted) {
                                            showSuccessModal(
                                                context,
                                                "Error en la solicitud.",
                                                Icons8.warning_1);
                                          }
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text(
                                    actionType == 1 ? "Agregar" : "Quitar",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),
          if (showNew)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: screenWidth * 0.60,
                  // height: screenHeight * 0.20,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: screenWidth * 0.55,
                        padding: const EdgeInsets.all(5),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () {
                                      showNew = false;
                                      variantsToSelect = [];

                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                              const Center(
                                child: Text("Nueva reserva"),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Visibility(
                                    visible: type == 1,
                                    child: Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Variable'),
                                          const SizedBox(height: 3),
                                          SizedBox(
                                            width: 250,
                                            child:
                                                DropdownButtonFormField<String>(
                                              isExpanded: true,
                                              hint: Text(
                                                'Seleccione Variante',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Theme.of(context)
                                                      .hintColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              items:
                                                  variantsToSelect.map((item) {
                                                return DropdownMenuItem(
                                                  value: item,
                                                  child: Text(
                                                    item.split("|")[1],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              value: chosenVariantToReserve,
                                              onChanged: (value) {
                                                setState(() {
                                                  chosenVariantToReserve =
                                                      value as String;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 130,
                                    child: TextFieldIcon(
                                      controller: _quantityNew,
                                      labelText: "Cantidad",
                                      inputType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      icon: Icons.numbers,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFieldIcon(
                                      controller: _emailNew,
                                      labelText: "Correo",
                                      icon: Icons.email,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      //
                                      bool ready = true;

                                      if (_emailNew.text.isNotEmpty &&
                                          _quantityNew.text.isNotEmpty) {
                                        if (_emailNew.text.isNotEmpty &&
                                            !_emailNew.text.contains('@')) {
                                          ready = false;
                                          showSuccessModal(
                                              context,
                                              "Por favor, ingrese un correo electrónico válido.",
                                              Icons8.warning_1);
                                        }

                                        if (ready) {
                                          getLoadingModal(context, false);

                                          String id_comercial = "";

                                          var response = await Connections()
                                              .getPersonalInfoAccountByEmail(
                                                  _emailNew.text.toString());
                                          if (response != 1 || response != 2) {
                                            //
                                            id_comercial =
                                                response['vendedores'][0]
                                                    ['id_master'];

                                            //
                                            if (type == 0) {
                                              // chosenVariantToReserve =
                                              //     reservesList[0]['sku'];
                                              chosenVariantToReserve =
                                                  skuGeneral;
                                            }
                                            print(
                                                "chosenVariantToReserve: $chosenVariantToReserve");

                                            var responseNewRes =
                                                await Connections()
                                                    .createReserve(
                                              widget.prodId.toString(), //prodId
                                              chosenVariantToReserve
                                                  ?.split("|")[0]
                                                  .toString(), //sku
                                              _quantityNew.text.toString(),
                                              id_comercial.toString(),
                                              priceW.toString(),
                                            );

                                            if (mounted) {
                                              Navigator.pop(context);
                                            }

                                            if (responseNewRes == 0) {
                                              print("successful");
                                              _quantityNew.clear();
                                              _emailNew.clear();
                                              showNew = false;
                                              await updateData();

                                              setState(() {});
                                            } else if (responseNewRes == 3) {
                                              if (mounted) {
                                                showSuccessModal(
                                                    context,
                                                    "Error en la solicitud. Stock insuficiente",
                                                    Icons8.warning_1);
                                              }
                                            } else if (responseNewRes == 4) {
                                              if (mounted) {
                                                showSuccessModal(
                                                    context,
                                                    "Error en la solicitud. Reserva ya existente",
                                                    Icons8.warning_1);
                                              }
                                            } else {
                                              print("error");

                                              if (mounted) {
                                                showSuccessModal(
                                                    context,
                                                    "Error en la solicitud.",
                                                    Icons8.warning_1);
                                              }
                                            }
                                            /*
                                              var response = await Connections()
                                                  .adminReserveStockHistory(
                                                widget.prodId
                                                    .toString(), //prodId
                                                skuToEdit.toString(), //sku
                                                _quantity.text
                                                    .toString(), //units
                                                sellerIdToEdit
                                                    .toString(), //id_SellerMaster
                                                _description.text, //description
                                                "4", //new
                                              );
                                              if (response == 0) {
                                                print("successful");
                                                _quantity.clear();
                                                _description.clear();
                                                showEdit = false;
                                                setState(() {});
                                              } else {
                                                print("error");
                                              }
                                              */
                                          } else if (response == []) {
                                            if (mounted) {
                                              Navigator.pop(context);
                                            }
                                            print(
                                                "Error no existe este email o no tiene una tienda relacionada");
                                          } //
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text(
                                      "Reservar",
                                    ),
                                  ),
                                ],
                              ),
                              /*
                                Row(
                                  children: [
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children:
                                          reservasToSend.map<Widget>((reserva) {
                                        String chipLabel =
                                            "SKU: ${reserva['sku']}";

                                        // Asegúrate de que la clave 'email' exista en el mapa antes de intentar acceder
                                        if (reserva.containsKey('email')) {
                                          chipLabel +=
                                              " - Correo: ${reserva['email']}";
                                        }
                                        if (reserva.containsKey('stock')) {
                                          chipLabel +=
                                              " - Cantidad: ${reserva['stock']}";
                                        }

                                        return Chip(
                                          label: Text(chipLabel),
                                          onDeleted: () {
                                            setState(() {
                                              reservasToSend.remove(reserva);
                                            });
                                            print(
                                                "reservasToSend actualizado:");
                                            print(reservasToSend);
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              */
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      //_btn_add_new
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //
          variantsToSelect = [];
          buildVariantsToSelect(variantsList);
          setState(() {
            showNew = true;
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      const DataColumn2(
        label: Text('Correo'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Tienda'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Producto'),
        size: ColumnSize.L,
      ),
      const DataColumn2(
        label: Text('Cantidad'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Agregar'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Quitar'),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text(''),
        size: ColumnSize.S, //btnEliminar
      ),
    ];
  }

  List<DataRow> buildDataRows(List reservas) {
    List<DataRow> rows = [];

    for (var reserva in reservas) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Text(
              reserva['seller']['email'] ?? 'No disponible',
            ),
          ),
          DataCell(
            Text(
              // reserva['seller']['username'] ?? 'No disponible',
              reserva['seller']['vendor']['nombre_comercial'] ??
                  'No disponible',
            ),
          ),
          DataCell(
            Text(
              getName(reserva['sku']),
            ),
          ),
          DataCell(
            Text(
              reserva['stock'].toString(),
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () async {
                // Acción para agregar
                showEdit = true;
                actionType = 1;
                skuToEdit = reserva['sku'];
                sellerIdToEdit = reserva['id_comercial'].toString();
                variantToEdit = getName(reserva['sku']);
                // sellerToEdit = reserva['seller']['email'];
                sellerNameToEdit = reserva['seller']['vendor']
                        ['nombre_comercial'] ??
                    'No disponible';

                _quantity.clear();
                _description.clear();
                setState(() {});
              },
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: Colors.blue,
              ),
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () async {
                // Acción para quitar
                showEdit = true;
                actionType = 0;
                skuToEdit = reserva['sku'];
                sellerIdToEdit = reserva['id_comercial'].toString();
                variantToEdit = getName(reserva['sku']);
                sellerNameToEdit = reserva['seller']['vendor']
                        ['nombre_comercial'] ??
                    'No disponible';

                _quantity.clear();
                _description.clear();
                setState(() {});
              },
              child: const Icon(
                Icons.minimize_rounded,
                size: 20,
                color: Colors.red,
              ),
            ),
          ),
          DataCell(
            ElevatedButton(
              onPressed: () async {
                variantToEdit = getName(reserva['sku']);
                sellerNameToEdit = reserva['seller']['vendor']
                        ['nombre_comercial'] ??
                    'No disponible';

                AwesomeDialog(
                  width: 500,
                  context: context,
                  dialogType: DialogType.info,
                  animType: AnimType.rightSlide,
                  title: '¿Estás seguro de eliminar la Reserva?',
                  desc: '$variantToEdit - $sellerNameToEdit',
                  btnOkText: "Confirmar",
                  btnCancelText: "Cancelar",
                  btnOkColor: Colors.blueAccent,
                  btnCancelOnPress: () {},
                  btnOkOnPress: () async {
                    getLoadingModal(context, false);
                    skuToEdit = reserva['sku'];

                    print(skuToEdit);
                    sellerIdToEdit = reserva['id_comercial'].toString();

                    var response = await Connections().adminReserveStockHistory(
                      widget.prodId.toString(), //prodId
                      skuToEdit.toString(), //sku
                      "0", //units
                      sellerIdToEdit.toString(), //id_SellerMaster
                      "0", //description
                      "3",
                    );

                    if (response == 0) {
                      print("successful");

                      await updateData();

                      if (mounted) {
                        Navigator.pop(context);
                      }
                      setState(() {});
                    } else {
                      print("error");

                      if (mounted) {
                        showSuccessModal(context, "Error en la solicitud.",
                            Icons8.warning_1);
                      }
                    }
                  },
                ).show();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Eliminar',
              ),
            ),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  String getName(String sku) {
    String productName = "";

    if (type == 0) {
      productName = widget.prodName;
    } else {
      for (var variant in variantsList) {
        if (variant['sku'] == sku) {
          String nameVariantTitle = buildVariantTitle(variant);
          productName = "${widget.prodName} $nameVariantTitle";
          break;
        }
      }
    }
    return productName;
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

  //
}
