import 'package:flutter/material.dart';
import 'package:ptncenter/models/near_miss_promotion.dart';
import 'package:ptncenter/models/promotion_group_model.dart';
import 'package:ptncenter/utility/my_style.dart';

/// การ์ดแจ้งเตือน "ใกล้ได้ของแถมแล้ว" / "อัปเกรดของแถมได้" ที่แสดงในหน้าตะกร้า
class NearMissSection extends StatelessWidget {
  final List<NearMissPromotion> nearMissPromotions;
  final void Function(PromotionGroupModel group) onRouteToGroupProducts;
  final void Function(String? productId) onRouteToPromoProduct;

  const NearMissSection({
    super.key,
    required this.nearMissPromotions,
    required this.onRouteToGroupProducts,
    required this.onRouteToPromoProduct,
  });

  Widget _nearMissBanner(NearMissPromotion item, {bool showDivider = true}) {
    String giftName = item.gift?.name ?? 'ของแถม';
    // level > 1 หมายถึงได้ของแถมขั้นก่อนหน้าไปแล้ว กำลังจะขยับไปขั้นที่ดีกว่า จึงเรียกว่า "อัปเกรด"
    // แทนที่จะเป็น "ใกล้ได้ของแถมแล้ว" ซึ่งสื่อถึงการได้ของแถมเป็นครั้งแรก
    String prefix = (item.level != null && item.level! > 1)
        ? 'อัปเกรดของแถมได้!'
        : 'ใกล้ได้ของแถมแล้ว!';
    String message = '$prefix "${item.sourceLabel}"'
        ' ขาดอีก ${item.remaining} ${item.remainingUnit} เพื่อรับ $giftName ${item.giftQty} ${item.giftUnit} ฟรี';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Color(0xFFFFE8A3), width: 1.0)),
            )
          : null,
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
                    onRouteToGroupProducts(item.group!);
                  } else {
                    onRouteToPromoProduct(item.productId);
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (nearMissPromotions.isEmpty) return Container();

    return Card(
      color: Color(0xFFFFFBEA),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Color(0xFFFFE8A3)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: nearMissPromotions.asMap().entries.map((entry) {
            bool isLast = entry.key == nearMissPromotions.length - 1;
            return _nearMissBanner(entry.value, showDivider: !isLast);
          }).toList(),
        ),
      ),
    );
  }
}
