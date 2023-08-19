import 'package:flutter/material.dart';

class OptionsModal extends StatefulWidget {
  final List<String> options;
  final VoidCallback onCancel;
  final Function(String) onConfirm;
  final List<Widget>? children;
  final double height;
  const OptionsModal({
    Key? key,
    required this.options,
    required this.onCancel,
    required this.onConfirm,
    this.children,
    this.height = 300,
  }) : super(key: key);

  @override
  State<OptionsModal> createState() => _OptionsModalState();
}

class _OptionsModalState extends State<OptionsModal> {
  String _selected = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: SizedBox(
      height: widget.height,
      width: 500,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: widget.options
                    .map(
                      (e) => CheckboxListTile(
                        value: _selected == e,
                        onChanged: (bool? value) {
                          setState(() {
                            _selected = e;
                          });
                        },
                        title: Text(
                          e,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          widget.children != null
              ? _selected == 'REALIZADO'
                  ? widget.children![0]
                  : _selected == 'RECHAZADO'
                      ? widget.children![1]
                      : Offstage()
              : Offstage(),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: widget.onCancel,
                child: Text(
                  "Cancelar",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    widget.onConfirm(_selected);
                  },
                  child: Text(
                    "Aceptar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ))
            ],
          )
        ],
      ),
    ));
  }
}
