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
import '../../widgets/forms/image_row.dart';
import 'controllers/controllers.dart';

class TransportVoucherDetails extends StatefulWidget {
  const TransportVoucherDetails({super.key});

  @override
  State<TransportVoucherDetails> createState() => _TransportVoucherDetailsState();
}

class _TransportVoucherDetailsState extends State<TransportVoucherDetails> {
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
    Color color = Colors.black;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators().pushNamedAndRemoveUntil(context,
                  "/layout/transport/payment-vouchers/by-transport");
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
                  title: 'Marca de Tiempo',
                  value: 'Innovo',
                  color: color,
                ),
                RowLabel(
                  title: 'Fecha de entrega',
                  value: '12/02/2022',
                  color: color,
                ),
                RowLabel(
                  title: 'Fecha de Depósito',
                  value: 'Malla del Sol',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Transportadora',
                  value: '1.0',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'Valores Recibidos',
                  value: 'Producto de muestra',
                  color: color,
                ),
                RowLabel(
                  title: 'Costo de Entrega',
                  value:
                  '2.5',
                  color: color,
                ),
                RowImage(
                  title: "Comprobante",
                  value:
                  "https://www.state.gov/wp-content/uploads/2019/04/Ecuador-e1556042668750-2501x1406.jpg",
                ),
                RowLabel(
                  title: 'Monto a depositar',
                  value: 'NOVEDAD',
                  color: Colors.black,
                ),
                RowLabel(
                  title: 'ID Validación',
                  value: '27/09/2023',
                  color: color,
                ),
                RowLabel(
                  title: 'Estado Recibido',
                  value: 'Gestión no procede',
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
