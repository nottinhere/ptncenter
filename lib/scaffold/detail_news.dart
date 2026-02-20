import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';

// import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'my_service.dart';

import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS/macOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class DetailNews extends StatefulWidget {
  final PopupModel? popupModel;
  final UserModel? userModel;

  DetailNews({Key? key, this.popupModel, this.userModel}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<DetailNews> {
  // Explicit
  PopupModel? currentPopupModel;
  PopupModel? popupModel;
  UserModel? myUserModel;
  String? id; // productID
  String? memberID;
  String? imagePopup = '';
  String? textButton = '';
  String? textURL = '';
  String? subjectPopup = '';
  String? DetailNews = '';
  String? postdatePopup = '';
  int? currentIndex = 1;
  int selectIndex = 3;

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
    String id = currentPopupModel!.id.toString();

    String url = 'https://www.ptnpharma.com/apishop/json_newsdetail.php?id=$id';
    print('urlPopup >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);

    var mapItemPopup =
        result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    for (var map in mapItemPopup) {
      PopupModel? popupModel = PopupModel.fromJson(map);
      String? urlImage = popupModel!.photo!;
      String? subject = popupModel!.subject!;
      String? postdate = popupModel!.postdate!;
      String? detail = popupModel!.detail!;
      String? txtBTN = popupModel!.txtBTN!;
      String? txtURL = popupModel!.url!;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง arra
        subjectPopup = subject;
        imagePopup = urlImage;
        DetailNews = detail;
        postdatePopup = postdate;
        textButton = txtBTN;
        textURL = txtURL;
      });
    } // for
  }

  Widget spaceBox() {
    return SizedBox(width: 10.0, height: 16.0);
  }

  Widget showTitle() {
    return Card(
      child: Column(
        children: <Widget>[
          Text(
            subjectPopup!,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(0xff, 56, 80, 82),
            ),
          ),
          SizedBox(width: 10.0, height: 15.0),
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
              imagePopup!,
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
                      builder: (context) => WebViewExample(
                            userModel: myUserModel!,
                            webPage: textURL!,
                          )));
            },
            child: Text(textButton!,style: TextStyle(fontSize: 16, color: Colors.white)),
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
            SizedBox(width: 10.0, height: 5.0),
            Text(
              'โพสเมื่อ :' + postdatePopup!,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0, 0, 0),
              ),
            ),
            SizedBox(width: 10.0, height: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DetailNews!.replaceAll('\\n', '\n\n'),
                /* 'Like\nAndroidRide\n\nShare Posts', */
                style: TextStyle(
                  fontSize: 19.0,
                  // fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0xff, 0, 0, 0),
                ),
              ),
            ),
            (textButton != '') ? showButton() : Container(),
          ],
        ),
      ),
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProduct(index: index, userModel: myUserModel);
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

  void changePage(int? index) {
    // selected  >>  BubbleBottomBar
    setState(() {
      currentIndex = index;
    });

    //You can have a switch case to Navigate to different pages
    switch (currentIndex) {
      case 0:
        MaterialPageRoute route = MaterialPageRoute(
          builder: (value) => MyService(userModel: myUserModel),
        );
        Navigator.of(context).pushAndRemoveUntil(route, (route) => false);

        break; // home
      case 1:
        routeToListProduct(0);
        break; // all product
      case 2:
        routeToListProduct(2);
        MaterialPageRoute materialPageRoute = MaterialPageRoute(
          builder: (BuildContext buildContext) {
            return DetailCart(userModel: myUserModel);
          },
        );
        Navigator.of(context).push(materialPageRoute).then((value) {
          setState(() {
            // readCart();
          });
        });
        break; // promotion
    }
  }

  // Widget showBubbleBottomBarNav() {
  //   return BubbleBottomBar(
  //     hasNotch: true,
  //     // fabLocation: BubbleBottomBarFabLocation.end,
  //     opacity: .2,
  //     borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(
  //             16)), //border radius doesn't work when the notch is enabled.
  //     elevation: 8,
  //     currentIndex: currentIndex,
  //     onTap: changePage,
  //     items: <BubbleBottomBarItem>[
  //       BubbleBottomBarItem(
  //           backgroundColor: Colors.red,
  //           icon: Icon(
  //             Icons.home,
  //             color: Colors.black,
  //           ),
  //           activeIcon: Icon(
  //             Icons.home,
  //             color: Colors.red,
  //           ),
  //           title: Text("หน้าหลัก")),
  //       BubbleBottomBarItem(
  //           backgroundColor: Colors.green,
  //           icon: Icon(
  //             Icons.medical_services,
  //             color: Colors.black,
  //           ),
  //           activeIcon: Icon(
  //             Icons.medical_services,
  //             color: Colors.green,
  //           ),
  //           title: Text("สินค้า")),
  //       BubbleBottomBarItem(
  //           backgroundColor: Colors.blue,
  //           icon: Icon(
  //             Icons.shopping_cart,
  //             color: Colors.black,
  //           ),
  //           activeIcon: Icon(
  //             Icons.shopping_cart,
  //             color: Colors.blue,
  //           ),
  //           title: Text("ตะกร้าสินค้า")),
  //     ],
  //   );
  // }

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return DetailCart(userModel: myUserModel);
      },
    );
    Navigator.of(context).push(materialPageRoute);
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
              builder: (value) => MyService(userModel: myUserModel),
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
                    Icon(Icons.home, size: 20.0, color: Colors.white),
                    Text(
                      '  หน้าหลัก',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              print('You click home');
              MaterialPageRoute materialPageRoute = MaterialPageRoute(
                builder: (BuildContext buildContext) {
                  return MyService(userModel: myUserModel);
                },
              );

              Navigator.of(context).pushAndRemoveUntil(
                materialPageRoute, // pushAndRemoveUntil  clear หน้าก่อนหน้า route with out airrow back
                (Route<dynamic> route) {
                  return false;
                },
              );
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
        children: <Widget>[gotoHome()],
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
      body: ListView(
        children: <Widget>[
          // homeMenu(),
          // spaceBox(),
          showTitle(),
          (imagePopup != '') ? showImage() : Container(),
          showDetail(), //  popupModel == null ? showProgress() : detailBox(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
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

    
    String? url = mywebPage!; //
    print('URL ==>> $url');

    String? urlView =  url!;
    

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


