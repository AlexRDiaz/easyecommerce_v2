import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageRow extends StatefulWidget {
  final String title;
  final Function(XFile) onSelect;
  const ImageRow({
    Key? key,
    required this.title,
    required this.onSelect,
  }) : super(key: key);

  @override
  State<ImageRow> createState() => _ImageRowState();
}

class _ImageRowState extends State<ImageRow> {
  XFile? imageSelect = null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          const SizedBox(
            height: 20,
          ),
          Container(
            width: 500,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: const Color.fromARGB(255, 245, 244, 244),
            ),
            child: TextButton(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image =
                    await picker.pickImage(source: ImageSource.gallery);

                setState(() {
                  imageSelect = image;
                  widget.onSelect(imageSelect!);
                });
              },
              child: Text(
                "Seleccionar:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
