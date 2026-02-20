import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/promote_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/authen.dart';
import 'package:ptncenter/scaffold/detail.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';

import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
// import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';

// import 'package:flutter_ui_challenges/core/presentation/res/assets.dart';

class HomeScreen extends StatefulWidget {
  final UserModel? userModel;

  HomeScreen({Key? key, this.userModel}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Explicit
  // List<PromoteModel> promoteModels;
  List<Widget>? promoteLists;
  List<Widget>? suggestLists;
  List<String>? urlImages;
  List<String>? urlImagesSuggest;
  List<String>? productsName;

  int? amontCart = 0;
  int banerIndex = 0;
  int suggestIndex = 0;
  UserModel? myUserModel;
  List<ProductAllModel>? promoteModels;
  List<ProductAllModel>? suggestModels;
  String? qrString;
  int? currentIndex = 0;
  String? _result = '';

  // Method
  @override
  void initState() {
    super.initState();

    readPromotion();
    myUserModel = widget.userModel;
    readSuggest();
  }

  Future<void> readPromotion() async {
    String? url = 'http://www.ptnpharma.com/apishop/json_promotion.php';
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel? promoteModel = PromoteModel.fromJson(map);
      ProductAllModel? productAllModel = ProductAllModel.fromJson(map);
      String? urlImage = promoteModel.photo;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        promoteModels!.add(productAllModel);
        promoteLists!.add(showImageNetWork(urlImage!));
        urlImages!.add(urlImage);
      });
    }
  }

  Image showImageNetWork(String? urlImage) {
    return Image.network(urlImage!);
  }

  Future<void> readSuggest() async {
    String? memId = myUserModel!.id;
    String? url =
        'http://www.ptnpharma.com/apishop/json_suggest.php?memberId=$memId'; // ?memberId=$memberId
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel promoteModel = PromoteModel.fromJson(map);
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      String? urlImage = promoteModel.photo;
      String? productName = promoteModel.title;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        suggestModels!.add(productAllModel);
        suggestLists!.add(Image.network(urlImage!));
        urlImagesSuggest!.add(urlImage);
        productsName!.add(productName!);
      });
    }
  }

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showCarouseSlider() {
    return GestureDetector(
      onTap: () {
        print('You Click index is $banerIndex');

        MaterialPageRoute route = MaterialPageRoute(
          builder: (BuildContext context) => Detail(
            productAllModel: promoteModels![banerIndex],
            userModel: myUserModel,
          ),
        );
        // Navigator.of(context).push(route).then((value) {});  //  link to detail page
      },
      child: CarouselSlider(
        options: CarouselOptions(
          height: 1200,
          viewportFraction: 0.8,
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          // pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlay: true,
          autoPlayAnimationDuration: Duration(seconds: 5),
          onPageChanged: (int index, reason) {
            banerIndex = index;
            Text('x');
            // print('index = $index');
          },
        ),
        items: promoteLists,
      ),
    );
  }

  Widget showCarouseSliderSuggest() {
    int indexSlide = 0;
    return GestureDetector(
      onTap: () {
        print('You Click index is $suggestIndex');

        MaterialPageRoute route = MaterialPageRoute(
          builder: (BuildContext context) => Detail(
            productAllModel: suggestModels![suggestIndex],
            userModel: myUserModel,
          ),
        );
        Navigator.of(context).push(route).then((value) {});
      },
      child: CarouselSlider(
        options: CarouselOptions(
          height: 350.0,
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          // pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlay: true,
          autoPlayAnimationDuration: Duration(seconds: 5),
          onPageChanged: (int index, reason) {
            suggestIndex = index;
            // print('index = $index');
          },
        ),
        // items: suggestLists,
        items: suggestLists!
            .map((item) => Container(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Container(
                          // width: MediaQuery.of(context).size.width * 0.50,
                          height: 135.00,
                          child: item,
                          padding: EdgeInsets.all(8.0),
                        ),
                        Text(
                          productsName![indexSlide++].toString(),
                          style: TextStyle(
                              fontSize: 12,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.grey.shade200,
                ))
            .toList(),
      ),
    );
  }

  Widget promotion() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        height: MediaQuery.of(context).size.width * 0.70, // size.height * 0.20,
        child: promoteLists!.length == 0
            ? myCircularProgress()
            : showCarouseSlider(),
      ),
    );
  }

  Widget suggest() {
    return Card(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.25,
        child: suggestLists!.length == 0
            ? myCircularProgress()
            : showCarouseSliderSuggest(),
      ),
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget orderhistoryBox() {
    String? login = myUserModel!.name;
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.greenAccent.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_drugs.png'),
                  padding: EdgeInsets.all(8.0),
                ),
                Text(
                  'ประวัติการสั่งซื้อ',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click product');
          routeToListProduct(0);
        },
      ),
    );
  }

  Widget productBox() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 45.0,
                  child: Image.asset('images/icon_drugs.png'),
                ),
                Text(
                  'รายการสินค้า',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click promotion');
          routeToListProduct(0);
        },
      ),
    );
  }

  Widget promotionBox() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 45.0,
                  child: Image.asset('images/icon_promotion.png'),
                ),
                Text(
                  'สินค้าโปรโมชัน',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click promotion');
          routeToListProduct(2);
        },
      ),
    );
  }

  Widget updatepriceBox() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 45.0,
                  child: Image.asset('images/icon_updateprice.png'),
                ),
                Text(
                  'จะปรับราคา',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click promotion');
          routeToListProduct(3);
        },
      ),
    );
  }

  Widget newproductBox() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 45.0,
                  child: Image.asset('images/icon_new.png'),
                ),
                Text(
                  'สินค้าใหม่',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click promotion');
          routeToListProduct(1);
        },
      ),
    );
  }

  Widget cartBox() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 45.0,
                  child: Image.asset('images/icon_cart.png'),
                ),
                Text(
                  'ตะกร้าสินค้า',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click newproduct');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return DetailCart(
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget historyBox() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 45.0,
                  child: Image.asset('images/icon_history.png'),
                ),
                Text(
                  'ประวัติการสั่ง',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click order history');
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => WebView(
          //               userModel: myUserModel!,
          //             )));
        },
      ),
    );
  }

  Widget barcodeBox() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 45.0,
                  child: Image.asset('images/icon_barcode.png'),
                ),
                Text(
                  'Barcode scan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click barcode scan');
          // readQRcode();
          // readQRcodePreview();
          // Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget bottomRight() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 45.0,
                  child: Image.asset('images/icon_recommend.png'),
                ),
                Text(
                  'Recommend',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click recommend');
          routeToListProduct(3);
        },
      ),
    );
  }

  Widget row1Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        productBox(),
        promotionBox(),
      ],
    );
  }

  Widget row2Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        updatepriceBox(),
        newproductBox(),
      ],
    );
  }

  Widget row3Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        cartBox(),
        barcodeBox(),
      ],
    );
  }

  Widget row4Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        historyBox(),
        // barcodeBox(),
      ],
    );
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 30.0,
    );
  }

  Widget menuReadQRcode() {
    return ListTile(
      leading: Icon(
        Icons.photo_camera,
        size: 36.0,
      ),
      title: Text('Read QR code'),
      subtitle: Text('Read QR code or barcode'),
      onTap: () {
        // readQRcode();
        // readQRcodePreview();
        Navigator.of(context).pop();
      },
    );
  }

  // Future<void> readQRcode() async {
  //   try {
  //     var qrString? = await BarcodeScanner.scan();
  //     print('QR code = $qrString');
  //     if (qrString? != null) {
  //       decodeQRcode(qrString);
  //     }
  //   } catch (e) {
  //     print('e = $e');
  //   }
  // }

  // Future<void> readQRcodePreview() async {
  //   try {
  //     final qrScanString = await Navigator.push(this.context,
  //         MaterialPageRoute(builder: (context) => ScanPreviewPage()));

  //     print('Before scan');
  //     // final qrScanString? = await BarcodeScanner.scan();
  //     print('After scan');
  //     print('scanl result: $qrScanString');
  //     qrString = qrScanString;
  //     if (qrString != null) {
  //       decodeQRcode(qrString);
  //     }
  //     // setState(() => scanResult = qrScanString);
  //   } on PlatformException catch (e) {
  //     print('e = $e');
  //   }
  // }

  Future<void> readCart() async {
    amontCart = 0;
    String? memberId = myUserModel!.id.toString();
    String? url =
        'https://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];

    for (var map in cartList) {
      setState(() {
        amontCart = amontCart! + 1;
      });
      print('amontCart (service page))>>>> $amontCart');
    }
  }

  Future<void> decodeQRcode(var code) async {
    try {
      String? url =
          'https://ptnpharma.com/apishop/json_productlist.php?bqcode=$code';
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      print('result ===*******>>>> $result');

      int status = result['status'];
      print('status ===>>> $status');
      if (status == 0) {
        normalDialog(context, 'Not found', 'ไม่พบ code :: $code ในระบบ');
      } else {
        var itemProducts = result['itemsProduct'];
        for (var map in itemProducts) {
          print('map ===*******>>>> $map');

          ProductAllModel productAllModel = ProductAllModel.fromJson(map);
          MaterialPageRoute route = MaterialPageRoute(
            builder: (BuildContext context) => Detail(
              userModel: myUserModel,
              productAllModel: productAllModel,
            ),
          );
          Navigator.of(context).push(route).then((value) => readCart());

          // Navigator.of(context).push(route).then((value) {
          //   setState(() {
          //     // readCart();
          //   });
          // });
        }
      }
    } catch (e) {}
  }

  Widget homeMenu() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(top: 5.0),
      alignment: Alignment(0.0, 0.0),
      // color: Colors.green.shade50,
      // height: MediaQuery.of(context).size.height * 0.5 - 81,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          row1Menu(),
          // mySizebox(),
          row2Menu(),
          // mySizebox(),
          row3Menu(),
          // mySizebox(),
          row4Menu(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          headTitle('สินค้าแนะนำ (8/2020)', Icons.thumb_up),
          suggest(),
          headTitle('เมนู', Icons.home),
          homeMenu(),
          // productBox(),
          // orderhistoryBox(),
          // headTitle('สินค้าโปรโมชัน', Icons.bookmark),
          // promotion(),
        ],
      ),
    );
  }

  Widget headTitle(String? string, IconData iconData) {
    // Widget  แทน object ประเภทไดก็ได้
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Row(
        children: <Widget>[
          Icon(
            iconData,
            size: 24.0,
            color: MyStyle().textColor,
          ),
          mySizebox(),
          Text(
            string!,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: MyStyle().textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// class WebViewWidget extends StatefulWidget {
//   WebViewWidget({Key? key}) : super(key: key);

//   @override
//   _WebViewWidgetState createState() => _WebViewWidgetState();
// }

// class _WebViewWidgetState extends State {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("Sample WebView Widget"),
//           backgroundColor: MyStyle().bgColor,
//         ),
//         body: Center(
//           child: Column(
//             children: [
//               Container(
//                 child: TextButton(
//                     child: Text("Open my Blog"),
//                     onPressed: () {
//                       print("in");
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (context) => WebView()));
//                     }),
//               )
//             ],
//           ),
//         ));
//   }
// }

// class WebView extends StatefulWidget {
//   final UserModel? userModel;

//   WebView({Key? key, this.userModel}) : super(key: key);

//   @override
//   _WebViewState createState() => _WebViewState();
// }

// class _WebViewState extends State<WebView> {
//   UserModel? myUserModel;

//   @override
//   void initState() {
//     super.initState();
//     myUserModel = widget.userModel;
//   }

//   @override
//   Widget build(BuildContext context) {
//     String? memberId = myUserModel!.id;
//     String? memberCode = myUserModel!.customerCode;
//     String? url =
//         'https://ptnpharma.com/shop/pages/tables/orderhistory_mb.php?memberId=$memberId&memberCode=$memberCode'; //
//     print('URL ==>> $url');
//     return WebviewScaffold(
//       url: url, //"https://www.androidmonks.com",
//       appBar: AppBar(
//         backgroundColor: MyStyle().bgColor,
//         title: Text("ประวัติการสั่งซื้อ"),
//       ),
//       withZoom: true,
//       withJavascript: true,
//       withLocalStorage: true,
//       appCacheEnabled: false,
//       ignoreSSLErrors: true,
//     );
//   }
// }

// class ScanPreviewPage extends StatefulWidget {
//   @override
//   _ScanPreviewPageState createState() => _ScanPreviewPageState();
// }

// class _ScanPreviewPageState extends State<ScanPreviewPage> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('PTN Pharma'),
//           backgroundColor: MyStyle().bgColor,
//         ),
//         body: SizedBox(
//           width: double.infinity,
//           height: double.infinity,
//           // child: ScanPreviewWidget(
//           //   onScanResult: (result) {
//           //     debugPrint('scan result: $result');
//           //     Navigator.pop(context, result);
//           //   },
//           // ),
//         ),
//       ),
//     );
//   }
// }
