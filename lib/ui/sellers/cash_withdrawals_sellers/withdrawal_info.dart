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

class SellerWithdrawalInfo extends StatefulWidget {
  const SellerWithdrawalInfo({
    super.key,
  });

  @override
  State<SellerWithdrawalInfo> createState() => _SellerWithdrawalInfoState();
}

class _SellerWithdrawalInfoState extends State<SellerWithdrawalInfo> {
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
    var response = await Connections().getWithDrawalByID();
    // data = response;
    data = response;

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators().pushNamedAndRemoveUntil(context, "/layout/sellers");
            },
            child: Icon(Icons.arrow_back_ios, color: Colors.black)),
        centerTitle: true,
        title: Text(
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
              width: 500,
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
                    "Fecha: ${data.isNotEmpty ? data['attributes']['Fecha'].toString() : ''}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Monto: ${data.isNotEmpty ? data['attributes']['Monto'].toString() : ''}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Estado: ${data.isNotEmpty ? data['attributes']['Estado'].toString() : ''}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Transferencia: ${data.isNotEmpty ? data['attributes']['FechaTransferencia'].toString() : ''}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  data.isNotEmpty
                      ? data['attributes']['Estado'].toString() == "PENDIENTE"
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
                      ? data['attributes']['Estado'].toString() == "PENDIENTE"
                          ? SizedBox(
                              width: 500,
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
                                      data['attributes']['CodigoGenerado']) {
                                    getLoadingModal(context, false);
                                    var response = await Connections()
                                        .withdrawalPut(_codeController.text);
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
                      ? data['attributes']['Comprobante'].toString() != "null"
                          ? SizedBox(
                              width: 500,
                              child: Image.network(
                                "$generalServer${data['attributes']['Comprobante'].toString()}",
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
