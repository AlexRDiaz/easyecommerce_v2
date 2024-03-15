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

class EditCoverage extends StatefulWidget {
  final Map data;
  final List<dynamic> types;
  final List coveragesList;

  const EditCoverage(
      {super.key,
      required this.data,
      required this.types,
      required this.coveragesList});

  @override
  State<EditCoverage> createState() => _EditCoverageState();
}

class _EditCoverageState extends State<EditCoverage> {
  String? selectedTypeEdit;
  TextEditingController editIdProvController = TextEditingController(text: "");
  TextEditingController editIdCiudadController =
      TextEditingController(text: "");
  Map data = {};
  List coveragesList = [];
  List<String> typesToSelect = [];

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    try {
      data = widget.data;
      // print("${widget.data['id']}");
      // print("${widget.types}");
      // print("${widget.coveragesList}");

      setState(() {
        editIdProvController.text = data['id_prov_ref'];
        editIdCiudadController.text = data['id_ciudad_ref'];
        selectedTypeEdit = data['type'];
      });

      typesToSelect =
          widget.types.map((dynamic item) => item.toString()).toList();
      setState(() {
        coveragesList = widget.coveragesList;
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
          color: Colors.deepPurple.shade100,
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              const Text(
                "Editar Cobertura",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextFieldWithIcon(
                      controller: editIdProvController,
                      labelText: 'ID Provincia',
                      icon: Icons.edit,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 250,
                    child: Text(
                      "Provincia: ${data['coverage_external']['dpa_provincia']['provincia'].toString()}",
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 250,
                    child: TextFieldWithIcon(
                      controller: editIdCiudadController,
                      labelText: 'ID Ciudad',
                      icon: Icons.edit,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 250,
                    child: Text(
                      "Ciudad: ${data['coverage_external']['ciudad'].toString()}",
                    ),
                  ),
                  const SizedBox(
                    height: 10,
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
                        value: selectedTypeEdit,
                        onChanged: (value) async {
                          setState(() {
                            selectedTypeEdit = value as String;
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
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    //
                    getLoadingModal(context, false);

                    if (editIdProvController.text == "" ||
                        editIdCiudadController.text == "" ||
                        selectedTypeEdit == null) {
                      showSuccessModal(
                          context,
                          "Por favor, ingrese/seleccione todos los valores.",
                          Icons8.warning_1);
                    } else {
                      bool idCiudadExists =
                          idCiudadRefExists(editIdCiudadController.text);
                      if (editIdCiudadController.text !=
                          data['id_ciudad_ref'].toString()) {
                        if (idCiudadExists) {
                          showSuccessModal(
                              context,
                              "Error, este ID para una Ciudad ya existe.",
                              Icons8.warning_1);
                        } else {
                          var responseUpt = await Connections()
                              .updateCoverage(data['id'].toString(), {
                            "id_prov_ref": editIdProvController.text,
                            "id_ciudad_ref": editIdCiudadController.text,
                            "type": selectedTypeEdit.toString(),
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
                        }
                      } else {
                        var responseUpt = await Connections()
                            .updateCoverage(data['id'].toString(), {
                          "id_prov_ref": editIdProvController.text,
                          "id_ciudad_ref": editIdCiudadController.text,
                          "type": selectedTypeEdit.toString(),
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
