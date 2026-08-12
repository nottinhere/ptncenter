import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/orn_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/orn_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'detail.dart';
import 'detail_cart.dart';
import 'package:ptncenter/widget/home.dart';
import 'package:ptncenter/scaffold/orn_menu.dart';
import 'package:ptncenter/scaffold/detail_orn.dart';

import 'my_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:intl/intl.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class OrnList extends StatefulWidget {
  final int? index;
  final UserModel? userModel;
  String? _result = '';

  OrnList({Key? key, this.index, this.userModel}) : super(key: key);

  @override
  _OrnListState createState() => _OrnListState();
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

class _OrnListState extends State<OrnList> {
  // Explicit
  int? myIndex;
  OrnModel? ornAllModel;
  List<OrnModel>? ornAllModels = []; // []; // set array
  List<OrnModel>? filterOrnAllModels = []; // []; //

  int? amontCart = 0;
  UserModel? myUserModel;
  String? searchString = '';
  String? lastItemName = '';

  int? amountListView = 6;
  int? page = 1;

  String? qrString;
  int? myCate = 0;
  String? myCateName = '';
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 300); // ตั้งค่า เวลาที่จะ delay
  bool? statusStart = true;

  int? currentIndex;
  int? selectIndex = 2;
  String? deliverName;
  int? shippingStatus;

  // List<OrnModel> productAllModels_buffer = []; // []; //

  var _controller = TextEditingController();

  int? substart = 0;
  bool? visible = true;
  // String? ornGID,ornRGID;

  // Method
  @override
  void initState() {
    print('auto load');

    // auto load
    super.initState();

    if (myIndex == 0) {
      currentIndex = 1;
    } else if (myIndex == 1) {
      currentIndex = 4;
    } else if (myIndex == 2) {
      currentIndex = 2;
    } else if (myIndex == 3) {
      currentIndex = 3;
    } else if (myIndex == 4) {
      currentIndex = 1;
    } else if (myIndex == 5) {
      currentIndex = 1;
    }

    createController(); // เมื่อ scroll to bottom

    setState(() {
      myIndex = widget.index;
      myUserModel = widget.userModel;
      readData(); // read  ข้อมูลมาแสดง
      // readShipping();
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

  String? ornGID;
  String? ornRGID;

  int totalRecords = 0;
  Future<void> readData() async {
    setState(() {
      visible = true;
    });

    String? memberId = myUserModel!.id.toString();


    String? url =
        '${MyStyle().serverName}/apishop/json_ornlist.php?memberId=$memberId&page=$page&searchKey=$searchString';
    print("URL (orn list)= $url");
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemData = result['itemsData'];
    totalRecords = result['totalRecords'];
    print("totalRecords = $totalRecords");

    for (var map in itemData) {
      OrnModel ornAllModel = OrnModel.fromJson(map);
      ornAllModels!.add(ornAllModel);
    }
    setState(() {
      visible = false;
      filterOrnAllModels = ornAllModels;
    });
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

  Widget showDeliveryStatus(int index) {
    String? deliveryDate = filterOrnAllModels![index].deliveryDate;
    String? shippingOrndate = filterOrnAllModels![index].shippingOrndate;

    bool delivered =
        deliveryDate != null && deliveryDate != '-' && deliveryDate != '';
    bool shipping = shippingOrndate != null &&
        shippingOrndate != '-' &&
        shippingOrndate != '';

    String text;
    Color color;
    if (delivered) {
      text = 'นำส่งสำเร็จ';
      color = Colors.green;
    } else if (shipping) {
      text = 'อยู่ระหว่างจัดส่ง';
      color =  Colors.orange;
    } else {
      text = 'รอจัดส่ง';
      color = Colors.grey;
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget showORN(int index) {
    return Row(
      children: <Widget>[
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.45,
              child: Row(
                children: [
                  Text(
                    filterOrnAllModels![index!].ornNo!,
                    style: MyStyle().h3bStyle,
                  ),
                  (filterOrnAllModels![index!].billingStatus! == '1' ||
                          filterOrnAllModels![index!].billingStatus! == '2')
                      ? Text(
                          ' (เก็บบิล)',
                          style: MyStyle().h3StyleRed,
                        )
                      : Text(''),
                  (filterOrnAllModels![index!].ornNo!.substring(0, 3) == 'ORC')
                      ? Text(
                          ' (สั่งงาน)',
                          style: MyStyle().h3StyleRed,
                        )
                      : Text(''),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // showOrnStatus(index!),
                  showDeliveryStatus(index!),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget showPackbox(int index) {

    
DateTime parseDate =
    new DateFormat("yyyy-MM-dd HH:mm:ss").parse(filterOrnAllModels![index].datepost!);
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat('dd/MM/yyyy HH:mm');
    var outputDate = outputFormat.format(inputDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
        width: MediaQuery.of(context).size.width * 0.45,
        child: Text(outputDate)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.15,
              child: Text(
                'จำนวน ',
                style: MyStyle().h3StyleGray,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Text(
                ' ${filterOrnAllModels![index].box}  กล่อง',
                style: MyStyle().h3StyleGray,
              ),
            ),
          ],
        ),
      ],
    );
    // return Text('na');
  }

  Widget showText(int index) {
    return Container(
      padding: EdgeInsets.only(top: 5.0,bottom: 5.0,  left: 5.0, right: 0.0),
      // width: MediaQuery.of(context).size.width * 0.98,
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
        Radius.circular(5.0), //                 <--- border radius here
      ),
    );
  }

  

  Widget myCircularProgress() {
    return Visibility(
      maintainSize: false,
      maintainAnimation: false,
      maintainState: false,
      visible: visible!,
      // child: Center(child: CupertinoActivityIndicator()),
      child: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.green,
        size: 20,
      )),
    );
  }

  Widget showProductItem() {
    int? perpage = 15;
    bool? loadingIcon = false;

    //int?  i = 0;
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: ornAllModels!.length,
        itemBuilder: (BuildContext buildContext, int? index) {

          if ((index! + 1) % perpage == 0) {
            loadingIcon = true;
          } else {
            loadingIcon = false;
          }

          if (loadingIcon == true) {
            // return CupertinoActivityIndicator();
                        print('with loading');

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
                            showText(index!),
                            // showShipBox(index!),
                          ],
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    // print('index select item => ${ornAllModels![index!]}');
                    // print('index select BTN => $index');
                    MaterialPageRoute materialPageRoute =
                        MaterialPageRoute(builder: (BuildContext buildContext) {
                      return MenuOrn(
                        ornID: filterOrnAllModels![index!].id.toString(),
                        userModel: myUserModel,
                      );
                    });
                    Navigator.of(context).push(materialPageRoute);
                    // Navigator.of(context)
                    //     .push(materialPageRoute)
                    //     .then((value) => setState(() {
                    //           ornAllModels!.clear();
                    //           readData();
                    //           updateDatalist(index);
                    //         }));
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
                      showText(index!),
                      // showShipBox(index!),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              // print('index select item => ${ornAllModels![index!]}');
              // print('index select BTN => $index');
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return MenuOrn(
                  ornID: filterOrnAllModels![index!].id.toString(),
                  userModel: myUserModel,
                );
              });
              Navigator.of(context).push(materialPageRoute);
              // Navigator.of(context)
              //     .push(materialPageRoute)
              //     .then((value) => setState(() {
              //           ornAllModels!.clear();
              //           readData();
              //           updateDatalist(index);
              //         }));
            },
          );
        },
      ),
    );
  }

  Future<void> updateDatalist(index) async {
    setState(() {
      filterOrnAllModels![index].shippingBox =
          filterOrnAllModels![index].shippingBox;
    });
  }

  Widget showContent() {
    print(filterOrnAllModels!.length);
    bool? searchKey;
    if (searchString != '') {
      searchKey = true;
    }

    if (filterOrnAllModels!.length == 0) {
      return Center(child: Text(''));
    } else {
      return showProductItem();
    }
  }

  Widget showProgressIndicate(searchKey) {
    // print('searchKey >> $searchKey');

    if (searchKey == true) {
      if (filterOrnAllModels!.length == 0) {
        return Center(child: Text('')); // Search not found
      } else {
        return Center(child: Text(''));
      }
    } else {
      return Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.green,
        size: 30,
      ));
    }
    
  }

  Widget totalOrn() {
    print('totalRecords >> $totalRecords');
    late MaterialColor colorTotalBTN;
    colorTotalBTN = Colors.grey;
    String txttotalRecords = totalRecords.toString();

    String? memberId = myUserModel!.id.toString();

    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        padding: EdgeInsets.all(3.0),
        alignment: AlignmentDirectional(0.0, 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'พบ $txttotalRecords รายการ   ',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
      onTap: () {
        // print('You click product');
      },
    );
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

  Widget searchForm() {
    print('searchString >> $searchString');


    return Container(
      // decoration: MyStyle().boxLightGrey,
      // color: Colors.grey,
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
            print('onSubmitted');
            setState(() {
              page = 1;
              myIndex = 0;
              ornAllModels!.clear();
              readData();
            });
          },
        ),
      ),
    );
  }

  void routeToOrnList(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return OrnList(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget stylishBottomBar() {
    int? unread =
        myUserModel!.lastNewsId!.toInt() - myUserModel!.lastNewsOpen!.toInt();
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
          // selectedIcon: const Icon(Icons.home),
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
      // fabLocation: StylishBarFabLocation.end,
      hasNotch: true,
      currentIndex: selectIndex!,
      onTap: (index) {
        setState(() {
          selectIndex = index;
          // controller.jumpToPage(index);
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
        backgroundColor: MyStyle().bgColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('ใบส่งของ', style: TextStyle(color: Colors.white)),
        // actions: <Widget>[
        //   showCart(),
        // ],
      ),

      body: Column(
        children: <Widget>[
          searchForm(),
          totalOrn(),
          showContent(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }
}
