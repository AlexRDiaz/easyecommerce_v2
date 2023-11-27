import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerExample extends StatefulWidget {
  final Function(XFile? image)? onImageSelected;
  final String? label;
  final double? widgetWidth;

  const ImagePickerExample({Key? key, this.onImageSelected,this.label,this.widgetWidth}) : super(key: key);

  @override
  _ImagePickerExampleState createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  XFile? _image;
  String? _imageName;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = image;
        _imageName = image.name;
      });

      // Llamar al callback con la imagen seleccionada
      if (widget.onImageSelected != null) {
        widget.onImageSelected!(_image);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.widgetWidth ?? 300,
      height: 550,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _image == null
              ? Text(
                  widget.label.toString(),
                  style: TextStyle(color: Color.fromARGB(255, 107, 105, 105)),
                )
              : kIsWeb
                  ? Image.network(_image!.path, height: 50, width: 50, fit: BoxFit.cover)
                  : Row(
                      children: [
                        Image.file(
                          File(_image!.path),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 15),
                        Text(_imageName ?? ""),
                      ],
                    ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Seleccionar Imagen'),
          ),
        ],
      ),
    );
  }
}
