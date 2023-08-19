import 'package:flutter/material.dart';

responsive(web, mobile, context) {
  if (MediaQuery.of(context).size.width > 930) {
    return web;
  } else {
    return mobile;
  }
}
