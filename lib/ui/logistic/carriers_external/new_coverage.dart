import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/text_field_icon.dart';

class NewCoverage extends StatefulWidget {
  final String carrierId;

  final List<dynamic> types;
  final List coveragesList;

  const NewCoverage(
      {super.key,
      required this.carrierId,
      required this.types,
      required this.coveragesList});

  @override
  State<NewCoverage> createState() => _NewCoverageState();
}

class _NewCoverageState extends State<NewCoverage> {
  bool isLoading = false;

  List coveragesList = [];
  String? selectedProvinciaNewC;

  TextEditingController newIdCiudadController = TextEditingController(text: "");
  TextEditingController newCiudadController = TextEditingController(text: "");
  TextEditingController newIdProvController = TextEditingController(text: "");
  bool newProvincia = false;
  List<String> provinciasToSelect = [];
  List<String> typesToSelect = [];
  String? selectedType;

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
      });
      //
      var provinciasList = [];

      provinciasList = await Connections().getProvincias();
      for (var i = 0; i < provinciasList.length; i++) {
        provinciasToSelect.add('${provinciasList[i]}');
      }

      typesToSelect =
          widget.types.map((dynamic item) => item.toString()).toList();

      setState(() {
        coveragesList = widget.coveragesList;
        // typesToSelect = widget.types;
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Nueva Cobertura",
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
                                newIdProvController.text = "";
                                String resProv = idProvRef(selectedProvinciaNewC
                                    .toString()
                                    .split('-')[0]);
                                newIdProvController.text =
                                    resProv != "-1" ? resProv : "";
                                newProvincia = resProv == "-1" ? true : false;
                              });

                              // print(newProvincia);
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
                        child:
                            // TextFieldIcon(
                            //   //el nuevo widget
                            //   controller: newIdProvController,
                            //   labelText: 'ID Provincia',
                            //   readOnly: true,
                            //   icon: Icons.edit,
                            //   inputFormatters: [
                            //     FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            //   ],
                            // ),
                            TextField(
                          controller: newIdProvController,
                          decoration: InputDecoration(
                            labelText: 'ID Provincia',
                            icon: Icon(
                              Icons.edit,
                              color: ColorsSystem().colorSelectMenu,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                          readOnly: newProvincia
                              ? false
                              : true, // Deshabilitar la edición
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: TextFieldWithIcon(
                          //widget de producto
                          controller: newIdCiudadController,
                          labelText: 'ID Ciudad',
                          icon: Icons.edit,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
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

                    if (newIdCiudadController.text == "" ||
                        newCiudadController.text == "" ||
                        newIdProvController.text == "" ||
                        selectedType == null ||
                        selectedProvinciaNewC == null) {
                      showSuccessModal(
                          context,
                          "Por favor, ingrese/seleccione todos los valores.",
                          Icons8.warning_1);
                    } else {
                      getLoadingModal(context, false);

                      if (newProvincia) {
                        bool idProvExists =
                            idProvinciaRefExists(newIdProvController.text);
                        if (idProvExists) {
                          showSuccessModal(
                              context,
                              "Error, este ID para una Provincia ya existe.",
                              Icons8.warning_1);
                        } else {
                          bool idCiudadExists =
                              idCiudadRefExists(newIdCiudadController.text);
                          if (idCiudadExists) {
                            showSuccessModal(
                                context,
                                "Error, este ID para una Ciudad ya existe.",
                                Icons8.warning_1);
                          } else {
                            // print("Continuar con el proceso");
                            var responseCreate = await Connections()
                                .createNewCoverage(
                                    widget.carrierId,
                                    newIdCiudadController.text,
                                    newCiudadController.text,
                                    newIdProvController.text,
                                    selectedProvinciaNewC
                                        .toString()
                                        .split('-')[1],
                                    selectedProvinciaNewC
                                        .toString()
                                        .split('-')[0],
                                    selectedType.toString());

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
                          }
                        }
                      } else {
                        bool idCiudadExists =
                            idCiudadRefExists(newIdCiudadController.text);
                        if (idCiudadExists) {
                          showSuccessModal(
                              context,
                              "Error, este ID para una Ciudad ya existe.",
                              Icons8.warning_1);
                        } else {
                          // print("Continuar con el proceso");
                          var responseCreate = await Connections()
                              .createNewCoverage(
                                  widget.carrierId,
                                  newIdCiudadController.text,
                                  newCiudadController.text,
                                  newIdProvController.text,
                                  selectedProvinciaNewC
                                      .toString()
                                      .split('-')[1],
                                  selectedProvinciaNewC
                                      .toString()
                                      .split('-')[0],
                                  selectedType.toString());

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
