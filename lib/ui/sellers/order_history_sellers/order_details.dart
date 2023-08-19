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

class OrderHistoryDetails extends StatefulWidget {
  const OrderHistoryDetails({super.key});

  @override
  State<OrderHistoryDetails> createState() => _OrderHistoryDetailsState();
}

class _OrderHistoryDetailsState extends State<OrderHistoryDetails> {
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
                  "/layout/sellers");
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
                  title: 'Fecha',
                  value: '1.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Fecha de Entrega',
                  value: 'X1 Cargador Inalambrico',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Ciudad',
                  value: 'Envio Prioritario',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Nombre Cliente',
                  value: '25.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Dirección',
                  value:
                  '2.5',
                  color: color,
                ),
                RowLabel(
                  title: 'Teléfono Cliente',
                  value: 'NOVEDAD',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Teléfono',
                  value: '27/09/2023',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Cantidad',
                  value: '2',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Producto',
                  value: 'Carlos Express',
                  color: color,
                ),
                RowLabel(
                  title: 'Precio Total',
                  value: '',
                  color:  color,
                ),
                RowLabel(
                  title: 'Status',
                  value: '',
                  color:  color,
                ),
                RowLabel(
                  title: 'Costo Envío',
                  value: '27/09/2012',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Estado Logístico',
                  value: 'PAGADO',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Costo Devolución',
                  value: '0.00',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Marca Tiempo Envio',
                  value: '0.00',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Estado Pago',
                  value: '0.00',
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
