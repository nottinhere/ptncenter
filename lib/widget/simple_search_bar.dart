import 'package:flutter/material.dart';

/// ช่องค้นหาแบบง่าย (ไม่มี autocomplete) พร้อมไอคอนสแกนบาร์โค้ด/QR ทางขวา
/// ใช้ร่วมกันในหน้ารายการโปรด สินค้ายอดนิยม และรายการ ORN
class SimpleSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String iconAsset;
  final Decoration? decoration;

  /// เรียกเมื่อแตะไอคอนสแกนทางขวา
  final VoidCallback onScanTap;

  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  /// เรียกเมื่อกดปุ่มล้างข้อความ หลังจาก controller ถูกเคลียร์แล้ว ใช้เพิ่มเติมเมื่อหน้านั้น
  /// ต้องรีเซ็ตคำค้น/โหลดข้อมูลใหม่ด้วย (ถ้าไม่ระบุ จะแค่เคลียร์ข้อความในช่อง)
  final VoidCallback? onClear;

  const SimpleSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.iconAsset,
    required this.onScanTap,
    required this.onChanged,
    required this.onSubmitted,
    this.onClear,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: decoration,
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 2.0, bottom: 2.0),
      child: ListTile(
        trailing: SizedBox(
          width: 45.0,
          child: Image.asset(iconAsset),
        ),
        onTap: onScanTap,
        title: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          scrollPadding: EdgeInsets.all(1.00),
          style: TextStyle(
              color: Colors.blue.shade900,
              fontWeight: FontWeight.w300,
              fontSize: 18.00),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hintText,
            suffixIcon: IconButton(
              onPressed: () {
                controller.clear();
                onClear?.call();
              },
              icon: Icon(Icons.clear),
            ),
          ),
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
