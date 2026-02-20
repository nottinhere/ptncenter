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
import 'package:ptncenter/scaffold/list_promotionbanner.dart';

import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:ptncenter/scaffold/list_product_frequent.dart';
import 'package:ptncenter/scaffold/list_product_vote.dart';
import 'package:ptncenter/scaffold/map.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:popup_banner/popup_banner.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import 'package:ptncenter/main.dart';
import 'package:ptncenter/scaffold/my_service.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/scaffold/detail_popup.dart';

import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:webview_flutter_android/webview_flutter_android.dart' as webview_flutter_android;

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
  List<Widget>? slideshowLists = [];
  List<Widget>? newsLists;
  List<String>? urlImages = [];
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
  List<ProductAllModel>? slideshowModels = [];
  List<PopupModel>? popupAllModel;
  List<PopupModel>? newsModels = [];

  String? qrString;
  int? currentIndex = 0;

  // Method
  @override
  void initState() {
    super.initState();

    myUserModel = widget.userModel;
    orderSuccess = widget.orderSuccess;
    // readPromotion();
    // readSuggest();
    readSlide();
    setState(() {
      readCart();
    });
    _requestPermission();
    readNews();
    // showOrderSuccessPopup();
    Future.delayed(Duration.zero, () => showOrderSuccessDialog(context));
    // _setFirebase();
  }



  _requestPermission() async {
    await Permission.camera.request();
  }

  

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  /***************************  */

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
      print('slideshowLists (readSlide) >> $slideshowLists ');
    }
  }

  /*************************** 

  Future<void> readSuggest() async {
    String? memId = myUserModel!.id;
    String? url =
        'https://www.ptnpharma.com/apishop/json_suggest.php?memberId=$memId'; // ?memberId=$memberId
    print('urlSuggest >> $url');

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
*/
  /*************************** */

  Future<void> readNews() async {
    String? memId = myUserModel!.id;
    String? url =
        'https://www.ptnpharma.com/apishop/json_news.php?limit=7'; // ?memberId=$memberId
    print('urlNews >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemNews =
        result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    print('mapItemNews >> $mapItemNews');

    for (var map in mapItemNews) {
      PopupModel? popupModel = PopupModel.fromJson(map);
      // String? postdate = popupModel!.postdate!;
      // String? subject = popupModel!.subject!;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        newsModels!.add(popupModel);
        // subjectList.add(subject);
        // postdateList.add(postdate);
      });
    }
    // print('newsModels.length (readNews) >> $newsModels ');
  }

  // Future<void> showAdsPopup() async {
  //   PopupBanner(
  //     context: context,
  //     images: images,
  //     onClick: (index) {
  //       debugPrint("CLICKED $index");
  //     },
  //   ).show();
  // }

  void showOrderSuccessDialog(BuildContext context) {
    // orderSuccess = true;
    if (orderSuccess == true) {
      AwesomeDialog(
        context: context,
        headerAnimationLoop: false,
        dialogType: DialogType.noHeader,
        autoHide: const Duration(seconds: 5),
        title: 'บันทึกคำสั่งซื้อ',
        desc: 'คำสั่งซื้อของคุณได้ถูกดำเนินการเสร็จสิ้น ',
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
      ).show();
    }
  }

    Future<void> normalDialogLogin(
    BuildContext buildContext,
    String title,
    String message,
  ) async {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.error,
      autoHide: const Duration(seconds: 4),
      title: title,
      desc: message,
      btnOkColor: Colors.red,
      btnOkOnPress: () {
        debugPrint('OnClcik');
      },
      btnOkIcon: Icons.check_circle,
    ).show();
    // showDialog(
    //   context: buildContext,
    //   builder: (BuildContext buildContext) {
    //     return AlertDialog(
    //       title: showTitle(title),
    //       content: Text(message),
    //       actions: <Widget>[okButtonLogin(buildContext)],
    //     );
    //   },
    // );
  }

  Future<void> showOrderSuccessPopup() async {
    if (orderSuccess == true) {
      // print('--------------- *showOrderSuccessPopup* ------------');
      // StatusAlert.show(
      //   context,
      //   duration: Duration(seconds: 3),
      //   title: 'Success',
      //   subtitle: 'สั่งซื้อเรียบร้อย',
      //   configuration: IconConfiguration(icon: Icons.done),
      //   maxWidth: 260,
      // );

      // successAlertBox()
      //     .animate()
      //     .fadeOut(duration: 3.seconds)
      //     .then(delay: 5.seconds) // baseline=800ms
      //     .slide();
    }
  }

  // Widget? successAlertBox() {
  //   WidgetsBinding.instance.addPostFrameCallback(
  //     (_) => Alert(
  //       context: context,
  //       type: AlertType.success,
  //       title: "สั่งซื้อเรียบร้อย",
  //       desc: "ทางเราจะจัดส่งสินค้าโดยเร็ว",
  //       alertAnimation: fadeAlertAnimation,
  //       buttons: [
  //         // DialogButton(
  //         //   child: Text(
  //         //     "OK",
  //         //     style: TextStyle(color: Colors.white, fontSize: 18),
  //         //   ),
  //         //   onPressed: () => Navigator.pop(context),
  //         //   color: Color.fromRGBO(0, 179, 134, 1.0),
  //         // ),
  //       ],
  //     ).show(),
  //   );
  // }

  // Widget fadeAlertAnimation(
  //   BuildContext context,
  //   Animation<double> animation,
  //   Animation<double> secondaryAnimation,
  //   Widget child,
  // ) {
  //   return Align(
  //     child: FadeTransition(
  //       opacity: animation,
  //       child: child,
  //     ),
  //   );
  // }


  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }


  void routeToListProductByCate(int index, int cate, String cateName) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index!,
        userModel: myUserModel!,
        cate: cate!,
        cateName: cateName!,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget showCarouseSlideshow() {
    print('slideshowLists.length (showCarouseSlideshow) >> ' +
        slideshowLists!.length.toString());

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

  Widget slideshow() {
    print('slideshowLists.length (Widget slideshow) >> ' +
        slideshowLists!.length.toString());

    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.25,
        child: slideshowLists!.isEmpty
            ? myCircularProgress()
            : showCarouseSlideshow(),
      ),
    );
  }

  Widget showNews() {
    // print('newsModels.length (showNews) >> ' + newsModels!.length.toString());

    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.4,
        child: newsModels!.isNotEmpty ? listNews() : Container(),
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

  // Widget orderhistoryBox() {
  //   String? login = myUserModel!.name;
  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.8,
  //     // height: 80.0,
  //     child: GestureDetector(
  //       child: Card(
  //         color: Colors.greenAccent.shade100,
  //         child: Container(
  //           padding: EdgeInsets.all(16.0),
  //           alignment: AlignmentDirectional(0.0, 0.0),
  //           child: Row(
  //             children: <Widget>[
  //               Container(
  //                 width: 45.0,
  //                 child: Image.asset('images/icon_drugs.png'),
  //                 padding: EdgeInsets.all(8.0),
  //               ),
  //               Text(
  //                 'ประวัติการสั่งซื้อ',
  //                 style: TextStyle(
  //                     fontSize: 24,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       onTap: () {
  //         print('You click product');
  //         routeToListProduct(0);
  //       },
  //     ),
  //   );
  // }

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.blue.shade300,
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
                  child: Image.asset('images/icon_drugs.png'),
                ),
                Text(
                  'สั่งสินค้า',
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

  Widget promotionbannerBTN() {
    String? login = myUserModel!.name;
    String? address = myUserModel!.address;
    // int loginStatus = myUserModel.status;

    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40), // if you need this
            side: BorderSide(
              color: Colors.blue.shade200,
              width: 2,
            ),
          ),
          color: Color.fromARGB(255, 255, 255, 255),
          child: Container(
            padding: EdgeInsets.all(3.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'โปรโมชันทั้งหมด', // 'ผู้แทน : $login',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ),
        onTap: () {
          print('You click promotion banner');
          // routeToListProduct(0);
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return Promotionbanner(
              userModel: myUserModel!,
            );
          });
          Navigator.of(context).push(materialPageRoute);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.green.shade300,
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

  Widget bestsellerBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.green.shade300,
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
                  child: Image.asset('images/icon_bestseller.png'),
                ),
                Text(
                  'สินค้าขายดี',
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
          print('You click product bestseller');
          routeToListProduct(7);
        },
      ),
    );
  }

  Widget topintrendBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.green.shade300,
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
                  child: Image.asset('images/icon_intrend.png'),
                ),
                Text(
                  'สินค้า Intrend',
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
          print('You click product Intrend');
          routeToListProduct(8);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.green.shade300,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.green.shade300,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.green.shade300,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.green.shade300,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.blue.shade300,
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

  Widget suggestionBox() {
    String webPage = 'suggestion';

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
                  child: Image.asset('images/icon_suggestion.png'),
                ),
                Text(
                  'ข้อเสนอแนะ',
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
          print('You click suggestion');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewExample(
                        userModel: myUserModel!,
                        webPage: webPage,
                      )));
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

  Widget historyBox() {
    String webPage = 'history';

    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.blue.shade300,
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
                  builder: (context) => WebViewExample(
                        userModel: myUserModel!,
                        webPage: webPage,
                      )));
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

  Widget rewardBox() {
    String webPage = 'reward';

    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.blue.shade300,
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
                  child: Image.asset('images/icon_pointredeem.png'),
                ),
                Text(
                  'ของสมนาคุณ',
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
                  builder: (context) => WebViewExample(
                        userModel: myUserModel!,
                        webPage: webPage,
                      )));
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

  // Widget barcodeBox() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.45,
  //     // height: 80.0,
  //     child: GestureDetector(
  //       child: Card(
  //         // color: Colors.green.shade100,
  //         child: Container(
  //           padding: EdgeInsets.all(16.0),
  //           alignment: AlignmentDirectional(0.0, 0.0),
  //           child: Column(
  //             children: <Widget>[
  //               Container(
  //                 width: 45.0,
  //                 child: Image.asset('images/icon_barcode.png'),
  //               ),
  //               Text(
  //                 'Scan',
  //                 style: TextStyle(
  //                     fontSize: 17,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       onTap: () {
  //         print('You click barcode scan');
  //         // readQRcodePreview();
  //         // scanBarcodeNormal();
  //       },
  //     ),
  //   );
  // }

  Widget favariteBox() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.green.shade300,
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

  Widget paymentBox() {
    String webPage = 'pay';
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          // color: Colors.green.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
            side: BorderSide(
              color: Colors.blue.shade300,
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
                  child: Image.asset('images/icon_payment.png'),
                ),
                Text(
                  'การชำระเงิน',
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewExample(
                        userModel: myUserModel!,
                        webPage: webPage,
                      )));
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
    // print('newsModels.length (listNews) >> ' + newsModels!.length.toString());
    return ListView.builder(
      controller: scrollController,
      itemCount: newsModels!.length,
      itemBuilder: (BuildContext buildContext, int index) {
        return Column(
          children: [
            // Text(newsModels!.length.toString()),
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
        paymentBox(),
      ],
    );
  }

  Widget row2Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        historyBox(),
        rewardBox(),
      ],
    );
  }

  Widget row3Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        bestsellerBox(),
        topintrendBox(),
      ],
    );
  }

  Widget row4Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        frequentBox(),
        notreceiveBox(),
      ],
    );
  }

  Widget row5Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        promotionBox(),
        updatepriceBox(),
      ],
    );
  }

  Widget row6Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        newproductBox(),
        favariteBox(),
      ],
    );
  }

  Widget row7Menu() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        voteBox(),
        suggestionBox(),
        // barcodeBox(),
        // cartBox(),
      ],
    );
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 30.0,
    );
  }

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel!.id.toString();
    String url =
        'https://www.ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId&screen=home';

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
          row6Menu(),
          // mySizebox(),
          row7Menu(),
        ],
      ),
    );
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
            // headTitle('สินค้าแนะนำ', Icons.thumb_up), //($loginStatus)
            slideshow(),
            promotionbannerBTN(),
            headTitle('เมนู', Icons.medical_services),
            homeMenu(),
            headTitle('ข่าวสาร', Icons.newspaper),
            showNews(),
          ],
        ),
      );
    } else {
      return Text('กรุณาติดต่อ PTN Pharma');
    }
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
    } else if (webPage == 'history') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/tables/orderhistory_mb.php?memberId=$memberId&memberCode=$memberCode'; //
      txtTitle = 'ประวัติการสั่งซื้อ';
    } else if (webPage == 'reward') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/tables/reward_list_mb.php?memberId=$memberId&memberCode=$memberCode'; //
      txtTitle = 'รายการของสมนาคุณ ';
    } else if (webPage == 'suggestion') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/forms/complain_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
      txtTitle = 'ข้อเสนอแนะ ';
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
