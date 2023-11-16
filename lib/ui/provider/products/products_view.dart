import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/provider/products/product_details.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:intl/intl.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final TextEditingController _search = TextEditingController();
  NumberPaginatorController paginatorController = NumberPaginatorController();
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  bool isLoading = false;
  List populate = ["warehouse"];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [
    "product_id",
    "product_name",
    "stock",
    //"features",
    "price"
  ];
  var sortFieldDefaultValue = "product_id:DESC";

  List<String> warehouse = [];
  var warehouseList = [];
  String? selectedWarehouse;
  List<String> categories = [];
  List<String> types = [];
  String? selectedType;
  String? selectedCat;

  List selectedCategories = [];

  List data = [];
  int counterChecks = 1;
  int total = 0;

  @override
  void initState() {
    data = [];

    loadData();
    super.initState();
  }

  loadData() async {
    try {
      setState(() {
        data.clear();
      });

      isLoading = true;
      currentPage = 1;

      var response = await Connections().getProducts(
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue,
        _search.text,
      );
      data = response["data"];
      // print("prductos: $data");

      setState(() {
        data = [];
        data = response['data'];

        paginatorController.navigateToPage(0);
      });
      //
    } catch (e) {
      //     Navigator.pop(context);
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  paginateData() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      var response = await Connections().getProducts(
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue,
        _search.text,
      );

      setState(() {
        data = [];
        data = response['data'];
        // _scrollController.jumpTo(0);
      });

      // Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
      // });
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // return const Text("hola mundo");
    return Scaffold(
      body: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(6.0),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return const AddProduct();
                                },
                              );
                              await loadData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Nuevo",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.add_box,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          ElevatedButton.icon(
                            onPressed: () async {
                              // resetFilters();
                              await loadData();
                            },
                            icon: const Icon(
                              Icons.replay_circle_filled_sharp,
                              color: Colors.white,
                            ),
                            label: const Text(
                              // "Recargar Información",
                              "",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: _modelTextField(
                              text: "Busqueda", controller: _search.text),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 5),
                                child: Text(
                                  "Registros: $total",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Row(
                                  children: [
                                    Text(
                                      counterChecks > 0
                                          ? "Seleccionados: $counterChecks"
                                          : "",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    counterChecks > 0
                                        ? Visibility(
                                            visible: true,
                                            child: IconButton(
                                              iconSize: 20,
                                              onPressed: () =>
                                                  {counterChecks = 0},
                                              icon: const Icon(
                                                  Icons.close_rounded),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Expanded(child: numberPaginator()),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Expanded(
                        child: DataTable2(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
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
                          dataRowHeight: 120,
                          dividerThickness: 1,
                          dataRowColor:
                              MaterialStateColor.resolveWith((states) {
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
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          columnSpacing: 12,
                          // headingRowHeight: 80,
                          horizontalMargin: 12,
                          // minWidth: 3500,
                          columns: [
                            const DataColumn2(
                              label: Text(''), //check
                              size: ColumnSize.S,
                            ),
                            DataColumn2(
                              label: const Text(''), //img
                              size: ColumnSize.L,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("marca_t_i", changevalue);
                              },
                            ),
                            DataColumn2(
                              label: const Text('ID'),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("numero_orden", changevalue);
                              },
                            ),
                            DataColumn2(
                              label: const Text('Nombre'),
                              size: ColumnSize.M,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("ciudad_shipping", changevalue);
                              },
                            ),
                            DataColumn2(
                              label: const Text('Tipo'),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("nombre_shipping", changevalue);
                              },
                            ),
                            DataColumn2(
                              label: const Text('Existencia'),
                              size: ColumnSize.M,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("direccion_shipping", changevalue);
                              },
                            ),
                            DataColumn2(
                              label: const Text('Precio'),
                              size: ColumnSize.M,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("telefonoS_shipping", changevalue);
                              },
                            ),
                            DataColumn2(
                              label: const Text('Creado'),
                              size: ColumnSize.M,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("cantidad_total", changevalue);
                              },
                            ),
                            DataColumn2(
                              label: const Text('Bodega'),
                              size: ColumnSize.M,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("producto_p", changevalue);
                              },
                            ),
                            // DataColumn2(
                            //   label: const Text('Aprobado'),
                            //   size: ColumnSize.M,
                            //   onSort: (columnIndex, ascending) {
                            //     // sortFunc3("producto_extra", changevalue);
                            //   },
                            // ),
                            const DataColumn2(
                              label: Text(''), //btns para crud
                              size: ColumnSize.S,
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            // data.length,
                            data.length,
                            (index) => DataRow(
                              cells: [
                                DataCell(Checkbox(
                                    //  verificarIndice
                                    value: false,
                                    onChanged: (value) {
                                      setState(() {});
                                    })),
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: FractionallySizedBox(
                                      widthFactor: 0.6,
                                      heightFactor: 0.9,
                                      child: data[index]['url_img']
                                                  .toString()
                                                  .isEmpty ||
                                              data[index]['url_img']
                                                      .toString() ==
                                                  "null"
                                          ? Container()
                                          : Image.network(
                                              "$generalServer${data[index]['url_img'].toString()}",
                                              fit: BoxFit.fill,
                                            ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(data[index]['product_id'].toString()),
                                  onTap: () {
                                    // info(context, index);
                                  },
                                ),
                                DataCell(
                                  Text(data[index]['product_name']),
                                  onTap: () {
                                    // info(context, index);
                                  },
                                ),
                                DataCell(
                                  Text(getTypeValue(data[index]['features'])),
                                  // Text(data[index]['features']),
                                  onTap: () {
                                    // info(context, index);
                                  },
                                ),
                                DataCell(
                                  Text(data[index]['stock'].toString()),
                                  onTap: () {
                                    // info(context, index);
                                  },
                                ),
                                DataCell(
                                  Text('\$${data[index]['price'].toString()}'),
                                  onTap: () {
                                    // info(context, index);
                                  },
                                ),
                                DataCell(
                                  // Text(data[index]['created_at']
                                  //     .toString()),
                                  Text(formatDate(
                                      data[index]['created_at'].toString())),
                                  onTap: () {
                                    // info(context, index);
                                  },
                                ),
                                DataCell(
                                  Text(data[index]['warehouse']['branch_name']
                                      .toString()),
                                  onTap: () {
                                    // info(context, index);
                                  },
                                ),
                                // DataCell(
                                //   Text('aprobado'),
                                //   onTap: () {
                                //     // info(context, index);
                                //   },
                                // ),
                                DataCell(Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () async {
                                        showDialogInfoData(data[index]);
                                      },
                                      child: const Icon(
                                        Icons.edit_square,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () async {
                                        AwesomeDialog(
                                          width: 500,
                                          context: context,
                                          dialogType: DialogType.info,
                                          animType: AnimType.rightSlide,
                                          title:
                                              '¿Estás seguro de eliminar el Producto?',
                                          desc:
                                              '${data[index]['product_id']}-${data[index]['product_name']}',
                                          btnOkText: "Confirmar",
                                          btnCancelText: "Cancelar",
                                          btnOkColor: Colors.blueAccent,
                                          btnCancelOnPress: () {},
                                          btnOkOnPress: () async {
                                            getLoadingModal(context, false);

                                            await Connections().deleteProduct(
                                                data[index]['product_id']);

                                            Navigator.pop(context);
                                            await loadData();
                                          },
                                        ).show();
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //

                      //
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getTypeValue(features) {
    // Busca la característica con el nombre 'type'
    List<dynamic> dataFeatures = json.decode(features);
    // print("data: $dataFeatures");

    try {
      var typeFeature = dataFeatures.firstWhere(
        (dataFeatures) => dataFeatures['feature_name'] == 'type',
        orElse: () => null,
      );

      // Si se encuentra la característica 'type', devuelve su valor, de lo contrario, devuelve un valor predeterminado o un mensaje de error.
      return typeFeature != null
          ? typeFeature['value'].toString()
          : 'Tipo no encontrado';
    } catch (e) {
      return "";
    }
  }

  Future<dynamic> showDialogInfoData(data) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              // width: MediaQuery.of(context).size.width * 0.4,
              // height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        paginateData();
                      },
                      child: Icon(Icons.close),
                    ),
                  ),
                  Expanded(
                      child: ProductDetails(
                    data: data,
                    function: paginateData,
                    // function: loadData(),
                  ))
                ],
              ),
            ),
          );
        }).then((value) => loadData());
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(),
    );
  }

  formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -5);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
  }

  NumberPaginator numberPaginator() {
    return NumberPaginator(
      config: NumberPaginatorUIConfig(
        buttonShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5), // Customize the button shape
        ),
      ),
      controller: paginatorController,
      numberPages: pageCount > 0 ? pageCount : 1,
      // initialPage: 0,
      onPageChange: (index) async {
        //  print("indice="+index.toString());
        setState(() {
          currentPage = index + 1;
        });
        if (!isLoading) {
          //await paginateData();
        }
      },
    );
  }
}
