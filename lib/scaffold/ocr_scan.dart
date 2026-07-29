import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ptncenter/models/product_all_model.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/my_service.dart';
import 'package:ptncenter/scaffold/reward_list.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class OcrLookupResult {
  final String code;
  final String matchType;
  final ProductAllModel? product;

  OcrLookupResult({required this.code, required this.matchType, this.product});
}

class OcrScan extends StatefulWidget {
  final UserModel? userModel;

  const OcrScan({Key? key, this.userModel}) : super(key: key);

  @override
  _OcrScanState createState() => _OcrScanState();
}

class _OcrScanState extends State<OcrScan> {
  UserModel? myUserModel;
  final ImagePicker picker = ImagePicker();
  final TextRecognizer textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  // ลำดับความน่าเชื่อถือ: บาร์โค้ดสินค้า > โค้ดภายในระบบ 5 หลัก > ชื่อสินค้า
  final RegExp barcodeRegex = RegExp(r'\b\d{13}\b|\b\d{12}\b|\b\d{8}\b');
  final RegExp internalCodeRegex = RegExp(r'\b\d{5}\b');
  final RegExp numericOnlyRegex = RegExp(r'^[\d\s.,%/-]+$');
  // ตัดเอาคำแรกของ block ชื่อสินค้ามาเป็น keyword (ตัวอักษร+ตัวเลขผสมกันได้ เช่น "3M", "Acetin200")
  final RegExp firstWordRegex = RegExp(r'[A-Za-z0-9]+');

  File? pickedImage;
  bool scanning = false;
  List<OcrLookupResult> results = [];
  int selectIndex = 1;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      pickedImage = File(pickedFile.path);
      results = [];
    });

    await scanAndLookup(pickedImage!);
  }

  List<String> extractBarcodesFromLine(String text) {
    // กรณีเลขบาร์โค้ดติดกันไม่มีช่องว่างปน อาจมีมากกว่าหนึ่งอันอยู่ในบรรทัดเดียวกัน
    List<String> found = [];
    for (Match embedded in barcodeRegex.allMatches(text)) {
      String? value = embedded.group(0);
      if (value != null && !found.contains(value)) found.add(value);
    }
    if (found.isNotEmpty) return found;

    // กรณี OCR อ่านเลขบาร์โค้ดแบบเว้นวรรคเป็นกลุ่ม เช่น "8 850336 100088"
    String collapsed = text.replaceAll(RegExp(r'\s+'), '');
    if (RegExp(r'^\d{8}$|^\d{12}$|^\d{13}$').hasMatch(collapsed)) {
      found.add(collapsed);
    }
    return found;
  }

  Future<void> scanAndLookup(File image) async {
    setState(() {
      scanning = true;
    });

    List<String> barcodes = [];
    List<String> internalCodes = [];
    List<String> nameCandidates = [];

    try {
      InputImage inputImage = InputImage.fromFile(image);
      RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      print('OCR full text: ${recognizedText.text}');

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String lineText = line.text.trim();
          if (lineText.isEmpty) continue;

          List<String> lineBarcodes = extractBarcodesFromLine(lineText);
          if (lineBarcodes.isNotEmpty) {
            for (String barcodeValue in lineBarcodes) {
              if (!barcodes.contains(barcodeValue)) barcodes.add(barcodeValue);
            }
            continue;
          }

          Match? codeMatch = internalCodeRegex.firstMatch(lineText);
          if (codeMatch != null) {
            String value = codeMatch.group(0)!;
            if (!internalCodes.contains(value)) internalCodes.add(value);
            continue;
          }

          // แต่ละบรรทัดที่ไม่ใช่บาร์โค้ด/โค้ดภายใน และไม่ใช่ตัวเลขล้วน
          // ถือเป็นชื่อสินค้าหนึ่งตัว - หนึ่งรูปมีโอกาสเจอชื่อสินค้าได้หลายคำ/หลายบรรทัด
          bool looksNumeric = numericOnlyRegex.hasMatch(lineText);
          if (!looksNumeric && !nameCandidates.contains(lineText)) {
            nameCandidates.add(lineText);
          }
        }
      }

      print('OCR barcodes found: $barcodes');
      print('OCR internal codes found: $internalCodes');
      print('OCR name candidates found: $nameCandidates');
    } catch (e) {
      print('OCR error: $e');
    }

    List<OcrLookupResult> lookupResults = [];

    if (barcodes.isNotEmpty) {
      for (String barcode in barcodes) {
        ProductAllModel? product = await lookupProductByBarcode(barcode);
        lookupResults.add(OcrLookupResult(
            code: barcode, matchType: 'บาร์โค้ด', product: product));
      }
    } else if (internalCodes.isNotEmpty) {
      for (String code in internalCodes) {
        ProductAllModel? product = await lookupProductByCode(code);
        lookupResults.add(
            OcrLookupResult(code: code, matchType: 'โค้ดสินค้า', product: product));
      }
    } else if (nameCandidates.isNotEmpty) {
      for (String candidate in nameCandidates) {
        Match? firstMatch = firstWordRegex.firstMatch(candidate);
        String? keyword = firstMatch?.group(0);
        // keyword ที่นำไปค้นหาต้องยาวอย่างน้อย 5 ตัวอักษร ไม่งั้นถือว่าไม่น่าเชื่อถือพอ
        if (keyword == null || keyword.length < 5) continue;

        List<ProductAllModel> products = await lookupProductByKeyword(keyword);
        if (products.isEmpty) {
          lookupResults.add(
              OcrLookupResult(code: keyword, matchType: 'ชื่อสินค้า', product: null));
        } else {
          for (ProductAllModel product in products) {
            lookupResults.add(OcrLookupResult(
                code: keyword, matchType: 'ชื่อสินค้า', product: product));
          }
        }
      }
    }

    setState(() {
      results = lookupResults;
      scanning = false;
    });
  }

  Future<ProductAllModel?> lookupProductByBarcode(String barcode) async {
    String? memberId = myUserModel?.id;
    String url = '${MyStyle().serverName}/apishop/json_productlist.php'
        '?memberId=$memberId&bqcode=$barcode&page=1';
    print('url > $url');
    return _fetchFirstProduct(url);
  }

  Future<ProductAllModel?> lookupProductByCode(String code) async {
    String? memberId = myUserModel?.id;
    String url = '${MyStyle().serverName}/apishop/json_productlist.php'
        '?memberId=$memberId&searchKey=x|$code&page=1';
    print('url > $url');
    return _fetchFirstProduct(url);
  }

  Future<List<ProductAllModel>> lookupProductByKeyword(String keyword) async {
    String? memberId = myUserModel?.id;
    String url = '${MyStyle().serverName}/apishop/json_productlist.php'
        '?memberId=$memberId&searchKey=ocr|${Uri.encodeComponent(keyword)}&page=1';
    print('url > $url');
    return _fetchAllProduct(url);
  }

  Future<ProductAllModel?> _fetchFirstProduct(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      int status = result['status'] ?? 0;
      if (status == 0) return null;

      var itemsProduct = result['itemsProduct'];
      if (itemsProduct is List && itemsProduct.isNotEmpty) {
        return ProductAllModel.fromJson(itemsProduct[0]);
      }
    } catch (e) {
      print('lookup error: $e');
    }
    return null;
  }

  Future<List<ProductAllModel>> _fetchAllProduct(String url) async {
    try {
      http.Response response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      int status = result['status'] ?? 0;
      if (status == 0) return [];

      var itemsProduct = result['itemsProduct'];
      if (itemsProduct is List) {
        return itemsProduct
            .map((item) => ProductAllModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('lookup error: $e');
    }
    return [];
  }

  void routeToDetail(ProductAllModel product) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return Detail(userModel: myUserModel, productAllModel: product);
    });
    Navigator.of(context).push(materialPageRoute);
  }

  Widget pickImageButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(backgroundColor: MyStyle().bgColor),
              icon: Icon(Icons.camera_alt, color: Colors.white),
              label: Text('ถ่ายรูป', style: TextStyle(color: Colors.white)),
              onPressed: () => pickImage(ImageSource.camera),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(backgroundColor: MyStyle().bgColor),
              icon: Icon(Icons.photo_library, color: Colors.white),
              label: Text('เลือกรูป', style: TextStyle(color: Colors.white)),
              onPressed: () => pickImage(ImageSource.gallery),
            ),
          ),
        ),
      ],
    );
  }

  Widget showPickedImage() {
    if (pickedImage == null) return SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(pickedImage!, height: 180.0, fit: BoxFit.cover),
      ),
    );
  }

  Widget scanningIndicator() {
    if (!scanning) return SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(color: MyStyle().bgColor),
            SizedBox(height: 8.0),
            Text('กำลังอ่านข้อความและค้นหาสินค้า...',
                style: MyStyle().h4StyleGray),
          ],
        ),
      ),
    );
  }

  Widget resultTile(OcrLookupResult result) {
    ProductAllModel? product = result.product;

    return Card(
      child: ListTile(
        onTap: product != null ? () => routeToDetail(product) : null,
        leading: Text(result.code, style: MyStyle().h4bStyleGray),
        title: product != null
            ? Text(product.title ?? '', style: MyStyle().h3Style)
            : Text('ไม่พบสินค้าจาก "${result.code}" ในระบบ',
                style: MyStyle().h4StyleRed),
        subtitle: Text(
          product != null
              ? 'จับคู่ด้วย${result.matchType} • คงเหลือ: ${product.stock ?? '-'}'
              : 'ค้นหาด้วย${result.matchType}',
          style: MyStyle().h4StyleGray,
        ),
        trailing: product != null
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.error_outline, color: Colors.red),
      ),
    );
  }

  Widget resultList() {
    if (!scanning && pickedImage != null && results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Text('ไม่พบรหัสสินค้าในรูปภาพนี้', style: MyStyle().h4StyleGray),
      );
    }

    if (results.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('พบ ${results.length} รายการจากรูปภาพ',
              style: MyStyle().h4bStyleGray),
        ),
        ...results.map(resultTile),
      ],
    );
  }

  Widget showController() {
    return ListView(
      padding: EdgeInsets.all(10.0),
      children: <Widget>[
        Text(
            'ถ่ายรูปหรือเลือกรูปรายการสินค้า ระบบจะอ่านรหัสสินค้าแล้วค้นหาในระบบให้อัตโนมัติ',
            style: MyStyle().h4StyleGray),
        SizedBox(height: 10.0),
        pickImageButtons(),
        showPickedImage(),
        scanningIndicator(),
        resultList(),
      ],
    );
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(
        index: index,
        userModel: myUserModel,
      );
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToDetailCart() {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return DetailCart(userModel: myUserModel);
    });
    Navigator.of(context).push(materialPageRoute);
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
          icon: const Icon(Icons.card_giftcard),
          title: const Text('Reward'),
          backgroundColor: Colors.red,
        ),
        BottomBarItem(
          icon: const Icon(Icons.shopping_cart),
          title: const Text('Cart'),
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
            routeToListProduct(0);
          } else if (index == 2) {
            MaterialPageRoute materialPageRoute =
                MaterialPageRoute(builder: (BuildContext buildContext) {
              return RewardList(userModel: myUserModel);
            });
            Navigator.of(context).push(materialPageRoute);
          } else if (index == 3) {
            routeToDetailCart();
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
        title:
            Text('สแกนหาสินค้า (OCR)', style: TextStyle(color: Colors.white)),
      ),
      body: showController(),
      bottomNavigationBar: stylishBottomBar(),
    );
  }
}
