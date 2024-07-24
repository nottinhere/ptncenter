import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/scaffold/authen.dart';
import 'package:ptncenter/scaffold/detail_notify.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class Notify extends StatefulWidget {
  final UserModel userModel;
  bool firstLoadAds;

  Notify({Key key, this.userModel, this.firstLoadAds = false})
      : super(key: key);

  @override
  _NotifyState createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  // Explicit
  // List<PromoteModel> promoteModels = List();
  List<Widget> promoteLists = List();
  List<Widget> suggestLists = List();
  List<Widget> slideshowLists = List();
  List<Widget> notifyLists = List();
  List<String> urlImages = List();
  List<String> urlImagesSuggest = List();
  List<String> productsName = List();
  // List<String> subjectList = List();
  // List<String> postdateList = List();

  ScrollController scrollController = ScrollController();

  int amontCart = 0, banerIndex = 0, suggestIndex = 0;
  UserModel myUserModel;
  PopupModel popupModel;
  PopupModel notifyModel;

  bool firstLoad = false;
  List<PopupModel> popupAllModel = List();
  List<PopupModel> notifyModels = List();

  String qrString;
  int currentIndex = 0;
  String _result = '';

  // Method
  @override
  void initState() {
    super.initState();

    myUserModel = widget.userModel;
    setState(() {
      readCart();
    });
    readNotify();
  }

  /*************************** */

  Future<void> readNotify() async {
    String memberId = myUserModel.id;
    String url =
        'https://www.ptnpharma.com/apishop/json_notify.php?limit=10&memberId=$memberId'; // ?memberId=$memberId
    print('urlNotify >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemNotify =
        result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    for (var map in mapItemNotify) {
      PopupModel popupModel = PopupModel.fromJson(map);
      String postdate = popupModel.postdate;
      String subject = popupModel.subject;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        notifyModels.add(popupModel);
        // subjectList.add(subject);
        // postdateList.add(postdate);
      });
    }
    // print('notifyModels.length (readNotify) >> ' + notifyModels.length.toString());
  }

  Widget showNotify() {
    print('notifyModels.length (showNotify) >> ' +
        notifyModels.length.toString());

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      child: notifyModels.length > 0 ? listNotify() : Container(),
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

  Widget listNotify() {
    Duration duration = new Duration();
    final now = new DateTime.now();
    return ListView.builder(
      controller: scrollController,
      itemCount: notifyModels.length,
      itemBuilder: (BuildContext buildContext, int index) {
        return Column(
          children: [
            // Text(notifyLists.length.toString()),
            GestureDetector(
              child: Column(
                children: [
                  DateChip(
                    // date: new DateTime(now.year, now.month, now.day - 1),
                    date: new DateTime(now.year, now.month,
                        now.day - int.parse(notifyModels[index].diffdate)),
                  ),
                  Container(
                      height: 70,
                      child: BubbleSpecialOne(
                        text: notifyModels[index].subject,
                        isSender: false,
                        color: Color(0xFF1B97F3),
                        tail: true,
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      )
                      // Card(
                      //   child: Container(
                      //     decoration: myBoxDecoration(),
                      //     padding: EdgeInsets.only(top: 1.5),
                      //     child: Row(
                      //       children: <Widget>[
                      //         Flexible(
                      //           child: Text(
                      //             notifyModels[index].subject,
                      //             style: MyStyle().h3Style,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      ),
                ],
              ),
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return DetailNotify(
                    popupModel: notifyModels[index],
                    userModel: myUserModel,
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

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel.id.toString();
    String url =
        'https://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    if (cartList != null) {
      for (var map in cartList) {
        setState(() {
          amontCart++;
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

  Widget _buttonWidget({
    String title,
    VoidCallback onClick,
  }) {
    return ElevatedButton(
      onPressed: () => onClick(),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          //showCart(),
        ],
        backgroundColor: MyStyle().barColor,
        title: Text('การแจ้งเตือน'),
      ),
      body: Column(
        children: <Widget>[
          showNotify(),
        ],
      ),
      // bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
    );
  }
}
