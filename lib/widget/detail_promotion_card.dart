import 'package:flutter/material.dart';
import 'package:ptncenter/models/gift_model.dart';
import 'package:ptncenter/models/medicine_promotion_model.dart';
import 'package:ptncenter/utility/my_style.dart';

/// การ์ดแสดงโปรโมชันสินค้า (ซื้อครบ X ได้ของแถม) พร้อมความคืบหน้าไปยังขั้นถัดไป
/// ในหน้ารายละเอียดสินค้า
class ProductPromotionCard extends StatelessWidget {
  final MedicinePromotionModel? currentPromotion;
  final int? showSincart;
  final int? showMincart;
  final int? showLincart;
  final Map<String, String> priceLabelBySize;
  final Map<String, GiftModel> giftMap;

  const ProductPromotionCard({
    super.key,
    required this.currentPromotion,
    required this.showSincart,
    required this.showMincart,
    required this.showLincart,
    required this.priceLabelBySize,
    required this.giftMap,
  });

  String _formatNum(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
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
    MedicinePromotionModel? promo = currentPromotion;
    if (promo == null) return Container();

    double qtyS = (showSincart ?? 0).toDouble();
    double qtyM = (showMincart ?? 0).toDouble();
    double qtyL = (showLincart ?? 0).toDouble();
    double cartQty = promo.equivalentQty(qtyS: qtyS, qtyM: qtyM, qtyL: qtyL);

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
    String promoUnit = priceLabelBySize[promo.size] ?? '';
    String referenceUnit = priceLabelBySize[referenceSize] ?? promoUnit;

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

    void addTier(int level, String? qtyStr, String? giftId,
        String? getqtyStr, String? limitStr) {
      double? target = double.tryParse(qtyStr ?? '');
      if (target == null || target <= 0) return;
      if ((giftId ?? '').isEmpty) return;
      double perSet = double.tryParse(getqtyStr ?? '') ?? 0;
      double? limit = double.tryParse(limitStr ?? '');
      double? maxSetsRaw = (limit != null && limit > 0 && perSet > 0)
          ? (limit / perSet).floorToDouble()
          : null;
      tierRows.add((
        level: level,
        target: target,
        gift: giftMap[giftId],
        perSet: perSet,
        getqty: _formatNum(perSet),
        maxSetsRaw: (maxSetsRaw != null && maxSetsRaw > 0) ? maxSetsRaw : null,
        maxSets: _maxSetsText(limit, perSet),
        reached: cartQty >= target,
      ));
    }

    addTier(1, promo.qty, promo.gift, promo.getqty, promo.limitgift);
    addTier(2, promo.qty2, promo.gift2, promo.getqty2, promo.limitgift2);
    addTier(3, promo.qty3, promo.gift3, promo.getqty3, promo.limitgift3);

    if (tierRows.isEmpty) return Container();

    // หาขั้นที่ "กำลังสะสม" อยู่ตอนนี้ (ขั้นแรกที่ยังไม่ครบ limit ตามลำดับขั้น 1 -> 2 -> 3)
    // แต่ละขั้นให้ของแถมซ้ำได้ทุกๆ ครบจำนวน qty ของขั้นนั้น (ไม่เกิน limitgift ถ้ามีการกำหนด)
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
    // (เช่น ขั้น 1 ไม่มี limit แต่จำนวนถึงขั้น 2 แล้ว ต้องมองจากขั้น 2 ไม่ใช่วนอยู่ขั้น 1 ตลอดไป)
    for (var row in tierRows) {
      double currentSets = (cartQty / row.target).floorToDouble();
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
    double remainingPromoUnit = 0;
    double progress = 1.0;
    if (activeTier != null) {
      double currentSets = (cartQty / activeTier.target).floorToDouble();
      nextSetOrdinal = currentSets + 1;
      double amountForNextSet = nextSetOrdinal * activeTier.target;
      remainingPromoUnit = (amountForNextSet - cartQty).ceilToDouble();
      progress = ((cartQty - currentSets * activeTier.target) / activeTier.target)
          .clamp(0.0, 1.0);
    }
    double remainingReferenceUnit =
        (remainingPromoUnit * safeOwnFactor / safeReferenceFactor).ceilToDouble();

    return Container(
      margin: EdgeInsets.only(bottom: 14.0),
      padding: EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MyStyle().radiusM),
        border: Border.all(color: MyStyle().borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...tierRows.map((row) => Container(
                margin: EdgeInsets.only(bottom: 8.0),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: row.reached ? Color(0xFFEFF9F0) : Color(0xFFFFFBEA),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                      color: row.reached
                          ? Colors.green.shade200
                          : Color(0xFFFFE8A3)),
                ),
                child: Row(
                  children: <Widget>[
                    Text('ขั้น ${row.level}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: row.reached
                                ? Colors.green.shade800
                                : Colors.orange.shade800)),
                    SizedBox(width: 8.0),
                    Text('ซื้อครบ ${_formatNum(row.target)} $promoUnit',
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
                    if (row.reached) ...[
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
              )),
          if (showNextTier) ...[
            Divider(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: Text(
                      'จำนวนในตะกร้าปัจจุบัน ${_formatNum(cartQty)} $promoUnit',
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 12.5, color: Colors.grey.shade700)),
                ),
                SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                      'ขาดอีก ${_formatNum(remainingReferenceUnit)} $referenceUnit ได้ ${_formatNum(nextSetOrdinal)} ชุด '
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
                      'ครบ ${_formatNum(activeTier.target)} $promoUnit '
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
        ],
      ),
    );
  }
}
