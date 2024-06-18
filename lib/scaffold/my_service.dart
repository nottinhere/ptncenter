import 'dart:convert';
import 'dart:io';

// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/category_model.dart';
import 'package:ptncenter/scaffold/detail.dart';

import 'package:ptncenter/scaffold/list_news.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:ptncenter/widget/contact.dart';
import 'package:ptncenter/widget/home.dart';
import 'package:ptncenter/widget/homescreen.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'detail_cart.dart';
import 'package:toast/toast.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class MyService extends StatefulWidget {
  final UserModel userModel;
  bool firstLoadAds;
  bool orderSuccess;
  MyService(
      {Key key,
      this.userModel,
      this.firstLoadAds = false,
      this.orderSuccess = false})
      : super(key: key);

  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  //Explicit
  List<CategoryModel> categoryModels = List(); // set array
  UserModel myUserModel;

  String mywebPage;

  Widget currentWidget;
  String qrString;
  int amontCart = 0;
  int currentIndex;
  ScrollController scrollController = ScrollController();
  String _result = '';

  // Method
  @override
  void initState() {
    super.initState(); // จะทำงานก่อน build
    currentIndex = 0;
    setState(() {
      myUserModel = widget.userModel;
      currentWidget = Home(
        userModel: myUserModel,
        firstLoadAds: widget.firstLoadAds,
        orderSuccess: widget.orderSuccess,
      );
      print('Here is initState');
      readCategory(); // read  ข้อมูลมาแสดง
      readCart();
    });
  }

  Future<void> readCart() async {
    amontCart = 0;
    // List map;
    String memberId = myUserModel.id.toString();
    String url =
        'https://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    // print('cartList >> $cartList');

    if (cartList != null) {
      for (var map in cartList) {
        setState(() {
          amontCart++;
        });
      }
    }
    // print('amontCart (service page))>>>> $amontCart');
  }

  Future<void> readCategory() async {
    String url = 'https://ptnpharma.com/apishop/json_category.php';
    // print('url readCategory >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cateList = result['data'];
    for (var map in cateList) {
      CategoryModel categoryModel = CategoryModel.fromJson(map);
      categoryModels.add(categoryModel);
    }
    // print(' cateList ()>> $categoryModels');
  }

/*************************** */
  String _scanBarcode = 'Unknown';

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);

      String url =
          'https://ptnpharma.com/apishop/json_productlist.php?bqcode=$barcodeScanRes';
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print('result ===*******>>>> $result');

      int status = result['status'];
      // print('status ===>>> $status');
      if (status == 0) {
        normalDialog(
            context, 'Not found', 'ไม่พบ code :: $barcodeScanRes ในระบบ');
      } else {
        var itemProducts = result['itemsProduct'];
        for (var map in itemProducts) {
          // print('map ===*******>>>> $map');

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
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

/*************************** */

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

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProductfav(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductByCate(int index, int cate, String cateName) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel,
        cate: cate,
        cateName: cateName,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToNews() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return News(
        userModel: myUserModel,
      );
    });
    int unread;
    // Navigator.of(context).push(materialPageRoute);
    Navigator.of(context).push(materialPageRoute).then((value) => unread = 0);
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });

    //You can have a switch case to Navigate to different pages
    switch (currentIndex) {
      case 0:
        break; // home
      case 1:
        routeToListProductfav(0);
        break; // all product
      case 2:
        routeToListProduct(0);
        break; // all product
      case 3:
        routeToNews();
        break; // Shopping cart

      // case 2:  routeToListProduct(2);   break;  // promotion
      // case 3:  routeToListProduct(3);   break;  // update price
      // case 4:  routeToListProduct(1);   break;  // new item
    }
  }

  Widget menuHome() {
    return ListTile(
      leading: Icon(
        Icons.home,
        size: 36.0,
        color: MyStyle().mainColor,
      ),
      title: Text(
        'หน้าหลัก',
        style: TextStyle(
          color: MyStyle().textColor,
        ),
      ),
      // subtitle: Text(
      //   'หน้าหลัก',
      //   style: TextStyle(
      //     color: MyStyle().mainColor,
      //   ),
      // ),
      onTap: () {
        setState(() {
          print('Here is menu home');
          readCart();
          currentWidget = Home(
            userModel: myUserModel,
          );
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuCategory() {
    print('menuCategory');
    return ExpansionTile(
      leading: Icon(
        Icons.category,
        size: 36.0,
      ),
      title: Text('หมวดสินค้า'),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new InkWell(
                          child: Text(
                            ' - สินค้าทั้งหมด',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          onTap: () => routeToListProduct(
                              0)), //  routeToListProductByCate(6, 0, 'สินค้าทั้งหมด')),
                    ),
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        controller: scrollController,
                        itemCount: categoryModels.length,
                        itemBuilder: (BuildContext buildContext, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new InkWell(
                                child: Text(
                                  ' - ' + categoryModels[index].cateName,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                onTap: () => routeToListProductByCate(
                                    5,
                                    categoryModels[index].cateId,
                                    categoryModels[index].cateName)),
                          );
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget menuLogOut() {
    return ListTile(
      leading: Icon(
        Icons.exit_to_app,
        size: 36.0,
      ),
      title: Text('ออกจากระบบ'),
      // subtitle: Text('Logout and exit'),
      onTap: () {
        logOut();
      },
    );
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    exit(0);
  }

  Widget menuContact() {
    return ListTile(
      leading: Icon(
        Icons.home,
        size: 36.0,
      ),
      title: Text('ติดต่อเรา'),
      // subtitle: Text('ข้อมูลติดต่อพัฒนาเภสัช'),
      onTap: () {
        setState(() {
          currentWidget = Contact();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuPay() {
    String webPage = 'pay';

    return ListTile(
      leading: Icon(
        Icons.payment,
        size: 36.0,
      ),
      title: Text('แจ้งชำระเงิน'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebView(
                      userModel: myUserModel,
                      webPage: webPage,
                    )));
      },
    );
  }

  Widget menuComplain() {
    String webPage = 'complain';
    return ListTile(
      leading: Icon(
        Icons.comment,
        size: 36.0,
      ),
      title: Text('แจ้งร้องเรียน'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebView(
                      userModel: myUserModel,
                      webPage: webPage,
                    )));
      },
    );
  }

  Widget menuReadQRcode() {
    return ListTile(
      leading: Icon(
        Icons.photo_camera,
        size: 36.0,
      ),
      title: Text('Scan barcode'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        // readQRcode();
        // readQRcodePreview();
        scanBarcodeNormal();
      },
    );
  }

  // Future<void> readQRcode() async {
  //   try {
  //     var qrString = await BarcodeScanner.scan();
  //     print('QR code = $qrString');
  //     if (qrString != null) {
  //       decodeQRcode(qrString);
  //     }
  //   } catch (e) {
  //     print('e = $e');
  //   }
  // }

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

  Future<void> decodeQRcode(var code) async {
    try {
      String url =
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
          // Navigator.of(context).push(route).then((value) {
          //   setState(() {
          //     // readCart();
          //   });
          // });
          Navigator.of(context).push(route).then((value) => readCart());
        }
      }
    } catch (e) {}
  }

  Widget showAppName() {
    return Text(
      'PTN CENTER',
      style: TextStyle(
        fontSize: 24.0,
        color: MyStyle().textColor,
      ),
    );
  }

  Widget showLogin() {
    String login = myUserModel.name;
    if (login == null) {
      login = '...';
    }
    return Text(
      'ร้าน $login',
      style: TextStyle(
        fontSize: 20.0,
        color: MyStyle().mainColor,
      ),
    );
  }

  Widget showLogo() {
    return Container(
      width: 80.0,
      height: 80.0,
      child: Image.asset('images/logo_master.png'),
    );
  }

  Widget headDrawer() {
    return DrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/pharma.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: <Widget>[
          showLogo(),
          showAppName(),
          showLogin(),
        ],
      ),
    );
  }

  Widget showDrawer() {
    // print(' cateList (showDrawer)>> $categoryModels');

    return Drawer(
      child: ListView(
        children: <Widget>[
          headDrawer(),
          menuHome(),
          menuCategory(),
          menuContact(),
          menuPay(),
          menuComplain(),
          menuReadQRcode(),
          menuLogOut(),
        ],
      ),
    );
  }

  Widget showCart() {
    return GestureDetector(
      onTap: () {
        routeToDetailCart();
      },
      child: Container(
        margin: EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/shopping_cart.png'),
            Text(
              ' $amontCart ',
              style: TextStyle(
                backgroundColor: Colors.red.shade600,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }

  Widget showMsg() {
    var iconMsg = 'images/bubble-white.png';
    if (myUserModel.msg == '') {
      iconMsg = 'images/bubble-white.png';
    } else {
      iconMsg = 'images/bubble-red.png';
    }
    return GestureDetector(
      onTap: () => showToast(myUserModel.msg, gravity: Toast.TOP, duration: 5),
      child: Container(
        margin: EdgeInsets.only(top: 5.0, right: 5.0),
        width: 28.0,
        height: 28.0,
        child: Stack(
          children: <Widget>[
            Image.asset(iconMsg),
          ],
        ),
      ),
    );
  }

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailCart(
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute).then((value) {
      setState(() {
        print('Here is routeToDetailCart');

        readCart();
      });
    });
  }

  BottomNavigationBarItem homeBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    );
  }

  BottomNavigationBarItem favoriteBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: 'Favorite',
    );
  }

  BottomNavigationBarItem cartBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: 'Cart',
    );
  }

  BottomNavigationBarItem readQrBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.code),
      label: 'QR code',
    );
  }

  Widget showBottomBarNav() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        homeBotton(),
        favoriteBotton(),
        cartBotton(),
        readQrBotton(),
      ],
      onTap: (int index) {
        print('index =$index');
        if (index == 1) {
          routeToListProductfav(0);
        } else if (index == 2) {
          routeToListProduct(0);
        } else if (index == 3) {
          routeToNews();
        }
      },
    );
  }

  Widget showBubbleBottomBarNav() {
    int unread = myUserModel.lastNewsId - myUserModel.lastNewsOpen;

    return BubbleBottomBar(
      hasNotch: true,
      // fabLocation: BubbleBottomBarFabLocation.end,
      opacity: .2,
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(
              16)), //border radius doesn't work when the notch is enabled.
      elevation: 8,
      currentIndex: currentIndex,
      onTap: changePage,
      items: <BubbleBottomBarItem>[
        BubbleBottomBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            title: Text("หน้าหลัก")),
        BubbleBottomBarItem(
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.favorite,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            title: Text("รายการโปรด")),
        BubbleBottomBarItem(
            backgroundColor: Colors.green,
            icon: Icon(
              Icons.medical_services,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.medical_services,
              color: Colors.green,
            ),
            title: Text("สินค้า")),
        BubbleBottomBarItem(
            backgroundColor: Colors.brown,
            icon: Stack(
              children: <Widget>[
                Icon(
                  Icons.newspaper,
                  color: Colors.black,
                ),
                (unread != 0)
                    ? Text(
                        ' $unread ',
                        style: TextStyle(
                          fontSize: 13,
                          backgroundColor: Colors.red.shade600,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          wordSpacing: 100.0,
                        ),
                      )
                    : Text(''),
                // CircleAvatar(
                //   radius: 8,
                //   backgroundColor: Colors.red,
                //   child: Text(
                //     ' 5 ',
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
            activeIcon: Icon(
              Icons.newspaper,
              color: Colors.brown,
            ),
            title: Text("ข่าวสาร")),
        /*
        BubbleBottomBarItem(
            backgroundColor: Colors.green,
            icon: Icon(
              Icons.bookmark,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.bookmark,
              color: Colors.green,
            ),
            title: Text("โปรโมชัน")),
        BubbleBottomBarItem(
            backgroundColor: Colors.green,
            icon: Icon(
              Icons.arrow_upward,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.arrow_upward,
              color: Colors.green,
            ),
            title: Text("ปรับราคา")),
        BubbleBottomBarItem(
            backgroundColor: Colors.green,
            icon: Icon(
              Icons.fiber_new,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.fiber_new,
              color: Colors.green,
            ),
            title: Text("สินค้าใหม่")),
            */
      ],
    );
    // readCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          // showMsg(),
          showCart(),
        ],
        backgroundColor: MyStyle().bgColor,
        title: Text('หน้าหลัก'),
        // centerTitle: true,
      ),

      body: currentWidget,
      drawer: showDrawer(),
      bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
    );
  }
}

class WebView extends StatefulWidget {
  final UserModel userModel;
  final String webPage;

  WebView({Key key, this.userModel, this.webPage}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  UserModel myUserModel;
  String mywebPage;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    mywebPage = widget.webPage;
  }

  @override
  Widget build(BuildContext context) {
    String memberId = myUserModel.id;
    String memberCode = myUserModel.customerCode;
    String webPage = mywebPage.toString();

    String url =
        'https://ptnpharma.com/shop/pages/tables/orderhistory_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
    String txtTitle = 'หน้า.....';

    if (webPage == 'pay') {
      url =
          'https://ptnpharma.com/shop/pages/forms/pay_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
      txtTitle = 'แจ้งชำระเงิน';
    } else {
      url =
          'https://ptnpharma.com/shop/pages/forms/complain_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
      txtTitle = 'แจ้งร้องเรียน';
    }

    print('Click open ==>> $webPage');

    print('URL ==>> $url');
    return WebviewScaffold(
      url: url, //"https://www.androidmonks.com",
      appBar: AppBar(
        backgroundColor: MyStyle().bgColor,
        title: Text(txtTitle),
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
