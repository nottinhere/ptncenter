import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:ptncenter/models/orn_model.dart';
import 'package:ptncenter/models/orn_product_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/orn_list.dart';
import 'package:ptncenter/scaffold/orn_menu.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'my_service.dart';

class ListProductOrn extends StatefulWidget {
  final UserModel? userModel;
  final String? ornId;
  final String? ornNo;

  const ListProductOrn({Key? key, this.userModel, this.ornId, this.ornNo})
      : super(key: key);

  @override
  _ListProductOrnState createState() => _ListProductOrnState();
}

class _ListProductOrnState extends State<ListProductOrn> {
  UserModel? myUserModel;
  String? ornId;
  String? ornNo;
  List<OrnProductModel> ornProductModels = [];
  List<OrnProductModel> filterOrnProductModels = [];
  int page = 1;
  int totalRecords = 0;
  bool visible = true;
  ScrollController scrollController = ScrollController();
  int selectIndex = 2;
  String? qrString;

  String productTab = 'all'; // 'notreceived' or 'all'

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    ornId = widget.ornId;
    ornNo = widget.ornNo;

    createController(); // เมื่อ scroll to bottom

    readData();
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          page = page + 1;
          readData();
        }
      }
    });
  }

  Future<void> readData() async {
    setState(() {
      visible = true;
    });

    String? memberId = myUserModel!.id;
    String url =
        '${MyStyle().serverName}/apishop/json_orn_productlist.php?memberId=$memberId&orn_id=$ornId&page=$page';
    print('url > $url');
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemsProduct = result['itemsProduct'] ?? [];
    totalRecords = int.tryParse(result['totalRecords']?.toString() ?? '0') ?? 0;
    print('totalRecords > $totalRecords');

    if (itemsProduct is List) {
      for (var map in itemsProduct) {
        OrnProductModel ornProductModel = OrnProductModel.fromJson(map);
        ornProductModels.add(ornProductModel);
      }
    }

    setState(() {
      visible = false;
    });
    applyProductTab();
  }

  void applyProductTab() {
    setState(() {
      if (productTab == 'notreceived') {
        filterOrnProductModels =
            ornProductModels.where((item) => item.receive == 0).toList();
      } else {
        filterOrnProductModels = ornProductModels;
      }
    });
  }

  Widget productTabButton(String value, String label) {
    bool selected = productTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          productTab = value;
          applyProductTab();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? MyStyle().bgColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget productTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Row(
        children: <Widget>[
          productTabButton('notreceived', 'สินค้าที่ไม่ได้รับ'),
          SizedBox(width: 10.0),
          productTabButton('all', 'ทั้งหมด'),
        ],
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.green.shade300),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
  }

  Widget showImage(OrnProductModel item) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: 80,
      height: 80,
      decoration: (item.photo != null && item.photo != '')
          ? BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                alignment: FractionalOffset.topCenter,
                image: NetworkImage(item.photo!),
              ),
            )
          : null,
      child: (item.photo == null || item.photo == '')
          ? Icon(Icons.medication_outlined,
              color: Colors.grey.shade400, size: 40.0)
          : null,
    );
  }

  Widget showText(OrnProductModel item) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 5.0, right: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(item.title ?? '', style: MyStyle().h3Style),
            Text(
              'สั่ง: ${item.qty ?? ''} ${item.unit ?? ''}   รับแล้ว: ${item.receive ?? ''} ${item.unit ?? ''}',
              style: MyStyle().h4StyleGray,
            ),
            (item.warehouse != null && item.warehouse != '')
                ? Text('คลัง: ${item.warehouse}', style: MyStyle().h4StyleGray)
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget productItem(OrnProductModel item) {
    return Card(
      child: Container(
        decoration: myBoxDecoration(),
        padding: EdgeInsets.only(top: 0.5),
        child: Row(
          children: <Widget>[
            showImage(item),
            showText(item),
          ],
        ),
      ),
    );
  }

  Widget myCircularProgress() {
    return Visibility(
      maintainSize: false,
      maintainAnimation: false,
      maintainState: false,
      visible: visible,
      child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.green,
        size: 20,
      )),
    );
  }

  Widget showProductItem() {
    int perpage = 15;
    bool loadingIcon = false;

    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: filterOrnProductModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          if ((index + 1) % perpage == 0) {
            loadingIcon = true;
          } else {
            loadingIcon = false;
          }

          if (loadingIcon == true) {
            return Column(
              children: [
                productItem(filterOrnProductModels[index]),
                myCircularProgress(),
              ],
            );
          }

          return productItem(filterOrnProductModels[index]);
        },
      ),
    );
  }

  Widget showProgressIndicate() {
    return Expanded(
      child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.green,
        size: 30,
      )),
    );
  }

  Widget showContent() {
    if (visible && ornProductModels.isEmpty) {
      return showProgressIndicate();
    }

    if (totalRecords <= 0) {
      return Expanded(
        child: Center(child: Text('ไม่พบรายการสินค้า')),
      );
    }

    if (filterOrnProductModels.isEmpty) {
      return Expanded(
        child: Center(child: Text('ไม่พบรายการสินค้า')),
      );
    }

    return showProductItem();
  }

  Future<void> readQRcodeORNPreview() async {
    try {
      // final qrScanString = await Navigator.push(this.context,
      //     MaterialPageRoute(builder: (context) => ScanPreviewPage()));
      var qrScanString;
      qrString = '';
      print('Before scan');
      qrScanString = await BarcodeScanner.scan();
      print('After scan');
      // print('scan result: $qrScanString');
      qrString = qrScanString!.rawContent;
      print('scan result: $qrString');

      if (qrString != null) {
        decodeQRcodeORN(qrString!);
      }
      // setState(() => scanResult = qrScanString);
    } on PlatformException catch (e) {
      print('e = $e');
    }
  }

  Future<void> decodeQRcodeORN(var code) async {
    // normalDialog(context,'xxxx','code -> $code');
    try {
      if (code != '' && code != null) {
        String? memberId = myUserModel!.id.toString();
        // id = currentOrnAllModel!.id.toString();
        String? url =
            '${MyStyle().serverName}/apishop/json_ornlist.php?memberId=$memberId&code=$code'; // &code=$code
        print("URL = $url");
        http.Response response = await http.get(Uri.parse(url));
        var result = json.decode(response.body);

        print('result (decodeQRcode) ===>>>> $result');

        int? status = result!['status'];
        String? title = 'ข้อมูลไม่ถูกต้อง';
        String? message = result!['message'];
        OrnModel? ornScanAllModel;
        print('status ===>>> $status');
        if (status == 0) {
          // normalDialog(context, 'Not found', 'ไม่พบ code :: $code ในระบบ');
          AwesomeDialog(
            context: context,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            autoHide: const Duration(seconds: 4),
            title: title,
            desc: message,
            btnOkColor: Colors.red,
            btnOkOnPress: () {},
            btnOkIcon: Icons.check_circle,
          ).show();
        } else {
          var mapItemScanOrn = result!['itemsData'];
          for (var map in mapItemScanOrn) {
            ornScanAllModel = OrnModel.fromJson(map);
          }
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return MenuOrn(
              ornID: ornScanAllModel!.id.toString(),
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        }
      }
    } catch (e) {}
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
          icon: const Icon(Icons.fact_check_rounded),
          title: const Text('ORN'),
          backgroundColor: Colors.red,
        ),
        BottomBarItem(
          icon: const Icon(Icons.qr_code_scanner),
          title: const Text('Scan'),
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
              builder: (value) => MyService(
                userModel: myUserModel,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            // routeToListProduct(0);
          } else if (index == 2) {
            MaterialPageRoute materialPageRoute =
                MaterialPageRoute(builder: (BuildContext buildContext) {
              return OrnList(
                userModel: myUserModel!,
              );
            });
            Navigator.of(context).push(materialPageRoute);
          } else if (index == 3) {
              readQRcodeORNPreview();
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
        title: Text(
          (ornNo != null && ornNo != '') ? 'รายการสินค้า $ornNo' : 'รายการสินค้า',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          productTabBar(),
          showContent(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(),
    );
  }
}
