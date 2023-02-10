import 'dart:convert';

// import 'package:barcode_scan2/barcode_scan2.dart';
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
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'my_service.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';

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
  double newQTY = 0;
  double newQTYS = 0;
  double newQTYM = 0;
  double newQTYL = 0;
  int newQTYint = 0;
  double total = 0;
  String transport;
  int index = 0;
  String comment = '', memberID;
  int currentIndex = 3;
  String _result = '';
  String qrString;

  List<String> listTransport = [
    '',
    '1. รับสินค้าเองที่ พัฒนาเภสัช',
    '2. รับสินค้าเองที่คลังสินค้า (ซอยวัดท่าทอง)',
    '3. รถส่งของตามรอบส่งสินค้า ตามสายส่ง',
    '4. รถส่งของตามรอบส่งสินค้าในเมืองนครสวรรค์',
    '5. ส่งทางบริษัทขนส่ง (เอกชน)'
  ];

  // List<String> listTransport = [
  //   '',
  //   '1. รับสินค้าเองที่ พัฒนาเภสัช',
  //   '2. รับเองที่คลังสินค้า(ซอยวัดท่าทอง)',
  //   '3. รถส่งของตามรอบสายส่งสินค้า',
  //   '4. รถส่งตามรอบส่งในเมืองนครสวรรค์',
  //   '5. ส่งทางบริษัทขนส่ง (เอกชน)'
  // ];

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

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    // print('cartList =======>>> $cartList');

    for (var map in cartList) {
      ProductAllModel2 productAllModel = ProductAllModel2.fromJson(map);

      // print('productAllModel = ${productAllModel.toJson().toString()}');

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
        priceListModel.quantity = priceListModel.quantity.replaceAll(',', '');
        print('quantity >> ' + priceListModel.quantity);
        calculateTotal(priceListModel.price, (priceListModel.quantity));
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
        priceListModel.quantity = priceListModel.quantity.replaceAll(',', '');
        calculateTotal(priceListModel.price, (priceListModel.quantity));
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
        priceListModel.quantity = priceListModel.quantity.replaceAll(',', '');
        calculateTotal(priceListModel.price, (priceListModel.quantity));
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
            ' $amontCart ',
            style: TextStyle(
              backgroundColor: Colors.red.shade600,
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
                fontSize: 16.0,
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
    double quantity = 0;
    String unitText = '';
    if (size == 's') {
      quantity = double.parse(priceListSModels[index].quantity);
      newQTYS = (quantity).toDouble();
      unitText = priceListSModels[index].lable;
    } else if (size == 'm') {
      quantity = double.parse(priceListMModels[index].quantity);
      newQTYM = (quantity).toDouble();
      unitText = priceListMModels[index].lable;
    } else if (size == 'l') {
      quantity = double.parse(priceListLModels[index].quantity);
      newQTYL = (quantity).toDouble();
      unitText = priceListLModels[index].lable;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(productAllModels[index].title),
        Text('Size = $unitText'),
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

  Widget editQTY(double quantity) {
    // return TextFormField(
    //   keyboardType: TextInputType.number,
    //   onChanged: (String string) {
    //     newQTY = string.trim();
    //   },
    //   initialValue: quantity,
    // );
    return SpinBox(
        value: (quantity).toDouble(),
        min: 1,
        max: 10000,
        onChanged: (changevalue) {
          newQTY = (changevalue == 0) ? 0 : (changevalue).toDouble();

          // if (index == 0) {
          //   setState(() {
          //     qtyS = (changevalue == 0) ? 0 : (changevalue).toInt();
          //   });
          // } else if (index == 1) {
          //   setState(() {
          //     qtyM = (changevalue == 0) ? 0 : (changevalue).toInt();
          //   });
          // } else if (index == 2) {
          //   setState(() {
          //     qtyL = (changevalue == 0) ? 0 : (changevalue).toInt();
          //   });
          // }
        }
        // decoration: InputDecoration(labelText: 'Decimals'),
        );
  }

  Widget changeQTY(String productID, String size, double quantity) {
    String memberID = myUserModel.id.toString();
    return SizedBox(
      width: 140.0,
      child: SpinBox(
          value: (quantity).toDouble(),
          min: 1,
          max: 10000,
          onChanged: (changevalue) {
            newQTY = (changevalue == 0) ? 0 : (changevalue).toDouble();
            print(
                'productID = $productID ,unitSize = $size ,memberID = $memberID, newQTY = $newQTY');
            updateDetailCart(productID, size, memberID);
          }),
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

    return TextButton(
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

    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        readCart();
      });
    });
  }

  Future<void> updateDetailCart(
      String productID, String unitSize, String memberID) async {
    String url =
        'http://ptnpharma.com/apishop/json_updatemycart.php?productID=$productID&unitSize=$unitSize&newQTY=$newQTY&memberId=$memberID';
    print('url editDetailCart ====>>>>> $url');
    await http.get(Uri.parse(url)).then((response) {});

    String url2 = '${MyStyle().loadMyCart}$memberID';
    http.Response response = await http.get(Uri.parse(url2));
    var result = json.decode(response.body);
    var cartList = result['cart'];

    double totalPrice = 0;
    for (var map in cartList) {
      ProductAllModel2 productAllModel = ProductAllModel2.fromJson(map);
      // print('productAllModel = ${productAllModel.toJson().toString()}');
      Map<String, dynamic> priceListMap = map['price_list'];

      var priceDou = 0;
      var quantityDou = 0;

      Map<String, dynamic> sizeSmap = priceListMap['s'];
      if (sizeSmap == null) {
        sMap.add({'lable': ''});
        PriceListModel priceListModel = PriceListModel.fromJson({'lable': ''});
        priceListSModels.add(priceListModel);
      } else {
        sMap.add(sizeSmap);

        PriceListModel priceListModel = PriceListModel.fromJson(sizeSmap);
        priceListSModels.add(priceListModel);

        double priceDou = double.parse(priceListModel.price);
        double quantityDou =
            (double.parse(priceListModel.quantity.replaceAll(',', '')));
        totalPrice = totalPrice + (priceDou * quantityDou);
      }

      Map<String, dynamic> sizeMmap = priceListMap['m'];
      if (sizeMmap == null) {
        mMap.add({'lable': ''});
        PriceListModel priceListModel = PriceListModel.fromJson({'lable': ''});
        priceListMModels.add(priceListModel);
      } else {
        mMap.add(sizeMmap);
        PriceListModel priceListModel = PriceListModel.fromJson(sizeMmap);
        priceListMModels.add(priceListModel);
        double priceDou = double.parse(priceListModel.price);
        double quantityDou =
            (double.parse(priceListModel.quantity.replaceAll(',', '')));
        totalPrice = totalPrice + (priceDou * quantityDou);
      }

      Map<String, dynamic> sizeLmap = priceListMap['l'];
      if (sizeLmap == null) {
        lMap.add({'lable': ''});
        PriceListModel priceListModel = PriceListModel.fromJson({'lable': ''});
        priceListLModels.add(priceListModel);
      } else {
        lMap.add(sizeLmap);
        PriceListModel priceListModel = PriceListModel.fromJson(sizeLmap);
        priceListLModels.add(priceListModel);
        double priceDou = double.parse(priceListModel.price);
        double quantityDou =
            (double.parse(priceListModel.quantity.replaceAll(',', '')));
        totalPrice = totalPrice + (priceDou * quantityDou);
      }
    }
    setState(() {
      total = totalPrice;
      showTotal();
    });
  }

  Widget cancelButton() {
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget deleteButton(int index, String size) {
    return IconButton(
      icon: Icon(Icons.delete),
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
    return TextButton(
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

    await http.get(Uri.parse(url)).then((response) {
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

  void calculateTotal(String price, String quantity) {
    double priceDou = double.parse(price);
    print('price Dou ====>>>> $priceDou');
    quantity = quantity.replaceAll(',', '');
    double quantityDou = double.parse(quantity);
    print('quantityDou ====>> $quantityDou');
    total = total + (priceDou * quantityDou);
    print('total = $total');
  }

  Widget showSText(int index) {
    String productID = productAllModels[index].id.toString();
    String priceS = sMap[index]['price'].toString();
    String lableS = sMap[index]['lable'];
    String quantityS = sMap[index]['quantity'];
    double showQTYS =
        (quantityS == null) ? 0.0 : double.parse(quantityS.replaceAll(',', ''));

    return lableS.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                '$priceS บาท/ $lableS',
                style: MyStyle().h3Style,
              ),
              changeQTY(productID, 's', showQTYS),
              deleteButton(index, 's'),
            ],
          );
  }

  Widget showMText(int index) {
    String productID = productAllModels[index].id.toString();
    String priceM = mMap[index]['price'].toString();
    String lableM = mMap[index]['lable'];
    String quantityM = mMap[index]['quantity'];
    double showQTYM =
        (quantityM == null) ? 0.0 : double.parse(quantityM.replaceAll(',', ''));

    return lableM.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                '$priceM บาท/ $lableM',
                style: MyStyle().h3Style,
              ),
              changeQTY(productID, 'm', showQTYM),
              deleteButton(index, 'm'),
            ],
          );
  }

  Widget showLText(int index) {
    String productID = productAllModels[index].id.toString();
    String priceL = lMap[index]['price'].toString();
    String lableL = lMap[index]['lable'];
    String quantityL = lMap[index]['quantity'];
    double showQTYL =
        (quantityL == null) ? 0.0 : double.parse(quantityL.replaceAll(',', ''));

    return lableL.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                '$priceL บาท/ $lableL',
                style: MyStyle().h3Style,
              ),
              changeQTY(productID, 'l', showQTYL),
              deleteButton(index, 'l'),
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(width: 2, color: Colors.grey.shade200)),
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
    return Card(
      child: Center(
        child: Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Text(
            'ยอดรวม        $total บาท',
            style: MyStyle().h1Style,
          ),
        ),
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
        fontSize: 20.0,
      ),
    );
  }

  Widget showTransport() {
    return Container(
      width: 400.0,
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Card(
        child: PopupMenuButton<String>(
          onSelected: (String string) {
            selectedTransport(string);
          },
          child: showTitleTransport(),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                child: new Container(
                  width: 400.0,
                  child: Text(listTransport[1]),
                ),
                value: '1',
              ),
              PopupMenuItem(
                child: new Container(
                  width: 400.0,
                  child: Text(listTransport[2]),
                ),
                value: '2',
              ),
              PopupMenuItem(
                child: new Container(
                  width: 400.0,
                  child: Text(listTransport[3]),
                ),
                value: '3',
              ),
              PopupMenuItem(
                child: new Container(
                  width: 400.0,
                  child: Text(listTransport[4]),
                ),
                value: '4',
              ),
              PopupMenuItem(
                child: new Container(
                  width: 400.0,
                  child: Text(listTransport[5]),
                ),
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
          child: ElevatedButton(
            // color: MyStyle().textColor,
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
        SizedBox(
          width: 10.0,
          height: (myUserModel.msg == '') ? 0 : 90.0,
        )
      ],
    );
  }

  Future<void> submitThread() async {
    try {
      String url =
          'http://ptnpharma.com/apishop/json_submit_myorder.php?memberId=$memberID&transport=$transport&comment=$comment';
      print('url ==> $url');

      await http.get(Uri.parse(url)).then((value) {
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
              TextButton(
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
      label: 'Home',
    );
  }

  BottomNavigationBarItem cartBotton() {
    return BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart), label: 'Cart');
  }

  BottomNavigationBarItem readQrBotton() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.code),
      label: 'QR code',
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
          // readQRcode();
          readQRcodePreview();
        }
      },
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
          'http://ptnpharma.com/apishop/json_productlist.php?bqcode=$code';
      http.Response response = await http.get(Uri.parse(url));
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
        routeToListProductfav(0);
        break; // all product
      case 2:
        routeToListProduct(0);
        break; // all product
      case 3:
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyStyle().bgColor,
        title: Text('ตะกร้าสินค้า'),
      ),
      body: ListView(
        children: <Widget>[
          showTotal(),
          showListCart(),
          showTotal(),
          showTransport(),
          commentBox(),
          submitButton(),
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
