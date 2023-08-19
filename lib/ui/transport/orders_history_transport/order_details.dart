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

class OrderProDeliveryHistoryDetails extends StatefulWidget {
  const OrderProDeliveryHistoryDetails({super.key});

  @override
  State<OrderProDeliveryHistoryDetails> createState() => _OrderProDeliveryHistoryDetailsState();
}

class _OrderProDeliveryHistoryDetailsState extends State<OrderProDeliveryHistoryDetails> {
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
    Color color = UIUtils.getColor('reagendado');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators().pushNamedAndRemoveUntil(context,
                  "/layout/transport");
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black)),
        centerTitle: true,
        title: const Text(
          "Detalles",
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
                  value: '12/02/2022',
                  color: color,
                ),
                RowLabel(
                  title: 'Ciudad',
                  value: 'Malla del Sol',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Nombre de Cliente',
                  value: '1.0',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Dirección',
                  value:
                  '2.5',
                  color: color,
                ),
                RowLabel(
                  title: 'Teléfono',
                  value: 'NOVEDAD',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Cantidad',
                  value: '27/09/2023',
                  color: color,
                ),
                RowLabel(
                  title: 'Producto',
                  value: 'Gestión no procede',
                  color: color,
                ),
                RowLabel(
                  title: 'Precio Total',
                  value: 'Carlos Express',
                  color: color,
                ),
                RowLabel(
                  title: 'Operador',
                  value: 'TransExpress',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Status',
                  value: 'REAGENDADO',
                  color: color,
                ),
                RowLabel(
                  title: 'Costo Transportadora',
                  value: '3.44',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Marca Tiempo Envío',
                  value: '4.33',
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
