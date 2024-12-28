import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/image_processor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedImagePath;
  bool isProcessing = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        selectedImagePath = result.files.single.path;
      });
    }
  }

  Future<void> _processImage() async {
    if (selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择图片')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final saveDirectory = await FilePicker.platform.getDirectoryPath();
      if (saveDirectory != null) {
        final processor = ImageProcessor();
        await processor.processImage(
          File(selectedImagePath!),
          saveDirectory,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('处理完成！')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('处理失败：$e')),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo 生成器'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedImagePath != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.file(
                    File(selectedImagePath!),
                    height: 200,
                  ),
                ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('选择图片'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isProcessing ? null : _processImage,
                child: Text(isProcessing ? '处理中...' : '开始处理'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 