import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/product_model.dart';
import 'package:frontend/models/provider_model.dart';
import 'package:frontend/models/warehouses_model.dart';
import 'package:frontend/ui/logistic/add_provider/controllers/provider_controller.dart';
import 'package:frontend/ui/provider/products/controllers/product_controller.dart';
import 'package:frontend/ui/provider/warehouses/controllers/warehouses_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ApproveProducts extends StatefulWidget {
  final ProviderModel provider;

  const ApproveProducts({super.key, required this.provider});

  @override
  State<ApproveProducts> createState() => _ApproveProductsState();
}

class _ApproveProductsState extends State<ApproveProducts> {
  late ProductController _productController;
  List<ProductModel> products = [];
  late WrehouseController _warehouseController;
  List<WarehouseModel> warehousesList = [];
  List<String> warehousesToSelect = [];
  String? selectedWarehouse;

  int currentPage = 1;
  int pageSize = 70;
  int pageCount = 100;
  bool isLoading = false;
  bool isFirst = false;
  List populate = ["warehouse.provider"];
  List arrayFiltersAnd = [];
  List arrayFiltersOr = [];
  var sortFieldDefaultValue = "product_id:DESC";

  @override
  void initState() {
    super.initState();
    _productController = ProductController();
    _warehouseController = WrehouseController();
    getWarehouses();
  }

  Future<List<WarehouseModel>> _getWarehousesData() async {
    await _warehouseController.loadWarehouses(widget.provider.id.toString());
    return _warehouseController.warehouses;
  }

  getWarehouses() async {
    var responseBodegas = await _getWarehousesData();
    warehousesList = responseBodegas;
    warehousesToSelect.insert(0, 'TODO');
    for (var warehouse in warehousesList) {
      if (warehouse.approved == 1 && warehouse.active == 1) {
        warehousesToSelect.add('${warehouse.id}-${warehouse.branchName}');
      }
    }

    print(warehousesToSelect);
  }

  Future<List<ProductModel>> _getProductModelData() async {
    await _productController.loadProductsByProvider(
        widget.provider.id,
        populate,
        pageSize,
        currentPage,
        arrayFiltersOr,
        arrayFiltersAnd,
        sortFieldDefaultValue.toString(),
        "");
    return _productController.products;
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Productos:",
                  style: customTextStyleTitle,
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

                        setState(() {});
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
            Expanded(
              child: FutureBuilder(
                future: _getProductModelData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar productos'));
                  } else {
                    List<ProductModel> products = snapshot.data ?? [];
                    return DataTable2(
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
                      dataRowColor: MaterialStateColor.resolveWith((states) {
                        return Colors.white;
                      }),
                      headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                      dataTextStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                      columnSpacing: 12,
                      columns: [
                        const DataColumn2(
                          label: Text('Creado'),
                          size: ColumnSize.L,
                        ),
                        DataColumn2(
                          label: const Text('ID'),
                          size: ColumnSize.M,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Bodega'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Nombre'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text('Aprobado'),
                          size: ColumnSize.S,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                        DataColumn2(
                          label: const Text(''), //btn
                          size: ColumnSize.S,
                          onSort: (columnIndex, ascending) {
                            // Lógica para ordenar
                          },
                        ),
                      ],
                      rows: List<DataRow>.generate(
                        products.length,
                        (index) => DataRow(
                          cells: [
                            DataCell(
                              Text(products[index].createdAt.toString()),
                            ),
                            DataCell(
                              Text(products[index].productId.toString()),
                            ),
                            DataCell(
                              Text(products[index]
                                  .warehouse!
                                  .branchName
                                  .toString()),
                            ),
                            DataCell(
                              Text(products[index].productName.toString()),
                            ),
                            DataCell(products[index].approved == 1
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Colors.green)
                                : products[index].approved == 2
                                    ? const Icon(Icons.hourglass_bottom_sharp,
                                        color: Colors.indigo)
                                    : const Icon(Icons.cancel_rounded,
                                        color: Colors.red)),
                            DataCell(
                              ElevatedButton(
                                onPressed: () async {
                                  //
                                  _productController.upate(
                                      int.parse(
                                          products[index].productId.toString()),
                                      {
                                        "approved":
                                            products[index].approved != 1
                                                ? 1
                                                : 0
                                      });
                                  setState(() {});
                                  //
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: products[index].approved != 1
                                      ? Colors.green
                                      : Colors.red[400],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      products[index].approved != 1
                                          ? "Aprobar"
                                          : "Rechazar",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
