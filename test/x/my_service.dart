import 'dart:convert';
import 'dart:io';

// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/main.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/category_model.dart';

import 'package:ptncenter/scaffold/list_news.dart';
import 'package:ptncenter/scaffold/list_notify.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:ptncenter/widget/contact.dart';
import 'package:ptncenter/widget/home.dart';
import 'package:ptncenter/widget/homescreen.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_cart.dart';
import 'package:toast/toast.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
// import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';

// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class MyService extends StatefulWidget {
  final UserModel? userModel;
  bool? firstLoadAds;
  bool? orderSuccess;
  MyService(
      {Key? key,
      this.userModel,
      this.firstLoadAds = false,
      this.orderSuccess = false})
      : super(key: key);

  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  //Explicit
  List<CategoryModel>? categoryModels; // set array
  UserModel? myUserModel;
  String? mywebPage;
  Widget? currentWidget;
  String? qrString;
  int? amontCart = 0;
  int? currentIndex;
  ScrollController? scrollController = ScrollController();
  // String? _result = '';

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
      print('start  initState');
      // readCart();
      // readCategory(); // read  ข้อมูลมาแสดง
      print('end  initState');
    });
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel!,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProductfav(
        index: index,
        userModel: myUserModel!,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductByCate(int index, int cate, String cateName) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel!,
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
        userModel: myUserModel!,
      );
    });
    Navigator.of(context).push(materialPageRoute);
    // int unread;
    // Navigator.of(context).push(materialPageRoute).then((value) => unread = 0);
  }

  void routeToNotify() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return Notify(
        userModel: myUserModel!,
      );
    });
    int unread;
    // Navigator.of(context).push(materialPageRoute);
    Navigator.of(context).push(materialPageRoute).then((value) => unread = 0);
  }

  // void changePage(int? index) {
  //   setState(() {
  //     currentIndex = index;
  //   });

  //   //You can have a switch case to Navigate to different pages
  //   switch (currentIndex) {
  //     case 0:
  //       break; // home
  //     case 1:
  //       routeToListProductfav(0);
  //       break; // all product
  //     case 2:
  //       routeToListProduct(0);
  //       break; // all product
  //     case 3:
  //       routeToNotify();
  //       break; // Shopping cart

  //     // case 2:  routeToListProduct(2);   break;  // promotion
  //     // case 3:  routeToListProduct(3);   break;  // update price
  //     // case 4:  routeToListProduct(1);   break;  // new item
  //   }
  // }

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
          // readCart();
          currentWidget = Home(
            userModel: myUserModel!,
          );
        });
        Navigator.of(context).pop();
      },
    );
  }

  // Widget menuCategory() {
  //   print('menuCategory >> ' + categoryModels!.length.toString());
  //   return ExpansionTile(
  //     leading: Icon(
  //       Icons.category,
  //       size: 36.0,
  //     ),
  //     title: Text('หมวดสินค้า'),
  //     children: <Widget>[
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //         child: Align(
  //           alignment: Alignment.topLeft,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: <Widget>[
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: <Widget>[
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: new InkWell(
  //                         child: Text(
  //                           ' - สินค้าทั้งหมด',
  //                           style: TextStyle(fontSize: 16, color: Colors.black),
  //                         ),
  //                         onTap: () => routeToListProduct(
  //                             0)), //  routeToListProductByCate(6, 0, 'สินค้าทั้งหมด')),
  //                   ),
  //                   ListView.builder(
  //                       scrollDirection: Axis.vertical,
  //                       shrinkWrap: true,
  //                       controller: scrollController,
  //                       itemCount: categoryModels!.length,
  //                       itemBuilder: (BuildContext buildContext, int index) {
  //                         return Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: new InkWell(
  //                               child: Text(
  //                                 ' - ' + categoryModels![index].cateName!,
  //                                 style: TextStyle(
  //                                     fontSize: 16, color: Colors.black),
  //                               ),
  //                               onTap: () => routeToListProductByCate(
  //                                   5,
  //                                   categoryModels![index].cateId!,
  //                                   categoryModels![index].cateName!)),
  //                         );
  //                       }),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget menuexpandCate() {}

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
    // exit(0);
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return MyApp();
    });
    Navigator.of(context).push(materialPageRoute);
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
        Icons.payments,
        size: 36.0,
      ),
      title: Text('แจ้งชำระเงิน'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
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
      leading: Icon(
        Icons.checklist,
        size: 36.0,
      ),
      title: Text('ตรวจสอบใบส่งของ'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
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
      leading: Icon(
        Icons.workspace_premium,
        size: 36.0,
      ),
      title: Text('ของสมนาคุณ'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
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
      leading: Icon(
        Icons.comment,
        size: 36.0,
      ),
      title: Text('แจ้งร้องเรียน'),
      // subtitle: Text('Read QR code or barcode'),
      onTap: () {
        print('You click $webPage');
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
      leading: Icon(
        Icons.photo_camera,
        size: 36.0,
      ),
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
      style: TextStyle(
        fontSize: 24.0,
        color: MyStyle().textColor,
      ),
    );
  }

  Widget showLogin() {
    String login = myUserModel!.name!;
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
          // menuCategory(),
          menuORN(),
          menuPay(),
          menuReward(),
          menuContact(),
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
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailCart(
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute).then((value) {
      setState(() {
        print('Here is routeToDetailCart');

        // readCart();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          showCart(),
        ],
        backgroundColor: MyStyle().bgColor,
        title: Text('หน้าหลัก'),
        // centerTitle: true,
      ),

      body: currentWidget,
      drawer: showDrawer(),
      // bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
    );
  }
}
