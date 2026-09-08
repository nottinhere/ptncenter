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
      this.level});
}
