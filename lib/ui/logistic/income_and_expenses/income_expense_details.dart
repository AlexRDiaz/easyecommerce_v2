import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/image_input.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/forms/row_options.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import 'controllers/controllers.dart';

class IncomeExpenseDetailsView extends StatefulWidget {
  final bool isNew;
  const IncomeExpenseDetailsView({
    super.key,
    required this.isNew,
  });

  @override
  State<IncomeExpenseDetailsView> createState() =>
      _IncomeExpenseDetailsViewState();
}

class _IncomeExpenseDetailsViewState extends State<IncomeExpenseDetailsView> {
  late IncomeAndExpenseControllers _controllers;
  String id = "0";
  String button = "";
  XFile? imageSelect = null;
  String comprobante = "";
  var data = {};
  @override
  void didChangeDependencies() {
    initControllers();
    super.didChangeDependencies();
  }

  initControllers() async {
    id = Get.parameters['id'].toString();
    setState(() {});

    // ignore: unnecessary_null_comparison
    if (id.toString() == "null") {
      _controllers = IncomeAndExpenseControllers(
          fechaMovimiento: '', persona: '', motivo: '', monto: '0');
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getLoadingModal(context, false);
      });
      _controllers = IncomeAndExpenseControllers(
          fechaMovimiento: '', persona: '', motivo: '', monto: '');
      var response = await Connections().getIngresosEgresosByID();
      setState(() {
        button = response['attributes']['Tipo'].toString();
        comprobante = response['attributes']['Comprobante'].toString();
        _controllers = IncomeAndExpenseControllers(
            fechaMovimiento: response['attributes']['Fecha']
                .toString()
                .split(" ")[0]
                .toString(),
            persona: response['attributes']['Persona'].toString(),
            motivo: response['attributes']['Motivo'].toString(),
            monto: response['attributes']['Monto'].toString());
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigators().pushNamedAndRemoveUntil(context, "/layout/logistic");
            },
            child: const Icon(Icons.arrow_back_ios, color: Colors.black)),
        centerTitle: true,
        title: const Text(
          "Ingresos Form",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  DateInput(
                    isEdit: true,
                    title: "Fecha Movimiento",
                    dateTime: DateTime.now(),
                    controller: _controllers.fechaMovimientoController,
                  ),
                  id == "null"
                      ? Container()
                      : Text(
                          "ACTUAL: $button",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                  RowOptions(
                      title: 'Tipo Movimiento',
                      options: ['INGRESO', 'EGRESO'],
                      onSelect: (String value) {
                        setState(() {
                          button = value;
                        });
                      }),
                  InputRow(
                      controller: _controllers.personaController,
                      title: 'Persona'),
                  InputRow(
                      controller: _controllers.motivoController,
                      title: 'Motivo'),
                  id == "null"
                      ? Container()
                      : TextButton(
                          onPressed: () {
                            launchUrl(Uri.parse("$generalServer$comprobante"));
                          },
                          child: Text(
                            "VER COMPROBANTE",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          )),
                  id == "null"
                      ? Container()
                      : Text(
                          "ACTUAL: ${comprobante.toString().split("/").last.toString()}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                  ImageRow(
                      title: 'Comprobante',
                      onSelect: (XFile image) {
                        imageSelect = image;
                      }),
                  InputRow(
                      controller: _controllers.montoController, title: 'Monto'),
                  ElevatedButton(
                      onPressed: () async {
                        if (id == "null") {
                          if (imageSelect != null) {
                            getLoadingModal(context, false);

                            var result =
                                await Connections().postDoc(imageSelect!);
                            var response = await Connections().createIngresos(
                                _controllers.fechaMovimientoController.text,
                                button,
                                _controllers.personaController.text,
                                _controllers.motivoController.text,
                                result[1],
                                _controllers.montoController.text);
                            if (response[0]) {
                              Navigator.pop(context);
                              Navigators().pushNamedAndRemoveUntil(
                                  context, "/layout/logistic");
                            } else {
                              Navigator.pop(context);
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.rightSlide,
                                title: 'Error',
                                desc: 'Revisa los Campos',
                                btnCancel: Container(),
                                btnOkText: "Aceptar",
                                btnOkColor: colors.colorGreen,
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {},
                              ).show();
                            }
                          } else {
                            AwesomeDialog(
                              width: 500,
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.rightSlide,
                              title: 'Error',
                              desc: 'Debes Seleccionar Comprobante',
                              btnCancel: Container(),
                              btnOkText: "Aceptar",
                              btnOkColor: colors.colorGreen,
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {},
                            ).show();
                          }
                        } else {
                          getLoadingModal(context, false);

                          if (imageSelect != null) {
                            var result =
                                await Connections().postDoc(imageSelect!);
                            var response = await Connections().updateIngresos(
                                _controllers.fechaMovimientoController.text,
                                button.toString(),
                                _controllers.personaController.text,
                                _controllers.motivoController.text,
                                result[1],
                                _controllers.montoController.text);
                            if (response[0]) {
                              Navigator.pop(context);
                              await initControllers();
                            } else {
                              Navigator.pop(context);
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.rightSlide,
                                title: 'Error',
                                desc: 'Revisa los Campos',
                                btnCancel: Container(),
                                btnOkText: "Aceptar",
                                btnOkColor: colors.colorGreen,
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {},
                              ).show();
                            }
                          } else {
                            var response = await Connections().updateIngresos(
                                _controllers.fechaMovimientoController.text,
                                button.toString(),
                                _controllers.personaController.text,
                                _controllers.motivoController.text,
                                comprobante,
                                _controllers.montoController.text);
                            if (response[0]) {
                              Navigator.pop(context);
                              await initControllers();
                            } else {
                              Navigator.pop(context);
                              AwesomeDialog(
                                width: 500,
                                context: context,
                                dialogType: DialogType.error,
                                animType: AnimType.rightSlide,
                                title: 'Error',
                                desc: 'Revisa los Campos',
                                btnCancel: Container(),
                                btnOkText: "Aceptar",
                                btnOkColor: colors.colorGreen,
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {},
                              ).show();
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors.colorGreen),
                      child: Text(
                        "Guardar",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  SizedBox(
                    height: 30,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
