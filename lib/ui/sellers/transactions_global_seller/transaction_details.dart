import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/loading.dart';

class TransactionDetailsInfoNew extends StatefulWidget {
  final Map data;

  const TransactionDetailsInfoNew({
    super.key,
    required this.data,
  });

  @override
  State<TransactionDetailsInfoNew> createState() =>
      _TransactionDetailsInfoNewState();
}

class _TransactionDetailsInfoNewState extends State<TransactionDetailsInfoNew> {
  TextEditingController _codeController = TextEditingController();
  var data = {};
  bool loading = true;

  @override
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getLoadingModal(context, false);
    });
    // var response = await Connections().getWithDrawalByID();
    // data = response;
    data = widget.data;

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context);
      setState(() {
        loading = false;
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print("VALIDAR e Info");
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return CustomProgressModal(
        isLoading: loading,
        content: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text("Detalle de Transacción",
                  style: TextStylesSystem().ralewayStyle(
                      14, FontWeight.bold, ColorsSystem().colorLabels)),
              iconTheme: IconThemeData(
                color: ColorsSystem().colorLabels,
              ),
            ),
            body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: responsive(
                    webContainer(context), phoneContainer(context), context))));
  }

  Stack webContainer(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: ColorsSystem().colorInitialContainer,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: ColorsSystem().colorSection,
            ),
          ),
        ],
      ),
      Positioned(
        top: 30,
        left: 50,
        right: 50,
        height: MediaQuery.of(context).size.height * 0.35,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          width: MediaQuery.of(context).size.width * 0.41,
          padding: const EdgeInsets.all(20),
          child: const SingleChildScrollView(
            // Hacemos scrolleable solo esta parte
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            ),
          ),
        ),
      ),
    ]);
  }

  Stack phoneContainer(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: ColorsSystem().colorInitialContainer,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: ColorsSystem().colorSection,
              ),
            ),
          ],
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.05,
          left: 8,
          right: 8,
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: constraints.maxHeight,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("DATOS",
                                      style: TextStylesSystem().ralewayStyle(
                                          12,
                                          FontWeight.w600,
                                          ColorsSystem().colorSelected)),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  Row(
                                    children: [
                                      Text("Status: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        "${data.isNotEmpty ? data['status'].toString() : ''}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Código: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        data.isNotEmpty
                                            ? data['code'].toString()
                                            : '',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Origen: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        "${data.isNotEmpty ? data['origin'].toString() : ''}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Fecha Ingreso: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        "${data.isNotEmpty ? data['admission_date'].toString() : ''}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Fecha Entrega: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        "${data.isNotEmpty ? data['delivery_date'].toString() : ''}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text("VALORES",
                                      style: TextStylesSystem().ralewayStyle(
                                          12,
                                          FontWeight.w600,
                                          ColorsSystem().colorSelected)),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  if (data['origin'] == 'Referenciado')
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Costo Referido: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['referer_cost']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Total Transacción: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['total_transaction']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                  if (data['origin'] == 'Retiro de Efectivo')
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Valor Retiro: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['withdrawal_price']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Total Transacción: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['total_transaction']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                  // // Si el origen es 'Pedido' (incluye los distintos estados)
                                  if (data['origin'].contains('Pedido'))
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Valor Pedido: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['value_order']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Costo Devolución: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['return_cost']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Costo Entregado: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['delivery_cost']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Costo No Entregado: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['notdelivery_cost']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Costo Proveedor: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['provider_cost']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Total Transacción: ",
                                              style: TextStylesSystem()
                                                  .ralewayStyle(
                                                      12,
                                                      FontWeight.w600,
                                                      ColorsSystem()
                                                          .colorStore),
                                            ),
                                            Text(
                                              "${data['total_transaction']}",
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                  SizedBox(height: 10),
                                  Text("SALDO",
                                      style: TextStylesSystem().ralewayStyle(
                                          12,
                                          FontWeight.w600,
                                          ColorsSystem().colorSelected)),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  Row(
                                    children: [
                                      Text("Saldo Actual: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        "\$ ${data['current_value'].toString()}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Saldo Previo: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        "\$ ${data['previous_value'].toString()}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
