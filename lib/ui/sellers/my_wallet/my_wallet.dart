import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/sellers/my_wallet/controllers/my_wallet_controller.dart';
import 'package:frontend/ui/widgets/transport/data_table_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Transaction {
  final String title;
  final double amount;

  Transaction(this.title, this.amount);
}

class MyWallet extends StatefulWidget {
  @override
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  MyWalletController walletController = MyWalletController();
  TextEditingController searchController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String saldo = '0';
  List data = [];
  String start = "";
  String end = "";
  List arrayFiltersAnd = [];
  List<String> listOrigen = [
    'TODO',
    'RECAUDO',
    'ENVIO',
    'REFERENCIADO',
    'DEVOLUCION',
    'REEMBOLSO'
  ];
  TextEditingController origenController = TextEditingController(text: "TODO");

  // Saldo

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    var res = await walletController.getSaldo();
    setState(() {
      saldo = res;
    });

    try {
      var response =
          await Connections().getTransactionsBySeller([], [], [], 1, 100, "");

      setState(() {
        data = response["data"];
      });
    } catch (e) {
      print(e);
    }
  }

  filterData() async {
    arrayFiltersAnd.add({
      "id_vendedor":
          sharedPrefs!.getString("idComercialMasterSeller").toString()
    });

    try {
      var response = await Connections().getTransactionsByDate(
          start, end, searchController.text, arrayFiltersAnd);

      setState(() {
        data = response;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.only(left: width * 0.01, right: width * 0.01),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Mi Billetera',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _leftWidget(width, heigth, context),
                  Container(
                    child: Column(
                      children: [
                        _searchBar(width, heigth, context),
                        _dataTableTransactions(),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Container _dataTableTransactions() {
    return Container(
      height: 700,
      width: 1070,
      child: Expanded(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: DataTableModelPrincipal(
              columnWidth: 400,
              columns: getColumns(),
              rows: buildDataRows(data)),
        ),
      ),
    );
  }

  Container _searchBar(double width, double heigth, BuildContext context) {
    return Container(
      width: width * 0.55,
      height: heigth * 0.075,
      color: Colors.grey.withOpacity(0.3),
      child: responsive(
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: _modelTextField(
                    text: "Buscar", controller: searchController),
              ),

              SizedBox(width: 10),

              SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.only(left: 15, right: 5),
                child: Text(
                  "Registros: ${data.length}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Spacer(),
              TextButton(
                  onPressed: () => loadData(), child: Text("Actualizar")),

              //   Expanded(child: numberPaginator()),
            ],
          ),
          Container(),
          context),
    );
  }

  Container _leftWidget(double width, double heigth, BuildContext context) {
    return Container(
      width: width * 0.2,
      height: heigth * 0.8,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          width: width * 0.2,
          height: heigth * 0.2,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Saldo de Cuenta',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '\$${formatNumber(double.parse(saldo))}',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          width: width * 0.2,
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: width * 0.2,
                    padding: EdgeInsets.only(bottom: 10),
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        _showDatePickerModal(context);
                      },
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Ajusta el valor según sea necesario
                          ),
                        ),
                      ),
                      label: Text('Seleccionar'),
                      icon: Icon(Icons.calendar_month_outlined),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    width: width * 0.2,
                    child: FilledButton.tonalIcon(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                5), // Ajusta el valor según sea necesario
                          ),
                        ),
                      ),
                      onPressed: () {
                        _showDatePickerModal(context);
                      },
                      label: Text('Consultar'),
                      icon: Icon(Icons.search),
                    ),
                  ),
                ],
              ),
              Container(
                width: 300,
                child: Column(
                  children: [
                    _buildDateField("Fecha Inicio", _startDateController),
                    SizedBox(height: 16),
                    _buildDateField("Fecha Fin", _endDateController),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        _optionButtons(width),
      ]),
    );
  }

  String formatNumber(double number) {
    var formatter =
        NumberFormat('###,###.##', 'es'); // 'es' para formato en español
    return formatter.format(number);
  }

  Container _optionButtons(double width) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      width: width * 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 300,
            child: FilledButton.tonalIcon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      // Color cuando el botón está presionado
                      return Color.fromARGB(255, 235, 251, 64);
                    }
                    // Color cuando el botón está en su estado normal
                    return Color.fromARGB(255, 209, 184, 146);
                  },
                ),
                // Otros estilos pueden ir aquí
              ),
              //  backgroundColor: Color.fromARGB(255, 196, 134, 207),
              onPressed: () {},
              label: const Text(
                'Consultar',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              icon: const Icon(Icons.check_circle),
            ),
          ),
          Container(
            width: 300,
            child: FilledButton.tonalIcon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      // Color cuando el botón está presionado
                      return Color.fromARGB(255, 235, 251, 64);
                    }
                    // Color cuando el botón está en su estado normal
                    return Color.fromARGB(255, 209, 184, 146);
                  },
                ),
                // Otros estilos pueden ir aquí
              ),
              //  backgroundColor: Color.fromARGB(255, 196, 134, 207),

              onPressed: () {},
              label: const Text(
                'Descargar reporte',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              icon: const Icon(Icons.check_circle),
            ),
          ),
          Container(
            width: 300,
            child: FilledButton.tonalIcon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      // Color cuando el botón está presionado
                      return Color.fromARGB(255, 235, 251, 64);
                    }
                    // Color cuando el botón está en su estado normal
                    return Color.fromARGB(255, 209, 184, 146);
                  },
                ),
                // Otros estilos pueden ir aquí
              ),
              //  backgroundColor: Color.fromARGB(255, 196, 134, 207),
              onPressed: () {},
              label: const Text(
                'Últimos registros',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              icon: const Icon(Icons.check_circle),
            ),
          ),
        ],
      ),
    );
  }

  Future _showDatePickerModal(BuildContext context) {
    return openDialog(
        context,
        400,
        400,
        SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.range,
          onSelectionChanged: _onSelectionChanged,
        ),
        () {});
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 120,
              child: Text(
                label + ":",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "2023-01-31",
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12), // Ajusta la altura aquí
                ),
                validator: (value) {
                  // Puedes agregar validaciones adicionales según tus necesidades
                  if (value == null || value.isEmpty) {
                    return "Este campo no puede estar vacío";
                  }
                  // Aquí podrías validar el formato de la fecha
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      final PickerDateRange dateRange = args.value;

      print('Fecha de inicio: ${dateRange.startDate}');
      print('Fecha de fin: ${dateRange.endDate}');
      _startDateController.text = dateRange.startDate.toString();
      _endDateController.text = dateRange.endDate.toString();

      // start = dateRange.startDate.toString();
      // end = dateRange.endDate.toString();
      // if (dateRange.endDate != null) {
      //   Navigator.of(context).pop();
      //  // filterData();
      // }
    }
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          filterData();
          //  paginatorController.navigateToPage(0);
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      searchController.clear();
                    });

                    Navigator.pop(context);
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  Column SelectFilterNoId(String title, filter,
      TextEditingController controller, List<String> listOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 4.5, top: 4.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Color.fromRGBO(6, 6, 6, 1)),
            ),
            height: 50,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.text,
              onChanged: (String? newValue) {
                setState(() {
                  controller.text = newValue ?? "";
                  arrayFiltersAnd
                      .removeWhere((element) => element.containsKey(filter));

                  if (newValue != 'TODO') {
                    arrayFiltersAnd.add({filter: newValue});
                  } else {}

                  filterData();
                });
              },
              decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
              items: listOptions.map<DropdownMenuItem<String>>((String value) {
                // var nombre = value.split('-')[0];
                // print(nombre);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.split('-')[0],
                      style: const TextStyle(fontSize: 15)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<DataColumn2> getColumns() {
    return [
      // DataColumn2(
      //   label: // Espacio entre iconos
      //       Text('Id'),
      //   size: ColumnSize.S,
      //   onSort: (columnIndex, ascending) {
      //     // sortFunc3("marca_tiempo_envio", changevalue);
      //   },
      // ),
      DataColumn2(
        label: Text('Tipo Transacción.'),
        fixedWidth: 200,
        onSort: (columnIndex, ascending) {
          // sortFunc3("fecha_entrega", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Monto'),
        fixedWidth: 200,
        onSort: (columnIndex, ascending) {
          // sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Valor Anterior'),
        fixedWidth: 200,
        onSort: (columnIndex, ascending) {
          // sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Valor Actual'),
        fixedWidth: 200,
        onSort: (columnIndex, ascending) {
          // sortFunc3("Marca de Tiempo", changevalue);
        },
      ),
      DataColumn2(
        label: Text('Marca de Tiempo'),
        fixedWidth: 200,
        onSort: (columnIndex, ascending) {
          // sortFunc3("Marca de Tiempo", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Text('Id Origen'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Text('Codigo'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 200,
        label:
            SelectFilterNoId('Origen', 'origen', origenController, listOrigen),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("direccion_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 200,
        label: Text('Id Vendedor'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
      DataColumn2(
        fixedWidth: 600,
        label: Text('Comentario'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefono_shipping", changevalue);
        },
      ),
    ];
  }

  setColor(transaccion) {
    final color = transaccion == "credit"
        ? Color.fromARGB(255, 202, 236, 162)
        : Color.fromARGB(255, 236, 176, 175);
    return color;
  }

  List<DataRow> buildDataRows(List data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        color: MaterialStateColor.resolveWith(
            (states) => setColor(data[index]['tipo'])!),
        cells: [
          // DataCell(InkWell(
          //     child: Text(data[index]['id'].toString()),
          //     onTap: () {
          //       // OpenShowDialog(context, index);
          //     })),
          DataCell(InkWell(
              child: Text(data[index]['tipo'].toString()),
              onTap: () {
                // OpenShowDialog(context index);
              })),
          DataCell(InkWell(
              child: Text(
                data[index]['tipo'] == 'debit'
                    ? "\$ - ${data[index]['monto'].toString()}"
                    : "\$ + ${data[index]['monto'].toString()}",
              ),
              onTap: () {
                // OpenShowDialog(context index);
              })),
          DataCell(InkWell(
              child: Text("\$ ${data[index]['valor_anterior']}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text("\$ ${data[index]['valor_actual']}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(
                  "${data[index]['marca_de_tiempo'].toString().split(" ")[0]}   ${data[index]['marca_de_tiempo'].toString().split(" ")[1]}"),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['id_origen'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['codigo'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['origen'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['id_vendedor'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
          DataCell(InkWell(
              child: Text(data[index]['comentario'].toString()),
              onTap: () {
                // OpenShowDialog(context, index);
              })),
        ],
      );
      rows.add(row);
    }

    return rows;
  }
}
