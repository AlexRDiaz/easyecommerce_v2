import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
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
    print("old _SellerWithdrawalInfoState strapi version");
    double heigth = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Retiros Vendedores Form",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 600
                  ? MediaQuery.of(context).size.width * 0.60
                  : MediaQuery.of(context).size.width * 0.90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Fecha: ${data.isNotEmpty ? data['fecha'].toString() : ''}",
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Monto: ${data.isNotEmpty ? data['monto'].toString() : ''}",
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Estado: ${data.isNotEmpty ? data['estado'].toString() : ''}",
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Transferencia: ${data.isEmpty || data['fecha_transferencia'].toString() == "null" ? "" : data['fecha_transferencia'].toString()}",
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  data.isNotEmpty
                      ? data['estado'].toString() == "PENDIENTE"
                          ? SizedBox(
                              width: 500,
                              child: TextField(
                                controller: _codeController,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                    hintText:
                                        "INGRESA EL CÓDIGO DE VERIFICACIÓN",
                                    hintStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ))
                          : Container()
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                  data.isNotEmpty
                      ? data['estado'].toString() == "PENDIENTE"
                          ? SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                child: Text(
                                  "VALIDAR",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_codeController.text ==
                                      data['codigo_generado']) {
                                    getLoadingModal(context, false);
                                    var response = await Connections()
                                        .withdrawalPut(
                                            data['id'], _codeController.text);
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
                                        await loadData();
                                      },
                                    ).show();
                                  } else {
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
                              ))
                          : Container()
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                  data.isNotEmpty
                      ? data['comprobante'].toString() != "null"
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width > 600
                                  ? MediaQuery.of(context).size.width * 0.60
                                  : MediaQuery.of(context).size.width * 0.90,
                              child: Image.network(
                                "$generalServer${data['comprobante'].toString()}",
                                fit: BoxFit.cover,
                              ))
                          : Container()
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
