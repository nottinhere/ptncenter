import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/product_all_model2.dart';
import 'package:ptncenter/models/unit_size_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/models/medicine_promotion_model.dart';
import 'package:ptncenter/models/promotion_tier.dart';
import 'package:ptncenter/models/gift_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/utility/my_style.dart';

import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ptncenter/models/promote_model.dart';
import 'my_service.dart';
import 'package:favorite_button/favorite_button.dart';



import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:ptncenter/widget/detail_promotion_card.dart';
import 'package:ptncenter/widget/detail_package_size_row.dart';

class NearMissPromotion {
  final String sourceLabel;
  final String remaining;
  final String remainingUnit;
  final GiftModel? gift;
  final String giftQty;
  final String giftUnit;
  final double progress; // 0.0 - 1.0 ความคืบหน้าไปยัง tier ถัดไป
  final String? sizeLabel; // ไซส์ (S/M/L) ที่เข้าเงื่อนไขโปรโมชันนี้ ถ้ามี
  final String? maxSets; // จำนวนชุดสูงสุดที่ได้รับได้ (คำนวนจาก limitgift) ถ้ามีการตั้ง limit

  NearMissPromotion(
      {required this.sourceLabel,
      required this.remaining,
      required this.remainingUnit,
      required this.gift,
      required this.giftQty,
      required this.giftUnit,
      required this.progress,
      this.sizeLabel,
      this.maxSets});
}

class ReceivedGiftItem {
  final String sourceLabel;
  final GiftModel? gift;
  final String sets; // จำนวนชุดที่ได้ คำนวนจากจำนวนในตะกร้า
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

class Detail extends StatefulWidget {
  final ProductAllModel? productAllModel;
  final UserModel? userModel;

  const Detail({super.key, this.productAllModel, this.userModel});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  // Explicit
  ProductAllModel? currentProductAllModel;
  ProductAllModel2? productAllModel;
  ProductAllModel? relateAllModel;

  List<UnitSizeModel>? unitSizeModels = [];
  List<ProductAllModel>? slideshowModels = [];
  List<ProductAllModel>? relateslideshowModels = [];

  List<int>? amounts = [0, 0, 0];
  int? amontCart = 0;
  UserModel? myUserModel;
  String? id; // productID
  // String qtyS = '', qtyM = '', qtyL = '';
  int? sizeSincart = 0, sizeMincart = 0, sizeLincart = 0;
  int? qtyS, qtyM, qtyL;
  int? showSincart = 0, showMincart = 0, showLincart = 0;
  int? limitS = 0, limitM = 0, limitL = 0;
  // ไซส์นั้นมีวางขายจริง (มีราคา > 0) หรือไม่ ใช้ตัดสินใจปลายทางของปุ่ม quick-add (btnAdd1/btnAdd2)
  bool mSoldSeparately = false, lSoldSeparately = false;
  // var showSincart = '', showMincart = '', showLincart = '';

  List<Widget>? promoteLists = [];
  List<Widget>? relateLists = [];
  List<String>? urlImages = [];
  List<String>? urlImagesRelate = [];
  List<String>? productsName = [];
  List<String>? productsNameRelate = [];
  List<ProductAllModel>? promoteModels = [];
  List<ProductAllModel>? relateModels = [];
  List<Widget>? slideshowLists = [];
  List<Widget>? relateslideshowLists = [];

  int? banerIndex = 0, relateIndex = 0;
  int? currentIndex = 1;
  String? qrString;
  String? videoCode = "";
  int selectIndex = 1;
  WebViewController? tiktokController;
  String? tiktokUrl;

  MedicinePromotionModel? currentPromotion;
  Map<String, GiftModel> giftMap = {};
  Map<String, String> unitNameMap = {};
  Map<String, String> priceLabelBySize = {};
  NearMissPromotion? nearMiss;
  ReceivedGiftItem? receivedGift;

  // Method
  @override
  void initState() {
    super.initState();
    currentProductAllModel = widget.productAllModel;
    myUserModel = widget.userModel;
    setState(() {
      readCart();
      getProductWhereID();
    });
    readSlide();
    readRelate();
    readMedicinePromotion();
    readGiftItems();
    readUnitNames();
  }

  Future<void> getProductWhereID() async {
    if (currentProductAllModel != null) {
      String? memberId = myUserModel!.id.toString();
      id = currentProductAllModel!.id.toString();
      String? url = '${MyStyle().getProductWhereId}$id&memberId=$memberId';
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print('result =0000000>>> $result');

      var itemProducts = result['itemsProduct'];
      for (var map in itemProducts) {

        setState(() {
          productAllModel = ProductAllModel2.fromJson(map);

          Map<String, dynamic> priceListMap = map['price_list'];

          Map<String, dynamic>? sizeSmap = priceListMap['s'];
          if (sizeSmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeSmap);
            unitSizeModels!.add(unitSizeModel);
            priceLabelBySize['s'] = unitSizeModel.lable ?? '';
          }
          Map<String, dynamic>? sizeMmap = priceListMap['m'];
          if (sizeMmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeMmap);
            unitSizeModels!.add(unitSizeModel);
            priceLabelBySize['m'] = unitSizeModel.lable ?? '';
            mSoldSeparately = (double.tryParse(unitSizeModel.price ?? '') ?? 0) > 0;
          }
          Map<String, dynamic>? sizeLmap = priceListMap['l'];
          if (sizeLmap != null) {
            UnitSizeModel unitSizeModel = UnitSizeModel.fromJson(sizeLmap);
            unitSizeModels!.add(unitSizeModel);
            priceLabelBySize['l'] = unitSizeModel.lable ?? '';
            lSoldSeparately = (double.tryParse(unitSizeModel.price ?? '') ?? 0) > 0;
          }
        });
      } // for

      setState(() {
        showSincart = productAllModel!.itemincartSunit;
        showMincart = productAllModel!.itemincartMunit;
        showLincart = productAllModel!.itemincartLunit;

        limitS = productAllModel!.limitS;
        limitM = productAllModel!.limitM;
        limitL = productAllModel!.limitL;


        videoCode = productAllModel?.youtube?.toString();

        String? tiktok = productAllModel?.tiktok;
        if (tiktok != null && tiktok.isNotEmpty) {
          tiktokUrl = tiktok;
          tiktokController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (NavigationRequest request) {
                  if (request.url.startsWith('http://') ||
                      request.url.startsWith('https://')) {
                    return NavigationDecision.navigate;
                  }
                  // เช่น intent://, tiktok://  ที่ WebView เปิดตรงไม่ได้
                  return NavigationDecision.prevent;
                },
              ),
            )
            ..loadRequest(Uri.parse(tiktok));
        }
      });
      computeNearMiss();
    }
  }

  Future<void> readMedicinePromotion() async {
    String url = 'https://ptnpharma.com/jsonData/medicinepromotion.json';
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      if (result is List) {
        String productId = currentProductAllModel!.id.toString();
        for (var map in result) {
          MedicinePromotionModel promo = MedicinePromotionModel.fromJson(map);
          if (promo.id == productId) {
            currentPromotion = promo;
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

  /// จำนวนชุดสูงสุดที่รับของแถมได้ ถ้ามีการตั้ง limitgift ไว้ (null = ไม่จำกัด)
  String? maxSetsText(double? limit, double perSet) {
    if (limit == null || limit <= 0 || perSet <= 0) return null;
    double maxSets = (limit / perSet).floorToDouble();
    if (maxSets <= 0) return null;
    return formatNum(maxSets);
  }

  /// รายการของแถมที่ได้รับแล้วจากโปรโมชันรายสินค้านี้ (tier สูงสุดที่ cartQty เข้าเงื่อนไข)
  ReceivedGiftItem? buildReceivedGift(
      MedicinePromotionModel promo, double cartQty) {
    MedicinePromotionTier? tier = promo.bestTierFor(cartQty);
    if (tier == null) return null;

    double tierQty = double.tryParse(tier.qty ?? '') ?? 0;
    if (tierQty <= 0) return null;

    double sets = (cartQty / tierQty).floorToDouble();
    if (sets <= 0) return null;

    double perSet = double.tryParse(tier.getqty ?? '') ?? 0;
    double rawTotal = sets * perSet;
    double? limit = double.tryParse(tier.limitgift ?? '');
    double total =
        (limit != null && limit > 0 && rawTotal > limit) ? limit : rawTotal;

    return ReceivedGiftItem(
      sourceLabel: promo.name ?? '',
      gift: giftMap[tier.gift],
      sets: formatNum(sets),
      perSetQty: formatNum(perSet),
      totalQty: formatNum(total),
      maxSets: maxSetsText(limit, perSet),
    );
  }

  void computeNearMiss() {
    MedicinePromotionModel? promo = currentPromotion;
    if (promo == null) {
      if (mounted) {
        setState(() {
        nearMiss = null;
        receivedGift = null;
      });
      }
      return;
    }

    double qtyS = (showSincart ?? 0).toDouble();
    double qtyM = (showMincart ?? 0).toDouble();
    double qtyL = (showLincart ?? 0).toDouble();
    double cartQty = promo.equivalentQty(qtyS: qtyS, qtyM: qtyM, qtyL: qtyL);

    ReceivedGiftItem? receivedItem = buildReceivedGift(promo, cartQty);

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
    double safeOwnFactor = ownFactor > 0 ? ownFactor : 1;
    double safeReferenceFactor = referenceFactor > 0 ? referenceFactor : 1;

    MedicinePromotionTier? tier = promo.nextTierFor(cartQty);
    NearMissPromotion? item;

    if (tier != null) {
      // ยังไม่เข้าเงื่อนไข tier ถัดไป (tier ที่สูงกว่า) แสดง progress จาก 0 ไปยัง tier นี้ตามเดิม
      double tierQty = double.tryParse(tier.qty ?? '') ?? 0;
      if (tierQty > 0) {
        double progress = cartQty / tierQty;
        double remaining =
            ((tierQty - cartQty) * safeOwnFactor / safeReferenceFactor)
                .ceilToDouble();
        double tierPerSet = double.tryParse(tier.getqty ?? '') ?? 0;
        double? tierLimit = double.tryParse(tier.limitgift ?? '');
        GiftModel? gift = giftMap[tier.gift];
        item = NearMissPromotion(
          sourceLabel: promo.name ?? '',
          remaining: formatNum(remaining),
          remainingUnit: priceLabelBySize[referenceSize] ?? '',
          gift: gift,
          giftQty: formatNum(tierPerSet),
          giftUnit: unitNameMap[gift?.unit] ?? '',
          progress: progress,
          sizeLabel: referenceSize.toUpperCase(),
          maxSets: maxSetsText(tierLimit, tierPerSet),
        );
      }
    } else {
      // เข้าเงื่อนไข tier สูงสุดแล้ว (ได้ของแถมอย่างน้อย 1 ชุด) โปรโมชันนี้ให้ของแถมซ้ำได้ทุกๆ
      // ครบจำนวน tier.qty อีกรอบ (ไม่เกิน limitgift) จึงแสดง progress มองจาก "ชุดถัดไป" แทน
      // คือ progress ภายในรอบปัจจุบัน ไม่ใช่จาก 0 และจะไม่แสดงถ้าได้รับของแถมครบ limit แล้ว
      MedicinePromotionTier? bestTier = promo.bestTierFor(cartQty);
      if (bestTier != null) {
        double tierQty = double.tryParse(bestTier.qty ?? '') ?? 0;
        double perSet = double.tryParse(bestTier.getqty ?? '') ?? 0;
        double? limit = double.tryParse(bestTier.limitgift ?? '');

        if (tierQty > 0) {
          double sets = (cartQty / tierQty).floorToDouble();
          bool atLimit = limit != null &&
              limit > 0 &&
              perSet > 0 &&
              (sets * perSet) >= limit;

          if (!atLimit) {
            double remainder = cartQty - (sets * tierQty);
            double progress = remainder / tierQty;
            double remaining =
                ((tierQty - remainder) * safeOwnFactor / safeReferenceFactor)
                    .ceilToDouble();
            GiftModel? gift = giftMap[bestTier.gift];
            item = NearMissPromotion(
              sourceLabel: promo.name ?? '',
              remaining: formatNum(remaining),
              remainingUnit: priceLabelBySize[referenceSize] ?? '',
              gift: gift,
              giftQty: formatNum(perSet),
              giftUnit: unitNameMap[gift?.unit] ?? '',
              progress: progress,
              sizeLabel: referenceSize.toUpperCase(),
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

  /// *************************

  Image showImageNetWork(String urlImage) {
    return Image.network(urlImage);
  }

  /// *************************

  Future<void> readSlide() async {
    String? memId = myUserModel!.id;
    id = currentProductAllModel!.id.toString();


    String url =
        '${MyStyle().serverName}/json_productimage.php?memberId=$memId&id=$id';
    // String url = '${MyStyle().serverName}/json_slideshow.php';


    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    for (var map in mapItemProduct) {
      PromoteModel? slideshowModel = PromoteModel.fromJson(map);
      ProductAllModel? productAllModel = ProductAllModel.fromJson(map);
      String? urlImage = slideshowModel.photo;
      // print('urlImage >> $urlImage');

      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        slideshowModels!.add(productAllModel);
        slideshowLists!.add(showImageNetWork(urlImage!));

        urlImages!.add(urlImage);
      });
    }
  }

  // /*************************** */
  Future<void> readRelate() async {
    String? memId = myUserModel!.id;
    id = currentProductAllModel!.id.toString();

    String url =
        '${MyStyle().serverName}/json_relate.php?memberId=$memId&productId=$id'; // ?memberId=$memberId

    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var mapItemProduct =
        result['itemsProduct']; // dynamic    จะส่ง value อะไรก็ได้ รวมถึง null

    for (var map in mapItemProduct) {
      PromoteModel? relateslideshowModel = PromoteModel.fromJson(map);
      ProductAllModel? productAllModel = ProductAllModel.fromJson(map);
      String? urlImage = relateslideshowModel.photo;

      setState(() {
        //promoteModels.add(promoteModel); // push ค่าลง array
        relateslideshowModels!.add(productAllModel);
        relateslideshowLists!.add(showImageNetWork(urlImage!));
        // productsNameRelate!.add(productName!);
        urlImagesRelate!.add(urlImage);
      });
    }
  }

  Widget myCircularProgress() {
    return Center(child: CircularProgressIndicator());
  }

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProductfav(index: index, userModel: myUserModel!);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }

  bool get hasAnyTag =>
      productAllModel!.promotion == 1 ||
      productAllModel!.newproduct == 1 ||
      productAllModel!.updateprice == 1 ||
      productAllModel!.notreceive == 1;

  Widget tagChip(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget showTag() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: <Widget>[
        if (productAllModel!.promotion == 1)
          tagChip('โปรโมชัน', MyStyle().mainColor, () => routeToListProduct(2)),
        if (productAllModel!.newproduct == 1)
          tagChip('สินค้าใหม่', Colors.blue.shade600, () => routeToListProduct(1)),
        if (productAllModel!.updateprice == 1)
          tagChip('จะปรับราคา', MyStyle().warningColor, () => routeToListProduct(3)),
        if (productAllModel!.notreceive == 1)
          tagChip('สั่งแล้วไม่ได้รับ', MyStyle().alertColor, () => routeToListProduct(4)),
      ],
    );
  }

  Widget showCarouseSlideshow() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(MyStyle().radiusM),
      child: GestureDetector(
        child: CarouselSlider.builder(
          options: CarouselOptions(
            // pauseAutoPlayOnTouch: Duration(seconds: 5),
            autoPlay: slideshowLists!.isNotEmpty ? true : false,
            autoPlayAnimationDuration: Duration(seconds: 5),
          ),
          itemCount: (slideshowLists!.length).round(),
          itemBuilder: (context, index, realIdx) {
            final int first = index;
            // final int second = first + 1;
            return Row(
              children: [first].map((idx) {
                return Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(1.0),
                    child: Center(
                      child: Image.network(
                        urlImages![idx],
                        fit: BoxFit.cover,
                        width: 1000,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget showCarouseSliderRelate() {
    return GestureDetector(
      child: CarouselSlider.builder(
        options: CarouselOptions(
          // pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlay: (relateslideshowLists!.isNotEmpty) ? true : false,
          autoPlayAnimationDuration: Duration(seconds: 5),
        ),
        itemCount: (relateslideshowLists!.length / 2).round(),
        itemBuilder: (context, index, realIdx) {
          final int first = index * 2;
          final int second = first + 1;
          return Row(
            children: [first, second].map((idx) {
              return Expanded(
                child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(MyStyle().radiusS),
                      border: Border.all(color: MyStyle().borderColor),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          height: 100.00,
                          padding: EdgeInsets.all(8.0),
                          child: Image.network(
                            urlImagesRelate![idx],
                            fit: BoxFit.cover,
                            width: 1000,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 4.0),
                          child: Text(
                            relateslideshowModels![idx].title!,
                            style: TextStyle(
                              fontSize: 12,
                              // fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (BuildContext context) => Detail(
                        productAllModel: relateslideshowModels![idx],
                        userModel: myUserModel,
                      ),
                    );
                    Navigator.of(context).push(route).then((value) {});
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Post ค่าไปยัง API ที่ต้องการ
  Future<void> editFavorite(
    String productID,
    String memberID,
    bool isFavorite,
  ) async {
    String url =
        '${MyStyle().serverName}/json_favorite.php?productID=$productID&memberId=$memberID&status=$isFavorite';

    await http.get(Uri.parse(url)).then((response) {
      setState(() {
        //readCart();
      });
    });
  }

  Widget favButton() {
    bool? favStatus = (productAllModel!.favorite == true) ? true : false;

    String? productID = id;
    String? memberID = myUserModel!.id.toString();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x1F000000), blurRadius: 6.0),
        ],
      ),
      child: FavoriteButton(
        isFavorite: favStatus,
        iconSize: 34.0,
        valueChanged: (isFavorite) {
          // print('Is Favorite : $_isFavorite');
          editFavorite(productID!, memberID, isFavorite);

          // http.Response response =  http.get(Uri.parse(url));
        },
      ),
    );
  }

  Widget imageSection() {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.30,
          padding: EdgeInsets.all(12.0),
          child: Image.network(productAllModel!.photo!, fit: BoxFit.contain),
        ),
        Positioned(
          top: 8.0,
          right: 8.0,
          child: favButton(),
        ),
      ],
    );
  }

  Widget titleCard() {
    return Padding(
      padding: EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(productAllModel!.title!, style: MyStyle().h2Style),
          if ((productAllModel?.hilight ?? '') != '')
            Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: Text(productAllModel!.hilight!, style: MyStyle().h3StyleRed),
            ),
          if ((productAllModel?.extrapoint ?? '') != '')
            Padding(
              padding: EdgeInsets.only(top: 4.0),
              child:
                  Text(productAllModel!.extrapoint!, style: MyStyle().h3StyleOrange),
            ),
          if (hasAnyTag)
            Padding(padding: EdgeInsets.only(top: 10.0), child: showTag()),
        ],
      ),
    );
  }

  Widget sectionDivider() {
    return Divider(height: 1.0, thickness: 1.0, color: MyStyle().borderColor);
  }

  /// การ์ดสรุปโปรโมชันรายสินค้า แสดงทุกขั้น (ขั้น 1/2/3) พร้อมสถานะสำเร็จ/ยังไม่สำเร็จ
  /// จำนวนในตะกร้าปัจจุบัน progress bar ไปยัง "ชุดถัดไป" ของขั้นที่กำลังสะสม และของแถมที่จะได้รับ
  /// (มองลำดับขั้นแบบเดียวกับโปรโมชันกลุ่มสินค้าใน list_product_promotion.dart)
  Widget productSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MyStyle().radiusM),
        border: Border.all(color: MyStyle().borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          titleCard(),
          sectionDivider(),
          imageSection(),
          sectionDivider(),
          showStockExpire(),
          sectionDivider(),
          showPrice(),
        ],
      ),
    );
  }

  Widget infoTile(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16.0, color: MyStyle().mutedTextColor),
          SizedBox(width: 6.0),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: MyStyle().captionStyle),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.grey.shade900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showStockExpire() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: <Widget>[
          infoTile(
            Icons.inventory_2_outlined,
            'สต๊อก',
            '${productAllModel!.stock}',
            valueColor: productAllModel!.stock.toString() != '0'
                ? Colors.grey.shade900
                : Colors.red,
          ),
          infoTile(
            Icons.event_outlined,
            'วันหมดอายุ',
            '${productAllModel!.expire}',
            valueColor: (productAllModel!.expireColor == 'red')
                ? Colors.red
                : (productAllModel!.expireColor == 'blue')
                    ? Colors.blue.shade700
                    : Colors.grey.shade900,
          ),
        ],
      ),
    );
  }

  Widget showVideo() {
    // String videoSelectCode = videoCode!;
    String videoSelectCode = productAllModel!.youtube!;
    final controllers = YoutubePlayerController(
      initialVideoId: videoSelectCode,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: true,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(MyStyle().radiusM),
      child: YoutubePlayer(
        key: ObjectKey(controllers),
        controller: controllers,
        actionsPadding: const EdgeInsets.only(left: 16.0),
        bottomActions: [
          CurrentPosition(),
          const SizedBox(width: 10.0),
          ProgressBar(isExpanded: true),
          const SizedBox(width: 10.0),
          RemainingDuration(),
          FullScreenButton(),
        ],
      ),
    );
  }

  Widget showTikTokVideo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(MyStyle().radiusM),
      child: SizedBox(
        height: 550.0,
        child: WebViewWidget(controller: tiktokController!),
      ),
    );
  }

  Widget infoSection(IconData icon, String title, String content) {
    return Padding(
      padding: EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16.0, color: MyStyle().mainColor),
              SizedBox(width: 6.0),
              Text(title, style: MyStyle().h4bStyleGray),
            ],
          ),
          SizedBox(height: 6.0),
          Text(content, style: MyStyle().h4StyleGray),
        ],
      ),
    );
  }

  Widget salepriceinfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: MyStyle().primaryLight,
        borderRadius: BorderRadius.circular(MyStyle().radiusM),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('ราคาป้าย', style: MyStyle().captionStyle),
                SizedBox(height: 4.0),
                Text(productAllModel!.pricelabel!, style: MyStyle().h3bStyleGray),
              ],
            ),
          ),
          Container(
            width: 1.0,
            height: 32.0,
            color: MyStyle().borderColor,
            margin: EdgeInsets.symmetric(horizontal: 12.0),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('แนะนำขายปลีก', style: MyStyle().captionStyle),
                SizedBox(height: 4.0),
                Text(productAllModel!.pricesale!, style: MyStyle().h3bStyleGray),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get hasMoreInfo =>
      (productAllModel?.usefor ?? '') != '' ||
      (productAllModel?.method ?? '') != '' ||
      (productAllModel?.detail ?? '') != '';

  Widget moreinfo() {
    List<Widget> items = <Widget>[
      if ((productAllModel?.usefor ?? '') != '')
        infoSection(Icons.medical_information_outlined, 'ใช้รักษา',
            productAllModel!.usefor!),
      if ((productAllModel?.method ?? '') != '')
        infoSection(Icons.info_outline, 'วิธีการใช้', productAllModel!.method!),
      if ((productAllModel?.detail ?? '') != '')
        infoSection(
            Icons.description_outlined, 'รายละเอียด', productAllModel!.detail!),
    ];

    List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) children.add(sectionDivider());
      children.add(items[i]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget moreInfoCard() {
    List<Widget> sections = <Widget>[
      if (slideshowLists!.isNotEmpty)
        Padding(padding: EdgeInsets.all(14.0), child: showCarouseSlideshow()),
      if ((productAllModel?.youtube ?? '-') != '-')
        Padding(padding: EdgeInsets.all(14.0), child: showVideo()),
      if (tiktokController != null)
        Padding(padding: EdgeInsets.all(14.0), child: showTikTokVideo()),
      Padding(padding: EdgeInsets.all(14.0), child: salepriceinfo()),
      if (hasMoreInfo) moreinfo(),
    ];

    List<Widget> children = [];
    for (int i = 0; i < sections.length; i++) {
      if (i > 0) children.add(sectionDivider());
      children.add(sections[i]);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MyStyle().radiusM),
        border: Border.all(color: MyStyle().borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget showPrice() {
    // ซ่อนไซส์ที่งดจำหน่าย (ราคา = 0) ไม่ต้องขึ้นแถวให้เห็นเลย ตัด index ที่จะโชว์ไว้ล่วงหน้า
    // (แต่ยังอ้าง index เดิมใน unitSizeModels ต่อไป เพราะ showValue() ผูก index 0/1/2 กับ S/M/L)
    List<int> sellableIndexes = List<int>.generate(
            unitSizeModels!.length, (index) => index)
        .where((index) => unitSizeModels![index].price.toString() != '0')
        .toList();

    return Padding(
      padding: EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('เลือกขนาดบรรจุ', style: MyStyle().h4bStyleGray),
          SizedBox(height: 8.0),
          ...sellableIndexes.asMap().entries.map((entry) {
            int position = entry.key;
            int index = entry.value;
            int? currentQtyInCart = index == 0
                ? showSincart
                : index == 1
                    ? showMincart
                    : showLincart;
            int? limit = index == 0
                ? limitS
                : index == 1
                    ? limitM
                    : limitL;
            return Padding(
              padding: EdgeInsets.only(
                  bottom: position == sellableIndexes.length - 1 ? 0 : 10.0),
              child: PackageSizeRow(
                unitSizeModel: unitSizeModels![index],
                currentQtyInCart: currentQtyInCart,
                limit: limit,
                onQuantityChanged: (newQty) {
                  setState(() {
                    if (index == 0) {
                      qtyS = newQty;
                    } else if (index == 1) {
                      qtyM = newQty;
                    } else if (index == 2) {
                      qtyL = newQty;
                    }
                  });
                },
              ),
            );
          }),
          quickAddButtonsRow(),
        ],
      ),
    );
  }

  /// เพิ่มจำนวนแบบด่วนจากปุ่ม quick-add (btnAdd1/btnAdd2)
  /// - ถ้าไซส์นั้น (M/L) มีวางขายจริง ให้เพิ่มที่ไซส์นั้นทีละ 1 หน่วย (เช่น +1 โหล / +1 ลัง)
  /// - ถ้าไม่ได้ขายแยกไซส์นั้น ให้ไปเพิ่มที่ไซส์ S แทน ตามจำนวนตัด (subtract_m / subtract_l)
  void quickAddPack(String sizeKey, int subtractQty, bool soldSeparately) {
    setState(() {
      if (soldSeparately && sizeKey == 'm') {
        int newVal = (showMincart ?? 0) + 1;
        if (limitM != null && limitM! > 0 && newVal > limitM!) newVal = limitM!;
        showMincart = newVal;
        qtyM = newVal;
      } else if (soldSeparately && sizeKey == 'l') {
        int newVal = (showLincart ?? 0) + 1;
        if (limitL != null && limitL! > 0 && newVal > limitL!) newVal = limitL!;
        showLincart = newVal;
        qtyL = newVal;
      } else {
        int newVal = (showSincart ?? 0) + subtractQty;
        if (limitS != null && limitS! > 0 && newVal > limitS!) newVal = limitS!;
        showSincart = newVal;
        qtyS = newVal;
      }
    });
  }

  Widget quickAddButton(String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: MyStyle().mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      ),
      icon: Icon(Icons.shopping_cart, color: Colors.white, size: 16.0),
      label: Text(label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget quickAddButtonsRow() {
    List<Widget> buttons = [];

    int? subtractM = productAllModel?.subtractM;
    String? unitM = priceLabelBySize['m'];
    if (productAllModel?.btnAdd1 == 1 &&
        subtractM != null &&
        subtractM > 0 &&
        unitM != null &&
        unitM.isNotEmpty) {
      buttons.add(quickAddButton(
        '$subtractM/$unitM',
        () => quickAddPack('m', subtractM, mSoldSeparately),
      ));
    }

    int? subtractL = productAllModel?.subtractL;
    String? unitL = priceLabelBySize['l'];
    if (productAllModel?.btnAdd2 == 1 &&
        subtractL != null &&
        subtractL > 0 &&
        unitL != null &&
        unitL.isNotEmpty) {
      buttons.add(quickAddButton(
        '$subtractL/$unitL',
        () => quickAddPack('l', subtractL, lSoldSeparately),
      ));
    }

    if (buttons.isEmpty) return Container();

    return Padding(
      padding: EdgeInsets.only(top: 10.0),
      // Wrap ไม่ขยายเต็มความกว้างเอง ต้องบังคับด้วย SizedBox ไม่งั้น WrapAlignment.end จะไม่มีที่ว่างให้ชิดขวา
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: 8.0,
          runSpacing: 8.0,
          children: buttons,
        ),
      ),
    );
  }

  Widget relate() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.25,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MyStyle().radiusM),
        border: Border.all(color: MyStyle().borderColor),
      ),
      child: relateslideshowLists!.isEmpty
          ? myCircularProgress()
          : showCarouseSliderRelate(),
    );
  }

  Widget headTitle(String string, IconData iconData) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: <Widget>[
          Icon(iconData, size: 20.0, color: MyStyle().textColor),
          SizedBox(width: 8.0),
          Text(string, style: MyStyle().sectionTitleStyle),
        ],
      ),
    );
  }

  Future<void> readCart() async {

    amontCart = 0;
    String memberId = myUserModel!.id.toString();
    String url =
        '${MyStyle().serverName}/json_loadmycart.php?memberId=$memberId&screen=detaiil';


    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var cartList = result['cart'];
    for (var _ in cartList) {
      // setState(() {
      amontCart = amontCart! + 1;
      // });
    }
    setState(() {
      amontCart;
    });
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
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return DetailCart(userModel: myUserModel);
      },
    );
    Navigator.of(context).push(materialPageRoute);
  }


  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return ListProduct(index: index, userModel: myUserModel!);
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
    return Scaffold(
      backgroundColor: MyStyle().scaffoldBackground,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[showCart()],
        backgroundColor: MyStyle().bgColor,
        title: Text('ข้อมูลสินค้า', style: TextStyle(color: Colors.white)),
      ),
      body: productAllModel == null ? showProgress() : showDetailList(),
      bottomNavigationBar: stylishBottomBar(), //showBottomBarNav
    );
  }

  Widget showProgress() {
    return Center(child: CircularProgressIndicator());
  }

  Widget addButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        14.0,
        10.0,
        14.0,
        10.0 + ((myUserModel!.msg == '') ? 0 : 90.0),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: MyStyle().borderColor)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48.0,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyStyle().mainColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(MyStyle().radiusS),
            ),
          ),
          icon: Icon(Icons.add_shopping_cart, color: Colors.white),
          label: Text(
            'เพิ่มลงตะกร้า',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            String? productID = id;
            String? memberID = myUserModel!.id.toString();

            // qtyS/qtyM/qtyL เป็น null หมายถึงผู้ใช้ยังไม่แตะช่องจำนวนไซส์นั้น (ไม่ต้องทำอะไร)
            // ถ้าแตะแล้วปรับเป็น 0 และของไซส์นั้นมีอยู่ในตะกร้า ให้ลบออกจากตะกร้า
            if (qtyS != null) {
              String unitSize = 's';
              if (qtyS != 0) {
                addCart(productID!, unitSize, qtyS!, memberID);
              } else if (showSincart != 0) {
                removeCart(productID!, unitSize, memberID);
              }
            }
            if (qtyM != null) {
              String unitSize = 'm';
              if (qtyM != 0) {
                addCart(productID!, unitSize, qtyM!, memberID);
              } else if (showMincart != 0) {
                removeCart(productID!, unitSize, memberID);
              }
            }
            if (qtyL != null) {
              String unitSize = 'l';
              if (qtyL != 0) {
                addCart(productID!, unitSize, qtyL!, memberID);
              } else if (showLincart != 0) {
                removeCart(productID!, unitSize, memberID);
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> addCart(
    String productID,
    String unitSize,
    int qTY,
    String memberID,
  ) async {
    String url =
        '${MyStyle().serverName}/json_savemycart.php?productID=$productID&unitSize=$unitSize&QTY=$qTY&memberId=$memberID';
    await http.get(Uri.parse(url)).then((response) {});

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> removeCart(
    String productID,
    String unitSize,
    String memberID,
  ) async {
    String url =
        '${MyStyle().serverName}/json_removeitemincart.php?productID=$productID&unitSize=$unitSize&memberId=$memberID';
    await http.get(Uri.parse(url)).then((response) {});

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Widget showDetailList() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(child: showController()),
          addButton(),
        ],
      ),
    );
  }

  ListView showController() {
    return ListView(
      padding: EdgeInsets.all(14.0),
      children: <Widget>[
        ProductPromotionCard(
          currentPromotion: currentPromotion,
          showSincart: showSincart,
          showMincart: showMincart,
          showLincart: showLincart,
          priceLabelBySize: priceLabelBySize,
          giftMap: giftMap,
        ),
        productSummaryCard(),
        SizedBox(height: 14.0),
        moreInfoCard(),
        SizedBox(height: 14.0),
        headTitle('สินค้าที่เกี่ยวข้อง', Icons.thumb_up),
        relate(),
      ],
    );
  }
}
