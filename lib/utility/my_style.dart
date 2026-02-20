import 'package:flutter/material.dart';

class MyStyle {
  double h1 = 24.0, h2 = 18.0;
  Color mainColor =
      Color.fromARGB(0xff, 0x2c, 0xb5, 0x1b); // (0xff, 0x31, 0xa3, 0x51);
  Color textColor = Color.fromARGB(0xff, 0x00, 0x73, 0x26);
  Color lightColor = Color.fromARGB(0x68, 0x00, 0xd5, 0x7f);
  Color bgColor =
      Color.fromARGB(0xff, 0x2c, 0xb5, 0x1b); // (0xff, 0x31, 0xa3, 0x51);
  Color barColor =
      Color.fromARGB(0xff, 0x2c, 0xb5, 0x1b); // (0xff, 0x00, 0x73, 0x26);

  TextStyle h1Style = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
  );

  TextStyle h2Style = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
  );

  TextStyle h3bStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
  );
  TextStyle h3Style = TextStyle(
    fontSize: 16.0,
    // fontWeight: FontWeight.bold,
    color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
  );

  TextStyle h3bStyleGreen = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
  );

  TextStyle h3StyleGray = TextStyle(
    fontSize: 16.0,
    // fontWeight: FontWeight.bold,
    color: Colors.grey.shade900,
  );

  TextStyle h3bStyleGray = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade900,
  );

  TextStyle h3bStyleRed = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(0xff, 0xff, 0x99, 0x99),
  );

  TextStyle h3bStyleOrange = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.orange,
  );

  TextStyle h3StyleRed = TextStyle(
    fontSize: 16.0,
    color: Colors.red,
  );

  TextStyle h3StyleOrange = TextStyle(
    fontSize: 16.0,
    color: Colors.orange.shade700,
  );

  TextStyle h3StyleBlue = TextStyle(
    fontSize: 16.0,
    color: Colors.blue,
  );

  TextStyle h4StyleBlue = TextStyle(
    fontSize: 14.0,
    color: Colors.blue,
  );

  TextStyle h4bStyleGray = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade900,
  );

  TextStyle h4StyleGray = TextStyle(
    fontSize: 14.0,
    color: Colors.grey.shade900,
  );

  TextStyle h4bStyleRed = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: Colors.red,
  );

  TextStyle h4StyleRed = TextStyle(
    fontSize: 14.0,
    color: Colors.red,
  );

  TextStyle h5StyleRed = TextStyle(
    fontSize: 11.0,
    color: Colors.red,
  );
  TextStyle h5StyleGreen = TextStyle(
    fontSize: 11.0,
    color: Colors.green,
  );
  TextStyle h5StyleBlue = TextStyle(
    fontSize: 11.0,
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  );

  BoxDecoration boxLightGreen = BoxDecoration(
    borderRadius: BorderRadius.circular(12.0),
    color: Color.fromARGB(0x68, 0x00, 0xd5, 0x7f),
  );

  BoxDecoration boxLightGray = BoxDecoration(
    borderRadius: BorderRadius.circular(5.0),
    color: Colors.grey.shade200,
  );

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 16.0,
    );
  }

  String fontName = 'Sarabun';

  String readAllProduct =
      'https://www.ptnpharma.com/apishop/json_productlist.php?top=100';
  String readProductWhereMode =
      'https://www.ptnpharma.com/apishop/json_productlist.php?searchKey=';
  String getUserWhereUserAndPass =
      'https://www.ptnpharma.com/apishop/json_login.php';
  String getProductWhereId =
      'https://www.ptnpharma.com/apishop/json_productdetail.php?id=';

  String loadMyCart =
      'https://www.ptnpharma.com/apishop/json_loadmycart.php?memberId='; //  json_loadmycart_gift.php

  MyStyle();
}
