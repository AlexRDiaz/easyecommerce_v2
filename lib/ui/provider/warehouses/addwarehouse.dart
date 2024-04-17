import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/logistic/custom_imagepicker.dart';
import 'package:frontend/ui/widgets/my_carousel.dart';
import 'package:get/get.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddWarehouse extends StatefulWidget {
  const AddWarehouse({super.key});

  @override
  _AddWarehouseState createState() => _AddWarehouseState();
}

class _AddWarehouseState extends StateMVC<AddWarehouse> {
  late WrehouseController _controller;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameSucursalController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _customerServiceController =
      TextEditingController();
  final TextEditingController _decriptionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  // !***************
  final TextEditingController _collectionDaysController =
      TextEditingController();
  final TextEditingController _collectionScheduleController =
      TextEditingController();
  final TextEditingController _trnasportController = TextEditingController();
  final TextEditingController _timeStartController = TextEditingController();
  final TextEditingController _timeEndController = TextEditingController();

  List<int> selectedDays = [];
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  List<dynamic> activeRoutes = [];
  List<dynamic> secondDropdownOptions = [];
  List<String> formattedList = [];

  XFile? pickedImage = null;

  List<String> provinciasToSelect = [];
  String? selectedProvincia;

  @override
  void initState() {
    _controller = WrehouseController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData().then((_) {
      setState(() {});
    });
  }

  Future loadData() async {
    if (activeRoutes.isEmpty) {
      activeRoutes = await Connections().getActiveRoutes();
    }
    var provinciasList = [];
    provinciasToSelect = [];
    provinciasList = await Connections().getProvincias();
    for (var i = 0; i < provinciasList.length; i++) {
      provinciasToSelect.add('${provinciasList[i]}');
    }
  }

  Column SelectFilter<T>(
    String title,
    TextEditingController controller,
    List<T> listOptions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Color.fromARGB(255, 107, 105, 105)),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 4.5, top: 4.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Color.fromRGBO(6, 6, 6, 1)),
          ),
          height: 50,
          child: DropdownButtonFormField<T>(
            isExpanded: true,
            value: controller.text as T,
            onChanged: (T? newValue) {
              setState(() {
                controller.text = newValue?.toString() ?? "";
                _cityController.text = newValue?.toString().split('-')[0] ?? "";
                // if (newValue != null && newValue != 'TODO') {
                Connections()
                    .getTransportsByRouteLaravel(
                        newValue.toString().split('-')[1])
                    .then((transportofRoute) {
                  // if (secondDropdownOptions.isEmpty) {
                  setState(() {
                    secondDropdownOptions = transportofRoute;
                    formattedList = secondDropdownOptions
                        .map((map) => '${map['nombre']}-${map['id']}')
                        .toList();
                  });
                  // }
                });
                // }

                loadData();
              });
            },
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: listOptions.map<DropdownMenuItem<T>>((T value) {
              String onlyName = value.toString().split('-')[0];
              String onlyId = value.toString().split('-')[1];
              return DropdownMenuItem<T>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    onlyName.toString(),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Column SelectFilterTrans<T>(
    String title,
    TextEditingController controller,
    List<T> listOptions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Color.fromARGB(255, 107, 105, 105)),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 4.5, top: 4.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(color: Color.fromRGBO(6, 6, 6, 1)),
          ),
          height: 50,
          child: DropdownButtonFormField<T>(
            isExpanded: true,
            value: controller.text as T,
            onChanged: (T? newValue) {
              setState(() {
                controller.text = newValue?.toString() ?? "";
                _trnasportController.text =
                    newValue?.toString().split('-')[0] ?? "";

                loadData();
              });
            },
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: listOptions.map<DropdownMenuItem<T>>((T value) {
              String onlyName = value.toString().split('-')[0];
              String onlyId = value.toString().split('-')[1];
              return DropdownMenuItem<T>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    onlyName.toString(),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ButtonState stateOnlyText = ButtonState.idle;

    final TextEditingController returnStatesController = TextEditingController(
        text: activeRoutes.isNotEmpty ? activeRoutes.first : '');
    final TextEditingController formattedListController = TextEditingController(
        text: formattedList.isNotEmpty ? formattedList.first : '');

    return responsive(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              height: 630,
              width: 900,
              child: SingleChildScrollView(
                  // scrollDirection: Axis.vertical,
                  child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Nueva Bodega',
                      style: TextStyle(
                        fontSize: 30.0, // Tamaño de fuente grande
                        fontWeight: FontWeight.normal, // Texto en negrita
                        color: Color.fromARGB(255, 3, 3, 3), // Color de texto
                        fontFamily:
                            'Arial', // Fuente personalizada (cámbiala según tus necesidades)
                        letterSpacing: 2.0, // Espaciado entre letras
                        decorationColor: Colors.red, // Color del subrayado
                        decorationThickness: 2.0, // Grosor del subrayado
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFieldWithIcon(
                      controller: _nameSucursalController,
                      labelText: 'Nombre de bodega',
                      icon: Icons.store_mall_directory,
                    ),
                    SizedBox(height: 10),
                    TextFieldWithIcon(
                      controller: _addressController,
                      labelText: 'Dirección',
                      icon: Icons.place,
                    ),
                    SizedBox(height: 10),
                    TextFieldWithIcon(
                      controller: _referenceController,
                      labelText: 'Referencia',
                      icon: Icons.bookmark_border,
                    ),
                    SizedBox(height: 10),
                    TextFieldWithIcon(
                      labelText: 'Número Atención al Cliente',
                      controller: _customerServiceController,
                      icon: Icons.phone,
                    ),
                    SizedBox(height: 10),
                    TextFieldWithIcon(
                      controller: _decriptionController,
                      labelText: 'Descripción',
                      icon: Icons.description,
                    ),
                    Text(
                      "Provincia",
                      style:
                          TextStyle(color: Color.fromARGB(255, 107, 105, 105)),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
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
                            });
                            // print(newProvincia);
                          },
                        ),
                      ),
                    ),

                    // Container(height: 80, child: ImagePickerExample()),
                    SizedBox(height: 25),
                    Row(children: [
                      Container(
                          width: 250,
                          padding: EdgeInsets.only(top: 10.0),
                          height: 100,
                          child: ImagePickerExample(
                            onImageSelected: (XFile? image) {
                              setState(() {
                                pickedImage = image;
                              });
                            },
                            label: 'Ninguna Imagen Seleccionada',
                          )),
                      Container(
                        width: 200,
                        child: SelectFilter(
                            'Ciudad', returnStatesController, activeRoutes),
                      ),
                      SizedBox(width: 30),
                      Container(
                        width: 200,
                        child: SelectFilterTrans('Transporte de Recolección',
                            formattedListController, formattedList),
                      ),
                    ]),
                    SizedBox(height: 10),

                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Días de Recolección",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 107, 105, 105))),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.38,

                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 105, 104, 104)),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              // padding: EdgeInsets.all(5.0),
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder: (context, index) {
                                  int dayValue = index + 1;

                                  List<String> daysOfWeek = [
                                    "Lunes",
                                    "Martes",
                                    "Miércoles",
                                    "Jueves",
                                    "Viernes"
                                  ];
                                  String dayName = daysOfWeek[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4.0, right: 4.0),
                                    child: FilterChip(
                                      backgroundColor:
                                          ColorsSystem().colorBlack,
                                      label: Text(
                                        dayName,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      selected: selectedDays.contains(dayValue),
                                      onSelected: (isSelected) {
                                        setState(() {
                                          if (isSelected) {
                                            selectedDays.add(dayValue);
                                          } else {
                                            selectedDays.remove(dayValue);
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(width: 20.0,),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Horario de Recolección:",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 107, 105, 105))),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.38,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 105, 104, 104)),
                                  borderRadius: BorderRadius.circular(10.0)),
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildTimePicker("Desde", startTime,
                                        (time) {
                                      setState(() {
                                        startTime = time;
                                      });
                                    }, _timeStartController),
                                  ),
                                  SizedBox(width: 50),
                                  Expanded(
                                    child: _buildTimePicker("Hasta", endTime,
                                        (time) {
                                      setState(() {
                                        endTime = time;
                                      });
                                    }, _timeEndController),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Text("Horario de Recolección:",
                    //             style: TextStyle(
                    //                 color: Color.fromARGB(255, 107, 105, 105))),

                    //         Container(
                    //           width: 300,
                    //           decoration: BoxDecoration(
                    //               border: Border.all(
                    //                   color: const Color.fromARGB(
                    //                       255, 105, 104, 104)),
                    //               borderRadius: BorderRadius.circular(10.0)),
                    //           padding: EdgeInsets.all(10.0),
                    //           child: Row(
                    //             children: [
                    //               Expanded(
                    //                 child: _buildTimePicker("Inicio", startTime,
                    //                     (time) {
                    //                   setState(() {
                    //                     startTime = time;
                    //                   });
                    //                 }, _timeStartController),
                    //               ),
                    //               // SizedBox(width: 10),
                    //               Expanded(
                    //                 child:
                    //                     _buildTimePicker("Fin", endTime, (time) {
                    //                   setState(() {
                    //                     endTime = time;
                    //                   });
                    //                 }, _timeEndController),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),

                    // Row(
                    //   children: [
                    //     Container(
                    //       width: 200,
                    //       child: SelectFilter(
                    //           'Ciudad', returnStatesController, activeRoutes),
                    //     ),
                    //     SizedBox(width: 30),
                    //     Container(
                    //       width: 200,
                    //       child: SelectFilterTrans('Transporte de Recolección',
                    //           formattedListController, formattedList),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 30),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                var responseChargeImage =
                                    await Connections().postDoc(pickedImage!);
                                // ! cambiar  segun lo que diga el modelo de warehouses
                                _controller.addWarehouse(WarehouseModel(
                                    branchName: _nameSucursalController.text,
                                    address: _addressController.text,
                                    customerphoneNumber:
                                        _customerServiceController.text,
                                    reference: _referenceController.text,
                                    description: _decriptionController.text,
                                    url_image: responseChargeImage[1],
                                    id_provincia: int.parse(selectedProvincia
                                        .toString()
                                        .split('-')[1]),
                                    city: _cityController.text,
                                    collection: {
                                      "collectionDays": selectedDays,
                                      "collectionSchedule":
                                          "${_timeStartController.text} - ${_timeEndController.text}",
                                      "collectionTransport":
                                          _trnasportController.text
                                    },
                                    providerId: int.parse(sharedPrefs!
                                        .getString("idProvider")
                                        .toString())));

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: ColorsSystem()
                                    .colorSelectMenu, // Cambia el color del texto del botón
                                padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal:
                                        40), // Ajusta el espaciado interno del botón
                                textStyle: TextStyle(
                                  fontSize: 18,
                                ), // Cambia el tamaño del texto
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Agrega bordes redondeados
                                ),
                                elevation: 3, // Agrega una sombra al botón
                              ),
                              child: Text(
                                'Aceptar',
                                style: TextStyle(
                                  fontSize: 14, // Cambia el tamaño del texto
                                  fontWeight: FontWeight
                                      .normal, // Aplica negrita al texto
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                              child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color.fromARGB(255, 12, 37,
                                  49), // Cambia el color del texto del botón
                              padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal:
                                      40), // Ajusta el espaciado interno del botón
                              textStyle: TextStyle(
                                fontSize: 18,
                              ), // Cambia el tamaño del texto
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Agrega bordes redondeados
                              ),
                              elevation: 3, // Agrega una sombra al botón
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 14, // Cambia el tamaño del texto
                                fontWeight: FontWeight
                                    .normal, // Aplica negrita al texto
                              ),
                            ),
                          )),
                        ]),
                  ],
                ),
              )),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              height: 630,
              // width: 400,
              child: SingleChildScrollView(
                  // scrollDirection: Axis.vertical,
                  child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Nueva Bodega',
                      style: TextStyle(
                        fontSize: 30.0, // Tamaño de fuente grande
                        fontWeight: FontWeight.normal, // Texto en negrita
                        color: Color.fromARGB(255, 3, 3, 3), // Color de texto
                        fontFamily:
                            'Arial', // Fuente personalizada (cámbiala según tus necesidades)
                        letterSpacing: 2.0, // Espaciado entre letras
                        decorationColor: Colors.red, // Color del subrayado
                        decorationThickness: 2.0, // Grosor del subrayado
                      ),
                    ),
                    SizedBox(height: 30),
                    TextFieldWithIcon(
                      controller: _nameSucursalController,
                      labelText: 'Nombre de bodega',
                      icon: Icons.store_mall_directory,
                    ),
                    SizedBox(height: 10),
                    TextFieldWithIcon(
                      controller: _addressController,
                      labelText: 'Dirección',
                      icon: Icons.place,
                    ),
                    SizedBox(height: 10),
                    TextFieldWithIcon(
                      controller: _referenceController,
                      labelText: 'Referencia',
                      icon: Icons.bookmark_border,
                    ),
                    SizedBox(height: 10),
                    TextFieldWithIcon(
                      labelText: 'Número Atención al Cliente',
                      controller: _customerServiceController,
                      icon: Icons.phone,
                    ),
                    SizedBox(height: 10),
                    TextFieldWithIcon(
                      controller: _decriptionController,
                      labelText: 'Descripción',
                      icon: Icons.description,
                    ),
                    SizedBox(height: 10),
                    // Container(height: 80, child: ImagePickerExample()),
                    SizedBox(width: 5),
                    Row(children: [
                      Column(
                        children: [
                          Container(
                              width: 210,
                              padding: EdgeInsets.only(top: 5.0),
                              height: 100,
                              child: ImagePickerExample(
                                  onImageSelected: (XFile? image) {
                                    setState(() {
                                      pickedImage = image;
                                    });
                                  },
                                  label: 'Ninguna Imagen Seleccionada')),
                        ],
                      ),
                    ]),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 220,
                          child: SelectFilter(
                              'Ciudad', returnStatesController, activeRoutes),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 220,
                          child: SelectFilterTrans('Transporte de Recolección',
                              formattedListController, formattedList),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Días de Recolección",
                            style: TextStyle(
                                color: Color.fromARGB(255, 107, 105, 105))),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(255, 105, 104, 104)),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      // padding: EdgeInsets.all(5.0),
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          int dayValue = index + 1;

                          List<String> daysOfWeek = [
                            "Lunes",
                            "Martes",
                            "Miércoles",
                            "Jueves",
                            "Viernes"
                          ];
                          String dayName = daysOfWeek[index];

                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 4.0, right: 4.0),
                            child: FilterChip(
                              backgroundColor: ColorsSystem().colorBlack,
                              label: Text(
                                dayName,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              selected: selectedDays.contains(dayValue),
                              onSelected: (isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    selectedDays.add(dayValue);
                                  } else {
                                    selectedDays.remove(dayValue);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Horario de Recolección:",
                            style: TextStyle(
                                color: Color.fromARGB(255, 107, 105, 105)))
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      // width: 300,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 105, 104, 104)),
                          borderRadius: BorderRadius.circular(10.0)),
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildTimePicker("Desde", startTime, (time) {
                                setState(() {
                                  startTime = time;
                                });
                              }, _timeStartController),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              _buildTimePicker("Hasta", endTime, (time) {
                                setState(() {
                                  endTime = time;
                                });
                              }, _timeEndController),
                            ],
                          )
                          // Expanded(
                          //   child:
                          //       _buildTimePicker("Inicio", startTime, (time) {
                          //     setState(() {
                          //       startTime = time;
                          //     });
                          //   },_timeStartController),
                          // ),
                          // // SizedBox(width: 10),
                          // Expanded(
                          //   child: _buildTimePicker("Fin", endTime, (time) {
                          //     setState(() {
                          //       endTime = time;
                          //     });
                          //   },_timeEndController),
                          // ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                /*
                                var responseChargeImage =
                                    await Connections().postDoc(pickedImage!);
                                _controller.addWarehouse(WarehouseModel(
                                    branchName: _nameSucursalController.text,
                                    address: _addressController.text,
                                    customerphoneNumber:
                                        _customerServiceController.text,
                                    reference: _referenceController.text,
                                    description: _decriptionController.text,
                                    url_image: responseChargeImage[1],
                                    id_provincia: int.parse(selectedProvincia
                                        .toString()
                                        .split('-')[1]),
                                    city: _cityController.text,
                                    collection: {
                                      "collectionDays": selectedDays,
                                      "collectionSchedule":
                                          "${_timeStartController.text} - ${_timeEndController.text}",
                                      "collectionTransport":
                                          _trnasportController.text
                                    },
                                    providerId: int.parse(sharedPrefs!
                                        .getString("idProvider")
                                        .toString())));
*/
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: ColorsSystem()
                                    .colorSelectMenu, // Cambia el color del texto del botón
                                padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal:
                                        40), // Ajusta el espaciado interno del botón
                                textStyle: TextStyle(
                                  fontSize: 18,
                                ), // Cambia el tamaño del texto
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Agrega bordes redondeados
                                ),
                                elevation: 3, // Agrega una sombra al botón
                              ),
                              child: Text(
                                'Aceptar',
                                style: TextStyle(
                                  fontSize: 12, // Cambia el tamaño del texto
                                  fontWeight: FontWeight
                                      .normal, // Aplica negrita al texto
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                              child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Color.fromARGB(255, 12, 37,
                                  49), // Cambia el color del texto del botón
                              padding: EdgeInsets.symmetric(
                                  vertical: 15,
                                  horizontal:
                                      40), // Ajusta el espaciado interno del botón
                              textStyle: TextStyle(
                                fontSize: 18,
                              ), // Cambia el tamaño del texto
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Agrega bordes redondeados
                              ),
                              elevation: 3, // Agrega una sombra al botón
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 12, // Cambia el tamaño del texto
                                fontWeight: FontWeight
                                    .normal, // Aplica negrita al texto
                              ),
                            ),
                          )),
                        ]),
                  ],
                ),
              )),
            ),
          ],
        ),
        context);
  }

  Widget _buildTimePicker(
    String label,
    TimeOfDay selectedTime,
    Function(TimeOfDay) onTimeChanged,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: ColorsSystem().colorSelectMenu,
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );

                if (pickedTime != null && pickedTime != selectedTime) {
                  onTimeChanged(pickedTime);
                }
                controller.text = "${selectedTime.hour}:${selectedTime.minute}";
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange, // Define el color del texto
              ),
              child: Text(
                "${selectedTime.hour}:${selectedTime.minute}",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class TextFieldWithIcon extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;

  const TextFieldWithIcon({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: ColorsSystem().colorSelectMenu),
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          // ... [Otros estilos]
        ),
        style: const TextStyle(
          // fontFamily: 'TuFuentePersonalizada', // Cambia esto por tu fuente
          color: Colors.black,
        ),
        // ... [Validaciones y otros ajustes]
      ),
    );
  }
}
