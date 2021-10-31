import 'dart:convert';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
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
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';

class Home extends StatefulWidget {
  final UserModel userModel;

  Home({Key key, this.userModel}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Explicit
  // List<PromoteModel> promoteModels = List();
  List<Widget> promoteLists = List();
  List<Widget> suggestLists = List();
  List<String> urlImages = List();
  List<String> urlImagesSuggest = List();
  List<String> productsName = List();

  int amontCart = 0, banerIndex = 0, suggestIndex = 0;
  UserModel myUserModel;
  List<ProductAllModel> promoteModels = List();
  List<ProductAllModel> suggestModels = List();
  String qrString;
  int currentIndex = 0;
  String _result = '';

  // Method
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => _onBasicAlertPressed(context));

    readPromotion();
    myUserModel = widget.userModel;
    readSuggest();
    setState(() {
      readCart();
    });
    directMessage();
  }

//   // The easiest way for creating RFlutter Alert
//   _onBasicAlertPressed(context) {
//     Alert(
//       context: context,
//       title: "RFLUTTER ALERT",
//       desc: "Flutter is more awesome with RFlutter Alert.",
//     ).show();
//   }

// //Custom animation alert
//   _onCustomAnimationAlertPressed(context) {
//     Alert(
//       context: context,
//       title: "RFLUTTER ALERT",
//       desc: "Flutter is more awesome with RFlutter Alert.",
//       alertAnimation: FadeAlertAnimation,
//     ).show();
//   }

  Future<void> readPromotion() async {
    String url = 'http://www.ptnpharma.com/apishop/json_promotion.php';
    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel promoteModel = PromoteModel.fromJson(map);
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      String urlImage = promoteModel.photo;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        promoteModels.add(productAllModel);
        promoteLists.add(showImageNetWork(urlImage));
        urlImages.add(urlImage);
      });
    }
  }

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  Future<void> readSuggest() async {
    String memId = myUserModel.id;
    String url =
        'http://www.ptnpharma.com/apishop/json_suggest.php?memberId=$memId'; // ?memberId=$memberId
    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel promoteModel = PromoteModel.fromJson(map);
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      String urlImage = promoteModel.photo;
      String productName = promoteModel.title;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        suggestModels.add(productAllModel);
        suggestLists.add(Image.network(urlImage));
        urlImagesSuggest.add(urlImage);
        productsName.add(productName);
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
            productAllModel: promoteModels[banerIndex],
            userModel: myUserModel,
          ),
        );
        // Navigator.of(context).push(route).then((value) {});  //  link to detail page
      },
      child: CarouselSlider(
        options: CarouselOptions(
          height: 1500,
          viewportFraction: 0.8,
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          // pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlay: true,
          autoPlayAnimationDuration: Duration(seconds: 5),
          onPageChanged: (int index, reason) {
            banerIndex = index;
            // print('index = $index');
          },
        ),
        items: promoteLists,
      ),
    );
  }

  Widget showCarouseSliderSuggest() {
    return GestureDetector(
      child: CarouselSlider.builder(
        options: CarouselOptions(
          // pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlay: true,
          autoPlayAnimationDuration: Duration(seconds: 5),
        ),
        itemCount: (suggestLists.length / 2).round(),
        itemBuilder: (context, index, realIdx) {
          final int first = index * 2;
          final int second = first + 1;

          return Row(
            children: [first, second].map((idx) {
              return Expanded(
                child: GestureDetector(
                  child: Card(
                    // flex: 1,
                    child: Column(
                      children: <Widget>[
                        Container(
                          // width: MediaQuery.of(context).size.width * 0.50,
                          height: 100.00,
                          child: suggestLists[idx],
                          padding: EdgeInsets.all(8.0),
                        ),
                        Text(
                          productsName[idx].toString(),
                          style: TextStyle(
                              fontSize: 12,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    print('You Click index >> $idx');
                    /*
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (BuildContext context) => Detail(
                        productAllModel: suggestModels[idx],
                        userModel: myUserModel,
                      ),
                    );
                    Navigator.of(context).push(route).then((value) {});
                    */
                    MaterialPageRoute materialPageRoute =
                        MaterialPageRoute(builder: (BuildContext buildContext) {
                      return Detail(
                        productAllModel: suggestModels[idx],
                        userModel: myUserModel,
                      );
                    });
                    Navigator.of(context)
                        .push(materialPageRoute)
                        .then((value) => readCart());
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget promotion() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        height: MediaQuery.of(context).size.width * 0.70, // size.height * 0.20,
        child: promoteLists.length == 0
            ? myCircularProgress()
            : showCarouseSlider(),
      ),
    );
  }

  Widget suggest() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.25,
        child: suggestLists.length == 0
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
    String login = myUserModel.name;
    return Container(
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
    return Container(
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
                Container(
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
          print('You click product');
          routeToListProduct(0);
        },
      ),
    );
  }

  Widget promotionBox() {
    return Container(
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
                Container(
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
    return Container(
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
                Container(
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
          print('You click update price');
          routeToListProduct(3);
        },
      ),
    );
  }

  Widget newproductBox() {
    return Container(
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
                Container(
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
          print('You click new item');
          routeToListProduct(1);
        },
      ),
    );
  }

  Widget notreceiveBox() {
    return Container(
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
                Container(
                  width: 45.0,
                  child: Image.asset('images/icon_cancel.png'),
                ),
                Text(
                  'สั่งแล้วไม่ได้รับ',
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
          print('You click not receive');
          routeToListProduct(4);
        },
      ),
    );
  }

  Widget cartBox() {
    return Container(
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
                Container(
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
          print('You click cart');
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
    return Container(
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
                Container(
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebView(
                        userModel: myUserModel,
                      )));
        },
      ),
    );
  }

  Widget barcodeBox() {
    return Container(
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
                Container(
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
          readQRcodePreview();
          // Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget bottomRight() {
    return Container(
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
                Container(
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
        notreceiveBox(),
      ],
    );
  }

  Widget row2Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        promotionBox(),
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
        updatepriceBox(),
        cartBox(),
      ],
    );
  }

  Widget row4Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        barcodeBox(),
        historyBox(),
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
        readQRcodePreview();
        // Navigator.of(context).pop();
      },
    );
  }

  Future<void> readQRcode() async {
    try {
      var qrString = await BarcodeScanner.scan();
      print('QR code = $qrString');
      if (qrString != null) {
        decodeQRcode(qrString);
      }
    } catch (e) {
      print('e = $e');
    }
  }

  Future<void> readQRcodePreview() async {
    try {
      final qrScanString = await Navigator.push(this.context,
          MaterialPageRoute(builder: (context) => ScanPreviewPage()));

      print('Before scan');
      // final qrScanString = await BarcodeScanner.scan();
      print('After scan');
      print('scanl result: $qrScanString');
      qrString = qrScanString;
      if (qrString != null) {
        decodeQRcode(qrString);
      }
      // setState(() => scanResult = qrScanString);
    } on PlatformException catch (e) {
      print('e = $e');
    }
  }

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel.id.toString();
    String url =
        'http://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var cartList = result['cart'];
    if (cartList != null) {
      for (var map in cartList) {
        setState(() {
          amontCart++;
        });
        print('amontCart (service page))>>>> $amontCart');
      }
    }
  }

  Future<void> decodeQRcode(var code) async {
    try {
      String url =
          'http://ptnpharma.com/apishop/json_productlist.php?bqcode=$code';
      http.Response response = await http.get(url);
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

  Widget FadeAlertAnimation(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Align(
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
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
          ////////////////////////////
          // RaisedButton(
          //   child: Text('Basic Alert'),
          //   onPressed: () => _onBasicAlertPressed(context),
          // ),
          // RaisedButton(
          //   child: Text('Custom Animation Alert'),
          //   onPressed: () => _onCustomAnimationAlertPressed(context),
          // ),
          ////////////////////////////

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

  Future<void> directMessage() {
    String msg = myUserModel.msg;
    if (msg != '') {
      // ToastView.createView(msg, context, Toast.LENGTH_LONG, Toast.BOTTOM,
      //     Colors.red, Colors.white, 200, null);
      Toast.show(msg, context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    String login = myUserModel.name;
    String loginStatus = myUserModel.status;
    String msg = myUserModel.msg;

    if (loginStatus == '1') {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            headTitle('สินค้าแนะนำ $login ', Icons.thumb_up), //($loginStatus)
            suggest(),
            headTitle('เมนู', Icons.home),
            homeMenu(),
            // Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: RaisedButton(
            //       child: Text('แสดงข้อความ'),
            //       onPressed: () => ToastView.createView(
            //           msg,
            //           context,
            //           Toast.LENGTH_LONG,
            //           Toast.BOTTOM,
            //           Colors.red,
            //           Colors.white,
            //           200,
            //           null)),
            // )
            // productBox(),
            // orderhistoryBox(),
            // headTitle('สินค้าโปรโมชัน', Icons.bookmark),
            // promotion(),
          ],
        ),
      );
    } else {
      return Text('กรุณาติดต่อ PTN Pharma');
    }
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  Widget headTitle(String string, IconData iconData) {
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
            string,
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

class WebViewWidget extends StatefulWidget {
  WebViewWidget({Key key}) : super(key: key);

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sample WebView Widget"),
          backgroundColor: MyStyle().bgColor,
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                child: FlatButton(
                    child: Text("Open my Blog"),
                    onPressed: () {
                      print("in");
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => WebView()));
                    }),
              )
            ],
          ),
        ));
  }
}

class WebView extends StatefulWidget {
  final UserModel userModel;

  WebView({Key key, this.userModel}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  UserModel myUserModel;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
  }

  @override
  Widget build(BuildContext context) {
    String memberId = myUserModel.id;
    String memberCode = myUserModel.customerCode;
    String url =
        'https://ptnpharma.com/shop/pages/tables/orderhistory_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
    print('URL ==>> $url');
    return WebviewScaffold(
      url: url, //"https://www.androidmonks.com",
      appBar: AppBar(
        backgroundColor: MyStyle().bgColor,
        title: Text("ประวัติการสั่งซื้อ"),
      ),
      withZoom: true,
      withJavascript: true,
      withLocalStorage: true,
      appCacheEnabled: false,
      ignoreSSLErrors: true,
    );
  }
}

class ScanPreviewPage extends StatefulWidget {
  @override
  _ScanPreviewPageState createState() => _ScanPreviewPageState();
}

class _ScanPreviewPageState extends State<ScanPreviewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PTN Pharma'),
          backgroundColor: MyStyle().bgColor,
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: ScanPreviewWidget(
            onScanResult: (result) {
              debugPrint('scan result: $result');
              Navigator.pop(context, result);
            },
          ),
        ),
      ),
    );
  }
}
