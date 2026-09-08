import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/orn_model.dart';
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';

/// รวม logic "สแกนบาร์โค้ด -> ค้นหาสินค้าด้วย bqcode -> แสดงผล" ที่เดิมก็อปวางซ้ำกัน
/// ในหลายหน้า (list_product.dart, list_product_favorite.dart,
/// list_product_promotion.dart, home.dart)
///
/// หน้าที่ mix-in ต้อง implement [onProductFound] เพื่อกำหนดเองว่าจะพาไปหน้าไหนต่อ
/// เมื่อเจอสินค้า
mixin ProductBarcodeScannerMixin<T extends StatefulWidget> on State<T> {
  void onProductFound(ProductAllModel product);

  Future<void> readQRcodePreview() async {
    try {
      var qrScanString = await BarcodeScanner.scan();
      String qrString = qrScanString.rawContent;
      if (qrString != '') {
        decodeQRcode(qrString);
      }
    } on PlatformException {} // ignore: empty_catches
  }

  Future<void> decodeQRcode(String code) async {
    try {
      if (code != '') {
        String url =
            '${MyStyle().serverName}/json_productlist.php?bqcode=$code';
        http.Response response = await http.get(Uri.parse(url));
        if (!mounted) return;
        var result = json.decode(response.body);

        int status = result['status'];
        if (status == 0) {
          normalDialog(context, 'Not found', 'ไม่พบ code :: $code ในระบบ');
        } else {
          var itemProducts = result['itemsProduct'];
          for (var map in itemProducts) {
            ProductAllModel productAllModel = ProductAllModel.fromJson(map);
            onProductFound(productAllModel);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ค้นหาสินค้าไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
  }
}

/// รวม logic "สแกนบาร์โค้ด -> ค้นหาใบส่งของ/ออเดอร์ (ORN) -> แสดงผล" ที่เดิมก็อปวางซ้ำกัน
/// ในหลายหน้า (orn_list.dart, orn_listproduct.dart, payment_orn.dart,
/// payment_ornlist.dart)
///
/// หน้าที่ mix-in ต้อง implement [scannerMemberId] (member id สำหรับยิง query)
/// และ [onOrnFound] เพื่อกำหนดเองว่าจะพาไปหน้าไหนต่อเมื่อเจอ ORN
mixin OrnBarcodeScannerMixin<T extends StatefulWidget> on State<T> {
  String? get scannerMemberId;

  void onOrnFound(OrnModel orn);

  Future<void> readQRcodeORNPreview() async {
    try {
      var qrScanString = await BarcodeScanner.scan();
      String qrString = qrScanString.rawContent;
      if (qrString != '') {
        decodeQRcodeORN(qrString);
      }
    } on PlatformException {} // ignore: empty_catches
  }

  Future<void> decodeQRcodeORN(String code) async {
    try {
      if (code != '') {
        String? memberId = scannerMemberId;
        String url = '${MyStyle().serverName}/json_ornlist.php'
            '?memberId=$memberId&code=$code';
        http.Response response = await http.get(Uri.parse(url));
        if (!mounted) return;
        var result = json.decode(response.body);

        int? status = result['status'];
        String title = 'ข้อมูลไม่ถูกต้อง';
        String? message = result['message'];
        if (status == 0) {
          AwesomeDialog(
            context: context,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            autoHide: const Duration(seconds: 4),
            title: title,
            desc: message,
            btnOkColor: Colors.red,
            btnOkOnPress: () {},
            btnOkIcon: Icons.check_circle,
          ).show();
        } else {
          var mapItemScanOrn = result['itemsData'];
          OrnModel? ornScanAllModel;
          for (var map in mapItemScanOrn) {
            ornScanAllModel = OrnModel.fromJson(map);
          }
          if (ornScanAllModel != null) {
            onOrnFound(ornScanAllModel);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ค้นหาข้อมูลไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
  }
}
