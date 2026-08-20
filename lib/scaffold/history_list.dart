import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/scaffold/history_detail.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:ptncenter/scaffold/my_service.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class OrderHistoryItem {
  final String orderNo;
  final String status;
  final String orderDate;
  final String? detailId;

  OrderHistoryItem({
    required this.orderNo,
    required this.status,
    required this.orderDate,
    this.detailId,
  });
}

class HistoryList extends StatefulWidget {
  final UserModel? userModel;

  const HistoryList({Key? key, this.userModel}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  UserModel? myUserModel;
  List<OrderHistoryItem> orders = [];
  int totalRecords = 0;
  int page = 1;
  bool hasNextPage = false;
  bool loading = true;
  int selectIndex = 3;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    readData();
  }

  Future<void> readData() async {
    setState(() {
      loading = true;
    });

    String? memberId = myUserModel?.id;
    String? memberCode = myUserModel?.customerCode;
    String url = 'https://www.ptnpharma.com/shop/pages/tables/pageforapp_orderhistory.php'
        '?memberId=$memberId&memberCode=$memberCode&page=$page';
    print('url (history) > $url');

    try {
      http.Response response = await http.get(Uri.parse(url));
      var document = html_parser.parse(response.body);

      int total = 0;
      var totalStrong = document.querySelector('h4 strong');
      if (totalStrong != null) {
        total = int.tryParse(
                totalStrong.text.trim().replaceAll(',', '').replaceAll(' ', '')) ??
            0;
      }

      List<OrderHistoryItem> items = [];
      for (var box in document.querySelectorAll('.box-item-2')) {
        String orderNo = box.querySelector('.box-item-title')?.text.trim() ?? '';
        if (orderNo.isEmpty) continue;

        String status = box.querySelector('.user-follow-info')?.text.trim() ?? '';

        String orderDate = '';
        Match? dateMatch =
            RegExp(r'Order date\s*:\s*([^\n]+)').firstMatch(box.text);
        if (dateMatch != null) {
          orderDate = dateMatch.group(1)!.trim();
        }

        String? detailId;
        String? detailHref =
            box.querySelector('a.action-button')?.attributes['href'];
        if (detailHref != null) {
          Match? idMatch = RegExp(r'id=(\d+)').firstMatch(detailHref);
          detailId = idMatch?.group(1);
        }

        items.add(OrderHistoryItem(
          orderNo: orderNo,
          status: status,
          orderDate: orderDate,
          detailId: detailId,
        ));
      }

      bool nextPage = document.querySelector('.pagination li.next') != null;

      setState(() {
        orders = items;
        totalRecords = total;
        hasNextPage = nextPage;
        loading = false;
      });
    } catch (e) {
      print('readData (history) error: $e');
      setState(() {
        loading = false;
      });
    }
  }

  void goToPage(int newPage) {
    if (newPage < 1) return;
    setState(() {
      page = newPage;
    });
    readData();
  }

  void openDetail(OrderHistoryItem order) {
    if (order.detailId == null) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => HistoryDetail(
        userModel: myUserModel,
        detailId: order.detailId!,
        orderNo: order.orderNo,
      ),
    ));
  }

  static const Map<String, Color> statusColorMap = {
    'ยังไม่ได้ตรวจสอบ': Colors.red,
    'ตรวจสอบใบสั่งซื้อ': Colors.green,
    'ใบส่งสินค้า': Colors.blue,
    'ไม่จัดส่ง': Color(0xFFD17F79),
  };

  Color statusColor(String status) {
    return statusColorMap[status.trim()] ?? Colors.grey;
  }

  static final RegExp priceChangeRegex =
      RegExp(r'เปลี่ยนแปลงราคา\s*\d+\s*รายการ');

  String cleanOrderDate(String orderDate) {
    return orderDate.replaceAll(priceChangeRegex, '').trim();
  }

  String? priceChangeNote(String orderDate) {
    return priceChangeRegex.firstMatch(orderDate)?.group(0);
  }

  Widget orderTile(OrderHistoryItem order) {
    String? priceChange = priceChangeNote(order.orderDate);

    return Card(
      child: ListTile(
        onTap: order.detailId != null ? () => openDetail(order) : null,
        title: Text(order.orderNo, style: MyStyle().h3bStyle),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('วันที่สั่ง: ${cleanOrderDate(order.orderDate)}',
                style: MyStyle().h4StyleGray),
            if (priceChange != null)
              Text(priceChange,
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (order.status.isNotEmpty)
              Text(order.status,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: statusColor(order.status))),
            if (order.detailId != null)
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget totalRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Text(
        'พบ $totalRecords รายการ',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget pageControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ElevatedButton.icon(
            onPressed: page > 1 ? () => goToPage(page - 1) : null,
            icon: Icon(Icons.chevron_left),
            label: Text('ก่อนหน้า'),
          ),
          Text('หน้า $page', style: MyStyle().h4bStyleGray),
          ElevatedButton.icon(
            onPressed: hasNextPage ? () => goToPage(page + 1) : null,
            icon: Icon(Icons.chevron_right),
            label: Text('ถัดไป'),
            style: ButtonStyle(
              iconAlignment: IconAlignment.end,
            ),
          ),
        ],
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

    if (orders.isEmpty) {
      return Expanded(
        child: Center(
          child: Text('ไม่พบประวัติการสั่งซื้อ', style: MyStyle().h4StyleGray),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        itemCount: orders.length,
        itemBuilder: (BuildContext context, int index) =>
            orderTile(orders[index]),
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
        title: Text('ประวัติการสั่งซื้อ', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          totalRow(),
          showContent(),
          pageControls(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(),
    );
  }
}
