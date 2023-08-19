import 'package:data_table_2/data_table_2.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/row_label.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import 'controllers/controllers.dart';

class AccountStatusDetail extends StatefulWidget {
  const AccountStatusDetail({super.key});

  @override
  State<AccountStatusDetail> createState() => _AccountStatusDetailState();
}

class _AccountStatusDetailState extends State<AccountStatusDetail> {
  List data = [];
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

    response = await Connections().getWithdrawalsSellersListWalletById();
    setState(() {
      data = response;
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
              Navigators().pushNamedAndRemoveUntil(context, "/layout/logistic");
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
            child: DataTable2(
                headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                columns: [
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.L,
                  ),
                  DataColumn(
                    label: Text('Monto'),
                  ),
                  DataColumn(
                    label: Text('Código'),
                  ),
                  DataColumn(
                    label: Text('Estado Pago'),
                  ),
                  DataColumn(
                    label: Text('Fecha Hora Transferencia'),
                  ),
                  DataColumn(
                    label: Text('Comentario'),
                  ),
                  DataColumn(
                    label: Text('Comprobante'),
                  ),
                ],
                rows: List<DataRow>.generate(
                    data.length,
                    (index) => DataRow(cells: [
                          DataCell(Text(
                              data[index]['attributes']['Fecha'].toString())),
                          DataCell(Text(
                              data[index]['attributes']['Monto'].toString())),
                          DataCell(Text(
                              data[index]['attributes']['Codigo'].toString())),
                          DataCell(Text(
                              data[index]['attributes']['Estado'].toString())),
                          DataCell(Text(data[index]['attributes']
                                  ['FechaTransferencia']
                              .toString())),
                          DataCell(Text(data[index]['attributes']['Comentario']
                              .toString())),
                          DataCell(TextButton(
                              onPressed: data[index]['attributes']['Estado']
                                          .toString() ==
                                      "REALIZADO"
                                  ? () {
                                      if (data[index]['attributes']
                                                  ['Comprobante']
                                              .toString() !=
                                          null) {
                                        launchUrl(Uri.parse(
                                            "$generalServer${data[index]['attributes']['Comprobante'].toString()}"));
                                      }
                                    }
                                  : null,
                              child: Text(
                                "Ver Comprobante",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )))
                        ])))),
      ),
    );
  }
}
