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

class DeliveryHistoryDetails extends StatefulWidget {
  const DeliveryHistoryDetails({super.key});

  @override
  State<DeliveryHistoryDetails> createState() => _DeliveryHistoryDetailsState();
}

class _DeliveryHistoryDetailsState extends State<DeliveryHistoryDetails> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    var response = [];

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
              Navigators().pushNamedAndRemoveUntil(
                  context, "/layout/logistic/delivery-history-by-date");
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
                  value: '12/02/2022',
                  color: color,
                ),
                RowLabel(
                  title: 'Dirección',
                  value: 'Malla del Sol',
                  color: color,
                ),
                RowLabel(
                  title: 'Cantidad',
                  value: '1.0',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Producto',
                  value: 'Producto de muestra',
                  color: color,
                ),
                RowLabel(
                  title: 'Precio Total',
                  value: '2.5',
                  color: color,
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
                  title: 'Comentario',
                  value: 'Gestión no procede',
                  color: color,
                ),
                RowLabel(
                  title: 'Operador',
                  value: 'Carlos Express',
                  color: color,
                ),
                RowLabel(
                  title: 'Transportadora',
                  value: 'TransExpress',
                  color: color,
                ),
                RowLabel(
                  title: 'Estado Logístico',
                  value: '',
                  color: color,
                ),
                RowLabel(
                  title: 'Cos.transportadora',
                  value: '3.44',
                  color: color,
                ),
                RowLabel(
                  title: 'Costo Envio',
                  value: '4.33',
                  color: color,
                ),
                RowLabel(
                  title: 'Nombre Cliente',
                  value: '0.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Teléfono',
                  value: '0.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Fecha de Entrega',
                  value: '0.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Ciudad',
                  value: '0.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Estado Devolución',
                  value: '0.00',
                  color: color,
                ),
                RowLabel(
                  title: 'Costo Devolución',
                  value: '0.00',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Marca Tiempo Envío',
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
