import 'package:flutter/material.dart';

class IncomeAndExpensesControllers {
  TextEditingController searchController = TextEditingController();

  TextEditingController idController = TextEditingController();
  TextEditingController dateController = TextEditingController(text: "");
  TextEditingController movementDateController =
      TextEditingController(text: "");
  TextEditingController personController = TextEditingController(text: "");
  TextEditingController reasonController = TextEditingController(text: "");
  TextEditingController amountController = TextEditingController(text: "");
}

class IncomeAndExpenseControllers {
  late TextEditingController fechaMovimientoController;
  late TextEditingController personaController;
  late TextEditingController motivoController;
  late TextEditingController montoController;

  IncomeAndExpenseControllers({
    required String fechaMovimiento,
    required String persona,
    required String motivo,
    required String monto,
  }) {
    fechaMovimientoController = TextEditingController(text: fechaMovimiento);
    personaController = TextEditingController(text: persona);
    motivoController = TextEditingController(text: motivo);
    montoController = TextEditingController(text: monto);
  }
}
