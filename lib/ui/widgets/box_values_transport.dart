import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/build_info_container.dart';

class boxValuesTransport extends StatelessWidget {
  const boxValuesTransport({
    super.key,
    required this.totalValoresRecibidos,
    required this.costoDeEntregas,
  });

  final double totalValoresRecibidos;
  final double costoDeEntregas;

  @override
Widget build(BuildContext context) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.all(5), // Ajusta el valor según lo que necesites
        child: BuildInfoContainer(
          title: 'Valores recibidos',
          value: '\$ ${totalValoresRecibidos.toStringAsFixed(2)}',
        ),
      ),
      const SizedBox(width: 10), // Espacio entre los contenedores
      Padding(
        padding: const EdgeInsets.all(5), // Ajusta el valor según lo que necesites
        child: BuildInfoContainer(
          title: 'Costo de envío',
          value: '\$ ${costoDeEntregas.toStringAsFixed(2)}',
        ),
      ),
    ],
  );
}

}
