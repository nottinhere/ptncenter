import 'package:ptncenter/models/gift_model.dart';

class ReceivedGiftItem {
  final String sourceLabel;
  final GiftModel? gift;
  final String sets; // จำนวนชุดที่ได้ คำนวนจากจำนวนในตะกร้า
  final String perSetQty; // จำนวนของแถมต่อชุด มาจาก getqty/getqty2/getqty3
  final String totalQty; // sets * perSetQty (ไม่เกิน limitgift ถ้ามีการกำหนด)
  final bool isInhouse; // true = โปรโมชันร้าน (inhousepromotion.json) อิงยอดรวมทั้งบิล

  ReceivedGiftItem(
      {required this.sourceLabel,
      required this.gift,
      required this.sets,
      required this.perSetQty,
      required this.totalQty,
      this.isInhouse = false});
}
