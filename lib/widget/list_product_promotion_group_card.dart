import 'package:flutter/material.dart';
import 'package:ptncenter/models/gift_model.dart';
import 'package:ptncenter/models/promotion_group_model.dart';
import 'package:ptncenter/utility/my_style.dart';

/// การ์ดแสดงโปรโมชันกลุ่มสินค้า (ซื้อครบยอด X ในกลุ่มนี้ได้ของแถม) พร้อมความคืบหน้า
/// ไปยังขั้นถัดไป ในหน้ารายการสินค้าตามโปรโมชันกลุ่ม
class GroupPromotionCard extends StatelessWidget {
  final PromotionGroupModel? currentPromotionGroup;

  /// มูลค่าสินค้าในตะกร้าแยกตาม productId ใช้รวมยอดเฉพาะสินค้าที่อยู่ในกลุ่มนี้
  final Map<int, double> cartValueByProduct;
  final Map<String, GiftModel> giftMap;

  const GroupPromotionCard({
    super.key,
    required this.currentPromotionGroup,
    required this.cartValueByProduct,
    required this.giftMap,
  });

  String _formatNum(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  String _formatPromotionTarget(String? target) {
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
  String? _maxSetsText(double? limit, double perSet) {
    if (limit == null || limit <= 0 || perSet <= 0) return null;
    double maxSets = (limit / perSet).floorToDouble();
    if (maxSets <= 0) return null;
    return _formatNum(maxSets);
  }

  @override
  Widget build(BuildContext context) {
    PromotionGroupModel? group = currentPromotionGroup;
    if (group == null) return Container();

    double subtotal = 0;
    for (String idStr in group.medIds) {
      int? id = int.tryParse(idStr);
      if (id == null) continue;
      subtotal += cartValueByProduct[id] ?? 0;
    }

    List<
        ({
          int level,
          double target,
          GiftModel? gift,
          double perSet,
          String getqty,
          double? maxSetsRaw,
          String? maxSets,
          bool reached
        })> tierRows = [];

    void addTier(int level, String? targetStr, String? giftId,
        String? getqtyStr, String? limitStr) {
      double? target = double.tryParse(targetStr ?? '');
      if (target == null || target <= 0) return;
      if ((giftId ?? '').isEmpty) return;
      double perSet = double.tryParse(getqtyStr ?? '') ?? 0;
      double? limit = double.tryParse(limitStr ?? '');
      double? maxSetsRaw =
          (limit != null && limit > 0 && perSet > 0) ? (limit / perSet).floorToDouble() : null;
      tierRows.add((
        level: level,
        target: target,
        gift: giftMap[giftId],
        perSet: perSet,
        getqty: _formatNum(perSet),
        maxSetsRaw: (maxSetsRaw != null && maxSetsRaw > 0) ? maxSetsRaw : null,
        maxSets: _maxSetsText(limit, perSet),
        reached: subtotal >= target,
      ));
    }

    addTier(1, group.target, group.gift, group.getqty, group.limitgift);
    addTier(2, group.target2, group.gift2, group.getqty2, group.limitgift2);
    addTier(3, group.target3, group.gift3, group.getqty3, group.limitgift3);

    if (tierRows.isEmpty) return Container();

    // หาขั้นที่ "กำลังสะสม" อยู่ตอนนี้ (ขั้นแรกที่ยังไม่ครบ limit ตามลำดับขั้น 1 -> 2 -> 3)
    // แต่ละขั้นให้ของแถมซ้ำได้ทุกๆ ครบยอด target ของขั้นนั้น (ไม่เกิน limitgift ถ้ามีการกำหนด)
    // ถ้าขั้นนั้นไม่มี limit จะค้างเป็นขั้นที่กำลังสะสมไปเรื่อยๆ ไม่ข้ามไปขั้นถัดไป
    ({
      int level,
      double target,
      GiftModel? gift,
      double perSet,
      String getqty,
      double? maxSetsRaw,
      String? maxSets,
      bool reached
    })? activeTier;
    // รอบแรก: หาขั้นที่ "ถึงแล้วและยังไม่ครบ limit" ที่สูงที่สุด (ไล่ overwrite ขึ้นไปเรื่อยๆ)
    // เพราะถ้าถึงขั้นที่สูงกว่าแล้ว ควรมองความคืบหน้าจากขั้นนั้น ไม่ใช่ขั้นล่างที่ยังไม่ครบ limit
    // (เช่น ขั้น 1 ไม่มี limit แต่ยอดถึงขั้น 2 แล้ว ต้องมองจากขั้น 2 ไม่ใช่วนอยู่ขั้น 1 ตลอดไป)
    for (var row in tierRows) {
      double currentSets = (subtotal / row.target).floorToDouble();
      bool maxedOut = row.maxSetsRaw != null && currentSets >= row.maxSetsRaw!;
      if (row.reached && !maxedOut) {
        activeTier = row;
      }
    }
    // รอบสอง: ถ้าไม่มีขั้นที่ถึงแล้วและยังไม่ครบ limit เลย (ยังไม่ถึงขั้นไหนเลย หรือถึงแล้วแต่ครบ
    // limit หมดทุกขั้น) ให้มองไปยังขั้นถัดไปที่ยังไม่ถึง (ไล่จากขั้นต่ำสุดที่ยังไม่ถึง)
    if (activeTier == null) {
      for (var row in tierRows) {
        if (!row.reached) {
          activeTier = row;
          break;
        }
      }
    }

    bool showNextTier = activeTier != null;
    double nextSetOrdinal = 0;
    double remaining = 0;
    double progress = 1.0;
    if (activeTier != null) {
      double currentSets = (subtotal / activeTier.target).floorToDouble();
      nextSetOrdinal = currentSets + 1;
      double amountForNextSet = nextSetOrdinal * activeTier.target;
      remaining = (amountForNextSet - subtotal).ceilToDouble();
      progress = ((subtotal - currentSets * activeTier.target) / activeTier.target)
          .clamp(0.0, 1.0);
    }

    // ขั้นสูงสุดที่ถึงแล้วถือเป็นขั้น "ปัจจุบัน" (เขียว + สำเร็จ) ส่วนขั้นที่ถึงแล้วแต่ต่ำกว่านั้น
    // ถือว่า "ผ่านไปแล้ว" ให้แสดงเป็นสีเทาเฉยๆ ไม่ต้องมีข้อความสำเร็จซ้ำ
    int highestReachedLevel = 0;
    for (var row in tierRows) {
      if (row.reached && row.level > highestReachedLevel) {
        highestReachedLevel = row.level;
      }
    }

    return Container(
      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
      padding: EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MyStyle().radiusM),
        border: Border.all(color: MyStyle().borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...tierRows.map((row) {
            bool isCurrent = row.reached && row.level == highestReachedLevel;
            bool isSurpassed = row.reached && !isCurrent;
            return Container(
                margin: EdgeInsets.only(bottom: 8.0),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Color(0xFFEFF9F0)
                      : isSurpassed
                          ? Colors.grey.shade100
                          : Color(0xFFFFFBEA),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                      color: isCurrent
                          ? Colors.green.shade200
                          : isSurpassed
                              ? Colors.grey.shade300
                              : Color(0xFFFFE8A3)),
                ),
                child: Row(
                  children: <Widget>[
                    Text('ขั้น ${row.level}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: isCurrent
                                ? Colors.green.shade800
                                : isSurpassed
                                    ? Colors.grey.shade600
                                    : Colors.orange.shade800)),
                    SizedBox(width: 8.0),
                    Text(
                        'ซื้อครบ ${_formatPromotionTarget(row.target.toString())}',
                        style:
                            TextStyle(fontSize: 12.5, color: Colors.grey.shade800)),
                    SizedBox(width: 4.0),
                    Icon(Icons.arrow_forward, size: 12.0, color: Colors.grey.shade600),
                    SizedBox(width: 4.0),
                    Icon(Icons.card_giftcard, size: 14.0, color: Colors.red.shade400),
                    SizedBox(width: 4.0),
                    Expanded(
                      child: Text('${row.gift?.name ?? 'ของแถม'} x${row.getqty}',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (row.maxSets != null) ...[
                      SizedBox(width: 6.0),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade200),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text('จำกัด ${row.maxSets} ชุด',
                            style: TextStyle(
                                fontSize: 10.0, color: Colors.orange.shade800)),
                      ),
                    ],
                    if (isCurrent) ...[
                      SizedBox(width: 6.0),
                      Icon(Icons.check_circle, size: 14.0, color: Colors.green),
                      SizedBox(width: 2.0),
                      Text('สำเร็จ',
                          style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ],
                  ],
                ),
              );
          }),
          if (showNextTier) ...[
            Divider(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text('ยอดในกลุ่มปัจจุบัน ${_formatNum(subtotal)} บาท',
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
                ),
                SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                      'ขาดอีก ${_formatNum(remaining)} บาท ได้ ${_formatNum(nextSetOrdinal)} ชุด '
                      '(ของขั้นที่ ${activeTier.level})',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800)),
                ),
              ],
            ),
            SizedBox(height: 6.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8.0,
                backgroundColor: Color(0xFFFFE8A3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Color(0xFFFFFBEA),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Color(0xFFFFE8A3)),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.card_giftcard, size: 16.0, color: Colors.red.shade400),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'ครบ ${_formatPromotionTarget(activeTier.target.toString())} '
                      'รับ ${activeTier.gift?.name ?? 'ของแถม'} x${activeTier.getqty} ต่อชุด'
                      '${activeTier.maxSets != null ? ' (จำกัด ${activeTier.maxSets} ชุด)' : ''}',
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
