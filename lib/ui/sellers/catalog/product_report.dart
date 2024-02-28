import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:frontend/helpers/server.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/product_model.dart';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';

class ProductReport {
//   *

  Future<void> generateExcelFileWithData(dataOrders) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel.sheets[excel.getDefaultSheet() as String];
      sheet!.setColWidth(2, 50);
      sheet.setColAutoFit(3);

      ProductModel product = dataOrders;

      // List<String> urlsImgsList = product.urlImg != null &&
      //         product.urlImg.isNotEmpty &&
      //         product.urlImg.toString() != "[]"
      //     ? (jsonDecode(product.urlImg) as List).cast<String>()
      //     : [];

      // String firstImg = getFirstImgUrl(urlsImgsList);
      String productName = product.productName.toString();

      // Decodificar el JSON
      Map<String, dynamic> features = jsonDecode(product.features);

      String suggestedPrice = features["price_suggested"].toString();
      String sku = features["sku"];
      String skuFinal = "";
      String description = features["description"];
      String type = features["type"];
      List<dynamic> categories = features["categories"];
      List<String> categoriesNames =
          categories.map((item) => item["id"].toString()).toList();

      if (product.isvariable == 1) {
        List<Map<String, dynamic>>? variants =
            (features["variants"] as List<dynamic>)
                .cast<Map<String, dynamic>>();
      } else {
        skuFinal = "${sku}C${product.productId.toString()}";
      }

      List<String> headers = [
        "Handle", //PRODUCTO
        "Title", //PRODUCTO
        "Body (HTML)", //DESCRIPCION
        "Vendor", //BODEGA
        "Product Category", //CATEGORIA
        "Type", //SIMPLE idk
        "Tags", //NULL o vacio?? it vacio
        "Published", //FALSE
        //Option1 Name: variant name
        //Option1 Value: variant value y asi sucesivamente
        "Variant SKU", //(SKUCIDPRODUCTO)
        "Variant Grams", //''
        "Variant Inventory Tracker", //''
        "Variant Inventory Qty", //''
        "Variant Inventory Policy", //deny
        "Variant Fulfillment Service", //manual
        "Variant Price", //warehouse price
        "Variant Compare At Price", //suggedted price
        "Variant Requires Shipping", //
        "Variant Taxable", //TRUE
        "Variant Barcode", //TRUE
        "Image Src", //first imgurl
        "Image Position", //1
        "Image Alt Text", //''
        "Gift Card", //FALSE
        "SEO Title", //NOMBRE DEL PRODUCTO - 70 characters or less
        "SEO Description", //DESCRIPCION PRODUCTO - 320 characters or less
        "Google Shopping / Google Product Category", //''
        "Google Shopping / Gender", //''
        "Google Shopping / Age Group", //''
        "Google Shopping / MPN", //''
        "Google Shopping / AdWords Grouping", //''
        "Google Shopping / AdWords Labels", //''
        "Google Shopping / Condition", //''
        "Google Shopping / Custom Product", //''
        "Google Shopping / Custom Label 0", //''
        "Google Shopping / Custom Label 1", //''
        "Google Shopping / Custom Label 2", //''
        "Google Shopping / Custom Label 3", //''
        "Google Shopping / Custom Label 4", //''
        "Variant Image", //''
        "Variant Weight Unit", //''
        "Variant Tax Code", //''
        "Cost per item", //suggedted price creo
        "Price / International", //''
        "Compare At Price / International", //''
        "Status" //active
      ];

      // for (var i = 0; i < headers.length; i++) {
      //   var cell =
      //       sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      //   cell.value = headers[i];
      // }

      //
      Map<String, dynamic> data = {
        "Handle": productName,
        "Title": productName,
        "Body (HTML)": description,
        "Vendor": product.warehouse?.branchName,
        "Product Category": product.productName.toString(), //Category
        "Type": type,
        "Tags": "",
        "Published": "FALSE",
        "Option1 Name": "",
        "Option1 Value": "",
        "Option2 Name": "",
        "Option2 Value": "",
        "Option3 Name": "",
        "Option3 Value": "",
        "Variant SKU": skuFinal,
        "Variant Grams": "",
        "Variant Inventory Tracker": "",
        "Variant Inventory Qty": "",
        "Variant Inventory Policy": "deny",
        "Variant Fulfillment Service": "manual",
        "Variant Price": product.price.toString(),
        "Variant Compare At Price": suggestedPrice,
        "Variant Requires Shipping": "",
        "Variant Taxable": "TRUE",
        "Variant Barcode": "TRUE",
        "Image Src": "url-firstImg",
        "Image Position": "1",
        "Image Alt Text": "",
        "Gift Card": "FALSE",
        "SEO Title": productName,
        "SEO Description": productName,
        "Google Shopping / Google Product Category": "",
        "Google Shopping / Gender": "",
        "Google Shopping / Age Group": "",
        "Google Shopping / MPN": "",
        "Google Shopping / AdWords Grouping": "",
        "Google Shopping / AdWords Labels": "",
        "Google Shopping / Condition": "",
        "Google Shopping / Custom Product": "",
        "Google Shopping / Custom Label 0": "",
        "Google Shopping / Custom Label 1": "",
        "Google Shopping / Custom Label 2": "",
        "Google Shopping / Custom Label 3": "",
        "Google Shopping / Custom Label 4": "",
        "Variant Image": "",
        "Variant Weight Unit": "",
        "Variant Tax Code": "",
        "Cost per item": suggestedPrice,
        "Price / International": "",
        "Compare At Price / International": "",
        "Status": "active"
      };

      data.keys.forEach((key) {
        int columnIndex = data.keys.toList().indexOf(key);
        sheet
            .cell(CellIndex.indexByColumnRow(
                columnIndex: columnIndex, rowIndex: 0))
            .value = key;
      });

// Llenar los datos
      data.forEach((key, value) {
        int columnIndex = data.keys.toList().indexOf(key);
        if (columnIndex != -1) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                  columnIndex: columnIndex, rowIndex: 1))
              .value = value;
        }
      });

      //
      var nameFile = "$productName-EasyEcommerce";
      excel.save(fileName: '${nameFile}.xlsx');
    } catch (e) {
      print("Error en Generar el reporte! $e");
    }
  }

  Future<void> generateCsvFileProductSimple(dataProduct) async {
    try {
      // print("It's simple");
      ProductModel product = dataProduct;
      String productName = product.productName.toString();

      // Decodificar el JSON
      Map<String, dynamic> features = jsonDecode(product.features);

      String suggestedPrice = features["price_suggested"].toString();
      String sku = features["sku"];
      String skuFinal = "";
      String description = features["description"];
      String type = features["type"];
      List<dynamic> categories = features["categories"];
      List<String> categoriesId =
          categories.map((item) => item["id"].toString()).toList();

      List<String> urlsImgsList = product.urlImg != null &&
              product.urlImg.isNotEmpty &&
              product.urlImg.toString() != "[]"
          ? (jsonDecode(product.urlImg) as List).cast<String>()
          : [];

      // String firstImg = urlsImgsList[0];
      String firstImg = "$generalServer${urlsImgsList[0]}";
      // print("firstImg: $firstImg");
      String firstCategory = categoriesId[0].toString();
      // print("firstCategory: $firstCategory");

      skuFinal = "${sku}C${product.productId.toString()}";

      //
      Map<String, dynamic> data = {
        "Handle": '$productName',
        "Title": '$productName',
        "Body (HTML)": '$description',
        "Vendor": product.warehouse?.branchName,
        "Product Category": firstCategory,
        "Type": type,
        "Tags": "",
        "Published": "TRUE",
        "Option1 Name": "",
        "Option1 Value": "",
        "Option2 Name": "",
        "Option2 Value": "",
        "Option3 Name": "",
        "Option3 Value": "",
        "Variant SKU": skuFinal,
        "Variant Grams": "",
        "Variant Inventory Tracker": "",
        "Variant Inventory Qty": "",
        "Variant Inventory Policy": "deny",
        "Variant Fulfillment Service": "manual",
        "Variant Price": suggestedPrice,
        "Variant Compare At Price": "",
        "Variant Requires Shipping": "",
        "Variant Taxable": "TRUE",
        "Variant Barcode": "TRUE",
        "Image Src": firstImg,
        "Image Position": "1",
        "Image Alt Text": "",
        "Gift Card": "FALSE",
        "SEO Title": '$productName',
        "SEO Description": '$productName',
        "Google Shopping / Google Product Category": "",
        "Google Shopping / Gender": "",
        "Google Shopping / Age Group": "",
        "Google Shopping / MPN": "",
        "Google Shopping / AdWords Grouping": "",
        "Google Shopping / AdWords Labels": "",
        "Google Shopping / Condition": "",
        "Google Shopping / Custom Product": "",
        "Google Shopping / Custom Label 0": "",
        "Google Shopping / Custom Label 1": "",
        "Google Shopping / Custom Label 2": "",
        "Google Shopping / Custom Label 3": "",
        "Google Shopping / Custom Label 4": "",
        "Variant Image": "",
        "Variant Weight Unit": "",
        "Variant Tax Code": "",
        "Cost per item": suggestedPrice,
        "Price / International": "",
        "Compare At Price / International": "",
        "Status": "active"
      };

      //
      var nameFile = "$productName-EasyEcommerce";
      List<List<dynamic>> csvData = [
        data.keys.toList(), // Encabezados (keys)
        data.values.toList(), // Datos
      ];

      String data4cvs = const ListToCsvConverter().convert(
        [
          csvData[0],
          csvData[1],
        ],
      );

      Uint8List bytes = Uint8List.fromList(utf8.encode(data4cvs));

      await FileSaver.instance.saveFile(
        name: nameFile,
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );
      //
    } catch (e) {
      print("Error en Generar el reporte! $e");
    }
  }

  Future<void> generateCsvFileProductVariant(dataProduct) async {
    try {
      // print("It's varaible");
      ProductModel product = dataProduct;
      String productName = product.productName.toString();
      String vendor = product.warehouse!.branchName.toString();
      // Decodificar el JSON
      Map<String, dynamic> features = jsonDecode(product.features);

      String suggestedPrice = features["price_suggested"].toString();
      String sku = features["sku"];
      String skuFinal = "";
      String description = features["description"];
      String type = features["type"];
      List<dynamic> categories = features["categories"];
      List<String> categoriesId =
          categories.map((item) => item["id"].toString()).toList();

      List<String> urlsImgsList = product.urlImg != null &&
              product.urlImg.isNotEmpty &&
              product.urlImg.toString() != "[]"
          ? (jsonDecode(product.urlImg) as List).cast<String>()
          : [];

      // String firstImg = urlsImgsList[0];
      String firstImg = "$generalServer${urlsImgsList[0]}";
      String firstCategory = categoriesId[0].toString();

      List<String> skuValues = [];
      String finalOptions = "";
      List<String> variantsValue = [];
      if (product.isvariable == 1) {
        List<dynamic> options = features["options"];

        for (var option in options) {
          String name = option["name"].toString();
          finalOptions += name;

          if (options.last != option) {
            finalOptions += "/";
          }
        }

        List<dynamic> variants = features["variants"];

        for (var variant in variants) {
          skuValues.add("${variant["sku"]}C${product.productId.toString()}");

          List<String> fields = ["size", "color", "dimension"];
          List<String> variantValues = [];

          for (var field in fields) {
            String value = variant[field] ?? "";

            if (value.isNotEmpty) {
              variantValues.add(value);
            }
          }

          if (variantValues.isNotEmpty) {
            variantsValue.add(variantValues.join("/"));
          }
        }
      }

      // print("skuValues: $skuValues");
      // print("finalOptions: $finalOptions");
      // print("variantsValue: $variantsValue");

      //
      List<String> headers = [
        "Handle",
        "Title",
        "Body (HTML)",
        "Vendor",
        "Product Category",
        "Type",
        "Tags",
        "Published",
        "Option1 Name",
        "Option1 Value",
        "Option2 Name",
        "Option2 Value",
        "Option3 Name",
        "Option3 Value",
        "Variant SKU",
        "Variant Grams",
        "Variant Inventory Tracker",
        "Variant Inventory Qty",
        "Variant Inventory Policy",
        "Variant Fulfillment Service",
        "Variant Price",
        "Variant Compare At Price",
        "Variant Requires Shipping",
        "Variant Taxable",
        "Variant Barcode",
        "Image Src",
        "Image Position",
        "Image Alt Text",
        "Gift Card",
        "SEO Title",
        "SEO Description",
        "Google Shopping / Google Product Category",
        "Google Shopping / Gender",
        "Google Shopping / Age Group",
        "Google Shopping / MPN",
        "Google Shopping / AdWords Grouping",
        "Google Shopping / AdWords Labels",
        "Google Shopping / Condition",
        "Google Shopping / Custom Product",
        "Google Shopping / Custom Label 0",
        "Google Shopping / Custom Label 1",
        "Google Shopping / Custom Label 2",
        "Google Shopping / Custom Label 3",
        "Google Shopping / Custom Label 4",
        "Variant Image",
        "Variant Weight Unit",
        "Variant Tax Code",
        "Cost per item",
        "Price / International",
        "Compare At Price / International",
        "Status"
      ];

      List<List<String>> dataRows = [headers];

      for (var i = 0; i < variantsValue.length; i++) {
        List<String> dataVariant = [];

        if (i == 0) {
          dataVariant = [
            "$productName",
            "$productName",
            '$description',
            vendor,
            firstCategory,
            type,
            "",
            "TRUE",
            finalOptions,
            variantsValue[i],
            "",
            "",
            "",
            "",
            skuValues[i],
            "",
            "",
            "",
            "deny",
            "manual",
            suggestedPrice,
            "",
            "",
            "TRUE",
            "TRUE",
            firstImg,
            "1",
            "",
            "FALSE",
            '$productName',
            '$productName',
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            suggestedPrice,
            "",
            "",
            "active"
          ];
        } else {
          dataVariant = [
            "$productName",
            "$productName",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            variantsValue[i],
            "",
            "",
            "",
            "",
            skuValues[i],
            "",
            "",
            "",
            "deny",
            "manual",
            suggestedPrice,
            "",
            "",
            "TRUE",
            "TRUE",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            suggestedPrice,
            "",
            "",
            "active"
          ];
        }
        dataRows.add(dataVariant);
      }

      //
      var nameFile = "$productName-EasyEcommerce";

      String data4cvs = const ListToCsvConverter().convert(dataRows);
      Uint8List bytes = Uint8List.fromList(utf8.encode(data4cvs));

      await FileSaver.instance.saveFile(
        name: nameFile,
        bytes: bytes,
        ext: 'csv',
        mimeType: MimeType.csv,
      );
      //
    } catch (e) {
      print("Error en Generar el reporte! $e");
    }
  }

  String csvExample = const ListToCsvConverter().convert(
    [
      ["Column1", "Column2"],
      ["Column1", "Column2"],
      ["Column1", "Column2"],
    ],
  );

  // Download and save CSV to your Device
  downloadCSV() async {
    // Convert your CSV string to a Uint8List for downloading.
    Uint8List bytes = Uint8List.fromList(utf8.encode(csvExample));

    // This will download the file on the device.
    await FileSaver.instance.saveFile(
      name: 'document_name', // you can give the CSV file name here.
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  }

  String getFirstImgUrl(dynamic urlImgData) {
    List<String> urlsImgsList = (jsonDecode(urlImgData) as List).cast<String>();
    String url = urlsImgsList[0];
    return url;
  }

  String getFirstCategory(dynamic urlImgData) {
    List<String> urlsImgsList = (jsonDecode(urlImgData) as List).cast<String>();
    String url = urlsImgsList[0];
    return url;
  }
}
