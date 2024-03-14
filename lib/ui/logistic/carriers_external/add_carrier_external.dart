import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:excel/excel.dart';

class AddCarrierExternal extends StatefulWidget {
  const AddCarrierExternal({super.key});

  @override
  State<AddCarrierExternal> createState() => _AddCarrierExternalState();
}

class _AddCarrierExternalState extends State<AddCarrierExternal> {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  List<String> provinciasToSelect = [];
  String? selectedProvincia;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController mailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  //estado_logistico
  TextEditingController pendienteController = TextEditingController(text: "");
  TextEditingController impresoController = TextEditingController(text: "");
  TextEditingController enviadoController = TextEditingController(text: "");
  TextEditingController rechazadoController = TextEditingController(text: "");
  //status
  TextEditingController programadoController = TextEditingController(text: "");
  TextEditingController enRutaController = TextEditingController(text: "");
  TextEditingController entregadoController = TextEditingController(text: "");
  TextEditingController noEntregadoController = TextEditingController(text: "");
  TextEditingController novedadController = TextEditingController(text: "");
  TextEditingController reagendadoController = TextEditingController(text: "");
  TextEditingController enOficinaStatusController =
      TextEditingController(text: "");
  TextEditingController novedadResueltaController =
      TextEditingController(text: "");
  //estado_devolucion
  TextEditingController devolucionEnRutacontroller =
      TextEditingController(text: "");
  TextEditingController enBodegaController = TextEditingController(text: "");
  TextEditingController enOficinaDevolucionController =
      TextEditingController(text: "");
  // TextEditingController pendienteController = TextEditingController(text: "");
  TextEditingController enBodegaProvController =
      TextEditingController(text: "");

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

  final TextEditingController _typeController = TextEditingController();

  var statusToSend;
  List typeToSend = [];

  List<String> parroquiasToSelect = [];
  String? selectedParroquia;

  List<Map<String, dynamic>> coberturaToSend = [];
  var costsToSend;

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
        setState(() {
          provinciasToSelect.add('${provinciasList[i]}');
        });
      }

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

  getParroquias() async {
    try {
      setState(() {
        parroquiasToSelect = [];
      });

      var parroquiasList = [];

      parroquiasList = await Connections()
          .getParroquiasByProvincia(selectedProvincia.toString().split("-")[0]);
      for (var i = 0; i < parroquiasList.length; i++) {
        setState(() {
          parroquiasToSelect.add('${parroquiasList[i]}');
        });
      }
      setState(() {});
    } catch (error) {
      print('Error al cargar parroquias: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWith = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWith > 600 ? screenWith * 0.4 : screenWith,
      height: screenHeight * 0.9,
      color: Colors.white,
      child: CustomProgressModal(
        isLoading: isLoading,
        content: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close))
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "AGREGAR",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              const Text(
                "Agregar tipo de cobertura",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(
                    width:
                        screenWith > 600 ? screenWith * 0.2 : screenWith * 0.42,
                    child: TextFieldWithIcon(
                      controller: _typeController,
                      labelText: 'Cobertura',
                      icon: Icons.label,
                      applyValidator: false,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      // minimumSize: Size(200, 40)
                    ),
                    onPressed: () async {
                      //
                      if (_typeController.text.isEmpty) {
                        showSuccessModal(context, "Por favor, ingrese un tipo.",
                            Icons8.warning_1);
                      } else {
                        var type = _typeController.text;

                        if (!typeToSend.contains(type)) {
                          typeToSend.add(type);
                          setState(() {
                            _typeController.clear();
                          });
                        }
                      }
                      // print("typeToSend: $typeToSend");
                    },
                    child: const Text(
                      "Añadir",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(typeToSend.length, (index) {
                  String categoryName = typeToSend[
                      index]; // Obtén el nombre de la categoría actual
                  return Chip(
                    label: Text(categoryName),
                    onDeleted: () {
                      setState(() {
                        typeToSend.removeAt(index);
                        // print("catAct: $selectedCategoriesMap");
                      });
                    },
                  );
                }),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      //

                      if (typeToSend.isEmpty) {
                        showSuccessModal(
                            context,
                            "Por favor, primero ingrese los Tipos de Cobertura.",
                            Icons8.warning_1);
                      } else {
                        _importFromExcel();
                      }
                    },
                    child: const Text(
                      "Cargar provincias de cobertura",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Visibility(
                    visible: coberturaToSend.isNotEmpty,
                    child: const Icon(Icons.check),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                      onPressed: () async {
                        //
                        generateExcelTemplate();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.file_download_rounded),
                          Text(
                            "Descargar plantilla",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      //
                      showAddCost(context);
                    },
                    child: const Text(
                      "Agregar Costos de Transporte",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Visibility(
                    visible: costsToSend != null,
                    child: const Icon(Icons.check),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      //
                      showStatus(context);
                    },
                    child: const Text(
                      "Agregar Estados Equivalentes",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Visibility(
                    visible: statusToSend != null,
                    child: const Icon(Icons.check),
                  ),
                ],
              ),
              /*
              DropdownButtonHideUnderline(
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
                              item.split('-')[1],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  value: selectedProvincia,
                  onChanged: (value) async {
                    setState(() {
                      selectedProvincia = value as String;
                      parroquiasToSelect.clear();
                      selectedParroquia = null;
                    });
                    await getParroquias();
                  },

                  //This to clear the search value when you close the menu
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {}
                  },
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: Text(
                    'Ciudad',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                        fontWeight: FontWeight.bold),
                  ),
                  items: parroquiasToSelect
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              item.split('-')[2],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  value: selectedParroquia,
                  onChanged: (value) async {
                    setState(() {
                      selectedParroquia = value as String;
                    });
                  },

                  //This to clear the search value when you close the menu
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {}
                  },
                ),
              ),
              */
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(200, 40)),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // getLoadingModal(context, false);

                      if (!mailController.text.contains('@')) {
                        showSuccessModal(
                            context,
                            "Por favor, ingrese un correo electrónico válido.",
                            Icons8.warning_1);
                      } else {
                        if (coberturaToSend.isEmpty ||
                            costsToSend == null ||
                            statusToSend == null) {
                          showSuccessModal(
                              context,
                              "Por favor, ingrese las Coberturas, Costos y Estados.",
                              Icons8.warning_1);
                        } else {
                          // print(_controllers.mailController.text);
                          getLoadingModal(context, false);

                          String phoneNumber = phoneController.text;
                          if (phoneNumber.startsWith("0")) {
                            phoneNumber = "+593${phoneNumber.substring(1)}";
                          }

                          var responseCreate = await Connections()
                              .createCarrierExternal(
                                  nameController.text,
                                  phoneNumber,
                                  mailController.text,
                                  addressController.text,
                                  statusToSend,
                                  typeToSend,
                                  costsToSend,
                                  coberturaToSend);

                          if (responseCreate == 0) {
                            Navigator.pop(context);
                            // ignore: use_build_context_synchronously
                            AwesomeDialog(
                              width: 500,
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.rightSlide,
                              title: 'Completado',
                              desc: 'Se creo el  con exito.',
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

                        //
                      }
                    }
                    //
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

  Future<dynamic> showAddCost(BuildContext context) {
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
            width: screenWith > 600 ? screenWith * 0.35 : screenWith,
            height: screenHeight * 0.75,
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: ListView(
              children: [
                Column(
                  children: [
                    const Text(
                      "Costo por entrega: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Text(
                          "Local-Local Normal: ",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: localLocalNormalController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Local-Local Especial: ",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: localLocalEspecialController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Local-Provincial Normal: ",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: localProvinciaNormalController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Local-Provincial Especial: ",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: localProvinciaEspecialController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Costo Devolucion: % ",
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: costoDevolucionController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const Text(
                              "Costo envio + (Costo.dev % del Costo envio)",
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "Costo seguro: % ",
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            SizedBox(
                              width: 150,
                              child: TextFormField(
                                controller: costoSeguroController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const Text(
                              "Costo.seg % del Precio total",
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                        Text(
                          "Mayor a Precio.max aplica Costo Icrem. % del Precio Total",
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "Costo base: ",
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: costoBaseController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "Precio Maximo: ",
                        ),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: maxPriceController,
                            onChanged: (value) {
                              setState(() {});
                            },
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
                          width: 100,
                          child: TextFormField(
                            controller: incrementalController,
                            onChanged: (value) {
                              setState(() {});
                            },
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
                            minimumSize: Size(200, 40)),
                        onPressed: () async {
                          //
                          print(localLocalNormalController.text);
                          if (localLocalNormalController.text.isEmpty) {
                            print("ifffff");

                            showSuccessModal(
                                context,
                                "Por favor, ingrese todos los datos.",
                                Icons8.warning_1);
                          } else {
                            print("elseee");

                            costsToSend = {
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
                          }

                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: const Text(
                          "Guardar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
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

  Future<dynamic> showStatus(BuildContext context) {
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
            width: screenWith > 600 ? screenWith * 0.35 : screenWith,
            height: screenHeight * 0.75,
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: ListView(
              children: [
                Column(
                  children: [
                    const Text(
                      "Estatus Equivalentes",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Ejemplo: 3-Entregado",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                          // style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text(
                          "Estado Interno",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "CONFIRMADO:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: pendienteController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text(
                          "Estado Logístico",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "IMPRESO:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: impresoController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "ENVIADO:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: enviadoController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "RECHAZADO:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: rechazadoController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text(
                          "Status",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "PEDIDO PROGRAMADO:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: programadoController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "EN RUTA:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: enRutaController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "ENTREGADO:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: entregadoController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "NO ENTREGADO:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: noEntregadoController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "NOVEDAD:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: novedadController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "REAGENDADO:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: reagendadoController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "EN OFICINA:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: enOficinaStatusController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "NOVEDAD RESUELTA:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: novedadResueltaController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Text(
                          "Estado Devolución",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "DEVOLUCION EN RUTA:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: devolucionEnRutacontroller,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "EN BODEGA:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: enBodegaController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "ENTREGADO EN OFICINA:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: enOficinaDevolucionController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "EN BODEGA PROVEEDOR:",
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: enBodegaProvController,
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 10),
                    // Row(
                    //   children: [
                    //     const Text(
                    //       "PENDIENTE:", //
                    //     ),
                    //     const SizedBox(width: 20),
                    //     SizedBox(
                    //       width: 150,
                    //       child: TextFormField(
                    //         controller: pendienteController,
                    //         onChanged: (value) {
                    //           setState(() {});
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(200, 40)),
                        onPressed: () async {
                          //
                          /*
                          statusToSend = {
                            "PEDIDO PROGRAMADO": programadoController.text != ""
                                ? programadoController.text
                                : 0,
                            "EN RUTA": enRutaController.text != ""
                                ? enRutaController.text
                                : 0,
                            "ENTREGADO": entregadoController.text != ""
                                ? entregadoController.text
                                : 0,
                            "NO ENTREGADO": noEntregadoController.text != ""
                                ? noEntregadoController.text
                                : 0,
                            "NOVEDAD": novedadController.text != ""
                                ? novedadController.text
                                : 0,
                            "REAGENDADO": reagendadoController.text != ""
                                ? reagendadoController.text
                                : 0,
                            "EN OFICINA": enOficinaStatusController.text != ""
                                ? enOficinaStatusController.text
                                : 0,
                            "NOVEDAD RESUELTA":
                                novedadResueltaController.text != ""
                                    ? novedadResueltaController.text
                                    : 0,
                            // devol
                            "DEVOLUCION EN RUTA":
                                devolucionEnRutacontroller.text != ""
                                    ? devolucionEnRutacontroller.text
                                    : 0,
                            "EN BODEGA": enBodegaController.text != ""
                                ? enBodegaController.text
                                : 0,
                            "ENTREGADO EN OFICINA":
                                enOficinaDevolucionController.text != ""
                                    ? enOficinaDevolucionController.text
                                    : 0,
                            "EN BODEGA PROVEEDOR":
                                enBodegaProvController.text != ""
                                    ? enBodegaProvController.text
                                    : 0,
                            "PENDIENTE": pendienteController.text != ""
                                ? pendienteController.text
                                : 0,
                          };
*/
                          statusToSend = [
                            {
                              "estado": "estado_interno",
                              "name_local": "CONFIRMADO",
                              "id": pendienteController.text.toString() != ""
                                  ? pendienteController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": pendienteController.text != ""
                                  ? pendienteController.text
                                      .toString()
                                      .split("-")[1]
                                  : "",
                            },
                            {
                              "estado": "estado_logistico",
                              "name_local": "IMPRESO",
                              "id": impresoController.text.toString() != ""
                                  ? impresoController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": impresoController.text != ""
                                  ? impresoController.text
                                      .toString()
                                      .split("-")[1]
                                  : "",
                            },
                            {
                              "estado": "estado_logistico",
                              "name_local": "ENVIADO",
                              "id": enviadoController.text.toString() != ""
                                  ? enviadoController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": enviadoController.text != ""
                                  ? enviadoController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "estado_logistico",
                              "name_local": "RECHAZADO",
                              "id": rechazadoController.text.toString() != ""
                                  ? rechazadoController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": rechazadoController.text != ""
                                  ? rechazadoController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            //
                            {
                              "estado": "status",
                              "name_local": "PEDIDO PROGRAMADO",
                              "id": programadoController.text.toString() != ""
                                  ? programadoController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": programadoController.text != ""
                                  ? programadoController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "status",
                              "name_local": "EN RUTA",
                              "id": enRutaController.text.toString() != ""
                                  ? enRutaController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": enRutaController.text != ""
                                  ? enRutaController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "status",
                              "name_local": "ENTREGADO",
                              "id": entregadoController.text.toString() != ""
                                  ? entregadoController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": entregadoController.text != ""
                                  ? entregadoController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "status",
                              "name_local": "NO ENTREGADO",
                              "id": noEntregadoController.text.toString() != ""
                                  ? noEntregadoController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": noEntregadoController.text != ""
                                  ? noEntregadoController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "status",
                              "name_local": "NOVEDAD",
                              "id": novedadController.text.toString() != ""
                                  ? novedadController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": novedadController.text != ""
                                  ? novedadController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "status",
                              "name_local": "NOVEDAD RESUELTA",
                              "id": novedadResueltaController.text.toString() !=
                                      ""
                                  ? novedadResueltaController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": novedadResueltaController.text != ""
                                  ? novedadResueltaController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "status",
                              "name_local": "REAGENDADO",
                              "id": reagendadoController.text.toString() != ""
                                  ? reagendadoController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": reagendadoController.text != ""
                                  ? reagendadoController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "status",
                              "name_local": "EN OFICINA",
                              "id": enOficinaStatusController.text.toString() !=
                                      ""
                                  ? enOficinaStatusController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": enOficinaStatusController.text != ""
                                  ? enOficinaStatusController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            //
                            {
                              "estado": "estado_devolucion",
                              "name_local": "DEVOLUCION EN RUTA",
                              "id":
                                  devolucionEnRutacontroller.text.toString() !=
                                          ""
                                      ? devolucionEnRutacontroller.text
                                          .toString()
                                          .split("-")[0]
                                      : 0,
                              "name": devolucionEnRutacontroller.text != ""
                                  ? devolucionEnRutacontroller.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "estado_devolucion",
                              "name_local": "EN BODEGA",
                              "id": enBodegaController.text.toString() != ""
                                  ? enBodegaController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": enBodegaController.text != ""
                                  ? enBodegaController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "estado_devolucion",
                              "name_local": "ENTREGADO EN OFICINA",
                              "id": enOficinaDevolucionController.text
                                          .toString() !=
                                      ""
                                  ? enOficinaDevolucionController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": enOficinaDevolucionController.text != ""
                                  ? enOficinaDevolucionController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            {
                              "estado": "estado_devolucion",
                              "name_local": "EN BODEGA PROVEEDOR",
                              "id": enBodegaProvController.text.toString() != ""
                                  ? enBodegaProvController.text
                                      .toString()
                                      .split("-")[0]
                                  : 0,
                              "name": enBodegaProvController.text != ""
                                  ? enBodegaProvController.text
                                      .toString()
                                      .split("-")[1]
                                  : ""
                            },
                            // {
                            //   "status": "PENDIENTE",
                            //   "id": pendienteController.text.toString() != ""
                            //       ? pendienteController.text
                            //           .toString()
                            //           .split("-")[0]
                            //       : 0,
                            //   "value": pendienteController.text != ""
                            //       ? pendienteController.text
                            //           .toString()
                            //           .split("-")[1]
                            //       : ""
                            // },
                          ];
                          print(statusToSend);

                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: const Text(
                          "Guardar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
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

  _importFromExcel() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    try {
      var bytes = pickedFile?.files.single.bytes;
      var excel = Excel.decodeBytes(bytes!);
      getLoadingModal(context, false);

      List<Map<String, dynamic>> provinciasList = [];

      List errorList = [];

      List<String> expectedSheetNames = ['provincias', 'ciudades'];

      List<String> sheetNames = excel.tables.keys.toList();
      bool namesCorrect = true;
      for (int i = 0; i < expectedSheetNames.length; i++) {
        String expectedName = expectedSheetNames[i];

        if (i < sheetNames.length &&
            sheetNames[i].toLowerCase() != expectedName) {
          namesCorrect = false;
        }
      }
      if (namesCorrect) {
        for (var table in excel.tables.keys) {
          // Asegurarse de estar en la hoja deseada, por ejemplo, "Hoja2"
          if (table.toLowerCase() == "provincias") {
            for (var row in excel.tables[table]!.rows.skip(1)) {
              try {
                Map<String, dynamic> provincia = {
                  "id_provincia":
                      int.tryParse(row[0]?.value?.toString().trim() ?? '') ?? 0,
                  "provincia": row[1]?.value?.toString().trim() ?? '',
                };
                provinciasList.add(provincia);
              } catch (e) {
                print('Error al procesar la fila:');
                print('Detalles del error: $e');
              }
            }
          }
          // print(provinciasList);

          if (table.toLowerCase() == "ciudades") {
            for (var row in excel.tables[table]!.rows.skip(1)) {
              try {
                Map<String, dynamic> ciudadData = {
                  "id_ciudad":
                      int.tryParse(row[0]?.value?.toString().trim() ?? '') ?? 0,
                  "ciudad": row[1]?.value?.toString().trim() ?? '',
                  "provincia": row[2]?.value?.toString().trim() ?? '',
                  "tipo": row[3]?.value?.toString().trim() ?? '',
                };

                int id_prov = 0;
                for (var provinciaNombre in provinciasList) {
                  if (provinciaNombre['provincia'] ==
                      (row[2]?.value?.toString()?.trim() ?? '')) {
                    id_prov = provinciaNombre["id_provincia"];
                    break;
                  }
                }

                // Agregar nuevo valor después de crear el mapa
                ciudadData["id_provincia"] = id_prov;

                bool matchFound = false;

                for (var element in typeToSend) {
                  if (row[3]?.value?.toString().trim() == element) {
                    matchFound = true;
                    break;
                  }
                }

                if (!matchFound) {
                  errorList.add(
                      "${row[1]?.value?.toString().trim()}-${row[3]?.value?.toString().trim()}");
                }

                coberturaToSend.add(ciudadData);
              } catch (e) {
                print('Error al procesar la fila:');
                print('Detalles del error: $e');
              }
            }
          }
        }

        Navigator.pop(context);
        setState(() {});
        if (errorList.isNotEmpty) {
          coberturaToSend.clear();
          setState(() {});

          String resError = errorList.join(',\n');

          // ignore: use_build_context_synchronously
          AwesomeDialog(
            width: 500,
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title:
                "Error, el archivo contiene tipos de cobertura que no ha ingresado.",
            desc: resError,
            btnCancel: Container(),
            btnOkText: "Aceptar",
            btnOkColor: colors.colorGreen,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              // Navigator.pop(context);
            },
          ).show();
        }
      } else {
        Navigator.pop(context);
        setState(() {});
        // ignore: use_build_context_synchronously
        AwesomeDialog(
          width: 500,
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: "Error",
          desc:
              "Los nombres y/o las posiciones de las hojas no son las correctas.",
          btnCancel: Container(),
          btnOkText: "Aceptar",
          btnOkColor: colors.colorGreen,
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            // Navigator.pop(context);
          },
        ).show();
      }
      // Imprimir la representación JSON (opcional)
      // print(jsonEncode(coberturaToSend));
    } catch (e) {
      print('Error al decodificar el archivo Excel: $e');
    }
  }

  Future<void> generateExcelTemplate() async {
    try {
      final excel = Excel.createExcel();

      Sheet sheet1 = excel['Provincias'];
      sheet1!.setColWidth(2, 20);

      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'ID Provincia';
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Provincia';
      //
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = "1301";
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
          .value = "Azuay";
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
          .value = "1302";
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
          .value = "Bolívar";

      excel.delete(excel.getDefaultSheet() as String);

      //
      Sheet sheet2 = excel['Ciudades'];

      sheet2!.setColWidth(2, 20);
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'ID';
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Ciudad';
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Provincia';
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Origen';
      //
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = "50210";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
          .value = "Cuenca";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
          .value = "Azuay";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1))
          .value = "Normal";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
          .value = "50211";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
          .value = "Sayuasí";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2))
          .value = "Azuay";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 2))
          .value = "Especial";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
          .value = "50212";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
          .value = "Chimbo";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 3))
          .value = "Bolívar";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 3))
          .value = "Especial";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
          .value = "50213";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
          .value = "Guaranda";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 4))
          .value = "Bolívar";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 4))
          .value = "Normal";
      /*
            // Hoja 1
      final sheet1 = excel.sheets['Provincias'];
      sheet1!.setColWidth(2, 50);

      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'ID Provincia';
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Provincia';
      //
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = "1301";
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
          .value = "Azuay";
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
          .value = "1302";
      sheet1
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
          .value = "Bolívar";

      // Hoja 2
      final sheet2 = excel.sheets['Ciudades'];
      sheet2!.setColWidth(2, 50);
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = 'ID';
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = 'Ciudad';
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = 'Provincia';
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
          .value = 'Origen';
      //
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = "50210";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
          .value = "Cuenca";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
          .value = "Azuay";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1))
          .value = "Normal";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
          .value = "50211";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
          .value = "Sayuasí";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2))
          .value = "Azuay";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 2))
          .value = "Especial";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
          .value = "50212";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
          .value = "Chimbo";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 3))
          .value = "Bolívar";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 3))
          .value = "Especial";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
          .value = "50213";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
          .value = "Guaranda";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 4))
          .value = "Bolívar";
      sheet2
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 4))
          .value = "Normal";
      */

      var nombreFile = "Coberturas-Plantilla-EasyEcommerce";
      excel.save(fileName: '$nombreFile.xlsx');
    } catch (e) {
      print("Error en Generar el reporte!");
    }
  }
}
