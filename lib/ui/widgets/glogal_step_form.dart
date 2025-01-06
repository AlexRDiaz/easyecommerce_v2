import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:frontend/config/colors.dart';
import 'package:frontend/config/textstyles.dart';

// ignore: must_be_immutable
class StepFormGlobal extends StatefulWidget {
  final int numSteps;
  final Widget contentstep1;
  final Widget contentstep2;
  final Widget contentstep3;
  final VoidCallback onFinish;
  final VoidCallback onFinishOptionElse;

  StepFormGlobal({
    super.key,
    required this.numSteps,
    required this.contentstep1,
    required this.contentstep2,
    required this.contentstep3,
    required this.onFinish,
    required this.onFinishOptionElse,
  });

  @override
  _StepFormGlobalState createState() => _StepFormGlobalState();
}

class _StepFormGlobalState extends State<StepFormGlobal> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: ColorsSystem().colorSelected,
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 10, color: Colors.black),
          ),
        ),
        child: Stepper(
          steps: _buildSteps(),
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          type: StepperType.horizontal,
          controlsBuilder: (context, ControlsDetails details) {
            return Column(
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text("Agregar Productos"),
                //     GestureDetector(
                //       child: Icon(Icons.close,color: Colors.black,),
                //       onTap: () {
                //         Navigator.pop(context);
                //       },
                //     )
                //   ],
                // ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 30,
                      width: _currentStep == 0
                          ? MediaQuery.of(context).size.width * 0.29
                          : 100,
                      child: ElevatedButton(
                        onPressed:
                            // (_currentStep == widget.numSteps - 1)
                            // ? null
                            // :
                            () {
                          details.onStepContinue!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_currentStep == widget.numSteps - 1)
                              ? Colors.green
                              : ColorsSystem().colorStore,
                        ),
                        child: Text(
                          _currentStep == widget.numSteps - 1
                              ? 'Finalizar'
                              : 'Siguiente',
                          style: TextStylesSystem()
                              .ralewayStyle(12, FontWeight.w600, Colors.white),
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
                            backgroundColor: ColorsSystem().colorSection2,
                          ),
                          child: Text(
                            'Atrás',
                            style: TextStylesSystem().ralewayStyle(
                                12, FontWeight.w500, Colors.white),
                          ),
                        ),
                      )
                  ],
                ),
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
              // widget.contentstep4,
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
    // Widget contentstep4,
  ) {
    switch (stepIndex) {
      case 0:
        return contentstep1;
      case 1:
        return contentstep2;
      case 2:
        return contentstep3;
      // case 3:
      // return contentstep4;
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
      } else {
        _optionElseofForm();
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

  void _optionElseofForm() {
    widget.onFinishOptionElse();
  }
}
