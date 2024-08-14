import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Uint8List? selectedImageFile;

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    List<int> imageBytes = await _file.readAsBytes();
    selectedImageFile = Uint8List.fromList(imageBytes);
  }
  print('No images selected');
}
