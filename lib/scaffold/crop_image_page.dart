import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import 'package:ptncenter/utility/my_style.dart';

class CropImagePage extends StatefulWidget {
  final Uint8List imageBytes;

  const CropImagePage({Key? key, required this.imageBytes}) : super(key: key);

  @override
  _CropImagePageState createState() => _CropImagePageState();
}

class _CropImagePageState extends State<CropImagePage> {
  final CropController _cropController = CropController();
  bool cropping = false;

  Future<void> _handleCropped(Uint8List croppedBytes) async {
    File file = File(
        '${Directory.systemTemp.path}/ocr_crop_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(croppedBytes);

    if (mounted) {
      Navigator.of(context).pop(file);
    }
  }

  Widget actionButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return Expanded(
      child: SizedBox(
        height: 56.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          onPressed: onPressed,
          child: loading
              ? SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: MyStyle().bgColor,
        iconTheme: IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        title: Text('ครอปรูปสินค้า', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Crop(
              image: widget.imageBytes,
              controller: _cropController,
              interactive: true,
              baseColor: Colors.black,
              maskColor: Colors.black.withOpacity(0.6),
              initialRectBuilder: (viewportRect, imageRect) {
                const double inset = 50.0;
                return Rect.fromLTRB(
                  imageRect.left + inset,
                  imageRect.top + inset,
                  imageRect.right - inset,
                  imageRect.bottom - inset,
                );
              },
              onCropped: (Uint8List croppedBytes) {
                setState(() {
                  cropping = false;
                });
                _handleCropped(croppedBytes);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  actionButton(
                    label: 'ยกเลิก',
                    color: Colors.grey.shade700,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 16.0),
                  actionButton(
                    label: 'ตกลง',
                    color: MyStyle().mainColor,
                    loading: cropping,
                    onPressed: cropping
                        ? null
                        : () {
                            setState(() {
                              cropping = true;
                            });
                            _cropController.crop();
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
