import 'package:ptncenter/models/promotion_tier.dart';

class PromotionGroupModel {
  String? id;
  String? code;
  String? name;
  String? hilight;
  String? med;
  String? target;
  String? gift;
  String? getqty;
  String? limitgift;
  String? target2;
  String? gift2;
  String? getqty2;
  String? limitgift2;
  String? target3;
  String? gift3;
  String? getqty3;
  String? limitgift3;

  PromotionGroupModel(
      {this.id,
      this.code,
      this.name,
      this.hilight,
      this.med,
      this.target,
      this.gift,
      this.getqty,
      this.limitgift,
      this.target2,
      this.gift2,
      this.getqty2,
      this.limitgift2,
      this.target3,
      this.gift3,
      this.getqty3,
      this.limitgift3});

  PromotionGroupModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    hilight = json['hilight'];
    med = json['med'];
    target = json['target'];
    gift = json['gift'];
    getqty = json['getqty'];
    limitgift = json['limitgift'];
    target2 = json['target2'];
    gift2 = json['gift2'];
    getqty2 = json['getqty2'];
    limitgift2 = json['limitgift2'];
    target3 = json['target3'];
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
    data['med'] = this.med;
    data['target'] = this.target;
    data['gift'] = this.gift;
    data['getqty'] = this.getqty;
    data['limitgift'] = this.limitgift;
    data['target2'] = this.target2;
    data['gift2'] = this.gift2;
    data['getqty2'] = this.getqty2;
    data['limitgift2'] = this.limitgift2;
    data['target3'] = this.target3;
    data['gift3'] = this.gift3;
    data['getqty3'] = this.getqty3;
    data['limitgift3'] = this.limitgift3;
    return data;
  }

  List<String> get medIds =>
      (med ?? '').split(',').where((s) => s.trim().isNotEmpty).toList();

  /// Best (highest-threshold) tier that [subtotal] qualifies for, or null if none match.
  MedicinePromotionTier? bestTierFor(double subtotal) {
    List<MedicinePromotionTier> tiers = [
      MedicinePromotionTier(
          qty: target3, gift: gift3, getqty: getqty3, limitgift: limitgift3, level: 3),
      MedicinePromotionTier(
          qty: target2, gift: gift2, getqty: getqty2, limitgift: limitgift2, level: 2),
      MedicinePromotionTier(
          qty: target, gift: gift, getqty: getqty, limitgift: limitgift, level: 1),
    ];

    for (MedicinePromotionTier tier in tiers) {
      double? tierTarget = double.tryParse(tier.qty ?? '');
      if (tierTarget == null || tierTarget <= 0) continue;
      if ((tier.gift ?? '').isEmpty) continue;
      if (subtotal >= tierTarget) return tier;
    }
    return null;
  }

  /// Lowest tier that [subtotal] has NOT reached yet, or null if every tier is met (or none defined).
  MedicinePromotionTier? nextTierFor(double subtotal) {
    List<MedicinePromotionTier> tiers = [
      MedicinePromotionTier(
          qty: target, gift: gift, getqty: getqty, limitgift: limitgift, level: 1),
      MedicinePromotionTier(
          qty: target2, gift: gift2, getqty: getqty2, limitgift: limitgift2, level: 2),
      MedicinePromotionTier(
          qty: target3, gift: gift3, getqty: getqty3, limitgift: limitgift3, level: 3),
    ];

    for (MedicinePromotionTier tier in tiers) {
      double? tierTarget = double.tryParse(tier.qty ?? '');
      if (tierTarget == null || tierTarget <= 0) continue;
      if ((tier.gift ?? '').isEmpty) continue;
      if (subtotal < tierTarget) return tier;
    }
    return null;
  }
}
