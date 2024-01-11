import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';

class MyCustomWidget extends StatelessWidget {
  final String value1;
  final String value2;
  final String value3;

  MyCustomWidget({
    required this.value1,
    required this.value2,
    required this.value3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomContainer(value: value1, labelText: 'Costo Transporte'),
              SizedBox(width: 8.0),
              CustomContainer(value: value2, labelText: 'Costo Entrega'),
              SizedBox(width: 8.0),
              CustomContainer(value: value3, labelText: 'Costo Devolución'),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomContainer extends StatelessWidget {
  final String value;
  final String labelText;

  CustomContainer({
    required this.value,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Estilo del contenedor según tus necesidades
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(width: 1, color: Colors.grey),
      ),
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("\$ "+value,style: TextStyle(
            color: ColorsSystem().colorSelectMenu,
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),),
          const SizedBox(height: 1.0),
          Text(labelText),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: MyCustomWidget(
          value1: 'Valor 1',
          value2: 'Valor 2',
          value3: 'Valor 3',
        ),
      ),
    ),
  );
}
