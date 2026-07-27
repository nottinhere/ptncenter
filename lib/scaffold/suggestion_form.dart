import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ptncenter/models/user_model.dart';
import 'package:ptncenter/scaffold/detail_cart.dart';
import 'package:ptncenter/scaffold/list_product.dart';
import 'package:ptncenter/scaffold/list_product_favorite.dart';
import 'package:ptncenter/scaffold/my_service.dart';
import 'package:ptncenter/utility/my_style.dart';
import 'package:ptncenter/utility/normal_dialog.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class SuggestionForm extends StatefulWidget {
  final UserModel? userModel;

  SuggestionForm({Key? key, this.userModel}) : super(key: key);

  @override
  _SuggestionFormState createState() => _SuggestionFormState();
}

class _SuggestionFormState extends State<SuggestionForm> {
  UserModel? myUserModel;
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  File? selectedImage;
  bool isSubmitting = false;
  int selectIndex = 3;

  @override
  void initState() {
    super.initState();
    myUserModel = widget.userModel;
  }

  @override
  void dispose() {
    subjectController.dispose();
    detailController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  MediaType imageMediaType(String path) {
    String ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'heic':
        return MediaType('image', 'heic');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  Future<void> submitSuggestion() async {
    var memberId = myUserModel?.id ?? '';
    var memberCode = myUserModel?.customerCode ?? '';
    if (subjectController.text.trim().isEmpty) {
      normalDialog(context, 'แจ้งเตือน', 'กรุณาระบุหัวข้อ');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      Uri uri = Uri.parse(
          'https://www.ptnpharma.com/apishop/json_submit_complain.php?memberId=$memberId&memberCode=$memberCode');
          print('submitSuggestion >> $uri');
      http.MultipartRequest request = http.MultipartRequest('POST', uri);
      request.fields['user'] = myUserModel?.name ?? '';
      request.fields['customer_code'] = myUserModel?.customerCode ?? '';
      request.fields['subject_th'] = subjectController.text.trim();
      request.fields['detail_th'] = detailController.text.trim();
      request.fields['mode'] = 'a';
      request.fields['id'] = '';

      if (selectedImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'upload',
          selectedImage!.path,
          contentType: imageMediaType(selectedImage!.path),
        ));
      }

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      setState(() {
        isSubmitting = false;
      });
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
      if (response.statusCode == 200) {
        normalDialogPopup(
            context, 'สำเร็จ', 'ส่งข้อเสนอแนะเรียบร้อยแล้ว');
      } else {
        normalDialog(context, 'แจ้งเตือน',
            'ไม่สามารถส่งข้อมูลได้ กรุณาลองใหม่\n(status ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });
      normalDialog(context, 'แจ้งเตือน', 'ไม่สามารถส่งข้อมูลได้ กรุณาลองใหม่');
    }
  }

  void routeToHome() {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (BuildContext buildContext) {
        return MyService(userModel: myUserModel);
      },
    );
    Navigator.of(context).pushAndRemoveUntil(materialPageRoute, (route) => false);
  }

  void routeToListProduct(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProduct(index: index, userModel: myUserModel);
    });
    Navigator.of(context).push(materialPageRoute);
  }

  void routeToListProductfav(int index) {
    MaterialPageRoute materialPageRoute =
        MaterialPageRoute(builder: (BuildContext buildContext) {
      return ListProductfav(index: index, userModel: myUserModel);
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
          icon: const Icon(Icons.favorite),
          title: const Text('Favorite'),
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
              builder: (value) => MyService(userModel: myUserModel),
            );
            Navigator.of(context).pushAndRemoveUntil(route, (route) => false);
          } else if (index == 1) {
            routeToListProduct(0);
          } else if (index == 2) {
            routeToListProductfav(0);
          } else if (index == 3) {
            routeToDetailCart();
          }
        });
      },
    );
  }

  Future<void> normalDialogPopup(
    BuildContext buildContext,
    String title,
    String message,
  ) async {
    AwesomeDialog(
      context: buildContext,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      title: title,
      desc: message,
      btnOkColor: MyStyle().mainColor,
      btnOkText: 'ตกลง',
      btnOkOnPress: () {
        routeToHome();
      },
      dismissOnTouchOutside: false,
    ).show();
  }

  Widget sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MyStyle().radiusM),
        border: Border.all(color: MyStyle().borderColor),
      ),
      child: child,
    );
  }

  Widget readOnlyField(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        style: MyStyle().h4StyleGray,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          filled: true,
          fillColor: MyStyle().scaffoldBackground,
        ),
      ),
    );
  }

  Widget imagePickerRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ElevatedButton.icon(
          onPressed: pickImage,
          icon: Icon(Icons.upload_file),
          label: Text('แนบภาพประกอบ (ถ้ามี)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            foregroundColor: Colors.white,
          ),
        ),
        if (selectedImage != null) ...[
          SizedBox(height: 10.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.file(
              selectedImage!,
              width: 120.0,
              height: 120.0,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyStyle().scaffoldBackground,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: MyStyle().bgColor,
        title: Text('ข้อเสนอแนะ', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: EdgeInsets.all(14.0),
        children: <Widget>[
          sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                readOnlyField('ชื่อผู้ใช้', myUserModel?.name ?? ''),
                readOnlyField(
                    'Customer code', myUserModel?.customerCode ?? ''),
                TextFormField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: 'หัวข้อ',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.0),
                TextFormField(
                  controller: detailController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'รายละเอียด',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.0),
                imagePickerRow(),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            height: 48.0,
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: MyStyle().mainColor),
              onPressed: isSubmitting ? null : submitSuggestion,
              child: isSubmitting
                  ? SizedBox(
                      width: 22.0,
                      height: 22.0,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : Text(
                      'ส่งข้อเสนอแนะ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: stylishBottomBar(),
    );
  }
}
