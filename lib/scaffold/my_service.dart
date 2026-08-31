import 'dart:convert';

// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/scaffold/authen.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/category_model.dart';

import 'package:ptncenter/scaffold/list_news.dart';
import 'package:ptncenter/scaffold/list_notify.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/widget/contact.dart';
import 'package:ptncenter/widget/home.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:ptncenter/scaffold/payment_ornlist.dart';
import 'package:ptncenter/scaffold/reward_list.dart';
import 'package:ptncenter/scaffold/suggestion_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'detail_cart.dart';

import 'package:flutter/services.dart';

// import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';

// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'package:webview_flutter/webview_flutter.dart';

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
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId&screen=service';
    // print('url readCart >> $url');
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    // print('cartList >> $cartList');

    if (cartList != null) {
      for (var _ in cartList) {
        setState(() {
          amontCart = amontCart! + 1;
        });
      }
    }
    // print('amontCart (service page))>>>> $amontCart');
  }

  Future<void> readCategory() async {
    String url = 'https://ptnpharma.com/jsonData/category.json';
    // print('url readCategory >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var cateList = json.decode(response.body);
    // print('cateList >> $cateList');
    for (var map in cateList) {
      CategoryModel? categoryModel = CategoryModel.fromJson(map);
      if (categoryModel.cateId == 2) {
        continue;
      }
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
    Navigator.of(context).push(materialPageRoute);
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

  Widget drawerIcon(IconData iconData, Color tint, Color iconColor) {
    return Container(
      width: 42.0,
      height: 42.0,
      decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
      child: Icon(iconData, color: iconColor, size: 22.0),
    );
  }

  Widget drawerTile({
    required IconData icon,
    required String label,
    required Color tint,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      leading: drawerIcon(icon, tint, iconColor),
      title: Text(label, style: MyStyle().tileLabelStyle),
      trailing: Icon(Icons.chevron_right, size: 20.0, color: MyStyle().mutedTextColor),
      onTap: onTap,
    );
  }

  Widget menuHome() {
    return drawerTile(
      icon: Icons.home_rounded,
      label: 'หน้าหลัก',
      tint: MyStyle().tileTints[0],
      iconColor: MyStyle().tileIconColors[0],
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
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16.0),
        leading: drawerIcon(
          Icons.category_rounded,
          MyStyle().tileTints[1],
          MyStyle().tileIconColors[1],
        ),
        title: Text('หมวดสินค้า', style: MyStyle().tileLabelStyle),
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.only(left: 72.0, right: 16.0),
            dense: true,
            visualDensity: VisualDensity(vertical: -4),
            minVerticalPadding: 0,
            title: Text('สินค้าทั้งหมด', style: MyStyle().h4StyleGray),
            onTap: () => routeToListProduct(0),
          ),
          ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            controller: scrollController,
            itemCount: categoryModels!.length,
            itemBuilder: (BuildContext buildContext, int index) {
              return ListTile(
                contentPadding: EdgeInsets.only(left: 72.0, right: 16.0),
                dense: true,
                title: Text(
                  categoryModels![index].cateName!,
                  style: MyStyle().h4StyleGray,
                ),
                onTap: () => routeToListProductByCate(
                  5,
                  categoryModels![index].cateId!,
                  categoryModels![index].cateName!,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget menuexpandCate() {}

  Widget menuLogOut() {
    return drawerTile(
      icon: Icons.exit_to_app_rounded,
      label: 'ออกจากระบบ',
      tint: Color(0xFFFDE8EF),
      iconColor: MyStyle().alertColor,
      onTap: () {
        logOut();
      },
    );
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();

    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return Authen();
      },
    );
    Navigator.of(context)
        .pushAndRemoveUntil(materialPageRoute, (Route<dynamic> route) => false);
  }

  Widget menuContact() {
    return drawerTile(
      icon: Icons.storefront_rounded,
      label: 'ติดต่อเรา',
      tint: MyStyle().tileTints[4],
      iconColor: MyStyle().tileIconColors[4],
      onTap: () {
        setState(() {
          currentWidget = Contact();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget menuNews() {
    return drawerTile(
      icon: Icons.article_rounded,
      label: 'ข่าวสาร',
      tint: MyStyle().tileTints[1],
      iconColor: MyStyle().tileIconColors[1],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => News(userModel: myUserModel!),
          ),
        );
      },
    );
  }

  Widget menuPay() {
    return drawerTile(
      icon: Icons.payments_rounded,
      label: 'การชำระเงิน',
      tint: MyStyle().tileTints[2],
      iconColor: MyStyle().tileIconColors[2],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentOrnList(userModel: myUserModel!),
          ),
        );
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
    return drawerTile(
      icon: Icons.workspace_premium_rounded,
      label: 'ของสมนาคุณ',
      tint: MyStyle().tileTints[3],
      iconColor: MyStyle().tileIconColors[3],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RewardList(userModel: myUserModel!),
          ),
        );
      },
    );
  }

  Widget menuComplain() {
    return drawerTile(
      icon: Icons.comment_rounded,
      label: 'ข้อเสนอแนะ',
      tint: MyStyle().tileTints[5],
      iconColor: MyStyle().tileIconColors[5],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuggestionForm(userModel: myUserModel!),
          ),
        );
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
      login,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black45, blurRadius: 4.0)],
      ),
    );
  }

  Widget showLogo() {
    return Container(
      width: 68.0,
      height: 68.0,
      child: Image.asset('images/logo_master.png', fit: BoxFit.contain),
    );
  }

  Widget headDrawer() {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/pharma.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.05),
              Colors.black.withOpacity(0.55),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            showLogo(),
            SizedBox(height: 10.0),
            showLogin(),
            SizedBox(height: 2.0),
            Text(
              'ยินดีต้อนรับ',
              style: TextStyle(fontSize: 12.0, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget showDrawer() {
    return Drawer(
      backgroundColor: MyStyle().scaffoldBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          headDrawer(),
          SizedBox(height: 6.0),
          menuHome(),
          menuCategory(),
          menuPay(),
          menuReward(),
          menuNews(),
          menuContact(),
          menuComplain(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Divider(color: MyStyle().borderColor, height: 1.0),
          ),
          menuLogOut(),
          SizedBox(height: 12.0),
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
    return PopScope(
      canPop: false,
      child: Scaffold(
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
      ),
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

    if (webPage == 'pay') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/forms/pay_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
    } else if (webPage == 'orn') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/tables/orn_list_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
    } else {
      urlView =
          'https://www.ptnpharma.com/shop/pages/forms/complain_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
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
