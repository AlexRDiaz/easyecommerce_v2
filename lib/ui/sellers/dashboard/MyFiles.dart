import 'package:flutter/material.dart';

class CloudStorageInfo {
  final String? svgSrc, title;
  final double? numOfFiles, percentage;
  final Color? color;

  CloudStorageInfo({
    this.svgSrc,
    this.title,
    this.numOfFiles,
    this.percentage,
    this.color,
  });
}
