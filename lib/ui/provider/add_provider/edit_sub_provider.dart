import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/add_sellers/custom_filterchip_for_user.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/add_provider/controllers/sub_provider_controller.dart';
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

class EditSubProvider extends StatefulWidget {
  final List<dynamic> accessTemp;

  final UserModel provider;
  final Function(dynamic) hasEdited;
  const EditSubProvider(
      {super.key,
      required this.provider,
      required this.hasEdited,
      required this.accessTemp});

  @override
  // State<EditSubProvider> createState() => _EditSubProviderState();
  _EditSubProviderState createState() => _EditSubProviderState();
}

class _EditSubProviderState extends StateMVC<EditSubProvider> {
  late SubProviderController _controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  bool _blocked = false;
  String?
      _selectedImageURL; // Esta variable almacenará la URL de la imagen seleccionada

  List<dynamic> accessTemp = [];
  Map<String, dynamic> accessGeneralofRol = {};
  String idUser = "";
  List vistas = [];

  @override
  void initState() {
    _controller = SubProviderController();
    // print(sharedPrefs!.getString("idProvider"));
    _usernameController.text = widget.provider.username!;
    _emailController.text = widget.provider.email!;
    _blocked = widget.provider.blocked!;

    super.initState();
    getAccess();
  }

  getAccess() async {
    //  sharedPrefs!.getString("id")
    idUser = widget.provider.id.toString();

    // print("general id: ${sharedPrefs!.getString("id")}");
    // print("to edit: $idUser");

    var result = await Connections().getPermissionsSellerPrincipalforNewSeller(
        sharedPrefs!.getString("id"));

    accessTemp = jsonDecode(widget.provider.permisos);

    setState(() {
      accessTemp = accessTemp;
      accessGeneralofRol = result;
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
            'Editar  Usuario',
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
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
                child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
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
                  SizedBox(height: 10),
                  FlutterSwitch(
                    width: 120.0,
                    height: 30.0,
                    activeText: "Desbloquear",
                    inactiveText: "Bloquear",
                    valueFontSize: 14.0,
                    toggleSize: 25.0,
                    value: _blocked,
                    borderRadius: 30.0,
                    padding: 2.0,
                    showOnOff: true,
                    onToggle: (value) {
                      setState(() {
                        _blocked = value;
                      });
                    },
                  ),
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
                          loadData: () {},
                          idUser: idUser.toString(),
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
              _controller.editSubProvider(UserModel(
                id: widget.provider.id,
                username: _usernameController.text,
                email: _emailController.text,
                blocked: _blocked,
              ));
              widget.hasEdited(true);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.blue, // Cambia el color de fondo del botón
              onPrimary: Colors.white, // Cambia el color del texto del botón
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
