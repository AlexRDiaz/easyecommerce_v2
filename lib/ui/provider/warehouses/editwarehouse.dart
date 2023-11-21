import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class EditWarehouse extends StatefulWidget {
  final WarehouseModel warehouse;

  const EditWarehouse({Key? key, required this.warehouse}) : super(key: key);

  @override
  _EditWarehouseState createState() => _EditWarehouseState();
}

class _EditWarehouseState extends StateMVC<EditWarehouse> {
  late WrehouseController _controller;
  late Future<List<WarehouseModel>> _futureWarehouseData;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _cityController;
  TextEditingController _trnasportController;
  TextEditingController _timeStartController;
  TextEditingController _timeEndController;

  List<int> selectedDays = [];

  List<dynamic> activeRoutes = [];
  List<dynamic> secondDropdownOptions = [];
  List<String> formattedList = [];
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();

  XFile? pickedImage = null;

  _EditWarehouseState()
      : _cityController = TextEditingController(),
        _trnasportController = TextEditingController(),
        _timeStartController = TextEditingController(),
        _timeEndController = TextEditingController();

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
    TextEditingController _nameSucursalController =
        TextEditingController(text: widget.warehouse.branchName);
    TextEditingController _addressController =
        TextEditingController(text: widget.warehouse.address);
    TextEditingController _referenceController =
        TextEditingController(text: widget.warehouse.reference);
    TextEditingController _descriptionController =
        TextEditingController(text: widget.warehouse.description);
    TextEditingController _collectionController =
        TextEditingController(text: widget.warehouse.collection);
    TextEditingController _cityControllerdb =
        TextEditingController(text: widget.warehouse.city);
    // TextEditingController _trnasportController = TextEditingController(text: widget.warehouse.collection);
    // TextEditingController _timeStartController = TextEditingController(text: widget.warehouse.collection);
    // TextEditingController _timeEndController   = TextEditingController(text: widget.warehouse.collection);

    // final TextEditingController _timeStartController = TextEditingController();
    // final TextEditingController _timeEndController = TextEditingController();

    // ... Agrega más controladores si tienes más campos

    // Decodificar el JSON
    Map<String, dynamic> warehouseJson =
        json.decode(_collectionController.text);

    // Acceder a la propiedad collectionTransport
    String collectionTransport = warehouseJson['collectionTransport'];
    String collectionSchedule = warehouseJson['collectionSchedule'];
    List<dynamic> collectionDays = warehouseJson['collectionDays'];

    // TextEditingController _trnasportController = TextEditingController(text: collectionTransport);
    TextEditingController _timeStartControllerdb =
        TextEditingController(text: collectionSchedule.split('-')[0]);
    TextEditingController _timeEndControllerdb =
        TextEditingController(text: collectionSchedule.split('-')[0]);

    TextEditingController _scheduleController =
        TextEditingController(text: collectionSchedule);
    List<int> listaDeEnteros =
        collectionDays.map((item) => item as int).toList();
    // TextEditingController _daysController =
    //     TextEditingController(text: );

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
              height: 600,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          const Text(
                            'Editar Bodega',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(
                            width: 50,
                          ),
                          Tooltip(
                            message: "Desactivar Bodega",
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _controller
                                    .deleteWarehouse(widget.warehouse.id!)
                                    .then((_) {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _futureWarehouseData = _loadWarehouses();
                                    SnackBarHelper.showOkSnackBar(
                                        context, "BODEGA INACTIVA.");
                                  });
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Tooltip(
                            message: "Activar Bodega",
                            child: IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _controller
                                    .activateWarehouse(widget.warehouse.id!)
                                    .then((_) {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _futureWarehouseData = _loadWarehouses();
                                    SnackBarHelper.showOkSnackBar(
                                        context, "BODEGA ACTIVA.");
                                  });
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      // content:
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
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
                              controller: _descriptionController,
                              labelText: 'Descripción',
                              icon: Icons.description,
                            ),
                            SizedBox(height: 20),
                            Text("Seleccione si desea cambiar estas opciones: ",
                                style: TextStyle(
                                    color: ColorsSystem().colorRedPassword)),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: Color.fromARGB(255, 95, 95, 95)),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Ciudad: ",
                                          style: TextStyle(
                                            color:
                                                ColorsSystem().colorSelectMenu,
                                          )),
                                      Text(
                                        "${_cityControllerdb.text}",
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Transporte de Recolección: ",
                                        style: TextStyle(
                                          color: ColorsSystem().colorSelectMenu,
                                        ),
                                      ),
                                      Text(
                                        "$collectionTransport",
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Text("Horario de Recoleción: ",
                                              style: TextStyle(
                                                  color: ColorsSystem()
                                                      .colorSelectMenu)),
                                          Text(
                                              "${_timeStartControllerdb.text}-${_timeEndControllerdb.text}")
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text("Días de Recoleción: ",
                                          style: TextStyle(
                                              color: ColorsSystem()
                                                  .colorSelectMenu)),
                                      Text(
                                          "${mapNumbersToDays(collectionDays)}")
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  width: 250,
                                  child: SelectFilter('Ciudad',
                                      returnStatesController, activeRoutes),
                                ),
                                SizedBox(width: 50),
                                Container(
                                  width: 250,
                                  child: SelectFilterTrans(
                                      'Transporte de Recolección',
                                      formattedListController,
                                      formattedList),
                                ),
                                SizedBox(width: 50),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text("Horario de Recolección",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 107, 105, 105))),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          padding:
                                              EdgeInsets.only(bottom: 20.0),
                                          child: _buildTimePicker(
                                              "Inicio", startTime, (time) {
                                            setState(() {
                                              startTime = time;
                                            });
                                          }, _timeStartController),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          padding:
                                              EdgeInsets.only(bottom: 20.0),
                                          child: _buildTimePicker(
                                              "Fin", endTime, (time) {
                                            setState(() {
                                              endTime = time;
                                            });
                                          }, _timeEndController),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            SizedBox(height: 20),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Días de Recolección",
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 107, 105, 105))),
                                Container(
                                  width: 600,
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
                                          selected:
                                              selectedDays.contains(dayValue),
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
                            SizedBox(height: 20),

                            // ... Agrega más TextFields para cada campo editable
                          ],
                        ),
                      ),
                      // actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_trnasportController.text == "") {
                                    _trnasportController =
                                        TextEditingController(
                                            text: collectionTransport);
                                  }
                                  if (selectedDays.isEmpty) {
                                    selectedDays = listaDeEnteros;
                                  }
                                  // ! LAS FECHAS DA PROBLEMA CAMBIA EN EL FRONT PERO LAS VARIABLES NO CAMBIAN DE VALOR
                                  if (_timeStartController.text != "" &&
                                      _timeEndController.text != "") {
                                    _timeStartControllerdb =
                                        TextEditingController(
                                            text: _timeStartController.text);
                                    _timeEndControllerdb =
                                        TextEditingController(
                                            text: _timeEndController.text);
                                    // "${_timeStartController.text} - ${_timeEndController.text}";

                                    collectionSchedule =
                                        " ${_timeStartControllerdb.text}-${_timeEndControllerdb.text}";
                                  }
                                  if (_cityController.text == "") {
                                    _cityController = TextEditingController(
                                        text: _cityControllerdb.text);
                                  }

                                  print(
                                      "Nombre de bodega: ${_nameSucursalController.text}");
                                  print(
                                      "Dirección: ${_addressController.text}");
                                  print(
                                      "Referencia: ${_referenceController.text}");
                                  print(
                                      "Descripción: ${_descriptionController.text}");
                                  print("Ciudad: ${_cityController.text}");
                                  print("Días de Recolección: $selectedDays");
                                  print(
                                      "Horario de Recolección: ${_timeStartControllerdb.text}-${_timeEndControllerdb.text}");
                                  print(
                                      "Transporte de Recolección: ${_trnasportController.text}");
                                  print("collec: $collectionSchedule ");
                                  print("*******************");
                                  // var responseChargeImage =
                                  //     await Connections().postDoc(pickedImage!);
                                  // _controller.updateWarehouse(
                                  //     widget.warehouse.id!,
                                  //     _nameSucursalController.text,
                                  //     _addressController.text,
                                  //     _referenceController.text,
                                  //     _descriptionController.text,
                                  //     responseChargeImage[1],
                                  //     _cityController.text, {
                                  //   "collectionDays": selectedDays,
                                  //   "collectionSchedule":
                                  //       "${_timeStartController.text} - ${_timeEndController.text}",
                                  //   "collectionTransport":
                                  //       _trnasportController.text
                                  // }).then((_) {
                                  //   Navigator.of(context).pop();
                                  //   setState(() {
                                  //     // Esto forzará la reconstrucción de la vista con los datos actualizados
                                  //     _futureWarehouseData = _loadWarehouses();
                                  //     SnackBarHelper.showOkSnackBar(
                                  //         context, "DATOS ACTUALIZADOS.");
                                  //   });
                                  // });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsSystem()
                                      .colorSelectMenu, // Color del botón 'Aceptar'
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Aceptar'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Cierra el diálogo
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsSystem()
                                      .colorBlack, // Color del botón 'Cancelar'
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              height: 600,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          const Text(
                            'Editar Bodega',
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Tooltip(
                            message: "Desactivar Bodega",
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _controller
                                    .deleteWarehouse(widget.warehouse.id!)
                                    .then((_) {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _futureWarehouseData = _loadWarehouses();
                                    SnackBarHelper.showOkSnackBar(
                                        context, "BODEGA INACTIVA.");
                                  });
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Tooltip(
                            message: "Activar Bodega",
                            child: IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _controller
                                    .activateWarehouse(widget.warehouse.id!)
                                    .then((_) {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _futureWarehouseData = _loadWarehouses();
                                    SnackBarHelper.showOkSnackBar(
                                        context, "BODEGA ACTIVA.");
                                  });
                                });
                              },
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      // content:
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
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
                              controller: _descriptionController,
                              labelText: 'Descripción',
                              icon: Icons.description,
                            ),
                            SizedBox(height: 20),
                            Text("Seleccione si desea cambiar estas opciones: ",
                                style: TextStyle(
                                    color: ColorsSystem().colorRedPassword)),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: Color.fromARGB(255, 95, 95, 95)),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Ciudad: ",
                                          style: TextStyle(
                                              color: ColorsSystem()
                                                  .colorSelectMenu,
                                              fontSize: 14)),
                                      Text(
                                        "${_cityController.text}",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "Transporte de R: ",
                                        style: TextStyle(
                                            color:
                                                ColorsSystem().colorSelectMenu,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "$collectionTransport",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Text("Horario de R: ",
                                              style: TextStyle(
                                                  color: ColorsSystem()
                                                      .colorSelectMenu,
                                                  fontSize: 14)),
                                          Text(
                                            "${collectionSchedule}",
                                            style: TextStyle(fontSize: 14),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text("Días de R: ",
                                          style: TextStyle(
                                              color: ColorsSystem()
                                                  .colorSelectMenu,
                                              fontSize: 14)),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Text(
                                          "${mapNumbersToDays(collectionDays)}",
                                          style: TextStyle(fontSize: 14))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  width: 250,
                                  child: SelectFilter('Ciudad',
                                      returnStatesController, activeRoutes),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  key: UniqueKey(),
                                  width: 250,
                                  child: SelectFilterTrans(
                                      'Transporte de Recolección',
                                      formattedListController,
                                      formattedList),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Horario de Recolección",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 107, 105, 105))),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePicker("Inicio", startTime,
                                      (time) {
                                    setState(() {
                                      startTime = time;
                                    });
                                  }, _timeStartController),
                                ),
                                // SizedBox(width: 10),
                                Expanded(
                                  child:
                                      _buildTimePicker("Fin", endTime, (time) {
                                    setState(() {
                                      endTime = time;
                                    });
                                  }, _timeEndController),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Días de Recolección",
                                    style: TextStyle(
                                        color: Color.fromARGB(
                                            255, 107, 105, 105))),
                                Container(
                                  // width: 300,
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
                                          selected:
                                              selectedDays.contains(dayValue),
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
                            SizedBox(height: 20),

                            // ... Agrega más TextFields para cada campo editable
                          ],
                        ),
                      ),
                      // actions: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Implementa la lógica de actualización aquí
                                  var responseChargeImage =
                                      await Connections().postDoc(pickedImage!);
                                  _controller.updateWarehouse(
                                      widget.warehouse.id!,
                                      _nameSucursalController.text,
                                      _addressController.text,
                                      _referenceController.text,
                                      _descriptionController.text,
                                      responseChargeImage[1],
                                      _cityController.text, {
                                    "collectionDays": selectedDays,
                                    "collectionSchedule":
                                        "${_timeStartController.text} - ${_timeEndController.text}",
                                    "collectionTransport":
                                        _trnasportController.text
                                  }).then((_) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      // Esto forzará la reconstrucción de la vista con los datos actualizados
                                      _futureWarehouseData = _loadWarehouses();
                                      SnackBarHelper.showOkSnackBar(
                                          context, "DATOS ACTUALIZADOS.");
                                    });
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsSystem()
                                      .colorSelectMenu, // Color del botón 'Aceptar'
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Aceptar'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Cierra el diálogo
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsSystem()
                                      .colorBlack, // Color del botón 'Cancelar'
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        context);
  }

  Future<List<WarehouseModel>> _loadWarehouses([String query = '']) async {
    await _controller.loadWarehouses();
    if (query.isEmpty) {
      return _controller.warehouses;
    } else {
      return _controller.warehouses.where((warehouse) {
        // Puedes ajustar los criterios de búsqueda según tus necesidades
        return warehouse.branchName!
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    }
  }

  String mapNumbersToDays(List<dynamic> numbers) {
    Map<int, String> daysMap = {
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
    };

    List<String?> days = numbers.map((number) {
      return (number >= 1 && number <= 5) ? daysMap[number] : null;
    }).toList();

    // Filtra los días válidos y los une con '-'
    return days.where((day) => day != null).join('-');
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
        ),
        style: const TextStyle(fontFamily: 'Arial', color: Colors.black),
      ),
    );
  }
}
