import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/add_sellers/custom_filterchip_for_user.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/html_editor.dart';
import 'package:frontend/ui/widgets/my_carousel.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';

class EditProvider extends StatefulWidget {
  final ProviderModel provider;
  final Function(dynamic) hasEdited;
  const EditProvider(
      {super.key, required this.provider, required this.hasEdited});

  @override
  // State<EditProvider> createState() => _EditProviderState();
  _EditProviderState createState() => _EditProviderState();
}

class _EditProviderState extends StateMVC<EditProvider> {
  late ProviderController _controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  String?
      _selectedImageURL; // Esta variable almacenará la URL de la imagen seleccionada

  List<dynamic> accessTemp = [];
  Map<String, dynamic> accessGeneralofRol = {};
  String idUser = "";
  var data = {};

  @override
  void initState() {
    _controller = ProviderController();
    _nameController.text = widget.provider.name!;
    _phone1Controller.text = widget.provider.phone!;
    _usernameController.text = widget.provider.user!.username!;
    _emailController.text = widget.provider.user!.email!;
    _descriptionController.text = (widget.provider.description == null
        ? ""
        : widget.provider.description)!;

    super.initState();
    getAccess();
  }

  getAccess() async {
    idUser = widget.provider.user!.id.toString();
    var resultAccessGeneralofRol = await Connections().getAccessofRolById(5);
    setState(() {
      accessTemp = jsonDecode(widget.provider.user!.permisos!);
      accessGeneralofRol = resultAccessGeneralofRol;
    });
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
            'Editar  Proveedor',
            style: TextStyle(
              fontSize: 20.0, // Tamaño de fuente grande
              fontWeight: FontWeight.bold, // Texto en negrita
              color: Color.fromARGB(255, 3, 3, 3), // Color de texto
              fontFamily:
                  'Arial', // Fuente personalizada (cámbiala según tus necesidades)
              letterSpacing: 2.0, // Espaciado entre letras
              decorationColor: Colors.red, // Color del subrayado
              decorationThickness: 2.0, // Grosor del subrayado
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      fillColor:
                          Colors.white, // Color del fondo del TextFormField
                      filled: true,
                      labelText: 'Nombre de proveedor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    style: const TextStyle(
                        fontFamily:
                            'AtractivaFont'), // Estilo de fuente personalizado
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Ingresa el nombre de la bodega';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _phone1Controller,
                    decoration: InputDecoration(
                      fillColor:
                          Colors.white, // Color del fondo del TextFormField
                      filled: true,
                      labelText: 'Telefono',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Por favor, ingresa tu número de telefono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
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
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: null,
                    decoration: InputDecoration(
                      fillColor:
                          Colors.white, // Color del fondo del TextFormField
                      filled: true,
                      labelText: 'Descripcion',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.symmetric(vertical: 10.0),
                  //   padding: EdgeInsets.all(8.0),
                  //   height: 200,
                  //   //  width: 600,
                  //   decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(10.0),
                  //       border: Border.all(color: Colors.black)),
                  //   child: HtmlEditor(
                  //       description: _descriptionController.text,
                  //       getValue: getValue),
                  // ),
                  // TextButton(
                  //   onPressed: () {
                  //     // Aquí puedes implementar la lógica para seleccionar una imagen
                  //     // Al seleccionar una imagen, actualiza la variable _selectedImageURL con la URL de la imagen
                  //     // _selectedImageURL = 'URL de la imagen seleccionada';
                  //     _selectImage();
                  //     setState(
                  //         () {}); // Para actualizar la interfaz de usuario con la imagen seleccionada
                  //   },
                  //   child: const Row(
                  //     children: [
                  //       Icon(Icons.image), // Icono para seleccionar imagen
                  //       SizedBox(width: 10),
                  //       Text(
                  //           'Seleccionar Imagen'), // Texto del botón para seleccionar imagen
                  //     ],
                  //   ),
                  // ),
                  // if (_selectedImageURL != null)
                  //   Image.network(
                  //     _selectedImageURL!, // URL de la imagen seleccionada
                  //     width: 300, // Ancho de la imagen
                  //     height: 300, // Alto de la imagen
                  //   ),
                  const SizedBox(height: 10),
                  const Text(
                    "Accesos",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Container(
                    margin: EdgeInsets.all(20.0),
                    height: 500,
                    width: 500,
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.0,
                            color: Color.fromARGB(255, 224, 222, 222)),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Builder(
                      builder: (context) {
                        return CustomFilterChips(
                          accessTemp: accessTemp,
                          accessGeneralofRol: accessGeneralofRol,
                          loadData: getAccess,
                          idUser: idUser.toString(),
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
              _controller.editProvider(ProviderModel(
                  id: widget.provider.id,
                  name: _nameController.text,
                  phone: _phone1Controller.text,
                  description: _descriptionController.text,
                  user: UserModel(
                    id: widget.provider.user!.id,
                    username: _usernameController.text,
                    email: _emailController.text,
                  )));
              widget.hasEdited(true);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor:
                  Colors.blue, // Cambia el color del texto del botón
              padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 40), // Ajusta el espaciado interno del botón
              textStyle:
                  const TextStyle(fontSize: 18), // Cambia el tamaño del texto
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10), // Agrega bordes redondeados
              ),
              elevation: 3, // Agrega una sombra al botón
            ),
            child: const Text(
              'Guardar',
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

  getValue(value) {
    _descriptionController.text = value;
    return value;
  }

  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImageURL = image.path;
      });
      // La variable 'image' contiene la ruta de la imagen seleccionada
      print('Ruta de la imagen: ${image.path}');
      // Aquí puedes mostrar la imagen o realizar otras operaciones con ella
    }
  }
}
