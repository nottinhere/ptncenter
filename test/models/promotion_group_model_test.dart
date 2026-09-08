import 'package:flutter_test/flutter_test.dart';
import 'package:ptncenter/models/promotion_group_model.dart';

void main() {
  group('PromotionGroupModel.medIds', () {
    test('splits a comma-separated med list', () {
      final group = PromotionGroupModel(med: '101,102,103');
      expect(group.medIds, ['101', '102', '103']);
    });

    test('drops empty/whitespace-only entries', () {
      final group = PromotionGroupModel(med: '101,, 102 ,');
      expect(group.medIds, ['101', ' 102 ']);
    });

    test('returns an empty list when med is null or empty', () {
      expect(PromotionGroupModel(med: null).medIds, isEmpty);
      expect(PromotionGroupModel(med: '').medIds, isEmpty);
    });
  });

  group('PromotionGroupModel.bestTierFor', () {
    test('returns null when subtotal has not reached any tier', () {
      final group =
          PromotionGroupModel(target: '500', gift: 'G1', getqty: '1');
      expect(group.bestTierFor(499), isNull);
    });

    test('returns the highest tier the subtotal qualifies for', () {
      final group = PromotionGroupModel(
        target: '500',
        gift: 'G1',
        getqty: '1',
        target2: '1000',
        gift2: 'G2',
        getqty2: '2',
      );
      expect(group.bestTierFor(500)!.level, 1);
      expect(group.bestTierFor(1000)!.level, 2);
    });

    test('ignores a tier with no target quantity configured', () {
      final group = PromotionGroupModel(
        target: '500',
        gift: 'G1',
        getqty: '1',
        target2: null,
        gift2: 'G2',
      );
      expect(group.bestTierFor(1000000)!.level, 1);
    });
  });
}
