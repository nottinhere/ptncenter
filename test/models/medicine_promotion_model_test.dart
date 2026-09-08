import 'package:flutter_test/flutter_test.dart';
import 'package:ptncenter/models/medicine_promotion_model.dart';

void main() {
  group('MedicinePromotionModel.subtractFactorFor', () {
    test('returns the parsed factor for s/m/l', () {
      final promo = MedicinePromotionModel(
          subtractS: '1', subtractM: '12', subtractL: '144');
      expect(promo.subtractFactorFor('s'), 1);
      expect(promo.subtractFactorFor('m'), 12);
      expect(promo.subtractFactorFor('l'), 144);
    });

    test('returns 0 for an unknown size key', () {
      final promo = MedicinePromotionModel(subtractS: '1');
      expect(promo.subtractFactorFor('xl'), 0);
    });

    test('returns 0 when the field is null or not a number', () {
      final promo = MedicinePromotionModel(subtractS: null, subtractM: 'abc');
      expect(promo.subtractFactorFor('s'), 0);
      expect(promo.subtractFactorFor('m'), 0);
    });
  });

  group('MedicinePromotionModel.equivalentQty', () {
    test('falls back to the matching size quantity when there is no subtract table', () {
      final promo = MedicinePromotionModel(size: 'm');
      final qty = promo.equivalentQty(qtyS: 5, qtyM: 3, qtyL: 1);
      expect(qty, 3);
    });

    test('returns 0 when falling back and the promo size matches none of s/m/l', () {
      final promo = MedicinePromotionModel(size: 'xl');
      final qty = promo.equivalentQty(qtyS: 5, qtyM: 3, qtyL: 1);
      expect(qty, 0);
    });

    test('converts every size into the promo size unit using the subtract table', () {
      // size = m, subtract_m = 12 => 12 หน่วยของ S เทียบเท่า 1 หน่วยของ M
      final promo = MedicinePromotionModel(
          size: 'm', subtractS: '1', subtractM: '12', subtractL: '144');
      // qtyS=24 (=2 units of m), qtyM=1 (already 1 unit), qtyL=0
      final qty = promo.equivalentQty(qtyS: 24, qtyM: 1, qtyL: 0);
      expect(qty, 3); // (24*1 + 1*12 + 0*144) / 12 = 36/12 = 3
    });
  });

  group('MedicinePromotionModel.bestTierFor', () {
    test('returns null when no tier is configured', () {
      final promo = MedicinePromotionModel();
      expect(promo.bestTierFor(100), isNull);
    });

    test('returns null when cartQty has not reached tier 1', () {
      final promo =
          MedicinePromotionModel(qty: '10', gift: 'G1', getqty: '1');
      expect(promo.bestTierFor(5), isNull);
    });

    test('returns tier 1 once its threshold is reached', () {
      final promo =
          MedicinePromotionModel(qty: '10', gift: 'G1', getqty: '1');
      final tier = promo.bestTierFor(10);
      expect(tier, isNotNull);
      expect(tier!.level, 1);
    });

    test('returns the highest tier that qualifies, not just the first', () {
      final promo = MedicinePromotionModel(
        qty: '10',
        gift: 'G1',
        getqty: '1',
        qty2: '20',
        gift2: 'G2',
        getqty2: '2',
        qty3: '30',
        gift3: 'G3',
        getqty3: '3',
      );
      expect(promo.bestTierFor(25)!.level, 2);
      expect(promo.bestTierFor(35)!.level, 3);
    });

    test('skips a tier whose gift is empty even if the quantity qualifies', () {
      final promo = MedicinePromotionModel(
        qty: '10',
        gift: 'G1',
        getqty: '1',
        qty2: '20',
        gift2: '', // ไม่มีของแถมของขั้นนี้ ถือว่าขั้นนี้ไม่ถูกตั้งค่า
        getqty2: '2',
      );
      expect(promo.bestTierFor(25)!.level, 1);
    });
  });
}
