import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/add_provider/controllers/sub_provider_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/sellers/add_seller_user/custom_filter_seller_user.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/html_editor.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/my_carousel.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';

class AddSubProvider extends StatefulWidget {
  final List<dynamic> accessTemp;

  const AddSubProvider({super.key, required this.accessTemp});

  @override
  // State<AddSubProvider> createState() => _AddSubProviderState();
  _AddSubProviderState createState() => _AddSubProviderState();
}

class _AddSubProviderState extends StateMVC<AddSubProvider> {
  late SubProviderController _controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  String?
      _selectedImageURL; // Esta variable almacenará la URL de la imagen seleccionada
  List<dynamic> accessTemp = [];
  List vistas = [];
  List<WarehouseModel> warehousesList = [];
  List<String> warehousesToSelect = [];
  String? selectedWarehouse;
  late WrehouseController _warehouseController;
  String idProv = sharedPrefs!.getString("idProvider").toString();
  List<Map<String, String>> selectedWarehouses = [];
  String idProvMaster =
      sharedPrefs!.getString("idProviderUserMaster").toString();
  String idUser = sharedPrefs!.getString("id").toString();

  @override
  void initState() {
    _controller = SubProviderController();
    _warehouseController = WrehouseController();
    accessTemp = widget.accessTemp;
    accessTemp.remove('Mis Transacciones');

    getWarehouses();

    super.initState();
  }

  Future<List<WarehouseModel>> _getWarehousesData() async {
    await _warehouseController.loadWarehouses(idProv);
    return _warehouseController.warehouses;
  }

  getWarehouses() async {
    var responseBodegas = await _getWarehousesData();
    warehousesList = responseBodegas;
    for (var warehouse in warehousesList) {
      if (warehouse.approved == 1 && warehouse.active == 1) {
        // if (warehouse.active == 1) {
        setState(() {
          warehousesToSelect
              .add('${warehouse.id}-${warehouse.branchName}-${warehouse.city}');
        });
      }
    }
    // print(warehousesToSelect);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final String id = Get.parameters['id'] ?? '';
    ButtonState stateOnlyText = ButtonState.idle;
    ButtonState stateOnlyCustomIndicatorText = ButtonState.idle;
    ButtonState stateTextWithIcon = ButtonState.idle;
    ButtonState stateTextWithIconMinWidthState = ButtonState.idle;

    void onPressedCustomButton() {
      setState(() {
        switch (stateOnlyText) {
          case ButtonState.idle:
            stateOnlyText = ButtonState.loading;
            break;
          case ButtonState.loading:
            stateOnlyText = ButtonState.fail;
            break;
          case ButtonState.success:
            stateOnlyText = ButtonState.idle;
            break;
          case ButtonState.fail:
            stateOnlyText = ButtonState.success;
            break;
        }
      });
    }

    return Center(
      child: Column(
        children: [
          const Text(
            'Nuevo Usuario',
            style: TextStyle(
              fontSize: 24.0, // Tamaño de fuente grande
              fontWeight: FontWeight.bold, // Texto en negrita
              color: Color.fromARGB(255, 3, 3, 3), // Color de texto
              fontFamily:
                  'Arial', // Fuente personalizada (cámbiala según tus necesidades)
              letterSpacing: 2.0, // Espaciado entre letras
              decorationColor: Colors.red, // Color del subrayado
              decorationThickness: 2.0, // Grosor del subrayado
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  // TextFormField(
                  //   keyboardType: TextInputType.phone,
                  //   controller: _phone1Controller,
                  //   decoration: InputDecoration(
                  //     fillColor:
                  //         Colors.white, // Color del fondo del TextFormField
                  //     filled: true,
                  //     labelText: 'Telefono',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10.0),
                  //     ),
                  //   ),
                  //   validator: (value) {
                  //     if (value!.isEmpty) {
                  //       return 'Por favor, ingresa tu número de telefono';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  //SizedBox(height: 10),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      fillColor:
                          Colors.white, // Color del fondo del TextFormField
                      filled: true,
                      labelText: 'Nombre de usuario',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Tu nombre de usuario';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      fillColor:
                          Colors.white, // Color del fondo del TextFormField
                      filled: true,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Por favor, ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),
                  Visibility(
                    visible: int.parse(idUser.toString()) ==
                        int.parse(idProvMaster.toString()),
                    child: responsive(
                        Row(
                          children: [
                            const Text(
                              "Bodega",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 250,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Seleccione Bodega',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                items: warehousesToSelect.map((item) {
                                  var parts = item.split('-');
                                  var branchName = parts[1];
                                  var city = parts[2];
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      '$branchName - $city',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                value: selectedWarehouse,
                                onChanged: (value) {
                                  setState(() {
                                    selectedWarehouse = value as String;
                                    selectedWarehouses.add({
                                      "id": selectedWarehouse
                                          .toString()
                                          .split("-")[0]
                                          .toString(),
                                      "name": selectedWarehouse
                                          .toString()
                                          .split("-")[1]
                                          .toString(),
                                    });
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
                        Column(
                          children: [
                            const Text(
                              "Bodega",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(
                              width: 250,
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Seleccione Bodega',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                items: warehousesToSelect.map((item) {
                                  var parts = item.split('-');
                                  var branchName = parts[1];
                                  var city = parts[2];
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      '$branchName - $city',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                value: selectedWarehouse,
                                onChanged: (value) {
                                  setState(() {
                                    selectedWarehouse = value as String;
                                    selectedWarehouses.add({
                                      "id": selectedWarehouse
                                          .toString()
                                          .split("-")[0]
                                          .toString(),
                                      "name": selectedWarehouse
                                          .toString()
                                          .split("-")[1]
                                          .toString(),
                                    });
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
                        context),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: List.generate(selectedWarehouses.length, (index) {
                      String categoryName =
                          selectedWarehouses[index]["name"] ?? "";

                      return Chip(
                        label: Text(categoryName),
                        onDeleted: () {
                          setState(() {
                            selectedWarehouses.removeAt(index);
                            // print("catAct: $selectedCategoriesMap");
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "ACCESOS ACTUALES",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    height: 500,
                    width: 500,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.0,
                            color: Color.fromARGB(255, 224, 222, 222)),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Builder(
                      builder: (context) {
                        return SimpleFilterChips(
                          // chipLabels: widget.accessTemp,
                          chipLabels: accessTemp,
                          onSelectionChanged: (selectedChips) {
                            setState(() {
                              vistas = List.from(selectedChips);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )),
          ),
          // Container(width: 200, height: 300, child: HtmlEditor()),

          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                getLoadingModal(context, false);

                // print("vistas: $vistas");
                // print("selectedWarehouses: $selectedWarehouses");

                if (int.parse(idUser.toString()) !=
                    int.parse(idProvMaster.toString())) {
                  var responseWarehouses =
                      await Connections().getWarehousesBySubProv(idUser);

                  List<String> warehousesList = [];
                  print(responseWarehouses);

                  if (responseWarehouses is List) {
                    for (var element in responseWarehouses) {
                      if (element is String) {
                        warehousesList.add(element);
                      } else {
                        print('Error: Elemento no es una cadena');
                      }
                    }

                    if (warehousesList.isNotEmpty) {
                      for (var element in warehousesList) {
                        selectedWarehouses.add({
                          "id": element.split('|')[0],
                          "name": element.split('|')[1]
                        });
                      }
                    }
                  } else {
                    print('Error: La respuesta no es una lista.');
                  }
                }

                print("selectedWarehouses: $selectedWarehouses");
                if (selectedWarehouses.isEmpty) {
                  Navigator.pop(context);

                  // ignore: use_build_context_synchronously
                  showSuccessModal(
                      context,
                      "Por favor, Debe seleccionar al menos una Bodega.",
                      Icons8.alert);
                } else {
                  var res = await _controller.addSubProvider(UserModel(
                    username: _usernameController.text,
                    email: _emailController.text,
                    blocked: false,
                    permisos: vistas,
                  ));
                  // print(res);
                  for (var warehouse in selectedWarehouses) {
                    Connections().newProviderWarehouse(res, warehouse['id']);
                    // print("ID: ${warehouse['id']}, Name: ${warehouse['name']}");
                  }

                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
                  Colors.blue, // Cambia el color del texto del botón
              padding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 40), // Ajusta el espaciado interno del botón
              textStyle: TextStyle(fontSize: 18), // Cambia el tamaño del texto
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Agrega bordes redondeados
              ),
              elevation: 3, // Agrega una sombra al botón
            ),
            child: Text(
              'Aceptar',
              style: TextStyle(
                fontSize: 18, // Cambia el tamaño del texto
                fontWeight: FontWeight.bold, // Aplica negrita al texto
              ),
            ),
          )
        ],
      ),
    );
    // Segunda sección con información adicional
  }
}
