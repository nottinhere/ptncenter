import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/utility/my_style.dart';
// import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'detail.dart';
import 'detail_cart.dart';
import 'package:ptncenter/widget/home.dart';

import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';

import 'my_service.dart';

import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ListProductfav extends StatefulWidget {
  final int index;
  final UserModel userModel;
  final int cate;
  final String cateName;
  String _result = '';

  ListProductfav(
      {Key key, this.index, this.userModel, this.cate, this.cateName})
      : super(key: key);

  @override
  _ListProductfavState createState() => _ListProductfavState();
}

//class
class Debouncer {
  // delay เวลาให้มีการหน่วง เมื่อ key searchview

  //Explicit
  final int milliseconds;
  VoidCallback action;
  Timer timer;

  //constructor
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (timer != null) {
      timer.cancel();
    }
    timer = Timer(Duration(microseconds: milliseconds), action);
  }
}

class _ListProductfavState extends State<ListProductfav> {
  // Explicit
  int myIndex;
  List<ProductAllModel> productAllModels = List(); // []; // set array
  List<ProductAllModel> filterProductAllModels = List(); // []; //

  int amontCart = 0;
  UserModel myUserModel;
  String searchString = '';
  String lastItemName = '';

  int amountListView = 6;
  int page = 1;

  String qrString;
  int myCate = 0;
  String myCateName = '';
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 300); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;

  int currentIndex = 1;

  // List<ProductAllModel> productAllModels_buffer = List(); // []; //

  var _controller = TextEditingController();

  int substart = 0;
  bool visible = true;

  // Method
  @override
  void initState() {
    // auto load
    super.initState();

    myIndex = widget.index;
    myUserModel = widget.userModel;
    myCate = widget.cate;
    myCateName = widget.cateName;

    createController(); // เมื่อ scroll to bottom

    setState(() {
      readData(); // read  ข้อมูลมาแสดง
      readCart();
    });
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          page++;
          readData();
          print('in the end');
        }
      } else {
        setState(() {
          visible = false;
        });
      }
    });
  }

/************************************** */
  Future<void> readCart() async {
    print('Here is readcart function');

    amontCart = 0;
    lastItemName = '';
    String memberId = myUserModel.id.toString();
    String url =
        'https://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    print('url Detail =====>>>>>>>> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    for (var map in cartList) {
      lastItemName = map['title'];
      // setState(() {
      amontCart++;
      // });
    }
    setState(() {
      lastItemName;
      amontCart;
    });
  }

/*************************** */
  String _scanBarcode = 'Unknown';

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)
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
              userModel: myUserModel,
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

  Widget showCart() {
    return GestureDetector(
      onTap: () {
        routeToDetailCart();
      },
      child: Container(
        margin: EdgeInsets.only(top: 5.0, right: 5.0),
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
    Navigator.of(context).push(materialPageRoute);
  }

  Future<void> readData() async {
    // List<ProductAllModel> productAllModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;
    print('Here is readdata function');
    setState(() {
      visible = true;
    });

    String memberId = myUserModel.id.toString();
    String url =
        'https://ptnpharma.com/apishop/json_productfavoritelist.php?memberId=$memberId&searchKey=$searchString&page=$page';

    // url = '${MyStyle().readProductWhereMode}$myIndex';
    print("URL = $url");

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemProductfavs = result['itemsProduct'];
    // print('itemProducts >> ${itemProducts}');
    int i = 0;
    // print('Start >> ${filterProductAllModels.length}');
    // int s = (filterProductAllModels.length);
    // if (filterProductAllModels.length == 0)
    //   int substart = 0;
    // else
    //   int substart = 20;

    int len = (filterProductAllModels.length);

    for (var map in itemProductfavs) {
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);

      setState(() {
        productAllModels.add(productAllModel);
        filterProductAllModels = productAllModels;
      });
      print(
          ' >> ${len} =>($i)  ${productAllModel.id}  || ${productAllModels[i].title} (${filterProductAllModels[i].itemincartSunit}) <<  (${productAllModel.itemincartSunit})');

      i = i + 1;
    }
    setState(() {
      visible = false;
    });
  }

  Future<void> updateDatalist(index) async {
    // List<ProductAllModel> productAllModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;
    print('Here is updateDatalist function');

    String memberId = myUserModel.id.toString();
    int productID = filterProductAllModels[index].id;
    String url =
        'https://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    print("URL update item = $url");
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    for (var mapCart in cartList) {
      if (mapCart['id'] == productID) {
        setState(() {
          if (mapCart['price_list'].containsKey('s')) {
            filterProductAllModels[index].itemincartSunit =
                mapCart['price_list']['s']['quantity'];
          }
          if (mapCart['price_list'].containsKey('m')) {
            filterProductAllModels[index].itemincartMunit =
                mapCart['price_list']['m']['quantity'];
          }
          if (mapCart['price_list'].containsKey('l')) {
            filterProductAllModels[index].itemincartLunit =
                mapCart['price_list']['l']['quantity'];
          }
        });
      }
    }
  }

  Widget showName(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7 - 10,
          child: Text(
            filterProductAllModels[index].title,
            style: MyStyle().h3Style,
          ),
        ),
      ],
    );
  }

  Widget showHilight(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.7 - 10,
          child: Text(
            filterProductAllModels[index].hilight,
            style: MyStyle().h3StyleRed,
          ),
        ),
      ],
    );
  }

  Widget showStock(int index) {
    return Row(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.12,
          child: Text(
            'Stock:',
            style: MyStyle().h4StyleGray,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.12,
          child: Text(
            ' ${filterProductAllModels[index].stock}',
            style: (filterProductAllModels[index].stock.toString() != '0')
                ? MyStyle().h4StyleGray
                : MyStyle().h4StyleRed,
          ),
        ),
        showIncart(index),
      ],
    );
    // return Text('na');
  }

  Widget showIncart(int index) {
    return Row(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width * 0.13,
        child: Text(
          (filterProductAllModels[index].itemincartSunit != '0' ||
                  filterProductAllModels[index].itemincartMunit != '0' ||
                  filterProductAllModels[index].itemincartLunit != '0')
              ? 'ตะกร้า:'
              : '',
          style: MyStyle().h4StyleRed,
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Text(
          ((filterProductAllModels[index].itemincartSunit != '0')
                  ? '${filterProductAllModels[index].itemincartSunit} ${filterProductAllModels[index].itemSunit}  '
                  : '') +
              ((filterProductAllModels[index].itemincartMunit != '0')
                  ? '${filterProductAllModels[index].itemincartMunit} ${filterProductAllModels[index].itemMunit}  '
                  : '') +
              ((filterProductAllModels[index].itemincartLunit != '0')
                  ? '${filterProductAllModels[index].itemincartLunit} ${filterProductAllModels[index].itemLunit}'
                  : ''),
          style: MyStyle().h4StyleRed,
        ),
      ),
    ]);
  }

  Widget showPrice(int index) {
    String txtShowPrice;
    String txtShowUnit;
    String txtPriceUnit = '';
    if (filterProductAllModels[index].itemSprice.toString() != '0') {
      txtShowPrice = filterProductAllModels[index].itemSprice.toString();
      txtShowUnit = filterProductAllModels[index].itemSunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '')
        txtPriceUnit = '$txtPriceUnit' + " [$txtShowPrice/$txtShowUnit] ";
    }
    if (filterProductAllModels[index].itemMprice.toString() != '0') {
      txtShowPrice = filterProductAllModels[index].itemMprice.toString();
      txtShowUnit = filterProductAllModels[index].itemMunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '')
        txtPriceUnit = '$txtPriceUnit' + " [$txtShowPrice/$txtShowUnit] ";
    }
    if (filterProductAllModels[index].itemLprice.toString() != '0') {
      txtShowPrice = filterProductAllModels[index].itemLprice.toString();
      txtShowUnit = filterProductAllModels[index].itemLunit.toString();
      if (txtShowPrice != '' && txtShowUnit != '')
        txtPriceUnit = '$txtPriceUnit' + " [$txtShowPrice/$txtShowUnit] ";
    }

    return Row(
      children: <Widget>[
        Text(
          '$txtPriceUnit',
          style: TextStyle(
            fontSize: 16.0,
            //  fontWeight: FontWeight.bold,
            color: Color.fromRGBO(50, 117, 168, 1.0),
          ), // h3StyleGray
        ),
      ],
    );
    // return Text('na');
  }

  Widget showText(int index) {
    return Container(
      padding: EdgeInsets.only(left: 5.0, right: 2.0),
      // height: MediaQuery.of(context).size.width * 0.5,
      width: MediaQuery.of(context).size.width * 0.73,
      child: Container(
        padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            showName(index),
            (filterProductAllModels[index].hilight != '')
                ? showHilight(index)
                : Container(),
            showPrice(index),
            showStock(index),
          ],
        ),
      ),
    );
  }

  Widget showImage(int index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      // width: MediaQuery.of(context).size.width * 0.25,
      // child: Image.network(filterProductAllModels[index].photo),
      width: 80,
      height: 80,
      decoration: new BoxDecoration(
          image: new DecorationImage(
        fit: BoxFit.cover,
        alignment: FractionalOffset.topCenter,
        image: new NetworkImage(filterProductAllModels[index].photo),
      )),
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

  Widget loading() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      child: Loading(indicator: BallPulseIndicator(), size: 10.0),
    );
  }

  Widget myCircularProgress() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      child: Center(child: CupertinoActivityIndicator()),
    );
  }

  Widget showProductfavItem() {
    int perpage = 15;
    bool loadingIcon = false;

    // int i = 0;
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: productAllModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          // print('perpage >> ${perpage} || index >> $index');

          if ((index + 1) % perpage == 0) {
            loadingIcon = true;
          } else {
            loadingIcon = false;
          }

          if (loadingIcon == true) {
            // return CupertinoActivityIndicator();
            return Column(
              children: [
                GestureDetector(
                  child: Container(
                    child: Card(
                      child: Container(
                        decoration: myBoxDecoration(),
                        padding: EdgeInsets.only(top: 0.5),
                        child: Row(
                          children: <Widget>[
                            showImage(index),
                            showText(index),
                          ],
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    print(
                        'index select item => ${filterProductAllModels[index]}');
                    MaterialPageRoute materialPageRoute =
                        MaterialPageRoute(builder: (BuildContext buildContext) {
                      return Detail(
                        productAllModel: filterProductAllModels[index],
                        userModel: myUserModel,
                      );
                    });

                    Navigator.of(context)
                        .push(materialPageRoute)
                        .then((value) => setState(() {
                              readCart();
                              updateDatalist(index);
                            }));
                    // Navigator.of(context).push(materialPageRoute);
                  },
                ),
                myCircularProgress(),
              ],
            );
          }

          return GestureDetector(
            child: Container(
              child: Card(
                child: Container(
                  decoration: myBoxDecoration(),
                  padding: EdgeInsets.only(top: 0.5),
                  child: Row(
                    children: <Widget>[
                      showImage(index),
                      showText(index),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              print('index select item => ${filterProductAllModels[index]}');
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return Detail(
                  productAllModel: filterProductAllModels[index],
                  userModel: myUserModel,
                );
              });

              Navigator.of(context)
                  .push(materialPageRoute)
                  .then((value) => setState(() {
                        readCart();
                        updateDatalist(index);
                      }));
              // Navigator.of(context).push(materialPageRoute);
            },
          );
        },
      ),
    );
  }

  Widget showContent() {
    bool searchKey;
    if (searchString != '') {
      searchKey = true;
    }

    if (filterProductAllModels.length == 0) {
      if (myIndex != 4) {
        return showProgressIndicate(searchKey);
      } else {
        return Center(child: Text(''));
      }
    } else {
      return showProductfavItem();
    }
  }

  Widget showProgressIndicate(searchKey) {
    // print('searchKey >> $searchKey');

    if (searchKey == true) {
      if (filterProductAllModels.length == 0) {
        return Center(child: Text('')); // Search not found
      } else {
        return Center(child: Text(''));
      }
    } else {
      return Center(child: CircularProgressIndicator());
    }
    /*
    return Center(
      child:
          statusStart ? CircularProgressIndicator() : Text('Search not found'),
    );
    */
  }

  /*
  Widget myLayout() {
    return Column(
      children: <Widget>[
        searchForm(),
        showProductItem(),
      ],
    );
  }
  */

  Widget lastItemInCart() {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(
            'รายการล่าสุดในตะกร้า',
            style: MyStyle().h3bStyle,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(lastItemName.toString(),
              style: TextStyle(
                fontSize: 14.0,
                // fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
              )),
        ),
      ],
    );
  }

  // Future<void> readQRcode() async {
  //   try {
  //     var qrString = await BarcodeScanner.scan();
  //     print('QR code = $qrString');
  //     if (qrString != null) {
  //       decodeQRcode(qrString);
  //     }
  //   } catch (e) {
  //     print('e = $e');
  //   }
  // }

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

  Future<void> decodeQRcode(var code) async {
    try {
      String url =
          'https://ptnpharma.com/apishop/json_productlist.php?bqcode=$code';
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print('result ===*******>>>> $result');

      int status = result['status'];
      print('status ===>>> $status');
      if (status == 0) {
        normalDialog(context, 'Not found', 'ไม่พบ code :: $code ในระบบ');
      } else {
        var itemProductfavs = result['itemsProduct'];
        for (var map in itemProductfavs) {
          // print('map ===*******>>>> $map');

          ProductAllModel productAllModel = ProductAllModel.fromJson(map);
          MaterialPageRoute route = MaterialPageRoute(
            builder: (BuildContext context) => Detail(
              userModel: myUserModel,
              productAllModel: productAllModel,
            ),
          );

          Navigator.of(context).push(route).then((value) => readCart());
        }
      }
    } catch (e) {}
  }

  Widget searchForm() {
    return Container(
      decoration: MyStyle().boxLightGray,
      // color: Colors.grey,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
      child: ListTile(
        trailing: Container(
          width: 45.0,
          child: Image.asset('images/icon_barcode.png'),
        ),
        onTap: () {
          print('You click barcode scan');
          // readQRcode();
          // readQRcodePreview();
          scanBarcodeNormal();
        },
        title: TextField(
          controller: _controller,
          textAlign: TextAlign.center,
          scrollPadding: EdgeInsets.all(1.00),
          style: TextStyle(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w300,
              fontSize: 18.00),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'ค้นหาสินค้า',
            suffixIcon: IconButton(
              onPressed: () => _controller.clear(),
              icon: Icon(Icons.clear),
            ),
          ),
          onChanged: (String string) {
            searchString = string.trim();
          },
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            setState(() {
              page = 1;
              myIndex = 0;
              productAllModels.clear();
              readData();
            });
          },
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

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProductfav(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void changePage(int index) {
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
        break; // all product
      case 2:
        routeToListProduct(0);
        break; // all product
      case 3:
        routeToListProduct(2);
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return DetailCart(
            userModel: myUserModel,
          );
        });
        Navigator.of(context).push(materialPageRoute).then((value) {
          setState(() {
            print('Here is change page');

            readCart();
          });
        });
        break; // Shopping cart
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
            backgroundColor: Colors.blue,
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            title: Text("หน้าหลัก")),
        BubbleBottomBarItem(
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.favorite,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            title: Text("รายการโปรด")),
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
            backgroundColor: Colors.brown,
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.shopping_cart,
              color: Colors.brown,
            ),
            title: Text("ตะกร้าสินค้า")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String txtheader = '';
    txtheader = 'รายการโปรด';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().bgColor,
        title: Text(txtheader),
        actions: <Widget>[
          showCart(),
        ],
      ),

      body: Column(
        children: <Widget>[
          searchForm(),
          lastItemInCart(),
          showContent(),
        ],
      ),
      bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
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
          child: ScanPreviewWidget(
            onScanResult: (result) {
              debugPrint('scan result: $result');
              Navigator.pop(context, result);
            },
          ),
        ),
      ),
    );
  }
}
