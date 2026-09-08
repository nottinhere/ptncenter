import 'package:flutter/material.dart';
import 'package:ptncenter/models/received_gift_item.dart';
import 'package:ptncenter/models/rewardredeem_model.dart';
import 'package:ptncenter/utility/my_style.dart';

Widget _storeGiftBadge() {
  Color color = Colors.pink;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Text(
      'ของสมนาคุณจากทางร้าน',
      style: TextStyle(color: color, fontSize: 12.0, fontWeight: FontWeight.bold),
    ),
  );
}

Widget _rewardTypeBadge(bool isFree) {
  Color color = isFree ? Colors.green : Colors.blue;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Text(
      isFree ? 'ของแถม' : 'แลกคะแนน',
      style: TextStyle(color: color, fontSize: 12.0, fontWeight: FontWeight.bold),
    ),
  );
}

/// การ์ดสรุปคะแนนสะสมที่จะได้รับจากคำสั่งซื้อนี้
class ExtraPointSummaryBadge extends StatelessWidget {
  final double points;
  const ExtraPointSummaryBadge({super.key, required this.points});

  String _formatNum(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFFFF3D6),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Color(0xFFFFE0A3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.star, size: 16.0, color: Color(0xFFF5A623)),
          SizedBox(width: 6.0),
          Flexible(
            child: Text(
              'คุณจะได้รับ ${_formatNum(points)} คะแนน (อาจปรับตามสินค้าที่ได้รับจริง)',
              style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A5B00)),
            ),
          ),
        ],
      ),
    );
  }
}

/// รายการ "ของสมนาคุณที่เลือก" (แลกคะแนน/ของแถม) ในหน้าตะกร้า
class RewardSection extends StatelessWidget {
  final List<RewardredeemModel> rewardredeemModels;
  const RewardSection({super.key, required this.rewardredeemModels});

  bool _isFreeGift(RewardredeemModel reward) {
    String? point = reward.point;
    return point == null || point.isEmpty || point == '0';
  }

  Widget _rewardItemTile(RewardredeemModel reward) {
    bool isFree = _isFreeGift(reward);
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
                      _rewardTypeBadge(isFree),
                    ],
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
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
              padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
              child: ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: rewardredeemModels.length,
                itemBuilder: (BuildContext buildContext, int index) {
                  return _rewardItemTile(rewardredeemModels[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// รายการ "รายการพิเศษที่ได้รับ" (ของแถมจากโปรโมชัน) ในหน้าตะกร้า
class PromotionSuccessSection extends StatelessWidget {
  final List<ReceivedGiftItem> giftItems;
  final Map<String, String> unitNameMap;
  const PromotionSuccessSection(
      {super.key, required this.giftItems, required this.unitNameMap});

  Widget _receivedGiftTile(ReceivedGiftItem item) {
    String unitName = unitNameMap[item.gift?.unit] ?? '';

    // ถ้าโดน limitgift ตัดยอดจนไม่เท่ากับ perSetQty x sets จริง (เช่น limit น้อยกว่า
    // 1 ชุดเต็ม) การโชว์ breakdown "x sets" จะขัดกับยอดรวมที่แสดง จึงซ่อน breakdown ไว้
    double perSetVal = double.tryParse(item.perSetQty) ?? 0;
    double setsVal = double.tryParse(item.sets) ?? 0;
    double totalVal = double.tryParse(item.totalQty) ?? 0;
    bool showBreakdown =
        perSetVal <= 0 || (perSetVal * setsVal) <= totalVal + 0.0001;

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
                      item.isInhouse ? _storeGiftBadge() : _rewardTypeBadge(true),
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
            if (showBreakdown) ...[
              SizedBox(width: 10.0),
              Text('${item.perSetQty} $unitName x ${item.sets} ชุด',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
            SizedBox(width: 10.0),
            Text('${item.totalQty} $unitName',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
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
            ...giftItems.map(_receivedGiftTile),
          ],
        ),
      ),
    );
  }
}
