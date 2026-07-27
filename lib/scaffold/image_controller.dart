import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageController extends GetxController{
  PickedFile? _pickedFile;
  PickedFile? get pickedFile=>pickedFile;

  final _picker = ImagePicker();
  Future<void>  pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    update();

  }
}