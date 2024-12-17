import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/main.dart';
import 'package:frontend/ui/operator/orders_operator/info_order_operator_new.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:url_launcher/url_launcher.dart';

class OrdersOperatorNew extends StatefulWidget {
  const OrdersOperatorNew({super.key});

  @override
  State<OrdersOperatorNew> createState() => _OrdersOperatorNewState();
}

class _OrdersOperatorNewState extends State<OrdersOperatorNew> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NumberPaginatorController paginatorController = NumberPaginatorController();

  List data = [];

  bool isLoading = false;
  int currentPage = 1;
  int pageSize = 200;
  int pageCount = 100;
  int total = 0;
  String sortFieldDefaultValue = "id:ASC";
  String sortField = "";
  bool changevalue = false;

  TextEditingController _searchController = TextEditingController(text: "");

  List populate = [
    "vendor",
    "users.vendedores",
    "operadore",
    "novedades",
  ];

  List filtersOrCont = [
    'marca_tiempo_envio',
    'name_comercial',
    'numero_orden',
    'ciudad_shipping',
    'nombre_shipping',
    'direccion_shipping',
    'telefono_shipping',
    'cantidad_total',
    'producto_p',
    "producto_extra",
    'precio_total',
    'status',
    'comentario',
  ];

  List arrayFiltersDefaultOr = [
    {
      "status": ["PEDIDO PROGRAMADO", "REAGENDADO"]
    }
  ];

  List arrayfiltersDefaultAnd = [
    {
      'operadore.operadore_id': sharedPrefs!.getString("idOperadore").toString()
    },
    {"estado_interno": "CONFIRMADO"},
    {"estado_logistico": "ENVIADO"},
  ];

  List arrayFiltersAnd = [];

  List arrayFiltersNotEq = [];
  List relationsToInclude = [];
  List relationsToExclude = [];
  String from = '0.0';
  String to = '0.0';

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    currentPage = 1;
    try {
      setState(() {
        isLoading = true;
      });

      var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
        populate,
        filtersOrCont,
        arrayFiltersDefaultOr,
        arrayfiltersDefaultAnd,
        arrayFiltersAnd,
        currentPage,
        pageSize,
        _searchController.text,
        arrayFiltersNotEq,
        sortFieldDefaultValue,
        relationsToInclude,
        relationsToExclude,
      );

      data = responseLaravel['data'];
      from = responseLaravel['from'].toString();
      to = responseLaravel['to'].toString();
      pageCount = responseLaravel['last_page'];
      if (sortFieldDefaultValue.toString() == "id:ASC") {
        total = responseLaravel['total'];
      }
      paginatorController.navigateToPage(0);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  paginateData() async {
    try {
      // setState(() {
      isLoading = true;
      // });

      var responseLaravel = await Connections().getOrdersSellersFilterLaravel(
        populate,
        filtersOrCont,
        arrayFiltersDefaultOr,
        arrayfiltersDefaultAnd,
        arrayFiltersAnd,
        currentPage,
        pageSize,
        _searchController.text,
        arrayFiltersNotEq,
        sortFieldDefaultValue,
        relationsToInclude,
        relationsToExclude,
      );

      data = responseLaravel['data'];

      setState(() {
        from = responseLaravel['from'].toString();
        to = responseLaravel['to'].toString();
        pageCount = responseLaravel['last_page'];
        total = responseLaravel['total'];
      });

      // setState(() {
      isLoading = false;
      // });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomProgressModal(
        content: Scaffold(
          key: _scaffoldKey,
          body: Container(
            height: double.infinity,
            width: double.infinity,
            child: responsive(
              webMainContainer(context),
              mobileMainContainer(context),
              context,
            ),
          ),
        ),
        isLoading: isLoading);
  }

  Stack webMainContainer(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 230,
              color: ColorsSystem().colorInitialContainer,
            )
          ],
        ),
        contentPrintipal(context)
      ],
    );
  }

  Stack mobileMainContainer(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 230,
              color: ColorsSystem().colorInitialContainer,
            )
          ],
        ),
        contentMobilePrincipal(context)
      ],
    );
  }

  Positioned contentPrintipal(BuildContext context) {
    return Positioned(
        top: 20,
        left: 20,
        right: 20,
        height: MediaQuery.of(context).size.height * 0.95,
        child: LayoutBuilder(
          builder: ((context, constraints) {
            return Container(
              height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // fistWidgetRow(),
                  secondWidgetRow(context),
                  containerTable(context),
                  data.isNotEmpty ? paginationComplete() : Container()
                ],
              ),
            );
          }),
        ));
  }

  Positioned contentMobilePrincipal(BuildContext context) {
    return Positioned(
        top: 8,
        left: 15,
        right: 15,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Column(
                          //   children: [
                          //     Row(
                          //       children: [
                          //         Text(
                          //           "Pedidos Operador",
                          //           style: TextStylesSystem().ralewayStyle(
                          //               16,
                          //               FontWeight.w700,
                          //               ColorsSystem().colorStore),
                          //         ),
                          //       ],
                          //     )
                          //   ],
                          // ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Registros: $total",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: ColorsSystem().colorStore,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          searchBarOnlyM(context, 30),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: [
                dropdownPagination(),
              ],
            ),
            /*
            Container(
              height: MediaQuery.of(context).size.height * 0.53,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: buildDataTable(context),
            ),
            */
            Expanded(
              flex: MediaQuery.of(context).size.height <= 640 ? 4 : 5,
              child: data.length > 0
                  ? Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var item = data[index];

                          return InkWell(
                            onTap: () {
                              // Mostrar el diálogo OrderInfo
                              var order = data[index];
                              showInfo(context, index);
                            },
                            child: cardOrder(item, index),
                          );
                        },
                      ),
                    )
                  : const Center(child: Text("Sin datos")),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.height <= 640
                    ? MediaQuery.of(context).size.height * 0.01
                    : MediaQuery.of(context).size.height * 0.03),
            Flexible(
              child: data.isNotEmpty
                  ? Container(
                      height: 30,
                      child: paginationPhoneComplete(),
                    )
                  : Container(),
            ),
          ],
        ));
  }

  Container containerTable(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: buildDataTable(context),
      // child: ExpandableDataTable(data:data),
    );
  }

  DataTable2 buildDataTable(BuildContext context) {
    return DataTable2(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      dataRowColor: MaterialStateColor.resolveWith((states) {
        return Colors.white;
      }),
      headingTextStyle: TextStylesSystem()
          .ralewayStyle(14, FontWeight.bold, ColorsSystem().colorLabels),
      dataTextStyle: const TextStyle(color: Colors.black),
      columnSpacing: 12,
      horizontalMargin: 6,
      minWidth: 2000,
      headingRowHeight: 45,
      showCheckboxColumn: false,
      columns: buildDataColumns(),
      rows: buildDataRows(data),
    );
  }

  List<DataColumn> buildDataColumns() {
    return [
      DataColumn2(
        label: Text('Fecha Envio'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Código'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text(''),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Ciudad'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Nombre'),
        size: ColumnSize.M,
      ),
      DataColumn2(
        label: Text('Dirección'),
        size: ColumnSize.L,
      ),
      DataColumn2(
        label: Text('Teléfono'),
        size: ColumnSize.S,
      ),
      DataColumn2(
        label: Text('Cantidad'),
        size: ColumnSize.S,
        numeric: true,
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
        label: Text('Observación'),
        size: ColumnSize.M,
        numeric: true,
      ),
      DataColumn2(
        label: Text('Comentario'),
        size: ColumnSize.M,
        numeric: true,
      ),
      DataColumn2(
        label: Text('Status'),
        size: ColumnSize.S,
      ),
    ];
  }

  List<DataRow> buildDataRows(List data) {
    data;

    List<DataRow> rows = [];
    for (int index = 0; index < data.length; index++) {
      DataRow row = DataRow(
        cells: [
          DataCell(
            Center(
              child: Text(
                data[index]['marca_tiempo_envio'].toString(),
              ),
            ),
          ),
          DataCell(
            Text(
              "${data[index]['vendor']['nombre_comercial']}-${data[index]['numero_orden']}",
              style: TextStyle(color: GetColor(data[index]['status'])),
            ),
            onTap: () {
              showInfo(context, index);
            },
          ),
          DataCell(
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    var _url = Uri.parse(
                        """https://api.whatsapp.com/send?phone=${data[index]['telefono_shipping'].toString()}&text=Buen día, le saluda el servicio de mensajería. Queremos informarle que tenemos una entrega para usted de ${data[index]['producto_p'].toString()}${data[index]['producto_extra'] != null && data[index]['producto_extra'].toString() != 'null' && data[index]['producto_extra'].toString() != '' ? ' y ${data[index]['producto_extra'].toString()}' : ''}, por un valor de ${data[index]['precio_total'].toString()}. Este pedido fue realizado en la tienda ${data[index]['tienda_temporal'].toString()}. Me confirma su recepción el Día de Hoy.""");
                    if (!await launchUrl(_url)) {
                      throw Exception('Could not launch $_url');
                    }
                  },
                  child: const Icon(
                    Icons.send,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                    onTap: () async {
                      var _url = Uri(
                          scheme: 'tel',
                          path: data[index]['telefono_shipping'].toString());

                      if (!await launchUrl(_url)) {
                        throw Exception('Could not launch $_url');
                      }
                    },
                    child: const Icon(Icons.phone))
              ],
            ),
          ),
          DataCell(
            Text(
              data[index]['ciudad_shipping'].toString(),
            ),
            onTap: () {
              showInfo(context, index);
            },
          ),
          DataCell(
            Text(
              data[index]['nombre_shipping'].toString(),
            ),
            onTap: () {
              showInfo(context, index);
            },
          ),
          DataCell(
            Text(
              data[index]['direccion_shipping'].toString(),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                data[index]['telefono_shipping'].toString(),
              ),
            ),
          ),
          DataCell(
            Center(
              child: Text(
                data[index]['cantidad_total'].toString(),
              ),
            ),
          ),
          DataCell(
            Text(
              data[index]['producto_p'].toString(),
            ),
          ),
          DataCell(
            Text(
              data[index]['producto_extra'] == null ||
                      data[index]['producto_extra'].toString() == "null"
                  ? ""
                  : data[index]['producto_extra'].toString(),
            ),
          ),
          DataCell(
            Text(
              data[index]['precio_total'].toString(),
            ),
          ),
          DataCell(
            Text(
              data[index]['observacion'] == null ||
                      data[index]['observacion'].toString() == "null"
                  ? ""
                  : data[index]['observacion'].toString(),
            ),
          ),
          DataCell(
            Text(
              data[index]['comentario'] == null ||
                      data[index]['comentario'].toString() == "null"
                  ? ""
                  : data[index]['comentario'].toString(),
            ),
          ),
          DataCell(
            Text(
              data[index]['status'].toString(),
            ),
          ),
        ],
      );
      rows.add(row);
    }
    return rows;
  }

  Card cardOrder(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item['vendor']['nombre_comercial']}-${item['numero_orden']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GetColor(item['status']),
                  ),
                ),
                Text(
                  item['marca_tiempo_envio'] ?? 'Fecha no disponible',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${item['nombre_shipping']}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorsSystem().colorStore,
                  ),
                ),
                // Text(
                //   item['marca_t_i'] ?? 'Fecha no disponible',
                //   style: const TextStyle(
                //     fontSize: 12,
                //     color: Colors.grey,
                //   ),
                // ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "${item['ciudad_shipping']}, ${item['direccion_shipping']}",
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorsSystem().colorStore,
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Row(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: const Color.fromARGB(255, 80, 78, 78),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(10.0),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            // print('Phone selected');
                            var _url = Uri(
                                scheme: 'tel',
                                path:
                                    '${data[index]['telefono_shipping'].toString()}');

                            if (!await launchUrl(_url)) {
                              throw Exception('Could not launch $_url');
                            }
                          },
                          child: Icon(
                            Icons.phone,
                            color: ColorsSystem().colorStore,
                            size: 14,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: const Color.fromARGB(255, 80, 78, 78),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(10.0),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            // print('Message selected');
                            var _url = Uri.parse(
                                """https://api.whatsapp.com/send?phone=${data[index]['telefono_shipping'].toString()}&text=Buen día, le saluda el servicio de mensajería. Queremos informarle que tenemos una entrega para usted de ${data[index]['producto_p'].toString()}${data[index]['producto_extra'] != null && data[index]['producto_extra'].toString() != 'null' && data[index]['producto_extra'].toString() != '' ? ' y ${data[index]['producto_extra'].toString()}' : ''}, por un valor de ${data[index]['precio_total'].toString()}. Este pedido fue realizado en la tienda ${data[index]['tienda_temporal'].toString()}. Me confirma su recepción el Día de Hoy.""");
                            if (!await launchUrl(_url)) {
                              throw Exception('Could not launch $_url');
                            }
                          },
                          child: Icon(
                            Icons.message,
                            color: ColorsSystem().colorStore,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color? GetColor(state) {
    int color = 0xFF000000;

    switch (state) {
      case "ENTREGADO":
        color = 0xFF33FF6D;
        break;
      case "NOVEDAD":
        color = 0xFFf2b600;
        // color = 0xFFD6DC27;
        break;
      case "NO ENTREGADO":
        color = 0xFFFF3333;
        break;
      case "REAGENDADO":
        color = 0xFFFA37BF;
        break;
      case "EN RUTA":
        color = 0xFF3341FF;
        break;
      case "EN OFICINA":
        color = 0xFF4B4C4B;
        break;

      default:
        color = 0xFF000000;
    }

    return Color(color);
  }

  Future<dynamic> showInfo(BuildContext context, int index) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.3),
            ),
            content: Container(
              color: Colors.white,
              // width: MediaQuery.of(context).size.width * 0.4,
              width: MediaQuery.of(context).size.width > 600
                  ? MediaQuery.of(context).size.width * 0.3
                  : MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
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
                    child: InfoOrderOperatorNew(
                      order: data[index],
                      function: loadData,
                      data: data,
                    ),
                  )
                ],
              ),
            ),
          );
          // return AlertDialog(
          //   shape: const RoundedRectangleBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(20.0))),
          //   contentPadding: const EdgeInsets.all(5),
          //   backgroundColor: Colors.red,
          //   content: SizedBox(
          //     width: MediaQuery.of(context).size.width > 930
          //         ? MediaQuery.of(context).size.width * 0.3
          //         : MediaQuery.of(context).size.width * 0.9,
          //     height: MediaQuery.of(context).size.height * 0.70,
          //     child: InfoOrderOperator(
          //       // function: loadData,
          //       data: data[index],
          //     ),
          //   ),
          // );
        }).then((value) {
      //
    });
  }

  Row fistWidgetRow() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Pedidos Operador',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: ColorsSystem().colorStore,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  icon: Icon(
                    Icons.replay_outlined,
                    color: ColorsSystem().colorSelected,
                  ),
                  onPressed: () {
                    loadData();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }

  Row secondWidgetRow(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                searchBarOnly(context, 40),
              ],
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("Registros: ",
                style: TextStylesSystem().ralewayStyle(
                    18, FontWeight.w700, ColorsSystem().colorStore)),
            const SizedBox(height: 5),
            Text(
              "$total",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: ColorsSystem().colorStore,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Row paginationComplete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$from - $to de $total resultados',
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
        Center(child: SizedBox(width: 400, child: numberPaginator())),
        dropdownPagination()
      ],
    );
  }

  Row paginationPhoneComplete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.85,
            child: numberPaginatorMobile()),
      ],
    );
  }

  DropdownButton<int> dropdownPagination() {
    return DropdownButton<int>(
      value: pageSize,
      items: const [
        DropdownMenuItem<int>(value: 70, child: Text('70')),
        DropdownMenuItem<int>(value: 100, child: Text('100')),
        DropdownMenuItem<int>(value: 200, child: Text('200')),
        DropdownMenuItem<int>(value: 1000, child: Text('1000')),
      ],
      onChanged: (newValue) {
        setState(() {
          pageSize = newValue!;
          paginateData(); // Llama a la función de paginación con la nueva cantidad
        });
      },
      style: const TextStyle(fontSize: 12, color: Colors.black),
      dropdownColor: Colors.white,
    );
  }

  Container searchBarOnly(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      height: height,
      width: MediaQuery.of(context).size.width * 0.20,
      child: _modelTextField(
        text: "Buscar",
        controller: _searchController,
      ),
    );
  }

  Container searchBarOnlyM(BuildContext context, height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      height: height,
      width: MediaQuery.of(context).size.width * 0.9,
      child: _modelTextFieldMobile(
        text: "Buscar",
        controller: _searchController,
      ),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
        },
        style: TextStylesSystem()
            .ralewayStyle(14, FontWeight.w500, ColorsSystem().colorSection2),
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.clear();
                      loadData();
                    });
                  },
                  child: const Icon(Icons.close))
              : null,
          hintText: text,
          iconColor: ColorsSystem().colorSection2,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  _modelTextFieldMobile({text, controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          loadData();
        },
        style: TextStylesSystem()
            .ralewayStyle(11, FontWeight.w500, ColorsSystem().colorSection2),
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          fillColor: Colors.white,
          prefixIcon: const Icon(
            Icons.search,
            size: 11,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.clear();
                      loadData();
                    });
                  },
                  child: const Icon(
                    Icons.close,
                    size: 11,
                  ))
              : null,
          hintText: text,
          iconColor: ColorsSystem().colorSection2,
          contentPadding: const EdgeInsets.only(bottom: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
          buttonUnselectedForegroundColor: ColorsSystem().colorSection2,
          buttonSelectedBackgroundColor: ColorsSystem().colorStore,
          buttonUnselectedBackgroundColor: Colors.white,
          buttonShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          mainAxisAlignment: MainAxisAlignment.center,
          mode: ContentDisplayMode.numbers),
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

  NumberPaginator numberPaginatorMobile() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
          buttonUnselectedForegroundColor: ColorsSystem().colorSection2,
          buttonSelectedBackgroundColor: ColorsSystem().colorStore,
          buttonUnselectedBackgroundColor: Colors.white,
          buttonShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          mainAxisAlignment: MainAxisAlignment.center,
          mode: ContentDisplayMode.numbers),
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
}
