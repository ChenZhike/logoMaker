import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ImageProcessor {
  // Mac 应用所需的图标尺寸配置
  final List<IconConfig> iconConfigs = [
    IconConfig(16),
    IconConfig(32),
    IconConfig(64),
    IconConfig(128),
    IconConfig(256),
    IconConfig(512),
    IconConfig(1024),
  ];

  Future<void> processImage(File inputFile, String outputDirectory) async {
    final bytes = await inputFile.readAsBytes();
    var image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('无法读取图片');
    }

    image = _cropToSquare(image);

    // 生成所有尺寸的图标
    for (final config in iconConfigs) {
      // 生成基础尺寸的图标
      final resized = img.copyResize(
        image,
        width: config.size,
        height: config.size,
        interpolation: img.Interpolation.linear,
      );

      // 保存基础尺寸图标
      final basePath = path.join(
        outputDirectory,
        'icon_${config.size}x${config.size}.png',
      );
      await File(basePath).writeAsBytes(img.encodePng(resized));

      // 将当前尺寸的图标同时作为较小尺寸的 @2x 版本
      if (config.size > 16) {  // 从32开始都可以作为较小尺寸的 @2x
        final halfSize = config.size ~/ 2;
        final path2x = path.join(
          outputDirectory,
          'icon_${halfSize}x${halfSize}@2x.png',
        );
        await File(path2x).writeAsBytes(img.encodePng(resized));
      }
    }
  }

  img.Image _cropToSquare(img.Image image) {
    final size = image.width < image.height ? image.width : image.height;
    final x = (image.width - size) ~/ 2;
    final y = (image.height - size) ~/ 2;
    
    return img.copyCrop(
      image,
      x: x,
      y: y,
      width: size,
      height: size,
    );
  }
}

class IconConfig {
  final int size;
  IconConfig(this.size);
} 