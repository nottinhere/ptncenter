import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/orn_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:ptncenter/scaffold/orn_list.dart';
import 'package:ptncenter/scaffold/payment_orn.dart';

import 'my_service.dart';
import 'package:flutter/services.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class PaymentOrnList extends StatefulWidget {
  final int? index;
  final UserModel? userModel;

  PaymentOrnList({Key? key, this.index, this.userModel}) : super(key: key);

  @override
  _PaymentOrnListState createState() => _PaymentOrnListState();
}

//class
class Debouncer {
  // delay เวลาให้มีการหน่วง เมื่อ key searchview

  //Explicit
  final int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  //constructor
  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(Duration(microseconds: milliseconds!), action);
  }
}

class _PaymentOrnListState extends State<PaymentOrnList> {
  // Explicit
  int? myIndex;
  List<OrnModel>? ornAllModels = []; // []; // set array
  List<OrnModel>? filterOrnAllModels = []; // []; //

  UserModel? myUserModel;
  String? searchString = '';

  int? page = 1;

  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 300); // ตั้งค่า เวลาที่จะ delay

  int? selectIndex = 2;

  var _controller = TextEditingController();

  bool? visible = true;

  String ornTab = 'unpaid'; // 'unpaid' or 'all'

  // Method
  @override
  void initState() {
    super.initState();

    myIndex = widget.index;
    myUserModel = widget.userModel;

    createController(); // เมื่อ scroll to bottom

    setState(() {
      readData(); // read  ข้อมูลมาแสดง
    });
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          page = page! + 1;
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

  int totalRecords = 0;
  Future<void> readData() async {
    setState(() {
      visible = true;
    });

    String? memberId = myUserModel!.id.toString();

    String? url =
        '${MyStyle().serverName}/apishop/json_ornlist.php?memberId=$memberId&page=$page&searchKey=$searchString';
    if (ornTab == 'unpaid') {
      url = '$url&status=3';
    }
    print("URL (payment orn list)= $url");
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemData = result['itemsData'];
    totalRecords = result['totalRecords'];

    for (var map in itemData) {
      OrnModel ornAllModel = OrnModel.fromJson(map);
      ornAllModels!.add(ornAllModel);
    }
    setState(() {
      visible = false;
    });
    applyOrnTab();
  }

  // แถวของ BI เอง orn_no จะเท่ากับ bill_no; ORN ที่ถูกผูกไปรวมกับ BI อื่น bill_no จะไม่ตรงกับ orn_no ของตัวเอง
  bool isMergedIntoBill(OrnModel o) {
    return o.billNo != null &&
        o.billNo != '' &&
        o.billNo != '-' &&
        o.billNo != o.ornNo;
  }

  void applyOrnTab() {
    // server กรองตาม status ให้แล้วผ่าน &status=3 ใน readData()
    // แท็บรอชำระเงิน: แสดง BI ที่ยังไม่ชำระ และ ORN ที่ยังไม่ชำระ+ไม่ได้ผูก BI
    // (ORN ที่ถูกผูกไปรวมกับ BI อื่นแล้ว ไม่ต้องแสดงซ้ำ เพราะแสดงผ่าน BI แทน)
    setState(() {
      if (ornTab == 'unpaid') {
        filterOrnAllModels =
            ornAllModels!.where((o) => !isMergedIntoBill(o)).toList();
      } else {
        filterOrnAllModels = ornAllModels;
      }
    });
  }

  Widget ornTabButton(String value, String label) {
    bool selected = ornTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ornTab = value;
          setState(() {
            page = 1;
            ornAllModels!.clear();
            readData();
          });
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

  Widget ornTabBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Row(
        children: <Widget>[
          ornTabButton('unpaid', 'รอชำระเงิน'),
          SizedBox(width: 10.0),
          ornTabButton('all', 'ทั้งหมด'),
        ],
      ),
    );
  }

  static const Map<String, Map<String, dynamic>> ornStatusMap = {
    '0': {'text': '', 'color': Colors.red},
    '1': {'text': 'รอเพิ่มยา', 'color': Color(0xFF008285)},
    '2': {'text': 'รอเพิ่มค่าขนส่ง', 'color': Colors.orange},
    '6': {'text': 'รอหัก cn / รวมบิล', 'color': Colors.red},
    '3': {'text': 'รอชำระเงิน', 'color': Colors.red},
    '4': {'text': 'รอตรวจสอบ', 'color': Color(0xFFD69E02)},
    '5': {'text': 'ชำระแล้ว', 'color': Colors.green},
    '7': {'text': 'ยกเลิกโดยผู้ดูแล', 'color': Color(0xFFD17F79)},
    '8': {'text': 'ระหว่างจัดส่ง', 'color': Colors.green},
    '9': {'text': 'จัดส่งแล้ว', 'color': Colors.green},
  };

  Widget showOrnStatus(int index) {
    Map<String, dynamic> statusInfo =
        ornStatusMap[filterOrnAllModels![index].status] ??
            {'text': '', 'color': Colors.grey};
    return Text(
      statusInfo['text'],
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: statusInfo['color'],
      ),
    );
  }

  Widget showORN(int index) {
    return Row(
      children: <Widget>[
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.55,
              child: Row(
                children: [
                  Text(
                    filterOrnAllModels![index].ornNo!,
                    style: MyStyle().h3bStyle,
                  ),
                  (filterOrnAllModels![index].billingStatus! == '1' ||
                          filterOrnAllModels![index].billingStatus! == '2')
                      ? Text(
                          ' (เก็บบิล)',
                          style: MyStyle().h3StyleRed,
                        )
                      : Text(''),
                  (filterOrnAllModels![index].ornNo!.substring(0, 3) == 'ORC')
                      ? Text(
                          ' (สั่งงาน)',
                          style: MyStyle().h3StyleRed,
                        )
                      : Text(''),
                  isMergedIntoBill(filterOrnAllModels![index])
                      ? Text(
                          '      (${filterOrnAllModels![index].billNo})',
                          style: MyStyle().h4StyleRed,
                        )
                      : Text(''),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.40,
              child: showOrnStatus(index),
            ),
          ],
        ),
      ],
    );
  }

  Widget showPackbox(int index) {
    DateTime parseDate = new DateFormat("yyyy-MM-dd HH:mm:ss")
        .parse(filterOrnAllModels![index].datepost!);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('MM/dd/yyyy HH:mm');
    var outputDate = outputFormat.format(inputDate);

    var customFormat = NumberFormat.decimalPattern()
        .format(double.parse(filterOrnAllModels![index].total!));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
            width: MediaQuery.of(context).size.width * 0.52,
            child: Text(outputDate)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.16,
              child: Text(
                'ยอดชำระ ',
                style: MyStyle().h3StyleGray,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Text(
                ' $customFormat  บ.',
                style: (filterOrnAllModels![index].total.toString() != '0')
                    ? MyStyle().h3StyleGray
                    : MyStyle().h4StyleRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget showText(int index) {
    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 0.0),
      child: Container(
        padding: EdgeInsets.only(bottom: 5.0, top: 5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            showORN(index),
            showPackbox(index),
          ],
        ),
      ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.green.shade300),
      borderRadius: BorderRadius.all(
        Radius.circular(5.0),
      ),
    );
  }

  Widget myCircularProgress() {
    return Visibility(
      maintainSize: false,
      maintainAnimation: false,
      maintainState: false,
      visible: visible!,
      child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.green,
        size: 20,
      )),
    );
  }

  void routeToPaymentOrn(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return PaymentOrn(
        ornId: filterOrnAllModels![index].id.toString(),
        userModel: myUserModel,
      );
    });
    // Navigator.of(context)
    //     .push(materialPageRoute)
    //     .then((value) => setState(() {
    //           page = 1;
    //           ornAllModels!.clear();
    //           readData();
    //         }));
        Navigator.of(context).push(materialPageRoute);

  }

  Widget showProductItem() {
    int? perpage = 15;
    bool? loadingIcon = false;

    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: filterOrnAllModels!.length,
        itemBuilder: (BuildContext buildContext, int? index) {
          if ((index! + 1) % perpage == 0) {
            loadingIcon = true;
          } else {
            loadingIcon = false;
          }

          if (loadingIcon == true) {
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
                            showText(index),
                          ],
                        ),
                      ),
                    ),
                  ),
                  onTap: () => routeToPaymentOrn(index),
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
                      showText(index),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () => routeToPaymentOrn(index),
          );
        },
      ),
    );
  }

  Widget showContent() {
    if (filterOrnAllModels!.length == 0) {
      return Center(child: Text(''));
    } else {
      return showProductItem();
    }
  }

  Widget totalOrn() {
    // แท็บรอชำระเงิน กรอง ORN ที่ผูก BI แล้วออกฝั่ง client (server ไม่รองรับ filter นี้)
    // จึงนับจากรายการที่กรองแล้วแทน totalRecords ของ server เพื่อไม่ให้ตัวเลขเกินกว่าที่แสดงจริง
    String txttotalRecords = ornTab == 'unpaid'
        ? filterOrnAllModels!.length.toString()
        : totalRecords.toString();

    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: EdgeInsets.all(3.0),
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            'พบ $txttotalRecords รายการ   ',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  String? qrString;
  Future<void> readQRcodeORNPreview() async {
    try {
      var qrScanString;
      qrString = '';
      qrScanString = await BarcodeScanner.scan();
      qrString = qrScanString!.rawContent;

      if (qrString != null) {
        decodeQRcodeORN(qrString!);
      }
    } on PlatformException catch (e) {
      print('e = $e');
    }
  }

  Future<void> decodeQRcodeORN(var code) async {
    try {
      if (code != '' && code != null) {
        String? memberId = myUserModel!.id.toString();
        String? url =
            '${MyStyle().serverName}/apishop/json_ornlist.php?memberId=$memberId&code=$code';
        http.Response response = await http.get(Uri.parse(url));
        var result = json.decode(response.body);

        int? status = result!['status'];
        String? title = 'ข้อมูลไม่ถูกต้อง';
        String? message = result!['message'];
        OrnModel? ornScanAllModel;
        if (status == 0) {
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
            return PaymentOrn(
              ornId: ornScanAllModel!.id.toString(),
              userModel: myUserModel,
            );
          });
          Navigator.of(context)
              .push(materialPageRoute)
              .then((value) => setState(() {
                    page = 1;
                    ornAllModels!.clear();
                    readData();
                  }));
        }
      }
    } catch (e) {}
  }

  Widget searchForm() {
    return Container(
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
      child: ListTile(
        trailing: Container(
          width: 45.0,
          child: Image.asset('images/qr_code.png'),
        ),
        onTap: () {
          readQRcodeORNPreview();
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
            hintText: 'ค้นหา ORN',
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _controller.clear();
                  searchString = '';
                  ornAllModels!.clear();
                  readData();
                });
              },
              icon: Icon(Icons.clear),
            ),
          ),
          onChanged: (String? string) {
            setState(() {
              searchString = string!.trim();
            });
          },
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            setState(() {
              page = 1;
              ornAllModels!.clear();
              readData();
            });
          },
        ),
      ),
    );
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
          icon: const Icon(Icons.payments_rounded),
          title: const Text('Payment'),
          backgroundColor: Colors.orange,
        ),
        BottomBarItem(
          icon: const Icon(Icons.qr_code_scanner),
          title: const Text('Scan'),
          backgroundColor: Colors.brown,
        ),
      ],
      hasNotch: true,
      currentIndex: selectIndex!,
      onTap: (index) {
        setState(() {
          selectIndex = index;
          if (index == 0) {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => MyService(userModel: myUserModel),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            // routeToListProduct(0);
          } else if (index == 2) {
            MaterialPageRoute materialPageRoute =
                MaterialPageRoute(builder: (BuildContext buildContext) {
              return PaymentOrnList(userModel: myUserModel!);
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
        backgroundColor: MyStyle().bgColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('การชำระเงิน', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          searchForm(),
          ornTabBar(),
          totalOrn(),
          showContent(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(),
    );
  }
}
