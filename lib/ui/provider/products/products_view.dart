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
import 'package:frontend/ui/logistic/transport_delivery_historial/show_error_snackbar.dart';
import 'package:frontend/ui/provider/products/add_product.dart';
import 'package:frontend/ui/provider/products/product_details.dart';
import 'package:frontend/ui/widgets/custom_succes_modal.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:intl/intl.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  TextEditingController _search = TextEditingController(text: "");
  NumberPaginatorController paginatorController = NumberPaginatorController();
  int currentPage = 1;
  int pageSize = 3;
  int pageCount = 100;
  bool isLoading = false;
  bool isFirst = false;
  List populate = ["warehouse.provider"];
  List arrayFiltersAnd = [
    // {"warehouse.warehouse_id": 1}
  ];
  List arrayFiltersOr = ["product_id", "product_name", "stock", "price"];
  var sortFieldDefaultValue = "product_id:DESC";

  List data = [];
  int counterChecks = 0;
  int total = 0;

  List warehouseList = [];
  List<String> warehousesToSelect = [];
  String? selectedWarehouse;
  List selectedCheckBox = [];
  String? selectedWarehouseToCopy;

  @override
  void initState() {
    data = [];

    loadData();
    super.initState();
  }

  loadData() async {
    try {
      setState(() {
        warehousesToSelect = [];
        isLoading = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      var responseBodegas = await Connections().getWarehousesProvider(
          int.parse(sharedPrefs!.getString("idProvider").toString()));
      warehouseList = responseBodegas;
      if (warehouseList != null) {
        warehousesToSelect.insert(0, 'TODO');
        warehouseList.forEach((warehouse) {
          setState(() {
            warehousesToSelect.add(
                '${warehouse["branch_name"]}-${warehouse["warehouse_id"]}');
          });
        });
      }

      var response = await Connections().getProductsByProvider(
          sharedPrefs!.getString("idProvider"),
          populate,
          pageSize,
          currentPage,
          arrayFiltersOr,
          arrayFiltersAnd,
          sortFieldDefaultValue.toString(),
          _search.text);
      data = response["data"];
      // print(data);

      for (Map producto in data) {
        var selectedItem = selectedCheckBox
            .where(
                (elemento) => elemento["product_id"] == producto["product_id"])
            .toList();
        if (selectedItem.isNotEmpty) {
          producto['check'] = true;
        } else {
          producto['check'] = false;
        }
      }
      // print("prductos: $data");
      total = response['total'];
      pageCount = response['last_page'];

      paginatorController.navigateToPage(0);
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      print("datos cargados correctamente");
      setState(() {
        isFirst = false;
        isLoading = false;
      });
      //
    } catch (e) {
      SnackBarHelper.showErrorSnackBar(
          context, "Ha ocurrido un error de conexión");
    }
  }

  paginateData() async {
    setState(() {
      isLoading = true;
    });
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });

      var response = await Connections().getProductsByProvider(
          sharedPrefs!.getString("idProvider"),
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
      });
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
      setState(() {
        isFirst = false;
        isLoading = false;
      });
      print("datos paginados");
    } catch (e) {
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
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                              arrayFiltersAnd.clear();
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
                                            item.split('-')[0],
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
                                        "warehouse.warehouse_id":
                                            selectedWarehouse
                                                .toString()
                                                .split("-")[1]
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
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 5),
                                    child: Text(
                                      "Registros: $total",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5),
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
                                                  icon:
                                                      Icon(Icons.close_rounded),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Container(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 5),
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
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue[600],
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        "Copiar",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                            DataColumn2(
                              label: const Text('Aprobado'),
                              size: ColumnSize.S,
                              onSort: (columnIndex, ascending) {
                                // sortFunc3("producto_extra", changevalue);
                              },
                            ),
                            const DataColumn2(
                              label: Text(''), //btns para crud
                              size: ColumnSize.S,
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
                                          "product_id": data[index]
                                                  ['product_id']
                                              .toString()
                                        });
                                      } else {
                                        selectedCheckBox.removeWhere(
                                            (element) =>
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
                                DataCell(
                                  data[index]['approved'] == 1
                                      ? const Icon(Icons.check,
                                          color: Colors.green)
                                      : data[index]['approved'] == 2
                                          ? const Icon(Icons.access_time,
                                              color: Colors.blue)
                                          : const Icon(Icons.close,
                                              color: Colors.red),
                                ),
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

  void resetFilters() {
    // getOldValue(true);

    selectedWarehouse = "TODO";
    arrayFiltersAnd = [];
    _search.text = "";
  }

  String getTypeValue(features) {
    try {
      List<dynamic> dataFeatures = json.decode(features);
      // print("data: $dataFeatures");

      var typeFeature = dataFeatures.firstWhere(
        (feature) => feature.containsKey('type'),
        orElse: () => {'type': 'Tipo no encontrado'}, // Provide a default value
      );

      if (typeFeature['type'] is List<Map<String, dynamic>>) {
        var typeValue = typeFeature['type'] as List<Map<String, dynamic>>;

        var typeObject = typeValue.firstWhere(
          (typeObj) => typeObj.containsKey('type'),
          orElse: () =>
              {'type': 'Tipo no encontrado'}, // Provide a default value
        );

        return typeObject['type'].toString();
      }

      return typeFeature['type'].toString();
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
        // buttonUnselectedForegroundColor: Color.fromARGB(255, 67, 67, 67),
        // buttonSelectedBackgroundColor: Color.fromARGB(255, 67, 67, 67),
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
              items: warehousesToSelect
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item.split('-')[0],
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
                    var foundItem = data.firstWhere(
                        (item) =>
                            item['product_id'].toString() == idProductToSearch,
                        orElse: () => null);

                    if (foundItem != null) {
                      var nameProduct = foundItem['product_name'].toString();
                      var stock = 0;
                      var price = foundItem['price'].toString();

                      var img_url = foundItem['url_img'].toString();
                      if (img_url == "null" || img_url == "") {
                        img_url = "";
                      }
                      // var dataFeatures = foundItem['features'] ?? "";
                      var dataFeatures;
                      if (foundItem['features'] != null) {
                        dataFeatures = json.decode(foundItem['features']);
                      }
                      // print(dataFeatures);
                      //create a copy

                      var response = await Connections().createProduct(
                          nameProduct,
                          stock,
                          dataFeatures,
                          price,
                          img_url,
                          selectedWarehouseToCopy
                              .toString()
                              .split("-")[1]
                              .toString());
                      // 13);
                      // print(response[0]);
                      Navigator.pop(context);

                      //
                    } else {
                      print(
                          'Producto con product_id $idProductToSearch no encontrado.');
                    }
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
