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
      http.Response response = await http.get(Uri.parse(url));
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
        incDecValue(index),
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

  Widget decButton(int index) {
    int value = amounts[index];
    return IconButton(
      icon: Icon(Icons.remove_circle_outline),
      onPressed: () {
        // print('dec index $index');
        if (value == 0) {
          normalDialog(context, 'Cannot decrese', 'Because empty cart');
        } else {
          setState(() {
            value--;
            amounts[index] = value;
          });
        }
      },
    );
  }

  Widget incButton(int index) {
    int value = amounts[index];

    return IconButton(
      icon: Icon(Icons.add_circle_outline),
      onPressed: () {
        setState(() {
          // print('inc index $index');
          value++;
          amounts[index] = value;
          print('inc value = $value');
        });
      },
    );
  }

  Widget showValue(int value) {
    return Text('$value');
  }

  Widget incDecValue(int index) {
    int value = amounts[index];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        decButton(index),
        showValue(value),
        incButton(index),
      ],
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
        'https://ptnpharma.com/apishop/json_loadmycart.php?memberId=$memberId';

    // print('url Detail =====>>>>>>>> $url');
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    for (var map in cartList) {
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
              child: ElevatedButton(
                // color: MyStyle().mainColor,
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

                  int index = 0;
                  List<bool> status = List();

                  for (var object in unitSizeModels) {
                    if (amounts[index] == 0) {
                      status.add(true);
                    } else {
                      status.add(false);
                    }

                    index++;
                  }

                  bool sumStatus = true;
                  if (status.length == 1) {
                    sumStatus = status[0];
                  } else {
                    sumStatus = status[0] && status[1] && status[2];
                  }

                  if (sumStatus) {
                    normalDialog(
                        context, 'Do not choose item', 'Please choose item');
                  } else {
                    int index = 0;
                    for (var object in unitSizeModels) {
                      String unitSize = unitSizeModels[index].unit;
                      int qTY = amounts[index];

                      print(
                          'productID = $productID, memberID=$memberID, unitSize=$unitSize, QTY=$qTY');
                      if (qTY != 0) {
                        addCart(productID, unitSize, qTY, memberID);
                      }
                      index++;
                    }
                  }
                },
              ),
            ),
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
    await http.get(Uri.parse(url)).then((response) {});
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
        showImage(),
        MyStyle().mySizebox(),
        showTitle(),
        MyStyle().mySizebox(),
        showDetail(),
        showPrice(),
      ],
    );
  }
}
