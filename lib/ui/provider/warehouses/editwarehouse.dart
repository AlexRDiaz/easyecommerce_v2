import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/widgets/logistic/custom_imagepicker.dart';
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
  TextEditingController _provinciaController;

  List<int> selectedDays = [];

  List<dynamic> activeRoutes = [];
  List<dynamic> secondDropdownOptions = [];
  List<dynamic> provincias = [];
  String provnam = "";
  List<String> formattedList = [];

  XFile? pickedImage;

  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();

  var auxili;
  List<int> listaDeEnterosX = [];

  _EditWarehouseState()
      : _cityController = TextEditingController(),
        _trnasportController = TextEditingController(),
        _timeStartController = TextEditingController(),
        _timeEndController = TextEditingController(),
        _provinciaController = TextEditingController();
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
    try {
      if (provincias.isEmpty) {
        provincias = await Connections().getProvincias();
        for (String provincia in provincias) {
          String id = provincia.toString().split('-')[1];
          if (int.parse(id) == widget.warehouse.id_provincia) {
            provnam = provincia.toString().split('-')[0];
          }
        }
      }
      if (activeRoutes.isEmpty) {
        activeRoutes = await Connections().getActiveRoutes();
      }
    } catch (e) {
      print(" Load Data Error: $e " );
    }
  }

// ! selecfitlter with preselect value of controller
  Column SelectFilterN<T>(
    String title,
    TextEditingController controller,
    List<T> listOptions,
  ) {
    T? selectedValue;

    // Buscar el valor en la lista de opciones
    for (T option in listOptions) {
      String onlyName = option.toString().split('-')[0];
      if (onlyName == controller.text) {
        selectedValue = option;
        break;
      }
    }

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
            value: selectedValue,
            onChanged: (T? newValue) {
              setState(() {
                controller.text = newValue?.toString().split('-')[0] ?? "";
                _cityController.text = newValue?.toString().split('-')[0] ?? "";

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

// ! ************************************************

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
                // Connections()
                //     .getTransportsByRouteLaravel(
                //         newValue.toString().split('-')[1])
                //     .then((transportofRoute) {
                //   // if (secondDropdownOptions.isEmpty) {
                //   setState(() {
                //     secondDropdownOptions = transportofRoute;
                //     formattedList = secondDropdownOptions
                //         .map((map) => '${map['nombre']}-${map['id']}')
                //         .toList();
                //   });
                //   // }
                // });
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
    T? selectedValue;
    for (T option in listOptions) {
      String onlyName = option.toString().split('-')[0];
      if (onlyName == controller.text) {
        selectedValue = option;
        break;
      }
    }
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
            value: selectedValue,
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

  Column SelectFilterProvincia<T>(
    String title,
    String provName,
    // TextEditingController controller,
    List<T> listOptions,
  ) {
    T? selectedValue;

    // Buscar el valor en la lista de opciones
    for (T option in listOptions) {
      String onlyName = option.toString().split('-')[0];
      if (onlyName == provName) {
        selectedValue = option;
        break;
      }
    }

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
            value: selectedValue,
            onChanged: (T? newValue) {
              setState(() {
                // Actualiza el controlador con el nombre de la provincia
                provName = newValue?.toString().split('-')[0] ?? "";
                _provinciaController.text = newValue!.toString().split('-')[1];
                // Aquí puedes actualizar otros controladores o variables según sea necesario
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
                    onlyName,
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
    TextEditingController _customerServiceController =
        TextEditingController(text: widget.warehouse.customerphoneNumber);
    TextEditingController _referenceController =
        TextEditingController(text: widget.warehouse.reference);
    TextEditingController _descriptionController =
        TextEditingController(text: widget.warehouse.description);
    TextEditingController _collectionController =
        TextEditingController(text: widget.warehouse.collection);
    TextEditingController _cityControllerdb =
        TextEditingController(text: widget.warehouse.city);
    TextEditingController _urlImageController =
        TextEditingController(text: widget.warehouse.url_image);
    TextEditingController _provinciaControllerdb =
        TextEditingController(text: widget.warehouse.id_provincia.toString());

    // Decodificar el JSON
    Map<String, dynamic> warehouseJson =
        json.decode(_collectionController.text);

    // Acceder a la propiedad collectionTransport
    String collectionTransport = warehouseJson['collectionTransport'];
    String collectionSchedule = warehouseJson['collectionSchedule'];
    List<dynamic> collectionDays = warehouseJson['collectionDays'];

    TextEditingController _timeStartControllerdb =
        TextEditingController(text: collectionSchedule.split('-')[0]);
    TextEditingController _timeEndControllerdb =
        TextEditingController(text: collectionSchedule.split('-')[1]);
    TextEditingController _scheduleController =
        TextEditingController(text: collectionSchedule);
    TextEditingController _trnsportController =
        TextEditingController(text: collectionTransport);

    List<int> listaDeEnteros =
        collectionDays.map((item) => item as int).toList();

    final TextEditingController returnStatesController = TextEditingController(
        text: activeRoutes.isNotEmpty ? activeRoutes.first : '');
    final TextEditingController formattedListController = TextEditingController(
        text: formattedList.isNotEmpty ? formattedList.first : '');

    return responsive(
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width * 1,
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
                          widget.warehouse.active == 1
                              ? Tooltip(
                                  message: "Desactivar Bodega",
                                  child: IconButton(
                                    icon: const Icon(Icons.lock,
                                        color: Colors.red),
                                    onPressed: () {
                                      _controller
                                          .deleteWarehouse(widget.warehouse.id!)
                                          .then((_) {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _futureWarehouseData =
                                              _loadWarehouses();
                                          SnackBarHelper.showErrorSnackBar(
                                              context, "BODEGA INACTIVA.");
                                        });
                                      });
                                    },
                                  ),
                                )
                              : Tooltip(
                                  message: "Activar Bodega",
                                  child: IconButton(
                                    icon:
                                        Icon(Icons.check, color: Colors.green),
                                    onPressed: () {
                                      _controller
                                          .activateWarehouse(
                                              widget.warehouse.id!)
                                          .then((_) {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _futureWarehouseData =
                                              _loadWarehouses();
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
                              labelText: 'Número Atención al Cliente',
                              controller: _customerServiceController,
                              icon: Icons.phone,
                            ),
                            SizedBox(height: 10),
                            TextFieldWithIcon(
                              controller: _descriptionController,
                              labelText: 'Descripción',
                              icon: Icons.description,
                            ),
                            Row(children: [
                              Column(
                                children: [
                                  Container(
                                      padding: EdgeInsets.only(top: 15.0),
                                      height: 140,
                                      child: ImagePickerExample(
                                        onImageSelected: (XFile? image) {
                                          setState(() {
                                            pickedImage = image;
                                          });
                                        },
                                        label: 'Seleccione Nueva Imagen',
                                      )),
                                ],
                              ),
                            ]),
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
                                  child: SelectFilterN('Ciudad',
                                      _cityControllerdb, activeRoutes),
                                ),
                                SizedBox(width: 50),
                                Container(
                                  width: 250,
                                  child: SelectFilterTrans(
                                      'Transporte de Recolección',
                                      _trnsportController,
                                      formattedList),
                                ),
                                // SizedBox(width: 50),
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
                                  width: 520,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 105, 104, 104)),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  // padding: EdgeInsets.all(5.0),
                                  height: 50,
                                  child: DiasSeleccionadosWidget(
                                    initialSelectedDays: listaDeEnteros,
                                    onSelectionChanged: (selectedDaysInter) {
                                      setState(() {
                                        listaDeEnterosX = selectedDaysInter;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Horario de Recolección",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 107, 105, 105))),
                                    Container(
                                      width: 520,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 105, 104, 104)),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      padding: EdgeInsets.all(10.0),
                                      child: Row(children: [
                                        Expanded(
                                          child: _buildTimePicker(
                                              "Desde", startTime, (time) {
                                            setState(() {
                                              startTime = time;
                                              _timeStartController.text =
                                                  "${startTime.hour}:${startTime.minute}";
                                            });
                                          }, _timeStartControllerdb.text),
                                        ),
                                        SizedBox(width: 50),
                                        Expanded(
                                          child: _buildTimePicker(
                                              "Hasta", endTime, (time) {
                                            setState(() {
                                              endTime = time;
                                              _timeEndController.text =
                                                  "${endTime.hour}:${endTime.minute}";
                                            });
                                          }, _timeEndControllerdb.text),
                                        ),
                                      ]),
                                    ),
                                    // SizedBox(
                                    //   height: 10.0,
                                    // ),
                                  ],
                                ),
                              ],
                            ),

                            // ... Agrega más TextFields para cada campo editable
                          ],
                        ),
                      ),
                      // actions: <Widget>[
                      SizedBox(height: 40),
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

                                    collectionSchedule =
                                        " ${_timeStartControllerdb.text} - ${_timeEndControllerdb.text}";
                                  }
                                  if (_cityController.text == "") {
                                    _cityController = TextEditingController(
                                        text: _cityControllerdb.text);
                                  }
                                  if (_provinciaController.text == "") {
                                    _provinciaController =
                                        TextEditingController(
                                            text: _provinciaControllerdb.text);
                                  }

                                  if (listaDeEnterosX.isEmpty) {
                                    listaDeEnterosX = listaDeEnteros;
                                  }
                                  var responseChargeImage;

                                  if (pickedImage != null &&
                                      pickedImage!.name.isNotEmpty) {
                                    responseChargeImage = await Connections()
                                        .postDoc(pickedImage!);
                                    if (responseChargeImage[1] != "") {
                                      _urlImageController.text =
                                          responseChargeImage[1];
                                    }
                                  }
                                  _controller
                                      .updateWarehouse(
                                          widget.warehouse.id!,
                                          _nameSucursalController.text,
                                          _addressController.text,
                                          _customerServiceController.text,
                                          _referenceController.text,
                                          _descriptionController.text,
                                          _urlImageController.text,
                                          _cityController.text,
                                          {
                                            "collectionDays": listaDeEnterosX,
                                            "collectionSchedule":
                                                collectionSchedule,
                                            //       "${_timeStartController.text} - ${_timeEndController.text}",
                                            "collectionTransport":
                                                _trnasportController.text
                                          },
                                          _provinciaController.text as int)
                                      .then((_) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      // Esto forzará la reconstrucción de la vista con los datos actualizados
                                      _futureWarehouseData = _loadWarehouses();
                                      SnackBarHelper.showOkSnackBar(
                                          context, "DATOS ACTUALIZADOS.");
                                    });
                                  });
                                  // }

                                  // // print(
                                  // // "Horario de Recolección: ${_timeStartControllerdb.text}-${_timeEndControllerdb.text}");
                                  // print(
                                  //     "Transporte de Recolección: ${_trnasportController.text}");
                                  // print("collec: $collectionSchedule ");
                                  // print("*******************");
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
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      widget.warehouse.active == 1
                          ? Tooltip(
                              message: "Desactivar Bodega",
                              child: IconButton(
                                icon: const Icon(Icons.lock,
                                    color: Colors.red),
                                onPressed: () {
                                  _controller
                                      .deleteWarehouse(widget.warehouse.id!)
                                      .then((_) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _futureWarehouseData =
                                          _loadWarehouses();
                                      SnackBarHelper.showOkSnackBar(
                                          context, "BODEGA INACTIVA.");
                                    });
                                  });
                                },
                              ),
                            )
                          : Tooltip(
                              message: "Activar Bodega",
                              child: IconButton(
                                icon:
                                    Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  _controller
                                      .activateWarehouse(
                                          widget.warehouse.id!)
                                      .then((_) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _futureWarehouseData =
                                          _loadWarehouses();
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
                          labelText: 'Número Atención al Cliente',
                          controller: _customerServiceController,
                          icon: Icons.phone,
                        ),
                        SizedBox(height: 10),
                        TextFieldWithIcon(
                          controller: _descriptionController,
                          labelText: 'Descripción',
                          icon: Icons.description,
                        ),
                        SizedBox(height: 20),
                        Row(children: [
                          Column(
                            children: [
                              Container(
                                  padding: EdgeInsets.only(top: 15.0),
                                  height: 100,
                                  child: ImagePickerExample(
                                    onImageSelected: (XFile? image) {
                                      setState(() {
                                        pickedImage = image;
                                      });
                                    },
                                    label: 'Seleccione Nueva Imagen',
                                    widgetWidth: 200,
                                  )),
                            ],
                          ),
                        ]),
                        SizedBox(height: 10),
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
                                  Text("Provincia: ",
                                      style: TextStyle(
                                          color: ColorsSystem()
                                              .colorSelectMenu,
                                          fontSize: 14)),
                                  Text(
                                    "$provnam",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("Ciudad: ",
                                      style: TextStyle(
                                          color: ColorsSystem()
                                              .colorSelectMenu,
                                          fontSize: 14)),
                                  Text(
                                    "${_cityControllerdb.text}",
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
                                  Flexible(
                                    child: Text(
                                      "${mapNumbersToDays(collectionDays)}",
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 210,
                              child: SelectFilterProvincia(
                                  'Provincia', provnam, provincias),
                              // _provinciaController, provincias),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 210,
                              child: SelectFilterN('Ciudad',
                                  _cityControllerdb, activeRoutes),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              width: 210,
                              child: SelectFilterTrans(
                                  'Transporte de Recolección',
                                  _trnsportController,
                                  formattedList),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
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
                              child: DiasSeleccionadosWidget(
                                initialSelectedDays: listaDeEnteros,
                                onSelectionChanged: (selectedDaysInter) {
                                  setState(() {
                                    listaDeEnterosX = selectedDaysInter;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text("Horario de Recolección",
                            style: TextStyle(
                                color: Color.fromARGB(255, 107, 105, 105))),
                        SizedBox(height: 10),
        
                        Container(
                          // width: 300,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(
                                      255, 105, 104, 104)),
                              borderRadius: BorderRadius.circular(10.0)),
                          padding: EdgeInsets.all(10.0),
                          child: Column(children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePicker(
                                      "Desde", startTime, (time) {
                                    setState(() {
                                      startTime = time;
                                      _timeStartController.text =
                                          "${startTime.hour}:${startTime.minute}";
                                    });
                                  }, _timeStartControllerdb.text),
                                ),
                                // SizedBox(width: 10),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePicker("Hasta", endTime,
                                      (time) {
                                    setState(() {
                                      endTime = time;
                                      _timeEndController.text =
                                          "${endTime.hour}:${endTime.minute}";
                                    });
                                  }, _timeEndControllerdb.text),
                                ),
                              ],
                            ),
                          ]),
                        )
                        // SizedBox(height: 20),
        
                        // ... Agrega más TextFields para cada campo editable
                      ],
                    ),
                  ),
                  // actions: <Widget>[
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              // Implementa la lógica de actualización aquí
        
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
        
                                collectionSchedule =
                                    " ${_timeStartControllerdb.text} - ${_timeEndControllerdb.text}";
                              }
                              if (_cityController.text == "") {
                                _cityController = TextEditingController(
                                    text: _cityControllerdb.text);
                              }
        
                              if (listaDeEnterosX.isEmpty) {
                                listaDeEnterosX = listaDeEnteros;
                              }
                              var responseChargeImage;
        
                              if (pickedImage != null &&
                                  pickedImage!.name.isNotEmpty) {
                                responseChargeImage = await Connections()
                                    .postDoc(pickedImage!);
                                if (responseChargeImage[1] != "") {
                                  _urlImageController.text =
                                      responseChargeImage[1];
                                }
                              }
                              _controller
                                  .updateWarehouse(
                                      widget.warehouse.id!,
                                      _nameSucursalController.text,
                                      _addressController.text,
                                      _customerServiceController.text,
                                      _referenceController.text,
                                      _descriptionController.text,
                                      _urlImageController.text,
                                      _cityController.text,
                                      {
                                        "collectionDays": listaDeEnterosX,
                                        "collectionSchedule":
                                            collectionSchedule,
                                        "collectionTransport":
                                            _trnasportController.text
                                      },
                                      int.parse(_provinciaController.text))
                                  .then((_) {
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
                            child: const Text('Aceptar',
                                style: TextStyle(fontSize: 12)),
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
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(fontSize: 12),
                            ),
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
        context);
  }

  Widget buildDiasSeleccionadosWidget(
      {required List<int> initialSelectedDays}) {
    List<int> selectedDays = List.from(initialSelectedDays);

    return ListView.builder(
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
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return FilterChip(
                backgroundColor: Colors.black,
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
                      if (!selectedDays.contains(dayValue)) {
                        selectedDays.add(dayValue);
                      }
                    } else {
                      selectedDays.remove(dayValue);
                    }
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  TimeOfDay _parseTime(String time) {
    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<List<WarehouseModel>> _loadWarehouses([String query = '']) async {
    await _controller
        .loadWarehouses(sharedPrefs!.getString("idProvider").toString());
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
    String? dbvalue,

    // TextEditingController controller,
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
                  auxili = 1;
                  onTimeChanged(pickedTime);
                } else {
                  onTimeChanged(_parseTime(dbvalue!));
                }
                // controller.text = "${selectedTime.hour}:${selectedTime.minute}";
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange, // Define el color del texto
              ),
              child: auxili == 1
                  ? Text(
                      "${selectedTime.hour}:${selectedTime.minute}",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )
                  : Text(
                      "${_parseTime(dbvalue!).hour}:${_parseTime(dbvalue).minute}",
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

class DiasSeleccionadosWidget extends StatefulWidget {
  final List<int> initialSelectedDays;
  final Function(List<int>) onSelectionChanged;

  DiasSeleccionadosWidget({
    required this.initialSelectedDays,
    required this.onSelectionChanged,
  });

  @override
  _DiasSeleccionadosWidgetState createState() =>
      _DiasSeleccionadosWidgetState();
}

class _DiasSeleccionadosWidgetState extends State<DiasSeleccionadosWidget> {
  List<int> selectedDays = [];

  @override
  void initState() {
    super.initState();
    selectedDays = List.from(widget.initialSelectedDays);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return FilterChip(
                backgroundColor: Colors.black,
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
                      if (!selectedDays.contains(dayValue)) {
                        selectedDays.add(dayValue);
                      }
                    } else {
                      selectedDays.remove(dayValue);
                    }
                    // Llamar a la función de devolución de llamada con la lista actualizada
                    widget.onSelectionChanged(selectedDays);
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}
