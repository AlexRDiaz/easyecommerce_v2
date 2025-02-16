import 'package:flutter/material.dart';
import 'package:frontend/ui/widgets/build_info_container.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/widgets/build_info_container_seller.dart';

class boxValues extends StatelessWidget {
  const boxValues({
    super.key,
    required this.totalValoresRecibidos,
    required this.referenciados,
    required this.costoDeEntregas,
    required this.costoProveedor,
    required this.devoluciones,
    required this.utilidad,
    this.isTitleOnTop = false,
  });

  final double totalValoresRecibidos;
  final double referenciados;
  final double costoDeEntregas;
  final double costoProveedor;
  final double devoluciones;
  final double utilidad;
  final bool isTitleOnTop;

  @override
  Widget build(BuildContext context) {
    return responsive(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(isTitleOnTop.toString()),
          BuildInfoContainerSeller(
              title: 'Valores recibidos',
              value: '\$${totalValoresRecibidos.toStringAsFixed(2)}',
              iconOfTitle: const Icon(Icons.bookmark_outline_outlined)),
          const SizedBox(width: 20),
          // BuildInfoContainer(
          //     title: 'C. Referenciados',
          //     value: '\$${referenciados.toStringAsFixed(2)}'),
          // const SizedBox(width: 20),
          BuildInfoContainerSeller(
              title: 'Costo de envío',
              value: '\$${costoDeEntregas.toStringAsFixed(2)}',
              iconOfTitle: Icon(Icons.fire_truck)),
          const SizedBox(width: 20),
          BuildInfoContainerSeller(
              title: 'Costo Proveedor',
              value: '\$${costoProveedor.toStringAsFixed(2)}',
              iconOfTitle: Icon(Icons.storefront_rounded)),

          const SizedBox(width: 20),
          BuildInfoContainerSeller(
              title: 'Devoluciones',
              value: '\$${devoluciones.toStringAsFixed(2)}',
              iconOfTitle: Icon(Icons.currency_exchange_sharp)),

          const SizedBox(width: 20),
          BuildInfoContainerSeller(
              title: 'Utilidad',
              value: '\$${utilidad.toStringAsFixed(2)}',
              iconOfTitle: Icon(Icons.calculate)),

          const SizedBox(width: 20),
        ],
      ),
      Container(
        height: 60.0, // Ajusta la altura según tus necesidades
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            BuildInfoContainerSeller(
                title: 'Valores recibidos',
                value: '\$${totalValoresRecibidos.toStringAsFixed(2)}',
                iconOfTitle: const Icon(Icons.bookmark_outline_outlined),
                isTitleOnTop: isTitleOnTop),
            const SizedBox(width: 5),
            BuildInfoContainerSeller(
                title: 'Costo de envío',
                value: '\$${costoDeEntregas.toStringAsFixed(2)}',
                iconOfTitle: const Icon(Icons.fire_truck),
                isTitleOnTop: isTitleOnTop),

            const SizedBox(width: 5),
            BuildInfoContainerSeller(
                title: 'Devoluciones',
                value: '\$${devoluciones.toStringAsFixed(2)}',
                iconOfTitle: const Icon(Icons.currency_exchange_sharp),
                isTitleOnTop: isTitleOnTop),
            const SizedBox(width: 5),
            BuildInfoContainerSeller(
                title: 'Utilidad',
                value: '\$${utilidad.toStringAsFixed(2)}',
                iconOfTitle: const Icon(Icons.calculate),
                isTitleOnTop: isTitleOnTop),

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
              const SizedBox(width: 20),
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
              const SizedBox(width: 20),
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
