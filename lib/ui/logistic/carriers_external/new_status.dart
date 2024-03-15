import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';

class NewStatus extends StatefulWidget {
  final String carrierId;
  final List status;

  const NewStatus({super.key, required this.carrierId, required this.status});

  @override
  State<NewStatus> createState() => _NewStatusState();
}

class _NewStatusState extends State<NewStatus> {
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
  TextEditingController newIdController = TextEditingController(text: "");
  TextEditingController newEstadoController = TextEditingController(text: "");
  Map data = {};
  List statusList = [];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      // print(data);
      statusList = widget.status;
      // print(statusList);

      setState(() {});

      //
    } catch (e) {
      // print("error!!!:  $e");

      // ignore: use_build_context_synchronously
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error al cargar las Subrutas");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 400,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: 500,
          height: 400,
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Nuevo Estado Equivalente",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
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
                  ),
                  onPressed: () async {
                    //
                    if (newIdController.text == "" ||
                        newEstadoController.text == "" ||
                        selectedStatus == null) {
                      showSuccessModal(
                          context,
                          "Por favor, ingrese/seleccione todos los valores.",
                          Icons8.warning_1);
                    } else {
                      bool res = idExists(newIdController.text);
                      // print(res);
                      if (res) {
                        showSuccessModal(context, "Error, este ID ya existe.",
                            Icons8.warning_1);
                      } else {
                        //
                        getLoadingModal(context, false);

                        var newStatus = {
                          "estado": selectedStatus.toString().split("-")[1],
                          "name_local": selectedStatus.toString().split("-")[0],
                          "id_ref": newIdController.text.toString(),
                          "name": newEstadoController.text.toString(),
                          "id": (statusList.length + 1).toString()
                        };

                        statusList.add(newStatus);

                        var responseCreate = await Connections().updateCarrier(
                            widget.carrierId,
                            {"status": json.encode(statusList)});

                        if (responseCreate == 0) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else {
                          //
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
      ),
    );
  }

  bool idExists(String idRef) {
    for (var item in statusList) {
      if (item['id_ref'] == idRef) {
        return true;
      }
    }
    return false;
  }
}
