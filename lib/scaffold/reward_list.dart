import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ptncenter/models/reward_category_model.dart';
import 'package:ptncenter/models/reward_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/reward_detail.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'detail_cart.dart';
import 'my_service.dart';

class RewardList extends StatefulWidget {
  final UserModel? userModel;

  const RewardList({Key? key, this.userModel}) : super(key: key);

  @override
  _RewardListState createState() => _RewardListState();
}

class Debouncer {
  final int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  Debouncer({this.milliseconds});
  run(VoidCallback action) {
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(Duration(milliseconds: milliseconds!), action);
  }
}

class _RewardListState extends State<RewardList> {
  UserModel? myUserModel;
  List<RewardModel> rewardModels = [];
  Set<String> myRewardCartCodes = {};
  int page = 1;
  bool visible = true;
  ScrollController scrollController = ScrollController();
  int selectIndex = 2;

  List<RewardCategoryModel> rewardCategoryModels = [];
  String? selectedCateId;
  String searchString = '';
  TextEditingController searchController = TextEditingController();
  final Debouncer debouncer = Debouncer(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;

    createController(); // เมื่อ scroll to bottom

    readReward();
    loadMyReward();
    loadRewardCategories();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadRewardCategories() async {
    String url = 'https://ptnpharma.com/jsonData/reward_category.json';
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);

    List<RewardCategoryModel> categories = [];
    for (var map in result) {
      RewardCategoryModel rewardCategoryModel =
          RewardCategoryModel.fromJson(map);
      if (rewardCategoryModel.status == '1') {
        categories.add(rewardCategoryModel);
      }
    }

    setState(() {
      rewardCategoryModels = categories;
    });
  }

  void applyFilter() {
    setState(() {
      page = 1;
      rewardModels.clear();
    });
    readReward();
  }

  Future<void> loadMyReward() async {
    String? memberId = myUserModel!.id;
    String? memberCode = myUserModel!.customerCode;
    String url =
        '${MyStyle().serverName}/apishop/json_loadmyreward.php?memberId=$memberId&memberCode=$memberCode';
    print('url > $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemsData = result['itemsData'];

    if (itemsData is List) {
      setState(() {
        myRewardCartCodes =
            itemsData.map<String>((item) => item['rw_code'].toString()).toSet();
      });
    }
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          page = page + 1;
          readReward();
          print('in the end');
        }
      }
    });
  }

  Future<void> readReward() async {
    setState(() {
      visible = true;
    });

    String? memberId = myUserModel!.id;
    String? memberCode = myUserModel!.customerCode;
    String url =
        '${MyStyle().serverName}/apishop/json_reward.php?memberId=$memberId&memberCode=$memberCode&page=$page';
    if (selectedCateId != null && selectedCateId!.isNotEmpty) {
      url = '$url&cate_id=$selectedCateId';
    }
    if (searchString.isNotEmpty) {
      url = '$url&searchKey=${Uri.encodeQueryComponent(searchString)}';
    }
    print('url > $url');
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemReward = result['itemsData'];

    for (var map in mapItemReward) {
      RewardModel rewardModel = RewardModel.fromJson(map);
      setState(() {
        rewardModels.add(rewardModel);
      });
    }

    setState(() {
      visible = false;
    });
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(color: Colors.green.shade300),
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
    );
  }

  Widget showImage(RewardModel reward) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: 80,
      height: 80,
      decoration: (reward.photo != null && reward.photo != '')
          ? BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                alignment: FractionalOffset.topCenter,
                image: NetworkImage(reward.photo!),
              ),
            )
          : null,
      child: (reward.photo == null || reward.photo == '')
          ? Icon(Icons.card_giftcard, color: Colors.grey.shade400, size: 40.0)
          : null,
    );
  }

  Widget showText(RewardModel reward) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 5.0, right: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              reward.subject ?? '',
              style: MyStyle().h3Style,
            ),
            (reward.point != null && reward.point != '')
                ? Row(
                  children: [
                    Icon(Icons.stars, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                        '${reward.point}',
                        style: MyStyle().h3StyleRed,
                      ),
                  ],
                )
                : Container(),
            (reward.stock != null && reward.stock != '')
                ? Text(
                    'คงเหลือ: ${reward.stock} ${reward.unit ?? ''}',
                    style: MyStyle().h4StyleGray,
                  )
                : Container(),
            (reward.maxqty != null &&
                    reward.maxqty != '' &&
                    reward.maxqty != '0')
                ? Text(
                    'จำกัด: ${reward.maxqty} ${reward.unit ?? ''} ต่อคน',
                    style: MyStyle().h4StyleGray,
                  )
                : Container(),
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

  Widget showAlreadyRedeemedLabel() {
    return Positioned(
      right: 8.0,
      bottom: 4.0,
      child: Text('ทำรายการนี้แล้ว', style: MyStyle().h4StyleRed),
    );
  }

  Widget showRewardCard(RewardModel reward) {
    return GestureDetector(
      onTap: () => routeToRewardDetail(reward),
      child: Card(
        child: Container(
          decoration: myBoxDecoration(),
          padding: EdgeInsets.only(top: 0.5),
          child: Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  showImage(reward),
                  showText(reward),
                ],
              ),
              if (myRewardCartCodes.contains(reward.code)) showAlreadyRedeemedLabel(),
            ],
          ),
        ),
      ),
    );
  }

  List<RewardModel> get filteredRewardModels {
    return rewardModels.where((reward) {
      if (selectedCateId != null &&
          selectedCateId!.isNotEmpty &&
          reward.cateId != selectedCateId) {
        return false;
      }

      if (searchString.isNotEmpty) {
        String keyword = searchString.toLowerCase();
        bool matchCode = (reward.code ?? '').toLowerCase().contains(keyword);
        bool matchBarcode =
            (reward.barcode ?? '').toLowerCase().contains(keyword);
        bool matchSubject =
            (reward.subject ?? '').toLowerCase().contains(keyword);
        if (!matchCode && !matchBarcode && !matchSubject) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget showProductItem() {
    int perpage = 15;
    bool loadingIcon = false;
    List<RewardModel> shownRewardModels = filteredRewardModels;

    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: shownRewardModels.length,
        itemBuilder: (BuildContext buildContext, int index) {
          if ((index + 1) % perpage == 0) {
            loadingIcon = true;
          } else {
            loadingIcon = false;
          }

          if (loadingIcon == true) {
            return Column(
              children: [
                showRewardCard(shownRewardModels[index]),
                myCircularProgress(),
              ],
            );
          }

          return showRewardCard(shownRewardModels[index]);
        },
      ),
    );
  }

  void routeToRewardDetail(RewardModel rewardModel) async {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return RewardDetail(rewardModel: rewardModel, userModel: myUserModel);
    });
    final result = await Navigator.of(context).push(materialPageRoute);
    if (result is UserModel) {
      setState(() {
        myUserModel = result;
      });
      loadMyReward();
    }
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

  Widget showPointSummary() {
    final point = myUserModel?.point ?? 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.stars, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Text('คะแนนสะสม', style: MyStyle().h3Style),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$point คะแนน',
              style: MyStyle().h3StyleRed,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget showContent() {
    if (rewardModels.isEmpty) {
      return showProgressIndicate();
    } else if (filteredRewardModels.isEmpty) {
      return Expanded(
        child: Center(child: Text('ไม่พบรายการที่ค้นหา')),
      );
    } else {
      return showProductItem();
    }
  }

  Widget showProgressIndicate() {
    if (visible) {
      return Expanded(
        child: Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.green,
          size: 30,
        )),
      );
    } else {
      return Expanded(
        child: Center(child: Text('ไม่พบรายการของสมนาคุณ')),
      );
    }
  }

  Widget showFilterBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<String>(
              value: selectedCateId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'หมวดหมู่',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('ทั้งหมด'),
                ),
                ...rewardCategoryModels.map((category) {
                  return DropdownMenuItem<String>(
                    value: category.cateId,
                    child: Text(category.cateName ?? ''),
                  );
                }),
              ],
              onChanged: (value) {
                selectedCateId = value;
                applyFilter();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'ค้นหา code, barcode, ชื่อ',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    searchString = '';
                    applyFilter();
                  },
                ),
              ),
              onChanged: (value) {
                debouncer.run(() {
                  searchString = value.trim();
                  applyFilter();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: MyStyle().bgColor,
        title: Text('ของสมนาคุณ', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          showPointSummary(),
          showFilterBar(),
          showContent(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(),
    );
  }
}
