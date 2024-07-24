import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'my_service.dart';

class DetailPopup extends StatefulWidget {
  final PopupModel popupModel;
  final UserModel userModel;

  DetailPopup({Key key, this.popupModel, this.userModel}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<DetailPopup> {
  // Explicit
  PopupModel currentPopupModel;
  PopupModel popupModel;
  UserModel myUserModel;
  String id; // productID
  String memberID;
  String imagePopup = '';
  String textButton = '';
  String textURL = '';
  String subjectPopup = '';
  String detailPopup = '';
  String postdatePopup = '';
  int currentIndex = 1;
  // Method
  @override
  void initState() {
    super.initState();
    currentPopupModel = widget.popupModel;
    myUserModel = widget.userModel;
    setState(() {
      getPopupWhereID();
    });
  }

  Future<void> getPopupWhereID() async {
    String url = 'https://ptnpharma.com/apishop/json_popupdetail.php';
    print('urlPopup >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);

    var mapItemPopup =
        result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    for (var map in mapItemPopup) {
      PopupModel popupModel = PopupModel.fromJson(map);
      String urlImage = popupModel.photo;
      String subject = popupModel.subject;
      String postdate = popupModel.postdate;
      String detail = popupModel.detail;
      String txtBTN = popupModel.txtBTN;
      String txtURL = popupModel.url;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง arra
        subjectPopup = subject;
        imagePopup = urlImage;
        detailPopup = detail;
        postdatePopup = postdate;
        textButton = txtBTN;
        textURL = txtURL;
      });
    } // for
  }

  Widget spaceBox() {
    return SizedBox(
      width: 10.0,
      height: 16.0,
    );
  }

  Widget showTitle() {
    return Card(
      child: Column(
        children: <Widget>[
          Text(
            subjectPopup,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(0xff, 56, 80, 82),
            ),
          ),
          SizedBox(
            width: 10.0,
            height: 15.0,
          )
        ],
      ),
    );
  }

  Widget showImage() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: new EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Image.network(
              imagePopup,
              width: MediaQuery.of(context).size.width * 0.9,
            ),
          ],
        ),
      ),
    );
  }

  Widget showButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: new EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WebView(
                            userModel: myUserModel,
                            urlTarget: textURL,
                          )));
            },
            child: Text(textButton),
          ),
        ],
      ),
    );
  }

  Widget showDetail() {
    return Card(
      child: Container(
        // decoration: MyStyle().boxLightGreen,
        // height: 35.0,
        width: MediaQuery.of(context).size.width * 0.95,
        padding: EdgeInsets.only(left: 10.0, right: 20.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 10.0,
              height: 5.0,
            ),
            Text(
              'โพสเมื่อ :' + postdatePopup,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0, 0, 0),
              ),
            ),
            SizedBox(
              width: 10.0,
              height: 10.0,
            ),
            Text(
              detailPopup.replaceAll('\\n', '\n'),
              style: TextStyle(
                fontSize: 19.0,
                // fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0, 0, 0),
              ),
            ),
            (textButton != '') ? showButton() : Container(),
          ],
        ),
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

  void changePage(int index) {
    // selected  >>  BubbleBottomBar
    setState(() {
      currentIndex = index;
    });

    //You can have a switch case to Navigate to different pages
    switch (currentIndex) {
      case 0:
        MaterialPageRoute route = MaterialPageRoute(
          builder: (value) => MyService(
            userModel: myUserModel,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);

        break; // home
      case 1:
        routeToListProduct(0);
        break; // all product
      case 2:
        routeToListProduct(2);
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return DetailCart(
            userModel: myUserModel,
          );
        });
        Navigator.of(context).push(materialPageRoute).then((value) {
          setState(() {
            // readCart();
          });
        });
        break; // promotion
    }
  }

  Widget showBubbleBottomBarNav() {
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
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.home,
              color: Colors.red,
            ),
            title: Text("หน้าหลัก")),
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
            backgroundColor: Colors.blue,
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.shopping_cart,
              color: Colors.blue,
            ),
            title: Text("ตะกร้าสินค้า")),
      ],
    );
  }

  Widget gotoHome() {
    // all product
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.30,
          // color: Colors.greenAccent,
          // height: 80.0,
          child: GestureDetector(
            child: Card(
              color: Color.fromARGB(0xff, 0x2c, 0xb5, 0x1b),
              child: Container(
                padding: EdgeInsets.all(5.0),
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.home,
                      size: 20.0,
                      color: Colors.white,
                    ),
                    Text(
                      '  หน้าหลัก',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              print('You click home');
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return MyService(
                  userModel: myUserModel,
                );
              });

              Navigator.of(context).pushAndRemoveUntil(
                  materialPageRoute, // pushAndRemoveUntil  clear หน้าก่อนหน้า route with out airrow back
                  (Route<dynamic> route) {
                return false;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget homeMenu() {
    return Container(
      margin: EdgeInsets.only(top: 5.0),
      alignment: Alignment(0.0, 0.0),
      // color: Colors.green.shade50,
      // height: MediaQuery.of(context).size.height * 0.5 - 81,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          gotoHome(),
        ],
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
        title: Text(''),
      ),
      body: ListView(
        children: <Widget>[
          homeMenu(),
          spaceBox(),
          showTitle(),
          (imagePopup != '') ? showImage() : Container(),
          showDetail(), //  popupModel == null ? showProgress() : detailBox(),
        ],
      ),
      // bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
    );
  }

  // Widget showProgress() {
  //   return Center(
  //     child: CircularProgressIndicator(),
  //   );
  // }

  // Widget showDetailList() {
  //   return Stack(
  //     children: <Widget>[
  //       showController(),
  //       // addButton(),
  //     ],
  //   );
  // }

  // ListView showController() {
  //   return ListView(
  //     padding: EdgeInsets.all(15.0),
  //     children: <Widget>[
  //       showTitle(),
  //       // showImage(),
  //       detailBox(),

  //       // submitButton(),
  //     ],
  //   );
  // }
}

class WebView extends StatefulWidget {
  final UserModel userModel;
  final String urlTarget;

  WebView({Key key, this.userModel, this.urlTarget}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  UserModel myUserModel;
  String myUrlTarget;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    myUrlTarget = widget.urlTarget;
  }

  @override
  Widget build(BuildContext context) {
    String memberId = myUserModel.id;
    String memberCode = myUserModel.customerCode;
    String url = myUrlTarget; //
    print('URL ==>> $url');
    return WebviewScaffold(
      url: url, //"https://www.androidmonks.com",
      appBar: AppBar(
        backgroundColor: MyStyle().bgColor,
        title: Text("PTN Pharma"),
      ),
      withZoom: true,
      withJavascript: true,
      withLocalStorage: true,
      appCacheEnabled: false,
      ignoreSSLErrors: true,
    );
  }
}
