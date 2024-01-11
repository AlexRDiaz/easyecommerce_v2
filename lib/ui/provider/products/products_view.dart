import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/reserve_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/products/edit_product.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:frontend/ui/widgets/product/show_img.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  TextEditingController _search = TextEditingController(text: "");
  NumberPaginatorController paginatorController = NumberPaginatorController();
  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  bool isLoading = false;
  bool isFirst = false;
  List populate = ["warehouse.provider", "reserve.seller"];
  List arrayFiltersAnd = [
    // {"warehouse.warehouse_id": 1}
  ];
  List arrayFiltersOr = ["product_id", "product_name", "stock", "price"];
  var sortFieldDefaultValue = "product_id:DESC";

  List data = [];
  int counterChecks = 0;
  int total = 0;

  List warehouseList0 = [];
  String? selectedWarehouse;
  List selectedCheckBox = [];
  String? selectedWarehouseToCopy;
  //new with mvc
  late ProductController _productController;
  List<ProductModel> products = [];
  late WrehouseController _warehouseController;
  List<WarehouseModel> warehousesList = [];
  List<String> warehousesToSelect = [];
  List<String> warehouseToCopy = [];
  bool edited = false;
  bool warehouseActAprob = false;
  String idProv = sharedPrefs!.getString("idProvider").toString();

  @override
  void initState() {
    data = [];
    _productController = ProductController();
    _warehouseController = WrehouseController();

    loadData();
    super.initState();
    //mvc

// Fix the typo here
  }

  Future<List<ProductModel>> _getProductModelData() async {
    await _productController.loadProductsByProvider(
        idProv,
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue.toString(),
        _search.text,
        "");
    return _productController.products;
  }

  Future<List<WarehouseModel>> _getWarehousesData() async {
    await _warehouseController.loadWarehouses(idProv);
    return _warehouseController.warehouses;
  }

  hasEdited(value) {
    setState(() {
      edited = value;
    });
    loadData();
  }

  loadData() async {
    // try {
    setState(() {
      warehousesToSelect = [];
      isLoading = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });

    // print(data2);
    //
    var responseBodegas = await _getWarehousesData();
    warehousesList = responseBodegas;
    warehousesToSelect.insert(0, 'TODO');
    for (var warehouse in warehousesList) {
      warehousesToSelect
          .add('${warehouse.id}-${warehouse.branchName}-${warehouse.city}');

      if (warehouse.approved == 1 && warehouse.active == 1) {
        warehouseActAprob = true;
      }
    }

    products = await _getProductModelData();

    var response = await _productController.loadProductsByProvider(
        sharedPrefs!.getString("idProvider"),
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue.toString(),
        _search.text,
        "");

    data = response['data'];
    // print(data);
    // total = response['total'];
    // pageCount = response['last_page'];

    for (Map producto in data) {
      var selectedItem = selectedCheckBox
          .where((elemento) => elemento["product_id"] == producto["product_id"])
          .toList();
      if (selectedItem.isNotEmpty) {
        producto['check'] = true;
      } else {
        producto['check'] = false;
      }
    }
    // print("prductos: $data");
    // print("data2: $data");

    total = response['total'];
    pageCount = response['last_page'];

    paginatorController.navigateToPage(0);
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
    // print("datos cargados correctamente");
    setState(() {
      isFirst = false;
      isLoading = false;
    });
    //
    // } catch (e) {
    //   SnackBarHelper.showErrorSnackBar(
    //       context, "Ha ocurrido un error de conexión");
    // }
  }

  paginateData() async {
    setState(() {
      isLoading = true;
    });
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      // var response = await Connections().getProductsByProvider(
      //     sharedPrefs!.getString("idProvider"),
      //     populate,
      //     pageSize,
      //     currentPage,
      //     arrayFiltersOr,
      //     arrayFiltersAnd,
      //     sortFieldDefaultValue.toString(),
      //     _search.text);

      // setState(() {
      //   data = response['data'];
      //   pageCount = response['last_page'];
      // });
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {
        isFirst = false;
        isLoading = false;
      });
      // print("datos paginados");
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  @override
  Widget build(BuildContext context) {
    // return const Text("hola mundo");
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.grey[300],
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(6.0),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: warehouseActAprob
                          ? () async {
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return const AddProduct();
                                },
                              );
                              arrayFiltersAnd.clear();
                              await loadData();
                            }
                          : null, // Deshabilitar el botón si warehouseActAprob es false
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF274965),
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
                        resetFilters();
                        await loadData();
                      },
                      icon: const Icon(
                        Icons.replay_circle_filled_sharp,
                        color: Colors.white,
                      ),
                      label: const Text(
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
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          hint: Text(
                            'TODO',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          items: warehousesToSelect
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: selectedWarehouse,
                          onChanged: (value) {
                            setState(() {
                              selectedWarehouse = value;
                            });

                            if (value != 'TODO') {
                              if (value is String) {
                                arrayFiltersAnd = [];
                                arrayFiltersAnd.add({
                                  "warehouse.warehouse_id": selectedWarehouse
                                      .toString()
                                      .split("-")[0]
                                      .toString()
                                });
                              }
                            } else {
                              arrayFiltersAnd = [];
                            }

                            loadData();
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Expanded(
                        child: _modelTextField(
                            text: "Busqueda", controller: _search),
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
                              padding: const EdgeInsets.only(left: 5, right: 5),
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
                                            onPressed: () {
                                              {
                                                setState(() {
                                                  selectedCheckBox = [];
                                                  counterChecks = 0;
                                                });
                                                loadData();
                                              }
                                            },
                                            icon: Icon(Icons.close_rounded),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 5),
                                child: Row(children: [
                                  counterChecks > 0
                                      ? Visibility(
                                          visible: true,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              // print(selectedCheckBox);
                                              await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    showCopyProductToWarehouse(),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[600],
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Copiar",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Icon(
                                                  Icons.copy,
                                                  size: 24,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ])),
                            const SizedBox(width: 30),
                            Expanded(child: numberPaginator()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
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
                    dataRowHeight: 120,
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
                        label: const Text('Stock'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) {
                          // sortFunc3("direccion_shipping", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Precio Bodega'),
                        size: ColumnSize.M,
                        onSort: (columnIndex, ascending) {
                          // sortFunc3("telefonoS_shipping", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Precio Sugerido'),
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
                        size: ColumnSize.L,
                        onSort: (columnIndex, ascending) {
                          // sortFunc3("producto_p", changevalue);
                        },
                      ),
                      DataColumn2(
                        label: const Text('Aprobado'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) {
                          // sortFunc3("producto_extra", changevalue);
                        },
                      ),
                      const DataColumn2(
                        label: Text('Historial Stock'),
                        size: ColumnSize.M,
                      ),
                      const DataColumn2(
                        label: Text(''), //btns para crud
                        size: ColumnSize.L,
                      ),
                    ],
                    rows: List<DataRow>.generate(
                      data.length,
                      (index) => DataRow(
                        cells: [
                          DataCell(
                            Checkbox(
                              value: data[index]['check'] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  data[index]['check'] = value;
                                });
                                if (value!) {
                                  selectedCheckBox.add({
                                    "product_id":
                                        data[index]['product_id'].toString()
                                  });
                                } else {
                                  selectedCheckBox.removeWhere((element) =>
                                      element['product_id'] ==
                                      data[index]['id'].toString());
                                }

                                setState(() {
                                  counterChecks = selectedCheckBox.length;
                                });
                              },
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.center,
                              child: FractionallySizedBox(
                                widthFactor: 0.6,
                                heightFactor: 0.9,
                                child: data[index]['url_img'] != null &&
                                        data[index]['url_img'].isNotEmpty &&
                                        data[index]['url_img'].toString() !=
                                            "[]"
                                    ? Image.network(
                                        "$generalServer${getFirstUrl(data[index]['url_img'])}",
                                        fit: BoxFit.fill,
                                      )
                                    : Container(),
                              ),
                            ),
                            onTap: () {
                              _showProductInfo(data[index]);
                            },
                          ),
                          DataCell(
                            Text(data[index]['product_id'].toString()),
                          ),
                          DataCell(
                            Text(data[index]['product_name']),
                          ),
                          DataCell(Text(data[index]['isvariable'] == 1
                              ? "VARIABLE"
                              : "SIMPLE")),
                          DataCell(
                            Text(data[index]['stock'].toString()),
                          ),
                          DataCell(
                            Text('\$${data[index]['price'].toString()}'),
                          ),
                          DataCell(
                            Text(
                                '\$${getValue(jsonDecode(data[index]['features']), "price_suggested")}'),
                          ),
                          DataCell(Text(//
                              UIUtils.formatDate(
                                  data[index]['created_at'].toString()))),
                          DataCell(
                            Text(data[index]['warehouse']['branch_name']
                                .toString()),
                          ),
                          DataCell(
                            data[index]['approved'] == 1
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Colors.green)
                                : data[index]['approved'] == 2
                                    ? const Icon(Icons.hourglass_bottom_sharp,
                                        color: Colors.indigo)
                                    : const Icon(Icons.cancel_rounded,
                                        color: Colors.red),
                          ),
                          DataCell(
                            const Icon(Icons.list_alt_outlined,
                                color: Colors.orange),
                            onTap: () {
                              _historyProductInfo(data[index]);
                            },
                          ),
                          DataCell(Row(
                            children: [
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () async {
                                  //edit
                                  // showDialogInfoData(data[index]);

                                  await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return EditProduct(
                                        data: data[index],
                                        // function: paginateData,
                                        hasEdited: hasEdited,
                                      );
                                    },
                                  );

                                  // arrayFiltersAnd.clear();
                                  // await loadData();
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

                                      // await Connections().deleteProduct(
                                      //     data[index]['product_id']);

                                      _productController.disableProduct(
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
                    // ProductModel version
                    /*
                          rows: products.map<DataRow>(
                            (product) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Checkbox(
                                      value: false,
                                      onChanged: (value) {},
                                    ),
                                  ),
                                  DataCell(
                                    Text(""),
                                    // Align(
                                    //   alignment: Alignment.center,
                                    //   child: FractionallySizedBox(
                                    //     widthFactor: 0.6,
                                    //     heightFactor: 0.9,
                                    //     child: product.urlImg != null &&
                                    //             product.urlImg.isNotEmpty &&
                                    //             product.urlImg[0] != null &&
                                    //             product.urlImg[0].isNotEmpty
                                    //         ? Image.network(
                                    //             "$generalServer${product.urlImg[0]}",
                                    //             fit: BoxFit.fill,
                                    //           )
                                    //         : Container(),
                                    //   ),
                                    // ),
                                    onTap: () {},
                                  ),
                                  DataCell(
                                    Text(product.productId.toString()),
                                    onTap: () {
                                      _showProductInfo(product);
                                    },
                                  ),
                                  DataCell(
                                    Text(product.productName.toString()),
                                  ),
                                  DataCell(
                                    // Text(getTypeValue(product.features)),
                                    Text(product.isvariable == 1
                                        ? "VARIABLE"
                                        : "SIMPLE"),
                                  ),
                                  DataCell(
                                    Text(product.stock.toString()),
                                  ),
                                  DataCell(
                                    Text('\$${product.price.toString()}'),
                                  ),
                                  DataCell(
                                    Text(formatDate(
                                        product.createdAt.toString())),
                                  ),
                                  DataCell(
                                    Text(product.warehouse!.branchName
                                        .toString()),
                                  ),
                                  DataCell(
                                    product.approved == 1
                                        ? const Icon(Icons.check,
                                            color: Colors.green)
                                        : product.approved == 2
                                            ? const Icon(Icons.access_time,
                                                color: Colors.blue)
                                            : const Icon(Icons.close,
                                                color: Colors.red),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () async {
                                            showDialogInfoData(product);
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
                                                  '${product.productId}-${product.productName}',
                                              btnOkText: "Confirmar",
                                              btnCancelText: "Cancelar",
                                              btnOkColor: Colors.blueAccent,
                                              btnCancelOnPress: () {},
                                              btnOkOnPress: () async {
                                                getLoadingModal(context, false);

                                                // await Connections()
                                                //     .deleteProduct(
                                                //         product.productId);

                                                _productController
                                                    .deleteProduct(
                                                        product.productId!);

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
                                    ),
                                  ),
                                ],
                              );
                            },
                          ).toList(),
                          //
                          */
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetFilters() {
    // getOldValue(true);

    selectedWarehouse = "TODO";
    arrayFiltersAnd = [];
    _search.text = "";
  }

  String getFirstUrl(dynamic urlImgData) {
    List<String> urlsImgsList = (jsonDecode(urlImgData) as List).cast<String>();
    String url = urlsImgsList[0];
    return url;
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
                      child: EditProduct(
                    data: data,
                    hasEdited: hasEdited,
                    // function: loadData(),
                  ))
                ],
              ),
            ),
          );
        }).then((value) => loadData());
  }

  dynamic getValue(Map<String, dynamic> features, String key) {
    try {
      // Obtener el valor asociado con la clave proporcionada
      dynamic value = features[key];

      return value;
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante el proceso de decodificación o acceso a la clave
      print("Error al obtener '$key': $e");
      return null;
    }
  }

  void _showProductInfo(data) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    ProductModel product = ProductModel.fromJson(data);

    List<String> urlsImgsList = product.urlImg != null &&
            product.urlImg.isNotEmpty &&
            product.urlImg.toString() != "[]"
        ? (jsonDecode(product.urlImg) as List).cast<String>()
        : [];

    String selectedImage = urlsImgsList[0];

    // Decodificar el JSON
    Map<String, dynamic> features = jsonDecode(product.features);

    String guideName = "";
    String priceSuggested = "";
    String sku = "";
    String description = "";
    String type = "";
    String variablesSKU = "";
    String variablesText = "";
    String categoriesText = "";
    List<dynamic> categories;

    guideName = features["guide_name"];
    priceSuggested = features["price_suggested"].toString();
    sku = features["sku"];

    String reservesText = "";

    List<ReserveModel>? reservesList = product.reserves;
    if (reservesList != null) {
      for (int i = 0; i < reservesList.length; i++) {
        ReserveModel reserve = reservesList[i];
        UserModel? userSeller = reserve.user;
        reservesText +=
            "SKU: ${reserve.sku} \nVendedor: ${userSeller?.email}\nCantidad: ${reserve.stock}";
        if (i < reservesList.length - 1) {
          reservesText += "\n\n";
        }
      }
    }

    description = features["description"];
    type = features["type"];
    categories = features["categories"];
    List<String> categoriesNames =
        categories.map((item) => item["name"].toString()).toList();
    categoriesText = categoriesNames.join(', ');

    if (product.isvariable == 1) {
      List<Map<String, dynamic>>? variants =
          (features["variants"] as List<dynamic>).cast<Map<String, dynamic>>();

      variablesText = variants!.map((variable) {
        List<String> variableDetails = [];

        // if (variable.containsKey('sku')) {
        //   variableDetails.add("SKU: ${variable['sku']}");
        // }
        if (variable.containsKey('sku')) {
          variablesSKU += "${variable['sku']}\n";
        }
        if (variable.containsKey('color')) {
          variableDetails.add("Color: ${variable['color']}");
        }
        if (variable.containsKey('size')) {
          variableDetails.add("Talla: ${variable['size']}");
        }
        if (variable.containsKey('dimension')) {
          variableDetails.add("Tamaño: ${variable['dimension']}");
        }
        if (variable.containsKey('inventory_quantity')) {
          variableDetails.add("Cantidad: ${variable['inventory_quantity']}");
        }
        // if (variable.containsKey('price')) {
        //   variableDetails.add("Precio: ${variable['price']}");
        // }

        return variableDetails.join('\n');
      }).join('\n\n');
    }

    TextStyle customTextStyleTitle = GoogleFonts.dmSerifDisplay(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    );

    TextStyle customTextStyleText = GoogleFonts.dmSans(
      fontSize: 17,
      color: Colors.black,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // title: AppBar(
          //   title: const Text(
          //     "Detalles del Producto",
          //     style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 16,
          //     ),
          //   ),
          //   backgroundColor: Colors.blue[900],
          //   leading: Container(),
          //   centerTitle: true,
          // ),
          content: Container(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: ShowImages(urlsImgsList: urlsImgsList),
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      Text(
                                        "ID:",
                                        style: customTextStyleTitle,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "${product.productId}",
                                        style: customTextStyleText,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Creado:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${UIUtils.formatDate(product.createdAt)}",
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Aprobado:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          product.approved == 1
                                              ? const Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.green)
                                              : product.approved == 2
                                                  ? const Icon(
                                                      Icons
                                                          .hourglass_bottom_sharp,
                                                      color: Colors.indigo)
                                                  : const Icon(
                                                      Icons.cancel_rounded,
                                                      color: Colors.red)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text("Producto:",
                                              style: customTextStyleTitle),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: product.productName,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Nombre para mostrar en la guia de envio:",
                                            style: customTextStyleTitle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: guideName,
                                    style: customTextStyleText,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Descripción:",
                                            style: customTextStyleTitle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Html(
                                        data: description,
                                        style: {
                                          'p': Style(
                                            fontSize: FontSize(16),
                                            color: Colors.grey[800],
                                            margin: Margins.only(bottom: 0),
                                          ),
                                          'li': Style(
                                            margin: Margins.only(bottom: 0),
                                          ),
                                          'ol': Style(
                                            margin: Margins.only(bottom: 0),
                                          ),
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "SKU:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            sku,
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Visibility(
                              visible: product.isvariable == 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "SKU Variables:",
                                              style: customTextStyleTitle,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          variablesSKU,
                                          style: customTextStyleText,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Precio Bodega:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "\$${product.price}",
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Precio Sugerido:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            priceSuggested.isNotEmpty ||
                                                    priceSuggested != ""
                                                ? '\$$priceSuggested'
                                                : '',
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Tipo:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            type,
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Stock general:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "${product.stock}",
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Visibility(
                              visible: reservesText != "",
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Reservas:",
                                              style: customTextStyleTitle,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: reservesText != "",
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              reservesText,
                                              style: customTextStyleText,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: product.isvariable == 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Variables:",
                                              style: customTextStyleTitle,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          variablesText,
                                          style: customTextStyleText,
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Categorias:",
                                            style: customTextStyleTitle,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            categoriesText,
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Bodega:",
                                            style: customTextStyleTitle,
                                          ),
                                          SizedBox(width: 10),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            product.warehouse!.branchName
                                                .toString(),
                                            style: customTextStyleText,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _historyProductInfo(data) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    TextStyle customTextStyleTitle = GoogleFonts.dmSerifDisplay(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.black,
    );

    TextStyle customTextStyleText = GoogleFonts.dmSans(
      fontSize: 17,
      color: Colors.black,
    );

    ProductModel product = ProductModel.fromJson(data);

    int? productId = product.productId;
    var response = await Connections().historyByProduct(productId);
    List dataHistory = response ?? [];

    if (dataHistory.isNotEmpty) {
      print("successful");
    } else {
      print("error");
    }

    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            width: screenWidth * 0.50,
            height: screenHeight,
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                // width: 100,
                                child: Row(
                                  children: [
                                    Text(
                                      "Producto:",
                                      style: customTextStyleTitle,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "${product.productName}",
                                      style: customTextStyleText,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(
                                // width: 100,
                                child: Row(
                                  children: [
                                    Text(
                                      "Historial de Stock",
                                      style: customTextStyleTitle,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            height: screenHeight * 0.7,
                            child: DataTable2(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                                border: Border.all(color: Colors.blueGrey),
                              ),
                              // dataRowHeight: 120,
                              dataRowColor:
                                  MaterialStateColor.resolveWith((states) {
                                return Colors.white;
                              }),
                              dividerThickness: 1,
                              headingTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              dataTextStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              columnSpacing: 12,
                              horizontalMargin: 12,
                              columns: const [
                                DataColumn2(
                                  label: Text('SKU'), //check
                                  size: ColumnSize.M,
                                ),
                                DataColumn2(
                                  label: Text('Tipo'), //img
                                  size: ColumnSize.S,
                                ),
                                DataColumn2(
                                  label: Text('Fecha'),
                                  size: ColumnSize.S,
                                ),
                                DataColumn2(
                                  label: Text('Unidades'),
                                  size: ColumnSize.S,
                                ),
                                DataColumn2(
                                  label: Text('Stock Actual'),
                                  size: ColumnSize.S,
                                ),
                                DataColumn2(
                                  label: Text('Stock Anterior'),
                                  size: ColumnSize.S,
                                ),
                                DataColumn2(
                                  label: Text('Descripcion'),
                                  size: ColumnSize.L,
                                ),
                              ],
                              rows: List<DataRow>.generate(
                                dataHistory.length,
                                (index) => DataRow(cells: [
                                  DataCell(
                                    Text(dataHistory[index]['variant_sku']
                                        .toString()),
                                  ),
                                  DataCell(
                                    Text(
                                      dataHistory[index]['type'] == 1
                                          ? 'Entrada'
                                          : 'Salida',
                                    ),
                                  ),
                                  DataCell(
                                    Text(formatDate(
                                        dataHistory[index]['date'].toString())),
                                  ),
                                  DataCell(
                                    Text(
                                        dataHistory[index]['units'].toString()),
                                  ),
                                  DataCell(
                                    Text(dataHistory[index]['current_stock']
                                        .toString()),
                                  ),
                                  DataCell(
                                    Text(dataHistory[index]['last_stock']
                                        .toString()),
                                  ),
                                  DataCell(
                                    Text(dataHistory[index]['description']
                                        .toString()),
                                  ),
                                ]),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  formatDate(dateStringFromDatabase) {
    DateTime dateTime = DateTime.parse(dateStringFromDatabase);
    Duration offset = const Duration(hours: -7);
    dateTime = dateTime.toUtc().add(offset);
    String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);
    return formattedDate;
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          // getOldValue(true);
          setState(() {
            _search.text = value;
          });
          loadData();
          getLoadingModal(context, false);

          // paginatorController.navigateToPage(0);
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        },
        decoration: InputDecoration(
          labelText: 'Buscar producto',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    getLoadingModal(context, false);
                    setState(() {
                      _search.clear();
                      arrayFiltersAnd = [];
                    });

                    // resetFilters();
                    setState(() {
                      loadData();
                    });
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close))
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

  showCopyProductToWarehouse() {
    // print(selectedWarehouseToCopy.toString());
    warehouseToCopy = [];
    for (var warehouse in warehousesList) {
      warehouseToCopy
          .add('${warehouse.id}-${warehouse.branchName}-${warehouse.city}');

      if (warehouse.approved == 1 && warehouse.active == 1) {
        warehouseActAprob = true;
      }
    }

    return AlertDialog(
      content: Container(
        width: 400,
        height: MediaQuery.of(context).size.height / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccione la Bodega destinataria',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              hint: Text(
                'Seleccione Bodega',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              items: warehouseToCopy
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item.split('-')[1],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                  .toList(),
              value: selectedWarehouseToCopy,
              onChanged: (value) {
                setState(() {
                  selectedWarehouseToCopy = value as String;
                });
              },
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedWarehouseToCopy == null) {
                  showSuccessModal(context, "Por favor, Seleccione una Bodega.",
                      Icons8.alert);
                } else {
                  getLoadingModal(context, false);

                  // print(selectedCheckBox);
                  for (var i = 0; i < selectedCheckBox.length; i++) {
                    var idProductToSearch =
                        selectedCheckBox[i]['product_id'].toString();

                    var productoEncontrado = await Connections()
                        .getProductByID(int.parse(idProductToSearch), []);

                    if (productoEncontrado != 1 || productoEncontrado != 2) {
                      //
                      ProductModel product =
                          ProductModel.fromJson(productoEncontrado);

                      List<String> urlsImgsList = product.urlImg != null &&
                              product.urlImg.isNotEmpty &&
                              product.urlImg.toString() != "[]"
                          ? (jsonDecode(product.urlImg) as List).cast<String>()
                          : [];

                      Map<String, dynamic> dataFeatures =
                          jsonDecode(product.features);
                      List<dynamic> variantsListOriginal = [];
                      List<dynamic> optionsTypesOriginal = [];

                      if (product.isvariable == 1) {
                        optionsTypesOriginal = dataFeatures["options"];
                        variantsListOriginal = dataFeatures["variants"];
                        variantsListOriginal.forEach((variant) {
                          variant['inventory_quantity'] = "0";
                        });
                      } else {
                        optionsTypesOriginal = [];
                      }

                      var featuresToSend = {
                        "guide_name": dataFeatures["guide_name"],
                        "price_suggested":
                            dataFeatures["price_suggested"].toString(),
                        "sku": dataFeatures["sku"],
                        "categories": dataFeatures["categories"],
                        "description": dataFeatures["description"],
                        "type": product.isvariable == 1 ? "VARIABLE" : "SIMPLE",
                        "variants": variantsListOriginal,
                        "options": optionsTypesOriginal
                      };

                      var response =
                          await _productController.addProduct(ProductModel(
                        productName: product.productName,
                        stock: 0,
                        price: double.parse(product.price.toString()),
                        urlImg: urlsImgsList,
                        isvariable: product.isvariable,
                        features: featuresToSend,
                        warehouseId: int.parse(selectedWarehouseToCopy
                            .toString()
                            .split("-")[0]
                            .toString()),
                      ));

                      if (response == []) {
                        print("Error");
                        // ignore: use_build_context_synchronously
                        AwesomeDialog(
                          width: 500,
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Error',
                          desc: 'Ocurrio un error en la copia del producto.',
                          btnCancel: Container(),
                          btnOkText: "Aceptar",
                          btnOkColor: colors.colorGreen,
                          btnCancelOnPress: () {},
                          btnOkOnPress: () {
                            Navigator.pop(context);
                          },
                        ).show();
                      } else {
                        print("Se ha copiado el producto");
                      }

                      //
                    } else {
                      print(
                          'Producto con product_id $idProductToSearch no encontrado.');
                    }

                    Navigator.pop(context);

                    //

                    counterChecks = 0;
                  }

                  selectedCheckBox = [];
                  counterChecks = 0;
                  Navigator.pop(context);
                  loadData();
                }
              },
              child: const Text(
                "ACEPTAR",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
