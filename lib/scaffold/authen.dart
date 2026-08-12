import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/main.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/scaffold/my_service.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/scaffold/detail_popup.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class Authen extends StatefulWidget {
  @override
  _AuthenState createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  // Explicit
  String? user, password; // default value is null
  final formKey = GlobalKey<FormState>();
  UserModel? userModel;
  bool? remember = false; // false => unCheck      true = Check
  bool? status = true;

  List<PopupModel> popupModels = [];

  bool? firstLoadAds;

  // Method
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

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
          onChanged: (bool? value) {
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
      child: ElevatedButton(
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(12.0),
        // ),
        // color: MyStyle().textColor,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          textStyle: const TextStyle(
              color: Colors.white, fontSize: 16, fontStyle: FontStyle.normal),
        ),
        child: Text('Login',
            style: TextStyle(
              color: Colors.white,
            )),
        onPressed: () {
          formKey.currentState!.save();
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
    return ElevatedButton(
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
    AwesomeDialog(
      context: context,
      headerAnimationLoop: false,
      dialogType: DialogType.error,
      autoHide: const Duration(seconds: 4),
      title: title,
      desc: message,
      btnOkColor: Colors.red,
      btnOkOnPress: () {
        debugPrint('OnClcik');
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return MyApp();
        });
        Navigator.of(context).push(materialPageRoute);
      },
      btnOkIcon: Icons.check_circle,
    ).show();
    // showDialog(
    //   context: buildContext,
    //   builder: (BuildContext buildContext) {
    //     return AlertDialog(
    //       title: showTitle(title),
    //       content: Text(message),
    //       actions: <Widget>[okButtonLogin(buildContext)],
    //     );
    //   },
    // );
  }

  Future<void> checkAuthen() async {
    if (user!.isEmpty || password!.isEmpty) {
      // Have space
      // normalDialog(context, 'ข้อมูลไม่ครบ', 'กรุณากรอกข้อมูลให้ครบ');
      
     AwesomeDialog(
        context: context,
        headerAnimationLoop: false,
        dialogType: DialogType.warning,
        autoHide: const Duration(seconds: 5),
        title: 'ข้อมูลไม่ครบ',
        desc: 'กรุณากรอกข้อมูลให้ครบ ',
        // btnCancelOnPress: () {
        //   debugPrint('OnClcik');
        // },
        btnOkText: ('ok'),
        btnOkColor: const Color.fromARGB(255, 252, 183, 36),
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
      ).show();
      
    } else {
      // No space
      String url =
          '${MyStyle().getUserWhereUserAndPass}?username=$user&password=$password';
      print('url = $url');
      http.Response response = await http.get(Uri.parse(
          url)); // await จะต้องทำงานใน await จะเสร็จจึงจะไปทำ process ต่อไป
      var result = json.decode(response.body);
      int statusInt = result['status'];

      if (statusInt == 0) {
        String message = result['message'];
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.clear();
        await sharedPreferences.remove('user');
        await sharedPreferences.remove('password');

        normalDialogLogin(context, 'ข้อมูลไม่ถูกต้อง', message);
      } else if (statusInt == 1) {
        Map<String, dynamic> map = result['data'];
        print('map = $map');
        userModel = UserModel.fromJson(map);

        String urlPop =
            '${MyStyle().serverName}/apishop/json_mypopup.php?popup=1&memberId=${userModel!.id}';
            print('urlPop = $urlPop');
        http.Response responsePop = await http.get(Uri.parse(urlPop));
        var resultPop = json.decode(responsePop.body);
        var mapItemPopup = resultPop[
            'itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
        List<PopupModel> popups = [];
        if (mapItemPopup != null) {
          for (var map in mapItemPopup) {
            PopupModel popupModel = PopupModel.fromJson(map);
            if (popupModel.popstatus == '1') {
              popups.add(popupModel);
            }
          }
        }
        setState(() {
          popupModels = popups;
        });

        if (remember!) {
          saveSharePreference();
        } else {
          routeToMyService(popupModels);
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
    sharedPreferences.setString('User', user!);
    sharedPreferences.setString('Password', password!);

    routeToMyService(popupModels);
  }

  void gotoService() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return MyService(
        userModel: userModel!,
        firstLoadAds: true,
      );
    });

    Navigator.of(context).pushAndRemoveUntil(
        materialPageRoute, // pushAndRemoveUntil  clear หน้าก่อนหน้า route with out airrow back
        (Route<dynamic> route) {
      return false;
    });
  }

  void routeToMyService(List<PopupModel> popups) {
    if (popups.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return PopupCarouselDialog(
              popupModels: popups,
              userModel: userModel,
            );
          },
        );//.then((value) => gotoService());
      });
    } else {
      gotoService();
    }
  }

  Widget userForm() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: MyStyle().primaryLight,
        border: Border.all(color: MyStyle().mainColor),
      ),
      height: 45.0,
      width: 250.0,
      child: TextFormField(
        style: TextStyle(color: Colors.black87),
        //  initialValue: 'nott', // set default value
        onSaved: (String? string) {
          user = string!.trim();
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: MyStyle().primaryLight,
        border: Border.all(color: MyStyle().mainColor),
      ),
      height: 45.0,
      width: 250.0,
      child: TextFormField(
        style: TextStyle(color: Colors.black87),
        //  initialValue: '123456789', // set default value
        onSaved: (String? string) {
          password = string!.trim();
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
        child: status! ? showProcess() : mainContent(),
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
                // showAppName(),
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
