import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptncenter/models/gift_model.dart';
import 'package:ptncenter/models/medicine_promotion_model.dart';
import 'package:ptncenter/widget/detail_promotion_card.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ProductPromotionCard', () {
    testWidgets('renders nothing when there is no promotion', (tester) async {
      await tester.pumpWidget(wrap(const ProductPromotionCard(
        currentPromotion: null,
        showSincart: 0,
        showMincart: 0,
        showLincart: 0,
        priceLabelBySize: {},
        giftMap: {},
      )));

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('ขั้น 1'), findsNothing);
    });

    testWidgets('renders nothing when the promotion has no usable tier',
        (tester) async {
      final promo = MedicinePromotionModel(size: 's'); // no qty/gift set
      await tester.pumpWidget(wrap(ProductPromotionCard(
        currentPromotion: promo,
        showSincart: 5,
        showMincart: 0,
        showLincart: 0,
        priceLabelBySize: const {},
        giftMap: const {},
      )));

      expect(find.text('ขั้น 1'), findsNothing);
    });

    testWidgets('shows progress toward tier 1 when not yet reached',
        (tester) async {
      final promo = MedicinePromotionModel(
        size: 's',
        qty: '10',
        gift: 'G1',
        getqty: '2',
      );
      final giftMap = {'G1': GiftModel(name: 'ยาสามัญ')};

      await tester.pumpWidget(wrap(ProductPromotionCard(
        currentPromotion: promo,
        showSincart: 4,
        showMincart: 0,
        showLincart: 0,
        priceLabelBySize: const {'s': 'เม็ด'},
        giftMap: giftMap,
      )));

      expect(find.textContaining('ขั้น 1'), findsOneWidget);
      expect(find.textContaining('ยาสามัญ'), findsWidgets);
      expect(find.textContaining('ขาดอีก'), findsOneWidget);
      expect(find.textContaining('สำเร็จ'), findsNothing);
    });

    testWidgets('marks the tier as สำเร็จ once its quantity is reached',
        (tester) async {
      final promo = MedicinePromotionModel(
        size: 's',
        qty: '10',
        gift: 'G1',
        getqty: '2',
      );
      final giftMap = {'G1': GiftModel(name: 'ยาสามัญ')};

      await tester.pumpWidget(wrap(ProductPromotionCard(
        currentPromotion: promo,
        showSincart: 10,
        showMincart: 0,
        showLincart: 0,
        priceLabelBySize: const {'s': 'เม็ด'},
        giftMap: giftMap,
      )));

      expect(find.textContaining('สำเร็จ'), findsOneWidget);
    });

    testWidgets('shows the per-set limit badge when limitgift is set',
        (tester) async {
      final promo = MedicinePromotionModel(
        size: 's',
        qty: '10',
        gift: 'G1',
        getqty: '2',
        limitgift: '4', // จำกัดของแถมไม่เกิน 4 ชิ้น -> ได้สูงสุด 2 ชุด
      );
      final giftMap = {'G1': GiftModel(name: 'ของแถม')};

      await tester.pumpWidget(wrap(ProductPromotionCard(
        currentPromotion: promo,
        showSincart: 4,
        showMincart: 0,
        showLincart: 0,
        priceLabelBySize: const {'s': 'เม็ด'},
        giftMap: giftMap,
      )));

      // ปรากฏทั้งใน badge ของแถวขั้นและในข้อความแจ้งของแถมขั้นถัดไป
      expect(find.textContaining('จำกัด 2 ชุด'), findsNWidgets(2));
    });

    testWidgets(
        'once every tier is reached, keeps tracking progress toward the next '
        'set of the highest one', (tester) async {
      final promo = MedicinePromotionModel(
        size: 's',
        qty: '10',
        gift: 'G1',
        getqty: '1',
        qty2: '20',
        gift2: 'G2',
        getqty2: '2',
      );
      final giftMap = {
        'G1': GiftModel(name: 'ของแถม1'),
        'G2': GiftModel(name: 'ของแถม2'),
      };

      await tester.pumpWidget(wrap(ProductPromotionCard(
        currentPromotion: promo,
        showSincart: 25,
        showMincart: 0,
        showLincart: 0,
        priceLabelBySize: const {'s': 'เม็ด'},
        giftMap: giftMap,
      )));

      // ขั้น 1 ถึงแล้ว (25 >= 10) และขั้น 2 ก็ถึงแล้ว (25 >= 20) -> ทั้งคู่ควรขึ้น "สำเร็จ"
      expect(find.textContaining('สำเร็จ'), findsNWidgets(2));
      // ขั้น 2 ไม่มี limitgift จึงยังไล่ตามชุดถัดไปของขั้น 2 ต่อไปได้เรื่อยๆ
      // (25 ต้องการอีก 20 หน่วยครบชุดที่ 2 ของขั้น 2 คือ 40)
      expect(find.textContaining('ขาดอีก 15 เม็ด ได้ 2 ชุด (ของขั้นที่ 2)'),
          findsOneWidget);
    });
  });
}
