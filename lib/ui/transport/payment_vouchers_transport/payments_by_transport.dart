import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/ui/logistic/income_and_expenses/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'controllers/controllers.dart';

class PaymentVoucherByTransport extends StatefulWidget {
  const PaymentVoucherByTransport({super.key});

  @override
  State<PaymentVoucherByTransport> createState() => _PaymentVoucherByTransportState();
}

class _PaymentVoucherByTransportState extends State<PaymentVoucherByTransport> {
  /// todo: formulario y detalle
  final TransportPaymentControllers _controllers =
  TransportPaymentControllers();
  List optionsCheckBox = [];
  int counterChecks = 0;
  List data = [];
  String id="";

  @override
  void initState() {
    super.initState();
    if (Get.parameters['id']!=null) {
      id = Get.parameters['id'] as String;
    }
  }

  loadData() async {
    var response = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    /*response = await Connections().getOrdersForPrintGuidesInSendGuides(
        _controllers.searchController.text, Get.parameters['date'].toString());

    data = response;*/
    setState(() {
      optionsCheckBox = [];
      counterChecks = 0;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comprobantes de pago"),
        leading: InkWell(
          onTap: () {
            Navigators().pushNamedAndRemoveUntil(
                context, "/layout/transport");
          },
          child: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _modelTextField(
                  text: "Búsqueda", controller: _controllers.searchController),
            ),
            Expanded(
              child: DataTable2(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 6,
                minWidth: 2000,
                fixedLeftColumns: 2,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn2(
                    label: Text(''),
                    size: ColumnSize.S,
                    fixedWidth: 30,
                  ),
                  DataColumn2(
                    label: Text('Fecha de Entrega'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Fecha de Depósito'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Valores Recibidos'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Costo de Entregas'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Monto a depositar'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Estado Recibido'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text(''),
                    size: ColumnSize.S,
                    fixedWidth: 30,
                  ),
                ],
                rows: List<DataRow>.generate(
                  10,
                      (index) {
                    return DataRow(
                      onSelectChanged: (bool? selected) {
                        Navigators().pushNamed(
                          context,
                          '/layout/transport/payment-vouchers/by-transport/details?id=0',
                        );
                      },
                      cells: [
                        DataCell(Checkbox(value: false, onChanged: (value) {})),
                        DataCell(
                          Text(
                            '24/01/2023',
                          ),
                        ),
                        DataCell(
                          Text(
                            '24/01/2023',
                          ),
                        ),
                        DataCell(
                          Text(
                            '25.00',
                          ),
                        ),
                        DataCell(
                          Text(
                            '35,2',
                          ),
                        ),
                        DataCell(
                          Text(
                            '56,75',
                          ),
                        ),
                        DataCell(
                          Text(
                            'Recibido',
                          ),
                        ),
                        DataCell(
                          const Icon(
                            Icons.arrow_forward_ios_sharp,
                            size: 15,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {});
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
            onTap: () {
              setState(() {
                _controllers.searchController.clear();
              });
            },
            child: const Icon(Icons.close),
          )
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromRGBO(237, 241, 245, 1.0),
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }
}
