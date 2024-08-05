import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:intl/intl.dart';

class MyCustomWidget extends StatelessWidget {
  final String value1;
  final String value2;
  final String value3;
  final String filterInvoke;
  final String? entregados;
  final String? noEntregados;
  final String? novedad;

  MyCustomWidget(
      {required this.value1,
      required this.value2,
      required this.value3,
      required this.filterInvoke,
      this.entregados,
      this.noEntregados,
      this.novedad});

  String formatNumber(String number) {
    var formatter =
        NumberFormat('###,###.##', 'es'); // 'es' para formato en español
    return formatter.format(double.parse(number));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: filterInvoke == "3"
              ? [
                  CustomContainer(
                    value: formatNumber(value1),
                    labelText: 'Costo Trans. Externo',
                    type: "1",
                  ),
                  SizedBox(width: 8.0),
                  CustomContainer(
                    value: entregados!,
                    labelText: 'Entregados',
                    type: "2",
                  ),
                  SizedBox(width: 8.0),
                  CustomContainer(
                    value: noEntregados!,
                    labelText: 'No Entregados',
                    type: "2",
                  )
                ]
              : filterInvoke == "2"
                  ? [
                      CustomContainer(
                        value: formatNumber(value1),
                        labelText: 'Costo Transporte!',
                        type: "1",
                      ),
                      SizedBox(width: 8.0),
                      CustomContainer(
                        value: entregados!,
                        labelText: 'Entregados',
                        type: "2",
                      ),
                      SizedBox(width: 8.0),
                      CustomContainer(
                        value: noEntregados!,
                        labelText: 'No Entregados',
                        type: "2",
                      )
                    ]
                  : filterInvoke == "1"
                      ? [
                          // CustomContainer(value: value1, labelText: 'Costo Transporte'),
                          SizedBox(width: 8.0),
                          CustomContainer(
                            value: formatNumber(value2),
                            labelText: 'Costo Entrega',
                            type: "1",
                          ),
                          SizedBox(width: 8.0),
                          CustomContainer(
                            value: formatNumber(value3),
                            labelText: 'Costo Devolución',
                            type: "1",
                          ),
                          SizedBox(width: 8.0),
                          CustomContainer(
                            value: entregados!,
                            labelText: 'Entregados',
                            type: "2",
                          ),
                          SizedBox(width: 8.0),
                          CustomContainer(
                            value: noEntregados!,
                            labelText: 'No Entregados',
                            type: "2",
                          ),
                          SizedBox(width: 8.0),
                          CustomContainer(
                            value: novedad!,
                            labelText: 'Devoluciones',
                            type: "2",
                          ),
                        ]
                      : [
                          // Handle the case when filterInvoke is 0
                          // You can customize this section based on your needs
                          Container(
                            margin: EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(16.0),
                            child: Text("Data No Disponible..."),
                          )
                        ],
        ),
      ]),
    );
  }
}

class CustomContainer extends StatelessWidget {
  final String value;
  final String labelText;
  String type;

  CustomContainer(
      {required this.value, required this.labelText, required this.type});

  @override
  Widget build(BuildContext context) {
    return type == "1"
        ? responsive(
            Container(
              // Estilo del contenedor según tus necesidades
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(width: 1, color: getColor(labelText)!),
              ),
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "\$ " + value,
                      style: TextStyle(
                        color: ColorsSystem().colorSelectMenu,
                        fontWeight: FontWeight.bold,
                        fontSize: 26.0,
                      ),
                    ),
                    const SizedBox(height: 1.0),
                    Text(labelText),
                  ]),
            ),
            Container(
              // Estilo del contenedor según tus necesidades
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(width: 1, color: Colors.grey),
              ),
              padding: EdgeInsets.all(2.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "\$ " + value,
                      style: TextStyle(
                        color: ColorsSystem().colorSelectMenu,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 1.0),
                    Text(
                      labelText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                      ),
                    ),
                  ]),
            ),
            context)
        : responsive(
            Container(
              // Estilo del contenedor según tus necesidades
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(width: 1, color: getColor(labelText)!),
              ),
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: ColorsSystem().colorSelectMenu,
                      fontWeight: FontWeight.bold,
                      fontSize: 26.0,
                    ),
                  ),
                  const SizedBox(height: 1.0),
                  Text(labelText, style: TextStyle(color: getColor(labelText)))
                ],
              ),
            ),
            Container(
              // Estilo del contenedor según tus necesidades
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(width: 1, color: Colors.grey),
              ),
              padding: EdgeInsets.all(2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: ColorsSystem().colorSelectMenu,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 1.0),
                  Text(labelText,
                      style: TextStyle(
                          color: getColor(labelText),
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0))
                ],
              ),
            ),
            context);
  }
}

Color? getColor(state) {
  int color = 0xFF000000;

  switch (state) {
    case "Entregados":
      color = 0xFF66BB6A;
      break;
    case "Devoluciones":
      color = 0xFFD6DC27;
      break;
    case "No Entregados":
      color = 0xFFF32121;
      break;
    default:
      color = 0xFF000000;
  }

  return Color(color);
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: MyCustomWidget(
          value1: 'Valor 1',
          value2: 'Valor 2',
          value3: 'Valor 3',
          filterInvoke: '0',
        ),
      ),
    ),
  );
}
