import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/build_info_container.dart';
import 'package:frontend/helpers/responsive.dart';

// ignore: camel_case_types
class boxValuesExternalCarrier extends StatelessWidget {
  const boxValuesExternalCarrier(
      {super.key,
      required this.tittle,
      required this.totalValoresRecibidos,
      required this.costoEntrega,
      required this.costoDevolucion,
      required this.resultadoFinal});

  final String tittle;
  final double totalValoresRecibidos;
  final double costoEntrega;
  final double costoDevolucion;
  final double resultadoFinal;

  @override
  Widget build(BuildContext context) {
    return responsive(
      Column(
        children: [
          Row(children: [Text(tittle)]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BuildInfoContainer(
                  title: 'Valores recibidos',
                  value: '\$${totalValoresRecibidos.toStringAsFixed(2)}'),
              const SizedBox(width: 1),
              BuildInfoContainer(
                  title: 'Costo Entrega',
                  value: '\$${costoEntrega.toStringAsFixed(2)}'),
              const SizedBox(width: 1),
              BuildInfoContainer(
                title: 'Costo Devolución',
                value: '\$${costoDevolucion.toStringAsFixed(2)}',
              ),
              const SizedBox(width: 1),
              BuildInfoContainer(
                title: 'Total a Recibir',
                value: '\$${resultadoFinal.toStringAsFixed(2)}',
              ),
              const SizedBox(width: 1),
            ],
          ),
        ],
      ),
      Container(
        height: 55.0, // Ajusta la altura según tus necesidades
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            BuildInfoContainer(
                title: 'Valores recibidos',
                value: '\$${totalValoresRecibidos.toStringAsFixed(2)}'),
            const SizedBox(width: 5),
            BuildInfoContainer(
                title: 'Costo Entrega',
                value: '\$${costoEntrega.toStringAsFixed(2)}'),
            const SizedBox(width: 5),
            BuildInfoContainer(
              title: 'Costo Devolución',
              value: '\$${costoDevolucion.toStringAsFixed(2)}',
            ),
            BuildInfoContainer(
                title: 'Total a Recibir',
                value: '\$${resultadoFinal.toStringAsFixed(2)}',
              ),
              const SizedBox(width: 5),
          ],
        ),
      ),

      /*
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BuildInfoContainer(
                title: 'Valores recibidos',
                value: '\$${totalValoresRecibidos.toStringAsFixed(2)}',
              ),
              const SizedBox(width: 1),
              BuildInfoContainer(
                title: 'Costo de envío',
                value: '\$${costoDeEntregas.toStringAsFixed(2)}',
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BuildInfoContainer(
                title: 'Devoluciones',
                value: '\$${devoluciones.toStringAsFixed(2)}',
              ),
              const SizedBox(width: 1),
              BuildInfoContainer(
                title: 'Utilidad',
                value: '\$${utilidad.toStringAsFixed(2)}',
              ),
            ],
          ),
        ],
      ),
      */
      context,
    );
  }
}
