import 'dart:convert';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/popup_model.dart';

import 'package:ptncenter/analytics.dart';

import 'package:ptncenter/models/promote_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/authen.dart';
import 'package:ptncenter/scaffold/detail.dart';
import 'package:ptncenter/scaffold/detail_news.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';

import 'package:ptncenter/scaffold/list_news.dart';
import 'package:ptncenter/scaffold/list_notify.dart';

import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:ptncenter/scaffold/list_product_frequent.dart';
import 'package:ptncenter/scaffold/list_product_vote.dart';
import 'package:ptncenter/scaffold/map.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'package:popup_banner/popup_banner.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
// import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:status_alert/status_alert.dart';

class Home extends StatefulWidget {
  final UserModel? userModel;
  bool? firstLoadAds;
  bool? orderSuccess;

  Home(
      {Key? key,
      this.userModel,
      this.firstLoadAds = false,
      this.orderSuccess = false})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Explicit
  // List<PromoteModel> promoteModels;
  List<Widget>? promoteLists;
  List<Widget>? suggestLists;
  List<Widget>? slideshowLists;
  List<Widget>? newsLists;
  List<String>? urlImages;
  List<String>? urlImagesSuggest;
  List<String>? productsName;
  // List<String> subjectList;
  // List<String> postdateList;

  ScrollController scrollController = ScrollController();

  int? amontCart = 0;
  int? banerIndex = 0;
  int? suggestIndex = 0;
  UserModel? myUserModel;
  PopupModel? popupModel;
  PopupModel? newsModel;
  PromoteModel? promoteModel;
  bool? orderSuccess;

  bool? firstLoad = false;
  List<ProductAllModel>? promoteModels;
  List<ProductAllModel>? suggestModels;
  List<ProductAllModel>? slideshowModels;
  List<PopupModel>? popupAllModel;
  List<PopupModel>? newsModels;

  String? qrString;
  int? currentIndex = 0;
  String? _result = '';

  /*******       FirebaseAnalytics      *********/

  /*******       FirebaseAnalytics      *********/

  // Method
  @override
  void initState() {
    super.initState();

    /*   Ads banner  next upload 
    print('widget.firstLoadAds >> ${widget.firstLoadAds}');
    firstLoad = widget.firstLoadAds;
    print('firstLoad >> $firstLoad');
    if (firstLoad == true) {
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) => showAdsPopup());
        firstLoad = false;
      });
    }
    print('BF firstLoad >> $firstLoad');
    */
    readPromotion();
    myUserModel = widget.userModel;
    orderSuccess = widget.orderSuccess;

    readSuggest();
    readSlide();
    setState(() {
      readCart();
    });
    directMessage();
    _requestPermission();
    readNews();
    showOrderSuccessPopup();

    // _setFirebase();
  }

  // _setFirebase() async {
  //   FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  //   FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  //   FirebaseAnalytics.instance.setCurrentScreen(screenName: 'MainScreen');
  //   await FirebaseAnalytics.instance
  //       .setUserProperty(name: "PTNCENTER", value: "test");
  //   await FirebaseAnalytics.instance.logEvent(
  //     name: 'PTN_tracking',
  //     parameters: <String, dynamic>{
  //       'page_name': 'MainScreen',
  //       'page_index': 1,
  //     },
  //   );
  // }

  _requestPermission() async {
    await Permission.camera.request();
  }

  /*************************** */
  String _scanBarcode = 'Unknown';

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
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
              userModel: myUserModel!,
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

  Future<void> readPromotion() async {
    String? url = 'https://www.ptnpharma.com/apishop/json_promotion.php';
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    // Map<String, dynamic> map = result['data'];

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

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  /*************************** */

  Future<void> readSlide() async {
    String? url = 'https://www.ptnpharma.com/apishop/json_slideshow.php';
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel? slideshowModel = PromoteModel.fromJson(map);
      ProductAllModel? productAllModel = ProductAllModel.fromJson(map);
      String? urlImage = slideshowModel.photo;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        slideshowModels!.add(productAllModel);
        slideshowLists!.add(showImageNetWork(urlImage!));
        urlImages!.add(urlImage);
      });
    }
  }

  /*************************** */

  Future<void> readSuggest() async {
    String? memId = myUserModel!.id;
    String? url =
        'https://www.ptnpharma.com/apishop/json_suggest.php?memberId=$memId'; // ?memberId=$memberId
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel? promoteModel = PromoteModel.fromJson(map);
      ProductAllModel? productAllModel = ProductAllModel.fromJson(map);
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

  /*************************** */

  Future<void> readNews() async {
    String? memId = myUserModel!.id;
    String? url =
        'https://www.ptnpharma.com/apishop/json_news.php?limit=5'; // ?memberId=$memberId
    print('urlNews >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemNews =
        result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    for (var map in mapItemNews) {
      PopupModel? popupModel = PopupModel.fromJson(map);
      String? postdate = popupModel.postdate;
      String? subject = popupModel.subject;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        newsModels!.add(popupModel);
        // subjectList.add(subject);
        // postdateList.add(postdate);
      });
    }
    // print('newsModels.length (readNews) >> ' + newsModels.length.toString());
  }

  Future<void> showAdsPopup() async {
    PopupBanner(
      context: context,
      images: images,
      onClick: (index) {
        debugPrint("CLICKED $index");
      },
    ).show();
  }

  Future<void> showOrderSuccessPopup() async {
    if (orderSuccess == true) {
      print('--------------- *showOrderSuccessPopup* ------------');
      StatusAlert.show(
        context,
        duration: Duration(seconds: 3),
        title: 'Success',
        subtitle: 'สั่งซื้อเรียบร้อย',
        configuration: IconConfiguration(icon: Icons.done),
        maxWidth: 260,
      );

      // successAlertBox()
      //     .animate()
      //     .fadeOut(duration: 3.seconds)
      //     .then(delay: 5.seconds) // baseline=800ms
      //     .slide();
    }
  }

  Widget? successAlertBox() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Alert(
        context: context,
        type: AlertType.success,
        title: "สั่งซื้อเรียบร้อย",
        desc: "ทางเราจะจัดส่งสินค้าโดยเร็ว",
        alertAnimation: fadeAlertAnimation,
        buttons: [
          // DialogButton(
          //   child: Text(
          //     "OK",
          //     style: TextStyle(color: Colors.white, fontSize: 18),
          //   ),
          //   onPressed: () => Navigator.pop(context),
          //   color: Color.fromRGBO(0, 179, 134, 1.0),
          // ),
        ],
      ).show(),
    );
  }

  Widget fadeAlertAnimation(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Align(
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  /***************popup_banner ************ */
  List<String> images = [
    "https://tinyurl.com/popup-banner-image",
    "https://tinyurl.com/popup-banner-image2",
    "https://tinyurl.com/popup-banner-image3",
    "https://tinyurl.com/popup-banner-image4"
  ];

  List<String> imagesLocal = [
    "assets/images/popup-banner-local-image.jpg",
    "assets/images/popup-banner-local-image2.jpg",
    "assets/images/popup-banner-local-image3.jpeg",
    "assets/images/popup-banner-local-image4.jpg"
  ];

  void showDefaultPopup() {
    PopupBanner(
      context: context,
      images: images,
      onClick: (index) {
        debugPrint("CLICKED $index");
      },
    ).show();
  }

  void showHideDotsPopup() {
    PopupBanner(
      context: context,
      images: images,
      useDots: false,
      onClick: (index) {
        debugPrint("CLICKED $index");
      },
    ).show();
  }

  void showCustomizeDots() {
    PopupBanner(
      context: context,
      images: images,
      dotsAlignment: Alignment.bottomCenter,
      dotsColorActive: Colors.blue,
      dotsColorInactive: Colors.grey.withOpacity(0.5),
      onClick: (index) {
        debugPrint("CLICKED $index");
      },
    ).show();
  }

  void showNonactiveSlideCustomClose() {
    PopupBanner(
      context: context,
      images: images,
      autoSlide: false,
      customCloseButton: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          // primary: Colors.blue,
        ),
        child: const Text(
          "Close",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      onClick: (index) {
        debugPrint("CLICKED $index");
      },
    ).show();
  }

  void showFromLocal() {
    PopupBanner(
      context: context,
      images: imagesLocal,
      fromNetwork: false,
      onClick: (index) {},
    ).show();
  }

  /*************popup_banner ************** */

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  // Widget showCarouseSlider() {
  //   return GestureDetector(
  //     onTap: () {
  //       print('You Click index is $banerIndex');

  //       MaterialPageRoute route = MaterialPageRoute(
  //         builder: (BuildContext context) => Detail(
  //           productAllModel: promoteModel![banerIndex],
  //           userModel: myUserModel!,
  //         ),
  //       );
  //       // Navigator.of(context).push(route).then((value) {});  //  link to detail page
  //     },
  //     child: CarouselSlider(
  //       options: CarouselOptions(
  //         height: 1500,
  //         viewportFraction: 0.8,
  //         enlargeCenterPage: true,
  //         aspectRatio: 16 / 9,
  //         // pauseAutoPlayOnTouch: Duration(seconds: 5),
  //         autoPlay: true,
  //         autoPlayAnimationDuration: Duration(seconds: 5),
  //         onPageChanged: (int index, reason) {
  //           banerIndex = index;
  //           // print('index = $index');
  //         },
  //       ),
  //       items: promoteLists,
  //     ),
  //   );
  // }

  Widget showCarouseSliderSuggest() {
    return GestureDetector(
      child: CarouselSlider.builder(
        options: CarouselOptions(
          // pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlay: true,
          autoPlayAnimationDuration: Duration(seconds: 5),
        ),
        itemCount: (suggestLists!.length / 2).round(),
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
                            child: suggestLists![idx],
                            padding: EdgeInsets.all(8.0),
                          ),
                          Text(
                            productsName![idx].toString(),
                            style: TextStyle(
                                fontSize: 12,
                                // fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      MaterialPageRoute materialPageRoute = MaterialPageRoute(
                          builder: (BuildContext buildContext) {
                        return Detail(
                          productAllModel: suggestModels![idx],
                          userModel: myUserModel!,
                        );
                      });
                      Navigator.of(context)
                          .push(materialPageRoute)
                          .then((value) => readCart());
                    }),
              );
            }).toList(),
          );
        },
      ),
    );
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

  Widget showCarouseSlideshow() {
    return GestureDetector(
      child: CarouselSlider.builder(
        options: CarouselOptions(
          // pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlay: true,
          autoPlayAnimationDuration: Duration(seconds: 5),
        ),
        itemCount: (slideshowLists!.length).round(),
        itemBuilder: (context, index, realIdx) {
          final int first = index;
          // final int second = first + 1;
          return Row(
            children: [first].map((idx) {
              return InkWell(
                child: Container(
                  padding: EdgeInsets.all(1.0),
                  child: Center(
                    child: Image.network(urlImages![idx],
                        fit: BoxFit.cover, width: 280),
                  ),
                ),
                onTap: () {
                  print('You Click index >> $idx');
                  MaterialPageRoute materialPageRoute =
                      MaterialPageRoute(builder: (BuildContext buildContext) {
                    return ListProduct(
                      index: 6,
                      userModel: myUserModel!,
                      cateName: slideshowModels![idx].title.toString(),
                      searchStr: slideshowModels![idx].productCode.toString(),
                    );
                  });
                  Navigator.of(context)
                      .push(materialPageRoute)
                      .then((value) => readCart());
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Widget promotion() {
  //   return Card(
  //     child: Container(
  //       width: MediaQuery.of(context).size.width * 0.9,
  //       padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
  //       height: MediaQuery.of(context).size.width * 0.70, // size.height * 0.20,
  //       child: promoteLists!.length == 0
  //           ? myCircularProgress()
  //           : showCarouseSlider(),
  //     ),
  //   );
  // }

  Widget suggest() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.25,
        child: suggestLists!.length == 0
            ? myCircularProgress()
            : showCarouseSliderSuggest(),
      ),
    );
  }

  Widget slideshow() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.25,
        child: suggestLists!.length == 0
            ? myCircularProgress()
            : showCarouseSlideshow(),
      ),
    );
  }

  Widget showNews() {
    print('newsModels.length (showNews) >> ' + newsModels!.length.toString());

    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.4,
        child: newsModels!.length > 0 ? listNews() : Container(),
      ),
    );
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

  Widget orderhistoryBox() {
    String? login = myUserModel!.name;
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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () async {
          // await FirebaseAnalytics.instance.logEvent(
          //   name: 'PTN_tracking',
          //   parameters: <String, dynamic>{
          //     'page_name': 'ProductScreen',
          //     'page_index': 1,
          //   },
          // );
          print('You click product');
          routeToListProduct(0);
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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        onTap: () async {
          print('You click not receive');
          routeToListProduct(4);
        },
      ),
    );
  }

  Widget frequentBox() {
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
                  'สินค้าสั่งประจำ',
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
          print('You click product');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductFrequent(
              userModel: myUserModel!,
            );
          });
          Navigator.of(context).push(materialPageRoute);
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
                      fontSize: 17,
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
                      fontSize: 17,
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
                      fontSize: 17,
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
                      fontSize: 17,
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
              userModel: myUserModel!,
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
                      fontSize: 17,
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
                        userModel: myUserModel!,
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
                  'Scan',
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
          print('You click barcode scan');
          // readQRcodePreview();
          scanBarcodeNormal();
        },
      ),
    );
  }

  Widget favariteBox() {
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
                  child: Image.asset('images/icon_favarite.png'),
                ),
                Text(
                  'สินค้าโปรด',
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
          print('You click barcode scan');
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductfav(
              // index: index,
              userModel: myUserModel!,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
      ),
    );
  }

  Widget voteBox() {
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
                  child: Image.asset('images/icon_vote.png'),
                ),
                Text(
                  'โหวตยาน่าขาย',
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
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return ListProductvote(
              userModel: myUserModel!,
            );
          });
          Navigator.of(context).push(materialPageRoute);
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
        // bottom: BorderSide(
        //   color: Colors.blueGrey.shade100,
        //   width: 1.0,
        // ),
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
                      fontSize: 17,
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

  Widget listNews() {
    return ListView.builder(
      controller: scrollController,
      itemCount: newsModels!.length,
      itemBuilder: (BuildContext buildContext, int index) {
        return Column(
          children: [
            // Text(newsLists.length.toString()),
            GestureDetector(
              child: Container(
                height: 70,
                child: Card(
                  child: Container(
                    decoration: myBoxDecoration(),
                    padding: EdgeInsets.only(top: 1.5),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            newsModels![index].subject!,
                            style: MyStyle().h3Style,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return DetailNews(
                    popupModel: newsModels![index],
                    userModel: myUserModel!,
                  );
                });
                Navigator.of(context).push(materialPageRoute);
              },
            ),
          ],
        );
      },
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
        frequentBox(),
      ],
    );
  }

  Widget row4Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        favariteBox(),
        voteBox(),
      ],
    );
  }

  Widget row5Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        barcodeBox(),
        // cartBox(),
        historyBox(),
      ],
    );
  }

  Widget row6Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // frequentBox(),
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
        readQRcode();
        // readQRcodePreview();
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
    String memberId = myUserModel!.id.toString();
    String url =
        'https://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    if (cartList != null) {
      for (var map in cartList) {
        setState(() {
          amontCart = amontCart! + 1;
        });
        // print('amontCart (service page))>>>> $amontCart');
      }
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
              userModel: myUserModel!,
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

  // Widget successBox() {
  //   return Text(
  //     'สั่งซื้อเรียบร้อย',
  //     style: TextStyle(
  //       fontSize: 32,
  //       fontWeight: FontWeight.bold,
  //       color: MyStyle().textColor,
  //     ),
  //   )
  //       .animate()
  //       .fadeOut(duration: 3.seconds)
  //       .then(delay: 5.seconds) // baseline=800ms
  //       .slide();
  // }

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
          // ElevatedButton(
          //   child: Text('Basic Alert'),
          //   onPressed: () => _onBasicAlertPressed(context),
          // ),
          // ElevatedButton(
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
          // mySizebox(),
          row5Menu(),
          // mySizebox(),
          // row6Menu(),
        ],
      ),
    );
  }

  Future<void>? directMessage() {
    String? msg = myUserModel!.msg;
    if (msg != '') {
      // ToastView.createView(msg, context, Toast.LENGTH_LONG, Toast.BOTTOM,
      //     Colors.red, Colors.white, 200, null);
      Toast.show(msg!,
          duration: Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? login = myUserModel!.name;
    String? loginStatus = myUserModel!.status;
    String? msg = myUserModel!.msg;
    int? unread = myUserModel!.lastNewsId! - myUserModel!.lastNewsOpen!;

    if (loginStatus == '1') {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            profileBox(),
            headTitle('สินค้าแนะนำ', Icons.thumb_up), //($loginStatus)
            slideshow(),
            headTitle('เมนู', Icons.home),
            homeMenu(),
            headTitle('ข่าวสาร', Icons.home),
            showNews(),
          ],
        ),
      );
    } else {
      return Text('กรุณาติดต่อ PTN Pharma');
    }
  }

  void showToast(String? msg, {int? duration, int? gravity}) {
    Toast.show(msg!, duration: duration, gravity: gravity);
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

  Widget _buttonWidget({
    String? title,
    VoidCallback? onClick,
  }) {
    return ElevatedButton(
      // onPressed: () => onClick(),
      onPressed: () => () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      child: Text(
        title!,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}

class WebViewWidget extends StatefulWidget {
  WebViewWidget({Key? key}) : super(key: key);

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
                child: TextButton(
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
  final UserModel? userModel;

  WebView({Key? key, this.userModel}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  UserModel? myUserModel;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
  }

  @override
  Widget build(BuildContext context) {
    String? memberId = myUserModel!.id;
    String? memberCode = myUserModel!.customerCode;
    String? url =
        'https://ptnpharma.com/shop/pages/tables/orderhistory_mb.php?memberId=$memberId&memberCode=$memberCode'; //
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
