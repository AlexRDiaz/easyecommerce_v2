import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/my_carousel.dart';
import 'package:get/get.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:provider/provider.dart';

class AddWarehouse extends StatefulWidget {
  const AddWarehouse({super.key});

  @override
  // State<AddWarehouse> createState() => _AddWarehouseState();
  _AddWarehouseState createState() => _AddWarehouseState();
}

class _AddWarehouseState extends StateMVC<AddWarehouse> {
  late WrehouseController _controller;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameSucursalController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _decriptionController = TextEditingController();

  @override
  void initState() {
    _controller = WrehouseController();
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        SizedBox(height: 20),
        SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
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
                controller: _decriptionController,
                labelText: 'Descripción',
                icon: Icons.description,
              ),
              SizedBox(height: 30),
            ],
          ),
        )),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                // ! cambiar  segun lo que diga el modelo de warehouses
                _controller.addWarehouse(WarehouseModel(
                    branchName: _nameSucursalController.text,
                    address: _addressController.text,
                    reference: _referenceController.text,
                    description: _decriptionController.text,
                    providerId: int.parse(
                        sharedPrefs!.getString("idProvider").toString())));

                Navigator.pop(context);
                
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: ColorsSystem().colorSelectMenu, // Cambia el color del texto del botón
                padding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 40), // Ajusta el espaciado interno del botón
                textStyle:
                    TextStyle(fontSize: 18), // Cambia el tamaño del texto
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
                  fontWeight: FontWeight.normal, // Aplica negrita al texto
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
              backgroundColor:
                  Color.fromARGB(
                    255, 12, 37, 49), // Cambia el color del texto del botón
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
              'Cancelar',
              style: TextStyle(
                fontSize: 18, // Cambia el tamaño del texto
                fontWeight: FontWeight.normal, // Aplica negrita al texto
              ),
            ),
          )),
        ]),
      ],
    );
    // Segunda sección con información adicional
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
          fontFamily: 'TuFuentePersonalizada', // Cambia esto por tu fuente
          color: Colors.black,
        ),
        // ... [Validaciones y otros ajustes]
      ),
    );
  }
}
