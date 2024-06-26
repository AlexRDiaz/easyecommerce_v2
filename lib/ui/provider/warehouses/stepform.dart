import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/widgets/logistic/custom_imagepicker.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:image_picker/image_picker.dart';

class StepFormExample extends StatefulWidget {
  @override
  _StepFormExampleState createState() => _StepFormExampleState();
}

class _StepFormExampleState extends State<StepFormExample> {
  late WrehouseController _controller;

  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  List<dynamic> activeRoutes = [];
  List<String> formattedList = [];

  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _trnasportController = TextEditingController();
  // final TextEditingController _timeStartController = TextEditingController();
  // final TextEditingController _timeEndController = TextEditingController();

  List<dynamic> secondDropdownOptions = [];

  // final TextEditingController returnStatesController = TextEditingController();
  // final TextEditingController formattedListController = TextEditingController();

  // Controladores de TextField
  final TextEditingController _nameSucursalController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _customerServiceController =
      TextEditingController();
  final TextEditingController _decriptionController = TextEditingController();

  // Otros controladores y variables necesarias
  XFile? pickedImage;
  String? selectedProvincia;
  List<String> provinciasToSelect = [];

  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.now();
  final TextEditingController _timeStartController = TextEditingController();
  final TextEditingController _timeEndController = TextEditingController();
  List<int> selectedDays = [];

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
    return Container(
      height: 700,
      // width: 500,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Indicadores de paso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  2,
                  (index) => _buildStepButton(index + 1),
                ),
              ),
              Divider(),
              SizedBox(height: 20),
              // Contenido del formulario según el paso actual
              _buildCurrentStepContent(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepButton(int stepIndex) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _currentStep = stepIndex - 1;
        });
      },
      style: ElevatedButton.styleFrom(
        primary: _currentStep >= stepIndex - 1 ? Colors.green : Colors.grey,
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
      ),
      child: Text(
        '$stepIndex',
        style: TextStyle(fontSize: 10),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      // case 2:
      // return _buildStep3();
      default:
        return Container(); // Puede retornar un contenedor vacío o manejar otro caso según tus necesidades
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nueva Bodega",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19.0),
        ),
        const SizedBox(height: 30),
        TextFiledMod(Icons.store_mall_directory, "Nombre de bodega",
            _nameSucursalController),
        const SizedBox(height: 25),
        TextFiledMod(Icons.place, "Dirección", _addressController),
        const SizedBox(height: 25),
        TextFiledMod(Icons.bookmark_border, "Referencia", _referenceController),
        const SizedBox(height: 25),
        TextFiledMod(Icons.phone, "Número atención al cliente",
            _customerServiceController),
        const SizedBox(height: 25),
        TextFiledMod(Icons.description, "Descripción", _decriptionController),
        const SizedBox(height: 25),
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
        // SizedBox(height: 5),
      ],
    );
  }

  Widget _buildStep2() {
    final TextEditingController returnStatesController = TextEditingController(
        text: activeRoutes.isNotEmpty ? activeRoutes.first : '');
    final TextEditingController formattedListController = TextEditingController(
        text: formattedList.isNotEmpty ? formattedList.first : '');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 20),
      Text(
        "Provincia",
        style: TextStyle(color: Color.fromARGB(255, 107, 105, 105)),
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
                            fontSize: 14, fontWeight: FontWeight.bold),
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
      SizedBox(height: 20),
      Row(
        children: [
          Container(
            width: 210,
            child: SelectFilter('Ciudad', returnStatesController, activeRoutes),
          ),
        ],
      ),
      SizedBox(height: 20),
      Row(
        children: [
          Container(
            width: 210,
            child: SelectFilterTrans('Transporte de Recolección',
                formattedListController, formattedList),
          ),
        ],
      ),
      SizedBox(height: 20),
      Row(
        children: [
          Text("Días de Recolección",
              style: TextStyle(color: Color.fromARGB(255, 107, 105, 105))),
        ],
      ),
      // SizedBox(height: 20),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 105, 104, 104)),
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
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
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
      SizedBox(height: 20),
      Row(
        children: [
          Text("Horario de Recolección:",
              style: TextStyle(color: Color.fromARGB(255, 107, 105, 105)))
        ],
      ),
      Container(
        // width: 300,
        decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 105, 104, 104)),
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
          ],
        ),
      ),
      SizedBox(height: 40),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () async {
                _submitForm();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: ColorsSystem()
                    .colorSelectMenu, // Cambia el color del texto del botón
                padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 40), // Ajusta el espaciado interno del botón
                textStyle: TextStyle(
                  fontSize: 18,
                ), // Cambia el tamaño del texto
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Agrega bordes redondeados
                ),
                elevation: 3, // Agrega una sombra al botón
              ),
              child: Icon(Icons.check)
              // Text(
              //   'Aceptar',
              //   style: TextStyle(
              //     fontSize: 10, // Cambia el tamaño del texto
              //     fontWeight: FontWeight.normal, // Aplica negrita al texto
              //   ),
              // ),
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
                  backgroundColor: Color.fromARGB(
                      255, 12, 37, 49), // Cambia el color del texto del botón
                  padding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 40), // Ajusta el espaciado interno del botón
                  textStyle: TextStyle(
                    fontSize: 18,
                  ), // Cambia el tamaño del texto
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Agrega bordes redondeados
                  ),
                  elevation: 3, // Agrega una sombra al botón
                ),
                child: Icon(Icons.close)
                // Text(
                //   'Cancelar',
                //   style: TextStyle(
                //     fontSize: 10, // Cambia el tamaño del texto
                //     fontWeight: FontWeight.normal, // Aplica negrita al texto
                //   ),
                // ),
                )),
      ]),
    ]);
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );
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

  TextField TextFiledMod(icon, label, controller) {
    return TextField(
      // controller: _decriptionController,
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        // prefixIcon: Icon(Icons.description),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_nameSucursalController.text == " " ||
        _addressController.text == "" ||
        _customerServiceController.text == "" ||
        _referenceController.text == "" ||
        _decriptionController.text == "" ||
        _cityController.text == "" ||
        _timeStartController.text == "" ||
        _timeEndController.text == "" ||
        _trnasportController.text == "" ||
        pickedImage!.name.toString() == " " ||
        selectedProvincia.toString().split('-')[1] == " " ||
        selectedDays.isEmpty) {
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: 'Complete todos los campos',
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnOkOnPress: () async {
          Navigator.pop(context);
          await loadData();
        },
      ).show();
    } else {
      var responseChargeImage = await Connections().postDoc(pickedImage!);
      // ! cambiar  segun lo que diga el modelo de warehouses
      _controller.addWarehouse(WarehouseModel(
          branchName: _nameSucursalController.text,
          address: _addressController.text,
          customerphoneNumber: _customerServiceController.text,
          reference: _referenceController.text,
          description: _decriptionController.text,
          url_image: responseChargeImage[1],
          id_provincia: int.parse(selectedProvincia.toString().split('-')[1]),
          city: _cityController.text,
          collection: {
            "collectionDays": selectedDays,
            "collectionSchedule":
                "${_timeStartController.text} - ${_timeEndController.text}",
            "collectionTransport": _trnasportController.text
          },
          providerId:
              int.parse(sharedPrefs!.getString("idProvider").toString())));

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se elimina
    _nameSucursalController.dispose();
    _addressController.dispose();
    _referenceController.dispose();
    _customerServiceController.dispose();
    _decriptionController.dispose();
    _timeStartController.dispose();
    _timeEndController.dispose();
    super.dispose();
  }
}
