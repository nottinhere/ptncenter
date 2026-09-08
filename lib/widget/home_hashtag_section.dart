import 'package:flutter/material.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/utility/my_style.dart';

/// คำ/แฮชแท็กยอดนิยม 1 รายการ (คำค้นหา, ชื่อสามัญ หรือข้อบ่งใช้) พร้อมจำนวนครั้งที่ถูกค้นหา
class HashtagItem {
  final String label;
  final int count;
  HashtagItem(this.label, this.count);
}

/// การ์ดแท็กยอดนิยม 3 แท็บ (คำค้นหา/ชื่อสามัญ/ข้อบ่งใช้) ในหน้า Home
/// แยกออกมาจาก home.dart เพื่อลดขนาดไฟล์หลัก
class HashtagSection extends StatefulWidget {
  final List<HashtagItem> bestSearchTags;
  final List<HashtagItem> bestGenericTags;
  final List<HashtagItem> bestIndyTags;
  final UserModel? userModel;

  /// เรียกหลังกลับจากหน้าค้นหาสินค้าตามแท็ก ให้หน้า Home รีเฟรชตะกร้า/badge ของตัวเอง
  final VoidCallback? onReturnFromSearch;

  const HashtagSection({
    super.key,
    required this.bestSearchTags,
    required this.bestGenericTags,
    required this.bestIndyTags,
    required this.userModel,
    this.onReturnFromSearch,
  });

  @override
  State<HashtagSection> createState() => _HashtagSectionState();
}

class _HashtagSectionState extends State<HashtagSection> {
  int hashtagTabIndex = 0;

  List<HashtagItem> get activeHashtagItems {
    switch (hashtagTabIndex) {
      case 1:
        return widget.bestGenericTags;
      case 2:
        return widget.bestIndyTags;
      default:
        return widget.bestSearchTags;
    }
  }

  void searchByTag(String query) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: 0,
        userModel: widget.userModel!,
        searchStr: query,
      );
    });
    Navigator.of(context)
        .push(materialPageRoute)
        .then((value) => widget.onReturnFromSearch?.call());
  }

  Widget hashtagChip(String label) {
    return GestureDetector(
      onTap: () => searchByTag(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: MyStyle().mainColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          '#$label',
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget hashtagTabButton(int index, IconData icon, String label) {
    bool active = hashtagTabIndex == index;
    Color color = active ? MyStyle().mainColor : Colors.grey.shade500;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => hashtagTabIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 16.0, color: color),
                  SizedBox(width: 4.0),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: active ? FontWeight.bold : FontWeight.w500,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2.5,
              color: active ? MyStyle().mainColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bestSearchTags.isEmpty &&
        widget.bestGenericTags.isEmpty &&
        widget.bestIndyTags.isEmpty) {
      return SizedBox();
    }

    List<HashtagItem> items = activeHashtagItems.take(18).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(MyStyle().radiusM),
          border: Border.all(color: MyStyle().borderColor),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                hashtagTabButton(0, Icons.search_rounded, 'คำค้นหายอดนิยม'),
                hashtagTabButton(
                    1, Icons.medication_rounded, 'ชื่อสามัญยอดนิยม'),
                hashtagTabButton(
                    2, Icons.assignment_outlined, 'ข้อบ่งใช้ยอดนิยม'),
              ],
            ),
            Divider(height: 1.0, color: MyStyle().borderColor),
            Padding(
              padding: EdgeInsets.all(14.0),
              child: items.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child:
                          Text('ไม่มีข้อมูล', style: MyStyle().captionStyle),
                    )
                  : Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: items
                          .map((item) => hashtagChip(item.label))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
