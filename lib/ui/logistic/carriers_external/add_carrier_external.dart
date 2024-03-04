import 'package:awesome_dialog/awesome_dialog.dart';
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
  TextEditingController pendienteController = TextEditingController(text: "");
  TextEditingController enBodegaProvController =
      TextEditingController(text: "");

  final TextEditingController _typeController = TextEditingController();

  var statusToSend;
  List typeToSend = [];

  List<String> parroquiasToSelect = [];
  String? selectedParroquia;

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
      height: screenHeight * 0.85,
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
                      icon: Icons.description,
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
                        typeToSend.add(type);
                      }
                      print("typeToSend: $typeToSend");
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
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    //
                    showStatus(context);
                  },
                  child: const Text(
                    "Agregar Estados Equivalentes",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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

              // const Text(
              //   "Costo de Transporte",
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: TextButton(
              //     onPressed: () async {
              //       //
              //     },
              //     child: const Text(
              //       "Agregar Nuevo Coste Transporte",
              //       style: TextStyle(fontWeight: FontWeight.bold),
              //     ),
              //   ),
              // ),
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
                        // print(_controllers.mailController.text);
                        getLoadingModal(context, false);

                        String phoneNumber = phoneController.text;
                        if (phoneNumber.startsWith("0")) {
                          phoneNumber = "+593${phoneNumber.substring(1)}";
                        }
                        print("esteeeeee");
                        var responseCreate = await Connections()
                            .createCarrierExternal(
                                nameController.text,
                                phoneNumber,
                                mailController.text,
                                addressController.text,
                                statusToSend);

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
            width: screenWith > 600 ? screenWith * 0.3 : screenWith,
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
                            controller: enOficinaStatusController,
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
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text(
                          "PENDIENTE:",
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
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: Size(200, 40)),
                        onPressed: () async {
                          //
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

                          Navigator.pop(context);
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
}
