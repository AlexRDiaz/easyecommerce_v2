import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/main.dart';

List optionsLogistic = [
  {"name": "DashBoard", "icon": Icons.home_outlined},
  {"name": "Ingresos y Egresos", "icon": Icons.list},
  {"name": "Agregar Vendedores", "icon": Icons.add},
  // {"name": "Agregar Proveedores", "icon": Icons.add},
  {"name": "Agregar Transportistas", "icon": Icons.add},
  {"name": "Agregar Usuario Logística", "icon": Icons.add},
  {"name": "Estado de Cuenta", "icon": Icons.insert_drive_file_outlined},
  {"name": "Facturas Vendedores", "icon": Icons.person_outline_outlined},
  {"name": "Comprobantes de Pago", "icon": Icons.calendar_today_sharp},
  {"name": "Saldo Contable", "icon": Icons.monetization_on_outlined},
  {"name": "Saldo Logística", "icon": Icons.monetization_on_outlined},
  {"name": "Solicitud de Retiro Vendedores", "icon": Icons.edit_document},
  // {"name": "Depósitos a proveedores", "icon": Icons.credit_card},
  {"name": "Estado de Entregas", "icon": Icons.fire_truck_outlined},
  {"name": "Historial Pedidos Transportadora", "icon": Icons.list_alt},
  // {"name": "Asignar Rutas", "icon": Icons.add_box_outlined},
  {"name": "Imprimir Guías", "icon": Icons.print_outlined},
  {"name": "Guías Impresas", "icon": Icons.print},
  {"name": "Guías Enviadas", "icon": Icons.send_outlined},
  // {"name": "Añadir Stock a Vendedores", "icon": Icons.add},
  {"name": "Soporte Remoto", "icon": Icons.help_outline_outlined},
  // {"name": "Asignar Retiros", "icon": Icons.add_box_outlined},
  {"name": "Devoluciones", "icon": Icons.assignment_return_outlined},
  {"name": "Devolución en bodega", "icon": Icons.warehouse},

  {"name": "Cambiar Contraseña", "icon": Icons.security},
  {"name": "Cerrar Sesión", "icon": Icons.logout_outlined},
];

List optionsSellers = [
  {"name": "DashBoard", "icon": Icons.home_outlined},
  {"name": "Reporte de Ventas", "icon": Icons.document_scanner},
  {"name": "Mi Cuenta Vendedor", "icon": Icons.person_4_outlined},
  {
    "name": "Agregar Usuarios Vendedores",
    "icon": Icons.add_circle_outline_outlined
  },
  {"name": "Ingreso de Pedidos", "icon": Icons.add_circle_outline_outlined},
  {"name": "Estado Entregas Pedidos", "icon": Icons.add_alert_outlined},
  {"name": "Pedidos No Deseados", "icon": Icons.no_sim_outlined},
  {"name": "Billetera", "icon": Icons.wallet},
  {"name": "Devoluciones", "icon": Icons.list_outlined},
  {"name": "Retiros en Efectivo", "icon": Icons.monetization_on_outlined},
  {"name": "Cambiar Contraseña", "icon": Icons.security},
  {"name": "Cerrar Sesión", "icon": Icons.logout_outlined},
];

List optionsTransport = [
  {"name": "Home", "icon": Icons.home_outlined},
  {"name": "Mis Pedidos PRV", "icon": Icons.rebase_edit},
  {"name": "Estado de Entregas", "icon": Icons.traffic_outlined},
  {"name": "Agregar Operadores", "icon": Icons.add_box_outlined},
  {"name": "Mi Cuenta Transportador", "icon": Icons.account_balance_outlined},
  {"name": "Comprobantes de Pago", "icon": Icons.all_inbox_outlined},
  {
    "name": "Facturación transporte PRV",
    "icon": Icons.document_scanner_rounded
  },
  {"name": "Devoluciones", "icon": Icons.list_outlined},
  {"name": "Cambiar Contraseña", "icon": Icons.security},
  {"name": "Cerrar Sesión", "icon": Icons.logout_outlined},
];

List optionsOperator = [
  {"name": "Home", "icon": Icons.home_outlined},
  {"name": "Mi Cuenta", "icon": Icons.person_4_outlined},
  {"name": "Pedidos Operador", "icon": Icons.send_outlined},
  {"name": "Estado de Entregas", "icon": Icons.emoji_transportation},
  {"name": "Valores Recibidos", "icon": Icons.monetization_on_outlined},
  {"name": "Devoluciones", "icon": Icons.list_alt_outlined},
  {"name": "Actualizar Contraseña", "icon": Icons.security_outlined},
  {"name": "Cerrar Sesión", "icon": Icons.logout_outlined},
];
