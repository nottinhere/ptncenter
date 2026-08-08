import 'package:ptncenter/models/promotion_tier.dart';

class MedicinePromotionModel {
  String? id;
  String? code;
  String? name;
  String? hilight;
  String? size;
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

  /// Best (highest-threshold) tier that [cartQty] qualifies for, or null if none match.
  MedicinePromotionTier? bestTierFor(double cartQty) {
    List<MedicinePromotionTier> tiers = [
      MedicinePromotionTier(
          qty: qty3, gift: gift3, getqty: getqty3, limitgift: limitgift3),
      MedicinePromotionTier(
          qty: qty2, gift: gift2, getqty: getqty2, limitgift: limitgift2),
      MedicinePromotionTier(
          qty: qty, gift: gift, getqty: getqty, limitgift: limitgift),
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
          qty: qty, gift: gift, getqty: getqty, limitgift: limitgift),
      MedicinePromotionTier(
          qty: qty2, gift: gift2, getqty: getqty2, limitgift: limitgift2),
      MedicinePromotionTier(
          qty: qty3, gift: gift3, getqty: getqty3, limitgift: limitgift3),
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
