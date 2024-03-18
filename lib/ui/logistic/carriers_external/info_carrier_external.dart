import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/logistic/carriers_external/edit_coverage.dart';
import 'package:frontend/ui/logistic/carriers_external/edit_status.dart';
import 'package:frontend/ui/logistic/carriers_external/new_coverage.dart';
import 'package:frontend/ui/logistic/carriers_external/new_status.dart';
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
  bool newProvincia = false;

  final TextEditingController _newTypeController = TextEditingController();

  bool _statusSection = false;
  bool _coverageSection = false;

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
      width: screenWith > 600 ? screenWith * 0.85 : screenWith,
      height: screenHeight * 0.95,
      color: Colors.white,
      child: Form(
        key: formKey,
        child: CustomProgressModal(
          isLoading: isLoading,
          content: ListView(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                  responsive(
                      // web
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWith * 0.3,
                            // color: Colors.amber,
                            padding: const EdgeInsets.all(20),
                            child: _dataGeneral(context),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: screenWith * 0.4,
                            // color: Colors.blue,
                            padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                            child: _dataCostos(context),
                          ),
                        ],
                      ),
                      // mobile
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWith * 0.9,
                            // color: Colors.amber,
                            padding: const EdgeInsets.all(20),
                            child: _dataGeneral(context),
                          ),
                          Container(
                            width: screenWith * 0.9,
                            // color: Colors.blue,
                            padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                            child: _dataCostos(context),
                          ),
                        ],
                      ),
                      context),

                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
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
                  //
                  const SizedBox(height: 20),
                  ExpansionTile(
                    title: Text(
                      "Estados Equivalentes",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorsSystem().mainBlue,
                      ),
                    ),
                    trailing: Icon(_statusSection
                        ? Icons.arrow_drop_down_circle
                        : Icons.arrow_drop_down),
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _statusSection = expanded;
                      });
                    },
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () async {
                              //
                              // showAddNewStatus();
                              showAddStatus();
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
                        height: screenHeight * 0.45,
                        width: screenWith * 0.60,
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
                          dataRowColor:
                              MaterialStateColor.resolveWith((states) {
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
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      "Coberturas",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorsSystem().mainBlue,
                      ),
                    ),
                    trailing: Icon(_coverageSection
                        ? Icons.arrow_drop_down_circle
                        : Icons.arrow_drop_down),
                    onExpansionChanged: (bool expanded) {
                      setState(() {
                        _coverageSection = expanded;
                      });
                    },
                    children: [
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
                              // showAddNewCoverage();
                              showAddCoverage();
                            },
                            child: const Text(
                              "Agregar Nueva Cobertura",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                      responsive(
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              Container(
                                height: screenHeight * 0.45,
                                width: screenWith * 0.50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                ),
                                child: DataTable2(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                      ),
                                    ],
                                  ),
                                  dataRowColor:
                                      MaterialStateColor.resolveWith((states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return Colors.blue.withOpacity(0.5);
                                    } else if (states
                                        .contains(MaterialState.hovered)) {
                                      return const Color.fromARGB(
                                          255, 234, 241, 251);
                                    }
                                    return const Color.fromARGB(
                                        0, 173, 233, 231);
                                  }),
                                  headingTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  dataTextStyle:
                                      const TextStyle(color: Colors.black),
                                  columnSpacing: 12,
                                  horizontalMargin: 12,
                                  minWidth: 800,
                                  columns: getColumns(),
                                  rows: buildDataRows(coveragesList),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            "Nuevo tipo de Cobertura",
                                          ),
                                          const SizedBox(width: 5),
                                          SizedBox(
                                            width: 180,
                                            child: TextFieldWithIcon(
                                              controller: _newTypeController,
                                              labelText: '',
                                              icon: Icons.label,
                                              applyValidator: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo[900],
                                          // minimumSize: Size(200, 40)
                                        ),
                                        onPressed: () async {
                                          //
                                          getLoadingModal(context, false);

                                          if (_newTypeController.text.isEmpty) {
                                            showSuccessModal(
                                                context,
                                                "Por favor, ingrese un tipo.",
                                                Icons8.warning_1);
                                          } else {
                                            var type = _newTypeController.text;

                                            if (!typesToSelect.contains(type)) {
                                              typesToSelect.add(type);
                                              setState(() async {
                                                _newTypeController.clear();

                                                var responseUpt =
                                                    await Connections()
                                                        .updateCarrier(
                                                            widget.data['id']
                                                                .toString(),
                                                            {
                                                      "type_coverage":
                                                          json.encode(
                                                              typesToSelect),
                                                    });
                                                if (responseUpt == 0) {
                                                  Navigator.pop(context);
                                                  // ignore: use_build_context_synchronously
                                                  AwesomeDialog(
                                                    width: 500,
                                                    context: context,
                                                    dialogType:
                                                        DialogType.success,
                                                    animType:
                                                        AnimType.rightSlide,
                                                    title: 'Completado',
                                                    desc:
                                                        'Se actualizo con exito.',
                                                    btnCancel: Container(),
                                                    btnOkText: "Aceptar",
                                                    btnOkColor:
                                                        colors.colorGreen,
                                                    btnCancelOnPress: () {},
                                                    btnOkOnPress: () {
                                                      // Navigator.pop(context);
                                                      loadData();
                                                    },
                                                  ).show();
                                                } else {
                                                  Navigator.pop(context);
                                                  // ignore: use_build_context_synchronously
                                                  AwesomeDialog(
                                                    width: 500,
                                                    context: context,
                                                    dialogType:
                                                        DialogType.error,
                                                    animType:
                                                        AnimType.rightSlide,
                                                    title: 'Error',
                                                    desc: 'Intentelo de nuevo',
                                                    btnCancel: Container(),
                                                    btnOkText: "Aceptar",
                                                    btnOkColor:
                                                        colors.colorGreen,
                                                    btnCancelOnPress: () {},
                                                    btnOkOnPress: () {},
                                                  ).show();
                                                }
                                                //
                                              });
                                            } else {
                                              print("ya esta ");
                                            }
                                          }
                                          // print("typeToSend: $typeToSend");
                                        },
                                        child: const Text(
                                          "Añadir",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: screenWith * 0.2,
                                    height: screenHeight * 0.3,
                                    // color: Colors.amber,
                                    child: ListView.builder(
                                      itemCount: typesToSelect.length,
                                      itemBuilder: (context, index) {
                                        // return Text(typesToSelect[index]);
                                        return Container(
                                          width: 230,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            // color: Colors.deepPurple.shade100,
                                            border: Border.all(
                                              color: Colors.black,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Center(
                                            child: Text(
                                              typesToSelect[index],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                height: screenHeight * 0.50,
                                width: screenWith * 0.7,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                ),
                                child: DataTable2(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                      ),
                                    ],
                                  ),
                                  dataRowColor:
                                      MaterialStateColor.resolveWith((states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return Colors.blue.withOpacity(0.5);
                                    } else if (states
                                        .contains(MaterialState.hovered)) {
                                      return const Color.fromARGB(
                                          255, 234, 241, 251);
                                    }
                                    return const Color.fromARGB(
                                        0, 173, 233, 231);
                                  }),
                                  headingTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                  dataTextStyle:
                                      const TextStyle(color: Colors.black),
                                  columnSpacing: 12,
                                  horizontalMargin: 12,
                                  minWidth: 800,
                                  columns: getColumns(),
                                  rows: buildDataRows(coveragesList),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        "Nuevo tipo de Cobertura",
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: 180,
                                        child: TextFieldWithIcon(
                                          controller: _newTypeController,
                                          labelText: '',
                                          icon: Icons.label,
                                          applyValidator: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo[900],
                                      // minimumSize: Size(200, 40)
                                    ),
                                    onPressed: () async {
                                      //
                                      getLoadingModal(context, false);

                                      if (_newTypeController.text.isEmpty) {
                                        showSuccessModal(
                                            context,
                                            "Por favor, ingrese un tipo.",
                                            Icons8.warning_1);
                                      } else {
                                        var type = _newTypeController.text;

                                        if (!typesToSelect.contains(type)) {
                                          typesToSelect.add(type);
                                          setState(() async {
                                            _newTypeController.clear();

                                            var responseUpt =
                                                await Connections()
                                                    .updateCarrier(
                                                        widget.data['id']
                                                            .toString(),
                                                        {
                                                  "type_coverage": json
                                                      .encode(typesToSelect),
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
                                                  loadData();
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
                                          });
                                        } else {
                                          print("ya esta ");
                                        }
                                      }
                                      // print("typeToSend: $typeToSend");
                                    },
                                    child: const Text(
                                      "Añadir",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: screenWith * 0.7,
                                height: screenHeight * 0.3,
                                // color: Colors.amber,
                                child: ListView.builder(
                                  itemCount: typesToSelect.length,
                                  itemBuilder: (context, index) {
                                    // return Text(typesToSelect[index]);
                                    return Container(
                                      width: 230,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        // color: Colors.deepPurple.shade100,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          typesToSelect[index],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Column _dataGeneral(BuildContext context) {
    return Column(
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
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
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
    );
  }

  Column _dataCostos(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Costo por entrega",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        responsive(
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 230,
                      //      color: Colors.deepPurple.shade100,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Local",
                                    ),
                                    TextSpan(
                                      text: "-Local Especial",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "(Especial 1)",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      child: TextFieldWithIcon(
                        controller: localLocalEspecialController,
                        labelText: "",
                        icon: Icons.monetization_on,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 230,
                      //      color: Colors.deepPurple.shade100,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Local",
                                    ),
                                    TextSpan(
                                      text: "-Provincial Normal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "(Normal 2)",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      child: TextFieldWithIcon(
                        controller: localProvinciaNormalController,
                        labelText: "",
                        icon: Icons.monetization_on,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 230,
                      //      color: Colors.deepPurple.shade100,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Local",
                                    ),
                                    TextSpan(
                                      text: "-Provincial Especial",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "(Especial 2)",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      child: TextFieldWithIcon(
                        controller: localProvinciaEspecialController,
                        labelText: "",
                        icon: Icons.monetization_on,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 230,
                      //      color: Colors.deepPurple.shade100,
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Costo Devolucion %",
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  "Costo envio + (Costo.dev % del Costo envio)",
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 120,
                      child: TextFieldWithIcon(
                        controller: costoDevolucionController,
                        labelText: "",
                        icon: Icons.percent,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 230,
                      // color: Colors.deepPurple.shade100,
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Costo seguro %",
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Costo.seg % del Precio total",
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
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
              ],
            ),
            Column(
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Local",
                      ),
                      TextSpan(
                        text: "-Local Especial",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "(Especial 1)",
                ),
                SizedBox(
                  width: 120,
                  child: TextFieldWithIcon(
                    controller: localLocalEspecialController,
                    labelText: "",
                    icon: Icons.monetization_on,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Local",
                      ),
                      TextSpan(
                        text: "-Provincial Normal",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "(Normal 2)",
                ),
                SizedBox(
                  width: 120,
                  child: TextFieldWithIcon(
                    controller: localProvinciaNormalController,
                    labelText: "",
                    icon: Icons.monetization_on,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Local",
                      ),
                      TextSpan(
                        text: "-Provincial Especial",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "(Especial 2)",
                ),
                SizedBox(
                  width: 120,
                  child: TextFieldWithIcon(
                    controller: localProvinciaEspecialController,
                    labelText: "",
                    icon: Icons.monetization_on,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Costo Devolucion %",
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Costo envio + (Costo.dev % del Costo envio)",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 120,
                  child: TextFieldWithIcon(
                    controller: costoDevolucionController,
                    labelText: "",
                    icon: Icons.percent,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Costo seguro %",
                ),
                const Text(
                  "Costo.seg % del Precio total",
                  style: TextStyle(fontSize: 11),
                ),
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
            context),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Costo Recaudo: ",
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Menor/igual a Precio.max aplica Costo base",
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                "Mayor a Precio.max aplica Costo Icrem. % del Precio Total",
                style: TextStyle(fontSize: 11),
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        responsive(
            // web
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
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
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
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
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
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // mobile
            Column(
              children: [
                Row(
                  children: [
                    const Text(
                      "Precio Maximo: ",
                    ),
                    SizedBox(
                      width: 120,
                      child: TextFieldWithIcon(
                        controller: maxPriceController,
                        labelText: "",
                        icon: Icons.monetization_on,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Costo base: ",
                    ),
                    SizedBox(
                      width: 120,
                      child: TextFieldWithIcon(
                        controller: costoBaseController,
                        labelText: "",
                        icon: Icons.monetization_on,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Costo Icremental %: ",
                    ),
                    SizedBox(
                      width: 120,
                      child: TextFieldWithIcon(
                        controller: incrementalController,
                        labelText: "",
                        icon: Icons.percent,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            context),
      ],
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
              statusList != [] ? dataL[index]['id_ref'].toString() : "",
            ),
            onTap: () {
              showEditStatus(dataL[index], statusList);
            },
          ),
          DataCell(
            Text(
              statusList != [] ? dataL[index]['name'].toString() : "",
            ),
            onTap: () {
              showEditStatus(dataL[index], statusList);
            },
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
        // size: ColumnSize.S,
        fixedWidth: 100,
      ),
      DataColumn2(
        label: Text('Provincia'),
        // size: ColumnSize.S,
        fixedWidth: 180,
      ),
      DataColumn2(
        label: Text('ID'),
        // size: ColumnSize.S,
        fixedWidth: 100,
      ),
      DataColumn2(
        label: Text("Ciudad"),
        fixedWidth: 180,
        // size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Tipo'),
        // size: ColumnSize.S,
        fixedWidth: 120,
      ),
      DataColumn2(
        label: Text(''),
        // size: ColumnSize.S,
        fixedWidth: 50,
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
            // onTap: () {
            //   // showEditCoverage(dataL[index]);
            //   showEditCoverage(dataL[index], typesToSelect);
            // },
            onTap: () {
              //
            },
          ),
          DataCell(
            Text(
              coveragesList != []
                  ? dataL[index]['coverage_external']['dpa_provincia']
                          ['provincia']
                      .toString()
                  : "",
            ),
            onTap: () {
              //
            },
          ),
          DataCell(
            Text(
              coveragesList != []
                  ? dataL[index]['id_ciudad_ref'].toString()
                  : "",
            ),
            onTap: () {
              //
            },
          ),
          DataCell(
            Text(
              coveragesList != []
                  ? dataL[index]['coverage_external']['ciudad'].toString()
                  : "",
            ),
            onTap: () {
              //
            },
          ),
          DataCell(
            Text(
              coveragesList != [] ? dataL[index]['type'].toString() : "",
            ),
            onTap: () {
              //
            },
          ),
          DataCell(
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    AwesomeDialog(
                      width: 500,
                      context: context,
                      dialogType: DialogType.info,
                      animType: AnimType.rightSlide,
                      title: '¿Estás seguro de eliminar el Producto?',
                      desc:
                          '${coveragesList != [] ? dataL[index]['id'].toString() : ""}-${coveragesList != [] ? dataL[index]['coverage_external']['ciudad'].toString() : ""}',
                      btnOkText: "Confirmar",
                      btnCancelText: "Cancelar",
                      btnOkColor: Colors.blueAccent,
                      btnCancelOnPress: () {},
                      btnOkOnPress: () async {
                        getLoadingModal(context, false);

                        var responseUpt = await Connections()
                            .updateCoverage(dataL[index]['id'].toString(), {
                          "active": 0,
                        });

                        if (responseUpt == 0) {
                          Navigator.pop(context);
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

                        await loadData();
                      },
                    ).show();
                  },
                  child: const Icon(
                    Icons.delete,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            onTap: () {
              //
            },
          ),
        ],
      );
      rows.add(row);
    }

    return rows;
  }

  Future<dynamic> showEditCoverage(data, types) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: EditCoverage(
                  data: data, types: types, coveragesList: coveragesList),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }

  Future<dynamic> showEditStatus(data, status) {
    // print(data);
    // print(status);
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: EditStatus(
                  carrierId: widget.data['id'].toString(),
                  data: data,
                  status: status),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }

  Future<dynamic> showAddCoverage() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: NewCoverage(
                  carrierId: widget.data['id'].toString(),
                  types: typesToSelect,
                  coveragesList: coveragesList),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }

  Future<dynamic> showAddStatus() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            //
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              contentPadding: EdgeInsets.all(0),
              content: NewStatus(
                  carrierId: widget.data['id'].toString(), status: statusList),
            );
          },
        );
      },
    ).then((value) => setState(() {
          loadData();
        }));
  }

  String idProvRef(provincia) {
    String res = "";

    String targetProvincia = provincia;
    String targetIdProvRef = coveragesList.firstWhere(
            (element) =>
                element["coverage_external"]["dpa_provincia"]["provincia"] ==
                targetProvincia,
            orElse: () => null)?["id_prov_ref"] ??
        "-1";

    // print("targetProvincia: $targetProvincia");
    // print("resultado: $targetIdProvRef");

    return targetIdProvRef.toString();
  }

  bool idCiudadRefExists(String idCiudadRef) {
    // Obtener todos los id_ciudad_ref de coveragesList
    List<String> idCiudadRefs = coveragesList
        .map<String>((element) => element["id_ciudad_ref"])
        .toList();

    // Comprobar si el id_ciudad_ref dado ya existe en la lista
    bool idExists = idCiudadRefs.contains(idCiudadRef);

    return idExists;
  }

  bool idProvinciaRefExists(String idProvRef) {
    // Obtener todos los id_ciudad_ref de coveragesList
    List<String> idProvRefs =
        coveragesList.map<String>((element) => element["id_prov_ref"]).toList();

    // Comprobar si el id_ciudad_ref dado ya existe en la lista
    bool idExists = idProvRefs.contains(idProvRef);

    return idExists;
  }
}
