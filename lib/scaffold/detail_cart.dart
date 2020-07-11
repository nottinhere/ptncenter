import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/price_list_model.dart';
import 'package:ptncenter/models/product_all_model.dart';

import 'package:ptncenter/models/product_all_model2.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:ptncenter/widget/home.dart';

import 'my_service.dart';

class DetailCart extends StatefulWidget {
  final UserModel userModel;
  DetailCart({Key key, this.userModel}) : super(key: key);

  @override
  _DetailCartState createState() => _DetailCartState();
}

class _DetailCartState extends State<DetailCart> {
  // Explicit
  UserModel myUserModel;

  List<PriceListModel> priceListSModels = List();
  List<PriceListModel> priceListMModels = List();
  List<PriceListModel> priceListLModels = List();

  List<ProductAllModel2> productAllModels = List();
  List<Map<String, dynamic>> sMap = List();
  List<Map<String, dynamic>> mMap = List();
  List<Map<String, dynamic>> lMap = List();
  int amontCart = 0;
  String newQTY = '';
  int newQTYint = 0;
  double total = 0;
  String transport;
  int index = 0;
  String comment = '', memberID;

  List<String> listTransport = [
    '',
    'รับสินค้าเองที่ พัฒนาเภสัช',
    'รับสินค้าเองที่คลังสินค้า (ซอยวัดท่าทอง)',
    'รถส่งของตามรอบส่งสินค้า ตามสายส่ง',
    'รถส่งของตามรอบส่งสินค้าในเมืองนครสวรรค์',
    'ส่งทางบริษัทขนส่ง (เอกชน)'
  ];

  // Method
  @override
  void initState() {
    // initState = auto load เพื่อแสดงใน  stateless

    super.initState();
    myUserModel = widget.userModel;
    setState(() {
      // setState เพื่อสั่งให้ทำงานถีง initState จะ load เสร็จแล้วมันก็ย้อนมาทำใน  setState
      readCart();
    });
  }

  Future<void> readCart() async {
    clearArray();

    String memberId = myUserModel.id.toString();
    String url = '${MyStyle().loadMyCart}$memberId';
    print('url Detail Cart ====>>>>> $url');

    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var cartList = result['cart'];
    // print('cartList =======>>> $cartList');

    for (var map in cartList) {
      ProductAllModel2 productAllModel = ProductAllModel2.fromJson(map);

      print('productAllModel = ${productAllModel.toJson().toString()}');

      Map<String, dynamic> priceListMap = map['price_list'];

      Map<String, dynamic> sizeSmap = priceListMap['s'];

      if (sizeSmap == null) {
        sMap.add({'lable': ''});
        PriceListModel priceListModel = PriceListModel.fromJson({'lable': ''});
        priceListSModels.add(priceListModel);
      } else {
        sMap.add(sizeSmap);
        // var priceSdisplay = double.parse(sizeSmap['price']);
        // print('S is not null >> $priceSdisplay');
        PriceListModel priceListModel = PriceListModel.fromJson(sizeSmap);
        priceListSModels.add(priceListModel);
        calculateTotal(priceListModel.price, priceListModel.quantity);
      }

      //  print('sizeSmap = $sizeSmap');

      Map<String, dynamic> sizeMmap = priceListMap['m'];
      if (sizeMmap == null) {
        mMap.add({'lable': ''});
        PriceListModel priceListModel = PriceListModel.fromJson({'lable': ''});
        priceListMModels.add(priceListModel);
      } else {
        mMap.add(sizeMmap);
        PriceListModel priceListModel = PriceListModel.fromJson(sizeMmap);
        priceListMModels.add(priceListModel);
        calculateTotal(
            priceListModel.price.toString(), priceListModel.quantity);
      }
      // print('sizeMmap = $sizeMmap');

      Map<String, dynamic> sizeLmap = priceListMap['l'];
      if (sizeLmap == null) {
        lMap.add({'lable': ''});
        PriceListModel priceListModel = PriceListModel.fromJson({'lable': ''});
        priceListLModels.add(priceListModel);
      } else {
        lMap.add(sizeLmap);
        PriceListModel priceListModel = PriceListModel.fromJson(sizeLmap);
        priceListLModels.add(priceListModel);
        calculateTotal(
            priceListModel.price.toString(), priceListModel.quantity);
      }
      // print('sizeLmap = $sizeLmap');

      setState(() {
        amontCart++;
        print('amontCart >> $amontCart');
        productAllModels.add(productAllModel);
      });
    }
  }

  void clearArray() {
    total = 0;
    productAllModels.clear();
    priceListSModels.clear();
    priceListMModels.clear();
    priceListLModels.clear();
    sMap.clear();
    mMap.clear();
    lMap.clear();
  }

  Widget showCart() {
    return Container(
      margin: EdgeInsets.only(top: 5.0, right: 5.0),
      width: 32.0,
      height: 32.0,
      child: Stack(
        children: <Widget>[
          Image.asset('images/shopping_cart.png'),
          Text(
            '$amontCart',
            style: TextStyle(
              backgroundColor: Colors.blue.shade600,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget showTitle(int index) {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 10.0),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width - 40,
            child: Text(
              productAllModels[index].title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
              ),
              // style: MyStyle().h2Style,
            ),
          ),
        ],
      ),
    );
  }

  Widget editButton(int index, String size) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        myAlertDialog(index, size);
      },
    );
  }

  Widget alertTitle() {
    return ListTile(
      leading: Icon(
        Icons.edit,
        size: 36.0,
      ),
      title: Text('แก้ไขจำนวน'),
    );
  }

  Widget alertContent(int index, String size) {
    String quantity = '';

    if (size == 's') {
      quantity = priceListSModels[index].quantity;
      newQTY = quantity;
    } else if (size == 'm') {
      quantity = priceListMModels[index].quantity;
      newQTY = quantity;
    } else if (size == 'l') {
      quantity = priceListLModels[index].quantity;
      newQTY = quantity;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(productAllModels[index].title),
        Text('Size = $size'),
        Container(
          // width: 50.0,
          child: editQTY(quantity),
        ),
      ],
    );
  }

  Widget decButton() {
    return IconButton(
      icon: Icon(Icons.remove_circle_outline),
      onPressed: () {},
    );
  }

  Widget incButton() {
    return IconButton(
      icon: Icon(Icons.add_circle_outline),
      onPressed: () {},
    );
  }

  Widget showValue(int value) {
    return Text('$value');
  }

  Widget editQTY(String quantity) {
    /*
      newQTYint = int.parse(quantity);
      return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        decButton(),
        showValue(newQTYint),
        incButton(),
      ],
    );
    */
    return TextFormField(
      keyboardType: TextInputType.number,
      onChanged: (String string) {
        newQTY = string.trim();
      },
      initialValue: quantity,
    );
  }

  void myAlertDialog(int index, String size) {
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return AlertDialog(
            title: alertTitle(),
            content: alertContent(index, size),
            actions: <Widget>[
              cancelButton(),
              okButton(index, size),
            ],
          );
        });
  }

  Widget okButton(int index, String size) {
    String productID = productAllModels[index].id.toString();
    String unitSize = size;
    String memberID = myUserModel.id.toString();

    return FlatButton(
      child: Text('OK'),
      onPressed: () {
        print(
            'productID = $productID ,unitSize = $unitSize ,memberID = $memberID, newQTY = $newQTY');
        editDetailCart(productID, unitSize, memberID);
        Navigator.of(context).pop();
      },
    );
  }

  // Post ค่าไปยัง API ที่ต้องการ
  Future<void> editDetailCart(
      String productID, String unitSize, String memberID) async {
    String url =
        'http://ptnpharma.com/apishop/json_updatemycart.php?productID=$productID&unitSize=$unitSize&newQTY=$newQTY&memberId=$memberID';

    print('url editDetailCart ====>>>>> $url');

    await http.get(url).then((response) {
      setState(() {
        readCart();
      });
    });
  }

  Widget cancelButton() {
    return FlatButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget deleteButton(int index, String size) {
    return IconButton(
      icon: Icon(Icons.remove_circle_outline),
      onPressed: () {
        confirmDelete(index, size);
      },
    );
  }

  void confirmDelete(int index, String size) {
    String titleProduct = productAllModels[index].title;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm delete'),
            content: Text('Do you want delete : $titleProduct'),
            actions: <Widget>[
              cancelButton(),
              comfirmButton(index, size),
            ],
          );
        });
  }

  Widget comfirmButton(int index, String size) {
    return FlatButton(
      child: Text('Confirm'),
      onPressed: () {
        deleteCart(index, size);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> deleteCart(int index, String size) async {
    String productID = productAllModels[index].id.toString();
    String unitSize = size;
    String memberID = myUserModel.id.toString();

    print('productID = $productID ,unitSize = $unitSize ,memberID = $memberID');

    String url =
        'http://ptnpharma.com/apishop/json_removeitemincart.php?productID=$productID&unitSize=$unitSize&memberId=$memberID';
    print('url DeleteCart#######################======>>>> $url');

    await http.get(url).then((response) {
      setState(() {
        readCart();
      });
    });
  }

  Widget editAndDeleteButton(int index, String size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        editButton(index, size),
        deleteButton(index, size),
      ],
    );
  }

  Widget showSText(int index) {
    String price = sMap[index]['price'].toString();
    String lable = sMap[index]['lable'];
    String quantity = sMap[index]['quantity'];

    //calculateTotal(price, quantity);

    return lable.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                '$price บาท/ $lable',
                style: MyStyle().h3Style,
              ),
              Text(
                'จำนวน $quantity',
                style: MyStyle().h3Style,
              ),
              editAndDeleteButton(index, 's'),
            ],
          );
  }

  void calculateTotal(String price, String quantity) {
    double priceDou = double.parse(price);
    print('price Dou ====>>>> $priceDou');
    double quantityDou = double.parse(quantity);
    print('quantityDou ====>> $quantityDou');
    total = total + (priceDou * quantityDou);
    print('total = $total');
  }

  Widget showMText(int index) {
    String price = mMap[index]['price'].toString();
    String lable = mMap[index]['lable'];
    String quantity = mMap[index]['quantity'];

    return lable.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                '$price บาท/ $lable',
                style: MyStyle().h3Style,
              ),
              Text(
                'จำนวน $quantity',
                style: MyStyle().h3Style,
              ),
              editAndDeleteButton(index, 'm'),
            ],
          );
  }

  Widget showLText(int index) {
    String price = lMap[index]['price'].toString();
    String lable = lMap[index]['lable'];
    String quantity = lMap[index]['quantity'];

    return lable.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                '$price บาท/ $lable',
                style: MyStyle().h3Style,
              ),
              Text(
                'จำนวน $quantity',
                style: MyStyle().h3Style,
              ),
              editAndDeleteButton(index, 'l'),
            ],
          );
  }

  Widget showListCart() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      physics: ScrollPhysics(),
      shrinkWrap: true,
      itemCount: productAllModels.length,
      itemBuilder: (BuildContext buildContext, int index) {
        return Card(
          child: Container(
            padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: Column(
              children: <Widget>[
                showTitle(index),
                showSText(index),
                showMText(index),
                showLText(index),
                // Divider(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget showTotal() {
    return Container(
      padding: EdgeInsets.only(left: 16.0, top: 10.0),
      child: Text(
        'รวม ::  $total บาท',
        style: MyStyle().h1Style,
      ),
    );
  }

  void selectedTransport(String string) {
    transport = string;
    print('Transport ==> $transport');
    setState(() {
      index = int.parse(string);
    });
  }

  Widget showTitleTransport() {
    return Text(
      'การจัดส่ง : ${listTransport[index]}',
      style: TextStyle(
        fontSize: 24.0,
      ),
    );
  }

  Widget showTransport() {
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Card(
        child: PopupMenuButton<String>(
          onSelected: (String string) {
            selectedTransport(string);
          },
          child: showTitleTransport(),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: Text(listTransport[1]),
                value: '1',
              ),
              PopupMenuItem(
                child: Text(listTransport[2]),
                value: '2',
              ),
              PopupMenuItem(
                child: Text(listTransport[3]),
                value: '3',
              ),
              PopupMenuItem(
                child: Text(listTransport[4]),
                value: '4',
              ),
              PopupMenuItem(
                child: Text(listTransport[5]),
                value: '5',
              ),
            ];
          },
        ),
      ),
    );
  }

  Widget commentBox() {
    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        onChanged: (value) {
          comment = value.trim();
        },
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        decoration: InputDecoration(labelText: 'Comment :'),
      ),
    );
  }

  Widget submitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 30.0),
          child: RaisedButton(
            color: MyStyle().textColor,
            onPressed: () {
              if (transport == null) {
                normalDialog(context, 'ยังไม่เลือก  การจัดส่ง',
                    'กรุณา เลือกการจัดส่ง ด้วยค่ะ');
              } else {
                memberID = myUserModel.id.toString();
                print(
                    'transport = $transport, comment = $comment, memberId = $memberID');

                submitThread();
              }
            },
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> submitThread() async {
    try {
      String url =
          'http://ptnpharma.com/apishop/json_submit_myorder.php?memberId=$memberID&transport=$transport&comment=$comment';
      print('url ==> $url');

      await http.get(url).then((value) {
        confirmSubmit();
      });
    } catch (e) {}
  }

  Future<void> confirmSubmit() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Complete'),
            content: Text('การสั่งซื้อเรียบร้อย'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    backProcess();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  void backProcess() {
    Navigator.of(context).pop();
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
      String url = 'http://ptnpharma.com/apishop/json_product.php?bqcode=$code';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: showBottomBarNav(),
      appBar: AppBar(
        backgroundColor: MyStyle().textColor,
        title: Text('ตะกร้าสินค้า'),
      ),
      body: ListView(
        children: <Widget>[
          showListCart(),
          showTotal(),
          showTransport(),
          commentBox(),
          submitButton(),
        ],
      ),
    );
  }
}
