import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/reward_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/reward_list.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'detail_cart.dart';
import 'my_service.dart';

class RewardDetail extends StatefulWidget {
  final RewardModel rewardModel;
  final UserModel? userModel;

  const RewardDetail({Key? key, required this.rewardModel, this.userModel})
      : super(key: key);

  @override
  _RewardDetailState createState() => _RewardDetailState();
}

class _RewardDetailState extends State<RewardDetail> {
  RewardModel? rewardModel;
  UserModel? myUserModel;
  int qty = 1;
  int selectIndex = 2;
  bool alreadyInCart = false;

  @override
  void initState() {
    super.initState();
    rewardModel = widget.rewardModel;
    myUserModel = widget.userModel;
    checkAlreadyInCart();
  }

  Future<void> checkAlreadyInCart() async {
    String? memberId = myUserModel?.id;
    String? memberCode = myUserModel?.customerCode;
    String url = '${MyStyle().serverName}/apishop/json_loadmyreward.php'
        '?memberId=$memberId&memberCode=$memberCode';
    print('url > $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemsData = result['itemsData'];

    if (itemsData is List) {
      bool found = itemsData
          .any((item) => item['rw_code'].toString() == rewardModel!.code);
      setState(() {
        alreadyInCart = found;
      });
    }
  }

  Widget showImage(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: (rewardModel!.photo != null && rewardModel!.photo != '')
          ? Image.network(rewardModel!.photo!, fit: BoxFit.contain)
          : Icon(Icons.card_giftcard, color: Colors.grey.shade400, size: 80.0),
    );
  }

  Widget showTitle() {
    return Text(rewardModel!.subject ?? '', style: MyStyle().h3bStyle);
  }

  Widget showDetail() {
    return (rewardModel!.detail == null || rewardModel!.detail == '')
        ? Container()
        : Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('รายละเอียด :', style: MyStyle().h4bStyleGray),
              ),
              Container(
                child:
                    Text(rewardModel!.detail!, style: MyStyle().h4StyleGray),
              ),
              SizedBox(height: 20.0),
            ],
          );
  }

  Widget showPointStock() {
    return Container(
      width: double.infinity,
      child: Row(
        children: <Widget>[
          Container(
            width: 90.0,
            child: Text('แต้มที่ใช้ :', style: MyStyle().h4bStyleGray),
          ),
          Container(
            child: Text(
              rewardModel!.point ?? '',
              style: MyStyle().h3StyleRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget showStock() {
    return Container(
      width: double.infinity,
      child: Row(
        children: <Widget>[
          Container(
            width: 90.0,
            child: Text('คงเหลือ :', style: MyStyle().h4bStyleGray),
          ),
          Container(
            child: Text(
              '${rewardModel!.stock ?? ''} ${rewardModel!.unit ?? ''}',
              style: (rewardModel!.stock.toString() != '0')
                  ? MyStyle().h3StyleGray
                  : MyStyle().h3StyleRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget showSpinbox() {
    double maxValue = double.tryParse(rewardModel!.maxqty ?? '') ?? 1;
    if (maxValue < 1) maxValue = 1;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 90.0,
            child: Text('จำนวน :', style: MyStyle().h4bStyleGray),
          ),
          Expanded(
            child: SpinBox(
              min: 1,
              max: maxValue,
              value: qty.toDouble(),
              onChanged: (changevalue) {
                setState(() {
                  qty = changevalue.toInt();
                });
              },
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const int maxRewardCartItems = 3;

  Future<void> checkRewardCartThenSubmit() async {
    String? memberId = myUserModel?.id;
    String? memberCode = myUserModel?.customerCode;
    String url = '${MyStyle().serverName}/apishop/json_loadmyreward.php'
        '?memberId=$memberId&memberCode=$memberCode';
    print('url > $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemsData = result['itemsData'];
    int cartCount = (itemsData is List) ? itemsData.length : 0;

    if (cartCount >= maxRewardCartItems) {
      normalDialogPopup(context, 'แจ้งเตือน',
          'คุณแลกของสมนาคุณครบ $maxRewardCartItems รายการแล้ว');
      return;
    }

    submitRedeem();
  }

  Future<void> normalDialogPopup(
    BuildContext buildContext,
    String title,
    String message,
  ) async {
    AwesomeDialog(
      context: buildContext,
      headerAnimationLoop: false,
      dialogType: DialogType.error,
      title: title,
      desc: message,
      btnOkColor: Colors.red,
      btnOkText: 'ปิดแจ้งเตือน',
      btnOkOnPress: () {},
      dismissOnTouchOutside: false,
    ).show();
  }

  Future<void> submitRedeem() async {
    String? memberId = myUserModel?.id;
    String url = '${MyStyle().serverName}/apishop/json_submit_reward_redeem.php'
        '?memberId=$memberId&rw_id=${rewardModel!.id}&qty=$qty';
    print('url > $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);

    if (myUserModel != null && result['pointbalance'] != null) {
      myUserModel!.point = result['pointbalance'];
    }

    showThankYouDialog();
  }

  Widget thankYouTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text('Thank you', style: TextStyle(color: Colors.grey.shade600)),
    );
  }

  Widget thankYouIcon() {
    return Container(
      width: 70.0,
      height: 70.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
      ),
      child: Icon(Icons.check, color: Colors.white, size: 40.0),
    );
  }

  Widget thankYouCloseButton(BuildContext dialogContext) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: Text('Close', style: TextStyle(color: Colors.white)),
      onPressed: () {
        Navigator.of(dialogContext).pop();
        Navigator.of(context).pop(myUserModel);
      },
    );
  }

  void showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                thankYouTitle(),
                SizedBox(height: 20.0),
                thankYouIcon(),
                SizedBox(height: 20.0),
                Text(
                  'ยืนยันการแลกของสมนาคุณ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.0),
                Text(
                  'กรุณาตรวจสอบตะกร้าสินค้า\nของสมนาคุณจะถูกจัดส่งไปในการจัดส่งสินค้ารอบถัดไป',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: thankYouCloseButton(dialogContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget submitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MyStyle().bgColor,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(
              'แลกของสมนาคุณ',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            onPressed: alreadyInCart
                ? null
                : () {
                    checkRewardCartThenSubmit();
                  },
          ),
          if (alreadyInCart)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                'คุณได้ทำรายการนี้แล้ว',
                textAlign: TextAlign.center,
                style: MyStyle().h4StyleRed,
              ),
            ),
        ],
      ),
    );
  }

  Widget showController(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10.0),
      children: <Widget>[
        showImage(context),
        showTitle(),
        Divider(),
        showPointStock(),
        showStock(),
        showSpinbox(),
        submitButton(),
        Divider(),
        showDetail(),
      ],
    );
  }

  Widget showDetailList(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        side: BorderSide(width: 5, color: Colors.grey.shade200),
      ),
      child: showController(context),
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel,
      );
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
          icon: const Icon(Icons.card_giftcard),
          title: const Text('Reward'),
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
              builder: (value) => MyService(
                userModel: myUserModel,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            routeToListProduct(0);
          } else if (index == 2) {
            MaterialPageRoute materialPageRoute =
                MaterialPageRoute(builder: (BuildContext buildContext) {
              return RewardList(userModel: myUserModel);
            });
            Navigator.of(context).push(materialPageRoute);
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
        title: Text('รายละเอียดของสมนาคุณ',
            style: TextStyle(color: Colors.white)),
      ),
      body: showDetailList(context),
      bottomNavigationBar: stylishBottomBar(),
    );
  }
}
