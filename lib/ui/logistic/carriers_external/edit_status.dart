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

class EditStatus extends StatefulWidget {
  final String carrierId;
  final Map data;
  final List status;
  const EditStatus(
      {super.key,
      required this.carrierId,
      required this.data,
      required this.status});

  @override
  State<EditStatus> createState() => _EditStatusState();
}

class _EditStatusState extends State<EditStatus> {
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
  TextEditingController editIdController = TextEditingController(text: "");
  TextEditingController editEstadoController = TextEditingController(text: "");
  Map data = {};
  List statusList = [];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      data = widget.data;
      // print(data);
      statusList = widget.status;
      // print(statusList);

      setState(() {
        editIdController.text = data['id_ref'];
        editEstadoController.text = data['name'];
        selectedStatus = "${data['name_local']}-${data['estado']}";
      });

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
      height: 500,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                "Editar Estado Equivalente",
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
                          controller: editIdController,
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
                          controller: editEstadoController,
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
                    String idToUpdate = data['id'];

                    // Buscar el elemento con el ID específico
                    var foundElementIndex = statusList
                        .indexWhere((element) => element['id'] == idToUpdate);

                    if (foundElementIndex != -1) {
                      bool res = idExists(editIdController.text);
                      // print(res);
                      if (res) {
                        showSuccessModal(context, "Error, este ID ya existe.",
                            Icons8.warning_1);
                      } else {
                        //
                        getLoadingModal(context, false);

                        // Actualizar los valores del elemento encontrado
                        statusList[foundElementIndex]['estado'] =
                            selectedStatus.toString().split("-")[1];
                        statusList[foundElementIndex]['name_local'] =
                            selectedStatus.toString().split("-")[0];
                        statusList[foundElementIndex]['id_ref'] =
                            editIdController.text;
                        statusList[foundElementIndex]['name'] =
                            editEstadoController.text;

                        var responseUpdt = await Connections().updateCarrier(
                            widget.carrierId,
                            {"status": json.encode(statusList)});

                        if (responseUpdt == 0) {
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
                              Navigator.pop(context);
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
                    } else {
                      print("Elemento con ID $idToUpdate no encontrado.");
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
