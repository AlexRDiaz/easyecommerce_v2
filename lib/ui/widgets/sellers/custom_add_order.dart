import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulario Flutter para Web',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CustomAddOrder(),
    );
  }
}

class CustomAddOrder extends StatefulWidget {
  @override
  _CustomAddOrderState createState() => _CustomAddOrderState();
}

class _CustomAddOrderState extends State<CustomAddOrder> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para cada campo
  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  // Añade más controladores según sea necesario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CREACIOND PEDIDO"),
              Divider(),
              _buildSection('Información del Cliente', [
                _buildFormField('Nombre del Cliente', _nombreController),
                _buildFormField('Dirección', _direccionController),
                _buildFormField('Teléfono', _telefonoController),
              ]),
              _buildSection('Detalles del Pedido', [
                // Añade más campos relacionados con el pedido aquí
              ]),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Realizar acciones con los datos del formulario
                    // Puedes acceder a los valores con _nombreController.text, _direccionController.text, etc.
                    // Por ejemplo:
                    print('Nombre del Cliente: ${_nombreController.text}');
                    print('Dirección: ${_direccionController.text}');
                    print('Teléfono: ${_telefonoController.text}');
                    // Agrega el resto de los campos según sea necesario
                  }
                },
                child: Text('Enviar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(String labelText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText,
            style: TextStyle(
              color: Colors.black, // Cambia el color del labelText
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, complete este campo';
            }
            return null;
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSection(String sectionTitle, List<Widget> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  sectionTitle,
                ),
              ),
              Container(
                width: 599,
                child: Column(children: fields),
              )
            ],
          ),
        ),

        Divider(), // O cualquier otro divisor que desees
      ],
    );
  }
}
