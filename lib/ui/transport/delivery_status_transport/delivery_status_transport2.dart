import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/delivery_status_transport/delivery_details.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:intl/intl.dart';

class DeliveryStatusTransport extends StatefulWidget {
  const DeliveryStatusTransport({super.key});

  @override
  State<DeliveryStatusTransport> createState() =>
      _DeliveryStatusTransportState();
}

class _DeliveryStatusTransportState extends State<DeliveryStatusTransport> {
  MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();
  List data = [];
  List<DateTime?> _dates = [];
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
    var response = [];

    if (_controllers.searchController.text.isEmpty) {
      response = await Connections()
          .getOrdersForTransportState(_controllers.searchController.text);
    } else {
      response = await Connections()
          .getOrdersForTransportStateCode(_controllers.searchController.text);
    }

    data = response;

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            _modelTextField(
                text: "Buscar", controller: _controllers.searchController),
            Container(
                width: double.infinity,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () async {
                          setState(() {
                            _controllers.searchController.clear();
                          });
                          var results = await showCalendarDatePicker2Dialog(
                            context: context,
                            config: CalendarDatePicker2WithActionButtonsConfig(
                              dayTextStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              yearTextStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              selectedYearTextStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                              weekdayLabelTextStyle:
                                  TextStyle(fontWeight: FontWeight.bold),
                            ),
                            dialogSize: const Size(325, 400),
                            value: _dates,
                            borderRadius: BorderRadius.circular(15),
                          );
                          setState(() {
                            if (results != null) {
                              String fechaOriginal = results![0]
                                  .toString()
                                  .split(" ")[0]
                                  .split('-')
                                  .reversed
                                  .join('-')
                                  .replaceAll("-", "/");
                              List<String> componentes =
                                  fechaOriginal.split('/');

                              String dia = int.parse(componentes[0]).toString();
                              String mes = int.parse(componentes[1]).toString();
                              String anio = componentes[2];

                              String nuevaFecha = "$dia/$mes/$anio";

                              sharedPrefs!
                                  .setString("dateOperatorState", nuevaFecha);
                            }
                          });
                          loadData();
                        },
                        child: Text(
                          "Seleccionar Fecha",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Fecha: ${sharedPrefs!.getString("dateOperatorState")}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                )),
            Expanded(
              child: DataTable2(
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 2500,
                  columns: [
                    DataColumn2(
                      label: Text('Fecha'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_Tiempo_Envio");
                      },
                    ),
                    DataColumn2(
                      label: Text('Fecha de Entrega'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Fecha_Entrega");
                      },
                    ),
                    DataColumn2(
                      label: Text('Código'),
                      size: ColumnSize.S,
                      onSort: (columnIndex, ascending) {
                        sortFunc("NumeroOrden");
                      },
                    ),
                    DataColumn2(
                      label: Text('Nombre Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("NombreShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Ciudad'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("CiudadShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Dirección'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("DireccionShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Teléfono Cliente'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("TelefonoShipping");
                      },
                    ),
                    DataColumn2(
                      label: Text('Cantidad'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Cantidad_Total");
                      },
                    ),
                    DataColumn2(
                      label: Text('Producto'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("ProductoP");
                      },
                    ),
                    DataColumn2(
                      label: Text('Producto Extra'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("ProductoExtra");
                      },
                    ),
                    DataColumn2(
                      label: Text('Precio Total'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("PrecioTotal");
                      },
                    ),
                    DataColumn2(
                      label: Text('Observación'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Observacion");
                      },
                    ),
                    DataColumn2(
                      label: Text('Comentario'),
                      size: ColumnSize.M,
                      numeric: true,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Comentario");
                      },
                    ),
                    DataColumn2(
                      label: Text('Status'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Status");
                      },
                    ),
                    DataColumn2(
                      label: Text('Tipo de Pago'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("TipoPago");
                      },
                    ),
                    DataColumn2(
                      label: Text('Sub Ruta'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncSubRoute();
                      },
                    ),
                    DataColumn2(
                      label: Text('Operador'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncOperator();
                      },
                    ),
                    DataColumn2(
                      label: Text('Est. Dev'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Devolucion");
                      },
                    ),
                    DataColumn2(
                      label: Text('MDT. OF.'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Marca_T_D");
                      },
                    ),
                    DataColumn2(
                      label: Text('MDT. BOD'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_T_D_L");
                      },
                    ),
                    DataColumn2(
                      label: Text('MDT. RUTA'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_T_D_T");
                      },
                    ),
                    DataColumn2(
                      label: Text('MTD. INP'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFuncDate("Marca_T_I");
                      },
                    ),
                    DataColumn2(
                      label: Text('Estado de Pago'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Pagado");
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.isNotEmpty ? data.length : [].length,
                      (index) => DataRow(cells: [
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Marca_Tiempo_Envio']
                                    .toString()
                                    .split(" ")[0]), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Fecha_Entrega']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(
                                    '${data[index]['attributes']['Name_Comercial'].toString()}-${data[index]['attributes']['NumeroOrden'].toString()}'),
                                onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['NombreShipping']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['CiudadShipping']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['DireccionShipping']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['TelefonoShipping']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Cantidad_Total']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoP']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['ProductoExtra']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['PrecioTotal']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Observacion']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Comentario']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Status']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['TipoPago']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['sub_ruta']
                                            ['data'] !=
                                        null
                                    ? data[index]['attributes']['sub_ruta']
                                            ['data']['attributes']['Titulo']
                                        .toString()
                                    : ""), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['operadore']
                                            ['data'] !=
                                        null
                                    ? data[index]['attributes']['operadore']
                                            ['data']['attributes']['user']
                                        ['data']['attributes']['username']
                                    : "".toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']
                                        ['Estado_Devolucion']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Marca_T_D']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Marca_T_D_L']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Marca_T_D_T']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Marca_T_I']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            DataCell(
                                Text(data[index]['attributes']['Estado_Pagado']
                                    .toString()), onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height,
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                            Expanded(
                                                child:
                                                    TransportProDeliveryHistoryDetails(
                                              id: data[index]['id'].toString(),
                                            ))
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                          ]))),
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
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
        },
        onChanged: (value) {
          setState(() {});
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
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

  sortFuncOperator() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes']['operadore']['data']['attributes']
              ['user']['data']['attributes']['username']
          .toString()
          .compareTo(a['attributes']['operadore']['data']['attributes']['user']
                  ['data']['attributes']['username']
              .toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes']['operadore']['data']['attributes']
              ['user']['data']['attributes']['username']
          .toString()
          .compareTo(b['attributes']['operadore']['data']['attributes']['user']
                  ['data']['attributes']['username']
              .toString()));
    }
  }

  sortFuncDate(name) {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) {
        DateTime? dateA = a['attributes'][name] != null &&
                a['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null &&
                b['attributes'][name].toString().isNotEmpty
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
        DateTime? dateA = a['attributes'][name] != null &&
                a['attributes'][name].toString().isNotEmpty
            ? DateFormat("d/M/yyyy").parse(a['attributes'][name].toString())
            : null;
        DateTime? dateB = b['attributes'][name] != null &&
                b['attributes'][name].toString().isNotEmpty
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

  sortFuncSubRoute() {
    if (sort) {
      setState(() {
        sort = false;
      });
      data.sort((a, b) => b['attributes']['sub_ruta']['data']['attributes']
              ['Titulo']
          .toString()
          .compareTo(a['attributes']['sub_ruta']['data']['attributes']['Titulo']
              .toString()));
    } else {
      setState(() {
        sort = true;
      });
      data.sort((a, b) => a['attributes']['sub_ruta']['data']['attributes']
              ['Titulo']
          .toString()
          .compareTo(b['attributes']['sub_ruta']['data']['attributes']['Titulo']
              .toString()));
    }
  }
}
