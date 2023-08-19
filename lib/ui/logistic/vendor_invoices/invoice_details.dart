import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/row_label.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import 'controllers/controllers.dart';

class InvoiceByVendorsDetail extends StatefulWidget {
  const InvoiceByVendorsDetail({super.key});

  @override
  State<InvoiceByVendorsDetail> createState() => _InvoiceByVendorsDetailState();
}

class _InvoiceByVendorsDetailState extends State<InvoiceByVendorsDetail> {
  String id = "";

  @override
  void initState() {
    super.initState();
    if (Get.parameters['id'] != null) {
      id = Get.parameters['id'] as String;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  getLoadingModal(context, false);
    });
  }

  var data = {};
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color color = UIUtils.getColor('ENTREGADO');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators().pushNamedAndRemoveUntil(context,
                  "/layout/logistic/vendor-invoices-by-vendor/by-date");
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black)),
        centerTitle: true,
        title: const Text(
          "",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                RowLabel(
                  title: 'Código',
                  value: 'Elrinconcito#7024',
                  color: color,
                ),
                RowLabel(
                  title: 'Fecha',
                  value: '30/09/2022',
                  color: color,
                ),
                RowLabel(
                  title: 'Fecha de Entrega',
                  value: '30/09/2022',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Ciudad',
                  value: 'Quito. Conocoto',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Nombre',
                  value: 'Humberto Vallejo',
                  color: color,
                ),
                RowLabel(
                  title: 'Dirección',
                  value:
                      'Carlos salas n761 y miguel de santiagoser Servidorrs de la salud a 50 metros ',
                  color: color,
                ),
                RowLabel(
                  title: 'Cantidad',
                  value: '1.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Producto',
                  value: 'Liquido Reparador de Vidrio',
                  color: color,
                ),
                RowLabel(
                  title: 'Producto Extra',
                  value: 'Envio Prioritario',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Precio total',
                  value: '21,.98',
                  color: color,
                ),
                RowLabel(
                  title: 'Estatus',
                  value: 'ENTREGADO',
                  color: color,
                ),
                RowLabel(
                  title: 'Comentario',
                  value: 'Sin novedad',
                  color: color,
                ),
                RowLabel(
                  title: 'Costo Envío',
                  value: '21,.98',
                  color: color,
                ),
                RowLabel(
                  title: 'Vendedor',
                  value: 'El rinconcito Ecuatoriano',
                  color: color,
                ),
                RowLabel(
                  title: 'Costo Devolución',
                  value: '',
                  color: color,
                ),
                RowLabel(
                  title: 'Marca Tiempo Envío',
                  value: '30/09/2022',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Estado Pago',
                  value: 'Pendiente',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Ganancias Vendedor',
                  value: '21,.98',
                  color: Colors.black,
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
