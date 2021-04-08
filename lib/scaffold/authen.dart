import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/scaffold/my_service.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/scaffold/detail_popup.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Authen extends StatefulWidget {
  @override
  _AuthenState createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  // Explicit
  String user, password; // default value is null
  final formKey = GlobalKey<FormState>();
  UserModel userModel;
  bool remember = false; // false => unCheck      true = Check
  bool status = true;

  PopupModel popupModel;
  String subjectPopup = '';
  String imagePopup = '';
  String statusPopup = '';

  // Method
  @override
  void initState() {
    super.initState();
    // setState(() {
    //   readPopup();
    // });
    checkLogin();
  }

  // Future<void> readPopup() async {
  //   String url = 'http://ptnpharma.com/apishop/json_popup.php';
  //   http.Response response = await http.get(url);
  //   var result = json.decode(response.body);
  //   var mapItemPopup =
  //       result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
  //   for (var map in mapItemPopup) {
  //     // PromoteModel promoteModel = PromoteModel.fromJson(map);
  //     PopupModel popupModel = PopupModel.fromJson(map);
  //     String urlImage = popupModel.photo;
  //     String subject = popupModel.subject;
  //     String popstatus = popupModel.popstatus;
  //     setState(() {
  //       //promoteModels.add(promoteModel); // push ค่าลง arra
  //       subjectPopup = subject;
  //       statusPopup = popstatus;
  //       imagePopup = urlImage;
  //     });
  //   }
  // }

  Future<void> checkLogin() async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      user = sharedPreferences.getString('User');
      password = sharedPreferences.getString('Password');

      if (user != null) {
        checkAuthen();
      } else {
        setState(() {
          status = false;
        });
      }
    } catch (e) {}
  }

  Widget rememberCheckbox() {
    return Container(
      width: 250.0,
      child: Theme(
        data: Theme.of(context)
            .copyWith(unselectedWidgetColor: MyStyle().textColor),
        child: CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Remember me',
            style: TextStyle(color: MyStyle().textColor),
          ),
          value: remember,
          onChanged: (bool value) {
            setState(() {
              remember = value;
            });
          },
        ),
      ),
    );
  }

  // Method
  Widget loginButton() {
    return Container(
      width: 250.0,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: MyStyle().textColor,
        child: Text('Login',
            style: TextStyle(
              color: Colors.white,
            )),
        onPressed: () {
          formKey.currentState.save();
          print(
            'user = $user,password = $password',
          );
          checkAuthen();
        },
      ),
    );
  }

  Future<void> logOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    // exit(0);
  }

  Widget okButtonLogin(BuildContext buildContext) {
    return FlatButton(
      child: Text('OK'),
      onPressed: () {
        // Navigator.of(buildContext).pop();  // pop คือการทำให้มันหายไป
        logOut();
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return Authen();
        });
        Navigator.of(context).push(materialPageRoute);
      },
    );
  }

  Future<void> normalDialogLogin(
    BuildContext buildContext,
    String title,
    String message,
  ) async {
    showDialog(
      context: buildContext,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: showTitle(title),
          content: Text(message),
          actions: <Widget>[okButtonLogin(buildContext)],
        );
      },
    );
  }

  Future<void> checkAuthen() async {
    if (user.isEmpty || password.isEmpty) {
      // Have space
      normalDialog(context, 'ข้อมูลไม่ครบ', 'กรุณากรอกข้อมูลให้ครบ');
    } else {
      String urlPop = 'http://ptnpharma.com/apishop/json_popup.php';
      http.Response responsePop = await http.get(urlPop);
      var resultPop = json.decode(responsePop.body);
      var mapItemPopup = resultPop[
          'itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
      for (var map in mapItemPopup) {
        // PromoteModel promoteModel = PromoteModel.fromJson(map);
        PopupModel popupModel = PopupModel.fromJson(map);
        String urlImage = popupModel.photo;
        String subject = popupModel.subject;
        String popstatus = popupModel.popstatus;
        setState(() {
          //promoteModels.add(promoteModel); // push ค่าลง arra
          subjectPopup = subject;
          statusPopup = popstatus;
          imagePopup = urlImage;
        });
      }

      // No space
      String url =
          '${MyStyle().getUserWhereUserAndPass}?username=$user&password=$password';
      print('url = $url');
      http.Response response = await http
          .get(url); // await จะต้องทำงานใน await จะเสร็จจึงจะไปทำ process ต่อไป
      var result = json.decode(response.body);
      int statusInt = result['status'];

      print('statusPopup CA >>> $statusPopup');

      if (statusInt == 0) {
        String message = result['message'];
        normalDialogLogin(context, 'ข้อมูลไม่ถูกต้อง', message);
      } else if (statusInt == 1) {
        Map<String, dynamic> map = result['data'];
        print('map = $map');
        userModel = UserModel.fromJson(map);

        if (remember) {
          saveSharePreference();
        } else {
          routeToMyService(statusPopup);
        }
      }
      if (statusInt == 2) {
        String message = 'กรุณาติดต่อทางร้าน';
        normalDialog(context, 'ข้อมูลไม่ถูกต้อง !!!', message);
      }
    }
  }

  Future<void> saveSharePreference() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('User', user);
    sharedPreferences.setString('Password', password);

    routeToMyService(statusPopup);
  }

  void gotoService() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return MyService(
        userModel: userModel,
      );
    });

    Navigator.of(context).pushAndRemoveUntil(
        materialPageRoute, // pushAndRemoveUntil  clear หน้าก่อนหน้า route with out airrow back
        (Route<dynamic> route) {
      return false;
    });
  }

  void gotoPopupdetail() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailPopup(
        // index: index,
        userModel: userModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void _onBasicAlertPressed(context) {
    var alertStyle = AlertStyle(
      isCloseButton: false,
      isOverlayTapDismiss: false,
      titleStyle: TextStyle(
        color: Colors.red,
      ),
    );

    Alert(
      context: context,
      style: alertStyle,
      title: "ประกาศ !!!",
      desc: subjectPopup,
      buttons: [
        DialogButton(
          child: Text(
            "Close",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => gotoService(),
          color: Color.fromRGBO(255, 77, 77, 1.0),
        ),
        DialogButton(
          child: Text(
            "Detail",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => gotoPopupdetail(),
          color: Color.fromRGBO(51, 153, 255, 1.0),
        ),
      ],
    ).show();
  }

  void routeToMyService(statusPopup) async {
    // print('statusPopup >> $statusPopup');
    if (statusPopup == '1') {
      // when turn on popup alert
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _onBasicAlertPressed(context));
    } else {
      gotoService();
    }
  }

  Widget userForm() {
    return Container(
      decoration: MyStyle().boxLightGreen,
      height: 35.0,
      width: 250.0,
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        //  initialValue: 'nott', // set default value
        onSaved: (String string) {
          user = string.trim();
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            top: 6.0,
          ),
          prefixIcon: Icon(Icons.account_box, color: Colors.grey),
          border: InputBorder.none,
          hintText: 'User :',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget mySizeBox() {
    return SizedBox(
      height: 10.0,
    );
  }

  Widget passwordForm() {
    return Container(
      decoration: MyStyle().boxLightGreen,
      height: 35.0,
      width: 250.0,
      child: TextFormField(
        style: TextStyle(color: Colors.grey),
        //  initialValue: '123456789', // set default value
        onSaved: (String string) {
          password = string.trim();
        },
        obscureText: true, // hide text key replace with
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            top: 6.0,
          ),
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.grey,
          ),
          border: InputBorder.none,
          hintText: 'Pass :',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget showLogo() {
    return Container(
      width: 150.0,
      height: 150.0,
      child: Image.asset('images/logo_master.png'),
    );
  }

  Widget showAppName() {
    return Text(
      'PTN CENTER',
      style: TextStyle(
        fontSize: MyStyle().h1,
        color: MyStyle().mainColor,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
        fontFamily: MyStyle().fontName,
      ),
    );
  }

  Widget showProcess() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: status ? showProcess() : mainContent(),
      ),
    );
  }

  Container mainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.white, MyStyle().bgColor],
          // colors: [Colors.white, MyStyle().bgColor],
          radius: 1.5,
        ),
      ),
      child: Center(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, //
              children: <Widget>[
                showLogo(),
                mySizeBox(),
                showAppName(),
                mySizeBox(),
                userForm(),
                mySizeBox(),
                passwordForm(),
                mySizeBox(),
                rememberCheckbox(),
                mySizeBox(),
                loginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
