import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';

// ignore: must_be_immutable
class StepForm extends StatefulWidget {
  final int numSteps;
  final Widget contentstep1;
  final Widget contentstep2;
  final Widget contentstep3;
  final Widget contentstep4;
  final String? selectedCarrierType;
  final bool gtmCarrier;
  final List<dynamic> productoList;
  final String? selectedProvinciaExt;
  final String? selectedCityExt;
  final String? selectedValueRouteInt;
  double profit;
  final VoidCallback onFinish;
  String product;
  TextEditingController direction;
  TextEditingController phone;
  TextEditingController name;

  StepForm({super.key, 
    required this.numSteps,
    required this.contentstep1,
    required this.contentstep2,
    required this.contentstep3,
    required this.contentstep4,
    required this.selectedCarrierType,
    required this.gtmCarrier,
    required this.productoList,
    required this.selectedProvinciaExt,
    required this.selectedCityExt,
    required this.selectedValueRouteInt,
    required this.profit,
    required this.onFinish,
    required this.product,
    required this.direction,
    required this.phone,
    required this.name,
  });

  @override
  _StepFormState createState() => _StepFormState();
}

class _StepFormState extends State<StepForm> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  double auxiliar = 0;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary:
                ColorsSystem().colorSelected, 
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(
                fontSize: 10,
                color: Colors.black), 
          ),
        ),
        child: Stepper(
          steps: _buildSteps(),
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          type: StepperType.horizontal,
          controlsBuilder: (context, ControlsDetails details) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 30,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: (_currentStep == widget.numSteps - 1 &&
                            (widget.profit == auxiliar))
                        ? null 
                        : () {
                            widget.profit = auxiliar;
                            if ((_currentStep == 0)) {
                              if (widget.productoList.isNotEmpty) {
                                details.onStepContinue!();
                              } else {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.bottomSlide,
                                  title: 'Debe agregar un producto',
                                  desc:
                                      'Verifica los datos ingresados y vuelve a intentarlo.',
                                  btnOkOnPress: () {},
                                ).show();
                              }
                            } else if (_currentStep == 1
                            &&
                            (widget.name.text == "" ||
                            widget.direction.text == "" ||
                            widget.phone.text == ""))
                            {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                animType: AnimType.bottomSlide,
                                title: 'Debe llenar los campos necesarios',
                                desc:
                                    'Verifica los datos ingresados y vuelve a intentarlo.',
                                btnOkOnPress: () {},
                              ).show();
                            } else if ((_currentStep == 2)) {
                              if (widget.selectedCarrierType != " ") {
                                if ((widget.selectedCarrierType == "Interno" &&
                                        widget.selectedValueRouteInt != null) ||
                                    (widget.selectedCarrierType == "Externo" &&
                                        widget.gtmCarrier == true &&
                                        widget.selectedProvinciaExt != null &&
                                        widget.selectedCityExt != null)) {
                                  if (widget.gtmCarrier) {
                                    setState(() {
                                      widget.selectedValueRouteInt == null;
                                    });
                                  } else if (widget.gtmCarrier == false) {
                                    setState(() {
                                      widget.selectedProvinciaExt == null;
                                      widget.selectedCityExt == null;
                                    });
                                  }
                                  details.onStepContinue!();
                                } else {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.bottomSlide,
                                    title:
                                        'Debe seleccionar una transportadora',
                                    desc:
                                        'Verifica los datos ingresados y vuelve a intentarlo.',
                                    btnOkOnPress: () {},
                                  ).show();
                                }
                              } else {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.warning,
                                  animType: AnimType.bottomSlide,
                                  title: 'Debe seleccionar una Transportadora',
                                  desc:
                                      'Verifica los datos ingresados y vuelve a intentarlo.',
                                  btnOkOnPress: () {},
                                ).show();
                              }
                            } else {
                              details.onStepContinue!();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_currentStep == widget.numSteps - 1 &&
                              widget.profit == 0)
                          ? Colors
                              .grey 
                          : (_currentStep == widget.numSteps - 1 &&
                                  widget.profit > 0)
                              ? Colors
                                  .green 
                              : ColorsSystem()
                                  .colorStore, 
                    ),
                    child: Text(
                      _currentStep == widget.numSteps - 1
                          ? 'Finalizar'
                          : 'Siguiente',
                      style: TextStylesSystem()
                          .ralewayStyle(10, FontWeight.w500, Colors.white),
                    ),
                  ),
                ),
                if (_currentStep > 0)
                  Container(
                    height: 30,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: details.onStepCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsSystem()
                            .colorSection2, 
                      ),
                      child: Text(
                        'Atrás',
                        style: TextStylesSystem()
                            .ralewayStyle(10, FontWeight.w500, Colors.white),
                      ),
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    List<Step> steps = [];

    for (int i = 0; i < widget.numSteps; i++) {
      steps.add(
        Step(
          title: Text(
            i <= 2 ? ">" : "",
            style: TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.w400,
              color: Colors.grey[600], 
            ),
          ),
          content: Container(
            padding: EdgeInsets.zero, 
            margin: EdgeInsets.zero, 
            child: _buildStepContent(
              i,
              widget.contentstep1,
              widget.contentstep2,
              widget.contentstep3,
              widget.contentstep4,
            ),
          ),
          isActive: _currentStep >= i,
          state: _currentStep > i ? StepState.complete : StepState.indexed,
        ),
      );
    }

    return steps;
  }

  Widget _buildStepContent(
    int stepIndex,
    Widget contentstep1,
    Widget contentstep2,
    Widget contentstep3,
    Widget contentstep4,
  ) {
    switch (stepIndex) {
      case 0:
        return contentstep1;
      case 1:
        return contentstep2;
      case 2:
        return contentstep3;
      case 3:
        return contentstep4;
      default:
        return SizedBox();
    }
  }

  void _onStepContinue() {
    if (_currentStep < widget.numSteps - 1) {
      setState(() {
        _currentStep += 1;
      });
    } else {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        _submitForm();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _submitForm() {
    widget.onFinish();
  }
}
