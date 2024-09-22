import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
import 'package:frontend/ui/widgets/blurry_modal_progress_indicator.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/loading.dart';

import '../../../helpers/navigators.dart';
import 'controllers/controllers.dart';

class SellerWithdrawalInfoNew extends StatefulWidget {
  final Map data;

  const SellerWithdrawalInfoNew({
    super.key,
    required this.data,
  });

  @override
  State<SellerWithdrawalInfoNew> createState() =>
      _SellerWithdrawalInfoNewState();
}

class _SellerWithdrawalInfoNewState extends State<SellerWithdrawalInfoNew> {
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
              title: Text("Retiros Vendedores",
                  style: TextStylesSystem().ralewayStyle(
                      20, FontWeight.bold, ColorsSystem().colorLabels)),
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
          child: SingleChildScrollView(
            // Hacemos scrolleable solo esta parte
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Fecha: ",
                        style: TextStylesSystem().ralewayStyle(
                            16, FontWeight.w600, ColorsSystem().colorStore)),
                    Text(
                      "${data.isNotEmpty ? data['fecha'].toString() : ''}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Monto: ",
                        style: TextStylesSystem().ralewayStyle(
                            16, FontWeight.w600, ColorsSystem().colorStore)),
                    Text(
                      "${data.isNotEmpty ? data['monto'].toString() : ''}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Estado: ",
                        style: TextStylesSystem().ralewayStyle(
                            16, FontWeight.w600, ColorsSystem().colorStore)),
                    Text(
                      "${data.isNotEmpty ? data['estado'].toString() : ''}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text("Transferencia: ",
                        style: TextStylesSystem().ralewayStyle(
                            16, FontWeight.w600, ColorsSystem().colorStore)),
                    Text(
                      "${data.isEmpty || data['fecha_transferencia'].toString() == "null" ? "" : data['fecha_transferencia'].toString()}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (data.isNotEmpty &&
                    data['estado'].toString() == "PENDIENTE") ...[
                  SizedBox(
                    width: 350,
                    child: TextField(
                      controller: _codeController,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "INGRESA EL CÓDIGO DE VERIFICACIÓN",
                        hintStyle: TextStylesSystem().ralewayStyle(
                            16, FontWeight.w500, ColorsSystem().colorLabels),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsSystem().colorSelected,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text("VALIDAR",
                          style: TextStylesSystem()
                              .ralewayStyle(18, FontWeight.bold, Colors.white)),
                      onPressed: () async {
                        // Lógica de validación
                        if (_codeController.text == data['codigo_generado']) {
                          getLoadingModal(context, false);
                          // var response = await Connections()
                          //     .withdrawalPut(
                          //         data['id'], _codeController.text);
                          var response = await Connections()
                              .sendAproveWithdrawal(data['id']);

                          if (response == 0) {
                            Navigator.pop(context);

                            AwesomeDialog(
                              width: 500,
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.rightSlide,
                              title: 'Completado',
                              desc: '',
                              btnCancel: Container(),
                              btnOkText: "Aceptar",
                              btnOkColor: colors.colorGreen,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () async {
                                Navigator.pop(context);

                                Navigators().pushNamedAndRemoveUntil(
                                    context, "/layout/sellers");
                              },
                            ).show();
                          }
                        } else {
                          Navigator.pop(context);

                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title: 'Error',
                            desc: 'Código Incorrecto',
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: colors.colorGreen,
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                        }
                      },
                    ),
                  ),
                ],
                SizedBox(height: 20),
                if (data.isNotEmpty && data['comprobante'].toString() != "null")
                  SizedBox(
                    width: MediaQuery.of(context).size.width > 600
                        ? MediaQuery.of(context).size.width * 0.60
                        : MediaQuery.of(context).size.width * 0.90,
                    child: Image.network(
                      "$generalServer${data['comprobante'].toString()}",
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
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
          height: MediaQuery.of(context).size.height * 0.3,
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
                                  Row(
                                    children: [
                                      Text("Fecha: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        "${data.isNotEmpty ? data['fecha'].toString() : ''}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text("Monto: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        "${data.isNotEmpty ? data['monto'].toString() : ''}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text("Estado: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                      Text(
                                        "${data.isNotEmpty ? data['estado'].toString() : ''}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text("Transferencia: ",
                                          style: TextStylesSystem()
                                              .ralewayStyle(12, FontWeight.w600,
                                                  ColorsSystem().colorStore)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        " ${data.isEmpty || data['fecha_transferencia'].toString() == "null" ? "" : data['fecha_transferencia'].toString()}",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  data.isNotEmpty &&
                                          data['estado'].toString() ==
                                              "PENDIENTE"
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              child: TextField(
                                                controller: _codeController,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                decoration: InputDecoration(
                                                    hintText:
                                                        "INGRESA EL CÓDIGO DE VERIFICACIÓN",
                                                    hintStyle: TextStylesSystem()
                                                        .ralewayStyle(
                                                            12,
                                                            FontWeight.w500,
                                                            ColorsSystem()
                                                                .colorLabels)),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            SizedBox(
                                              width: 80,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      ColorsSystem()
                                                          .colorSelected,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                                ),
                                                child: Text("VALIDAR",
                                                    style: TextStylesSystem()
                                                        .ralewayStyle(
                                                            12,
                                                            FontWeight.bold,
                                                            Colors.white)),
                                                onPressed: () async {
                                                  // Lógica para validar el código
                                                  if (_codeController.text ==
                                                      data['codigo_generado']) {
                                                    getLoadingModal(
                                                        context, false);
                                                    // var response = await Connections()
                                                    //     .withdrawalPut(
                                                    //         data['id'], _codeController.text);
                                                    var response =
                                                        await Connections()
                                                            .sendAproveWithdrawal(
                                                                data['id']);

                                                    if (response == 0) {
                                                      Navigator.pop(context);

                                                      AwesomeDialog(
                                                        width: 500,
                                                        context: context,
                                                        dialogType:
                                                            DialogType.success,
                                                        animType:
                                                            AnimType.rightSlide,
                                                        title: 'Completado',
                                                        desc: '',
                                                        btnCancel: Container(),
                                                        btnOkText: "Aceptar",
                                                        btnOkColor:
                                                            colors.colorGreen,
                                                        btnCancelOnPress: () {},
                                                        btnOkOnPress: () async {
                                                          Navigator.pop(
                                                              context);

                                                          Navigators()
                                                              .pushNamedAndRemoveUntil(
                                                                  context,
                                                                  "/layout/sellers");
                                                        },
                                                      ).show();
                                                    }
                                                  } else {
                                                    Navigator.pop(context);

                                                    AwesomeDialog(
                                                      width: 500,
                                                      context: context,
                                                      dialogType:
                                                          DialogType.error,
                                                      animType:
                                                          AnimType.rightSlide,
                                                      title: 'Error',
                                                      desc: 'Código Incorrecto',
                                                      btnCancel: Container(),
                                                      btnOkText: "Aceptar",
                                                      btnOkColor:
                                                          colors.colorGreen,
                                                      btnCancelOnPress: () {},
                                                      btnOkOnPress: () {},
                                                    ).show();
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(height: 20),
                                  data.isNotEmpty &&
                                          data['comprobante'].toString() !=
                                              "null"
                                      ? SizedBox(
                                          width:
                                              MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.60
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.90,
                                          child: Image.network(
                                            "$generalServer${data['comprobante'].toString()}",
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(),
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
