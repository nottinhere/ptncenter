import 'package:flutter/material.dart';

/// ช่องค้นหาสินค้าแบบ autocomplete (พร้อมไฮไลต์คำที่ตรงกับคำค้น) และปุ่มสแกนบาร์โค้ด
/// ใช้ร่วมกันในหน้ารายการสินค้า (list_product.dart) และหน้ารายการสินค้าตามโปรโมชันกลุ่ม
/// (list_product_promotion.dart)
class ProductSearchForm extends StatelessWidget {
  /// รายการคำแนะนำทั้งหมดในรูปแบบ "ชื่อ|รหัส" (โหลดจาก jsonData/medicine_unit.json)
  final List<String> suggestions;

  /// เรียกทุกครั้งที่ผู้ใช้พิมพ์ในช่องค้นหา (ยังไม่กด submit)
  final ValueChanged<String> onSearchChanged;

  /// เรียกเมื่อผู้ใช้กด submit/enter ในช่องค้นหา
  final ValueChanged<String> onSearchSubmitted;

  /// เรียกเมื่อผู้ใช้เลือกคำแนะนำจากรายการ (ค่าที่ส่งมาคือ "ชื่อ|รหัส" ดิบ)
  final ValueChanged<String> onSuggestionSelected;

  /// เรียกเมื่อผู้ใช้แตะไอคอนสแกนบาร์โค้ด
  final VoidCallback onScanBarcode;

  /// padding ของแต่ละแถวคำแนะนำ (ค่าเดิมต่างกันเล็กน้อยระหว่าง 2 หน้าที่ใช้ widget นี้)
  final EdgeInsetsGeometry optionPadding;

  const ProductSearchForm({
    super.key,
    required this.suggestions,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onSuggestionSelected,
    required this.onScanBarcode,
    this.optionPadding = const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
  });

  List<String> _searchWords(String query) {
    return query
        .toLowerCase()
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .toList();
  }

  Widget _highlightedOptionText(
      BuildContext context, String text, String query) {
    List<String> words = _searchWords(query);
    if (words.isEmpty) {
      return Text(text);
    }

    String lowerText = text.toLowerCase();
    List<TextSpan> spans = <TextSpan>[];
    int cursor = 0;

    while (cursor < text.length) {
      int bestIndex = -1;
      int bestLength = 0;
      for (String word in words) {
        int idx = lowerText.indexOf(word, cursor);
        if (idx != -1 && (bestIndex == -1 || idx < bestIndex)) {
          bestIndex = idx;
          bestLength = word.length;
        }
      }

      if (bestIndex == -1) {
        spans.add(TextSpan(text: text.substring(cursor)));
        break;
      }

      if (bestIndex > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, bestIndex)));
      }
      spans.add(TextSpan(
        text: text.substring(bestIndex, bestIndex + bestLength),
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
      cursor = bestIndex + bestLength;
    }

    TextStyle baseStyle =
        DefaultTextStyle.of(context).style.copyWith(fontSize: 15.0);
    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }

  @override
  Widget build(BuildContext context) {
    // เก็บคำค้นล่าสุดไว้ใช้ตอนไฮไลต์ผลลัพธ์ใน optionsViewBuilder (ถูกตั้งค่าจาก
    // optionsBuilder ที่ทำงานก่อนหน้าในรอบ build เดียวกันเสมอ)
    String autocompleteQuery = '';

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.00),
              width: MediaQuery.of(context).size.width * 0.85,
              child: Autocomplete<String>(
                optionsMaxHeight: 700.00,
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    onChanged: onSearchChanged,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSearchSubmitted,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ค้นหาสินค้า',
                      suffixIcon: IconButton(
                        onPressed: () => textEditingController.clear(),
                        icon: Icon(Icons.clear),
                      ),
                    ),
                  );
                },
                optionsBuilder: (TextEditingValue textEditingValue) {
                  autocompleteQuery = textEditingValue.text.trim();
                  List<String> words = _searchWords(textEditingValue.text);
                  if (words.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return suggestions.where((String option) {
                    return words.every((String word) => option.contains(word));
                  });
                },
                optionsViewBuilder: (context, onSelected, options) {
                  List<String> optionsList = options.toList();
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 700.0),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: optionsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            String option = optionsList[index];
                            String displayName = option.split('|').first;
                            return InkWell(
                              onTap: () => onSelected(option),
                              child: Padding(
                                padding: optionPadding,
                                child: _highlightedOptionText(
                                    context, displayName, autocompleteQuery),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                onSelected: onSuggestionSelected,
              ),
            ),
            GestureDetector(
              onTap: onScanBarcode,
              child: Image.asset('images/icon_barcode.png',
                  width: 50.0, height: 50.0),
            ),
          ],
        ),
      ],
    );
  }
}
