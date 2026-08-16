class MedicinePromotionTier {
  final String? qty;
  final String? gift;
  final String? getqty;
  final String? limitgift;
  final int? level; // ขั้นของโปรโมชัน (1, 2, 3) ระบุว่ามาจาก qty/qty2/qty3 (หรือ target/target2/target3)

  MedicinePromotionTier(
      {this.qty, this.gift, this.getqty, this.limitgift, this.level});
}
