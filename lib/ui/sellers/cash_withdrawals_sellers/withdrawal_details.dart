import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/config/exports.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/ui/sellers/my_seller_account/controllers/controllers.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/loading.dart';

import '../../../helpers/navigators.dart';
import 'controllers/controllers.dart';

class SellerWithdrawalDetails extends StatefulWidget {
  const SellerWithdrawalDetails({
    super.key,
  });

  @override
  State<SellerWithdrawalDetails> createState() =>
      _SellerWithdrawalDetailsState();
}

class _SellerWithdrawalDetailsState extends State<SellerWithdrawalDetails> {
  late CashWithdrawalsSellersControllers _controllers =
      CashWithdrawalsSellersControllers();

  @override
  void initState() {
    super.initState();
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
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 20,
                ),
                InputRow(
                    controller: _controllers.montoController,
                    title: 'Monto a Retirar'),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                    width: 500,
                    child: ElevatedButton(
                      child: Text(
                        "Guardar",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onPressed: () async {
                        getLoadingModal(context, false);
                        var response = await Connections()
                            .withdrawalPost(_controllers.montoController.text);
                        if (response) {
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
                            btnOkOnPress: () {
                              Navigators().pushNamedAndRemoveUntil(
                                  context, "/layout/sellers");
                            },
                          ).show();
                        } else {
                          Navigator.pop(context);
                          AwesomeDialog(
                            width: 500,
                            context: context,
                            dialogType: DialogType.error,
                            animType: AnimType.rightSlide,
                            title: 'Error',
                            desc: 'Vuelve a intentarlo',
                            btnCancel: Container(),
                            btnOkText: "Aceptar",
                            btnOkColor: colors.colorGreen,
                            btnCancelOnPress: () {},
                            btnOkOnPress: () {},
                          ).show();
                        }
                      },
                    )),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
