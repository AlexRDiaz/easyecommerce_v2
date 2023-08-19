import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/ui/operator/received_values.dart/info_received_orders.dart';
import 'package:intl/intl.dart';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/navigators.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/transport/my_orders_prv/controllers/controllers.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/routes/sub_routes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/helpers/server.dart';

class ReceivedValues extends StatefulWidget {
  const ReceivedValues({super.key});

  @override
  State<ReceivedValues> createState() => _ReceivedValuesState();
}

class _ReceivedValuesState extends State<ReceivedValues> {
  MyOrdersPRVTransportControllers _controllers =
      MyOrdersPRVTransportControllers();
  List data = [];
  List<DateTime?> _dates = [];
  double suma = 0.0;
  double sumaCosto = 0.0;
  String statusPagado = 'PENDIENTE';
  List dataTemporal = [];
  String option = "";
  bool sort = false;

  List bools = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List titlesFilters = [
    "Fecha",
    "Código",
    "Ciudad",
    "Nombre Cliente",
    "Dirección",
    "Teléfono Cliente",
    "Cantidad",
    "Producto",
    "Producto Extra",
    "Precio Total",
    "Observación",
    "Comentario",
    "Status",
    "Fecha Entrega",
    "Tipo",
    "Estado de Pago"
  ];
  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

//SUMA LOS ESTATUS ENTREGADO Y NO ENTREGADOS VALOR COSTO OPERADOR
  loadData() async {
    var response = [];
    setState(() {
      suma = 0.0;
      sumaCosto = 0.0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    if (_controllers.searchController.text.isEmpty) {
      response = await Connections()
          .getOrdersForOperatorState(_controllers.searchController.text);
    } else {
      String params =
          "&filters[\$or][0][Marca_Tiempo_Envio][\$contains]=${_controllers.searchController.text}&filters[\$or][1][Fecha_Entrega][\$contains]=${_controllers.searchController.text}&filters[\$or][2][NumeroOrden][\$contains]=${_controllers.searchController.text}&filters[\$or][3][NombreShipping][\$contains]=${_controllers.searchController.text}&filters[\$or][4][CiudadShipping][\$contains]=${_controllers.searchController.text}&filters[\$or][5][DireccionShipping][\$contains]=${_controllers.searchController.text}&filters[\$or][6][TelefonoShipping][\$contains]=${_controllers.searchController.text}&filters[\$or][7][Cantidad_Total][\$contains]=${_controllers.searchController.text}&filters[\$or][8][ProductoP][\$contains]=${_controllers.searchController.text}&filters[\$or][9][ProductoExtra][\$contains]=${_controllers.searchController.text}&filters[\$or][10][PrecioTotal][\$contains]=${_controllers.searchController.text}&filters[\$or][11][Observacion][\$contains]=${_controllers.searchController.text}&filters[\$or][12][Comentario][\$contains]=${_controllers.searchController.text}&filters[\$or][13][Status][\$contains]=${_controllers.searchController.text}&filters[\$or][14][TipoPago][\$contains]=${_controllers.searchController.text}&filters[\$or][15][Estado_Pagado][\$contains]=${_controllers.searchController.text}";
      response = await Connections().getOrdersForOperatorStateForCode(params);
    }

    data = response;

    for (var i = 0; i < response.length; i++) {
      if (response[i]['attributes']['Status'].toString() == "ENTREGADO") {
        setState(() {
          statusPagado = response[i]['attributes']['Estado_Pagado'];
        });
      }
    }
    dataTemporal = response;

    for (var i = 0; i < response.length; i++) {
      if (response[i]['attributes']['Status'].toString() == "ENTREGADO") {
        suma +=
            double.parse(response[i]['attributes']['PrecioTotal'].toString());
      }
    }
    for (var i = 0; i < response.length; i++) {
      if (response[i]['attributes']['Status'].toString() == "ENTREGADO" ||
          response[i]['attributes']['Status'].toString() == "NO ENTREGADO") {
        sumaCosto += double.parse(response[i]['attributes']['operadore']['data']
                ['attributes']['Costo_Operador']
            .toString());
      }
    }

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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: double.infinity,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () async {
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
            Text(
              " Valores Recibidos: \$${suma.toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              " Costo Entrega: \$${sumaCosto.toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              " Total: \$${(suma - sumaCosto).toStringAsFixed(2)}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              " Estado de Pago: $statusPagado",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            statusPagado == "PAGADO"
                ? TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          "$generalServer${data.isNotEmpty ? data[0]['attributes']['Url_Pagado_Foto'].toString() : ''}"));
                    },
                    child: Text(
                      "VER COMPROBANTE",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))
                : Container(),
            SizedBox(
              height: 10,
            ),
            statusPagado == "PAGADO"
                ? ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image!.path.isNotEmpty &&
                          image!.path.toString() != "null") {
                        getLoadingModal(context, false);

                        var responseI = await Connections().postDoc(image);

                        for (var i = 0; i < data.length; i++) {
                          if (data[i]['attributes']['Status'].toString() ==
                              "ENTREGADO") {
                            var response = await Connections()
                                .updateOrderPayState(
                                    data[i]['id'], responseI[1]);
                          }
                        }
                        await loadData();
                        setState(() {});
                        Navigator.pop(context);
                      } else {}
                    },
                    child: Text(
                      "CAMBIAR COMPROBANTE",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ))
                : ElevatedButton(
                    onPressed: _controllers.searchController.text.isNotEmpty
                        ? null
                        : () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (image!.path.isNotEmpty &&
                                image!.path.toString() != "null") {
                              getLoadingModal(context, false);

                              var responseI =
                                  await Connections().postDoc(image);

                              for (var i = 0; i < data.length; i++) {
                                if (data[i]['attributes']['Status']
                                        .toString() ==
                                    "ENTREGADO") {
                                  var response = await Connections()
                                      .updateOrderPayState(
                                          data[i]['id'], responseI[1]);
                                }
                              }
                              await loadData();
                              setState(() {});
                              Navigator.pop(context);
                            } else {}
                          },
                    child: Text(
                      "REALIZAR PAGO",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    )),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              child: _modelTextField(
                  text: "Busqueda", controller: _controllers.searchController),
            ),
            // _filters(context),
            Expanded(
              child: DataTable2(
                  headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  dataTextStyle:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
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
                        onSort: (columnIndex, ascending) {
                          sortFunc("Cantidad_Total");
                        },
                        numeric: true),
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
                        onSort: (columnIndex, ascending) {
                          sortFunc("PrecioTotal");
                        },
                        numeric: true),
                    DataColumn2(
                        label: Text('Observación'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("Observacion");
                        },
                        numeric: true),
                    DataColumn2(
                        label: Text('Comentario'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          sortFunc("Comentario");
                        },
                        numeric: true),
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
                      label: Text('Estado de Pago'),
                      size: ColumnSize.M,
                      onSort: (columnIndex, ascending) {
                        sortFunc("Estado_Pagado");
                      },
                    ),
                  ],
                  rows: List<DataRow>.generate(
                      data.isNotEmpty ? data.length : [].length,
                      (index) => DataRow(
                              onSelectChanged: (value) {
                                 info(context, index);
                              },
                              cells: [
                                DataCell(Text(data[index]['attributes']
                                        ['Marca_Tiempo_Envio']
                                    .toString()
                                    .split(" ")[0])),
                                DataCell(Text(data[index]['attributes']
                                        ['Fecha_Entrega']
                                    .toString())),
                                DataCell(Text(
                                    '${data[index]['attributes']['Name_Comercial'].toString()}-${data[index]['attributes']['NumeroOrden'].toString()}')),
                                DataCell(Text(data[index]['attributes']
                                        ['NombreShipping']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['CiudadShipping']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['DireccionShipping']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['TelefonoShipping']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['Cantidad_Total']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['ProductoP']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['ProductoExtra']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['PrecioTotal']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['Observacion']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['Comentario']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['Status']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['TipoPago']
                                    .toString())),
                                DataCell(Text(data[index]['attributes']
                                        ['Estado_Pagado']
                                    .toString())),
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
          // getLoadingModal(context, false);

          // setState(() {
          //   data = dataTemporal;
          // });
          // if (value.isEmpty) {
          //   setState(() {
          //     data = dataTemporal;
          //   });
          // } else {
          //   if (option.isEmpty) {
          //     var dataTemp = data
          //         .where((objeto) =>
          //             objeto['attributes']['Marca_Tiempo_Envio']
          //                 .toString()
          //                 .split(" ")[0]
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['NumeroOrden']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['CiudadShipping']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['NombreShipping']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['DireccionShipping']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['TelefonoShipping']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['Cantidad_Total']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['ProductoP']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['ProductoExtra']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['PrecioTotal']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()) ||
          //             objeto['attributes']['Observacion'].toString().toLowerCase().contains(value.toLowerCase()) ||
          //             objeto['attributes']['Comentario'].toString().toLowerCase().contains(value.toLowerCase()) ||
          //             objeto['attributes']['Status'].toString().toLowerCase().contains(value.toLowerCase()) ||
          //             objeto['attributes']['Fecha_Entrega'].toString().toLowerCase().contains(value.toLowerCase()) ||
          //             objeto['attributes']['TipoPago'].toString().toLowerCase().contains(value.toLowerCase()) ||
          //             objeto['attributes']['Estado_Pagado'].toString().toLowerCase().contains(value.toLowerCase()))
          //         .toList();
          //     setState(() {
          //       data = dataTemp;
          //     });
          //   } else {
          //     switch (option) {
          //       case "Fecha":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']
          //                     ['Marca_Tiempo_Envio']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Código":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['NumeroOrden']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Ciudad":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['CiudadShipping']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Nombre Cliente":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['NombreShipping']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Dirección":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']
          //                     ['DireccionShipping']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Teléfono Cliente":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']
          //                     ['TelefonoShipping']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Cantidad":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['Cantidad_Total']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Producto":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['ProductoP']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Producto Extra":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['ProductoExtra']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Precio Total":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['PrecioTotal']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Observación":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['Observacion']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Comentario":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['Comentario']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Status":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['Status']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Fecha Entrega":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['Fecha_Entrega']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Tipo":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['TipoPago']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       case "Estado de Pago":
          //         var dataTemp = data
          //             .where((objeto) => objeto['attributes']['Estado_Pagado']
          //                 .toString()
          //                 .toLowerCase()
          //                 .contains(value.toLowerCase()))
          //             .toList();
          //         setState(() {
          //           data = dataTemp;
          //         });
          //         break;
          //       default:
          //     }
          //   }
          // }
          // Navigator.pop(context);
          loadData();
        },
        onChanged: (value) {},
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _controllers.searchController.clear();
                    });
                    setState(() {
                      data = dataTemporal;
                    });
                    loadData();
                    Navigator.pop(context);
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

  _filters(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        content: Container(
                          width: 500,
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.close)),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Filtros:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: Center(
                                  child: ListView(
                                    children: [
                                      Wrap(
                                        children: [
                                          ...List.generate(
                                              titlesFilters.length,
                                              (index) => Container(
                                                    width: 140,
                                                    child: Row(
                                                      children: [
                                                        Checkbox(
                                                            value: bools[index],
                                                            onChanged: (v) {
                                                              if (bools[
                                                                      index] ==
                                                                  true) {
                                                                setState(() {
                                                                  bools[index] =
                                                                      false;
                                                                  option = "";
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  bools[index] =
                                                                      true;
                                                                  option =
                                                                      titlesFilters[
                                                                          index];
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          bools
                                                                              .length;
                                                                      i++) {
                                                                    if (i !=
                                                                        index) {
                                                                      bools[i] =
                                                                          false;
                                                                    }
                                                                  }
                                                                });
                                                              }
                                                              Navigator.pop(
                                                                  context);
                                                            }),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          titlesFilters[index],
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12),
                                                        )
                                                      ],
                                                    ),
                                                  ))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  });
              setState(() {});
            },
            icon: Icon(Icons.filter_alt_outlined)),
        Flexible(
            child: Text(
          "Activo: $option",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ))
      ],
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
    Future<dynamic> info(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                      child: InfoReceivedValuesOperator(
                    id: data[index]['id'].toString(),
                  ))
                ],
              ),
            ),
          );
        });
  }
}
