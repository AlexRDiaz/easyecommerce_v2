import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:frontend/ui/logistic/shopping_status/controllers/controllers.dart';

class ShoppingStatus extends StatefulWidget {
  const ShoppingStatus({super.key});

  @override
  State<ShoppingStatus> createState() => _ShoppingStatusState();
}

class _ShoppingStatusState extends State<ShoppingStatus> {
  ShoppingStatusControllers _controllers = ShoppingStatusControllers();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: _modelTextField(
                  text: "Busqueda", controller: _controllers.searchController),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                          trailing: const Icon(
                            Icons.arrow_forward_ios_sharp,
                            size: 15,
                          ),
                          title: Text(
                            "3/16/2023:  42",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ));
                    })),
          ],
        ),
      ),
    );
  }

  _modelTextField({text, controller}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 245, 244, 244),
      ),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {});
        },
        style: TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: _controllers.searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _controllers.searchController.clear();
                    });
                  },
                  child: Icon(Icons.close))
              : null,
          hintText: text,
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1, color: Color.fromRGBO(237, 241, 245, 1.0)),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Colors.black,
          iconColor: Colors.black,
        ),
      ),
    );
  }
}
