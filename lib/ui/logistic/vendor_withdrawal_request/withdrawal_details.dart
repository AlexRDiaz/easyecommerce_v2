import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:frontend/ui/utils/utils.dart';
import 'package:frontend/ui/widgets/forms/date_input.dart';
import 'package:frontend/ui/widgets/forms/image_input.dart';
import 'package:frontend/ui/widgets/forms/image_row.dart';
import 'package:frontend/ui/widgets/forms/input_row.dart';
import 'package:frontend/ui/widgets/forms/row_label.dart';
import 'package:frontend/ui/widgets/forms/text_input.dart';
import 'package:frontend/ui/widgets/loading.dart';
import 'package:get/route_manager.dart';
import 'package:frontend/helpers/server.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/exports.dart';
import '../../../connections/connections.dart';
import '../../../helpers/navigators.dart';
import '../../widgets/options_modal.dart';
import 'controllers/controllers.dart';

class WithdrawalDetails extends StatefulWidget {
  const WithdrawalDetails({super.key});

  @override
  State<WithdrawalDetails> createState() => _WithDrawalDetailsState();
}

class _WithDrawalDetailsState extends State<WithdrawalDetails> {
  TextEditingController _modalController = TextEditingController();
  var data = {};
  bool loading = true;
  XFile? imageSelect = null;
  TextEditingController _fecha = TextEditingController();
  TextEditingController _monto = TextEditingController();
  TextEditingController _codigoDeValidacion = TextEditingController();
  TextEditingController _codigoDeRetiro = TextEditingController();
  TextEditingController _fechaT = TextEditingController();

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
    _fecha.text = data['attributes']['Fecha'].toString();
    _monto.text = data['attributes']['Monto'].toString();
    _codigoDeValidacion.text = data['attributes']['CodigoGenerado'].toString();
    _codigoDeRetiro.text = data['attributes']['Codigo'].toString();
    _fechaT.text = data['attributes']['FechaTransferencia'].toString();

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
    Color color = UIUtils.getColor('NOVEDAD');
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
          "",
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
          child: loading == false
              ? SingleChildScrollView(
                  child: data['attributes']['Estado'].toString() == "REALIZADO"
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return OptionsModal(
                                              height: 300,
                                              options: const [
                                                'REALIZADO',
                                                'RECHAZADO'
                                              ],
                                              children: [
                                                ImageRow(
                                                    title: imageSelect == null
                                                        ? 'Comprobante'
                                                        : imageSelect!.name
                                                            .toString(),
                                                    onSelect: (XFile image) {
                                                      setState(() {
                                                        imageSelect = image;
                                                      });
                                                    }),
                                                InputRow(
                                                    controller:
                                                        _modalController,
                                                    title: 'Comentario')
                                              ],
                                              onCancel: () {
                                                Navigator.of(context).pop();
                                              },
                                              onConfirm:
                                                  (String selected) async {
                                                if (selected == "RECHAZADO") {
                                                  getLoadingModal(
                                                      context, false);
                                                  var result = await Connections()
                                                      .updateWithdrawalRechazado(
                                                          _modalController
                                                              .text);
                                                  await loadData();
                                                  setState(() {
                                                    _modalController.clear();
                                                  });
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                }
                                                if (selected == "REALIZADO") {
                                                  if (imageSelect != null) {
                                                    var response =
                                                        await Connections()
                                                            .postDoc(
                                                                imageSelect!);

                                                    getLoadingModal(
                                                        context, false);

                                                    var result = await Connections()
                                                        .updateWithdrawalRealizado(
                                                            response[1]
                                                                .toString());
                                                    await loadData();
                                                    setState(() {
                                                      imageSelect = null;
                                                    });
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  } else {
                                                    AwesomeDialog(
                                                      width: 500,
                                                      context: context,
                                                      dialogType:
                                                          DialogType.error,
                                                      animType:
                                                          AnimType.rightSlide,
                                                      title:
                                                          'Debes Seleccionar un Comprobante',
                                                      desc:
                                                          'Vuelve a intentarlo',
                                                      btnCancel: Container(),
                                                      btnOkText: "Aceptar",
                                                      btnOkColor:
                                                          colors.colorGreen,
                                                      btnCancelOnPress: () {},
                                                      btnOkOnPress: () {},
                                                    ).show();
                                                  }
                                                }
                                                if (selected != "RECHAZADO" &&
                                                    selected != "REALIZADO") {
                                                  Navigator.pop(context);
                                                }

                                        
                                              });
                                        });
                                  },
                                  child: const Text(
                                    "Estado",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    getLoadingModal(context, false);
                                    var response = await Connections()
                                        .updateOrdenRetiro(
                                            _fecha.text,
                                            _monto.text,
                                            _codigoDeValidacion.text,
                                            _codigoDeRetiro.text,
                                            _fechaT.text);
                                    Navigator.pop(context);
                                    await loadData();
                                  },
                                  child: const Text(
                                    "Actualizar Datos",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: _fecha,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                    labelText: "Fecha",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            RowLabel(
                              title: 'Vendedor',
                              value: data['attributes']
                                          ['users_permissions_user']['data']
                                      ['attributes']['username']
                                  .toString(),
                              color: Colors.black,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: _monto,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                    labelText: "Monto a retirar",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: _codigoDeValidacion,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                    labelText: "Codigo Generado",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: _codigoDeRetiro,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                    labelText: "Codigo de retiro",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            RowLabel(
                              title: 'Estado del pago',
                              value: data['attributes']['Estado'].toString(),
                              color: Colors.black,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                controller: _fechaT,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                    labelText: "Fecha y Hora Transferencia",
                                    labelStyle:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            RowLabel(
                              title: 'Comentario',
                              value:
                                  data['attributes']['Comentario'].toString(),
                              color: Colors.black,
                            ),
                            RowImage(
                              title: "Comprobante",
                              value:
                                  data['attributes']['Comprobante'].toString(),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            data['attributes']['Estado'].toString() ==
                                    "APROBADO"
                                ? ElevatedButton(
                                    onPressed: () async {
                                      await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return OptionsModal(
                                                height: 300,
                                                options: const [
                                                  'REALIZADO',
                                                  'RECHAZADO'
                                                ],
                                                children: [
                                                  ImageRow(
                                                      title: imageSelect == null
                                                          ? 'Comprobante'
                                                          : imageSelect!.name
                                                              .toString(),
                                                      onSelect: (XFile image) {
                                                        setState(() {
                                                          imageSelect = image;
                                                        });
                                                      }),
                                                  InputRow(
                                                      controller:
                                                          _modalController,
                                                      title: 'Comentario')
                                                ],
                                                onCancel: () {
                                                  Navigator.of(context).pop();
                                                },
                                                onConfirm:
                                                    (String selected) async {
                                                  if (selected == "RECHAZADO") {
                                                    getLoadingModal(
                                                        context, false);
                                                    var result = await Connections()
                                                        .updateWithdrawalRechazado(
                                                            _modalController
                                                                .text);
                                                    await loadData();
                                                    setState(() {
                                                      _modalController.clear();
                                                    });
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  }
                                                  if (selected == "REALIZADO") {
                                                    if (imageSelect != null) {
                                                      var response =
                                                          await Connections()
                                                              .postDoc(
                                                                  imageSelect!);

                                                      getLoadingModal(
                                                          context, false);

                                                      var result = await Connections()
                                                          .updateWithdrawalRealizado(
                                                              response[1]
                                                                  .toString());
                                                      await loadData();
                                                      setState(() {
                                                        imageSelect = null;
                                                      });
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    } else {
                                                      AwesomeDialog(
                                                        width: 500,
                                                        context: context,
                                                        dialogType:
                                                            DialogType.error,
                                                        animType:
                                                            AnimType.rightSlide,
                                                        title:
                                                            'Debes Seleccionar un Comprobante',
                                                        desc:
                                                            'Vuelve a intentarlo',
                                                        btnCancel: Container(),
                                                        btnOkText: "Aceptar",
                                                        btnOkColor:
                                                            colors.colorGreen,
                                                        btnCancelOnPress: () {},
                                                        btnOkOnPress: () {},
                                                      ).show();
                                                    }
                                                  }
                                                  if (selected != "RECHAZADO" &&
                                                      selected != "REALIZADO") {
                                                    Navigator.pop(context);
                                                  }

                                                });
                                          });
                                    },
                                    child: const Text(
                                      "Pagado",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                : Container(),
                            RowLabel(
                              title: 'Fecha',
                              value: data['attributes']['Fecha'].toString(),
                              color: Colors.black,
                            ),
                            RowLabel(
                              title: 'Vendedor',
                              value: data['attributes']
                                          ['users_permissions_user']['data']
                                      ['attributes']['username']
                                  .toString(),
                              color: Colors.black,
                            ),
                            RowLabel(
                              title: 'Monto a retirar',
                              value: data['attributes']['Monto'].toString(),
                              color: Colors.black,
                            ),
                            RowLabel(
                              title: 'Código de validación',
                              value: data['attributes']['CodigoGenerado']
                                  .toString(),
                              color: Colors.black,
                            ),
                            RowLabel(
                              title: 'Código de retiro',
                              value: data['attributes']['Codigo'].toString(),
                              color: Colors.black,
                            ),
                            RowLabel(
                              title: 'Estado del pago',
                              value: data['attributes']['Estado'].toString(),
                              color: Colors.black,
                            ),
                            RowLabel(
                              title: 'Fecha y Hora Transferencia',
                              value: data['attributes']['FechaTransferencia']
                                  .toString(),
                              color: Colors.black,
                            ),
                            RowLabel(
                              title: 'Comentario',
                              value:
                                  data['attributes']['Comentario'].toString(),
                              color: Colors.black,
                            ),
                            RowImage(
                              title: "Comprobante",
                              value:
                                  data['attributes']['Comprobante'].toString(),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                )
              : Container(),
        ),
      ),
    );
  }
}
