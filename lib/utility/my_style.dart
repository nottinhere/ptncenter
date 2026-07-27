import 'package:flutter/material.dart';

class MyStyle {
  double h1 = 24.0, h2 = 18.0;

  // Brand palette (modern pharmacy-shopping green)
  Color mainColor = Color(0xFF12A669);
  Color textColor = Color(0xFF0B6B41);
  Color lightColor = Color(0x2612A669);
  Color bgColor = Color(0xFF12A669);
  Color barColor = Color(0xFF12A669);

  // Extended design-system tokens
  Color primaryDark = Color(0xFF0B7A4C);
  Color primaryLight = Color(0xFFE6F7EF);
  Color scaffoldBackground = Color(0xFFF6F8F7);
  Color surfaceColor = Colors.white;
  Color mutedTextColor = Color(0xFF667085);
  Color borderColor = Color(0xFFE4E7EC);
  Color alertColor = Color(0xFFE5484D);
  Color warningColor = Color(0xFFF59E0B);

  double radiusS = 10.0;
  double radiusM = 16.0;
  double radiusL = 24.0;

  EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16.0);

  // Soft pastel tints used behind quick-access icons for visual variety
  List<Color> tileTints = [
    Color(0xFFE6F7EF),
    Color(0xFFE8F1FF),
    Color(0xFFFFF4E5),
    Color(0xFFFDE8EF),
    Color(0xFFF3ECFF),
    Color(0xFFFFF9DB),
  ];
  List<Color> tileIconColors = [
    Color(0xFF12A669),
    Color(0xFF2E6BE6),
    Color(0xFFE8890C),
    Color(0xFFE0507A),
    Color(0xFF8250DF),
    Color(0xFFC79000),
  ];

  BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16.0),
    boxShadow: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 12.0,
        offset: Offset(0, 4),
      ),
    ],
  );

  TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0B6B41),
  );

  TextStyle tileLabelStyle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: Color(0xFF344054),
  );

  TextStyle captionStyle = TextStyle(
    fontSize: 13.0,
    color: Color(0xFF667085),
  );

  TextStyle h1Style = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0B6B41),
  );

  TextStyle h2Style = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0B6B41),
  );

  TextStyle h3bStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0B6B41),
  );
  TextStyle h3Style = TextStyle(
    fontSize: 16.0,
    // fontWeight: FontWeight.bold,
    color: Color(0xFF0B6B41),
  );

  TextStyle h3bStyleGreen = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF0B6B41),
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
    color: Color(0x2612A669),
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

  String? serverName = 'https://ptnpharma.com';


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
