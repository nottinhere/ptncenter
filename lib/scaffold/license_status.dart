import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';

import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'my_service.dart';

import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class License extends StatefulWidget {
  final UserModel? userModel;

  License({Key? key, this.userModel}) : super(key: key);

  @override
  _LicenseState createState() => _LicenseState();
}

class _LicenseState extends State<License> {
  // Explicit

  UserModel? myUserModel;
  int selectIndex = 3;
  File? _selectimage1;

  String showDetailBox = 'T';

  // Method
  @override
  void initState() {
    super.initState();
    setState(() {
    myUserModel = widget.userModel;
    print(myUserModel!.name);
    });
    updateUserProfile();
    readLicenseAlert();
  }

int?    userlicenseyear ;
String? userlicensestatus ;

UserModel? updateuserModel;
Future<void> updateUserProfile() async {
    String? memberId = myUserModel!.id.toString();
    String? url =
        '${MyStyle().serverName}/json_customer_profile.php?memberId=$memberId';

    print("URL update item = $url");
    http.Response response = await http.get(Uri.parse(url));
    print(111);
     var result = json.decode(response.body);
    print("result updateuserModel = $result");
      Map<String, dynamic> map = result['data'];
      print('map = $map');
      setState(() {
        updateuserModel = UserModel.fromJson(map);
        userlicenseyear   = updateuserModel!.lastupdateLicenseYear;
        userlicensestatus = updateuserModel!.lastupdateLicenseStatus;
      });
  }


  String? licenseAlertStatus;
  String? licenseAlertYear;
  Future<void> readLicenseAlert() async {
      String urlPop = '${MyStyle().serverName}/json_license_alert.php';
      http.Response responsePop = await http.get(Uri.parse(urlPop));
      var resultPop = json.decode(responsePop.body);
      var mapItemPopup = resultPop[
          'itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
      for (var map in mapItemPopup) {
        // PromoteModel promoteModel = PromoteModel.fromJson(map);
        PopupModel popupModel = PopupModel.fromJson(map);
        String? subject = popupModel.subject;
        String? popstatus = popupModel.popstatus;
        setState(() {
          //promoteModels.add(promoteModel); // push ค่าลง arra
          licenseAlertYear = subject;
          licenseAlertStatus = popstatus;
        });
      }
  }


  Widget profileBox() {
    String? login = myUserModel!.name;
    String? address = myUserModel!.address;
    // int loginStatus = myUserModel.status;

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      // height: 80.0,
      child: GestureDetector(
        child: Card(
          color: Color.fromARGB(255, 255, 255, 255),
          child: Container(
            padding: EdgeInsets.all(7.0),
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Row(
              children: <Widget>[
                Container(
                    width: 45.0,
                    child: Image.asset('images/icon_user.png'),
                    padding: EdgeInsets.only(right: 8.0)),
                Column(
                  children: [
                    Text(
                      '$login', // 'ผู้แทน : $login',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      '$address', // 'ผู้แทน : $login',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          print('You click profile');
          // routeToListProduct(0);
        },
      ),
    );
  }

  Widget licenseBox() {
    if (licenseAlertStatus != '1') return SizedBox();

    int showlicenseAlertYear = int.parse(licenseAlertYear!) + 543;

    String txtTitle = '';
    Color colorAlertBox = MyStyle().alertColor;

    if (userlicensestatus == '0' ||
        userlicenseyear.toString() != licenseAlertYear) {
      txtTitle = 'กรุณาอัพโหลดใบอนุญาตขายยา ปี $showlicenseAlertYear';
      colorAlertBox = MyStyle().alertColor;
      showDetailBox = 'T';
    } else if (userlicensestatus == '1' &&
        userlicenseyear.toString() == licenseAlertYear) {
      txtTitle = 'อยู่ระหว่างตรวจสอบใบอนุญาตขายยา';
      colorAlertBox = MyStyle().warningColor;
      showDetailBox = 'F';
    } else if (userlicensestatus == '2' &&
        userlicenseyear.toString() == licenseAlertYear) {
      txtTitle = 'อัพเดทใบอนุญาตขายยาเรียบร้อย';
      colorAlertBox = MyStyle().mainColor;
      showDetailBox = 'F';
    } else if (userlicensestatus == '3' &&
        userlicenseyear.toString() == licenseAlertYear) {
      txtTitle = 'ใบอนุญาตขายยาของคุณไม่สมบูรณ์';
      colorAlertBox = MyStyle().alertColor;
      showDetailBox = 'T';
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: colorAlertBox.withOpacity(0.08),
          borderRadius: BorderRadius.circular(MyStyle().radiusS),
          border: Border(left: BorderSide(color: colorAlertBox, width: 4.0)),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.description_rounded, color: colorAlertBox),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'อัพเดทใบอนุญาต ปี $showlicenseAlertYear',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: colorAlertBox,
                    ),
                  ),
                  Text(txtTitle, style: MyStyle().captionStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailBox() {
    return Card(
      child: Container(
        // decoration: MyStyle().boxLightGreen,
        // height: 35.0,
        width: MediaQuery.of(context).size.width * 0.95,
        padding: EdgeInsets.only(left: 10.0, right: 20.0),
        child: Column(
          children: <Widget>[
            SizedBox(width: 10.0, height: 5.0),
            Text(
              'อัพเดทใบอนุญาต',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0, 0, 0),
              ),
            ),
            SizedBox(width: 10.0, height: 10.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size.fromWidth(110),
                  backgroundColor: const Color.fromARGB(209, 0, 167, 245), // Set the background color
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255), // Set the text color
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo_camera,size: 16.0),
                    Text(' ถ่ายรูป '),
                  ],
                ),
                onPressed: () {
                  // orderAllModels = [];
                  // print('transport = $transport, deliver = $deliver');
                  // readData(); //
                  getImage1();
                },
              ),
            Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

              children: [
                // const  SizedBox(height: 20.0,),
                _selectimage1 != null ? Container(width: 200.0,height: 200.0, child: Image.file(_selectimage1!)) : const Text('ยังไม่มีรูปใบอนุญาต'),
                // Container(width: 200.0,),
              ],
            ),
          ),

            submitButton(),

            // (textButton != '') ? showButton() : Container(),
          ],
        ),
      ),
    );
  }


  final picker = ImagePicker();

  // Capture image from camera
  Future getImage1() async {
     final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
        setState(() {
           _selectimage1 = File(pickedFile.path); 
        });
    }else{
      return;
    }
  }

  // Upload image to server
  Future uploadImage1() async {
    Dio dio = new Dio();
    dio.options.headers["Content-Type"] = "multipart/form-data";
    
    if (_selectimage1 == null) return;

    String? memId = myUserModel!.id;

    var uri = Uri.parse("https://ptnpharma.com/apishop/json_submit_license.php?memId=$memId");
    print("Upload uri > $uri");
    var request = http.MultipartRequest("POST", uri);
    // Attach file
    var multipartFile = await http.MultipartFile.fromPath('image1', _selectimage1!.path,
    contentType: MediaType('image', 'jpg'),);
    request.files.add(multipartFile);

    var response = await request.send();
    var statusCode = response.statusCode;
    print('upload statusCode = $statusCode');
    if (response.statusCode == 200) {
      print("Image Uploaded Successfully");
    } else {
      print("Upload Failed");
    }
  }


  bool _isLoading = false;
  void _handleSubmit() async {
    setState(() => _isLoading = true);

    // Simulate network request
    await Future.delayed(Duration(seconds: 5));
    setState(() => _isLoading = false);

     MaterialPageRoute materialPageRoute = MaterialPageRoute(
        builder: (BuildContext buildContext) {
          return MyService(userModel: myUserModel);
        },
      );

      Navigator.of(context).pushAndRemoveUntil(
        materialPageRoute, // pushAndRemoveUntil  clear หน้าก่อนหน้า route with out airrow back
        (Route<dynamic> route) {
          return false;
        },
      );
  }


  Widget submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80,
      child: Row(
         mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ElevatedButton(
          //   style: ElevatedButton.styleFrom(
          //     fixedSize: const Size.fromWidth(110),
          //     backgroundColor: const Color.fromARGB(255, 255, 72, 72), // Set the background color
          //     foregroundColor: Colors.white, // Set the text color
          //     shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(6)),
          //     textStyle: TextStyle(
          //           color: Colors.white,
          //           fontSize: 20),
          //   ),
          //   child: Text('ยกเลิก'),
          //   onPressed: () {
          //     Navigator.pop(context);            },
          // ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromWidth(120),
              backgroundColor: Colors.teal, // Set the background color
              foregroundColor: Colors.white, // Set the text color
              shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20),
            ),
            // child: Text('ยืนยัน'),
            onPressed: _isLoading ? null : (){
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  headerAnimationLoop: false,
                  animType: AnimType.bottomSlide,
                  title: 'ยืนยันข้อมูล',
                  desc: 'ท่านต้องการยืนยันการอัพเดทใบอนุญาต',
                  buttonsTextStyle: const TextStyle(color: Colors.white),
                  showCloseIcon: true,
                  btnCancelText: 'ยกเลิก',
                  btnCancelOnPress: () {},
                  btnOkText: 'ยืนยัน',
                  btnOkOnPress: () {
                    _handleSubmit();
                    uploadImage1();
                  },
                ).show();
            },
            child: _isLoading 
              ? SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return DetailCart(userModel: myUserModel);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  Widget stylishBottomBar() {
    return StylishBottomBar(
      option: AnimatedBarOptions(iconStyle: IconStyle.animated, opacity: 0.3),
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
      // fabLocation: StylishBarFabLocation.end,
      hasNotch: true,
      currentIndex: selectIndex,
      onTap: (index) {
        setState(() {
          selectIndex = index;
          // controller.jumpToPage(index);
          if (index == 0) {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => MyService(userModel: myUserModel),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            // routeToListProduct(0);
          } else if (index == 2) {
            // routeToListProductfav(0);
          } else if (index == 3) {
            routeToDetailCart();
          }
        });
      },
    );
  }

  Widget mySizebox() {
    return SizedBox(
      width: 10.0,
      height: 30.0,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          //showCart(),
        ],
        backgroundColor: MyStyle().barColor,
        title: Text('ต่ออายุใบอนุญาต', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            profileBox(),
            licenseBox(),
            mySizebox(),
            (showDetailBox == 'T') ? detailBox() : SizedBox(), //   detailBox(), //  
          ],
        ),
      ),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }

}

