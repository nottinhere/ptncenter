import 'package:ptncenter/models/promotion_tier.dart';

class MedicinePromotionModel {
  String? id;
  String? code;
  String? name;
  String? hilight;
  String? size;
  String? subtractS;
  String? subtractM;
  String? subtractL;
  String? qty;
  String? gift;
  String? getqty;
  String? limitgift;
  String? qty2;
  String? gift2;
  String? getqty2;
  String? limitgift2;
  String? qty3;
  String? gift3;
  String? getqty3;
  String? limitgift3;

  MedicinePromotionModel(
      {this.id,
      this.code,
      this.name,
      this.hilight,
      this.size,
      this.subtractS,
      this.subtractM,
      this.subtractL,
      this.qty,
      this.gift,
      this.getqty,
      this.limitgift,
      this.qty2,
      this.gift2,
      this.getqty2,
      this.limitgift2,
      this.qty3,
      this.gift3,
      this.getqty3,
      this.limitgift3});

  MedicinePromotionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    hilight = json['hilight'];
    size = json['size'];
    subtractS = json['subtract_s'];
    subtractM = json['subtract_m'];
    subtractL = json['subtract_l'];
    qty = json['qty'];
    gift = json['gift'];
    getqty = json['getqty'];
    limitgift = json['limitgift'];
    qty2 = json['qty2'];
    gift2 = json['gift2'];
    getqty2 = json['getqty2'];
    limitgift2 = json['limitgift2'];
    qty3 = json['qty3'];
    gift3 = json['gift3'];
    getqty3 = json['getqty3'];
    limitgift3 = json['limitgift3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['code'] = this.code;
    data['name'] = this.name;
    data['hilight'] = this.hilight;
    data['size'] = this.size;
    data['subtract_s'] = this.subtractS;
    data['subtract_m'] = this.subtractM;
    data['subtract_l'] = this.subtractL;
    data['qty'] = this.qty;
    data['gift'] = this.gift;
    data['getqty'] = this.getqty;
    data['limitgift'] = this.limitgift;
    data['qty2'] = this.qty2;
    data['gift2'] = this.gift2;
    data['getqty2'] = this.getqty2;
    data['limitgift2'] = this.limitgift2;
    data['qty3'] = this.qty3;
    data['gift3'] = this.gift3;
    data['getqty3'] = this.getqty3;
    data['limitgift3'] = this.limitgift3;
    return data;
  }

  /// จำนวนต่อ 1 หน่วยของขนาด [sizeKey] เทียบเป็นหน่วยฐาน (จำนวนตัด subtract_s/m/l)
  double subtractFactorFor(String sizeKey) {
    switch (sizeKey) {
      case 's':
        return double.tryParse(subtractS ?? '') ?? 0;
      case 'm':
        return double.tryParse(subtractM ?? '') ?? 0;
      case 'l':
        return double.tryParse(subtractL ?? '') ?? 0;
      default:
        return 0;
    }
  }

  /// แปลงจำนวนที่สั่งของแต่ละขนาด (S/M/L) ให้เทียบเท่าหน่วยของ [size] ที่โปรโมชันนี้กำหนดไว้
  /// โดยใช้จำนวนตัด (subtract_s/subtract_m/subtract_l) เป็นตัวคูณหน่วยฐาน
  /// เช่น size = 'm', subtract_m = 12 หมายถึง 12 ชิ้นของ size S เทียบเท่า 1 หน่วยของ size M
  double equivalentQty({
    required double qtyS,
    required double qtyM,
    required double qtyL,
  }) {
    double factorS = subtractFactorFor('s');
    double factorM = subtractFactorFor('m');
    double factorL = subtractFactorFor('l');
    double ownFactor = subtractFactorFor(size ?? '');

    if (ownFactor <= 0) {
      // ไม่มีตารางจำนวนตัดกำหนดไว้ ใช้จำนวนที่สั่งของ size เดียวกับโปรโมชันตามเดิม
      if (size == 's') return qtyS;
      if (size == 'm') return qtyM;
      if (size == 'l') return qtyL;
      return 0;
    }

    double baseUnits = (qtyS * factorS) + (qtyM * factorM) + (qtyL * factorL);
    return baseUnits / ownFactor;
  }

  /// Best (highest-threshold) tier that [cartQty] qualifies for, or null if none match.
  MedicinePromotionTier? bestTierFor(double cartQty) {
    List<MedicinePromotionTier> tiers = [
      MedicinePromotionTier(
          qty: qty3, gift: gift3, getqty: getqty3, limitgift: limitgift3, level: 3),
      MedicinePromotionTier(
          qty: qty2, gift: gift2, getqty: getqty2, limitgift: limitgift2, level: 2),
      MedicinePromotionTier(
          qty: qty, gift: gift, getqty: getqty, limitgift: limitgift, level: 1),
    ];

    for (MedicinePromotionTier tier in tiers) {
      double? tierQty = double.tryParse(tier.qty ?? '');
      if (tierQty == null || tierQty <= 0) continue;
      if ((tier.gift ?? '').isEmpty) continue;
      if (cartQty >= tierQty) return tier;
    }
    return null;
  }

  /// Lowest tier that [cartQty] has NOT reached yet, or null if every tier is met (or none defined).
  MedicinePromotionTier? nextTierFor(double cartQty) {
    List<MedicinePromotionTier> tiers = [
      MedicinePromotionTier(
          qty: qty, gift: gift, getqty: getqty, limitgift: limitgift, level: 1),
      MedicinePromotionTier(
          qty: qty2, gift: gift2, getqty: getqty2, limitgift: limitgift2, level: 2),
      MedicinePromotionTier(
          qty: qty3, gift: gift3, getqty: getqty3, limitgift: limitgift3, level: 3),
    ];

    for (MedicinePromotionTier tier in tiers) {
      double? tierQty = double.tryParse(tier.qty ?? '');
      if (tierQty == null || tierQty <= 0) continue;
      if ((tier.gift ?? '').isEmpty) continue;
      if (cartQty < tierQty) return tier;
    }
    return null;
  }
}
