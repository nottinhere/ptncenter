import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/promotion_group_model.dart';
import 'package:ptncenter/models/promotion_tier.dart';
import 'package:ptncenter/models/gift_model.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'my_service.dart';
import 'detail.dart';
import 'detail_cart.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:toast/toast.dart';
import 'package:ptncenter/utility/qr_scan_mixins.dart';
import 'package:ptncenter/widget/list_product_promotion_group_card.dart';
import 'package:ptncenter/widget/list_product_promotion_item_card.dart';
import 'package:ptncenter/widget/list_product_promotion_search_form.dart';

class NearMissPromotion {
  final String sourceLabel;
  final String remaining;
  final String remainingUnit;
  final GiftModel? gift;
  final String giftQty;
  final String giftUnit;
  final double progress; // 0.0 - 1.0 ความคืบหน้าไปยัง tier ถัดไป
  final String? maxSets; // จำนวนชุดสูงสุดที่ได้รับได้ (คำนวนจาก limitgift) ถ้ามีการตั้ง limit

  NearMissPromotion(
      {required this.sourceLabel,
      required this.remaining,
      required this.remainingUnit,
      required this.gift,
      required this.giftQty,
      required this.giftUnit,
      required this.progress,
      this.maxSets});
}

class ReceivedGiftItem {
  final String sourceLabel;
  final GiftModel? gift;
  final String sets; // จำนวนชุดที่ได้ คำนวนจากยอดสั่งในตะกร้า
  final String perSetQty; // จำนวนของแถมต่อชุด มาจาก getqty/getqty2/getqty3
  final String totalQty; // sets * perSetQty (ไม่เกิน limitgift ถ้ามีการกำหนด)
  final String? maxSets; // จำนวนชุดสูงสุดที่ได้รับได้ (คำนวนจาก limitgift) ถ้ามีการตั้ง limit

  ReceivedGiftItem(
      {required this.sourceLabel,
      required this.gift,
      required this.sets,
      required this.perSetQty,
      required this.totalQty,
      this.maxSets});
}

class ListProductPromotion extends StatefulWidget {
  final int? index;
  final UserModel? userModel;
  final int? cate;
  final String? cateName;
  final String? searchStr;
  final String? promotionGroupId;

  const ListProductPromotion(
      {super.key,
      this.index,
      this.userModel,
      this.cate,
      this.cateName,
      this.searchStr,
      this.promotionGroupId});

  @override
  _ListProductPromotionState createState() => _ListProductPromotionState();
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

class _ListProductPromotionState extends State<ListProductPromotion>
    with ProductBarcodeScannerMixin<ListProductPromotion> {
  // Explicit
  int? myIndex;
  List<ProductAllModel>? productAllModels = []; // []; // set array
  List<ProductAllModel>? filterProductAllModels = []; // []; //

  int? amontCart = 0;
  UserModel? myUserModel;
  String? searchString = '';
  String? lastItemName = '';

  int? amountListView = 6;
  int? page = 1;

  PromotionGroupModel? currentPromotionGroup;
  Map<String, GiftModel> giftMap = {};
  Map<String, String> unitNameMap = {};
  // key: productId -> มูลค่ารวมในตะกร้า (สำหรับเทียบกับ target ของกลุ่มโปรโมชันนี้)
  Map<int, double> cartValueByProduct = {};
  NearMissPromotion? nearMiss;
  ReceivedGiftItem? receivedGift;

  int? myCate = 0;
  String? myCateName = '';
  String? mysearchString = '';
  String? myPromotionGroupId;
  ScrollController scrollController = ScrollController();
  final Debouncer debouncer =
      Debouncer(milliseconds: 300); // ตั้งค่า เวลาที่จะ delay
  bool statusStart = true;

  int? currentIndex;

  String? creditterm = '-';
  String? financialamount = '-';
  String? contactAdmin = '-';


  int substart = 0;
  bool visible = true;
  int selectIndex = 1;
  // bool creditAlert = false; 

  // Method
  @override
  void initState() {
    // auto load
    super.initState();

    myIndex = widget.index;
    myUserModel = widget.userModel;
    myCate = widget.cate;
    myCateName = widget.cateName;
    mysearchString = widget.searchStr;
    myPromotionGroupId = widget.promotionGroupId;

    if (mysearchString != null) {
      searchString = mysearchString;
    } else {
      searchString = '';
    }

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
    } else if (myIndex == 6) {
      currentIndex = 1;
    } else if (myIndex == 7) {
      currentIndex = 1;
    } else if (myIndex == 8) {
      currentIndex = 1;
    }

    createController(); // เมื่อ scroll to bottom

    setState(() {
      readData(); // read  ข้อมูลมาแสดง
      readCart();
      loadJsonAsset();
    });

    readPromotionGroupRule();
    readGiftItems();
    readUnitNames();
  }

  void createController() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          page = page! + 1;
          readData();
        }
      } else {
        setState(() {
          visible = false;
        });

      }
    });
  }

/// ************************************
  Future<void> readCart() async {

    amontCart = 0;
    lastItemName = '';
    String memberId = myUserModel!.id.toString();
    String url =
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId&screen=listproduct';


    http.Response response = await http.get(Uri.parse(url));
    if (!mounted) return;
    var result = json.decode(response.body);

    final Map<String, dynamic>  myCredit = result['data'];
    creditterm      = myCredit['credittermAlert'];
    financialamount = myCredit['financialamountAlert'];
    contactAdmin    = myCredit['contactAdminAlert'];
    ToastContext().init(context);
    showCreditAlertMessage();

    cartValueByProduct.clear();
    var cartList = result['cart'];
    for (var map in cartList) {
      lastItemName = map['title'];
      amontCart = amontCart! + 1;

      int? productID = map['id'];
      var priceListMap = map['price_list'];
      if (productID != null && priceListMap is Map) {
        for (String size in ['s', 'm', 'l']) {
          var sizeMap = priceListMap[size];
          if (sizeMap == null || sizeMap is! Map || sizeMap.isEmpty) continue;

          double qty = double.tryParse(
                  (sizeMap['quantity'] ?? '').toString().replaceAll(',', '')) ??
              0;
          double price = double.tryParse(
                  (sizeMap['price'] ?? '').toString().replaceAll(',', '')) ??
              0;

          cartValueByProduct[productID] =
              (cartValueByProduct[productID] ?? 0) + (price * qty);
        }
      }
    }
    setState(() {
      lastItemName;
      amontCart;
    });

    computeNearMiss();
  }

  Future<void> readPromotionGroupRule() async {
    String url = 'https://ptnpharma.com/jsonData/medicinepromotiongroup.json';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result is List) {
        for (var map in result) {
          PromotionGroupModel group = PromotionGroupModel.fromJson(map);
          if (group.id == myPromotionGroupId) {
            currentPromotionGroup = group;
            break;
          }
        }
        computeNearMiss();
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
        computeNearMiss();
      }
    } catch (e) {} // ignore: empty_catches
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
        unitNameMap = map;
        computeNearMiss();
      }
    } catch (e) {} // ignore: empty_catches
  }

  String formatNum(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
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

  /// จำนวนชุดสูงสุดที่รับของแถมได้ ถ้ามีการตั้ง limitgift ไว้ (null = ไม่จำกัด)
  String? maxSetsText(double? limit, double perSet) {
    if (limit == null || limit <= 0 || perSet <= 0) return null;
    double maxSets = (limit / perSet).floorToDouble();
    if (maxSets <= 0) return null;
    return formatNum(maxSets);
  }

  /// รายการของแถมที่ได้รับแล้วจากโปรโมชันกลุ่มสินค้านี้ (tier สูงสุดที่ subtotal เข้าเงื่อนไข)
  ReceivedGiftItem? buildReceivedGift(PromotionGroupModel group, double subtotal) {
    MedicinePromotionTier? tier = group.bestTierFor(subtotal);
    if (tier == null) return null;

    double tierTarget = double.tryParse(tier.qty ?? '') ?? 0;
    if (tierTarget <= 0) return null;

    double sets = (subtotal / tierTarget).floorToDouble();
    if (sets <= 0) return null;

    double perSet = double.tryParse(tier.getqty ?? '') ?? 0;
    double rawTotal = sets * perSet;
    double? limit = double.tryParse(tier.limitgift ?? '');
    double total =
        (limit != null && limit > 0 && rawTotal > limit) ? limit : rawTotal;

    return ReceivedGiftItem(
      sourceLabel: group.name ?? '',
      gift: giftMap[tier.gift],
      sets: formatNum(sets),
      perSetQty: formatNum(perSet),
      totalQty: formatNum(total),
      maxSets: maxSetsText(limit, perSet),
    );
  }

  void computeNearMiss() {
    PromotionGroupModel? group = currentPromotionGroup;
    if (group == null) return;

    double subtotal = 0;
    for (String idStr in group.medIds) {
      int? id = int.tryParse(idStr);
      if (id == null) continue;
      subtotal += cartValueByProduct[id] ?? 0;
    }

    ReceivedGiftItem? receivedItem = buildReceivedGift(group, subtotal);

    MedicinePromotionTier? tier = group.nextTierFor(subtotal);
    NearMissPromotion? item;

    if (tier != null) {
      // ยังไม่เข้าเงื่อนไข tier ถัดไป (tier ที่สูงกว่า) แสดง progress จาก 0 ไปยัง tier นี้ตามเดิม
      double tierTarget = double.tryParse(tier.qty ?? '') ?? 0;
      if (tierTarget > 0) {
        double progress = subtotal / tierTarget;
        double remaining = (tierTarget - subtotal).ceilToDouble();
        double tierPerSet = double.tryParse(tier.getqty ?? '') ?? 0;
        double? tierLimit = double.tryParse(tier.limitgift ?? '');
        GiftModel? gift = giftMap[tier.gift];
        item = NearMissPromotion(
          sourceLabel: group.name ?? '',
          remaining: formatNum(remaining),
          remainingUnit: 'บาท',
          gift: gift,
          giftQty: formatNum(tierPerSet),
          giftUnit: unitNameMap[gift?.unit] ?? '',
          progress: progress,
          maxSets: maxSetsText(tierLimit, tierPerSet),
        );
      }
    } else {
      // เข้าเงื่อนไข tier สูงสุดแล้ว (ได้ของแถมอย่างน้อย 1 ชุด) โปรโมชันนี้ให้ของแถมซ้ำได้ทุกๆ
      // ครบยอด tier.qty อีกรอบ (ไม่เกิน limitgift) จึงแสดง progress มองจาก "ชุดถัดไป" แทน
      // คือ progress ภายในรอบปัจจุบัน ไม่ใช่จาก 0 และจะไม่แสดงถ้าได้รับของแถมครบ limit แล้ว
      MedicinePromotionTier? bestTier = group.bestTierFor(subtotal);
      if (bestTier != null) {
        double tierTarget = double.tryParse(bestTier.qty ?? '') ?? 0;
        double perSet = double.tryParse(bestTier.getqty ?? '') ?? 0;
        double? limit = double.tryParse(bestTier.limitgift ?? '');

        if (tierTarget > 0) {
          double sets = (subtotal / tierTarget).floorToDouble();
          bool atLimit = limit != null &&
              limit > 0 &&
              perSet > 0 &&
              (sets * perSet) >= limit;

          if (!atLimit) {
            double remainder = subtotal - (sets * tierTarget);
            double progress = remainder / tierTarget;
            double remaining = (tierTarget - remainder).ceilToDouble();
            GiftModel? gift = giftMap[bestTier.gift];
            item = NearMissPromotion(
              sourceLabel: group.name ?? '',
              remaining: formatNum(remaining),
              remainingUnit: 'บาท',
              gift: gift,
              giftQty: formatNum(perSet),
              giftUnit: unitNameMap[gift?.unit] ?? '',
              progress: progress,
              maxSets: maxSetsText(limit, perSet),
            );
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        nearMiss = item;
        receivedGift = receivedItem;
      });
    }
  }


  Widget showCart() {
    return GestureDetector(
      onTap: () {
        routeToDetailCart();
      },
      child: Container(
        margin: EdgeInsets.only(top: 5.0, right: 5.0),
        width: 32.0,
        height: 32.0,
        child: Stack(
          children: <Widget>[
            Image.asset('images/shopping_cart.png'),
            Text(
              ' $amontCart ',
              style: TextStyle(
                backgroundColor: Colors.red.shade600,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailCart(
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Future<void> readData() async {
    // List<ProductAllModel> productAllModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;
    setState(() {
      visible = true;
    });

    String memberId = myUserModel!.id.toString();
    String url =
            '${MyStyle().serverName}/json_productlist.php?memberId=$memberId&promotiongroup_id=$myPromotionGroupId&page=$page';


    // url = '${MyStyle().readProductWhereMode}$myIndex';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemProducts = result['itemsProduct'];
    // print('itemProducts >> ${itemProducts}');
    int i = 0;

    for (var map in itemProducts) {
      ProductAllModel productAllModel = ProductAllModel.fromJson(map);

      setState(() {
        productAllModels!.add(productAllModel);
        filterProductAllModels = productAllModels;
      });

      i = i + 1;
    }
    setState(() {
      visible = false;
    });
  }

  Future<void>? showCreditAlertMessage() {
    if (creditterm !='-' || financialamount !='-' || contactAdmin !='-') {
        var txtCreditTitle =  '';
        if(creditterm !='-' ) {
          txtCreditTitle =  'ท่านมียอดค้างชำระเกินกำหนด';
        } else if(financialamount !='-' ) {
          txtCreditTitle =  'ท่านมียอดค้างชำระเกินวงเงินที่กำหนด';
        } else if(contactAdmin !='-' ) {
          txtCreditTitle =  'กรุณาติดต่อผู้ดูแลระบบ';
        }

      Toast.show(txtCreditTitle,
          duration: 5,// Toast.lengthLong,
          gravity: Toast.bottom,
          backgroundColor: const Color.fromARGB(255, 243, 88, 61));
    }
    return null;
  }


  Future<void> updateDatalist(index) async {
    // List<ProductAllModel> productAllModels_buffer = List(); // []; //
    // String url = MyStyle().readAllProduct;

    String? memberId = myUserModel!.id.toString();
    int? productID = filterProductAllModels![index].id!;
    String? url =
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId';

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];

    Map<String, dynamic>? mapCart;
    for (var m in cartList) {
      if (m['id'] == productID) {
        mapCart = m;
        break;
      }
    }

    // ถ้าไม่พบสินค้าในตะกร้าแล้ว (ถูกลบออกทั้งหมด) หรือไซส์นั้นไม่มีอยู่ในตะกร้าแล้ว
    // (ถูกลบออกโดยการตั้งจำนวนเป็น 0) ให้เคลียร์ข้อความจำนวนในตะกร้าของไซส์นั้นด้วย
    setState(() {
      filterProductAllModels![index].itemincartSunit =
          (mapCart != null && mapCart['price_list'].containsKey('s'))
              ? mapCart['price_list']['s']['quantity']
              : '0';
      filterProductAllModels![index].itemincartMunit =
          (mapCart != null && mapCart['price_list'].containsKey('m'))
              ? mapCart['price_list']['m']['quantity']
              : '0';
      filterProductAllModels![index].itemincartLunit =
          (mapCart != null && mapCart['price_list'].containsKey('l'))
              ? mapCart['price_list']['l']['quantity']
              : '0';
    });
  }

  Widget loading() {
    return Visibility(
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: visible,
      // child: Loading(indicator: BallPulseIndicator(), size: 10.0),
      child: LoadingIndicator(
          indicatorType: Indicator.ballPulse,

          /// Required, The loading type of the widget
          colors: const [Colors.red],

          /// Optional, The color collections
          strokeWidth: 2,

          /// Optional, The stroke of the line, only applicable to widget which contains line
          backgroundColor: Colors.black,

          /// Optional, Background of the widget
          pathBackgroundColor: Colors.black

          /// Optional, the stroke backgroundColor
          ),
    );
  }

  Widget loadMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 20.0,
            height: 20.0,
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.green,
              size: 20,
            ),
          ),
          SizedBox(width: 10.0),
          Text('กำลังโหลดข้อมูลเพิ่มเติม...',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13.0)),
        ],
      ),
    );
  }

  Widget showProductItem() {
    int itemCount = filterProductAllModels!.length;
    bool showLoadingFooter = visible && itemCount > 0;

    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        itemCount: itemCount + (showLoadingFooter ? 1 : 0),
        itemBuilder: (BuildContext buildContext, int index) {
          if (index >= itemCount) {
            return loadMoreIndicator();
          }

          return ProductPromotionListItem(
            product: filterProductAllModels![index],
            onTap: () {
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return Detail(
                  productAllModel: filterProductAllModels![index],
                  userModel: myUserModel,
                );
              });

              Navigator.of(context)
                  .push(materialPageRoute)
                  .then((value) => setState(() {
                        readCart();
                        updateDatalist(index);
                      }));
            },
          );
        },
      ),
    );
  }

  Widget showContent() {
    bool? searchKey;
    if (searchString != '') {
      searchKey = true;
    }

    if (filterProductAllModels!.isEmpty) {
      if (myIndex != 4) {
        return showProgressIndicate(searchKey);
      } else {
        return Center(child: Text(''));
      }
    } else {
      return showProductItem();
    }
  }

  Widget showProgressIndicate(searchKey) {
    // print('searchKey >> $searchKey');

    if (searchKey == true) {
      if (filterProductAllModels!.isEmpty) {
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
    /*
    return Center(
      child:
          statusStart ? CircularProgressIndicator() : Text('Search not found'),
    );
    */
  }

  /*
  Widget myLayout() {
    return Column(
      children: <Widget>[
        searchForm(),
        showProductItem(),
      ],
    );
  }
  */

  // Widget lastItemInCart() {
  //   return Column(
  //     children: <Widget>[
  //       Container(
  //         width: MediaQuery.of(context).size.width * 0.9,
  //         child: Text(
  //           'รายการล่าสุดในตะกร้า',
  //           style: MyStyle().h3bStyle,
  //         ),
  //       ),
  //       Container(
  //         width: MediaQuery.of(context).size.width * 0.9,
  //         child: Text(lastItemName.toString(),
  //             style: TextStyle(
  //               fontSize: 14.0,
  //               // fontWeight: FontWeight.bold,
  //               color: Color.fromARGB(0xff, 0x00, 0x73, 0x26),
  //             )),
  //       ),
  //     ],
  //   );
  // }


  @override
  void onProductFound(ProductAllModel product) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (BuildContext context) => Detail(
        userModel: myUserModel,
        productAllModel: product,
      ),
    );
    Navigator.of(context).push(route).then((value) => readCart());
  }

  List<String> jsonSuggestMed =[];
  Future<void> loadJsonAsset() async {
    String url = 'https://ptnpharma.com/jsonData/medicine_unit.json';
    http.Response response = await http.get(Uri.parse(url));
    var result =  json.decode(response.body.toLowerCase()); // json.decode(utf8.decode(response.bodyBytes).toLowerCase());
    for (var map in result) {
      jsonSuggestMed.add('${map['name']}|${map['code']}');   // map['code']+"|"+map['name']
    }
    setState(() {
       jsonSuggestMed;
    });
  }

  String buildSearchKey(String query) {
    String trimmed = query.trim();
    if (trimmed.isEmpty) return trimmed;

    List<String> words = trimmed.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      // ค้นหาด้วย 2 คำแรกพร้อมกัน (ต้องเจอทั้งคู่ใน field เดียวกัน) เช่น "Acetin 200"
      String keyword1 = Uri.encodeComponent(words[0]);
      String keyword2 = Uri.encodeComponent(words[1]);
      return 'kw2|$keyword1|$keyword2';
    }
    return trimmed;
  }

  Widget searchForm() {
    return ProductPromotionSearchForm(
      suggestions: jsonSuggestMed,
      onSearchChanged: (String string) {
        searchString = string.trim();
      },
      onSearchSubmitted: (value) {
        setState(() {
          searchString = buildSearchKey(value);
          page = 1;
          myIndex = 0;
          productAllModels!.clear();
          readData();
        });
      },
      onSuggestionSelected: (String selection) {
        var parts = selection.split('|');
        searchString = 'x|${parts.sublist(1).join('|').trim()}';
        setState(() {
          page = 1;
          myIndex = 0;
          productAllModels!.clear();
          readData();
        });
      },
      onScanBarcode: () {
        readQRcodePreview();
      },
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

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProductfav(
        index: index,
        userModel: myUserModel,
      );
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
              builder: (value) => MyService(
                userModel: myUserModel,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            routeToListProduct(0);
          } else if (index == 2) {
            routeToListProductfav(index);
          } else if (index == 3) {
            routeToDetailCart();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String txtheader  = 'กลุ่ม${myCateName!}';

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: MyStyle().bgColor,
        title: Text(txtheader, style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          showCart(),
        ],
      ),

      body: Column(
        children: <Widget>[
          GroupPromotionCard(
            currentPromotionGroup: currentPromotionGroup,
            cartValueByProduct: cartValueByProduct,
            giftMap: giftMap,
          ),
          searchForm(),
          // lastItemInCart(),
          showContent(),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }
}

class ScanPreviewPage extends StatefulWidget {
  const ScanPreviewPage({super.key});

  @override
  _ScanPreviewPageState createState() => _ScanPreviewPageState();
}

class _ScanPreviewPageState extends State<ScanPreviewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PTN Pharma'),
          backgroundColor: MyStyle().bgColor,
        ),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          // child: ScanPreviewWidget(
          //   onScanResult: (result) {
          //     debugPrint('scan result: $result');
          //     Navigator.pop(context, result);
          //   },
          // ),
        ),
      ),
    );
  }
}
