import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/rewardredeem_model.dart';
import 'package:ptncenter/models/price_list_model.dart';
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/product_all_model2.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/medicine_promotion_model.dart';
import 'package:ptncenter/models/promotion_group_model.dart';
import 'package:ptncenter/models/promotion_tier.dart';
import 'package:ptncenter/models/gift_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/scaffold/detail.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_promotion.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
// import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'my_service.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter/services.dart';
// import 'package:scan_preview/scan_preview_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
       

class ReceivedGiftItem {
  final String sourceLabel;
  final GiftModel? gift;
  final String sets; // จำนวนชุดที่ได้ คำนวนจากจำนวนในตะกร้า
  final String perSetQty; // จำนวนของแถมต่อชุด มาจาก getqty/getqty2/getqty3
  final String totalQty; // sets * perSetQty (ไม่เกิน limitgift ถ้ามีการกำหนด)

  ReceivedGiftItem(
      {required this.sourceLabel,
      required this.gift,
      required this.sets,
      required this.perSetQty,
      required this.totalQty});
}

class NearMissPromotion {
  final String sourceLabel;
  final String remaining;
  final String remainingUnit;
  final GiftModel? gift;
  final String giftQty;
  final String giftUnit;
  final double progress; // 0.0 - 1.0 ความคืบหน้าไปยัง tier ถัดไป
  final String? productId; // สำหรับโปรโมชันรายสินค้า
  final PromotionGroupModel? group; // สำหรับโปรโมชันกลุ่มสินค้า

  NearMissPromotion(
      {required this.sourceLabel,
      required this.remaining,
      required this.remainingUnit,
      required this.gift,
      required this.giftQty,
      required this.giftUnit,
      required this.progress,
      this.productId,
      this.group});
}

class DetailCart extends StatefulWidget {
  final UserModel? userModel;
  DetailCart({Key? key, this.userModel}) : super(key: key);

  @override
  _DetailCartState createState() => _DetailCartState();
}

class _DetailCartState extends State<DetailCart> {
  // Explicit
  UserModel? myUserModel;

  List<PriceListModel>? priceListModels = [];
  List<PriceListModel>? priceListSModels = [];
  List<PriceListModel>? priceListMModels = [];
  List<PriceListModel>? priceListLModels = [];
  List<RewardredeemModel>? rewardredeemModels = [];
  // List<RewardredeemModel>? rewardredeemModels;

  ProductAllModel2? productAllModel;
  List<ProductAllModel2>? productAllModels = [];
  List<Map<String, dynamic>>? sMap = [];
  List<Map<String, dynamic>>? mMap = [];
  List<Map<String, dynamic>>? lMap = [];
  int? amontCart = 0;
  double? newQTY = 0;
  double? newQTYS = 0;
  double? newQTYM = 0;
  double? newQTYL = 0;
  int? newQTYint = 0;
  double? total = 0;
  String? transport;
  int? index = 0;
  int? selectedTranindex = 0;
  int selectIndex = 3;
  int countpricechange = 0;

  String? comment = '', memberID;
  int currentIndex = 3;
  String? qrString;
  bool? _isPressed = false;
  List<dynamic>? allArrIncartS = [];
  List<dynamic>? allArrIncartM = [];
  List<dynamic>? allArrIncartL = [];

  String? creditterm = '-';
  String? financialamount = '-';
  String? contactAdmin = '-';
  String? promotionalert = '-';
  String? promotionsuccess = '-';
  String? promotionsuccessgift = '-';

  List<MedicinePromotionModel> medicinePromotions = [];
  List<PromotionGroupModel> promotionGroupModels = [];
  Map<String, GiftModel> giftMap = {};
  Map<String, String> unitNameMap = {};

  // key: '${productId}_$size' -> qty ในตะกร้า (สำหรับเทียบโปรโมชันรายสินค้า)
  Map<String, double> cartQtyBySizeKey = {};
  // key: '${productId}_$size' -> หน่วยนับ เช่น กล่อง, ขวด (สำหรับแสดงผล)
  Map<String, String> cartLabelBySizeKey = {};
  // key: productId -> มูลค่ารวมในตะกร้า (สำหรับเทียบโปรโมชันกลุ่มสินค้ากับ target)
  Map<int, double> cartValueByProduct = {};

  List<ReceivedGiftItem> productGiftsReceived = [];
  List<ReceivedGiftItem> groupGiftsReceived = [];
  List<NearMissPromotion> nearMissPromotions = [];

  List<String>? listTransport = [
    '',
    '1. รับสินค้าเองที่ พัฒนาเภสัช',
    '2. รับสินค้าเองที่คลังสินค้า (ซอยวัดท่าทอง)',
    '3. รถส่งของตามรอบส่งสินค้า ตามสายส่ง',
    '4. รถส่งของตามรอบส่งสินค้าในเมืองนครสวรรค์',
    '5. ส่งทางบริษัทขนส่ง (เอกชน)',
  ];

  // List<String> listTransport = [
  //   '',
  //   '1. รับสินค้าเองที่ พัฒนาเภสัช',
  //   '2. รับเองที่คลังสินค้า(ซอยวัดท่าทอง)',
  //   '3. รถส่งของตามรอบสายส่งสินค้า',
  //   '4. รถส่งตามรอบส่งในเมืองนครสวรรค์',
  //   '5. ส่งทางบริษัทขนส่ง (เอกชน)'
  // ];

  // Method
  @override
  void initState() {
    // initState = auto load เพื่อแสดงใน  stateless
    super.initState();
    myUserModel = widget.userModel;
    setState(() {
      readCart();
      readReward();
    });
    readMedicinePromotions();
    readPromotionGroupRules();
    readGiftItems();
    readUnitNames();
  }

  // void _myCallback() {
  //   setState(() {
  //     _isPressed = true;
  //   });
  // }

  Future<void> readCart() async {
    clearArray();
    String? memberId = myUserModel!.id.toString();
    String? url = '${MyStyle().loadMyCart}$memberId&screen=cart';
    print('url Detail Cart ====>>>>> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    print('cartList =======>>> $cartList');

    // List<Map<bool, dynamic>> arrIncart = [];
    List<dynamic>? arrIncartS = [];
    List<dynamic>? arrIncartM = [];
    List<dynamic>? arrIncartL = [];
    productAllModels = [];
        total = 0;


    for (var map in cartList) {
     ProductAllModel2 productAllModel = ProductAllModel2.fromJson(map);
      // print('productAllModel = ${productAllModel.toJson().toString()}');

      setState(() {
        print('Start setState size S-1');
        Map<String, dynamic> priceListMap = map['price_list'];
        print('Start setState size S-2');
        int? productID = productAllModel.id;
        print('Start setState size S-3');


        if (priceListMap['s'] != null) {
          arrIncartS.add(productID);

          Map<String, dynamic> sizeSmap = priceListMap['s'];
          if (sizeSmap.isEmpty) {
            sMap?.add({'lable': ''});
            PriceListModel? priceListModel = PriceListModel.fromJson({
              'lable': '',
            });
            priceListSModels!.add(priceListModel);
          } else {
            sMap?.add(sizeSmap);
            PriceListModel? priceListModel = PriceListModel.fromJson(sizeSmap);
            priceListSModels!.add(priceListModel);
            priceListModel.quantity = priceListModel.quantity!.replaceAll(
              ',',
              '',
            );
            calculateTotal(priceListModel.price!, (priceListModel.quantity!));
            recordCartQtyAndValue(productID, 's', priceListModel);
          }
          // print('$productID > $priceS > $lableS > $quantityS > $pricechange');
        }

        if (priceListMap['m'] != null) {
          arrIncartM.add(productID);

          Map<String, dynamic> sizeMmap = priceListMap['m'];
          if (sizeMmap.isEmpty) {
            mMap?.add({'lable': ''});
            PriceListModel priceListModel = PriceListModel.fromJson({
              'lable': '',
            });
            priceListMModels!.add(priceListModel);
          } else {
            mMap?.add(sizeMmap);
            PriceListModel priceListModel = PriceListModel.fromJson(sizeMmap);
            priceListMModels!.add(priceListModel);
            priceListModel.quantity = priceListModel.quantity!.replaceAll(
              ',',
              '',
            );
            calculateTotal(priceListModel.price!, (priceListModel.quantity!));
            recordCartQtyAndValue(productID, 'm', priceListModel);
          }
          // print('sizeMmap = $sizeMmap');
        }

        if (priceListMap['l'] != null) {
          arrIncartL.add(productID);
          Map<String, dynamic> sizeLmap = priceListMap['l'];
          if (sizeLmap.isEmpty) {
            lMap!.add({'lable': ''});
            PriceListModel? priceListModel = PriceListModel.fromJson({
              'lable': '',
            });
            priceListLModels!.add(priceListModel);
          } else {
            lMap?.add(sizeLmap);
            PriceListModel? priceListModel = PriceListModel.fromJson(sizeLmap);
            priceListLModels!.add(priceListModel);
            priceListModel.quantity = priceListModel.quantity!.replaceAll(
              ',',
              '',
            );
            calculateTotal(priceListModel.price!, (priceListModel.quantity!));
            recordCartQtyAndValue(productID, 'l', priceListModel);
          }
          // print('sizeLmap = $sizeLmap');
        }
      });
      // print('arrIncartS >> $arrIncartS');
      // print('arrIncartM >> $arrIncartM');
      // print('arrIncartL >> $arrIncartL');

      // String? urlDT = '${MyStyle().loadMyCart}$memberId';
      // http.Response responseDT = await http.get(Uri.parse(urlDT));
      // var resultDT = json.decode(responseDT.body);

      print('Start setState readCart');
      setState(() {
        amontCart = amontCart! + 1;
        productAllModels!.add(productAllModel);
        allArrIncartS = arrIncartS;
        allArrIncartM = arrIncartM;
        allArrIncartL = arrIncartL;

        final Map<String, dynamic>  myData = result['data'];
        creditterm      = myData['credittermAlert'];
        financialamount = myData['financialamountAlert'];
        contactAdmin    = myData['contactAdminAlert'];
        promotionalert    = myData['promotionalert'];
        promotionsuccess    = myData['promotionsuccess'];
        promotionsuccessgift    = myData['promotionsuccessgift'];
        print('MY CREDIT > $creditterm + $financialamount + $contactAdmin');
        var countIC = productAllModels?.length;
            print('read productAllModels?.length >> {$countIC}');

      });
    }

    setState(() {
      Map<String, dynamic>? dataList = result['data'];
      countpricechange = dataList?['countpricechange'];
      print('countpricechange >>' + countpricechange.toString());
    });

    computeReceivedGifts();
  }

  void recordCartQtyAndValue(
      int? productID, String size, PriceListModel priceListModel) {
    if (productID == null) return;
    double qty = double.tryParse(priceListModel.quantity ?? '') ?? 0;
    double price =
        double.tryParse((priceListModel.price ?? '').replaceAll(',', '')) ??
            0;

    String key = '${productID}_$size';
    cartQtyBySizeKey[key] = (cartQtyBySizeKey[key] ?? 0) + qty;
    cartLabelBySizeKey[key] = priceListModel.lable ?? '';
    cartValueByProduct[productID] =
        (cartValueByProduct[productID] ?? 0) + (price * qty);
  }

  Future<void> readMedicinePromotions() async {
    String url = 'https://ptnpharma.com/jsonData/medicinepromotion.json';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result is List) {
        medicinePromotions =
            result.map((map) => MedicinePromotionModel.fromJson(map)).toList();
        computeReceivedGifts();
      }
    } catch (e) {
      print('readMedicinePromotions error: $e');
    }
  }

  Future<void> readPromotionGroupRules() async {
    String url = 'https://ptnpharma.com/jsonData/medicinepromotiongroup.json';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result is List) {
        promotionGroupModels =
            result.map((map) => PromotionGroupModel.fromJson(map)).toList();
        computeReceivedGifts();
      }
    } catch (e) {
      print('readPromotionGroupRules error: $e');
    }
  }

  Future<void> readGiftItems() async {
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
        giftMap = map;
        computeReceivedGifts();
      }
    } catch (e) {
      print('readGiftItems error: $e');
    }
  }

  Future<void> readUnitNames() async {
    String url = 'https://ptnpharma.com/jsonData/unit.json';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result is List) {
        Map<String, String> map = {};
        for (var itemMap in result) {
          String? unitId = itemMap['unit_id'];
          String? unitName = itemMap['unit_name'];
          if (unitId != null && unitName != null) map[unitId] = unitName;
        }
        if (mounted) {
          setState(() {
            unitNameMap = map;
          });
        }
      }
    } catch (e) {
      print('readUnitNames error: $e');
    }
  }

  String formatNum(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  /// จำนวนชุดที่เข้าเงื่อนไข tier นี้ คำนวนจากจำนวน/มูลค่าในตะกร้า หาร qty ของ tier
  double setsFor(double cartAmount, MedicinePromotionTier tier) {
    double tierQty = double.tryParse(tier.qty ?? '') ?? 0;
    if (tierQty <= 0) return 0;
    return (cartAmount / tierQty).floorToDouble();
  }

  ReceivedGiftItem? buildReceivedGift(
      String sourceLabel, double cartAmount, MedicinePromotionTier tier) {
    double sets = setsFor(cartAmount, tier);
    if (sets <= 0) return null;

    double perSet = double.tryParse(tier.getqty ?? '') ?? 0;
    double rawTotal = sets * perSet;
    double? limit = double.tryParse(tier.limitgift ?? '');
    double total =
        (limit != null && limit > 0 && rawTotal > limit) ? limit : rawTotal;

    return ReceivedGiftItem(
      sourceLabel: sourceLabel,
      gift: giftMap[tier.gift],
      sets: formatNum(sets),
      perSetQty: formatNum(perSet),
      totalQty: formatNum(total),
    );
  }

  /// โปรโมชันที่ยังไม่ถึงเงื่อนไข tier ถัดไป แต่มีความคืบหน้า >= 50%
  NearMissPromotion? buildNearMiss({
    required String sourceLabel,
    required double cartAmount,
    required MedicinePromotionTier tier,
    required String remainingUnit,
    String? productId,
    PromotionGroupModel? group,
  }) {
    double tierQty = double.tryParse(tier.qty ?? '') ?? 0;
    if (tierQty <= 0) return null;

    double progress = cartAmount / tierQty;
    if (progress < 0.5 || progress >= 1.0) return null;

    double remaining = (tierQty - cartAmount).ceilToDouble();
    GiftModel? gift = giftMap[tier.gift];

    return NearMissPromotion(
      sourceLabel: sourceLabel,
      remaining: formatNum(remaining),
      remainingUnit: remainingUnit,
      gift: gift,
      giftQty: formatNum(double.tryParse(tier.getqty ?? '') ?? 0),
      giftUnit: unitNameMap[gift?.unit] ?? '',
      progress: progress,
      productId: productId,
      group: group,
    );
  }

  void computeReceivedGifts() {
    List<ReceivedGiftItem> productGifts = [];
    List<NearMissPromotion> nearMiss = [];
    for (MedicinePromotionModel promo in medicinePromotions) {
      String key = '${promo.id}_${promo.size}';
      double cartQty = cartQtyBySizeKey[key] ?? 0;

      MedicinePromotionTier? tier = promo.bestTierFor(cartQty);
      if (tier != null) {
        ReceivedGiftItem? item =
            buildReceivedGift(promo.name ?? '', cartQty, tier);
        if (item != null) productGifts.add(item);
      }

      MedicinePromotionTier? next = promo.nextTierFor(cartQty);
      if (next != null) {
        NearMissPromotion? item = buildNearMiss(
          sourceLabel: promo.name ?? '',
          cartAmount: cartQty,
          tier: next,
          remainingUnit: cartLabelBySizeKey[key] ?? '',
          productId: promo.id,
        );
        if (item != null) nearMiss.add(item);
      }
    }

    List<ReceivedGiftItem> groupGifts = [];
    for (PromotionGroupModel group in promotionGroupModels) {
      double subtotal = 0;
      for (String idStr in group.medIds) {
        int? id = int.tryParse(idStr);
        if (id == null) continue;
        subtotal += cartValueByProduct[id] ?? 0;
      }

      MedicinePromotionTier? tier = group.bestTierFor(subtotal);
      if (tier != null) {
        ReceivedGiftItem? item =
            buildReceivedGift(group.name ?? '', subtotal, tier);
        if (item != null) groupGifts.add(item);
      }

      MedicinePromotionTier? next = group.nextTierFor(subtotal);
      if (next != null) {
        NearMissPromotion? item = buildNearMiss(
          sourceLabel: group.name ?? '',
          cartAmount: subtotal,
          tier: next,
          remainingUnit: 'บาท',
          group: group,
        );
        if (item != null) nearMiss.add(item);
      }
    }

    if (mounted) {
      setState(() {
        productGiftsReceived = productGifts;
        groupGiftsReceived = groupGifts;
        nearMissPromotions = nearMiss;
      });
    }
  }

  Future<void> readReward() async {
    String? memberId = myUserModel!.id;
    String? memberCode = myUserModel!.customerCode;
    String? url =
        '${MyStyle().serverName}/apishop/json_loadmyreward.php?memberId=$memberId&memberCode=$memberCode'; // ?memberId=$memberId
    print('urlReward >> $url');

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemNews =
        result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    print('Start setState readReward');

    for (var map in mapItemNews) {
      RewardredeemModel? rewardModel = RewardredeemModel.fromJson(map);

      setState(() {
        rewardredeemModels!.add(rewardModel);
      });
    }
  }

  void clearArray() {
    total = 0;
    productAllModels?.clear();
    priceListSModels?.clear();
    priceListMModels?.clear();
    priceListLModels?.clear();
    sMap?.clear();
    mMap?.clear();
    lMap?.clear();
    cartQtyBySizeKey.clear();
    cartLabelBySizeKey.clear();
    cartValueByProduct.clear();
  }

  Widget showCart() {
    return Container(
      margin: EdgeInsets.only(top: 5.0, right: 5.0),
      width: 32.0,
      height: 32.0,
      child: Stack(
        children: <Widget>[
          Image.asset('images/shopping_cart.png'),
          Text(
            ' $amontCart \u{2605}',
            style: TextStyle(
              backgroundColor: Colors.red.shade600,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget showTitle(int index) {
    print('Here is showTitle');
    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 10.0),
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: Text(
              productAllModels![index].title!,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
              ),
              // style: MyStyle().h2Style,
            ),
          ),
        ],
      ),
    );
  }

  Widget showHilight(int index) {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 16.00),
          width: MediaQuery.of(context).size.width * 0.75,
          child: Text(productAllModels![index].hilight!,
              style: MyStyle().h3StyleRed),
        ),
      ],
    );
  }

  Widget editButton(int index, String size) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        myAlertDialog(index, size);
      },
    );
  }

  Widget alertTitle() {
    return ListTile(
      leading: Icon(Icons.edit, size: 36.0),
      title: Text('แก้ไขจำนวน'),
    );
  }

  Widget alertContent(int index, String size) {
    double quantity = 0;
    String unitText = '';
    if (size == 's') {
      quantity = double.parse(priceListSModels![index].quantity!);
      newQTYS = (quantity).toDouble();
      unitText = priceListSModels![index].lable!;
    } else if (size == 'm') {
      quantity = double.parse(priceListMModels![index].quantity!);
      newQTYM = (quantity).toDouble();
      unitText = priceListMModels![index].lable!;
    } else if (size == 'l') {
      quantity = double.parse(priceListLModels![index].quantity!);
      newQTYL = (quantity).toDouble();
      unitText = priceListLModels![index].lable!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(productAllModels![index].title!),
        Text('Size = $unitText'),
        Container(
          // width: 50.0,
          child: editQTY(quantity),
        ),
      ],
    );
  }

  Widget decButton() {
    return IconButton(
      icon: Icon(Icons.remove_circle_outline),
      onPressed: () {},
    );
  }

  Widget incButton() {
    return IconButton(icon: Icon(Icons.add_circle_outline), onPressed: () {});
  }

  Widget showValue(int value) {
    return Text('$value');
  }

  Widget editQTY(double quantity) {
    int? limitValue = 0;
    if (index == 0) {
      limitValue = productAllModel!.limitS;
    } else if (index == 1) {
      limitValue = productAllModel!.limitM;
    } else if (index == 2) {
      limitValue = productAllModel!.limitL;
    }

    // return TextFormField(
    //   keyboardType: TextInputType.number,
    //   onChanged: (String string) {
    //     newQTY = string.trim();
    //   },
    //   initialValue: quantity,
    // );
    return SpinBox(
      value: (quantity).toDouble(),
      min: 1,
      max: (limitValue==0)?10000:limitValue!.toDouble(),  //10000,// 
      onChanged: (changevalue) {
        newQTY = (changevalue == 0) ? 0 : (changevalue).toDouble();

        // if (index == 0) {
        //   setState(() {
        //     qtyS = (changevalue == 0) ? 0 : (changevalue).toInt();
        //   });
        // } else if (index == 1) {
        //   setState(() {
        //     qtyM = (changevalue == 0) ? 0 : (changevalue).toInt();
        //   });
        // } else if (index == 2) {
        //   setState(() {
        //     qtyL = (changevalue == 0) ? 0 : (changevalue).toInt();
        //   });
        // }
      },
      // decoration: InputDecoration(labelText: 'Decimals'),
      decoration: InputDecoration(
        border: UnderlineInputBorder(), // InputBorder.none,
      ),
    );
  }

  Widget changeQTY(String productID, String size, double quantity, double limitorder) {

    double? limitValue = limitorder;
    // if (size =='s') {
    //   limitValue = productAllModel!.limitS!.toDouble();
    // } else if (size =='m') {
    //   limitValue = productAllModel!.limitM!.toDouble();
    // } else if (size =='l') {
    //   limitValue = productAllModel!.limitL!.toDouble();
    // }

    print('size -> $size -> $limitValue');
    String? memberID = myUserModel!.id.toString();
    return SizedBox(
      width: 140.0,
      child: SpinBox(
        decoration: InputDecoration(
          border: UnderlineInputBorder(), // InputBorder.none,
        ),
        value: (quantity).toDouble(),
        min: 1,
        max: (limitValue==0)?10000:limitValue.toDouble(),  //10000,// 
        onChanged: (changevalue) {
          newQTY = (changevalue == 0) ? 0 : (changevalue).toDouble();
          print(
            'productID = $productID ,unitSize = $size ,memberID = $memberID, newQTY = $newQTY',
          );
          updateDetailCart(productID, size, memberID);
        },
      ),
    );
  }

  void myAlertDialog(int index, String size) {
    showDialog(
      context: context,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: alertTitle(),
          content: alertContent(index, size),
          actions: <Widget>[cancelButton(), okButton(index, size)],
        );
      },
    );
  }

  Widget okButton(int index, String size) {
    String? productID = productAllModels![index].id.toString();
    String? unitSize = size;
    String? memberID = myUserModel!.id.toString();

    return TextButton(
      child: Text('OK'),
      onPressed: () {
        print(
          'productID = $productID ,unitSize = $unitSize ,memberID = $memberID, newQTY = $newQTY',
        );
        editDetailCart(productID, unitSize, memberID);
        Navigator.of(context).pop();
      },
    );
  }

  // Post ค่าไปยัง API ที่ต้องการ
  Future<void> editDetailCart(
    String productID,
    String unitSize,
    String memberID,
  ) async {
    String url =
        '${MyStyle().serverName}/apishop/json_updatemycart.php?productID=$productID&unitSize=$unitSize&newQTY=$newQTY&memberId=$memberID';

    print('url editDetailCart ====>>>>> $url');

    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        readCart();
      });
    });
  }

  Future<void> updateDetailCart(
    String productID,
    String unitSize,
    String memberID,
  ) async {
    String url =
        '${MyStyle().serverName}/apishop/json_updatemycart.php?productID=$productID&unitSize=$unitSize&newQTY=$newQTY&memberId=$memberID';
    print('url editDetailCart ====>>>>> $url');
    await http.get(Uri.parse(url)).then((response) {});

    double totalPrice = 0;
    List<dynamic>? arrIncartS = [];
    List<dynamic>? arrIncartM = [];
    List<dynamic>? arrIncartL = [];
    clearArray();
    readCart();
    setState(() {
      productAllModels!.add(productAllModel!);
      allArrIncartS = arrIncartS;
      allArrIncartM = arrIncartM;
      allArrIncartL = arrIncartL;
      amontCart = amontCart! + 1;
      total = totalPrice;
      showTotal();
    });
  }

  Widget cancelButton() {
    return TextButton(
      child: Text('Cancel'),
      onPressed: () {
       // Navigator.of(context).pop();
       Navigator.pop(context);
      },
    );
  }

  Widget deleteButton(int index, String size) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        confirmDelete(index, size);
      },
    );
  }

  void confirmDelete(int index, String size) {
    String titleProduct = productAllModels![index].title!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ลบสินค้าออกจากตะกร้า'),
          content: Text('ต้องการลบรายการออกจากตะกร้า : $titleProduct'),
          actions: <Widget>[cancelButton(), comfirmButton(index, size)],
        );
      },
    );
  }

  Widget comfirmButton(int index, String size) {
    return TextButton(
      child: Text('Confirm'),
      onPressed: () {
        deleteCart(index, size);
       // Navigator.of(context).pop();
       Navigator.pop(context);
      },
    );
  }

  Future<void> deleteCart(int index, String size) async {
    String productID = productAllModels![index].id.toString();
    String unitSize = size;
    String memberID = myUserModel!.id.toString();

    print('productID = $productID ,unitSize = $unitSize ,memberID = $memberID');

    String url =
        '${MyStyle().serverName}/apishop/json_removeitemincart.php?productID=$productID&unitSize=$unitSize&memberId=$memberID';
    print('url DeleteCart======>>>> $url');

    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        print('amontCart after remove item>> $amontCart');
        readCart();
      });
    });
  }

  Widget editAndDeleteButton(int index, String size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[editButton(index, size), deleteButton(index, size)],
    );
  }

  void calculateTotal(String price, String quantity) {
    double? priceDou = double.parse(price);
    print('price Dou ====>>>> $priceDou');
    quantity = quantity.replaceAll(',', '');
    double? quantityDou = double.parse(quantity);
    print('quantityDou ====>> $quantityDou');
    total = total! + (priceDou * quantityDou);
    print('total = $total');
  }

  Widget showSText(int proIndex, int index) {
    // print('unit >' + sMap?[index]['unit']);
    // if (sMap?[index]['unit']) {
    String? productID = productAllModels![proIndex].id.toString();
    print('Here is showSText ($productID) ($index)');
    print('Here is showSText 1.1');
    String? priceS = sMap?[index]['price']?.toString();
    print('Here is showSText 1.2');
    String? lableS = sMap?[index]['lable'];
    print('Here is showSText 1.3');
    String? quantityS = sMap?[index]['quantity'];
    print('Here is showSText 1.4');
    String? pricechange = sMap?[index]['pricechange']?.toString();
    // String? txtpricechange = (sMap![index]['pricechange'].toString() != '');
    print('Here is showSText 2');

    double? showQTYS =
        (quantityS == null) ? 0.0 : double.parse(quantityS.replaceAll(',', ''));

    double? limitS = double.parse(sMap?[index]['limitorder']);
    double? showlimitS = (limitS == null) ? 0.0 : limitS;

    print('Here is showSText 3');

    print('$productID > $priceS > $lableS > $quantityS > $pricechange');

    return lableS!.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              (pricechange != '-')
                  ? Column(
                      children: [
                        Text('$priceS บาท/ $lableS', style: MyStyle().h3Style),
                        // (pricechange != '-')?
                        (pricechange != '-')
                            ? Text(
                                'ปรับราคา ' + pricechange! + ' บาท',
                                style: (double.parse(pricechange) > 0)
                                    ? MyStyle().h5StyleRed
                                    : MyStyle().h5StyleBlue,
                              )
                            : Container(),
                        // : '',
                      ],
                    )
                  : Text('$priceS บาท/ $lableS', style: MyStyle().h3Style),
              changeQTY(productID, 's', showQTYS, showlimitS),
              deleteButton(proIndex, 's'),
            ],
          );
    // }
  }

  Widget showMText(int proIndex, int index) {
    String? productID = productAllModels![proIndex].id.toString();
    print('Here is showMText ($productID) ($index)');
    print('Here is showMText 1.1');
    String? priceM = mMap?[index]['price']?.toString();
    print('Here is showMText 1.2');
    String? lableM = mMap?[index]['lable'];
    print('Here is showMText 1.3');
    String? quantityM = mMap?[index]['quantity'];
    print('Here is showMText 1.4');
    String? pricechange = mMap?[index]['pricechange']?.toString();
    print('Here is showMText 2');

    double? showQTYM =
        (quantityM == null) ? 0.0 : double.parse(quantityM.replaceAll(',', ''));

    double? limitM = double.parse(mMap?[index]['limitorder']);
    double? showlimitM = (limitM == null) ? 0.0 : limitM;


    print('Here is showMText 3');

    print('$productID > $priceM > $lableM > $quantityM > $pricechange');

    return lableM!.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              (pricechange != '-')
                  ? Column(
                      children: [
                        Text('$priceM บาท/ $lableM', style: MyStyle().h3Style),
                        // (pricechange != '-')?
                        (pricechange != '-')
                            ? Text(
                                'ปรับราคา ' + pricechange! + ' บาท',
                                style: (double.parse(pricechange) > 0)
                                    ? MyStyle().h5StyleRed
                                    : MyStyle().h5StyleBlue,
                              )
                            : Container(),
                        // : '',
                      ],
                    )
                  : Text('$priceM บาท/ $lableM', style: MyStyle().h3Style),
              changeQTY(productID, 'm', showQTYM,showlimitM),
              deleteButton(proIndex, 'm'),
            ],
          );
  }

  Widget showLText(int proIndex, int index) {
    String? productID = productAllModels![proIndex].id.toString();
    print('Here is showLText ($productID) ($index)');
    String? priceL = lMap?[index]['price']?.toString();
    String? lableL = lMap?[index]['lable'];
    String? quantityL = lMap?[index]['quantity'];
    String? pricechange = lMap?[index]['pricechange']?.toString();
    print('Here is showLText 2');

    double? showQTYL =
        (quantityL == null) ? 0.0 : double.parse(quantityL.replaceAll(',', ''));
            print('showQTYL->$showQTYL ');

    double? limitL = double.parse(lMap?[index]['limitorder']);
    double? showlimitL = (limitL == null) ? 0.0 : limitL;

    print('showQTYL->$showQTYL | limitL->$limitL  | showlimitL->$showlimitL ');

    return lableL!.isEmpty
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              (pricechange != '-')
                  ? Column(
                      children: [
                        Text('$priceL บาท/ $lableL', style: MyStyle().h3Style),
                        // (pricechange != '-') ?
                        (pricechange != '-')
                            ? Text(
                                'ปรับราคา ' + pricechange! + ' บาท',
                                style: (double.parse(pricechange) > 0)
                                    ? MyStyle().h5StyleRed
                                    : MyStyle().h5StyleBlue,
                              )
                            : Container(),
                        // : '',
                      ],
                    )
                  : Text('$priceL บาท/ $lableL', style: MyStyle().h3Style),
              changeQTY(productID, 'l', showQTYL,showlimitL),
              deleteButton(proIndex, 'l'),
            ],
          );
  }

  Widget showListCart() {
    print('allArrIncartS >> $allArrIncartS');
    print('allArrIncartM >> $allArrIncartM');
    print('allArrIncartL >> $allArrIncartL');


    var iS = 0;
    var iM = 0;
    var iL = 0;
    return ListView.builder(
      padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
      physics: ScrollPhysics(),
      shrinkWrap: true,
      itemCount: productAllModels?.length,
      itemBuilder: (BuildContext buildContext, int index) {
        int? proID = productAllModels![index].id;
        // print('proID >> $proID');

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: BorderSide(width: 2, color: Colors.grey.shade200),
          ),
          child: Container(
            padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
            child: Column(
              children: <Widget>[
                showTitle(index),
                (productAllModels![index].hilight! == '')
                    ? Container()
                    : showHilight(index),
                (allArrIncartS!.contains(proID))
                    ? showSText(index, iS++)
                    : Container(),
                (allArrIncartM!.contains(proID))
                    ? showMText(index, iM++)
                    : Container(),
                (allArrIncartL!.contains(proID))
                    ? showLText(index, iL++)
                    : Container(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget showTotal() {
    return Card(
      child: Center(
        child: Container(
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          child: Text('ยอดรวม        $total บาท', style: MyStyle().h1Style),
        ),
      ),
    );
  }

  bool isFreeGift(RewardredeemModel reward) {
    String? point = reward.point;
    return point == null || point.isEmpty || point == '0';
  }

  Widget rewardTypeBadge(bool isFree) {
    Color color = isFree ? Colors.green : Colors.blue;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        isFree ? 'ของแถม' : 'แลกคะแนน',
        style: TextStyle(
            color: color, fontSize: 12.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget rewardItemTile(RewardredeemModel reward) {
    bool isFree = isFreeGift(reward);
    Color color = isFree ? Colors.green : Colors.blue;

    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(isFree ? Icons.card_giftcard : Icons.workspace_premium,
                color: color, size: 32.0),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: <Widget>[
                      Text(reward.rwSubject ?? '', style: MyStyle().h4bStyleGray),
                      rewardTypeBadge(isFree),
                    ],
                  ),
                  // Text(reward.rwCode ?? '',
                  //     style: TextStyle(fontSize: 12.0, color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(
              width: 40.0,
              child: Text(
                isFree ? 'ฟรี' : 'ได้รับ',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isFree ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 30.0,
              child: Text(reward.qty ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              width: 40.0,
              child: Text(reward.unit ?? '',
                  textAlign: TextAlign.center, style: MyStyle().h4StyleGray),
            ),

          ],
        ),
      ),
    );
  }

  Widget showReward() {
    return Card(
      child: Container(
        padding: EdgeInsets.only(
          top: 5.0,
          bottom: 5.0,
          left: 10.0,
          right: 10.0,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'ของสมนาคุณที่เลือก',
                style: MyStyle().h3bStyleGray,
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: 5.0,
                bottom: 5.0,
                left: 10.0,
                right: 10.0,
              ),
              child: ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: rewardredeemModels?.length,
                itemBuilder: (BuildContext buildContext, int index) {
                  return rewardItemTile(rewardredeemModels![index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void selectedTransport(String string) {
    transport = string;
    print('Transport ==> $transport');
    setState(() {
      selectedTranindex = int.parse(string);
    });
  }

  Widget showTitleTransport() {
    return Text(
      'การจัดส่ง :' + listTransport![selectedTranindex!.toInt()], // ,
      style: TextStyle(
          fontSize: 18.0,
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold),
    );
  }

  Widget showTransport() {
    return Container(
      width: 500.0,
      padding: EdgeInsets.all(
          10.0), // EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
      child: Card(
        child: Container(
          // color: Colors.blue,
          padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 5.0),
          child: PopupMenuButton<String>(
            onSelected: (String string) {
              selectedTransport(string);
            },
            child: showTitleTransport(),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: new Container(
                    width: 500.0,
                    child: Text(
                      listTransport![1],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                  value: '1',
                ),
                PopupMenuItem(
                  child: new Container(
                    width: 500.0,
                    child: Text(
                      listTransport![2],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                  value: '2',
                ),
                PopupMenuItem(
                  child: new Container(
                    width: 500.0,
                    child: Text(
                      listTransport![3],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                  value: '3',
                ),
                PopupMenuItem(
                  child: new Container(
                    width: 500.0,
                    child: Text(
                      listTransport![4],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                  value: '4',
                ),
                PopupMenuItem(
                  child: new Container(
                    width: 500.0,
                    child: Text(
                      listTransport![5],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                  value: '5',
                ),
              ];
            },
          ),
        ),
      ),
    );
  }

  Widget commentBox() {
    return Container(
      padding: EdgeInsets.only(bottom: 20.0),
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        onChanged: (value) {
          comment = value.trim();
        },
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        decoration: InputDecoration(labelText: 'Comment :'),
      ),
    );
  }

  Widget promotionAlert(String msg) {
    return Container(
          // padding: EdgeInsets.only(top: 50.0),
          // width: MediaQuery.of(context).size.width * 0.75,
          child: BubbleSpecialOne(
            text: msg,  // myUserModel!.promotionalert!
            isSender: true,
            color: Color.fromARGB(255, 254, 255, 175),
            tail: true,
            textStyle: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 223, 5, 5)),
          ),
        );
  }

  Widget nearMissBanner(NearMissPromotion item) {
    String giftName = item.gift?.name ?? 'ของแถม';
    String message = 'ใกล้ได้ของแถมแล้ว! เพิ่มอีก ${item.remaining} ${item.remainingUnit} '
        'ของ "${item.sourceLabel}" เพื่อรับ $giftName ${item.giftQty} ${item.giftUnit} ฟรี';

    double clampedProgress = item.progress.clamp(0.0, 1.0);
    int percent = (clampedProgress * 100).round();

    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Color(0xFFFFE8A3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 32.0,
                height: 32.0,
                decoration:
                    BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                child: Icon(Icons.campaign, color: Colors.white, size: 18.0),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: Text(message,
                    style:
                        TextStyle(fontSize: 12.5, color: Colors.grey.shade800)),
              ),
              SizedBox(width: 8.0),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: MyStyle().mainColor,
                  side: BorderSide(color: MyStyle().mainColor),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                onPressed: () {
                  if (item.group != null) {
                    routeToGroupProducts(item.group!);
                  } else {
                    routeToPromoProduct(item.productId);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('ดูเพิ่มเติม',
                        style: TextStyle(
                            fontSize: 12.0, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4.0),
                    Icon(Icons.arrow_forward, size: 14.0),
                  ],
                ),
              ),
            ],
          ),
          // SizedBox(height: 8.0),
          // Row(
          //   children: <Widget>[
          //     Expanded(
          //       child: ClipRRect(
          //         borderRadius: BorderRadius.circular(4.0),
          //         child: LinearProgressIndicator(
          //           value: clampedProgress,
          //           minHeight: 6.0,
          //           backgroundColor: Color(0xFFFFE8A3),
          //           valueColor:
          //               AlwaysStoppedAnimation<Color>(Colors.orange),
          //         ),
          //       ),
          //     ),
          //     SizedBox(width: 8.0),
          //     Text('$percent%',
          //         style: TextStyle(
          //             fontSize: 11.0,
          //             fontWeight: FontWeight.bold,
          //             color: Colors.orange.shade800)),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget nearMissSection() {
    if (nearMissPromotions.isEmpty) return Container();
    return Column(children: nearMissPromotions.map(nearMissBanner).toList());
  }

  Widget receivedGiftTile(ReceivedGiftItem item) {
    String unitName = unitNameMap[item.gift?.unit] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.card_giftcard, color: Colors.green, size: 32.0),
            SizedBox(width: 10.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: <Widget>[
                      Text(item.gift?.name ?? 'ของแถม', style: MyStyle().h4bStyleGray),
                      rewardTypeBadge(true),
                    ],
                  ),
                  SizedBox(height: 2.0),
                  Text('จาก "${item.sourceLabel}"',
                      style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(width: 8.0),
            Text(
              'ฟรี',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('${item.sets} ชุด',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (unitName.isNotEmpty)
                  Text('${item.perSetQty} $unitName/ชุด',
                      style: TextStyle(fontSize: 10.0, color: Colors.grey)),
              ],
            ),
            SizedBox(width: 10.0),
            Text('${item.totalQty} $unitName',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget promotionSuccess() {
    List<ReceivedGiftItem> giftItems = [
      ...productGiftsReceived,
      ...groupGiftsReceived,
    ];

    return Card(
      child: Container(
        padding: EdgeInsets.only(
          top: 5.0,
          bottom: 5.0,
          left: 10.0,
          right: 10.0,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'รายการพิเศษที่ได้รับ',
                style: MyStyle().h3bStyleGray,
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 6.0),
            ...giftItems.map(receivedGiftTile),
          ],
        ),
      ),
    );
  }

  Widget submitButton() {
    // String? creditterm = myUserModel!.credittermAlert;
    // String? financialamount = myUserModel!.financialamountAlert;
    // String? promotionalert = myUserModel!.promotionalert;
    // String? promotionsuccess = myUserModel!.promotionsuccess;

    print('CREDIT CHECK > $creditterm + $financialamount + $contactAdmin');
    print('promotionalert > $promotionalert');
    print('promotionsuccess > $promotionsuccess');
    print('transport = $transport, comment = $comment, memberId = $memberID');
    print(creditterm.toString() +'-'+  financialamount.toString()  +'-'+ contactAdmin.toString());
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Column(
            children: [
              (promotionalert != '-') ? promotionAlert(promotionalert!):Container(),
            ],
          )
        ),
        Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(right: 30.0),
          child: ElevatedButton(
            // color: MyStyle().textColor,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontStyle: FontStyle.normal,
              ),
            ),
            onPressed: _isPressed == false
                ? () {
                    setState(() {
                      print('amontCart submit >> $amontCart');
                      if (amontCart == 0) {
                        // normalDialog(
                        //   context,
                        //   'ไม่มีสินค้าในตะกร้า',
                        //   'กรุณา เลือกสินค้า ด้วยค่ะ',
                        // );
                        // null;
                              AwesomeDialog(
                                context: context,
                                headerAnimationLoop: false,
                                dialogType: DialogType.warning,
                                autoHide: const Duration(seconds: 5),
                                title: 'ไม่มีสินค้าในตะกร้า',
                                desc: 'กรุณา เลือกสินค้า ด้วยค่ะ ',
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
                        if (transport == null) {
                          // normalDialog(
                          //   context,
                          //   'ยังไม่เลือก  การจัดส่ง',
                          //   'กรุณา เลือกการจัดส่ง ด้วยค่ะ',
                          // );
                           AwesomeDialog(
                                context: context,
                                headerAnimationLoop: false,
                                dialogType: DialogType.warning,
                                autoHide: const Duration(seconds: 5),
                                title: 'ท่านยังไม่เลือก  การจัดส่ง',
                                desc: 'กรุณา เลือกการจัดส่ง ด้วยค่ะ ',
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
                        }else
                        if (creditterm !='-' || financialamount !='-' || contactAdmin !='-') {
                           var txtCreditTitle =  '';
                            if(creditterm !='-' )
                              txtCreditTitle =  'ท่านมียอดค้างชำระเกินกำหนด';
                            else if(financialamount !='-' )
                              txtCreditTitle =  'ท่านมียอดค้างชำระเกินวงเงินที่กำหนด';
                            else if(contactAdmin !='-' )
                              txtCreditTitle =  'กรุณาติดต่อผู้ดูแลระบบ';

                           AwesomeDialog(
                                context: context,
                                headerAnimationLoop: false,
                                dialogType: DialogType.warning,
                                autoHide: const Duration(seconds: 5),
                                title:  txtCreditTitle,
                                desc: 'กรุณาชำระรายการหรือติดต่อเจ้าหน้าที่ ',
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
                          _isPressed = true;
                          memberID = myUserModel!.id.toString();
                          print(
                            'Submit >> transport = $transport, comment = $comment, memberId = $memberID, promotionsuccess = $promotionsuccess',
                          );
                          print('promotionsuccessgift = $promotionsuccessgift');
                          submitThread();
                        }
                      }
                    });
                  }
                : null,
            child: Text('สั่งซื้อ', style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(width: 10.0, height: (myUserModel!.msg == '') ? 0 : 90.0),
      ],
    );
  }

  Future<void> submitThread() async {
    try {
      String url =
          '${MyStyle().serverName}/apishop/json_submit_myorder20022026.php?memberId=$memberID&transport=$transport&comment=$comment';
      print('url ==> $url');

      // await http.get(Uri.parse(url)).then((value) {
      //   // confirmSubmit();
      //   routeToHome();
      // });

    await http.post(Uri.parse(url), body: {
      'memberId': memberID,
      'transport': transport,
      'comment': comment,
      'promotionsuccess': promotionsuccess,
      'promotionsuccessgift': promotionsuccessgift,
    }).then((value) {
      routeToHome();
    });


    } catch (e) {}
  }

  Future<void> confirmSubmit() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Complete'),
          content: Text('การสั่งซื้อเรียบร้อย'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                backProcess();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void backProcess() {
    Navigator.of(context).pop();
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProduct(index: index, userModel: myUserModel!);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToPromoProduct(String? productId) {
    int? id = int.tryParse(productId ?? '');
    if (id == null) return;

    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return Detail(
          userModel: myUserModel,
          productAllModel: ProductAllModel(id: id),
        );
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToGroupProducts(PromotionGroupModel group) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProductPromotion(
        index: 6,
        userModel: myUserModel!,
        cateName: group.name,
        promotionGroupId: group.id,
        );
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProductfav(index: index, userModel: myUserModel!);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToHome() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return MyService(
          userModel: myUserModel!,
          firstLoadAds: false,
          orderSuccess: true,
        );
      },
    );
    Navigator.of(context).push(materialPageRoute);
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
    String? strcountpricechange = countpricechange.toString();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: MyStyle().bgColor,
        title: Text('ตะกร้าสินค้า', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: nearMissSection(),
          ),
          showTotal(),
          showListCart(),
          showTotal(),
          (productGiftsReceived.isNotEmpty || groupGiftsReceived.isNotEmpty)
              ? promotionSuccess()
              : Container(),
          (rewardredeemModels!.length != 0) ? showReward() : Container(),
          showTransport(),
          commentBox(),
          (countpricechange != 0)
              ? Text(
                  'มีสินค้าราคาเปลี่ยนแปลง $strcountpricechange รายการกรุณาตรวจสอบก่อนทำรายการ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: const Color.fromARGB(255, 228, 30, 30),
                  ),
                )
              : Container(),
          submitButton(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }
}
