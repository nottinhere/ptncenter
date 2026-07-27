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

import 'package:ptncenter/scaffold/orn_list.dart';
import 'package:ptncenter/scaffold/detail_orn.dart';
import 'package:ptncenter/scaffold/orn_listproduct.dart';
import 'package:ptncenter/scaffold/payment_orn.dart';


import 'package:ptncenter/scaffold/detail_cart.dart';
import 'my_service.dart';

import 'package:ptncenter/widget/home.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MenuOrn extends StatefulWidget {
  final String? ornID;
  final UserModel? userModel;

  MenuOrn(
      {Key? key,this.ornID, this.userModel})
      : super(key: key);

  @override
  _MenuOrnState createState() => _MenuOrnState();
}

class _MenuOrnState extends State<MenuOrn> {
  // Explicit

  ScrollController scrollController = ScrollController();

  int? banerIndex = 0;
  int? suggestIndex = 0;
  UserModel? myUserModel;

  OrnModel? currentOrnAllModel;
  OrnModel? ornAllModel;

  List<OrnModel> ornAllModels = []; // []; // set array
  List<OrnModel> filterOrnAllModels = []; // []; //
  int?  myshippingItem;

  String? id; // ornID

  String? qrString;
  int? currentIndex = 0;
  UserModel? userModel;
  String? currentOrnID;
  int? selectIndex = 2;

  // Method
  @override
  void initState() {
    super.initState();
    currentOrnID = widget.ornID;
    myUserModel = widget.userModel;
    setState(() {
      getOrnWhereID();
    });
  }


  Future<void> getOrnWhereID() async {
      String? staffID = myUserModel!.id.toString();
      id = currentOrnID.toString();
      String? url =
      '${MyStyle().serverName}/apipacking/json_ornlist.php?memberId=$staffID&ornId=$id';
    
    print("URL (orn detail)= $url");
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemOrn = result['itemsData']; 
    for (var map in mapItemOrn) {
      setState(() {
              ornAllModel = OrnModel.fromJson(map);
              var valbox = (ornAllModel!.shippingBox==0 || ornAllModel!.shippingBox =='-')?ornAllModel!.box!:ornAllModel!.shippingBox!;

      });
    } // for
  }

  Widget profileBox() {
    String? login = myUserModel!.name;
    String? address = myUserModel!.address;
    // int loginStatus = myUserModel.status;

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Color.fromARGB(255, 255, 255, 255),
          child: Container(
            padding: EdgeInsets.all(7.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                    width: 45.0,
                    child: Image.asset('images/icon_user.png'),
                    padding: EdgeInsets.only(right: 8.0)),
                Column(
                  children: [
                    Text(
                      '$login', // 'ผู้แทน : $login',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      '$address', // 'ผู้แทน : $login',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click profile');
          // routeToListProduct(0);
        },
      ),
    );
  }


   Widget ornBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.yellow.shade600,
              width: 2,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_vote.png'),
                ),
                Text(
                  'List ORN',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click vote list');
          // MaterialPageRoute materialPageRoute =
          //     MaterialPageRoute(builder: (BuildContext buildContext) {
          //   return OrnList(
          //     userModel: myUserModel!,
          //   );
          // });
          // Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }


  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Colors.blueGrey.shade100,
          width: 1.0,
        ),
      ),
    );
  }



  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 30.0,
    );
  }



  Widget infoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.32,
            child: Text(label, style: MyStyle().h4bStyleGray),
          ),
          Expanded(
            child: Text(value, style: valueStyle ?? MyStyle().h3Style),
          ),
        ],
      ),
    );
  }

  Map<String, String> getStatusDisplay(String? statusValue) {
    final value = statusValue?.toString().trim() ?? '';

    switch (value) {
      case '0':
        return {'text': '', 'color': 'red'};
      case '1':
        return {'text': 'รอเพิ่มยา', 'color': '#008285'};
      case '2':
        return {'text': 'รอเพิ่มค่าขนส่ง', 'color': 'orange'};
      case '6':
        return {'text': 'รอหัก cn / รวมบิล', 'color': 'red'};
      case '3':
        return {'text': 'รอชำระเงิน', 'color': 'red'};
      case '4':
        return {'text': 'รอตรวจสอบ', 'color': '#d69e02'};
      case '5':
        return {'text': 'ชำระแล้ว', 'color': 'green'};
      case '7':
        return {'text': 'ยกเลิกโดยผู้ดูแล', 'color': '#d17f79'};
      case '8':
        return {'text': 'ระหว่างจัดส่ง', 'color': 'green'};
      case '9':
        return {'text': 'จัดส่งแล้ว', 'color': 'green'};
      default:
        return {'text': value, 'color': 'black'};
    }
  }

  Color parseStatusColor(String? colorName) {
    final value = colorName?.toLowerCase() ?? 'black';

    switch (value) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'black':
        return Colors.black;
      default:
        if (value.startsWith('#') && value.length == 7) {
          return Color(int.parse(value.substring(1), radix: 16) + 0xFF000000);
        }
        return Colors.black;
    }
  }

  String formatNumber(String? value) {
    if (value == null || value.toString().trim().isEmpty) {
      return '';
    }

    final cleaned = value.toString().trim().replaceAll(RegExp(r'[^0-9.-]'), '');
    if (cleaned.isEmpty) {
      return '';
    }

    final number = double.tryParse(cleaned);
    if (number == null) {
      return value.toString().trim();
    }

    final parts = number.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '$integerPart.${parts[1]}';
  }

  Widget ornInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            infoRow(
              'สถานะ :',
              getStatusDisplay(ornAllModel?.status)['text'] ?? '',
              valueStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: parseStatusColor(
                  getStatusDisplay(ornAllModel?.status)['color'],
                ),
              ),
            ),
            // infoRow(
            //   'รหัสลูกค้า :',
            //   ornAllModel?.customerCode ?? '',
            //   valueStyle: MyStyle().h3bStyle,
            // ),
            // infoRow(
            //   'ร้านค้า :',
            //   ornAllModel?.shopname ?? '',
            //   valueStyle: MyStyle().h3Style,
            // ),
            infoRow(
              'เลขที่ใบส่งของ :',
              ornAllModel?.ornNo ?? '',
              valueStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            infoRow(
              'จำนวนกล่อง :',
              '${ornAllModel?.box ?? ''} กล่อง',
              valueStyle: MyStyle().h3StyleRed,
            ),
            infoRow(
              'หมายเหตุ :',
              ornAllModel?.note ?? '',
            ),
            infoRow(
              'ยอดรวม :',
              '${formatNumber(ornAllModel?.amount)} บาท',
              valueStyle: MyStyle().h3StyleBlue,
            ),
            ornAllModel?.shipping != null && ornAllModel?.shipping != '0' ? infoRow(
              'ค่าขนส่ง :',
              '${formatNumber(ornAllModel?.shipping)} บาท',
              valueStyle: MyStyle().h3StyleBlue,
            ) : Container(),
            ornAllModel?.cn != null && ornAllModel?.cn != '0' ? infoRow(
              'ยาคืน :',
              '${formatNumber(ornAllModel?.cn)} บาท',
            ) : Container(),
            infoRow(
              'ยอดชำระ :',
              '${formatNumber(ornAllModel?.total)} บาท',
              valueStyle: MyStyle().h3bStyleRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget actionButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 6.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(Icons.description_outlined, color: Colors.white),
              label:
                  Text('รายการสินค้า', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListProductOrn(
                      userModel: myUserModel,
                      ornId: currentOrnID,
                      ornNo: ornAllModel?.ornNo,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Expanded(
        //   child: Padding(
        //     padding: EdgeInsets.only(left: 6.0),
        //     child: ElevatedButton.icon(
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: MyStyle().bgColor,
        //         textStyle: TextStyle(
        //           color: Colors.white,
        //           fontSize: 16,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //       icon: Icon(Icons.payment, color: Colors.white),
        //       label: Text('ชำระเงิน', style: TextStyle(color: Colors.white)),
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => PaymentOrn(
        //               userModel: myUserModel,
        //               ornId: currentOrnID,
        //             ),
        //           ),
        //         );
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }




  // Widget submitButton() {
  //   print('submitButton -> ${ornAllModel!.box}');
  //   String? staffID = myUserModel!.id.toString();
  //   id = currentOrnID.toString();
  //   String? shipId = myshippingItem!.toString();

  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.80,
  //     child: Row(
  //        mainAxisAlignment: MainAxisAlignment.end,
  //       children: [
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             fixedSize: const Size.fromWidth(110),
  //             backgroundColor: const Color.fromARGB(255, 255, 72, 72), // Set the background color
  //             foregroundColor: Colors.white, // Set the text color
  //             shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(6)),
  //             textStyle: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 20),
  //           ),
  //           child: Text('ยกเลิก'),
  //           onPressed: () {
  //             Navigator.pop(context);            },
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             fixedSize: const Size.fromWidth(190),
  //             backgroundColor: Colors.teal, // Set the background color
  //             foregroundColor: Colors.white, // Set the text color
  //             shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(6)),
  //             textStyle: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 20),
  //           ),
  //           child: Text('ยืนยัน'),
  //           onPressed: () {
  //             // orderAllModels = [];
  //             // print('transport = $transport, deliver = $deliver');
  //             // readData(); //
  //             print('ยืนยันจำนวนกล่อง');
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget timelineStep({
    required String label,
    String? date,
    required bool isLast,
  }) {
    bool done = date != null && date != '-';
    Color color = done ? MyStyle().mainColor : Colors.grey.shade400;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                color: color,
                size: 22.0,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.0,
                    color: done ? MyStyle().mainColor : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: done ? Colors.black87 : Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    done ? date! : 'รอดำเนินการ',
                    style: MyStyle().h4StyleGray,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget statusBox() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('สถานะการจัดส่ง', style: MyStyle().h3bStyle),
            SizedBox(height: 12.0),
            timelineStep(
              label: 'วันที่สั่งซื้อ',
              date: ornAllModel?.datepost,
              isLast: false,
            ),
            timelineStep(
              label: 'เริ่มจัดส่งสินค้า',
              date: ornAllModel?.shippingOrndate,
              isLast: false,
            ),
            timelineStep(
              label: 'นำส่งสำเร็จ',
              date: ornAllModel?.deliveryDate,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget stylishBottomBar() {
    int? unread =
        myUserModel!.lastNewsId!.toInt() - myUserModel!.lastNewsOpen!.toInt();
    return StylishBottomBar(
      option: AnimatedBarOptions(
        iconStyle: IconStyle.animated,
        opacity: 0.3,
      ),
      items: [
        BottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text('Home'),
          backgroundColor: Colors.blue,
          // selectedIcon: const Icon(Icons.home),
        ),
        BottomBarItem(
          icon: const Icon(Icons.medical_services),
          title: const Text('Medicine'),
          backgroundColor: Colors.green,
        ),
        BottomBarItem(
          icon: const Icon(Icons.fact_check_rounded),
          title: const Text('ORN'),
          backgroundColor: Colors.red,
        ),
        BottomBarItem(
          icon: const Icon(Icons.qr_code_scanner),
          title: const Text('Scan'),
          backgroundColor: Colors.brown,
        ),
      ],
      // fabLocation: StylishBarFabLocation.end,
      hasNotch: true,
      currentIndex: selectIndex!,
      onTap: (index) {
        setState(() {
          selectIndex = index;
          // controller.jumpToPage(index);
          if (index == 0) {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => MyService(
                userModel: myUserModel,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            // routeToListProduct(0);
          } else if (index == 2) {
            MaterialPageRoute materialPageRoute =
                MaterialPageRoute(builder: (BuildContext buildContext) {
              return OrnList(
                userModel: myUserModel!,
              );
            });
            Navigator.of(context).push(materialPageRoute);
          } else if (index == 3) {
            // routeToDetailCart();
          }
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().bgColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('ข้อมูลใบส่งของ', style: TextStyle(color: Colors.white)),
      ),
      body: (ornAllModel == null)
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ornInfoCard(),
                  SizedBox(height: 20.0),
                  statusBox(),
                  SizedBox(height: 20.0),
                  actionButtons(),
                ],
              ),
            ),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }




}

