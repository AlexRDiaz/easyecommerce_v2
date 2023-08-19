import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/ui/logistic/income_and_expenses/controllers/controllers.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'controllers/controllers.dart';

class OrdersHistoryTransport extends StatefulWidget {
  const OrdersHistoryTransport({super.key});

  @override
  State<OrdersHistoryTransport> createState() => _OrdersHistoryTransportState();
}

class _OrdersHistoryTransportState extends State<OrdersHistoryTransport> {
  final OrdersHistoryTransportControllers _controllers = OrdersHistoryTransportControllers();
  List optionsCheckBox = [];
  int counterChecks = 0;
  List data = [];
  String id = "";

  @override
  void initState() {
    super.initState();
    if (Get.parameters['id'] != null) {
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
                columns: [
                  DataColumn2(
                    label: Text(''),
                    size: ColumnSize.S,
                    fixedWidth: 30,
                  ),
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Fecha de Entrega'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Código'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Ciudad'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Nombre Cliente'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Dirección'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Teléfono'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Cantidad'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Producto'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Producto Extra'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Precio Total'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Operador'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Status'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Cos. Transportadora'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Logística ADM'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Estado Devolución'),
                    size: ColumnSize.M,
                    numeric: true,
                  ),
                  DataColumn2(
                    label: Text('Costo Devolución'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Marca Tiempo Envío'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Estado Pago'),
                    size: ColumnSize.M,
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
                    Color rowColor = UIUtils.getColor('NOVEDAD');
                    return DataRow(
                      onSelectChanged: (bool? selected) {
                        Navigators().pushNamed(
                          context,
                          '/layout/transport/order-history/details?id=0',
                        );
                      },
                      cells: [
                        DataCell(Checkbox(value: false, onChanged: (value) {})),
                        DataCell(Text(
                          '6426',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          '',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          '9/26/2022 3:18:30 PM',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          '9/26/2022',
                        )),
                        DataCell(Text(
                          'X3 CEPILLO DENTAL MAGICCLEAN® PRO',
                        )),
                        DataCell(Text(
                          '39',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          '\$398.00',
                        )),
                        DataCell(Text(
                          'X3 CEPILLO DENTAL MAGICCLEAN® PRO',

                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text('QUITO', style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text(
                          'Novedad',
                        )),
                        DataCell(Text(
                          'Iiii',

                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          'QUITO',
                        )),
                        DataCell(Text('HALCON PRO', style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text('Fernando Ushiña', style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text(
                          'MANDE STORE',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          '9/28/2022',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          'DIEGO TONGUINO',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text(
                          '+5930995087305',
                        )),
                        DataCell(Text(
                          'En Bodega',
                        )),
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
