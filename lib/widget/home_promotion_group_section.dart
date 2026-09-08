import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ptncenter/models/gift_model.dart';
import 'package:ptncenter/models/promotion_group_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/list_product_promotion.dart';
import 'package:ptncenter/utility/my_style.dart';

/// การ์ดโปรโมชันกลุ่มสินค้า (เลื่อนดูได้) ที่แสดงในหน้า Home
/// แยกออกมาจาก home.dart เพื่อลดขนาดไฟล์หลัก
class PromotionGroupSection extends StatefulWidget {
  final List<PromotionGroupModel> promotionGroups;
  final Map<String, GiftModel> giftMap;
  final UserModel? userModel;

  const PromotionGroupSection({
    super.key,
    required this.promotionGroups,
    required this.giftMap,
    required this.userModel,
  });

  @override
  State<PromotionGroupSection> createState() => _PromotionGroupSectionState();
}

class _PromotionGroupSectionState extends State<PromotionGroupSection> {
  final CarouselSliderController _groupPromoController =
      CarouselSliderController();

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
      return ListProductPromotion(
        index: 6,
        userModel: widget.userModel!,
        cateName: group.name,
        promotionGroupId: group.id,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget promotionGroupCard(PromotionGroupModel group) {
    GiftModel? gift = widget.giftMap[group.gift];
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

  @override
  Widget build(BuildContext context) {
    if (widget.promotionGroups.isEmpty) return SizedBox();

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
              Text('(${widget.promotionGroups.length})',
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
            itemCount: widget.promotionGroups.length,
            itemBuilder: (context, index, realIdx) {
              return promotionGroupCard(widget.promotionGroups[index]);
            },
          ),
        ],
      ),
    );
  }
}
