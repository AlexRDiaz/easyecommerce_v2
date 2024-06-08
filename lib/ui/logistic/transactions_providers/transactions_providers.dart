import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/commons.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/provider_transactions_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/provider/transactions/controllers/transactions_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class TransactionsProviders extends StatefulWidget {
  const TransactionsProviders({super.key});

  @override
  State<TransactionsProviders> createState() => _TransactionsProvidersState();
}

class _TransactionsProvidersState extends State<TransactionsProviders> {
  TextEditingController _search = TextEditingController(text: "");
  NumberPaginatorController paginatorController = NumberPaginatorController();

  int currentPage = 1;
  int pageSize = 100;
  int pageCount = 0;
  bool isLoading = false;
  bool isFirst = false;
  String saldo = '0';

  List populate = ["pedido", "orden_retiro", "provider"];

  List arrayFiltersAnd = [
    // {
    //   'equals/provider_id': sharedPrefs!.getString("idProvider"),
    // }
  ];
  List arrayFiltersOr = [
    "transaction_type",
    "origin_code",
    "comment",
    "description",
    "sku_product_reference"
  ];
  var sortFieldDefaultValue = "id:DESC";

  List<String> listOrigen = [
    'TODO',
    'PAGO PRODUCTO',
    'RETIRO',
    'RESTAURACION',
  ];

  List<String> listTipo = [
    'TODO',
    'CREDIT',
    'DEBIT',
  ];

  String? selectedValueOrigen;
  String? selectedValueTipo;

  List data = [];
  int total = 0;

  late TransactionsController _transactionsController;
  List<ProviderTransactionsModel> transactions = [];

  late ProviderController _providerController;
  List<ProviderModel> providersList = [];
  List<String> providersToSelect = ['TODO'];

  String? selectedProvider;

  final _startDateController = TextEditingController(text: "2023-01-01");
  final _endDateController = TextEditingController(
      text:
          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}");

  String retiro = '0';
  List<String> providersInacToSelect = ['TODO'];
  bool changevalue = false;

  @override
  void initState() {
    data = [];
    _providerController = ProviderController();
    _transactionsController = TransactionsController();
    getProviders();
    loadData();
    super.initState();
  }

  getOldValue(Arrayrestoration) {
    if (Arrayrestoration) {
      setState(() {
        sortFieldDefaultValue = "id:DESC";
      });
    }
  }

  loadData() async {
    //
    setState(() {
      isLoading = true;
    });

    var response = await _transactionsController.loadTransactionsByProvider(
        _startDateController.text,
        _endDateController.text,
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue.toString(),
        _search.text);

    setState(() {
      data = response['data'];
      total = response['total'];
      pageCount = response['last_page'];
      paginatorController.navigateToPage(0);

      isLoading = false;
    });
  }

  paginateData() async {
    //
    setState(() {
      isLoading = true;
    });

    var response = await _transactionsController.loadTransactionsByProvider(
        _startDateController.text,
        _endDateController.text,
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue.toString(),
        _search.text);

    setState(() {
      data = response['data'];
      pageCount = response['last_page'];
      total = response['total'];
    });

    setState(() {
      isFirst = false;
      isLoading = false;
    });
  }

  getProviders() async {
    await _providerController.loadProvidersAll();
    providersList = _providerController.providers;
    for (var provider in providersList) {
      if (provider.active == 1) {
        providersToSelect
            .add('${provider.id}|${provider.name}|${provider.userId}');
      }
    }
    setState(() {});
  }

  getProvidersInactive() async {
    // var response = await _providerController.loadProvidersAll();
    // providersList = _providerController.providers;
    // for (var provider in providersList) {
    //   if (provider.active == 0) {
    //     providersInacToSelect
    //         .add('${provider.id}|${provider.name}|${provider.userId}');
    //   }
    // }
    // setState(() {});
  }

  getSaldo() async {
    var response = await Connections()
        .getSaldoProvider(selectedProvider?.split('|')[2].toString());
    setState(() {
      saldo = response;
    });
  }

  getTotalRetiros() async {
    var response = await Connections()
        .getTotalRetiros(selectedProvider?.split('|')[0].toString());
    setState(() {
      retiro = response.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return CustomProgressModal(
      isLoading: isLoading,
      content: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            // margin: const EdgeInsets.all(6.0),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                responsive(
                    webMainContainer(screenWidth, screenHeight, context),
                    mobileMainContainer(screenWidth, screenHeight, context),
                    context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row webMainContainer(double width, double heigth, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _leftWidgetWeb(width, heigth, context),
        Expanded(
          child: Column(
            children: [
              _searchBar(width, heigth, context),
              SizedBox(height: 10),
              _dataTableTransactions(heigth),
            ],
          ),
        ),
      ],
    );
  }

  Container _dataTableTransactions(height) {
    return Container(
      height: height * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: data.length > 0
          ? DataTable2(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                border: Border.all(color: Colors.blueGrey),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // dataRowHeight: 120,
              dividerThickness: 1,
              dataRowColor: MaterialStateColor.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                } else if (states.contains(MaterialState.hovered)) {
                  return const Color.fromARGB(255, 234, 241, 251);
                }
                return const Color.fromARGB(0, 255, 255, 255);
              }),
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
              dataTextStyle: const TextStyle(
                  fontSize: 12,
                  // fontWeight: FontWeight.bold,
                  color: Colors.black),
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 1200,
              columns: getColumns(),
              rows: buildDataRows(data))
          : const Center(
              child: Text("Sin datos"),
            ),
    );
  }

  List<DataColumn2> getColumns() {
    return [
      //
      DataColumn2(
        label: Text('Id Origen'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          sortFunc2("origin_id", changevalue);
        },
      ),
      const DataColumn2(
        label: Text('Fecha Envio'),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: const Text('Fecha Entrega'), //img
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          // sortFunc3("marca_t_i", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Tipo'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("numero_orden", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Codigo'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          sortFunc2("origin_id", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Proveedor'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          // sortFunc3("ciudad_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Cantidad'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("nombre_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Producto'),
        size: ColumnSize.L,
        onSort: (columnIndex, ascending) {
          // sortFunc3("direccion_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Valor'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefonoS_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Descripcion'),
        size: ColumnSize.M,
        onSort: (columnIndex, ascending) {
          // sortFunc3("telefonoS_shipping", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('V. Anterior'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("cantidad_total", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('V. Actual'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("producto_p", changevalue);
        },
      ),
      DataColumn2(
        label: const Text('Estado'),
        size: ColumnSize.S,
        onSort: (columnIndex, ascending) {
          // sortFunc3("producto_extra", changevalue);
        },
      ),
    ];
  }

  List<DataRow> buildDataRows(List data) {
    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          //
          DataCell(
            Text(data[index]['origin_id'] == null
                ? ""
                : data[index]['origin_id'].toString()),
          ),
          DataCell(
            data[index]['orden_retiro'] != null
                ? Text(UIUtils.formatDate(data[index]['orden_retiro']
                        ['createdAt']
                    .toString())) // Si orden_retiro no es null
                : Text(data[index]['pedido'] == null
                    ? ""
                    : data[index]['pedido']['marca_tiempo_envio']
                        .toString()), // Si orden_retiro es null
          ),
          DataCell(
            data[index]['orden_retiro'] != null
                ? Text(data[index]['orden_retiro']['fechaTransferencia']
                    .toString()) // Si orden_retiro no es null
                : Text(data[index]['pedido'] == null
                    ? ""
                    : data[index]['pedido']['fecha_entrega']
                        .toString()), // Si orden_retiro es null
          ),
          DataCell(
            Text(data[index]['transaction_type'].toString()),
            // Text("Tipo"),
          ),
          DataCell(
            Text(
              "${data[index]['origin_code']}",
              style: TextStyle(
                  color: getColor(
                      int.parse(data[index]['origin_id'].toString()))!),
            ), // Si orden_retiro es null
          ),
          DataCell(
            Text("${data[index]['provider']['name']}"),
          ),
          DataCell(Text(
              "${data[index]['origin_code'].toString().split('-')[0] == "Retiro" || data[index]['origin_code'].toString().split('-')[0] == "reembolso" ? 0 : data[index]['pedido']['cantidad_total'].toString()} ")),
          DataCell(
            Text(data[index]['comment'].toString()),
          ),
          DataCell(data[index]['transaction_type'].toString() == "Retiro" ||
                  data[index]['transaction_type'].toString() == "Restauracion"
              ? Row(
                  children: [
                    Icon(Icons.remove, color: Colors.red, size: 12),
                    Text(data[index]['amount'].toString()),
                  ],
                )
              : Row(
                  children: [
                    Icon(Icons.add, color: Colors.green, size: 12),
                    Text(data[index]['amount'].toString()),
                  ],
                )),
          DataCell(
            Text(data[index]['description'] == null
                ? ""
                : data[index]['description'].toString()),
            // Text(""),
          ),
          DataCell(
            Text(data[index]['previous_value'].toString()),
          ),
          DataCell(
            Text(data[index]['current_value'].toString()),
          ),
          DataCell(
            Text(data[index]['status'] == null
                ? ""
                : data[index]['status'].toString()),
          ),
        ],
      );
      rows.add(row);
    }
    return rows;
  }

  Color? getColor(int originId) {
    bool multiple = false;
    int color = 0xFF000000;

    String? targetOriginCode;
    for (var item in data) {
      if (item['origin_id'] == originId) {
        targetOriginCode = item['origin_code'];
        break;
      }
    }

    if (targetOriginCode == null) {
      return Color(color);
    }

    int count = 0;
    for (var item in data) {
      if (item['origin_code'] == targetOriginCode) {
        count++;
        if (count > 1) {
          multiple = true;
          break;
        }
      }
    }

    if (multiple) {
      color = 0xFFF32121;
    }

    return Color(color);
  }

  sortFunc2(filtro, changevalu) {
    setState(() {
      if (changevalu) {
        sortFieldDefaultValue = "$filtro:DESC";
        changevalue = false;
      } else {
        sortFieldDefaultValue = "$filtro:ASC";
        changevalue = true;
      }
      loadData();
    });
  }

  Container _leftWidgetWeb(double width, double heigth, BuildContext context) {
    return Container(
      width: width * 0.20,
      padding: EdgeInsets.only(left: 10, right: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
          width: width * 0.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${formatNumber(double.parse(saldo))}',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Text(
                  'Saldo de Cuenta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
          width: width * 0.2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${formatNumber(double.parse(retiro))}',
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10, right: 20),
                child: Text(
                  'Total de Retiros',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        _dateButtons(width, context),
        const SizedBox(height: 20),
        _optionButtons(width, heigth),
      ]),
    );
  }

  mobileMainContainer(double width, double heigth, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _leftWidgetMobile(width, heigth, context),
          Divider(),
          _searchBar(width, heigth, context),
          _dataTableTransactionsMobile(heigth),
        ],
      ),
    );
  }

  _dataTableTransactionsMobile(height) {
    return data.length > 0
        ? Container(
            height: height * 0.52,
            child: DataTable2(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Colors.blueGrey),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // dataRowHeight: 120,
                dividerThickness: 1,
                dataRowColor: MaterialStateColor.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                  } else if (states.contains(MaterialState.hovered)) {
                    return const Color.fromARGB(255, 234, 241, 251);
                  }
                  return const Color.fromARGB(0, 255, 255, 255);
                }),
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
                dataTextStyle: const TextStyle(
                    fontSize: 12,
                    // fontWeight: FontWeight.bold,
                    color: Colors.black),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 1200,
                columns: getColumns(),
                rows: buildDataRows(data)))
        : Center(
            child: Text("Sin datos"),
          );
  }

  Container _leftWidgetMobile(
      double width, double height, BuildContext context) {
    return Container(
      height: height * 0.25,
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _saldoDeCuentaMobile(width),
              Container(
                width: 1,
                height: height * 0.08,
                color: Colors.grey,
              ),
              _dateButtonsMobile(width, context),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [_optionButtonsMobile(width, height)],
          ),
        ],
      ),
    );
  }

  Container _saldoDeCuentaMobile(double width) {
    return Container(
      width: width * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${formatNumber(double.parse(saldo))}',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
          const Text(
            'Saldo de Cuenta',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${formatNumber(double.parse(retiro))}',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 20),
            child: Text(
              'Total de Retiros',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Container _dateButtonsMobile(double width, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: width * 0.60,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: FilledButton.tonal(
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
                  child: Icon(Icons.calendar_month_outlined),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: FilledButton.tonal(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            5), // Ajusta el valor según sea necesario
                      ),
                    ),
                  ),
                  onPressed: () {
                    loadData();
                  },
                  child: Icon(Icons.search),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateFieldMobile("Desde", _startDateController),
              const SizedBox(width: 5),
              _buildDateFieldMobile("Hasta", _endDateController),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFieldMobile(String label, TextEditingController controller) {
    return Container(
      width: 100,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          label: Text(label),
          isDense: true,
          border: OutlineInputBorder(),
          hintText: "2023-01-31",
          contentPadding: EdgeInsets.symmetric(vertical: 9, horizontal: 10),
        ),
        style: TextStyle(
          fontSize: 11,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Este campo no puede estar vacío";
          }
          return null;
        },
      ),
    );
  }

  Container _optionButtonsMobile(double width, double height) {
    return Container(
      // padding: EdgeInsets.all(10),
      // width: width * 0.3,
      // height: height * 0.28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: width * 0.4,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Seleccione Proveedor',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: providersToSelect
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item == 'TODO'
                                ? 'TODO'
                                : item.split("|")[1].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ))
                    .toList(),
                value: selectedProvider,
                onChanged: (String? value) {
                  setState(() {
                    selectedProvider = value;
                  });

                  arrayFiltersAnd.removeWhere(
                      (element) => element.containsKey("equals/provider_id"));
                  if (value != '') {
                    if (value == "TODO") {
                      saldo = "0";
                      retiro = "0";
                      arrayFiltersAnd.removeWhere((element) =>
                          element.containsKey("equals/provider_id"));
                    } else {
                      arrayFiltersAnd
                          .add({"equals/provider_id": value!.split('|')[0]});

                      getSaldo();
                      getTotalRetiros();
                    }
                  }

                  loadData();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 300,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 160,
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  // customHeights: _getCustomItemsHeights(providersToSelect),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: width * 0.4,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Origen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: _addDividersAfterItems(listOrigen),
                value: selectedValueOrigen,
                onChanged: (String? value) {
                  setState(() {
                    selectedValueOrigen = value;
                  });

                  arrayFiltersAnd.removeWhere((element) =>
                      element.containsKey("equals/transaction_type"));
                  if (value != '') {
                    if (value == 'TODO') {
                      arrayFiltersAnd.removeWhere((element) =>
                          element.containsKey("equals/transaction_type"));
                    } else {
                      arrayFiltersAnd.add({"equals/transaction_type": value});
                    }
                  }

                  loadData();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 140,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  customHeights: _getCustomItemsHeights(listOrigen),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatNumber(double number) {
    var formatter =
        NumberFormat('###,###.##', 'es'); // 'es' para formato en español
    return formatter.format(number);
  }

  _searchBar(double width, double heigth, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: responsive(
          Row(
            children: [
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                width: MediaQuery.of(context).size.width * 0.25,
                child: _modelTextField(text: "Buscar", controller: _search),
              ),
              const SizedBox(width: 10),
              Text(
                "Registros: $total",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    resetFilters();
                    paginatorController.navigateToPage(0);
                  });
                },
                child: const Row(
                  children: [
                    Icon(Icons.delete_forever_sharp),
                    SizedBox(width: 5),
                    Text('Limpiar Filtros'),
                  ],
                ),
              ),
              Spacer(),
              Container(width: width * 0.25, child: numberPaginator()),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(15)),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: _modelTextField(text: "Buscar", controller: _search),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.only(left: 15, right: 5),
                        width: width * 0.4,
                        child: Text(
                          "Registros: $total",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        resetFilters();
                        paginatorController.navigateToPage(0);
                      });
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.delete_forever_sharp),
                        SizedBox(width: 5),
                        Text('Limpiar Filtros'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                          width: width * 0.6, child: numberPaginator()),
                    ),
                  ),
                ],
              ),
            ],
          ),
          context),
    );
  }

  void resetFilters() {
    getOldValue(true);

    selectedValueOrigen = 'TODO';
    selectedProvider = 'TODO';
    _startDateController.text = "2023-01-01";
    _endDateController.text =
        "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
    arrayFiltersAnd = [];
    saldo = "0";
    retiro = "0";
    _search.text = "";
  }

  Container _dateButtons(double width, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3),
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
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
                    loadData();
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
                SizedBox(height: 10),
                _buildDateField("Fecha Fin", _endDateController),
                SizedBox(height: 10),
              ],
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
              width: 50,
              child: Text(
                label + ":",
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: "2023-01-31",
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12), // Ajusta la altura aquí
                ),
                style: TextStyle(
                  fontSize:
                      12, // Ajusta el tamaño del texto según tus necesidades
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
      _startDateController.text =
          "${dateRange.startDate!.year}-${dateRange.startDate!.month}-${dateRange.startDate!.day}";
      _endDateController.text =
          "${dateRange.endDate!.year}-${dateRange.endDate!.month}-${dateRange.endDate!.day}";

      // start = dateRange.startDate.toString();
      // end = dateRange.endDate.toString();
      // if (dateRange.endDate != null) {
      //   Navigator.of(context).pop();
      //  // filterData();
      // }
    }
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonSelectedBackgroundColor: const Color(0xFF253e55),
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      onPageChange: (index) async {
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          await paginateData();
        }
      },
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
          paginatorController.navigateToPage(0);
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          fillColor: Colors.grey[500],
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _search.clear();
                      loadData();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15)),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }

  Container _optionButtons(double width, double height) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 7,
          offset: Offset(0, 3),
        ),
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      width: width * 0.3,
      height: height * 0.28,
      child: Column(
        children: [
          Container(
            width: 400,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Seleccione Proveedor',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: providersToSelect
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: Text(
                            item == 'TODO'
                                ? 'TODO'
                                : item.split("|")[1].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ))
                    .toList(),
                value: selectedProvider,
                onChanged: (String? value) {
                  setState(() {
                    selectedProvider = value;
                  });

                  arrayFiltersAnd.removeWhere(
                      (element) => element.containsKey("equals/provider_id"));
                  if (value != '') {
                    if (value == "TODO") {
                      saldo = "0";
                      retiro = "0";
                      arrayFiltersAnd.removeWhere((element) =>
                          element.containsKey("equals/provider_id"));
                    } else {
                      arrayFiltersAnd
                          .add({"equals/provider_id": value!.split('|')[0]});

                      getSaldo();
                      getTotalRetiros();
                    }
                  }

                  loadData();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 300,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 160,
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  // customHeights: _getCustomItemsHeights(providersToSelect),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 300,
            color: Color(0xFFE8DEF8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Origen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: _addDividersAfterItems(listOrigen),
                value: selectedValueOrigen,
                onChanged: (String? value) {
                  setState(() {
                    selectedValueOrigen = value;
                  });

                  arrayFiltersAnd.removeWhere((element) =>
                      element.containsKey("equals/transaction_type"));
                  if (value != '') {
                    if (value == 'TODO') {
                      arrayFiltersAnd.removeWhere((element) =>
                          element.containsKey("equals/transaction_type"));
                    } else {
                      arrayFiltersAnd.add({"equals/transaction_type": value});
                    }
                  }

                  loadData();
                },
                buttonStyleData: const ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 140,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                ),
                menuItemStyleData: MenuItemStyleData(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  customHeights: _getCustomItemsHeights(listOrigen),
                ),
                iconStyleData: const IconStyleData(
                  openMenuIcon: Icon(Icons.arrow_drop_up),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _addDividersAfterItems(List<String> items) {
    final List<DropdownMenuItem<String>> menuItems = [];
    for (final String item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          //If it's last item, we will not add Divider after it.
          if (item != items.last)
            const DropdownMenuItem<String>(
              enabled: false,
              child: Divider(),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights(array) {
    final List<double> itemsHeights = [];
    for (int i = 0; i < (array.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(40);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        itemsHeights.add(4);
      }
    }
    return itemsHeights;
  }
}
