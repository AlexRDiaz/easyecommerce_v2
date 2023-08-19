import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/build_info_container.dart';

class boxValues extends StatelessWidget {
  const boxValues({
    super.key,
    required this.totalValoresRecibidos,
    required this.costoDeEntregas,
    required this.devoluciones,
    required this.utilidad,
  });

  final double totalValoresRecibidos;
  final double costoDeEntregas;
  final double devoluciones;
  final double utilidad;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      BuildInfoContainer(
          title: 'Valores recibidos:',
          value: '\$${totalValoresRecibidos.toStringAsFixed(2)}'),
      BuildInfoContainer(
          title: 'Costo de envío:',
          value: '\$${costoDeEntregas.toStringAsFixed(2)}'),
      BuildInfoContainer(
        title: 'Devoluciones:',
        value: '\$${devoluciones.toStringAsFixed(2)}',
      ),
      BuildInfoContainer(
        title: 'Utilidad:',
        value: '\$${utilidad.toStringAsFixed(2)}',
      ),
    ]);
  }
}
