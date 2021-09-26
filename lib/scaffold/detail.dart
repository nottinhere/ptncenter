import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/product_all_model2.dart';
import 'package:ptncenter/models/unit_size_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';

import 'package:ptncenter/scaffold/list_product.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ptncenter/models/promote_model.dart';
import 'package:ptncenter/widget/home.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'my_service.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:favorite_button/favorite_button.dart';

class Detail extends StatefulWidget {
  final ProductAllModel productAllModel;
  final UserModel userModel;

  Detail({Key key, this.productAllModel, this.userModel}) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // Explicit
  ProductAllModel currentProductAllModel;
  ProductAllModel2 productAllModel;
  List<UnitSizeModel> unitSizeModels = List();
  List<int> amounts = [0, 0, 0];
  int amontCart = 0;
  UserModel myUserModel;
  String id; // productID
  // String qtyS = '', qtyM = '', qtyL = '';
  int sizeSincart = 0, sizeMincart = 0, sizeLincart = 0;
  int qtyS = 0, qtyM = 0, qtyL = 0;
  int showSincart = 0, showMincart = 0, showLincart = 0;
  // var showSincart = '', showMincart = '', showLincart = '';

  List<Widget> promoteLists = List();
  List<Widget> relateLists = List();
  List<String> urlImages = List();
  List<String> urlImagesRelate = List();
  List<String> productsName = List();
  List<ProductAllModel> promoteModels = List();
  List<ProductAllModel> relateModels = List();
  int banerIndex = 0, relateIndex = 0;
  int currentIndex = 1;
  // Method
  @override
  void initState() {
    super.initState();
    currentProductAllModel = widget.productAllModel;
    myUserModel = widget.userModel;
    setState(() {
      readCart();
      getProductWhereID();
    });
    readRelate();
  }

  Future<void> getProductWhereID() async {
    if (currentProductAllModel != null) {
      String memberId = myUserModel.id.toString();
      id = currentProductAllModel.id.toString();
      String url = '${MyStyle().getProductWhereId}$id&memberId=$memberId';
      print('url Detaillll ====>>> $url');
      http.Response response = await http.get(url);
      var result = json.decode(response.body);
      // print('result =0000000>>> $result');

      var itemProducts = result['itemsProduct'];
      print('itemProducts ===>>>>$itemProducts');
      for (var map in itemProducts) {
        print('map DEtail ==========>>>>>>>> $map');

        setState(() {
          productAllModel = ProductAllModel2.fromJson(map);

          Map<String, dynamic> priceListMap = map['price_list'];
          print('priceListMap = $priceListMap');

          Map<String, dynamic> sizeSmap = priceListMap['s'];
          if (sizeSmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeSmap);
            unitSizeModels.add(unitSizeModel);
          }
          Map<String, dynamic> sizeMmap = priceListMap['m'];
          if (sizeMmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeMmap);
            unitSizeModels.add(unitSizeModel);
          }
          Map<String, dynamic> sizeLmap = priceListMap['l'];
          if (sizeLmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeLmap);
            unitSizeModels.add(unitSizeModel);
          }
          print('sizeSmap = $sizeSmap');
          print('sizeMmap = $sizeMmap');
          print('sizeLmap = $sizeLmap');
        });
      } // for

      setState(() {
        showSincart = productAllModel.itemincartSunit;
        showMincart = productAllModel.itemincartMunit;
        showLincart = productAllModel.itemincartLunit;
      });
    }
  }

  Future<void> readRelate() async {
    String memId = myUserModel.id;
    id = currentProductAllModel.id.toString();

    String url =
        'http://www.ptnpharma.com/apishop/json_relate.php?memberId=$memId&productId=$id'; // ?memberId=$memberId

    print('URL relate >> $url');
    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel promoteModel = PromoteModel.fromJson(map);
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);
      String urlImage = promoteModel.photo;
      String productName = promoteModel.title;
      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        relateModels.add(productAllModel);
        relateLists.add(Image.network(urlImage));
        urlImagesRelate.add(urlImage);
        productsName.add(productName);
      });
    }
  }

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget promotionTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.18,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade300,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'โปรโมชัน',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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

  Widget updatepriceTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade300,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'จะปรับราคา',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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

  Widget newproductTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.18,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade300,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'สินค้าใหม่',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
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

  Widget notreceiveTag() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Colors.green.shade300,
          child: Container(
            padding: EdgeInsets.all(4.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Text(
                  'สั่งแล้วไม่ได้รับ',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click not receive');
          routeToListProduct(4);
        },
      ),
    );
  }

  Widget showTag() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      // mainAxisSize: MainAxisSize.max,
      // mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 5.0,
          height: 8.0,
        ),
        productAllModel.promotion == 1 ? promotionTag() : Container(),
        productAllModel.newproduct == 1 ? newproductTag() : Container(),
        productAllModel.updateprice == 1 ? updatepriceTag() : Container(),
        productAllModel.notreceive == 1 ? notreceiveTag() : Container(),
        SizedBox(
          width: 5.0,
          height: 8.0,
        )
      ],
    );
  }

  Widget showCarouseSliderRelate() {
    return GestureDetector(
      child: CarouselSlider.builder(
        pauseAutoPlayOnTouch: Duration(seconds: 5),
        autoPlay: true,
        autoPlayAnimationDuration: Duration(seconds: 5),
        itemCount: (relateModels.length / 2).round(),
        itemBuilder: (context, index) {
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
                              child: relateLists[idx],
                              padding: EdgeInsets.all(8.0),
                            ),
                            Text(
                              productsName[idx].toString(),
                              style: TextStyle(
                                  fontSize: 12,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        print('You Click index >> $idx');
                        MaterialPageRoute route = MaterialPageRoute(
                          builder: (BuildContext context) => Detail(
                            productAllModel: relateModels[idx],
                            userModel: myUserModel,
                          ),
                        );
                        Navigator.of(context).push(route).then((value) {});
                      },
                    ),
                  );
                }).toList() ??
                [],
          );
        },
      ),
    );
  }

  Widget showImage() {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.5 - 50,
      height: MediaQuery.of(context).size.height * 0.5 - 150,
      child: Image.network(
        productAllModel.photo,
        fit: BoxFit.contain,
      ),
    );
  }

  // Post ค่าไปยัง API ที่ต้องการ
  Future<void> editFavorite(
      String productID, String memberID, bool _isFavorite) async {
    String url =
        'http://ptnpharma.com/apishop/json_favorite.php?productID=$productID&memberId=$memberID&status=$_isFavorite';

    print('url Favorites url ====>>>>> $url');
    // await http.get(url).then((response) {
    //   setState(() {
    //     readCart();
    //   });
    // });
  }

  Widget favButton() {
    bool favStatus = true;
    String productID = id;
    String memberID = myUserModel.id.toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Text(
        //   'รายการโปรด',
        //   style: MyStyle().h3StyleBlue,
        // ),
        FavoriteButton(
          isFavorite: favStatus,
          iconSize: 50.0,
          // iconDisabledColor: Colors.white,
          valueChanged: (_isFavorite) {
            // print('Is Favorite : $_isFavorite');
            editFavorite(productID, memberID, _isFavorite);

            // http.Response response =  http.get(url);
          },
        ),
      ],
    );
  }

  Widget showTitle() {
    return Text(
      productAllModel.title,
      style: MyStyle().h2Style,
    );
  }

  Widget showDetail() {
    return Text(productAllModel.detail);
  }

  Widget showPackage(int index) {
    if (unitSizeModels[index].price.toString() == '0') {
      return Text(
        unitSizeModels[index].lable,
        style: MyStyle().h3bStyleRed,
      );
    } else {
      return Text(
        unitSizeModels[index].lable,
        style: MyStyle().h3Style,
      );
    }
  }

  Widget showPricePackage(int index) {
    if (unitSizeModels[index].price.toString() == '0') {
      return Text(
        'งดจำหน่าย / ',
        style: MyStyle().h3bStyleRed,
      );
    } else {
      return Text(
        '${unitSizeModels[index].price.toString()} บาท / ',
        style: MyStyle().h3bStyleGreen,
      );
    }
  }

  Widget showChoosePricePackage(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        showDetailPrice(index),
        // incDecValue(index),
        showValue(index),
      ],
    );
  }

  Widget showDetailPrice(int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        showPricePackage(index),
        showPackage(index),
      ],
    );
  }

  Widget showValue(int index) {
    //  int value = amounts[index];
    //  return Text('$value');
    int iniValue = 0;
    bool readOnlyMode;
    var iconName;
    var iconColor;
    // print('$sizeSincart / $sizeMincart / $sizeLincart ');
    if (index == 0) {
      iniValue = showSincart;
    } else if (index == 1) {
      iniValue = showMincart;
    } else if (index == 2) {
      iniValue = showLincart;
    }

    iniValue = (iniValue).toInt();

    /////////////////////////////////////////////////////////
    if (unitSizeModels[index].price.toString() == '0') {
      readOnlyMode = true;
      iconName = Icons.cancel;
      iconColor = Color.fromARGB(0xff, 0xff, 0x99, 0x99);
      return Container(
        // decoration: MyStyle().boxLightGreen,
        // height: 35.0,
        width: MediaQuery.of(context).size.width * 0.50,
        padding: EdgeInsets.only(left: 20.0, right: 10.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: Colors.black),
              // initialValue: '$iniValue',
              // controller: TextEditingController()..text = '$iniValue',
              readOnly: readOnlyMode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  top: 6.0,
                ),
                prefixIcon: Icon(iconName, color: iconColor),
                // border: InputBorder.none,
                // hintText: 'ระบุจำนวน',
                hintStyle: TextStyle(color: iconColor),
              ),
            ),
          ],
        ),
      );
    } else {
      readOnlyMode = false;
      iconName = Icons.mode_edit;
      iconColor = Colors.grey;
      return Container(
        // decoration: MyStyle().boxLightGreen,
        // height: 35.0,
        width: MediaQuery.of(context).size.width * 0.50,
        padding: EdgeInsets.only(left: 20.0, right: 10.0),
        child: Column(
          children: <Widget>[
            Padding(
              child: SpinBox(
                value: (iniValue)
                    .toDouble(), //(iniValue == 0) ? 0 : (iniValue).toInt(),
                onChanged: (changevalue) {
                  if (index == 0) {
                    setState(() {
                      qtyS = (changevalue == 0) ? 0 : (changevalue).toInt();
                    });
                  } else if (index == 1) {
                    setState(() {
                      qtyM = (changevalue == 0) ? 0 : (changevalue).toInt();
                    });
                  } else if (index == 2) {
                    setState(() {
                      qtyL = (changevalue == 0) ? 0 : (changevalue).toInt();
                    });
                  }
                },
                // decoration: InputDecoration(labelText: 'Decimals'),
              ),
              padding: const EdgeInsets.all(2),
            ),
          ],
        ),
      );
    }

    // var x = (iniValue!='0')?int.tryParse(iniValue):('').toString();
    // print('iniValue ($index)>> $iniValue');
  }

  Widget showStockExpire() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.98,
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.16,
            child: Text(
              'Stock :',
              style: MyStyle().h3StyleGray,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.22,
            child: Text(' ${productAllModel.stock}',
                style: (productAllModel.stock.toString() != '0')
                    ? MyStyle().h3StyleGray
                    : MyStyle().h3StyleRed),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.14,
            child: Text(
              'Exp :',
              style: MyStyle().h3StyleGray,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Text(
              ' ${productAllModel.expire}',
              style: TextStyle(
                  fontSize: 16.0,
                  color: (productAllModel.expireColor == 'red')
                      ? Colors.red
                      : (productAllModel.expireColor == 'blue')
                          ? Colors.blue.shade700
                          : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget showPrice() {
    return Container(
      height: 150.0,
      // color: Colors.grey,
      child: ListView.builder(
        itemCount: unitSizeModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          return showChoosePricePackage(index);
        },
      ),
    );
  }

  Widget relate() {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.25,
        child: relateLists.length == 0
            ? myCircularProgress()
            : showCarouseSliderRelate(),
      ),
    );
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

  Future<void> readCart() async {
    print('Here is readcart function');

    amontCart = 0;
    String memberId = myUserModel.id.toString();
    String url =
        'http://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    print('url Detail =====>>>>>>>> $url');

    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var cartList = result['cart'];
    for (var map in cartList) {
      // setState(() {
      amontCart++;
      // });
    }
    setState(() {
      amontCart;
    });
  }

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

  BottomNavigationBarItem homeBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.home),
      title: Text('Home'),
    );
  }

  BottomNavigationBarItem cartBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      title: Text('Cart'),
    );
  }

  BottomNavigationBarItem readQrBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.code),
      title: Text('QR code'),
    );
  }

  Widget showBottomBarNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      items: <BottomNavigationBarItem>[
        homeBotton(),
        cartBotton(),
        readQrBotton(),
      ],
      onTap: (int index) {
        print('index =$index');
        if (index == 0) {
          // routeToDetailCart();
          MaterialPageRoute route = MaterialPageRoute(
            builder: (value) => MyService(
              userModel: myUserModel,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
        } else if (index == 2) {
          readQRcode();
        }
      },
    );
  }

  Future<void> readQRcode() async {
    try {
      String qrString = await BarcodeScanner.scan();
      print('QR code = $qrString');
      if (qrString != null) {
        decodeQRcode(qrString);
      }
    } catch (e) {
      print('e = $e');
    }
  }

  Future<void> decodeQRcode(String code) async {
    try {
      String url =
          'http://ptnpharma.com/apishop/json_productlist.php?bqcode=$code';
      http.Response response = await http.get(url);
      var result = json.decode(response.body);
      print('result ===*******>>>> $result');

      int status = result['status'];
      print('status ===>>> $status');
      if (status == 0) {
        normalDialog(context, 'No Code', 'No $code in my Database');
      } else {
        var itemProducts = result['itemsProduct'];
        for (var map in itemProducts) {
          print('map ===*******>>>> $map');

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
          //     readCart();
          //   });
          // });
        }
      }
    } catch (e) {}
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
            readCart();
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
              Icons.format_list_bulleted,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.format_list_bulleted,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          showCart(),
        ],
        backgroundColor: MyStyle().bgColor,
        title: Text('ข้อมูลสินค้า'),
      ),
      body: productAllModel == null ? showProgress() : showDetailList(),
      bottomNavigationBar: showBubbleBottomBarNav(), //showBottomBarNav
    );
  }

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget addButtonfix() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                color: MyStyle().mainColor,
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  String productID = id;
                  String memberID = myUserModel.id.toString();

                  if (qtyS != 0) {
                    String unitSize = 's';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=s, QTY=$qtyS');
                    addCart(productID, unitSize, qtyS, memberID);
                  }
                  if (qtyM != 0) {
                    String unitSize = 'm';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=m, QTY=$qtyM');
                    addCart(productID, unitSize, qtyM, memberID);
                  }
                  if (qtyL != 0) {
                    String unitSize = 'l';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=l, QTY=$qtyL');
                    addCart(productID, unitSize, qtyL, memberID);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget addButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                color: MyStyle().mainColor,
                child: Text(
                  'Add to Cart',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  String productID = id;
                  String memberID = myUserModel.id.toString();

                  if (qtyS != 0) {
                    String unitSize = 's';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=s, QTY=$qtyS');
                    addCart(productID, unitSize, qtyS, memberID);
                  }
                  if (qtyM != 0) {
                    String unitSize = 'm';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=m, QTY=$qtyM');
                    addCart(productID, unitSize, qtyM, memberID);
                  }
                  if (qtyL != 0) {
                    String unitSize = 'l';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=l, QTY=$qtyL');
                    addCart(productID, unitSize, qtyL, memberID);
                  }
                },
              ),
            ),
            SizedBox(
              width: 10.0,
              height: (myUserModel.msg == '') ? 0 : 105.0,
            )
          ],
        ),
      ],
    );
  }

  Future<void> addCart(
      String productID, String unitSize, int qTY, String memberID) async {
    String url =
        'http://www.ptnpharma.com/apishop/json_savemycart.php?productID=$productID&unitSize=$unitSize&QTY=$qTY&memberId=$memberID';
    print('urlAddcart = $url');
    await http.get(url).then((response) {});
    print('upload ok');

    Navigator.pop(context, true);
  }

  Widget showDetailList() {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(width: 5, color: Colors.grey.shade200)),
      child: Stack(
        children: <Widget>[
          showController(),
          MyStyle().mySizebox(),
          addButton(),
          MyStyle().mySizebox(),
        ],
      ),
    );
  }

  ListView showController() {
    String intVL = '10';
    return ListView(
      padding: EdgeInsets.all(10.0),
      children: <Widget>[
        favButton(),
        showTitle(),
        // MyStyle().mySizebox(),
        showTag(),
        // showStock(),
        // MyStyle().mySizebox(),
        // showExpire(),
        showStockExpire(),
        //  Padding(
        //     child: SpinBox(
        //       value: int.parse('intVL'),
        //       decoration: InputDecoration(labelText: 'Basic'),
        //     ),
        //     padding: const EdgeInsets.all(16),
        //   ),
        showPrice(),
        // addButtonfix(),
        // MyStyle().mySizebox(),
        showImage(),

        MyStyle().mySizebox(),
        headTitle('สินค้าที่เกี่ยวข้อง', Icons.thumb_up),
        relate(),
        MyStyle().mySizebox(),
        MyStyle().mySizebox(),
      ],
    );
  }
}
