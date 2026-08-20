import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:ptncenter/scaffold/my_service.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class HistoryDetailItem {
  final String name;
  final String price;
  final String unit;
  final String orderedQty;
  final String receivedQty;
  final String total;
  final String? productId;
  final String? unitCode;

  HistoryDetailItem({
    required this.name,
    required this.price,
    required this.unit,
    required this.orderedQty,
    required this.receivedQty,
    required this.total,
    this.productId,
    this.unitCode,
  });
}

class HistoryDetail extends StatefulWidget {
  final UserModel? userModel;
  final String detailId;
  final String? orderNo;

  const HistoryDetail({
    Key? key,
    this.userModel,
    required this.detailId,
    this.orderNo,
  }) : super(key: key);

  @override
  _HistoryDetailState createState() => _HistoryDetailState();
}

class _HistoryDetailState extends State<HistoryDetail> {
  UserModel? myUserModel;
  bool loading = true;
  int selectIndex = 3;

  String orderNo = '';
  String status = '';
  String orderDate = '';
  String delivery = '';
  List<HistoryDetailItem> items = [];
  String subtotal = '';
  String shipping = '';
  String grandTotal = '';
  Set<String> addedToCartKeys = {};

  String cartKey(HistoryDetailItem item) => '${item.productId}_${item.unitCode}';

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    orderNo = widget.orderNo ?? '';
    readData();
    readCart();
  }

  String formatAmount(String value) {
    String cleaned = value.trim().replaceAll(',', '');
    double? number = double.tryParse(cleaned);
    if (number == null) return value;
    return NumberFormat('#,##0.00').format(number);
  }

  static final RegExp priceChangeRegex = RegExp(r'\([+-]\d+(?:\.\d+)?\)');

  String cleanPrice(String price) {
    return price.replaceAll(priceChangeRegex, '').trim();
  }

  String? priceChangeText(String price) {
    return priceChangeRegex.firstMatch(price)?.group(0);
  }

  Widget priceUnitText(HistoryDetailItem item) {
    String? change = priceChangeText(item.price);
    String price = cleanPrice(item.price);

    if (change == null) {
      return Text('$price บาท / ${item.unit}', style: MyStyle().h4StyleGray);
    }

    return RichText(
      text: TextSpan(
        style: MyStyle().h4StyleGray,
        children: <TextSpan>[
          TextSpan(text: '$price บาท / ${item.unit} '),
          TextSpan(
            text: change,
            style: TextStyle(
              color: change.contains('+') ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> readCart() async {
    String? memberId = myUserModel?.id;
    String url =
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId';
    print('url readCart (history detail) > $url');

    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      var cartList = result['cart'];
      if (cartList is List) {
        Set<String> keys = {};
        for (var mapCart in cartList) {
          String? id = mapCart['id']?.toString();
          var priceList = mapCart['price_list'];
          if (id != null && priceList is Map) {
            for (var unitKey in priceList.keys) {
              keys.add('${id}_$unitKey');
            }
          }
        }

        if (mounted) {
          setState(() {
            addedToCartKeys.addAll(keys);
          });
        }
      }
    } catch (e) {
      print('readCart (history detail) error: $e');
    }
  }

  String extractSummaryValue(dom.Document document, String label) {
    for (var strong in document.querySelectorAll('strong')) {
      if (strong.text.trim() == label) {
        dom.Element? row = strong.parent?.parent;
        if (row != null) {
          var cells = row.querySelectorAll('td');
          if (cells.length >= 2) {
            return cells.last.text.trim();
          }
        }
      }
    }
    return '';
  }

  Future<void> readData() async {
    setState(() {
      loading = true;
    });

    String? memberCode = myUserModel?.customerCode;
    String url = 'https://www.ptnpharma.com/shop/pages/tables/'
        'pageforapp_orderhistory_detail.php?mode=v&id=${widget.detailId}&memberCode=$memberCode';
    print('url (history detail) > $url');

    try {
      http.Response response = await http.get(Uri.parse(url));
      var document = html_parser.parse(response.body);

      String parsedOrderNo = '';
      var h4 = document.querySelector('.box-header h4');
      if (h4 != null) {
        String raw = h4.text.replaceAll(' ', ' ');
        raw = raw.replaceFirst('หมายเลขใบสั่งซื้อ', '');
        List<String> tokens =
            raw.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
        if (tokens.isNotEmpty) parsedOrderNo = tokens.first;
      }

      String parsedStatus = '';
      String parsedOrderDate = '';
      String parsedDelivery = '';
      for (var group in document.querySelectorAll('.box-body .form-group')) {
        var label = group.querySelector('label');
        var valueDiv = group.querySelector('div');
        if (label == null || valueDiv == null) continue;

        String labelText = label.text.trim();
        String valueText = valueDiv.text.trim();
        if (labelText == 'สถานะ') {
          parsedStatus = valueText;
        } else if (labelText == 'วันที่สั่ง') {
          parsedOrderDate = valueText;
        } else if (labelText == 'การจัดส่ง') {
          parsedDelivery = valueText;
        }
      }

      List<HistoryDetailItem> parsedItems = [];
      for (var itemTable in document.querySelectorAll('table table')) {
        var rows = itemTable.querySelectorAll('tr');
        if (rows.length < 3) continue;

        var valueCells = rows[2].querySelectorAll('td');
        if (valueCells.length < 6) continue;

        String? productId;
        String? unitCode;
        String? inputName =
            itemTable.querySelector('input')?.attributes['name'];
        if (inputName != null) {
          Match? match = RegExp(r'q\[(\d+)\]\[(\w+)\]').firstMatch(inputName);
          productId = match?.group(1);
          unitCode = match?.group(2);
        }

        parsedItems.add(HistoryDetailItem(
          name: rows[0].text.trim(),
          price: valueCells[0].text.trim(),
          unit: valueCells[1].text.trim(),
          orderedQty: valueCells[2].text.trim(),
          receivedQty: valueCells[3].text.trim(),
          total: valueCells[5].text.trim(),
          productId: productId,
          unitCode: unitCode,
        ));
      }

      String parsedSubtotal = extractSummaryValue(document, 'ยอดรวมสินค้า');
      String parsedShipping = extractSummaryValue(document, 'ค่าจัดส่ง');
      String parsedGrandTotal = extractSummaryValue(document, 'ยอดรวมทั้งหมด');

      setState(() {
        if (parsedOrderNo.isNotEmpty) orderNo = parsedOrderNo;
        status = parsedStatus;
        orderDate = parsedOrderDate;
        delivery = parsedDelivery;
        items = parsedItems;
        subtotal = parsedSubtotal;
        shipping = parsedShipping;
        grandTotal = parsedGrandTotal;
        loading = false;
      });
    } catch (e) {
      print('readData (history detail) error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> addToCart(HistoryDetailItem item) async {
    if (item.productId == null || item.unitCode == null) return;

    int qty = int.tryParse(item.orderedQty) ?? 1;
    String? memberId = myUserModel?.id;
    String url = '${MyStyle().serverName}/json_savemycart.php'
        '?productID=${item.productId}&unitSize=${item.unitCode}&QTY=$qty&memberId=$memberId';
    print('url addToCart (history detail) > $url');

    try {
      await http.get(Uri.parse(url));
      if (mounted) {
        setState(() {
          addedToCartKeys.add(cartKey(item));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'เพิ่ม "${item.name}" จำนวน $qty ${item.unit} ลงตะกร้าแล้ว')),
        );
      }
    } catch (e) {
      print('addToCart (history detail) error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เพิ่มลงตะกร้าไม่สำเร็จ')),
        );
      }
    }
  }

  Widget infoRow(String label, String value, {bool alignValueRight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 100.0,
            child: Text(label, style: MyStyle().h4bStyleGray),
          ),
          Expanded(
            child: Text(
              value,
              style: MyStyle().h4StyleGray,
              textAlign: alignValueRight ? TextAlign.right : TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(orderNo, style: MyStyle().h3bStyle),
            SizedBox(height: 8.0),
            infoRow('สถานะ', status),
            infoRow('วันที่สั่ง', orderDate),
            infoRow('การจัดส่ง', delivery),
          ],
        ),
      ),
    );
  }

  Widget itemTile(HistoryDetailItem item) {
    bool alreadyInCart = addedToCartKeys.contains(cartKey(item));
    bool canAddToCart =
        item.productId != null && item.unitCode != null && !alreadyInCart;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.name, style: MyStyle().h4bStyleGray),
                  SizedBox(height: 6.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      priceUnitText(item),
                      Text('สั่ง ${item.orderedQty} / ได้รับ ${item.receivedQty}',
                          style: item.orderedQty == item.receivedQty
                              ? MyStyle().h4StyleGray
                              : TextStyle(fontSize: 14.0, color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_shopping_cart,
                  size: 30.0,
                  color: canAddToCart
                      ? MyStyle().mainColor
                      : Colors.grey.shade400),
              onPressed: canAddToCart ? () => addToCart(item) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            infoRow('ยอดรวมสินค้า', '${formatAmount(subtotal)} บาท',
                alignValueRight: true),
            infoRow('ค่าจัดส่ง', '${formatAmount(shipping)} บาท',
                alignValueRight: true),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('ยอดรวมทั้งหมด', style: MyStyle().h3bStyle),
                Text('${formatAmount(grandTotal)} บาท',
                    style: MyStyle().h3bStyleRed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showContent() {
    if (loading) {
      return Expanded(
        child: Center(
            child: CircularProgressIndicator(color: MyStyle().mainColor)),
      );
    }

    return Expanded(
      child: ListView(
        padding: EdgeInsets.all(10.0),
        children: <Widget>[
          infoCard(),
          SizedBox(height: 10.0),
          ...items.map(itemTile),
          SizedBox(height: 10.0),
          summaryCard(),
        ],
      ),
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(index: index, userModel: myUserModel);
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProductfav(index: index, userModel: myUserModel);
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailCart(userModel: myUserModel);
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget stylishBottomBar() {
    return StylishBottomBar(
      option: AnimatedBarOptions(
        iconStyle: IconStyle.animated,
        opacity: 0.3,
      ),
      items: [
        BottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text('Home'),
          backgroundColor: Colors.blue,
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
      hasNotch: true,
      currentIndex: selectIndex,
      onTap: (index) {
        setState(() {
          selectIndex = index;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: MyStyle().bgColor,
        title: Text(orderNo.isEmpty ? 'รายละเอียดคำสั่งซื้อ' : orderNo,
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          showContent(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(),
    );
  }
}
