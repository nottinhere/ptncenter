import 'dart:convert';
import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/popup_model.dart';
import 'package:ptncenter/models/promotion_group_model.dart';
import 'package:ptncenter/models/gift_model.dart';

import 'package:ptncenter/models/promote_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail.dart';
import 'package:ptncenter/scaffold/detail_news.dart';
import 'package:ptncenter/utility/normal_dialog.dart';

import 'package:ptncenter/scaffold/license_status.dart';

import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:ptncenter/scaffold/list_product_frequent.dart';
import 'package:ptncenter/scaffold/list_product_vote.dart';
import 'package:ptncenter/scaffold/list_promotionbanner.dart';

import 'package:ptncenter/scaffold/history_list.dart';
import 'package:ptncenter/scaffold/ocr_scan.dart';
import 'package:ptncenter/scaffold/orn_list.dart';
import 'package:ptncenter/scaffold/payment_ornlist.dart';
import 'package:ptncenter/scaffold/reward_list.dart';
import 'package:ptncenter/scaffold/suggestion_form.dart';

// import 'package:ptncenter/scaffold/map.dart';

import 'package:ptncenter/utility/my_style.dart';

import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:webview_flutter/webview_flutter.dart';

class Home extends StatefulWidget {
  final UserModel? userModel;
  bool? firstLoadAds;
  bool? orderSuccess;

  Home(
      {Key? key,
      this.userModel,
      this.firstLoadAds = false,
      this.orderSuccess = false})
      : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _QuickAction(this.icon, this.label, this.onTap);
}

class _HomeState extends State<Home> {
  // Explicit
  List<Widget>? slideshowLists = [];
  List<String>? urlImages = [];

  ScrollController scrollController = ScrollController();

  int? amontCart = 0;
  UserModel? myUserModel;
  bool? orderSuccess;

  List<ProductAllModel>? slideshowModels = [];
  List<PopupModel>? newsModels = [];

  int _promoIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  List<PromotionGroupModel> promotionGroups = [];
  Map<String, GiftModel> giftMap = {};
  final CarouselSliderController _groupPromoController =
      CarouselSliderController();

  // Method
  @override
  void initState() {
    super.initState();

    myUserModel = widget.userModel;
    orderSuccess = widget.orderSuccess;
    readSlide();
    setState(() {
      readCart();
    });
    _requestPermission();
    readNews();
    updateUserProfile();
    readLicenseAlert();
    readPromotionGroups();
    readGifts();
    Future.delayed(Duration.zero, () => showOrderSuccessDialog(context));
  }

  _requestPermission() async {
    await Permission.camera.request();
  }

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  /***************************  */

  Future<void> readSlide() async {
    String? url = '${MyStyle().serverName}/apishop/json_slideshow.php';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null
    for (var map in mapItemProduct) {
      PromoteModel? slideshowModel = PromoteModel.fromJson(map);
      ProductAllModel? productAllModel = ProductAllModel.fromJson(map);
      String? urlImage = slideshowModel.photo;
      setState(() {
        slideshowModels!.add(productAllModel);
        slideshowLists!.add(showImageNetWork(urlImage!));
        urlImages!.add(urlImage);
      });
    }
  }

  Future<void> readPromotionGroups() async {
    String url = 'https://ptnpharma.com/jsonData/medicinepromotiongroup.json';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result is List) {
        List<PromotionGroupModel> groups =
            result.map((map) => PromotionGroupModel.fromJson(map)).toList();
        if (mounted) {
          setState(() {
            promotionGroups = groups;
          });
        }
      }
    } catch (e) {
      print('readPromotionGroups error: $e');
    }
  }

  Future<void> readGifts() async {
    String url = 'https://ptnpharma.com/jsonData/gift.json';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result is List) {
        Map<String, GiftModel> map = {};
        for (var itemMap in result) {
          GiftModel gift = GiftModel.fromJson(itemMap);
          if (gift.id != null) map[gift.id!] = gift;
        }
        if (mounted) {
          setState(() {
            giftMap = map;
          });
        }
      }
    } catch (e) {
      print('readGifts error: $e');
    }
  }

  String formatPromotionTarget(String? target) {
    double? value = double.tryParse(target ?? '');
    if (value == null) return target ?? '';
    String formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    // ใส่ comma คั่นหลักพัน
    String intPart = formatted.split('.').first;
    String result = '';
    int count = 0;
    for (int i = intPart.length - 1; i >= 0; i--) {
      result = intPart[i] + result;
      count++;
      if (count % 3 == 0 && i != 0) result = ',$result';
    }
    return '$result.-';
  }

  void routeToGroupProducts(PromotionGroupModel group) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: 6,
        userModel: myUserModel!,
        cateName: group.name,
        promotionGroupId: group.id,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget promotionGroupCard(PromotionGroupModel group) {
    GiftModel? gift = giftMap[group.gift];
    int itemCount = group.medIds.length;

    return GestureDetector(
      onTap: () => routeToGroupProducts(group),
      child: Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MyStyle().radiusM),
        border: Border.all(color: MyStyle().borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.card_giftcard, color: Colors.red.shade400, size: 20.0),
              SizedBox(width: 6.0),
              Expanded(
                child: Text(group.name ?? '',
                    style: MyStyle().h3bStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Text('ซื้อครบ ${formatPromotionTarget(group.target)}',
                  style: TextStyle(
                      color: MyStyle().mainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0)),
              SizedBox(width: 4.0),
              Icon(Icons.arrow_forward, size: 14.0, color: MyStyle().mainColor),
            ],
          ),
          if (gift != null) ...[
            SizedBox(height: 6.0),
            Row(
              children: <Widget>[
                Icon(Icons.card_giftcard,
                    size: 16.0, color: Colors.red.shade400),
                SizedBox(width: 6.0),
                Expanded(
                  child: Text('${gift.name ?? ''} x1',
                      style: MyStyle().h4StyleGray,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
          Divider(height: 18.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.layers_outlined,
                        size: 14.0, color: Colors.grey.shade500),
                    SizedBox(width: 4.0),
                    Expanded(
                      child: Text('สินค้าร่วมรายการ $itemCount รายการ',
                          style: MyStyle().captionStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Text('ดูสินค้าในกลุ่ม',
                      style: TextStyle(
                          color: MyStyle().mainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0)),
                  Icon(Icons.chevron_right,
                      size: 16.0, color: MyStyle().mainColor),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget groupPromotionSection() {
    if (promotionGroups.isEmpty) return SizedBox();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.card_giftcard, size: 24.0, color: Colors.red.shade400),
              SizedBox(width: 8.0),
              Text('โปรโมชันกลุ่มสินค้า',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: MyStyle().textColor,
                      height: 1.1)),
              SizedBox(width: 6.0),
              Text('(${promotionGroups.length})',
                  style: MyStyle().captionStyle),
              Spacer(),
              IconButton(
                icon: Icon(Icons.chevron_left),
                color: MyStyle().mutedTextColor,
                onPressed: () => _groupPromoController.previousPage(),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                color: MyStyle().mutedTextColor,
                onPressed: () => _groupPromoController.nextPage(),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          CarouselSlider.builder(
            carouselController: _groupPromoController,
            options: CarouselOptions(
              height: 145.0,
              viewportFraction: 0.85,
              enableInfiniteScroll: false,
            ),
            itemCount: promotionGroups.length,
            itemBuilder: (context, index, realIdx) {
              return promotionGroupCard(promotionGroups[index]);
            },
          ),
        ],
      ),
    );
  }

  String? licenseAlertStatus;
  String? licenseAlertYear;
  Future<void> readLicenseAlert() async {
    String urlPop = '${MyStyle().serverName}/apishop/json_license_alert.php';
    http.Response responsePop = await http.get(Uri.parse(urlPop));
    var resultPop = json.decode(responsePop.body);
    var mapItemPopup = resultPop['itemsData'];
    for (var map in mapItemPopup) {
      PopupModel popupModel = PopupModel.fromJson(map);
      String? subject = popupModel.subject;
      String? popstatus = popupModel.popstatus;
      setState(() {
        licenseAlertYear = subject;
        licenseAlertStatus = popstatus;
      });
    }
  }

  int? userlicenseyear;
  String? userlicensestatus;

  UserModel? updateuserModel;
  Future<void> updateUserProfile() async {
    String? memberId = myUserModel!.id.toString();
    String? url =
        '${MyStyle().serverName}/apishop/json_customer_profile.php?memberId=$memberId';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    Map<String, dynamic> map = result['data'];
    updateuserModel = UserModel.fromJson(map);
    setState(() {
      userlicenseyear = updateuserModel!.lastupdateLicenseYear;
      userlicensestatus = updateuserModel!.lastupdateLicenseStatus;
    });
  }

  Future<void> readNews() async {
    String? url = '${MyStyle().serverName}/apishop/json_news.php?limit=7';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemNews = result['itemsData'];

    for (var map in mapItemNews) {
      PopupModel? popupModel = PopupModel.fromJson(map);
      setState(() {
        newsModels!.add(popupModel);
      });
    }
  }

  void showOrderSuccessDialog(BuildContext context) {
    if (orderSuccess == true) {
      AwesomeDialog(
        context: context,
        headerAnimationLoop: false,
        dialogType: DialogType.noHeader,
        autoHide: const Duration(seconds: 5),
        title: 'บันทึกคำสั่งซื้อ',
        desc: 'คำสั่งซื้อของคุณได้ถูกดำเนินการเสร็จสิ้น ',
        btnOkOnPress: () {
          debugPrint('OnClcik');
        },
        btnOkIcon: Icons.check_circle,
      ).show();
    }
  }

  Widget myCircularProgress() {
    return Center(
      child: CircularProgressIndicator(color: MyStyle().mainColor),
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel!,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void submitSearch(String value) {
    String query = value.trim();
    String? searchStr;

    if (query.isNotEmpty) {
      List<String> words = query.split(RegExp(r'\s+'));
      if (words.length >= 2) {
        // ค้นหาด้วย 2 คำแรกพร้อมกัน (ต้องเจอทั้งคู่ใน field เดียวกัน) เช่น "Acetin 200"
        String keyword1 = Uri.encodeComponent(words[0]);
        String keyword2 = Uri.encodeComponent(words[1]);
        searchStr = 'kw2|$keyword1|$keyword2';
      } else {
        searchStr = query;
      }
    }

    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: 0,
        userModel: myUserModel!,
        searchStr: searchStr,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Future<void> readQRcodePreview() async {
    try {
      var qrScanString = await BarcodeScanner.scan();
      String? qrString = qrScanString.rawContent;
      if (qrString != '') {
        decodeQRcode(qrString);
      }
    } on PlatformException catch (e) {
      print('e = $e');
    }
  }

  Future<void> decodeQRcode(var code) async {
    try {
      if (code != '' && code != null) {
        String url =
            '${MyStyle().serverName}/apishop/json_productlist.php?bqcode=$code';
        http.Response response = await http.get(Uri.parse(url));
        var result = json.decode(response.body);

        int status = result['status'];
        if (status == 0) {
          normalDialog(context, 'Not found', 'ไม่พบ code :: $code ในระบบ');
        } else {
          var itemProducts = result['itemsProduct'];
          for (var map in itemProducts) {
            ProductAllModel productAllModel = ProductAllModel.fromJson(map);
            MaterialPageRoute route = MaterialPageRoute(
              builder: (BuildContext context) => Detail(
                userModel: myUserModel,
                productAllModel: productAllModel,
              ),
            );
            Navigator.of(context).push(route);
          }
        }
      }
    } catch (e) {}
  }

  /// ---------------- UI sections ----------------

  Widget searchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: Container(
        height: 46.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MyStyle().radiusL),
          border: Border.all(color: MyStyle().borderColor),
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: submitSearch,
          style: TextStyle(fontSize: 15.0),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'ค้นหาสินค้า ยา เวชภัณฑ์...',
            hintStyle: TextStyle(color: MyStyle().mutedTextColor),
            prefixIcon: Icon(Icons.search_rounded, color: MyStyle().mainColor),
            suffixIcon: IconButton(
              icon: Icon(Icons.qr_code_scanner_rounded,
                  color: MyStyle().mainColor),
              onPressed: readQRcodePreview,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12.0),
          ),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget greetingHeader() {
    String? login = myUserModel!.name;
    String? address = myUserModel!.address;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 24.0,
            backgroundColor: MyStyle().primaryLight,
            child: Icon(Icons.storefront_rounded, color: MyStyle().mainColor),
          ),
          SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'สวัสดี, $login',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$address',
                  style: MyStyle().captionStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget licenseBanner() {
    if (licenseAlertStatus != '1') return SizedBox();

    int showlicenseAlertYear = int.parse(licenseAlertYear!) + 543;

    String txtTitle = '';
    Color colorAlertBox = MyStyle().alertColor;

    if (userlicensestatus == '0' || userlicenseyear.toString() != licenseAlertYear) {
      txtTitle = 'กรุณาอัพโหลดใบอนุญาตขายยา ปี $showlicenseAlertYear';
      colorAlertBox = MyStyle().alertColor;
    } else if (userlicensestatus == '1' && userlicenseyear.toString() == licenseAlertYear) {
      txtTitle = 'อยู่ระหว่างตรวจสอบใบอนุญาตขายยา';
      colorAlertBox = MyStyle().warningColor;
    } else if (userlicensestatus == '2' && userlicenseyear.toString() == licenseAlertYear) {
      txtTitle = 'อัพเดทใบอนุญาตขายยาเรียบร้อย';
      colorAlertBox = MyStyle().mainColor;
    } else if (userlicensestatus == '3' && userlicenseyear.toString() == licenseAlertYear) {
      txtTitle = 'ใบอนุญาตขายยาของคุณไม่สมบูรณ์';
      colorAlertBox = MyStyle().alertColor;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
      child: GestureDetector(
        onTap: () {
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return License(userModel: myUserModel!);
          });
          Navigator.of(context).push(materialPageRoute);
        },
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
              Icon(Icons.chevron_right_rounded, color: colorAlertBox),
            ],
          ),
        ),
      ),
    );
  }

  Widget promoCarousel() {
    if (slideshowLists!.isEmpty) {
      return Container(
        height: 160.0,
        margin: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
        child: myCircularProgress(),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 4.0),
      child: Column(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(MyStyle().radiusM),
            child: CarouselSlider.builder(
              options: CarouselOptions(
                height: 250.0,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayAnimationDuration: Duration(seconds: 5),
                onPageChanged: (int index, reason) {
                  setState(() {
                    _promoIndex = index;
                  });
                },
              ),
              itemCount: slideshowLists!.length,
              itemBuilder: (context, index, realIdx) {
                return GestureDetector(
                  onTap: () {
                    MaterialPageRoute materialPageRoute = MaterialPageRoute(
                        builder: (BuildContext buildContext) {
                      return ListProduct(
                        index: 6,
                        userModel: myUserModel!,
                        cateName: slideshowModels![index].title.toString(),
                        searchStr: slideshowModels![index].productCode.toString(),
                      );
                    });
                    Navigator.of(context)
                        .push(materialPageRoute)
                        .then((value) => readCart());
                  },
                  child: Image.network(
                    urlImages![index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                );
              },
            ),
          ),
          if (slideshowLists!.length > 1) ...[
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slideshowLists!.length, (index) {
                bool active = index == _promoIndex;
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 3.0),
                  width: active ? 18.0 : 6.0,
                  height: 6.0,
                  decoration: BoxDecoration(
                    color: active ? MyStyle().mainColor : MyStyle().borderColor,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                );
              }),
            ),
          ],
          SizedBox(height: 8.0),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: MyStyle().mainColor,
                side: BorderSide(color: MyStyle().mainColor),
              ),
              icon: Icon(Icons.local_offer_outlined),
              label: Text('ดูโปรโมชันทั้งหมด'),
              onPressed: () {
                MaterialPageRoute materialPageRoute = MaterialPageRoute(
                    builder: (BuildContext buildContext) {
                  return Promotionbanner(userModel: myUserModel);
                });
                Navigator.of(context).push(materialPageRoute);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionHeader(String title, IconData iconData) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        children: <Widget>[
          Icon(iconData, size: 22.0, color: MyStyle().textColor),
          SizedBox(width: 8.0),
          Text(title, style: MyStyle().sectionTitleStyle),
        ],
      ),
    );
  }

  List<_QuickAction> quickActionsProduct() {
    return <_QuickAction>[
      _QuickAction(Icons.medication_liquid_rounded, 'สั่งสินค้า',
          () => routeToListProduct(0)),
      _QuickAction(Icons.fiber_new_rounded, 'สินค้าใหม่',
          () => routeToListProduct(1)),
      _QuickAction(Icons.local_offer_rounded, 'สินค้าโปรโมชัน',
          () => routeToListProduct(2)),
      _QuickAction(Icons.price_change_rounded, 'จะปรับราคา',
          () => routeToListProduct(3)),
      _QuickAction(Icons.repeat_rounded, 'สินค้าสั่งประจำ', () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return ListProductFrequent(userModel: myUserModel!);
        });
        Navigator.of(context).push(materialPageRoute);
      }),
      _QuickAction(Icons.remove_shopping_cart_rounded, 'สั่งแล้วไม่ได้รับ',
          () => routeToListProduct(4)),
      _QuickAction(Icons.local_fire_department_rounded, 'สินค้าขายดี',
          () => routeToListProduct(7)),
      _QuickAction(Icons.trending_up_rounded, 'สินค้ามาแรง',
          () => routeToListProduct(8)),
      _QuickAction(Icons.favorite_rounded, 'สินค้าโปรด', () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return ListProductfav(userModel: myUserModel!);
        });
        Navigator.of(context).push(materialPageRoute);
      }),
    ];
  }

   List<_QuickAction> quickActions() {
    return <_QuickAction>[
      _QuickAction(Icons.document_scanner_rounded, 'OCR หาสินค้า', () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return OcrScan(userModel: myUserModel);
        });
        Navigator.of(context).push(materialPageRoute);
      }),
      _QuickAction(Icons.history_rounded, 'ประวัติการสั่ง', () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return HistoryList(userModel: myUserModel!);
        });
        Navigator.of(context).push(materialPageRoute);
      }),
      _QuickAction(Icons.card_giftcard_rounded, 'ของสมนาคุณ', () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return RewardList(userModel: myUserModel!);
        });
        Navigator.of(context).push(materialPageRoute);
      }),
      _QuickAction(Icons.payments_rounded, 'การชำระเงิน', () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return PaymentOrnList(userModel: myUserModel!);
        });
        Navigator.of(context).push(materialPageRoute);
      }),
      _QuickAction(Icons.fact_check_rounded, 'ใบส่งของ', () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return OrnList(userModel: myUserModel!);
        });
        Navigator.of(context).push(materialPageRoute);
      }),
      _QuickAction(Icons.how_to_vote_rounded, 'โหวตยาน่าขาย', () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return ListProductvote(userModel: myUserModel!);
        });
        Navigator.of(context).push(materialPageRoute);
      }),

      _QuickAction(Icons.rate_review_rounded, 'ข้อเสนอแนะ', () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return SuggestionForm(userModel: myUserModel!);
        });
        Navigator.of(context).push(materialPageRoute);
      }),
            _QuickAction(Icons.history_rounded, 'ประวัติสั่ง(Web)',
          () => _openWebPage('history')),

    ];
  }

  void _openWebPage(String webPage) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => WebViewExample(
                userModel: myUserModel!,
                webPage: webPage,
              )),
    );
  }

  Widget quickTile(_QuickAction action, int colorIndex) {
    Color tint = MyStyle().tileTints[colorIndex % MyStyle().tileTints.length];
    Color iconColor =
        MyStyle().tileIconColors[colorIndex % MyStyle().tileIconColors.length];

    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 65.0,
            height: 65.0,
            decoration: BoxDecoration(
              color: tint,
              shape: BoxShape.circle,
            ),
            child: Icon(action.icon, color: iconColor, size: 26.0),
          ),
          SizedBox(height: 6.0),
          Text(
            action.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: MyStyle().tileLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget quickAccessProductGrid() {
    List<_QuickAction> actions = quickActionsProduct();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 8.0,
        // childAspectRatio: 0.8,
        children: List.generate(
          actions.length,
          (index) => quickTile(actions[index], index),
        ),
      ),
    );
  }

    Widget quickAccessGrid() {
    List<_QuickAction> actions = quickActions();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20.0,
        crossAxisSpacing: 8.0,
        // childAspectRatio: 0.8,
        children: List.generate(
          actions.length,
          (index) => quickTile(actions[index], index),
        ),
      ),
    );
  }

  Widget newsSection() {
    if (newsModels!.isEmpty) return SizedBox();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: List.generate(newsModels!.length, (index) {
          PopupModel news = newsModels![index];
          return Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                MaterialPageRoute materialPageRoute =
                    MaterialPageRoute(builder: (BuildContext buildContext) {
                  return DetailNews(
                    popupModel: news,
                    userModel: myUserModel!,
                  );
                });
                Navigator.of(context).push(materialPageRoute);
              },
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(MyStyle().radiusS),
                  border: Border.all(color: MyStyle().borderColor),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: MyStyle().primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.campaign_rounded,
                          color: MyStyle().mainColor, size: 20.0),
                    ),
                    SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        '${news.subject}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: MyStyle().h3Style,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: MyStyle().mutedTextColor),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> readCart() async {
    amontCart = 0;
    String memberId = myUserModel!.id.toString();
    String url =
        '${MyStyle().serverName}/apishop/json_loadmycart.php?memberId=$memberId&screen=home';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    if (cartList != null) {
      for (var _ in cartList) {
        setState(() {
          amontCart = amontCart! + 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? loginStatus = myUserModel!.status;

    if (loginStatus != '1') {
      return Center(child: Text('กรุณาติดต่อ PTN Pharma'));
    }

    return Container(
      color: MyStyle().scaffoldBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            greetingHeader(),
            searchBar(),
            licenseBanner(),
            promoCarousel(),
            groupPromotionSection(),
            sectionHeader('สินค้า', Icons.medical_services_rounded),
            quickAccessProductGrid(),
            sectionHeader('เพิ่มเติม', Icons.menu_book_rounded),
            quickAccessGrid(),
            sectionHeader('ข่าวสาร', Icons.newspaper_rounded),
            newsSection(),
          ],
        ),
      ),
    );
  }
}

class WebViewExample extends StatefulWidget {
  final UserModel? userModel;
  final String? webPage;
  const WebViewExample({super.key, this.userModel, this.webPage});
  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  UserModel? myUserModel;
  String? mywebPage;
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    mywebPage = widget.webPage;
    String? memberId = myUserModel!.id;
    String? memberCode = myUserModel!.customerCode;
    String webPage = mywebPage.toString();


    String? urlView =
        'https://www.ptnpharma.com/shop/pages/tables/jo.php?memberId=$memberId&memberCode=$memberCode'; //
    if (webPage == 'pay') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/forms/pay_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
    } else if (webPage == 'history') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/tables/orderhistory_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
    } else if (webPage == 'suggestion') {
      urlView =
          'https://www.ptnpharma.com/shop/pages/forms/complain_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
    } else {
      urlView =
          'https://www.ptnpharma.com/shop/pages/forms/complain_mobile.php?memberId=$memberId&memberCode=$memberCode'; //
    }

    // #docregion webview_controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(urlView));
    // #enddocregion webview_controller
  }


  // #docregion webview_widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MyStyle().bgColor,
          iconTheme: IconThemeData(color: Colors.white),
          title:
              const Text('PTN Pharma', style: TextStyle(color: Colors.white))),
      body: WebViewWidget(controller: controller),
    );
  }
  // #enddocregion webview_widget
}
