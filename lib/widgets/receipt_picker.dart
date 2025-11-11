import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ReceiptFile {
  final String filePath;
  final String fileType; // 'image' or 'pdf'
  final String fileName;

  ReceiptFile({
    required this.filePath,
    required this.fileType,
    required this.fileName,
  });
}

class ReceiptPicker extends StatefulWidget {
  final List<ReceiptFile>? initialReceipts;
  final Function(List<ReceiptFile>) onReceiptsChanged;

  const ReceiptPicker({
    super.key,
    this.initialReceipts,
    required this.onReceiptsChanged,
  });

  @override
  State<ReceiptPicker> createState() => _ReceiptPickerState();
}

class _ReceiptPickerState extends State<ReceiptPicker> {
  final ImagePicker _imagePicker = ImagePicker();
  List<ReceiptFile> _receipts = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialReceipts != null) {
      _receipts = List.from(widget.initialReceipts!);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final receiptsDir = Directory(path.join(appDir.path, 'receipts'));
        if (!await receiptsDir.exists()) {
          await receiptsDir.create(recursive: true);
        }

        final fileName = path.basename(image.path);
        final newPath = path.join(receiptsDir.path, fileName);
        final file = File(image.path);
        await file.copy(newPath);

        final receipt = ReceiptFile(
          filePath: newPath,
          fileType: 'image',
          fileName: fileName,
        );

        setState(() {
          _receipts.add(receipt);
        });
        widget.onReceiptsChanged(_receipts);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final receiptsDir = Directory(path.join(appDir.path, 'receipts'));
        if (!await receiptsDir.exists()) {
          await receiptsDir.create(recursive: true);
        }

        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        final newPath = path.join(receiptsDir.path, fileName);
        final file = File(filePath);
        await file.copy(newPath);

        final receipt = ReceiptFile(
          filePath: newPath,
          fileType: 'pdf',
          fileName: fileName,
        );

        setState(() {
          _receipts.add(receipt);
        });
        widget.onReceiptsChanged(_receipts);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking PDF: $e')),
        );
      }
    }
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Pick PDF File'),
              onTap: () {
                Navigator.pop(context);
                _pickPDF();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeReceipt(int index) {
    setState(() {
      _receipts.removeAt(index);
    });
    widget.onReceiptsChanged(_receipts);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Receipts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showPickOptions,
              icon: const Icon(Icons.add),
              label: const Text('Add Receipt'),
            ),
          ],
        ),
        if (_receipts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No receipts added',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _receipts.length,
              (index) => Chip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _receipts[index].fileType == 'pdf'
                          ? Icons.picture_as_pdf
                          : Icons.image,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _receipts[index].fileName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                onDeleted: () => _removeReceipt(index),
              ),
            ),
          ),
      ],
    );
  }
}

