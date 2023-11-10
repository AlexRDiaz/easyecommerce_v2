import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/my_carousel.dart';
import 'package:get/get.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';

class AddProvider extends StatefulWidget {
  const AddProvider({super.key});

  @override
  // State<AddProvider> createState() => _AddProviderState();
  _AddProviderState createState() => _AddProviderState();
}

class _AddProviderState extends StateMVC<AddProvider> {
  late ProviderController _controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    _controller = ProviderController();
    super.initState();
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
            'Nuevo   Proveedor',
            style: TextStyle(
              fontSize: 30.0, // Tamaño de fuente grande
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
                    controller: _nameController,
                    decoration: InputDecoration(
                      fillColor:
                          Colors.white, // Color del fondo del TextFormField
                      filled: true,
                      labelText: 'Nombre de bodega',
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
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
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
                  TextFormField(
                    controller: _descriptionController,
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
                ],
              ),
            )),
          ),
          ElevatedButton(
            onPressed: () async {
              _controller.addProvider(ProviderModel(
                  name: _nameController.text,
                  phone: _phone1Controller.text,
                  description: _descriptionController.text,
                  user: UserModel(
                    username: _usernameController.text,
                    email: _emailController.text,
                  )));

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
