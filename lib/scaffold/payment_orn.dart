import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:ptncenter/models/orn_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/orn_list.dart';
import 'package:ptncenter/scaffold/orn_menu.dart';
import 'package:ptncenter/scaffold/payment_ornlist.dart';

import 'package:ptncenter/utility/my_style.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'my_service.dart';

class PaymentOrn extends StatefulWidget {
  final UserModel? userModel;
  final String? ornId;

  const PaymentOrn({Key? key, this.userModel, this.ornId}) : super(key: key);

  @override
  _PaymentOrnState createState() => _PaymentOrnState();
}

class _PaymentOrnState extends State<PaymentOrn> {
  UserModel? myUserModel;
  String? ornId;
  OrnModel? ornModel;
  bool visible = true;
  bool paymentCompleted = false;
  String paymentCompleteTitle = 'ชำระเงินสำเร็จ';
  String paymentCompleteMessage = 'ระบบได้รับการชำระเงินของคุณเรียบร้อยแล้ว';
  Timer? scanCheckTimer;
  int selectIndex = 2;

  String selectedPayment = 'qr'; // 'qr', 'credit_card', 'bank_transfer'
  bool qrScanConfirmed = false;
  bool savingQr = false;
  final TextEditingController cardLast4Controller = TextEditingController();
  String? cardLast4Error;
  String? ccSlipImagePath;
  String? ccSlipImageError;
  final TextEditingController bankTransferNoteController = TextEditingController();
  String? qrString;

  String selectedBankTransferMethod = 'bank_transfer';
  DateTime? bankTransferDate = DateTime.now();
  TimeOfDay? bankTransferTime;
  String selectedBankOption = '5';

  static const List<Map<String, String>> bankOptions = [
    {'value': '5', 'text': '[เลขบัญชี 628-0-48240-5] ธนาคารกรุงไทย'},
    {'value': '6', 'text': '[เลขบัญชี 083-1-09996-8] ธนาคารกสิกรไทย'},
    {'value': '7', 'text': '[เลขบัญชี 613-258677-4] ธนาคารไทยพาณิชย์'},
  ];
  String? uploadedBankImagePath;
  String? bankImageError;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
    ornId = widget.ornId;
    readData();
    createQrImage();
  }

  @override
  void dispose() {
    scanCheckTimer?.cancel();
    cardLast4Controller.dispose();
    bankTransferNoteController.dispose();
    super.dispose();
  }

  void startScanCheckTimer() {
    scanCheckTimer?.cancel();
    scanCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkScanSuccess();
    });
  }

  Future<void> checkScanSuccess() async {
    String? cusCode = myUserModel?.customerCode;
    String? ornNo = ornModel?.ornNo;
    if (cusCode == null || ornNo == null) {
      return;
    }

    try {
      String url =
          'https://ptnpharma.com/shop/ajax_scanpp_success.php?cus_code=$cusCode&orn_no=$ornNo';
      http.Response response = await http.get(Uri.parse(url));
      if (response.body.trim() == '1') {
        scanCheckTimer?.cancel();
        if (mounted) {
          setState(() {
            paymentCompleted = true;
          });
        }
      }
    } catch (e) {
      print('checkScanSuccess error: $e');
    }
  }

  Future<void> createQrImage() async {
    String createqrUrl = 'https://ptnpharma.com/shop/qrpromptpay.php?orn_id=$ornId';
    http.Response response = await http.get(Uri.parse(createqrUrl));
  }

  Future<void> saveQrImage(String url) async {
    setState(() {
      savingQr = true;
    });
    try {
      http.Response response = await http.get(Uri.parse(url));
      await Gal.putImageBytes(
        response.bodyBytes,
        name: 'qr_payment_${ornId}_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึก QR ลงเครื่องแล้ว')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('บันทึก QR ไม่สำเร็จ')),
        );
      }
    }
    if (mounted) {
      setState(() {
        savingQr = false;
      });
    }
  }

  Future<void> readData() async {
    setState(() {
      visible = true;
    });

    String? memberId = myUserModel!.id;
    String url =
        '${MyStyle().serverName}/apishop/json_ornlist.php?memberId=$memberId&ornId=$ornId';
    print('url > $url');
    http.Response response = await http.get(Uri.parse(url));
    var result = json.decode(response.body);
    var itemsData = result['itemsData'];

    for (var map in itemsData) {
      ornModel = OrnModel.fromJson(map);
    }

    setState(() {
      visible = false;
    });

    if (ornModel != null && ornModel?.status == '3') {
      startScanCheckTimer();
    }
  }

  Widget infoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
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

  String formatNumber(String? value) {
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

  Widget paymentInfoCard() {
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
            infoRow(
              'เลขที่ใบส่งของ :',
              ornModel?.ornNo ?? '',
              valueStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            // infoRow('ร้านค้า :', ornModel?.shopname ?? ''),
            Divider(),
            infoRow(
              'ยอดรวม :',
              '${formatNumber(ornModel?.amount)} บาท',
              valueStyle: MyStyle().h3StyleBlue,
            ),
            ornModel?.shipping != null && ornModel?.shipping != '0'
                ? infoRow(
                    'ค่าจัดส่ง :',
                    '${formatNumber(ornModel?.shipping)} บาท',
                  )
                : Container(),
            ornModel?.cn != null && ornModel?.cn != '0'
                ? infoRow(
                    'ยาคืน :',
                    '${formatNumber(ornModel?.cn)} บาท',
                  )
                : Container(),
            infoRow(
              'ยอดชำระ :',
              '${formatNumber(ornModel?.total)} บาท',
              valueStyle: MyStyle().h3bStyleRed,
            ),



            Divider(),
            infoRow('ประเภทชำระ :', ornModel?.paytype ?? ''),
            infoRow('วันที่ชำระ :', ornModel?.paydate ?? ''),
            infoRow('สถานะเก็บบิล :', ornModel?.billingStatus ?? ''),
            infoRow('เลขที่บิล :', ornModel?.billNo ?? ''),
          ],
        ),
      ),
    );
  }

  Widget paymentOptionTile({
    required String value,
    required String label,
    required IconData icon,
    VoidCallback? onSelected,
  }) {
    bool selected = selectedPayment == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
        if (onSelected != null) {
          onSelected();
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: selected
              ? MyStyle().mainColor.withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: selected ? MyStyle().mainColor : Colors.grey.shade300,
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon,
                color: selected ? MyStyle().mainColor : Colors.grey.shade600),
            SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? MyStyle().mainColor : Colors.black87,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? MyStyle().mainColor : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget saveQrButton(String url) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: savingQr ? null : () => saveQrImage(url),
        icon: savingQr
            ? SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              )
            : Icon(Icons.download),
        label: Text(savingQr ? 'กำลังบันทึก...' : 'บันทึก QR'),
        style: OutlinedButton.styleFrom(
          foregroundColor: MyStyle().mainColor,
          side: BorderSide(color: MyStyle().mainColor),
          padding: EdgeInsets.symmetric(vertical: 12.0),
        ),
      ),
    );
  }

  Future<void> pickBankTransferDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: bankTransferDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        bankTransferDate = picked;
      });
    }
  }

  Future<void> pickBankTransferImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        uploadedBankImagePath = pickedFile.path;
        bankImageError = null;
      });
    }
  }

  Future<void> pickCcSlipImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        ccSlipImagePath = pickedFile.path;
        ccSlipImageError = null;
      });
    }
  }

  Widget bankTransferMethodOption(String value, String label) {
    final selected = selectedBankTransferMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBankTransferMethod = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        margin: EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: selected ? MyStyle().mainColor.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: selected ? MyStyle().mainColor : Colors.grey.shade300,
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? MyStyle().mainColor : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget bankTransferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Image.network(
                'https://ptnpharma.com/shop/dist/img/PTNbankaccount.png',
                fit: BoxFit.contain,
              ),
              SizedBox(height: 10.0),
              Image.network(
                'https://ptnpharma.com/shop/dist/img/PTNpayinshop.png',
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.0),
        Text('เลือกวิธีชำระ', style: MyStyle().h3bStyle),
        SizedBox(height: 8.0),
        bankTransferMethodOption('bank_transfer', 'โอนผ่านธนาคาร'),
        bankTransferMethodOption('cash_store', 'ชำระเงินสดหน้าร้าน'),
        bankTransferMethodOption('cash_delivery', 'ชำระเงินสดกับพนักงานส่งของ'),
        SizedBox(height: 8.0),
        Divider(),
        GestureDetector(
          onTap: pickBankTransferDate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 18.0, color: Colors.grey.shade600),
                SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    bankTransferDate == null
                        ? 'เลือกวันที่ชำระ'
                        : '${bankTransferDate!.day}/${bankTransferDate!.month}/${bankTransferDate!.year}',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.0),
        if (selectedBankTransferMethod == 'bank_transfer') ...[
          DropdownButtonFormField<String>(
            value: selectedBankOption,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'โอนผ่านธนาคาร',
            ),
            items: bankOptions
                .map((bank) => DropdownMenuItem<String>(
                      value: bank['value'],
                      child: Text(bank['text']!),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedBankOption = value;
                });
              }
            },
          ),
          SizedBox(height: 10.0),
          ElevatedButton.icon(
            onPressed: pickBankTransferImage,
            icon: Icon(Icons.upload_file),
            label: Text('แนบไฟล์รูปหลักฐานการชำระเงิน'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              foregroundColor: Colors.white,
            ),
          ),
          if (bankImageError != null) ...[
            SizedBox(height: 6.0),
            Text(
              bankImageError!,
              style: TextStyle(color: Colors.red, fontSize: 13.0),
            ),
          ],
          if (uploadedBankImagePath != null) ...[
            SizedBox(height: 10.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.file(
                File(uploadedBankImagePath!),
                height: 220.0,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ],
        SizedBox(height: 10.0),
        TextField(
          controller: bankTransferNoteController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'หมายเหตุ',
          ),
        ),
        SizedBox(height: 12.0),
        confirmBankTransferButton(),
      ],
    );
  }

  Widget qrPaymentSection()  {
    String ornNo = ornModel!.ornNo!;
    String qrUrl = 'https://ptnpharma.com/shop/temp/PTN-$ornNo.png';

    if (qrScanConfirmed) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: MyStyle().mainColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: MyStyle().mainColor, width: 2.0),
        ),
        child: Column(
          children: <Widget>[
            Icon(Icons.check_circle, color: MyStyle().mainColor, size: 48.0),
            SizedBox(height: 8.0),
            Text(
              'สแกนสำเร็จ',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: MyStyle().mainColor,
              ),
            ),
            SizedBox(height: 4.0),
            Text('ระบบได้รับการชำระเงินของคุณแล้ว',
                style: MyStyle().h4StyleGray),
          ],
        ),
      );
    }

    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            children: [
              Image.network('https://ptnpharma.com/shop/pages/forms/images/logo_promptpay_orn.jpg', width: 220.0, fit: BoxFit.contain),
              Image.network(qrUrl, width: 220.0, fit: BoxFit.contain),
            ],
          ),
        ),
        SizedBox(height: 12.0),
        saveQrButton(qrUrl),
        // SizedBox(height: 10.0),
        // SizedBox(
        //   width: double.infinity,
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: MyStyle().bgColor,
        //       padding: EdgeInsets.symmetric(vertical: 14.0),
        //     ),
        //     child: Text(
        //       'ฉันสแกนชำระเงินแล้ว',
        //       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //     ),
        //     onPressed: () {
        //       setState(() {
        //         qrScanConfirmed = true;
        //       });
        //     },
        //   ),
        // ),
      ],
    );
  }

  Future<void> showCardLast4Dialog() async {

    String? cusCode = myUserModel?.customerCode;
    String? ornNo = ornModel?.ornNo;
    final totalValue = ornModel?.total ?? '0';
    final surcharge = double.tryParse(totalValue.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
    final totalWithFee = surcharge * 1.015;

    try {
      String url = 'https://ptnpharma.com/shop/confirm_cc_payment.php?rd=1';
      await http.post(Uri.parse(url), body: {
        'cus_code': cusCode,
        'orn_no': ornNo,
        'orn_id': ornId,
        'strCCcode': cardLast4Controller.text,
        'totalPay': totalValue,
        'totalPayCC': totalWithFee.toString(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งข้อมูลชำระเงินไม่สำเร็จ')),
        );
      }
    }


    final dialogController =
        TextEditingController(text: cardLast4Controller.text);
    String? dialogError;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('เลข 4 หลักสุดท้ายของบัตร'),
              content: TextField(
                controller: dialogController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: (value) {
                  if (dialogError != null) {
                    setDialogState(() {
                      dialogError = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'xxxx',
                  counterText: '',
                  errorText: dialogError,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('ยกเลิก'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyStyle().bgColor,
                  ),
                  onPressed: () {
                    if (dialogController.text.length != 4) {
                      setDialogState(() {
                        dialogError = 'กรุณากรอกเลข 4 หลักสุดท้ายของบัตรให้ครบ';
                      });
                      return;
                    }
                    setState(() {
                      cardLast4Controller.text = dialogController.text;
                      cardLast4Error = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('ตกลง', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget creditCardSection() {
    String qrUrl =
        'https://ptnpharma.com/shop/pages/forms/images/qr_cc.jpg';
    final totalValue = ornModel?.total ?? '0';
    final surcharge = double.tryParse(totalValue.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
    final totalWithFee = surcharge * 1.015;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('เลข 4 หลักสุดท้ายของบัตร', style: MyStyle().h4bStyleGray),
        SizedBox(height: 6.0),
        TextField(
          controller: cardLast4Controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          onChanged: (value) {
            if (cardLast4Error != null) {
              setState(() {
                cardLast4Error = null;
              });
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'xxxx',
            counterText: '',
            errorText: cardLast4Error,
          ),
        ),
        SizedBox(height: 12.0),
        ElevatedButton.icon(
          onPressed: pickCcSlipImage,
          icon: Icon(Icons.upload_file),
          label: Text('แนบไฟล์รูปหลักฐานการชำระเงิน'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            foregroundColor: Colors.white,
          ),
        ),
        if (ccSlipImageError != null) ...[
          SizedBox(height: 6.0),
          Text(
            ccSlipImageError!,
            style: TextStyle(color: Colors.red, fontSize: 13.0),
          ),
        ],
        if (ccSlipImagePath != null) ...[
          SizedBox(height: 10.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.file(
              File(ccSlipImagePath!),
              height: 220.0,
              fit: BoxFit.contain,
            ),
          ),
        ],
        SizedBox(height: 16.0),
                Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Text(
            'ยอดชำระ: ${formatNumber(totalWithFee.toString())}   (ค่าธรรมเนียม +1.5%)',  // ${formatNumber(totalValue)} × 1.015 =
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
        SizedBox(height: 12.0),

        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(qrUrl, width: 220.0, fit: BoxFit.contain),
          ),
        ),
        SizedBox(height: 12.0),
        saveQrButton(qrUrl),
        SizedBox(height: 12.0),
        confirmCreditCardButton(totalValue, totalWithFee),
      ],
    );
  }

  Widget paymentOptionsCard() {
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
            Text('เลือกช่องทางชำระเงิน', style: MyStyle().h3bStyle),
            SizedBox(height: 12.0),
            paymentOptionTile(
              value: 'qr',
              label: 'QR พร้อมเพย์',
              icon: Icons.qr_code,
            ),
            paymentOptionTile(
              value: 'credit_card',
              label: 'บัตรเครดิต',
              icon: Icons.credit_card,
              onSelected: showCardLast4Dialog,
            ),
            paymentOptionTile(
              value: 'bank_transfer',
              label: 'โอนผ่านธนาคาร',
              icon: Icons.account_balance,
            ),
            SizedBox(height: 12.0),
            if (selectedPayment == 'qr') qrPaymentSection(),
            if (selectedPayment == 'credit_card') creditCardSection(),
            if (selectedPayment == 'bank_transfer') bankTransferSection(),
          ],
        ),
      ),
    );
  }

  static const Map<String, Map<String, dynamic>> ornStatusMap = {
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

  Widget ornStatusBox() {
    Map<String, dynamic> statusInfo = ornStatusMap[ornModel?.status] ??
        {'text': '', 'color': Colors.grey, 'icon': Icons.info};

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

  Widget paymentCompleteBox() {
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
              paymentCompleteTitle,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: MyStyle().mainColor,
              ),
            ),
            SizedBox(height: 4.0),
            Text(paymentCompleteMessage, style: MyStyle().h4StyleGray),
          ],
        ),
      ),
    );
  }

  Future<void> submitCreditCardPayment(
      String totalValue, double totalWithFee) async {
    String? cusCode = myUserModel?.customerCode;
    String? ornNo = ornModel?.ornNo;

    try {
      String url = 'https://ptnpharma.com/shop/confirm_cc_payment.php?rd=2';
      print('Submitting credit card payment to $url with cus_code=$cusCode, orn_no=$ornNo, orn_id=$ornId, strCCcode=${cardLast4Controller.text}, totalPay=$totalValue, totalPayCC=$totalWithFee');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['cus_code'] = cusCode ?? '';
      request.fields['orn_no'] = ornNo ?? '';
      request.fields['orn_id'] = ornId ?? '';
      request.fields['strCCcode'] = cardLast4Controller.text;
      request.fields['totalPay'] = totalValue;
      request.fields['totalPayCC'] = totalWithFee.toString();

      if (ccSlipImagePath != null) {
        request.files
            .add(await http.MultipartFile.fromPath('slip', ccSlipImagePath!));
      }

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        if (mounted) {
          setState(() {
            paymentCompleted = true;
            paymentCompleteTitle = 'แจ้งชำระเงินเรียบร้อย';
            paymentCompleteMessage = 'กรุณารอตรวจสอบยืนยันการชำระเงิน';
          });
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งข้อมูลชำระเงินไม่สำเร็จ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งข้อมูลชำระเงินไม่สำเร็จ')),
        );
      }
    }
  }

  Widget confirmCreditCardButton(String totalValue, double totalWithFee) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyStyle().bgColor,
          padding: EdgeInsets.symmetric(vertical: 14.0),
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text('ยืนยันการชำระเงิน', style: TextStyle(color: Colors.white)),
        onPressed: () {
          if (cardLast4Controller.text.length != 4) {
            setState(() {
              cardLast4Error = 'กรุณากรอกเลข 4 หลักสุดท้ายของบัตรให้ครบ';
            });
            return;
          }

          if (ccSlipImagePath == null) {
            setState(() {
              ccSlipImageError = 'กรุณาแนบไฟล์รูปหลักฐานการชำระเงิน';
            });
            return;
          }

          submitCreditCardPayment(totalValue, totalWithFee);
        },
      ),
    );
  }

  Future<void> submitBankTransferPayment() async {
    String? cusCode = myUserModel?.customerCode;
    String? ornNo = ornModel?.ornNo;
    String totalValue = ornModel?.total ?? '0';
    String paydate = bankTransferDate == null
        ? ''
        : '${bankTransferDate!.year}-${bankTransferDate!.month.toString().padLeft(2, '0')}-${bankTransferDate!.day.toString().padLeft(2, '0')}';
    String paytime = bankTransferTime == null
        ? ''
        : '${bankTransferTime!.hour.toString().padLeft(2, '0')}:${bankTransferTime!.minute.toString().padLeft(2, '0')}';

    try {
      String url = 'https://ptnpharma.com/shop/confirm_transfer_payment.php';
  
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['cus_code'] = cusCode ?? '';
      request.fields['orn_no'] = ornNo ?? '';
      request.fields['orn_id'] = ornId ?? '';
      request.fields['paytype'] = selectedBankTransferMethod;
      request.fields['total'] = totalValue;
      request.fields['paydate'] = paydate;
      request.fields['note'] = bankTransferNoteController.text;

      if (selectedBankTransferMethod == 'bank_transfer') {
        request.fields['bank'] = selectedBankOption;
        request.fields['paytime'] = paytime;

        if (uploadedBankImagePath != null) {
          request.files.add(await http.MultipartFile.fromPath(
              'slip', uploadedBankImagePath!));
        }
      }

      var streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        if (mounted) {
          setState(() {
            paymentCompleted = true;
            paymentCompleteTitle = 'แจ้งชำระเงินเรียบร้อย';
            paymentCompleteMessage = 'กรุณารอตรวจสอบยืนยันการชำระเงิน';
          });
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งข้อมูลชำระเงินไม่สำเร็จ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ส่งข้อมูลชำระเงินไม่สำเร็จ')),
        );
      }
    }
  }

  Widget confirmBankTransferButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: MyStyle().bgColor,
          padding: EdgeInsets.symmetric(vertical: 14.0),
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text('ยืนยันการชำระเงิน', style: TextStyle(color: Colors.white)),
        onPressed: () {
          if (selectedBankTransferMethod == 'bank_transfer' &&
              uploadedBankImagePath == null) {
            setState(() {
              bankImageError = 'กรุณาแนบไฟล์รูปหลักฐานการชำระเงิน';
            });
            return;
          }

          submitBankTransferPayment();
        },
      ),
    );
  }

    Future<void> readQRcodeORNPreview() async {
    try {
      // final qrScanString = await Navigator.push(this.context,
      //     MaterialPageRoute(builder: (context) => ScanPreviewPage()));
      var qrScanString;
      qrString = '';
      print('Before scan');
      qrScanString = await BarcodeScanner.scan();
      print('After scan');
      // print('scan result: $qrScanString');
      qrString = qrScanString!.rawContent;
      print('scan result: $qrString');

      if (qrString != null) {
        decodeQRcodeORN(qrString!);
      }
      // setState(() => scanResult = qrScanString);
    } on PlatformException catch (e) {
      print('e = $e');
    }
  }

  Future<void> decodeQRcodeORN(var code) async {
    // normalDialog(context,'xxxx','code -> $code');
    try {
      if (code != '' && code != null) {
        String? memberId = myUserModel!.id.toString();
        // id = currentOrnAllModel!.id.toString();
        String? url =
            '${MyStyle().serverName}/apishop/json_ornlist.php?memberId=$memberId&code=$code'; // &code=$code
        print("URL = $url");
        http.Response response = await http.get(Uri.parse(url));
        var result = json.decode(response.body);

        print('result (decodeQRcode) ===>>>> $result');

        int? status = result!['status'];
        String? title = 'ข้อมูลไม่ถูกต้อง';
        String? message = result!['message'];
        OrnModel? ornScanAllModel;
        print('status ===>>> $status');
        if (status == 0) {
          // normalDialog(context, 'Not found', 'ไม่พบ code :: $code ในระบบ');
          AwesomeDialog(
            context: context,
            headerAnimationLoop: false,
            dialogType: DialogType.error,
            autoHide: const Duration(seconds: 4),
            title: title,
            desc: message,
            btnOkColor: Colors.red,
            btnOkOnPress: () {},
            btnOkIcon: Icons.check_circle,
          ).show();
        } else {
          var mapItemScanOrn = result!['itemsData'];
          for (var map in mapItemScanOrn) {
            ornScanAllModel = OrnModel.fromJson(map);
          }
          MaterialPageRoute materialPageRoute =
              MaterialPageRoute(builder: (BuildContext buildContext) {
            return MenuOrn(
              ornID: ornScanAllModel!.id.toString(),
              userModel: myUserModel,
            );
          });
          Navigator.of(context).push(materialPageRoute);
        }
      }
    } catch (e) {}
  }


  Widget stylishBottomBar() {
    return StylishBottomBar(
      option: AnimatedBarOptions(
        iconStyle: IconStyle.animated,
        opacity: 0.3,
      ),
      items: [
        BottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text('Home'),
          backgroundColor: Colors.blue,
        ),
        BottomBarItem(
          icon: const Icon(Icons.medical_services),
          title: const Text('Medicine'),
          backgroundColor: Colors.green,
        ),
        BottomBarItem(
          icon: const Icon(Icons.payment),
          title: const Text('Payment'),
          backgroundColor: Colors.red,
        ),
        BottomBarItem(
          icon: const Icon(Icons.qr_code_scanner),
          title: const Text('Scan'),
          backgroundColor: Colors.brown,
        ),
      ],
      hasNotch: true,
      currentIndex: selectIndex,
      onTap: (index) {
        setState(() {
          selectIndex = index;
          if (index == 0) {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (value) => MyService(
                userModel: myUserModel,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            // routeToListProduct(0);
          } else if (index == 2) {
            MaterialPageRoute materialPageRoute =
                MaterialPageRoute(builder: (BuildContext buildContext) {
              return PaymentOrnList(
                userModel: myUserModel!,
              );
            });
            Navigator.of(context).push(materialPageRoute);
          } else if (index == 3) {
              readQRcodeORNPreview();
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: MyStyle().bgColor,
        title: Text('ชำระเงิน', style: TextStyle(color: Colors.white)),
      ),
      body: visible
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.green,
                size: 30,
              ),
            )
          : (ornModel == null)
              ? Center(child: Text('ไม่พบข้อมูล'))
              : ListView(
                  padding: EdgeInsets.all(16.0),
                  children: <Widget>[
                    paymentInfoCard(),
                    SizedBox(height: 16.0),
                    ornModel?.status != '3'
                        ? ornStatusBox()
                        : (paymentCompleted
                            ? paymentCompleteBox()
                            : paymentOptionsCard()),
                    // if (selectedPayment != 'qr') SizedBox(height: 16.0),
                    // if (selectedPayment != 'qr') confirmButton(),
                  ],
                ),
      bottomNavigationBar: stylishBottomBar(),
    );
  }
}
