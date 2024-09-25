import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';
import 'package:frontend/connections/connections.dart';
import 'package:frontend/helpers/responsive.dart';
import 'package:pinput/pinput.dart';

/// This is the basic usage of Pinput
/// For more examples check out the demo directory
class PinInputSeller extends StatefulWidget {
  String code;
  String amount;

  PinInputSeller({Key? key, required this.code, required this.amount})
      : super(key: key);

  @override
  State<PinInputSeller> createState() => _PinInputSellerState();
}

class _PinInputSellerState extends State<PinInputSeller> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  late Timer _timer;
  int _start = 1 * 60; // 5 minutos en segundos
  bool formEnabled = true;

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    _timer.cancel();
    super.dispose();
  }

  String get timerText {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSecond,
      (Timer timer) {
        setState(() {
          if (_start == 0) {
            timer.cancel();
            // Llama a la función cuando el contador llega a cero
            onTimerFinished();
          } else {
            _start--;
          }
        });
      },
    );
  }

  void onTimerFinished() {
    // Lógica para ejecutar una función cuando el contador llega a cero
    setState(() {
      widget.code = "";
    });
    // Aquí puedes llamar a la función que necesites ejecutar al llegar a cero
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 22,
        color: ColorsSystem().colorLabels,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    final defaultPinPhoneTheme = PinTheme(
      width: 30,
      height: 30,
      textStyle: TextStyle(
        fontSize: 18,
        color: ColorsSystem().colorLabels,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    /// Optionally you can use form to validate the Pinput
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            // Specify direction if desired
            textDirection: TextDirection.ltr,
            child: Pinput(
              controller: pinController,
              focusNode: focusNode,
              androidSmsAutofillMethod:
                  AndroidSmsAutofillMethod.smsUserConsentApi,
              length: 8,
              listenForMultipleSmsOnAndroid: true,
              defaultPinTheme:
                  responsive(defaultPinTheme, defaultPinPhoneTheme, context),
              separatorBuilder: (index) => const SizedBox(width: 8),
              validator: (value) {
                // return value == widget.code
                //     ? saveApplication()
                //     : 'El pin es incorrecto';
                if (!formEnabled)
                  return null; // Evita validaciones adicionales si el formulario está deshabilitado
                if (value == widget.code) {
                  setState(() {
                    formEnabled =
                        false; // Deshabilita el formulario después de validarlo
                  });
                  saveApplication();
                  return null;
                }
                return 'El pin es incorrecto';
              },
              // onClipboardFound: (value) {
              //   debugPrint('onClipboardFound: $value');
              //   pinController.setText(value);
              // },
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: (pin) {
                debugPrint('onCompleted: $pin');
              },
              onChanged: (value) {
                debugPrint('onChanged: $value');
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    width: 22,
                    height: 1,
                    color: focusedBorderColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: focusedBorderColor),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: Colors.redAccent),
              ),
            ),
          ),
          Text(widget.code != "" ? "" : "Tiempo de espera terminado",
              style: TextStylesSystem().ralewayStyle(
                  14, FontWeight.w500, ColorsSystem().colorLabels)),
          widget.code != ""
              ? Container()
              : TextButton(
                  onPressed: formEnabled
                      ? () async {
                    pinController.clear();
                    var data =
                        await Connections().sendWithdrawalSeller(widget.amount);
                    print(data);
                    setState(() {
                      widget.code = data["response"];
                      _start = 1 * 60;
                    });
                    print(widget.code);

                    startTimer();
                  } : null,
                  child: Text(
                    'Reintentar',
                    style: TextStylesSystem()
                        .ralewayStyle(14, FontWeight.w500, Colors.green),
                  ),
                ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Tiempo restante:',
                  style: TextStylesSystem().ralewayStyle(
                      14, FontWeight.w500, ColorsSystem().colorLabels),
                ),
                SizedBox(height: 10),
                Text(
                  timerText,
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: ColorsSystem().colorSelected),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  saveApplication() async {
    var response =
        await Connections().sendWithdrawalAprovateSeller(widget.amount);
    // ignore: use_build_context_synchronously
    if (response == 0) {
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Solicitud aprobada',
        desc: 'Se ha registrado su solicitud de retiro',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        },
        onDismissCallback: (type) {
          Navigator.pop(context);
        },
      ).show();
    } else {
      AwesomeDialog(
        width: 500,
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error al realizar solicitud',
        desc: 'Porfavor contacte con el administrador',
        btnCancel: Container(),
        btnOkText: "Aceptar",
        btnOkColor: Colors.green,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    }
  }
}
