import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:number_paginator/number_paginator.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  final TextEditingController _controllers = TextEditingController();
  NumberPaginatorController paginatorController = NumberPaginatorController();
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  bool isLoading = false;

  List<String> warehouse = [];
  var warehouseList = [];
  String? selectedWarehouse;
  List<String> categories = [];
  List<String> types = [];
  String? selectedType;
  String? selectedCat;

  List<String> features = [];
  List selectedCategories = [];

  List data = [];
  int counterChecks = 1;
  int total = 0;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    print("loadData");
    try {
      warehouse = [
        "warehouseA-1",
        "warehouseB-2",
        "warehouseC-3",
        "warehouseD-4",
        "warehouseE-5",
      ];
//Hogar,Mascota,Moda,Tecnología,Cocina,Belleza
      categories = [
        "Hogar",
        "Mascota",
        "Moda",
        "Tecnología",
        "Cocina",
        "Belleza"
      ];
//simple: b/n; variable: colores
      types = ["SIMPLE", "VARIABLE"];

      //
    } catch (e) {
      Navigator.pop(context);
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
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
                      Row(children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                              const SizedBox(
                                width: 5,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: (context),
                                      builder: (context) {
                                        return const AddProduct();
                                      });
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
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Icon(
                                      Icons.add_box,
                                      size: 24,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ]))
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: _modelTextField(
                              text: "Busqueda", controller: _controllers.text),
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
                                          ? "Seleccionados: ${counterChecks}"
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
                            dividerThickness: 1,
                            dataRowColor:
                                MaterialStateColor.resolveWith((states) {
                              if (states.contains(MaterialState.selected)) {
                              } else if (states
                                  .contains(MaterialState.hovered)) {
                                return const Color.fromARGB(255, 234, 241, 251);
                              }
                              return const Color.fromARGB(0, 255, 255, 255);
                            }),
                            headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
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
                                size: ColumnSize.M,
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
                                10,
                                (index) => DataRow(cells: [
                                      DataCell(Checkbox(
                                          //  verificarIndice
                                          value: false,
                                          onChanged: (value) {
                                            setState(() {});
                                          })),
                                      /**
                                        data['archivo'].toString().isEmpty ||
                                        data['archivo'].toString() == "null"
                                        ? Container()
                                        : Container(
                                            width: 300,
                                            height: 400,
                                            child: Image.network(
                                              "$generalServer${data['archivo'].toString()}",
                                              fit: BoxFit.fill,
                                            )),
                                           */
                                      DataCell(
                                        Text('img'),
                                        onTap: () {
                                          // info(context, index);
                                        },
                                      ),
                                      DataCell(
                                        Text('ID'),
                                        onTap: () {
                                          // info(context, index);
                                        },
                                      ),
                                      DataCell(
                                        Text('product'),
                                        onTap: () {
                                          // info(context, index);
                                        },
                                      ),
                                      DataCell(
                                        Text('type'),
                                        onTap: () {
                                          // info(context, index);
                                        },
                                      ),
                                      DataCell(
                                        Text('cantidad: '),
                                        onTap: () {
                                          // info(context, index);
                                        },
                                      ),
                                      DataCell(
                                        Text('precio'),
                                        onTap: () {
                                          // info(context, index);
                                        },
                                      ),
                                      DataCell(
                                        Text('created_At'),
                                        onTap: () {
                                          // info(context, index);
                                        },
                                      ),
                                      DataCell(
                                        Text('Bodega'),
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
                                              print("edit");
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
                                              print("delete");
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
                                    ]))),
                      ),
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
