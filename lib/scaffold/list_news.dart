import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/scaffold/detail_news.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';

import 'package:ptncenter/utility/my_style.dart';

import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class News extends StatefulWidget {
  final UserModel? userModel;
  bool? firstLoadAds;

  News({Key? key, this.userModel, this.firstLoadAds = false}) : super(key: key);

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
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

  int amontCart = 0, banerIndex = 0, suggestIndex = 0;
  UserModel? myUserModel;
  PopupModel? popupModel;
  PopupModel? newsModel;

  bool firstLoad = false;
  List<PopupModel>? popupAllModel;
  List<PopupModel> newsModels = [];

  String? qrString;
  int? currentIndex = 0;

  static const int perPage = 12;
  int page = 1;
  bool isLoadingMore = false;
  bool hasMore = true;

  // Method
  @override
  void initState() {
    super.initState();

    myUserModel = widget.userModel;
    setState(() {
      readCart();
    });
    createController(); // เมื่อ scroll to bottom
    readNews();
  }

  /*************************** */

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (!isLoadingMore && hasMore) {
            page = page + 1;
            readNews();
            print('in the end');
          }
        }
      }
    });
  }

  Future<void> readNews() async {
    setState(() {
      isLoadingMore = true;
    });

    String? memberId = myUserModel!.id;
    
    String url = '${MyStyle().serverName}/json_news.php'
        '?memberId=$memberId&page=$page&limit=$perPage';
    print('urlNews >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemNews =
        result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    List<PopupModel> fetchedModels = [];
    for (var map in mapItemNews) {
      fetchedModels.add(PopupModel.fromJson(map));
    }

    setState(() {
      newsModels.addAll(fetchedModels);
      hasMore = fetchedModels.length >= perPage;
      isLoadingMore = false;
    });
    // print('newsModels.length (readNews) >> ' + newsModels.length.toString());
  }

  Widget myLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.green,
          size: 24,
        ),
      ),
    );
  }

  Widget showNews() {
    print('newsModels.length (showNews) >> ' + newsModels.length.toString());

    if (newsModels.isEmpty) {
      return isLoadingMore
          ? myLoadingIndicator()
          : Center(child: Text('ไม่พบข่าวสาร', style: MyStyle().h4StyleGray));
    }
    return listNews();
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

  Widget newsCard(PopupModel news) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: () {
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return DetailNews(
              popupModel: news,
              userModel: myUserModel!,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        },
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(MyStyle().radiusS),
            border: Border.all(color: MyStyle().borderColor),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: MyStyle().primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.campaign_rounded,
                    color: MyStyle().mainColor, size: 20.0),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  '${news.subject}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MyStyle().h3Style,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: MyStyle().mutedTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget listNews() {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: newsModels.length + (hasMore ? 1 : 0),
      itemBuilder: (BuildContext buildContext, int index) {
        if (index >= newsModels.length) {
          return myLoadingIndicator();
        }
        return newsCard(newsModels[index]);
      },
    );
  }

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel!.id.toString();
    String url =
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId&screen=listnews';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    if (cartList != null) {
      for (var _ in cartList) {
        setState(() {
          amontCart = amontCart! + 1;
        });
        // print('amontCart (service page))>>>> $amontCart');
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          //showCart(),
        ],
        backgroundColor: MyStyle().barColor,
        title: Text('ข่าวสาร', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: showNews()),
        ],
      ),
      // bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
    );
  }
}
