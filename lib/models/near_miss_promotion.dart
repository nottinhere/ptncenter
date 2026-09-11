import 'package:ptncenter/models/gift_model.dart';
import 'package:ptncenter/models/promotion_group_model.dart';

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
  final String? sizeLabel; // ไซส์ (S/M/L) ที่เข้าเงื่อนไขโปรโมชันนี้ ถ้ามี
  final int? level; // ขั้นของ tier ที่กำลังจะไปถึง (1, 2, 3) level > 1 หมายถึงได้ของแถมขั้นก่อนหน้าแล้ว

  /// true = ได้ของแถมอย่างน้อย 1 เซ็ตแล้ว กำลังสะสมเซ็ตที่ 2 เป็นต้นไป (หรือขั้นที่สูงกว่า)
  /// ใช้เลือกข้อความ "อัปเกรดของแถมได้!" แทน "ใกล้ได้ของแถมแล้ว!"
  final bool showAsUpgrade;

  /// ลำดับเซ็ตของของแถมที่กำลังจะได้ (1 = เซ็ตแรก, 2 = เซ็ตที่สอง ...)
  /// ใช้ต่อท้ายข้อความ "อัปเกรด" ว่า "x N ชุด" เมื่อ N >= 2
  final int? nextSetNumber;

  NearMissPromotion(
      {required this.sourceLabel,
      required this.remaining,
      required this.remainingUnit,
      required this.gift,
      required this.giftQty,
      required this.giftUnit,
      required this.progress,
      this.productId,
      this.group,
      this.sizeLabel,
      this.level,
      this.showAsUpgrade = false,
      this.nextSetNumber});
}
