import 'package:flutter/material.dart';
import 'package:ptncenter/models/orn_model.dart';
import 'package:ptncenter/utility/my_style.dart';

/// การ์ดสรุปข้อมูลใบส่งของ (เลขที่/ยอดรวม/ค่าจัดส่ง/ยาคืน/ยอดชำระ/สถานะ) ในหน้าชำระเงิน ORN
class PaymentOrnInfoCard extends StatelessWidget {
  final OrnModel? ornModel;

  const PaymentOrnInfoCard({super.key, required this.ornModel});

  String _formatNumber(String? value) {
    if (value == null || value.toString().trim().isEmpty) {
      return '';
    }

    final cleaned = value.toString().trim().replaceAll(RegExp(r'[^0-9.-]'), '');
    if (cleaned.isEmpty) {
      return '';
    }

    final number = double.tryParse(cleaned);
    if (number == null) {
      return value.toString().trim();
    }

    final parts = number.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '$integerPart.${parts[1]}';
  }

  Widget _infoRow(BuildContext context, String label, String value,
      {TextStyle? valueStyle}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.32,
            child: Text(label, style: MyStyle().h4bStyleGray),
          ),
          Expanded(
            child: Text(value, style: valueStyle ?? MyStyle().h3Style),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _infoRow(
              context,
              'เลขที่ใบส่งของ :',
              ornModel?.ornNo ?? '',
              valueStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Divider(),
            _infoRow(
              context,
              'ยอดรวม :',
              '${_formatNumber(ornModel?.amount)} บาท',
              valueStyle: MyStyle().h3StyleBlue,
            ),
            ornModel?.shipping != null && ornModel?.shipping != '0'
                ? _infoRow(
                    context,
                    'ค่าจัดส่ง :',
                    '${_formatNumber(ornModel?.shipping)} บาท',
                  )
                : Container(),
            ornModel?.cn != null && ornModel?.cn != '0'
                ? _infoRow(
                    context,
                    'ยาคืน :',
                    '${_formatNumber(ornModel?.cn)} บาท',
                  )
                : Container(),
            _infoRow(
              context,
              'ยอดชำระ :',
              '${_formatNumber(ornModel?.total)} บาท',
              valueStyle: MyStyle().h3bStyleRed,
            ),
            Divider(),
            _infoRow(context, 'ประเภทชำระ :', ornModel?.paytype ?? ''),
            _infoRow(context, 'วันที่ชำระ :', ornModel?.paydate ?? ''),
            _infoRow(
                context, 'สถานะเก็บบิล :', ornModel?.billingStatus ?? ''),
            _infoRow(context, 'เลขที่บิล :', ornModel?.billNo ?? ''),
          ],
        ),
      ),
    );
  }
}
