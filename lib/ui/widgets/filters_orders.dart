import 'package:flutter/material.dart';
import 'package:frontend/providers/filters_orders/filters_orders.dart';
import 'package:provider/provider.dart';

getFilterOrdersModal(context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Filtros",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: Container(
              width: 400,
              height: double.infinity,
              child: ListView(children: [
                _modelListTileModal(
                    "Todos",
                    Provider.of<FiltersOrdersProviders>(context).todos,
                    0,
                    context),
                _modelListTileModal(
                    "Código",
                    Provider.of<FiltersOrdersProviders>(context).codigoFilter,
                    1,
                    context),
                _modelListTileModal(
                    "Rango de Fechas",
                    Provider.of<FiltersOrdersProviders>(context).rangoFilter,
                    2,
                    context),
                _modelListTileModal(
                    "Nombre Cliente",
                    Provider.of<FiltersOrdersProviders>(context).nameFilter,
                    3,
                    context),
                _modelListTileModal(
                    "Ciudad",
                    Provider.of<FiltersOrdersProviders>(context).cityFilter,
                    4,
                    context),
              ])),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Aceptar",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            SizedBox(
              width: 10,
            )
          ],
        );
      });
}

ListTile _modelListTileModal(text, value, index, context) {
  return ListTile(
    title: Row(
      children: [
        Checkbox(
            value: value,
            onChanged: (val) {
              value = !value;
              Provider.of<FiltersOrdersProviders>(context, listen: false)
                  .changeValue(val, index);
            }),
        SizedBox(
          width: 10,
        ),
        Flexible(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ],
    ),
  );
}
