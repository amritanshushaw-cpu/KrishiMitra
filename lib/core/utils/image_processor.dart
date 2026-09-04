import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';

class ImageProcessor {
  /// Decodes raw JPEG bytes, crops to square, resizes to 224x224,
  /// and normalizes into a 4D Float32 tensor [1, 224, 224, 3] with rescale=1./255.
  static List<List<List<List<double>>>> preprocessForTFLite(Uint8List imageBytes) {
    final img.Image? decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception('Failed to decode image bytes.');
    }

    // 1. Center crop to 1:1 aspect ratio to avoid distorting leaf pathology features
    final int minDimension = decoded.width < decoded.height ? decoded.width : decoded.height;
    final int xOffset = (decoded.width - minDimension) ~/ 2;
    final int yOffset = (decoded.height - minDimension) ~/ 2;

    final img.Image cropped = img.copyCrop(
      decoded,
      x: xOffset,
      y: yOffset,
      width: minDimension,
      height: minDimension,
    );

    // 2. Resize to exact model input size (224 x 224)
    final img.Image resized = img.copyResize(
      cropped,
      width: AppConstants.modelInputSize,
      height: AppConstants.modelInputSize,
      interpolation: img.Interpolation.linear,
    );

    // 3. Build normalized 4D float tensor [1, 224, 224, 3]
    final List<List<List<double>>> imageTensor = [];

    for (int y = 0; y < AppConstants.modelInputSize; y++) {
      final List<List<double>> row = [];
      for (int x = 0; x < AppConstants.modelInputSize; x++) {
        final img.Pixel pixel = resized.getPixel(x, y);

        // Normalize RGB values with imageMean: 0.0, imageStd: 255.0
        final double r = (pixel.r - AppConstants.imageMean) / AppConstants.imageStd;
        final double g = (pixel.g - AppConstants.imageMean) / AppConstants.imageStd;
        final double b = (pixel.b - AppConstants.imageMean) / AppConstants.imageStd;

        row.add([r, g, b]);
      }
      imageTensor.add(row);
    }

    // Return batch tensor of size 1
    return [imageTensor];
  }
}
