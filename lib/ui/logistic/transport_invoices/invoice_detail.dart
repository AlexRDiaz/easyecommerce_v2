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

class TransportInvoiceDetail extends StatefulWidget {
  const TransportInvoiceDetail({super.key});

  @override
  State<TransportInvoiceDetail> createState() => _TransportInvoiceDetailState();
}

class _TransportInvoiceDetailState extends State<TransportInvoiceDetail> {
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
    Color color = UIUtils.getColor('NOVEDAD');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators().pushNamedAndRemoveUntil(context,
                  "/layout/logistic/transport-invoices-by-date/by-transport");
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
                  value: 'Innovo',
                  color: color,
                ),
                RowLabel(
                  title: 'Cantidad',
                  value: '1.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Producto',
                  value: 'X1 Cargador Inalambrico',
                  color: color,
                ),
                RowLabel(
                  title: 'Producto Extra',
                  value: 'Envio Prioritario',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Precio Total',
                  value: '25.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Cos. Transportadora',
                  value:
                  '2.5',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Status',
                  value: 'NOVEDAD',
                  color: color,
                ),
                RowLabel(
                  title: 'Fecha',
                  value: '27/09/2023',
                  color: color,
                ),
                RowLabel(
                  title: 'Fecha de entrega',
                  value: '2809/2023',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Transportadora',
                  value: 'Carlos Express',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Estado Devolución',
                  value: '',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Costo DEvolución',
                  value: '',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Marca Tiempo Envío',
                  value: '27/09/2012',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Estado Pago',
                  value: 'PAGADO',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Ganancia Transporte',
                  value: '0.00',
                  color: color,
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
