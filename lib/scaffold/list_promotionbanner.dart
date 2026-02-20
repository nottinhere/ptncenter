import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/promote_model.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/scaffold/authen.dart';
import 'package:ptncenter/scaffold/detail_notify.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/scaffold/list_notify.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_service.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class Promotionbanner extends StatefulWidget {
  final UserModel? userModel;

  Promotionbanner({Key? key, this.userModel}) : super(key: key);

  @override
  _PromotionbannerState createState() => _PromotionbannerState();
}

class _PromotionbannerState extends State<Promotionbanner> {
  // Explicit
  // List<PromoteModel> promoteModels;
  List<Widget>? promoteLists;
  List<Widget>? suggestLists;
  List<Widget>? slideshowLists = [];
  List<Widget>? notifyLists;
  List<String>? urlImages = [];
  List<String>? urlImagesSuggest;
  List<String>? productsName;
  // List<String> subjectList;
  // List<String> postdateList;
  int selectIndex = 3;

  ScrollController scrollController = ScrollController();

  int amontCart = 0, banerIndex = 0, suggestIndex = 0;
  UserModel? myUserModel;
  PopupModel? popupModel;
  PromoteModel? promoteModel;

  bool firstLoad = false;
  List<ProductAllModel>? slideshowModels = [];

  String? qrString;
  int? currentIndex = 0;
  String? _result = '';

  // Method
  @override
  void initState() {
    super.initState();

    myUserModel = widget.userModel;
    setState(() {
      readCart();
    });
    readSlide();
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
      print('slideshowLists (readSlide) >> $slideshowLists ');
    }
  }

  Widget showSlide() {
    print('slideshowModels.length (showNotify) >> ' +
        slideshowModels!.length.toString());

    return Container(
      width: MediaQuery.of(context).size.width * 0.99,
      height: MediaQuery.of(context).size.height * 0.8,
      child: slideshowModels!.length > 0 ? listSlide() : Container(),
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
              userModel: myUserModel,
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

  Widget listSlide() {
    Duration duration = new Duration();
    final now = new DateTime.now();
    return ListView.builder(
      controller: scrollController,
      itemCount: slideshowModels!.length,
      itemBuilder: (BuildContext buildContext, int index) {
        return Column(
          children: [
            // Text(notifyLists.length.toString()),
            GestureDetector(
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(1.0),
                  child: Center(
                    child: Image.network(urlImages![index],
                        fit: BoxFit.cover, width: 280),
                  ),
                ),
              ),
              onTap: () {
                print('You Click index >> $index');
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return ListProduct(
                    index: 6,
                    userModel: myUserModel!,
                    cateName: slideshowModels![index].title.toString(),
                    searchStr: slideshowModels![index].productCode.toString(),
                  );
                });
                Navigator.of(context)
                    .push(materialPageRoute)
                    .then((value) => readCart());
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel!.id.toString();
    String url =
        'https://www.ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId&screen=promotionbanner';

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

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 30.0,
    );
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

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return DetailCart(userModel: myUserModel);
      },
    );
    Navigator.of(context).push(materialPageRoute);
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

  Widget stylishBottomBar() {
    int? unread =
        myUserModel!.lastNewsId!.toInt() - myUserModel!.lastNewsOpen!.toInt();
    return StylishBottomBar(
      //  option: AnimatedBarOptions(
      //    iconSize: 32,
      //    barAnimation: BarAnimation.liquid,
      //    iconStyle: IconStyle.animated,
      //    opacity: 0.3,
      //  ),

      // option: BubbleBarOptions(
      //   barStyle: BubbleBarStyle.horizontal,
      //   // barStyle: BubbleBarStyle.vertical,
      //   bubbleFillStyle: BubbleFillStyle.fill,
      //   // bubbleFillStyle: BubbleFillStyle.outlined,
      //   opacity: 0.3,
      // ),

      // option: DotBarOptions(
      //   dotStyle: DotStyle.tile,
      //   gradient: const LinearGradient(
      //     colors: [
      //       Colors.deepPurple,
      //       Colors.pink,
      //     ],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      // ),
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
          icon: const Icon(Icons.favorite),
          title: const Text('Favorite'),
          backgroundColor: Colors.red,
        ),
        BottomBarItem(
          icon: const Icon(Icons.shopping_cart),
          title: const Text('Cart'),
          backgroundColor: Colors.brown,
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
              builder: (value) => MyService(
                userModel: myUserModel,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            routeToListProduct(0);
          } else if (index == 2) {
            routeToListProductfav(0);
          } else if (index == 3) {
            routeToDetailCart();
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
          //showCart(),
        ],
        backgroundColor: MyStyle().barColor,
        title: Text('โปรโมชันทั้งหมด', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          showSlide(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }
}
