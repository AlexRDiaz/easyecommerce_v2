import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/helpers/server.dart';

class WalletSellers extends StatefulWidget {
  const WalletSellers({super.key});

  @override
  State<WalletSellers> createState() => _WalletSellersState();
}

class _WalletSellersState extends State<WalletSellers> {
  List data = [];
  String valueWallet = "";
  bool sort = false;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    var response = await Connections().getWithdrawalsSellersListWallet();
    var responseWalletValue = await Connections().getWalletValue();

    setState(() {
      var tempWallet = double.parse(responseWalletValue.toString());
      valueWallet = tempWallet.toStringAsFixed(2) ;
      data = response;
    });
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ListView(
        children: [
          Center(
            child: Wrap(
              children: [
                _modelCard(
                    "Mi Saldo",
                    Center(
                      child: Text(
                        "\$$valueWallet",
                        style: TextStyle(fontSize: 22),
                      ),
                    )),
                _modelCard(
                    "Historial Retiro Efectivo",
                    DataTable2(
                        headingTextStyle:
                            TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        showCheckboxColumn: false,
                        dataTextStyle: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth: 800,
                        columns: [
                          DataColumn2(
                            label: Text('Fecha'),
                            size: ColumnSize.L,
                            onSort: (columnIndex, ascending) {
                              sortFuncDate("Fecha");
                            },
                          ),
                          DataColumn(
                            label: Text('Monto'),
                            onSort: (columnIndex, ascending) {
                              sortFunc("Monto");
                            },
                          ),
                          DataColumn(
                            label: Text('Código'),
                            onSort: (columnIndex, ascending) {
                              sortFunc("Codigo");
                            },
                          ),
                          DataColumn(
                            label: Text('Estado Pago'),
                            onSort: (columnIndex, ascending) {
                              sortFunc("Estado");
                            },
                          ),
                          DataColumn(
                            label: Text('Fecha Hora Transferencia'),
                            onSort: (columnIndex, ascending) {
                              sortFunc("FechaTransferencia");
                            },
                          ),
                          DataColumn(
                            label: Text('Comentario'),
                            onSort: (columnIndex, ascending) {
                              sortFunc("Comentario");
                            },
                          ),
                          DataColumn(
                            label: Text('VER COMPROBANTE'),
                          ),
                        ],
                        rows: List<DataRow>.generate(
                            data.length,
                            (index) => DataRow(
                                    onSelectChanged: (value) async {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return InfoWallet(
                                                fecha: data[index]['attributes']['Fecha']
                                                    .toString(),
                                                monto: data[index]['attributes']['Monto']
                                                    .toString(),
                                                codigo: data[index]['attributes']['Codigo']
                                                    .toString(),
                                                estadoPago: data[index]
                                                        ['attributes']['Estado']
                                                    .toString(),
                                                transferencia: data[index]['attributes']
                                                        ['FechaTransferencia']
                                                    .toString(),
                                                comentario: data[index]['attributes']
                                                        ['Comentario']
                                                    .toString(),
                                                comprobante: data[index]['attributes']['Comprobante'].toString().isEmpty ||
                                                        data[index]['attributes']['Comprobante'].toString() == "null"
                                                    ? ""
                                                    : data[index]['attributes']['Comprobante'].toString());
                                          });
                                    },
                                    cells: [
                                      DataCell(Text(data[index]['attributes']
                                              ['Fecha']
                                          .toString())),
                                      DataCell(Text(data[index]['attributes']
                                              ['Monto']
                                          .toString())),
                                      DataCell(Text(data[index]['attributes']
                                              ['Codigo']
                                          .toString())),
                                      DataCell(Text(data[index]['attributes']
                                              ['Estado']
                                          .toString())),
                                      DataCell(Text(data[index]['attributes']
                                              ['FechaTransferencia']
                                          .toString())),
                                      DataCell(Text(data[index]['attributes']
                                              ['Comentario']
                                          .toString())),
                                      DataCell(TextButton(
                                          onPressed: data[index]['attributes']
                                                          ['Comprobante']
                                                      .toString()
                                                      .isEmpty ||
                                                  data[index]['attributes']
                                                              ['Comprobante']
                                                          .toString() ==
                                                      "null"
                                              ? null
                                              : () {
                                                  launchUrl(Uri.parse(
                                                      "$generalServer${data[index]['attributes']['Comprobante'].toString()}"));
                                                },
                                          child: Text(
                                            "Ver Comprobante",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10),
                                          )))
                                    ])))),
              ],
            ),
          )
        ],
      ),
    );
  }

  sortFuncDate(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) {
        DateTime? dateA = a['attributes'][name] != null
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null
            ? DateFormat("d/M/yyyy").parse(b['attributes'][name].toString())
            : null;
        if (dateA == null && dateB == null) {
          return 0;
        } else if (dateA == null) {
          return 1;
        } else if (dateB == null) {
          return -1;
        } else {
          return dateB.compareTo(dateA);
        }
      });
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) {
        DateTime? dateA = a['attributes'][name] != null
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null
            ? DateFormat("d/M/yyyy").parse(b['attributes'][name].toString())
            : null;
        if (dateA == null && dateB == null) {
          return 0;
        } else if (dateA == null) {
          return -1;
        } else if (dateB == null) {
          return 1;
        } else {
          return dateA.compareTo(dateB);
        }
      });
    }
  }

  sortFunc(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes'][name]
          .toString()
          .compareTo(a['attributes'][name].toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes'][name]
          .toString()
          .compareTo(b['attributes'][name].toString()));
    }
  }

  Container _modelCard(title, content) {
    return Container(
      margin: EdgeInsets.all(10),
      width: 500,
      height: 500,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Divider(),
              Expanded(child: content)
            ],
          ),
        ),
      ),
    );
  }
}

class InfoWallet extends StatefulWidget {
  final String fecha;
  final String monto;
  final String codigo;
  final String estadoPago;
  final String transferencia;
  final String comentario;
  final String comprobante;

  const InfoWallet(
      {super.key,
      required this.fecha,
      required this.monto,
      required this.codigo,
      required this.estadoPago,
      required this.transferencia,
      required this.comentario,
      required this.comprobante});

  @override
  State<InfoWallet> createState() => _InfoWalletState();
}

class _InfoWalletState extends State<InfoWallet> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 500,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Fecha: ${widget.fecha}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Monto: ${widget.monto}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Código: ${widget.codigo}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Estado Pago: ${widget.estadoPago}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Fecha Hora Transferencia: ${widget.transferencia}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Comentario: ${widget.comentario}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Comprobante:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            widget.comprobante.isEmpty
                ? Container()
                : Container(
                    width: double.infinity,
                    child: Image.network("$generalServer${widget.comprobante}"),
                  )
          ],
        ),
      ),
    );
  }
}
