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
import 'package:ptncenter/models/reward_extrapoint_model.dart';
import 'package:ptncenter/models/near_miss_promotion.dart';
import 'package:ptncenter/models/received_gift_item.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/scaffold/detail.dart'
    hide NearMissPromotion, ReceivedGiftItem;
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_promotion.dart'
    hide NearMissPromotion, ReceivedGiftItem;
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:ptncenter/widget/detail_cart_near_miss_section.dart';
import 'package:ptncenter/widget/detail_cart_reward_section.dart';
import 'package:ptncenter/widget/detail_cart_list_section.dart';
// import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'my_service.dart';
// import 'package:scan_preview/scan_preview_widget.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
       

class DetailCart extends StatefulWidget {
  final UserModel? userModel;
  const DetailCart({super.key, this.userModel});

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
  double? total = 0;
  String? transport;
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
  List<PromotionGroupModel> inhousePromotions = [];
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
  List<ReceivedGiftItem> inhouseGiftsReceived = [];
  List<NearMissPromotion> nearMissPromotions = [];

  List<RewardExtrapointModel> rewardExtrapoints = [];

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
    readInhousePromotions();
    readGiftItems();
    readUnitNames();
    readRewardExtrapoints();
  }

  // void _myCallback() {
  //   setState(() {
  //     _isPressed = true;
  //   });
  // }

  Future<void> readCart() async {
    String? memberId = myUserModel!.id.toString();
    String? url = '${MyStyle().loadMyCart}$memberId&screen=cart';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];

    // เคลียร์หลัง await (ไม่ใช่ก่อนเรียก) เพื่อกัน race condition เวลา readCart() ถูกเรียกซ้อนกัน
    // (เช่น แก้ไข/ลบสินค้าติดกันเร็วๆ) ไม่งั้นการเรียกครั้งหลังจะ "บวกเพิ่ม" บนข้อมูลของครั้งก่อน
    // ที่เพิ่ง populate ไป (cartQtyBySizeKey/cartValueByProduct สะสมค่าด้วย +=) ทำให้จำนวนเพี้ยน
    // เกินทุก tier จน nextTierFor() คืน null และ nearMissSection() หายไปเป็นบางครั้ง
    clearArray();

    // List<Map<bool, dynamic>> arrIncart = [];
    List<dynamic>? arrIncartS = [];
    List<dynamic>? arrIncartM = [];
    List<dynamic>? arrIncartL = [];


    for (var map in cartList) {
     ProductAllModel2 productAllModel = ProductAllModel2.fromJson(map);
      // print('productAllModel = ${productAllModel.toJson().toString()}');

      setState(() {
        Map<String, dynamic> priceListMap = map['price_list'];
        int? productID = productAllModel.id;


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

      });
    }

    setState(() {
      Map<String, dynamic>? dataList = result['data'];
      countpricechange = dataList?['countpricechange'];
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
    } catch (e) {} // ignore: empty_catches
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
    } catch (e) {} // ignore: empty_catches
  }

  Future<void> readInhousePromotions() async {
    String url = 'https://ptnpharma.com/jsonData/inhousepromotion.json';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result is List) {
        inhousePromotions =
            result.map((map) => PromotionGroupModel.fromJson(map)).toList();
        computeReceivedGifts();
      }
    } catch (e) {} // ignore: empty_catches
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
    } catch (e) {} // ignore: empty_catches
  }

  Future<void> readRewardExtrapoints() async {
    String url = 'https://ptnpharma.com/jsonData/reward_extrapoint.json';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result is List) {
        List<RewardExtrapointModel> rules = result
            .map((map) => RewardExtrapointModel.fromJson(map))
            .toList();
        if (mounted) {
          setState(() {
            rewardExtrapoints = rules;
          });
        }
      }
    } catch (e) {} // ignore: empty_catches
  }

  /// จำนวนคะแนนพิเศษที่สินค้าชิ้นนี้เข้าเงื่อนไข (รวมทุกขนาดบรรจุที่เข้าเงื่อนไข)
  double extraPointsForProduct(int? productId) {
    if (productId == null) return 0;
    double total = 0;
    for (RewardExtrapointModel rule in rewardExtrapoints) {
      if (rule.medId != productId.toString()) continue;
      double neededQty = double.tryParse(rule.qty ?? '') ?? 0;
      if (neededQty <= 0) continue;

      double cartQty = cartQtyBySizeKey['${productId}_${rule.size}'] ?? 0;
      double sets = (cartQty / neededQty).floorToDouble();
      if (sets > 0) {
        total += sets * (double.tryParse(rule.point ?? '') ?? 0);
      }
    }
    return total;
  }

  double totalExtraPoints() {
    double total = 0;
    for (ProductAllModel2 p in productAllModels ?? []) {
      total += extraPointsForProduct(p.id);
    }
    return total;
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
    } catch (e) {} // ignore: empty_catches
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
      String sourceLabel, double cartAmount, MedicinePromotionTier tier,
      {bool isInhouse = false}) {
    double sets = setsFor(cartAmount, tier);
    if (sets <= 0) return null;

    double perSet = double.tryParse(tier.getqty ?? '') ?? 0;
    double rawTotal = sets * perSet;
    double? limit = double.tryParse(tier.limitgift ?? '');
    double total =
        (limit != null && limit > 0 && rawTotal > limit) ? limit : rawTotal;

    // ระบุขั้นของโปรโมชันที่เข้าเงื่อนไข (ขั้นที่ 2, 3) ให้เห็นชัดเจนว่าได้ของแถมจาก tier ไหน
    // ไม่ต้องระบุขั้นที่ 1 เพราะเป็นขั้นพื้นฐานที่ไม่มีขั้นอื่นให้สับสน
    String levelSuffix =
        (tier.level != null && tier.level! > 1) ? ' (ขั้นที่ ${tier.level})' : '';

    return ReceivedGiftItem(
      sourceLabel: '$sourceLabel$levelSuffix',
      gift: giftMap[tier.gift],
      sets: formatNum(sets),
      perSetQty: formatNum(perSet),
      totalQty: formatNum(total),
      isInhouse: isInhouse,
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
    String? sizeLabel,
    double ownFactor = 1, // จำนวนตัดของไซส์ที่โปรโมชันกำหนด (promo.size)
    double referenceFactor = 1, // จำนวนตัดของไซส์ที่จะใช้แสดงผล (sizeLabel)
  }) {
    double tierQty = double.tryParse(tier.qty ?? '') ?? 0;
    if (tierQty <= 0) return null;

    double progress = cartAmount / tierQty;
    if (progress < 0.5 || progress >= 1.0) return null;

    // แปลงจำนวนที่ขาดจากหน่วยของ promo.size ให้เป็นหน่วยฐานก่อน (คูณ ownFactor)
    // แล้วแปลงเป็นหน่วยของไซส์ที่ลูกค้ากำลังสั่งจริง (หาร referenceFactor)
    double safeReferenceFactor = referenceFactor > 0 ? referenceFactor : 1;
    double remaining =
        ((tierQty - cartAmount) * ownFactor / safeReferenceFactor)
            .ceilToDouble();
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
      sizeLabel: sizeLabel,
      level: tier.level,
    );
  }

  void computeReceivedGifts() {
    List<ReceivedGiftItem> productGifts = [];
    List<NearMissPromotion> nearMiss = [];
    for (MedicinePromotionModel promo in medicinePromotions) {
      String key = '${promo.id}_${promo.size}';
      double qtyS = cartQtyBySizeKey['${promo.id}_s'] ?? 0;
      double qtyM = cartQtyBySizeKey['${promo.id}_m'] ?? 0;
      double qtyL = cartQtyBySizeKey['${promo.id}_l'] ?? 0;
      double cartQty =
          promo.equivalentQty(qtyS: qtyS, qtyM: qtyM, qtyL: qtyL);

      MedicinePromotionTier? tier = promo.bestTierFor(cartQty);
      if (tier != null) {
        ReceivedGiftItem? item =
            buildReceivedGift(promo.name ?? '', cartQty, tier);
        if (item != null) productGifts.add(item);
      }

      MedicinePromotionTier? next = promo.nextTierFor(cartQty);
      if (next != null) {
        // แสดงจำนวนที่ขาดเป็นหน่วยของไซส์ที่ลูกค้าสั่งอยู่จริง (ไซส์ที่มีจำนวนในตะกร้ามากสุด)
        // ไม่ใช่หน่วยของไซส์ที่โปรโมชันกำหนดไว้ (promo.size) เสมอไป
        String referenceSize = promo.size ?? '';
        double bestQty = 0;
        Map<String, double> qtyBySize = {'s': qtyS, 'm': qtyM, 'l': qtyL};
        qtyBySize.forEach((sizeKey, qty) {
          if (qty > bestQty) {
            bestQty = qty;
            referenceSize = sizeKey;
          }
        });

        double ownFactor = promo.subtractFactorFor(promo.size ?? '');
        double referenceFactor = promo.subtractFactorFor(referenceSize);

        NearMissPromotion? item = buildNearMiss(
          sourceLabel: promo.name ?? '',
          cartAmount: cartQty,
          tier: next,
          remainingUnit: cartLabelBySizeKey['${promo.id}_$referenceSize'] ??
              cartLabelBySizeKey[key] ??
              '',
          productId: promo.id,
          sizeLabel: referenceSize.toUpperCase(),
          ownFactor: ownFactor > 0 ? ownFactor : 1,
          referenceFactor: referenceFactor > 0 ? referenceFactor : 1,
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

    // โปรโมชันร้าน (inhousepromotion.json) อิงยอดรวมทั้งบิล ไม่จำกัดตาม med
    // เหมือนโปรโมชันกลุ่มสินค้าทั่วไป แต่ไม่ต้องแสดง near miss
    List<ReceivedGiftItem> inhouseGifts = [];
    double orderTotal = total ?? 0;
    for (PromotionGroupModel promo in inhousePromotions) {
      MedicinePromotionTier? tier = promo.bestTierFor(orderTotal);
      if (tier != null) {
        ReceivedGiftItem? item = buildReceivedGift(
            promo.name ?? '', orderTotal, tier,
            isInhouse: true);
        if (item != null) inhouseGifts.add(item);
      }
    }

    if (mounted) {
      setState(() {
        productGiftsReceived = productGifts;
        groupGiftsReceived = groupGifts;
        inhouseGiftsReceived = inhouseGifts;
        nearMissPromotions = nearMiss;
      });
    }
  }

  /// รวมจำนวนของแถมที่ต้องใช้ทั้งหมดต่อ gift id (โปรโมชันต่างกันอาจให้ของแถมชิ้นเดียวกัน)
  Map<String, double> giftQtyNeeded() {
    Map<String, double> needed = {};
    List<ReceivedGiftItem> allGifts = [
      ...productGiftsReceived,
      ...groupGiftsReceived,
      ...inhouseGiftsReceived,
    ];
    for (ReceivedGiftItem item in allGifts) {
      String? giftId = item.gift?.id;
      if (giftId == null) continue;
      double qty = double.tryParse(item.totalQty) ?? 0;
      needed[giftId] = (needed[giftId] ?? 0) + qty;
    }
    return needed;
  }

  /// รายชื่อของแถมที่สต๊อกคงเหลือ (gift.json > stock) ไม่พอกับจำนวนที่ลูกค้าจะได้รับตามเงื่อนไขปัจจุบัน
  /// เพื่อกันไม่ให้ submit order ผ่าน ต้องให้ลูกค้าปรับจำนวนสินค้าในตะกร้าก่อน
  List<String> insufficientStockGiftNames() {
    List<String> names = [];
    giftQtyNeeded().forEach((giftId, neededQty) {
      GiftModel? gift = giftMap[giftId];
      if (gift == null) return;
      double? stock = double.tryParse(gift.stock ?? '');
      if (stock != null && neededQty > stock) {
        names.add(
            '${gift.name ?? giftId} (ต้องการ ${formatNum(neededQty)} เหลือ ${formatNum(stock)})');
      }
    });
    return names;
  }

  Future<void> readReward() async {
    String? memberId = myUserModel!.id;
    String? memberCode = myUserModel!.customerCode;
    String? url =
        '${MyStyle().serverName}/json_loadmyreward.php?memberId=$memberId&memberCode=$memberCode'; // ?memberId=$memberId

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemNews =
        result['itemsData']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null


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

  Future<void> updateDetailCart(
    String productID,
    String unitSize,
    String memberID,
  ) async {
    String url =
        '${MyStyle().serverName}/json_updatemycart.php?productID=$productID&unitSize=$unitSize&newQTY=$newQTY&memberId=$memberID';
    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        readCart();
      });
    });
  }

  Future<void> deleteCart(int index, String size) async {
    String productID = productAllModels![index].id.toString();
    String unitSize = size;
    String memberID = myUserModel!.id.toString();


    String url =
        '${MyStyle().serverName}/json_removeitemincart.php?productID=$productID&unitSize=$unitSize&memberId=$memberID';

    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        readCart();
      });
    });
  }

  void calculateTotal(String price, String quantity) {
    double? priceDou = double.parse(price);
    quantity = quantity.replaceAll(',', '');
    double? quantityDou = double.parse(quantity);
    total = total! + (priceDou * quantityDou);
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

  void selectedTransport(String string) {
    transport = string;
    setState(() {
      selectedTranindex = int.parse(string);
    });
  }

  Widget showTitleTransport() {
    return Text(
      'การจัดส่ง :${listTransport![selectedTranindex!.toInt()]}', // ,
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
                  value: '1',
                  child: SizedBox(
                    width: 500.0,
                    child: Text(
                      listTransport![1],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: '2',
                  child: SizedBox(
                    width: 500.0,
                    child: Text(
                      listTransport![2],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: '3',
                  child: SizedBox(
                    width: 500.0,
                    child: Text(
                      listTransport![3],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: '4',
                  child: SizedBox(
                    width: 500.0,
                    child: Text(
                      listTransport![4],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: '5',
                  child: SizedBox(
                    width: 500.0,
                    child: Text(
                      listTransport![5],
                      style: TextStyle(fontSize: 16.0, color: Colors.black),
                    ),
                  ),
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
    return BubbleSpecialOne(
      text: msg,  // myUserModel!.promotionalert!
      isSender: true,
      color: Color.fromARGB(255, 254, 255, 175),
      tail: true,
      textStyle: TextStyle(fontSize: 14, color: const Color.fromARGB(255, 223, 5, 5)),
    );
  }

  Widget submitButton() {
    // String? creditterm = myUserModel!.credittermAlert;
    // String? financialamount = myUserModel!.financialamountAlert;
    // String? promotionalert = myUserModel!.promotionalert;
    // String? promotionsuccess = myUserModel!.promotionsuccess;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
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
                            if(creditterm !='-' ) {
                              txtCreditTitle =  'ท่านมียอดค้างชำระเกินกำหนด';
                            } else if(financialamount !='-' ) {
                              txtCreditTitle =  'ท่านมียอดค้างชำระเกินวงเงินที่กำหนด';
                            } else if(contactAdmin !='-' ) {
                              txtCreditTitle =  'กรุณาติดต่อผู้ดูแลระบบ';
                            }

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
                          List<String> insufficientGifts =
                              insufficientStockGiftNames();
                          if (insufficientGifts.isNotEmpty) {
                            AwesomeDialog(
                              context: context,
                              headerAnimationLoop: false,
                              dialogType: DialogType.warning,
                              title: 'ของแถมในสต๊อกไม่เพียงพอ',
                              desc:
                                  'ของแถมต่อไปนี้มีสต๊อกไม่พอกับจำนวนที่ท่านจะได้รับตามเงื่อนไข '
                                  'กรุณาปรับจำนวนสินค้าในตะกร้า หรือติดต่อเจ้าหน้าที่:\n'
                                  '${insufficientGifts.join('\n')}',
                              btnOkText: ('ok'),
                              btnOkColor:
                                  const Color.fromARGB(255, 252, 183, 36),
                              btnOkOnPress: () {
                                debugPrint('OnClcik');
                              },
                              btnOkIcon: Icons.error,
                            ).show();
                          } else {
                            _isPressed = true;
                            memberID = myUserModel!.id.toString();
                            submitThread();
                          }
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
          '${MyStyle().serverName}/json_submit_myorder.php?memberId=$memberID&transport=$transport&comment=$comment';

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


    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งคำสั่งซื้อไม่สำเร็จ กรุณาลองใหม่อีกครั้ง')),
        );
      }
    }
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

  void routeToPromoProduct(String? productId) async {
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
    await Navigator.of(context).push(materialPageRoute);
    // กลับมาจากหน้ารายละเอียดสินค้า ให้โหลดตะกร้าใหม่ เผื่อมีการเพิ่มสินค้าระหว่างอยู่หน้านั้น
    readCart();
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
            child: NearMissSection(
              nearMissPromotions: nearMissPromotions,
              onRouteToGroupProducts: routeToGroupProducts,
              onRouteToPromoProduct: routeToPromoProduct,
            ),
          ),
          showTotal(),
          CartListSection(
            productAllModels: productAllModels!,
            allArrIncartS: allArrIncartS!,
            allArrIncartM: allArrIncartM!,
            allArrIncartL: allArrIncartL!,
            sMap: sMap!,
            mMap: mMap!,
            lMap: lMap!,
            extraPointsForProduct: extraPointsForProduct,
            onQuantityChanged: (productID, size, newQty) {
              newQTY = newQty;
              updateDetailCart(productID, size, myUserModel!.id.toString());
            },
            onDeleteConfirmed: (index, size) {
              deleteCart(index, size);
            },
          ),
          showTotal(),
          (totalExtraPoints() > 0)
              ? ExtraPointSummaryBadge(points: totalExtraPoints())
              : Container(),
          (productGiftsReceived.isNotEmpty ||
                  groupGiftsReceived.isNotEmpty ||
                  inhouseGiftsReceived.isNotEmpty)
              ? PromotionSuccessSection(
                  giftItems: [
                    ...productGiftsReceived,
                    ...groupGiftsReceived,
                    ...inhouseGiftsReceived,
                  ],
                  unitNameMap: unitNameMap,
                )
              : Container(),
          (rewardredeemModels!.isNotEmpty)
              ? RewardSection(rewardredeemModels: rewardredeemModels!)
              : Container(),
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
