import 'dart:convert';
import 'dart:async';
// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/orn_model.dart';


import 'package:ptncenter/scaffold/authen.dart';
import 'package:ptncenter/scaffold/detail.dart';

import 'package:ptncenter/scaffold/detail_orn.dart';


import 'package:ptncenter/scaffold/detail_cart.dart';
import 'my_service.dart';

import 'package:ptncenter/widget/home.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class Shipping extends StatefulWidget {
//   @override
//   _ShippingState createState() => _ShippingState();
// }

// class _ShippingState extends State<Shipping> {

// }