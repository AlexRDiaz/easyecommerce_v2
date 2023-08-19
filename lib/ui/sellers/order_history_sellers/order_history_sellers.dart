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

class OrderHistorySellers extends StatefulWidget {
  const OrderHistorySellers({super.key});

  @override
  State<OrderHistorySellers> createState() => _OrderHistorySellersState();
}

class _OrderHistorySellersState extends State<OrderHistorySellers> {
  final OrderHistorySellersControllers _controllers =
      OrderHistorySellersControllers();
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
                    label: Text('Código'),
                    size: ColumnSize.S,
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
                    label: Text('Ciudad'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Nombre Cliente'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Dirección'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Teléfono Cliente'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Teléfono'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Cantidad'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Producto'),
                    size: ColumnSize.M,
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
                    label: Text('Status'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Comentario'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Costo Envio'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Estado Logistico'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('LOGISTICA/ADM'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Estado Devolución'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Costo Devolución'),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Marca Tiempo Envio'),
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
                          '/layout/sellers/order-history/details?id=0',
                        );
                      },
                      cells: [
                        DataCell(Checkbox(value: false, onChanged: (value) {})),
                        DataCell(Text(
                          '123abc',
                          style: TextStyle(
                            color: rowColor,
                          ),
                        )),
                        DataCell(Text('3/8/2023 8:55',style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text('3/8/2023 8:55')),
                        DataCell(Text('Quito')),
                        DataCell(Text('IMNOVO')),
                        DataCell(Text('IMNOVO', style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text('0992989693')),
                        DataCell(Text('0992989693')),
                        DataCell(Text('3')),
                        DataCell(Text('IMNOVO', style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text('IMNOVO',style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text('\$3.50')),
                        DataCell(Text('IMNOVO', style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text('IMNOVO', style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text('\$3.50', style: TextStyle(
                          color: rowColor,
                        ),)),
                        DataCell(Text('IMNOVO')),
                        DataCell(Text('IMNOVO')),
                        DataCell(Text('IMNOVO')),
                        DataCell(Text('\$3.50')),
                        DataCell(Text('IMNOVO')),
                        DataCell(Text('IMNOVO')),
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
