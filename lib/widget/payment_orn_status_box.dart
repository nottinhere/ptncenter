import 'package:flutter/material.dart';
import 'package:ptncenter/utility/my_style.dart';

/// สถานะ ORN ทั่วไป (รอเพิ่มยา/รอชำระเงิน/ชำระแล้ว/ระหว่างจัดส่ง ฯลฯ) แสดงเมื่อ ORN
/// ยังไม่อยู่ในสถานะ "รอชำระเงิน" (status == '3')
class OrnStatusBox extends StatelessWidget {
  static const Map<String, Map<String, dynamic>> statusMap = {
    '0': {'text': '', 'color': Colors.red, 'icon': Icons.hourglass_top},
    '1': {'text': 'รอเพิ่มยา', 'color': Color(0xFF008285), 'icon': Icons.hourglass_top},
    '2': {'text': 'รอเพิ่มค่าขนส่ง', 'color': Colors.orange, 'icon': Icons.hourglass_top},
    '6': {'text': 'รอหัก cn / รวมบิล', 'color': Colors.red, 'icon': Icons.hourglass_top},
    '3': {'text': 'รอชำระเงิน', 'color': Colors.red, 'icon': Icons.hourglass_top},
    '4': {'text': 'รอตรวจสอบ', 'color': Color(0xFFD69E02), 'icon': Icons.hourglass_top},
    '5': {'text': 'ชำระแล้ว', 'color': Colors.green, 'icon': Icons.check_circle},
    '7': {'text': 'ยกเลิกโดยผู้ดูแล', 'color': Color(0xFFD17F79), 'icon': Icons.error},
    '8': {'text': 'ระหว่างจัดส่ง', 'color': Colors.green, 'icon': Icons.local_shipping},
    '9': {'text': 'จัดส่งแล้ว', 'color': Colors.green, 'icon': Icons.check_circle},
  };

  final String? status;

  const OrnStatusBox({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> statusInfo =
        statusMap[status] ?? {'text': '', 'color': Colors.grey, 'icon': Icons.info};

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Icon(statusInfo['icon'], color: statusInfo['color'], size: 48.0),
            SizedBox(height: 12.0),
            Text(
              'สถานะ ORN : ${statusInfo['text']}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: statusInfo['color'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// แจ้งว่า ORN นี้ถูกผูกไปรวมกับบิลอื่นแล้ว (bill_no ไม่ตรงกับ orn_no ของตัวเอง)
class LinkedToBillBox extends StatelessWidget {
  final String? ornNo;
  final String? billNo;

  const LinkedToBillBox({super.key, required this.ornNo, required this.billNo});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.orange.shade200, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Icon(Icons.info_outline, color: Colors.orange, size: 48.0),
            SizedBox(height: 12.0),
            Text(
              '${ornNo ?? ''} ได้ทำรายการไว้กับ ${billNo ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            SizedBox(height: 6.0),
            Text(
              'ท่านสามารถตรวจสอบหรือทำรายการได้ที่หมายเลขบิลที่แจ้ง',
              textAlign: TextAlign.center,
              style: MyStyle().h4StyleGray,
            ),
          ],
        ),
      ),
    );
  }
}

/// แจ้งผลชำระเงินสำเร็จ/รอตรวจสอบ
class PaymentCompleteBox extends StatelessWidget {
  final String title;
  final String message;

  const PaymentCompleteBox({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: MyStyle().mainColor, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            Icon(Icons.check_circle, color: MyStyle().mainColor, size: 56.0),
            SizedBox(height: 12.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: MyStyle().mainColor,
              ),
            ),
            SizedBox(height: 4.0),
            Text(message, style: MyStyle().h4StyleGray),
          ],
        ),
      ),
    );
  }
}
