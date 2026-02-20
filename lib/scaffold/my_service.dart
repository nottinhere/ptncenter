import 'dart:convert';
import 'dart:io';

// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/main.dart';
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/category_model.dart';
import 'package:ptncenter/scaffold/detail.dart';

import 'package:ptncenter/scaffold/list_news.dart';
import 'package:ptncenter/scaffold/list_notify.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:ptncenter/widget/contact.dart';
import 'package:ptncenter/widget/home.dart';
import 'package:ptncenter/widget/homescreen.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'detail_cart.dart';
import 'package:toast/toast.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
// import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';

// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MyService extends StatefulWidget {
  final UserModel? userModel;
  bool? firstLoadAds;
  bool? orderSuccess;
  MyService({
    Key? key,
    this.userModel,
    this.firstLoadAds = false,
    this.orderSuccess = false,
  }) : super(key: key);

  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  //Explicit
  List<CategoryModel>? categoryModels = []; // set array
  UserModel? myUserModel;
  String? mywebPage;
  Widget? currentWidget;
  String? qrString;
  int? amontCart = 0;
  int? currentIndex;
  ScrollController? scrollController = ScrollController();

  int selectIndex = 0;
  bool heart = false;
  final controller = PageController();

  // Method
  @override
  void initState() {
    super.initState(); // จะทำงานก่อน build
    currentIndex = 0;
    setState(() {
      myUserModel = widget.userModel;
      currentWidget = Home(
        userModel: myUserModel!,
        firstLoadAds: widget.firstLoadAds!,
        orderSuccess: widget.orderSuccess!,
      );
      print('Here is initState');
      readCategory(); // read  ข้อมูลมาแสดง
      readCart();
    });
  }

  Future<void> readCart() async {
    amontCart = 0;
    // List map;
    String memberId = myUserModel!.id.toString();
    String url =
        'https://www.ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId&screen=service';
    // print('url readCart >> $url');
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    // print('cartList >> $cartList');

    if (cartList != null) {
      for (var map in cartList) {
        setState(() {
          amontCart = amontCart! + 1;
        });
      }
    }
    // print('amontCart (service page))>>>> $amontCart');
  }

  Future<void> readCategory() async {
    String url = 'https://www.ptnpharma.com/apishop/json_category.php';
    // print('url readCategory >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cateList = result['data'];
    // print('cateList >> $cateList');
    for (var map in cateList) {
      CategoryModel? categoryModel = CategoryModel.fromJson(map);
      setState(() {
        categoryModels!.add(categoryModel);
      });
    }
    print(' cateList ()>> $categoryModels');
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProduct(index: index, userModel: myUserModel!);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProductfav(index: index, userModel: myUserModel!);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductByCate(int index, int cate, String cateName) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProduct(
          index: index,
          userModel: myUserModel!,
          cate: cate,
          cateName: cateName,
        );
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToNews() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return News(userModel: myUserModel!);
      },
    );
    Navigator.of(context).push(materialPageRoute);
    // int unread;
    // Navigator.of(context).push(materialPageRoute).then((value) => unread = 0);
  }

  void routeToNotify() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return Notify(userModel: myUserModel!);
      },
    );
    int unread;
    // Navigator.of(context).push(materialPageRoute);
    Navigator.of(context).push(materialPageRoute).then((value) => unread = 0);
  }

  void changePage(int? index) {
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
        routeToNotify();
        break; // Shopping cart

      // case 2:  routeToListProduct(2);   break;  // promotion
      // case 3:  routeToListProduct(3);   break;  // update price
      // case 4:  routeToListProduct(1);   break;  // new item
    }
  }

  Widget menuHome() {
    return ListTile(
      leading: Icon(Icons.home, size: 36.0, color: MyStyle().mainColor),
      title: Text('หน้าหลัก', style: TextStyle(color: MyStyle().textColor)),
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
          currentWidget = Home(userModel: myUserModel!);
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuCategory() {
    print('menuCategory >> ' + categoryModels!.length.toString());
    return ExpansionTile(
      leading: Icon(Icons.category, size: 36.0),
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
                        onTap: () => routeToListProduct(0),
                      ), //  routeToListProductByCate(6, 0, 'สินค้าทั้งหมด')),
                    ),
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      controller: scrollController,
                      itemCount: categoryModels!.length,
                      itemBuilder: (BuildContext buildContext, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new InkWell(
                            child: Text(
                              ' - ' + categoryModels![index].cateName!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            onTap: () => routeToListProductByCate(
                              5,
                              categoryModels![index].cateId!,
                              categoryModels![index].cateName!,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget menuexpandCate() {}

  Widget menuLogOut() {
    return ListTile(
      leading: Icon(Icons.exit_to_app, size: 36.0),
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
    // exit(0);
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return MyApp();
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  Widget menuContact() {
    return ListTile(
      leading: Icon(Icons.home, size: 36.0),
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
      leading: Icon(Icons.payments, size: 36.0),
      title: Text('การชำระเงิน'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WebViewExample(userModel: myUserModel!, webPage: webPage),
          ),
        );
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => WebView(
        //               userModel: myUserModel!,
        //               webPage: webPage,
        //             )));
      },
    );
  }

  Widget menuORN() {
    String webPage = 'orn';

    return ListTile(
      leading: Icon(Icons.checklist, size: 36.0),
      title: Text('ตรวจสอบใบส่งของ'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WebViewExample(userModel: myUserModel!, webPage: webPage),
          ),
        );
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => WebView(
        //               userModel: myUserModel!,
        //               webPage: webPage,
        //             )));
      },
    );
  }

  Widget menuReward() {
    String webPage = 'reward';

    return ListTile(
      leading: Icon(Icons.workspace_premium, size: 36.0),
      title: Text('ของสมนาคุณ'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WebViewExample(userModel: myUserModel!, webPage: webPage),
          ),
        );
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => WebView(
        //               userModel: myUserModel!,
        //               webPage: webPage,
        //             )));
      },
    );
  }

  Widget menuComplain() {
    String webPage = 'complain';
    return ListTile(
      leading: Icon(Icons.comment, size: 36.0),
      title: Text('ข้อเสนอแนะ'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WebViewExample(userModel: myUserModel!, webPage: webPage),
          ),
        );
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => WebView(
        //               userModel: myUserModel!,
        //               webPage: webPage,
        //             )));
      },
    );
  }

  Widget menuReadQRcode() {
    return ListTile(
      leading: Icon(Icons.photo_camera, size: 36.0),
      title: Text('Scan barcode'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        // readQRcode();
        // readQRcodePreview();
        // scanBarcodeNormal();
      },
    );
  }

  Widget showAppName() {
    return Text(
      'PTN CENTER',
      style: TextStyle(fontSize: 24.0, color: MyStyle().textColor),
    );
  }

  Widget showLogin() {
    String login = myUserModel!.name!;
    if (login == '') {
      login = '...';
    }
    return Text(
      '$login',
      style: TextStyle(fontSize: 20.0, color: MyStyle().mainColor),
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
          // showAppName(),
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
          // menuORN(),
          menuPay(),
          menuReward(),
          // menuReadQRcode(),
          menuContact(),
          menuComplain(),
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

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return DetailCart(userModel: myUserModel);
      },
    );
    Navigator.of(context).push(materialPageRoute).then((value) {
      setState(() {
        print('Here is routeToDetailCart');

        readCart();
      });
    });
  }

  Widget stylishBottomBar() {
    print(
      myUserModel!.lastNotifyId!.toString() +
          ' >> ' +
          myUserModel!.lastNotifyOpen!.toString(),
    );
    int? unread = myUserModel!.lastNotifyId!.toInt() -
        myUserModel!.lastNotifyOpen!.toInt();

    return StylishBottomBar(
      option: AnimatedBarOptions(iconStyle: IconStyle.animated, opacity: 0.3),
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
          icon: const Icon(Icons.favorite),
          title: const Text('Favorite'),
          backgroundColor: Colors.red,
        ),
        BottomBarItem(
          icon: Stack(
            children: <Widget>[
              Icon(Icons.notifications, color: Colors.orange),
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
            ],
          ),
          title: const Text('Notify'),
          backgroundColor: Colors.black,
        ),
      ],
      // fabLocation: StylishBarFabLocation.end,
      hasNotch: true,
      currentIndex: selectIndex,
      onTap: (index) {
        setState(() {
          selectIndex = index;
          // controller.jumpToPage(index);
          if (index == 0) {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => MyService(userModel: myUserModel),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            routeToListProduct(0);
          } else if (index == 2) {
            routeToListProductfav(0);
          } else if (index == 3) {
            routeToNotify();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          // showMsg(),
          showCart(),
        ],
        backgroundColor: MyStyle().bgColor,
        title: Text('หน้าหลัก', style: TextStyle(color: Colors.white)),
        // centerTitle: true,
      ),
      body: currentWidget,
      drawer: showDrawer(),
      // bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }
}

// class WebView extends StatefulWidget {
//   final UserModel? userModel;
//   final String? webPage;

//   WebView({Key? key, this.userModel, this.webPage}) : super(key: key);

//   @override
//   _WebViewState createState() => _WebViewState();
// }

// class _WebViewState extends State<WebView> {
//   UserModel? myUserModel;
//   String? mywebPage;

//   @override
//   void initState() {
//     super.initState();
//     myUserModel = widget.userModel;
//     mywebPage = widget.webPage;
//   }

//   @override
//   Widget build(BuildContext context) {
//     String? memberId = myUserModel!.id;
//     String? memberCode = myUserModel!.customerCode;
//     String webPage = mywebPage.toString();

//     String url =
//         'https://www.ptnpharma.com/shop/pages/tables/orderhistory_mb.php?memberId=$memberId&memberCode=$memberCode'; //
//     String txtTitle = 'หน้า.....';

//     if (webPage == 'pay') {
//       url =
//           'https://www.ptnpharma.com/shop/pages/forms/pay_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
//       txtTitle = 'แจ้งชำระเงิน';
//     } else if (webPage == 'orn') {
//       url =
//           'https://www.ptnpharma.com/shop/pages/tables/orn_list_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
//       txtTitle = 'ตรวจสอบใบส่งของ';
//     } else if (webPage == 'reward') {
//       url =
//           'https://www.ptnpharma.com/shop/pages/tables/reward_list_mb.php?memberId=$memberId&memberCode=$memberCode'; //
//       txtTitle = 'รายการของสมนาคุณ ';
//     } else {
//       url =
//           'https://www.ptnpharma.com/shop/pages/forms/complain_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
//       txtTitle = 'แจ้งร้องเรียน';
//     }

//     print('Click open ==>> $webPage');

//     print('URL ==>> $url');
//     return WebviewScaffold(
//       url: url, //"https://www.androidmonks.com",
//       appBar: AppBar(
//         backgroundColor: MyStyle().bgColor,
//         title: Text(txtTitle),
//       ),
//       withZoom: true,
//       withJavascript: true,
//       withLocalStorage: true,
//       appCacheEnabled: false,
//       ignoreSSLErrors: true,
//     );
//   }
// }

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
          // child: ScanPreviewWidget(
          //   onScanResult: (result) {
          //     debugPrint('scan result: $result');
          //     Navigator.pop(context, result);
          //   },
          // ),
        ),
      ),
    );
  }
}

class WebViewExample extends StatefulWidget {
  final UserModel? userModel;
  final String? webPage;
  const WebViewExample({super.key, this.userModel, this.webPage});
  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  UserModel? myUserModel;
  String? mywebPage;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    mywebPage = widget.webPage;
    String? memberId = myUserModel!.id;
    String? memberCode = myUserModel!.customerCode;
    String webPage = mywebPage.toString();

    String? urlView =
        'https://www.ptnpharma.com/shop/pages/tables/orderhistory_mb.php?memberId=$memberId&memberCode=$memberCode'; //
    String? txtTitle = 'หน้า.....';

    if (webPage == 'pay') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/forms/pay_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
      txtTitle = 'การชำระเงิน';
    } else if (webPage == 'orn') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/tables/orn_list_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
      txtTitle = 'ตรวจสอบใบส่งของ';
    } else if (webPage == 'reward') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/tables/reward_list_mb.php?memberId=$memberId&memberCode=$memberCode'; //
      txtTitle = 'รายการของสมนาคุณ ';
    } else {
      urlView =
          'https://www.ptnpharma.com/shop/pages/forms/complain_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
      txtTitle = 'แจ้งร้องเรียน';
    }

    // #docregion webview_controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(urlView));
    // #enddocregion webview_controller
  }

  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          iconTheme: IconThemeData(color: Colors.white),
          title:
              const Text('PTN Pharma', style: TextStyle(color: Colors.white))),
      body: WebViewWidget(controller: controller),
    );
  }

  // #enddocregion webview_widget
}
