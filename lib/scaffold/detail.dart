import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/product_all_model2.dart';
import 'package:ptncenter/models/unit_size_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';

import 'package:ptncenter/scaffold/list_product.dart';

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
  List<int> amounts = [
    0,
    0,
    0
  ]; // amount[0] -> s,amount[1] -> m,amount[2] -> l;
  int amontCart = 0;
  UserModel myUserModel;
  String id; // productID
  // int qtyS = 0, qtyM = 0, qtyL = 0;
  String qtyS = '', qtyM = '', qtyL = '';
  int sizeSincart = 0, sizeMincart = 0, sizeLincart = 0;
  int showSincart = 0, showMincart = 0, showLincart = 0;
    // int qtyS = 0, qtyM = 0, qtyL = 0;

  // Method
  @override
  void initState() {
    super.initState();
    currentProductAllModel = widget.productAllModel;
    myUserModel = widget.userModel;
    setState(() {
      getProductWhereID();
      readCart();
    });
  }

  Future<void> getProductWhereID() async {
    if (currentProductAllModel != null) {
      String memberId = myUserModel.id.toString();
      id = currentProductAllModel.id.toString();
      String url = '${MyStyle().getProductWhereId}$id&memberId=$memberId';
      print('url Detaillll ====>>> $url');
      http.Response response = await http.get(url);
      var result = json.decode(response.body);
      print('result =0000000>>> $result');

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
          // print('unitSizeModel = ${unitSizeModels[0].lable}');
        });
      } // for
    }
  }

  Widget showImage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5 - 50,
      child: Image.network(
        productAllModel.photo,
        fit: BoxFit.contain,
      ),
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
    return Text(
      unitSizeModels[index].lable,
      style: MyStyle().h3Style,
    );
  }

  Widget showPricePackage(int index) {
    return Text(
      '${unitSizeModels[index].price.toString()} บาท/ ',
      style: MyStyle().h3Style,
    );
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
    // int value = amounts[index];
    //  return Text('$value');
     int iniValue = 0;
    // print('$sizeSincart / $sizeMincart / $sizeLincart ');
    if (index == 0)
      iniValue = showSincart;
    else if (index == 1)
      iniValue = showMincart;
    else if (index == 2)
      iniValue = showLincart;

    return Container(
      // decoration: MyStyle().boxLightGreen,
      // height: 35.0,
      width: MediaQuery.of(context).size.width * 0.35,
      padding: EdgeInsets.only(left: 20.0, right: 10.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            style: TextStyle(color: Colors.black),
            initialValue: '$iniValue',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (index == 0)
                qtyS = value;
              else if (index == 1)
                qtyM = value;
              else if (index == 2) qtyL = value;
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 6.0,
              ),
              prefixIcon: Icon(Icons.mode_edit, color: Colors.grey),
              // border: InputBorder.none,
              hintText: 'ระบุจำนวน',
              hintStyle: TextStyle(color: Colors.grey),
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
          return showChoosePricePackage(index); // showDetailPrice(index);
        },
      ),
    );
  }

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel.id.toString();
    String url =
        'http://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    // print('url Detail =====>>>>>>>> $url');
    http.Response response = await http.get(url);
    var result = json.decode(response.body);
    var cartList = result['cart'];
    var thisproductID = id;

    for (var map in cartList) {
      var productID =   map['id'].toString();
      
      if(productID == thisproductID){
        if(map['price_list']['s'] != null){
            var sizeSincart = int.parse(map['price_list']['s']['quantity']);
            setState(() {
              showSincart =  sizeSincart;
            });
        }
        if(map['price_list']['m'] != null){
            int sizeMincart = int.parse(map['price_list']['m']['quantity']);
            setState(() {
              showMincart =  sizeMincart;
            });
       }
        if(map['price_list']['l'] != null){
            int sizeLincart = int.parse(map['price_list']['l']['quantity']);
            setState(() {
              showLincart =  sizeLincart;
            });
        }
      }

      setState(() {
        amontCart++;
      });
    }
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
              '$amontCart',
              style: TextStyle(
                backgroundColor: Colors.blue.shade600,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          showCart(),
        ],
        backgroundColor: MyStyle().textColor,
        title: Text('ข้อมูลสินค้า'),
      ),
      body: productAllModel == null ? showProgress() : showDetailList(),
    );
  }

  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
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


                  if (qtyS != 0 && qtyS != '') {
                    String unitSize = 's';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=s, QTY=$qtyS');
                    addCart(productID, unitSize, qtyS, memberID);
                  }
                  if (qtyM != 0 && qtyM != '') {
                    String unitSize = 'm';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=m, QTY=$qtyM');
                    addCart(productID, unitSize, qtyM, memberID);
                  }
                  if (qtyL != 0 && qtyL != '') {
                    String unitSize = 'l';
                    print(
                        'productID = $productID, memberID=$memberID, unitSize=l, QTY=$qtyL');
                    addCart(productID, unitSize, qtyL, memberID);
                  }
                  
                  // for (var object in unitSizeModels) {
                  //   if (amounts[index] == 0) {
                  //     status.add(true);
                  //   } else {
                  //     status.add(false);
                  //   }

                  //   index++;
                  // }

                  // bool sumStatus = true;
                  // if (status.length == 1) {
                  //   sumStatus = status[0];
                  // } else {
                  //   sumStatus = status[0] && status[1] && status[2];
                  // }

                  // if (sumStatus) {
                  //   normalDialog(
                  //       context, 'Do not choose item', 'Please choose item');
                  // } else {
                  //   int index = 0;
                  //   for (var object in unitSizeModels) {
                  //     String unitSize = unitSizeModels[index].unit;
                  //     int qTY = amounts[index];

                  //     print(
                  //         'productID = $productID, memberID=$memberID, unitSize=$unitSize, QTY=$qTY');
                  //     if (qTY != 0) {
                  //       addCart(productID, unitSize, qTY, memberID);
                  //     }
                  //     index++;
                  //   }
                  // }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> addCart(
      String productID, String unitSize, String qTY, String memberID) async {
    String url =
        'http://www.ptnpharma.com/apishop/json_savemycart.php?productID=$productID&unitSize=$unitSize&QTY=$qTY&memberId=$memberID';
    print('urlAddcart = $url');
    await http.get(url).then((response) {});
    print('upload ok');
    Navigator.pop(context, true);
  }

  Widget showDetailList() {
    return Card(
      child: Stack(
        children: <Widget>[
          showController(),
          addButton(),
        ],
      ),
    );
  }

  ListView showController() {
    return ListView(
      padding: EdgeInsets.all(10.0),
      children: <Widget>[
        showTitle(),
        MyStyle().mySizebox(),
        showDetail(),
        showPrice(),
        MyStyle().mySizebox(),
        showImage(),
      ],
    );
  }
}
