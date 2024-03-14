import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';

class InfoCarrierExternal extends StatefulWidget {
  final Map data;

  const InfoCarrierExternal({super.key, required this.data});

  @override
  State<InfoCarrierExternal> createState() => _InfoCarrierExternalState();
}

class _InfoCarrierExternalState extends State<InfoCarrierExternal> {
  bool isLoading = false;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController mailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");

  List<String> provinciasToSelect = [];
  String? selectedProvincia;
  List<String> parroquiasToSelect = [];
  String? selectedParroquia;

  List coveragesList = [];
  List statusList = [];
  var data = [];

  final formKey = GlobalKey<FormState>();

  //costos
  TextEditingController localLocalNormalController =
      TextEditingController(text: "");
  TextEditingController localLocalEspecialController =
      TextEditingController(text: "");
  TextEditingController localProvinciaNormalController =
      TextEditingController(text: "");
  TextEditingController localProvinciaEspecialController =
      TextEditingController(text: "");
  TextEditingController costoDevolucionController =
      TextEditingController(text: "");
  TextEditingController costoBaseController = TextEditingController(text: "");
  TextEditingController maxPriceController = TextEditingController(text: "");
  TextEditingController incrementalController = TextEditingController(text: "");
  TextEditingController costoSeguroController = TextEditingController(text: "");
  Map<String, dynamic> costsRes = {};

  TextEditingController newIdController = TextEditingController(text: "");
  TextEditingController newEstadoController = TextEditingController(text: "");
  List<String> statusToSelect = [
    "CONFIRMADO-estado_interno",
    //
    "IMPRESO-estado_logistico",
    "ENVIADO-estado_logistico",
    "RECHAZADO-estado_logistico",
    //
    'PEDIDO PROGRAMADO-status',
    'EN RUTA-status',
    'ENTREGADO-status',
    'NO ENTREGADO-status',
    'REAGENDADO-status',
    'EN OFICINA-status',
    'NOVEDAD-status',
    'NOVEDAD RESUELTA-status',
    //
    "DEVOLUCION EN RUTA-estado_devolucion",
    "EN BODEGA-estado_devolucion",
    "ENTREGADO EN OFICINA-estado_devolucion",
    "EN BODEGA PROVEEDOR-estado_devolucion",
  ];
  String? selectedStatus;

  List<String> typesToSelect = [];
  String? selectedType;
  String? selectedProvinciaNewC;

  TextEditingController newIdCiudadController = TextEditingController(text: "");
  TextEditingController newCiudadController = TextEditingController(text: "");
  TextEditingController newIdProvController = TextEditingController(text: "");

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      setState(() {
        isLoading = true;
        provinciasToSelect = [];
        parroquiasToSelect = [];
      });
      //
      var provinciasList = [];

      provinciasList = await Connections().getProvincias();
      for (var i = 0; i < provinciasList.length; i++) {
        provinciasToSelect.add('${provinciasList[i]}');
      }

      // data = widget.data;
      // print("${widget.data['id']}");
      var response =
          await Connections().getCarrierExternalById(widget.data['id']);
      data = response['data'];
      // print(data);
      // print(data[0]['status'].runtimeType);
      setState(() {
        nameController.text = data[0]['name'].toString();
        mailController.text = data[0]['email'].toString();
        phoneController.text = data[0]['phone'].toString();
        addressController.text = data[0]['address'].toString();
        coveragesList = data[0]['carrier_coverages'];
        statusList = jsonDecode(data[0]['status']);
        costsRes = jsonDecode(data[0]['costs']);
        localLocalNormalController.text = costsRes["local_local_normal"];
        localLocalEspecialController.text = costsRes["local_local_especial"];
        localProvinciaNormalController.text =
            costsRes["local_provincia_normal"];
        localProvinciaEspecialController.text =
            costsRes["local_provincia_especial"];
        costoDevolucionController.text = costsRes["costo_devolucion"];
        costoSeguroController.text = costsRes["costo_seguro"];
        costoBaseController.text = costsRes["costo_recaudo"]["base"];
        maxPriceController.text = costsRes["costo_recaudo"]["max_price"];
        incrementalController.text = costsRes["costo_recaudo"]["incremental"];
      });

      List<dynamic> types = jsonDecode(data[0]['type_coverage']);
      typesToSelect = types.map((dynamic item) => item.toString()).toList();

      //
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // print("error!!!:  $e");

      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error al cargar las Subrutas");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWith > 600 ? screenWith * 0.8 : screenWith,
      height: screenHeight * 0.95,
      color: Colors.white,
      child: Form(
        key: formKey,
        child: CustomProgressModal(
          isLoading: isLoading,
          content: ListView(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),
                  const Text(
                    "Información",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWith * 0.3,
                        // color: Colors.amber,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFieldWithIcon(
                              controller: nameController,
                              labelText: 'Nombre Transportadora',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 10),
                            TextFieldWithIcon(
                              controller: phoneController,
                              labelText: 'Número de Teléfono',
                              icon: Icons.phone_in_talk,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+]')),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFieldWithIcon(
                              controller: mailController,
                              labelText: 'Correo',
                              icon: Icons.mail,
                            ),
                            const SizedBox(height: 10),
                            TextFieldWithIcon(
                              controller: addressController,
                              labelText: 'Direccion',
                              icon: Icons.location_on,
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(width: 20),
                      Container(
                        width: screenWith * 0.4,
                        // color: Colors.blue,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Costo por entrega: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Local-Local Normal",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: TextFieldWithIcon(
                                        controller: localLocalNormalController,
                                        labelText: "",
                                        icon: Icons.monetization_on,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    const Text(
                                      "Local-Local Especial",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: TextFieldWithIcon(
                                        controller:
                                            localLocalEspecialController,
                                        labelText: "",
                                        icon: Icons.monetization_on,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Local-Provincial Normal",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: TextFieldWithIcon(
                                        controller:
                                            localProvinciaNormalController,
                                        labelText: "",
                                        icon: Icons.monetization_on,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    const Text(
                                      "Local-Provincial Especial",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: TextFieldWithIcon(
                                        controller:
                                            localProvinciaEspecialController,
                                        labelText: "",
                                        icon: Icons.monetization_on,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Costo Devolucion %",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Flexible(
                                    child: const Text(
                                      "Costo envio + (Costo.dev % del Costo envio)",
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: 120,
                                  child: TextFieldWithIcon(
                                    controller: costoDevolucionController,
                                    labelText: "",
                                    icon: Icons.percent,
                                  ),
                                ),

                                // const SizedBox(width: 20),
                                // Column(
                                //   children: [
                                //     const Text(
                                //       "Costo seguro %",
                                //       style: TextStyle(fontSize: 12),
                                //     ),
                                //     const Text(
                                //       "Costo.seg % del Precio total",
                                //       style: TextStyle(fontSize: 11),
                                //     ),
                                //     SizedBox(
                                //       width: 120,
                                //       child: TextFieldWithIcon(
                                //         controller: costoSeguroController,
                                //         labelText: "",
                                //         icon: Icons.percent,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Costo seguro %",
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Costo.seg % del Precio total",
                                  style: TextStyle(fontSize: 11),
                                ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width: 120,
                                  child: TextFieldWithIcon(
                                    controller: costoSeguroController,
                                    labelText: "",
                                    icon: Icons.percent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 20),
                                Text(
                                  "Costo Recaudo: ",
                                ),
                              ],
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(width: 20),
                                Flexible(
                                  child: Text(
                                    "Menor/igual a Precio.max aplica Costo base. Mayor a Precio.max aplica Costo Icrem. % del Precio Total",
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      "Precio Maximo",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: TextFieldWithIcon(
                                        controller: maxPriceController,
                                        labelText: "",
                                        icon: Icons.monetization_on,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  children: [
                                    const Text(
                                      "Costo base",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: TextFieldWithIcon(
                                        controller: costoBaseController,
                                        labelText: "",
                                        icon: Icons.monetization_on,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ),
                                    const Text(
                                      "Costo Icremental %",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: 120,
                                      child: TextFieldWithIcon(
                                        controller: incrementalController,
                                        labelText: "",
                                        icon: Icons.percent,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9.]')),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(200, 40)),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // getLoadingModal(context, false);
                          // print(mailController.text);
                          if (!mailController.text.contains('@')) {
                            showSuccessModal(
                                context,
                                "Por favor, ingrese un correo electrónico válido.",
                                Icons8.warning_1);
                          } else {
                            // print(
                            //     "Con búsqueda en la base de datos no encontró este correo. Puede crear un usuario");
                            getLoadingModal(context, false);

                            String phoneNumber = phoneController.text;
                            if (phoneNumber.startsWith("0")) {
                              phoneNumber = "+593${phoneNumber.substring(1)}";
                            }

                            var costsToSendUpdt = {
                              "local_local_normal":
                                  localLocalNormalController.text != ""
                                      ? localLocalNormalController.text
                                      : 0,
                              "local_local_especial":
                                  localLocalEspecialController.text != ""
                                      ? localLocalEspecialController.text
                                      : 0,
                              "local_provincia_normal":
                                  localProvinciaNormalController.text != ""
                                      ? localProvinciaNormalController.text
                                      : 0,
                              "local_provincia_especial":
                                  localProvinciaEspecialController.text != ""
                                      ? localProvinciaEspecialController.text
                                      : 0,
                              "costo_devolucion":
                                  costoDevolucionController.text != ""
                                      ? costoDevolucionController.text
                                      : 0,
                              "costo_seguro": costoSeguroController.text != ""
                                  ? costoSeguroController.text
                                  : 0,
                              "costo_recaudo": {
                                "base": costoBaseController.text != ""
                                    ? costoBaseController.text
                                    : 0, //ctvs fijos
                                "max_price": maxPriceController.text != ""
                                    ? maxPriceController.text
                                    : 0,
                                "incremental": incrementalController.text != ""
                                    ? incrementalController.text
                                    : 0 // %
                              },
                            };

                            var responseUpt = await Connections()
                                .updateCarrier(widget.data['id'], {
                              "name": nameController.text,
                              "phone": phoneNumber,
                              "email": mailController.text,
                              "address": addressController.text,
                              "costs": json.encode(costsToSendUpdt),
                            });

                            if (responseUpt == 0) {
                              Navigator.pop(context);
                              // ignore: use_build_context_synchronously
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.success,
                                animType: AnimType.rightSlide,
                                title: 'Completado',
                                desc: 'Se actualizo con exito.',
                                btnCancel: Container(),
                                btnOkText: "Aceptar",
                                btnOkColor: colors.colorGreen,
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {
                                  // Navigator.pop(context);
                                },
                              ).show();
                            } else {
                              Navigator.pop(context);
                              // ignore: use_build_context_synchronously
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.rightSlide,
                                title: 'Error',
                                desc: 'Intentelo de nuevo',
                                btnCancel: Container(),
                                btnOkText: "Aceptar",
                                btnOkColor: colors.colorGreen,
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {},
                              ).show();
                            }
                            //
                          }
                          //
                        }
                        //
                      },
                      child: const Text(
                        "Guardar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Estados Equivalentes:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () async {
                          //
                          showAddNewStatus();
                        },
                        child: const Text(
                          "Agregar Nuevo Estado Equivalente",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: screenHeight * 0.40,
                    width: screenWith * 0.55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: DataTable2(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
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
                      columns: getColumnsStatus(),
                      rows: buildDataRowsStatus(statusList),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Cobertura:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "Total Ciudades: ${coveragesList.length.toString()}"),
                      const SizedBox(width: 10),
                      /*
                      SizedBox(
                        width: screenWith * 0.3,
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

                                loadData();
                              });
                            },

                            //This to clear the search value when you close the menu
                            onMenuStateChange: (isOpen) {
                              if (!isOpen) {}
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      */
                      TextButton(
                        onPressed: () async {
                          //
                          showAddNewCoverage();
                        },
                        child: const Text(
                          "Agregar Nueva Cobertura",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: screenHeight * 0.40,
                    width: screenWith * 0.55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    // child: DataTableModelPrincipal(
                    //   columnWidth: 200,
                    //   columns: getColumns(),
                    //   rows: buildDataRows(coveragesList),
                    // ),
                    child: DataTable2(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
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
                      headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                      dataTextStyle: const TextStyle(color: Colors.black),
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 800,
                      columns: getColumns(),
                      rows: buildDataRows(coveragesList),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  List<DataColumn2> getColumnsStatus() {
    return [
      DataColumn2(
        label: Text('ID'),
        size: ColumnSize.S,
        fixedWidth: 80,
      ),
      DataColumn2(
        label: Text('Status Externo'),
        size: ColumnSize.M,
        fixedWidth: 200,
      ),
      DataColumn2(
        label: Text('Status Easy'),
        size: ColumnSize.S,
        fixedWidth: 200,
      ),
      DataColumn2(
        label: Text('Area'),
        size: ColumnSize.S,
        fixedWidth: 200,
      ),
    ];
  }

  List<DataRow> buildDataRowsStatus(List dataL) {
    dataL;

    List<DataRow> rows = [];
    for (int index = 0; index < dataL.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Text(
              statusList != [] ? dataL[index]['id'].toString() : "",
            ),
          ),
          DataCell(
            Text(
              statusList != [] ? dataL[index]['name'].toString() : "",
            ),
          ),
          DataCell(
            Text(
              statusList != [] ? dataL[index]['name_local'].toString() : "",
            ),
          ),
          DataCell(
            Text(
              statusList != [] ? dataL[index]['estado'].toString() : "",
            ),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  List<DataColumn2> getColumns() {
    return [
      DataColumn2(
        label: Text('ID'),
        size: ColumnSize.S,
        fixedWidth: 80,
      ),
      DataColumn2(
        label: Text('Provincia'),
        size: ColumnSize.M,
        fixedWidth: 180,
      ),
      DataColumn2(
        label: Text('ID'),
        size: ColumnSize.S,
        fixedWidth: 80,
      ),
      DataColumn2(
        label: Text("Ciudad"),
        size: ColumnSize.S,
        fixedWidth: 180,
      ),
      DataColumn2(
        label: Text('Tipo'),
        size: ColumnSize.S,
        fixedWidth: 150,
      ),
    ];
  }

  List<DataRow> buildDataRows(List dataL) {
    dataL;

    List<DataRow> rows = [];
    for (int index = 0; index < dataL.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Text(
              coveragesList != [] ? dataL[index]['id_prov_ref'].toString() : "",
            ),
          ),
          DataCell(
            Text(
              coveragesList != []
                  ? dataL[index]['coverage_external']['dpa_provincia']
                          ['provincia']
                      .toString()
                  : "",
            ),
          ),
          DataCell(
            Text(
              coveragesList != []
                  ? dataL[index]['id_ciudad_ref'].toString()
                  : "",
            ),
          ),
          DataCell(
            Text(
              coveragesList != []
                  ? dataL[index]['coverage_external']['ciudad'].toString()
                  : "",
            ),
          ),
          DataCell(
            Text(
              coveragesList != [] ? dataL[index]['type'].toString() : "",
            ),
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  Future<dynamic> showAddNewStatus() {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          contentPadding: EdgeInsets.all(0),
          content: Container(
            width: 500,
            height: 400,
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: ListView(
              children: [
                const Text(
                  "Nuevo Estado Equivalente",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 250,
                          child: TextFieldWithIcon(
                            controller: newIdController,
                            labelText: 'ID',
                            icon: Icons.edit,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9+]')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 250,
                          child: TextFieldWithIcon(
                            controller: newEstadoController,
                            labelText: 'Estado',
                            icon: Icons.edit,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 250,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Text(
                                'Estado',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              items: statusToSelect
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
                              value: selectedStatus,
                              onChanged: (value) async {
                                setState(() {
                                  selectedStatus = value as String;
                                });
                                Navigator.pop(context);
                                showAddNewStatus();
                              },

                              //This to clear the search value when you close the menu
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {}
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(200, 40)),
                    onPressed: () async {
                      //
                      var newStatus = {
                        "estado": selectedStatus.toString().split("-")[1],
                        "name_local": selectedStatus.toString().split("-")[0],
                        "id": newIdController.text != ""
                            ? newIdController.text.toString()
                            : 0,
                        "name": newEstadoController.text != ""
                            ? newEstadoController.text.toString()
                            : "",
                      };

                      statusList.add(newStatus);

                      var responseCreate = await Connections().updateCarrier(
                          widget.data['id'],
                          {"status": json.encode(statusList)});

                      if (responseCreate == 0) {
                        setState(() {});
                        Navigator.pop(context);
                        loadData();
                      } else {
                        setState(() {
                          statusList.removeLast();
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Guardar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        // El usuario cerró el diálogo correctamente
        setState(() {
          loadData();
        });
      }
    });
  }

  Future<dynamic> showAddNewCoverage() {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          contentPadding: EdgeInsets.all(0),
          content: Container(
            width: 500,
            height: 500,
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: ListView(
              children: [
                const Text(
                  "Nueva Cobertura",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 250,
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
                              value: selectedProvinciaNewC,
                              onChanged: (value) async {
                                setState(() {
                                  selectedProvinciaNewC = value as String;
                                  String resProv = idProvRef(
                                      selectedProvinciaNewC
                                          .toString()
                                          .split('-')[0]);
                                  newIdProvController.text =
                                      resProv != "-1" ? resProv : "";
                                });
                                Navigator.pop(context);
                                showAddNewCoverage();
                              },

                              //This to clear the search value when you close the menu
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {}
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: TextFieldWithIcon(
                            controller: newIdProvController,
                            labelText: 'ID Provincia',
                            icon: Icons.edit,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: TextFieldWithIcon(
                            controller: newIdCiudadController,
                            labelText: 'ID Ciudad',
                            icon: Icons.edit,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: TextFieldWithIcon(
                            controller: newCiudadController,
                            labelText: 'Ciudad',
                            icon: Icons.edit,
                          ),
                        ),
                        SizedBox(
                          width: 250,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: Text(
                                'Tipo Cobertura',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              items: typesToSelect
                                  .map((item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ))
                                  .toList(),
                              value: selectedType,
                              onChanged: (value) async {
                                setState(() {
                                  selectedType = value as String;
                                });
                                Navigator.pop(context);
                                showAddNewCoverage();
                              },

                              //This to clear the search value when you close the menu
                              onMenuStateChange: (isOpen) {
                                if (!isOpen) {}
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(200, 40)),
                    onPressed: () async {
                      //

                      var responseCreate = await Connections()
                          .createNewCoverage(
                              widget.data['id'],
                              newIdCiudadController.text,
                              newCiudadController.text,
                              newIdProvController.text,
                              selectedProvinciaNewC.toString().split('-')[1],
                              selectedProvinciaNewC.toString().split('-')[0],
                              selectedType.toString());

                      if (responseCreate == 0) {
                        setState(() {});
                        Navigator.pop(context);
                        loadData();
                      } else {
                        setState(() {
                          statusList.removeLast();
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Guardar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        // El usuario cerró el diálogo correctamente
        setState(() {
          loadData();
        });
      }
    });
  }

  String idProvRef(provincia) {
    String res = "";

    String targetProvincia = provincia;
    int targetIdProvRef = coveragesList.firstWhere(
            (element) =>
                element["coverage_external"]["dpa_provincia"]["provincia"] ==
                targetProvincia,
            orElse: () => null)?["id_prov_ref"] ??
        -1;

    print("targetProvincia: $targetProvincia");
    print("resultado: $targetIdProvRef");

    return targetIdProvRef.toString();
  }
}
