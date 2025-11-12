import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:fluttertoast/fluttertoast.dart';
import '../l10n/app_localizations.dart';

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
        final l10n = AppLocalizations.of(context)!;
        Fluttertoast.showToast(
          msg: l10n.errorPickingImage(e.toString()),
          toastLength: Toast.LENGTH_SHORT,
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
        final l10n = AppLocalizations.of(context)!;
        Fluttertoast.showToast(
          msg: l10n.errorPickingPDF(e.toString()),
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  void _showPickOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              title: Text(l10n.pickFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.green),
              ),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              title: Text(l10n.pickPDFFile),
              onTap: () {
                Navigator.pop(context);
                _pickPDF();
              },
            ),
            const SizedBox(height: 8),
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

  void _previewReceipt(ReceiptFile receipt) {
    if (receipt.fileType == 'image') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(receipt.fileName),
            ),
            body: Center(
              child: Image.file(File(receipt.filePath)),
            ),
          ),
        ),
      );
    } else {
      // For PDF, show a dialog with file info
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.previewReceipt),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(receipt.fileName),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.receipts,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _showPickOptions,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: Text(l10n.addReceipt),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_receipts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noReceiptsAdded,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _showPickOptions,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addReceipt),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _receipts.length,
            itemBuilder: (context, index) {
              final receipt = _receipts[index];
              return _buildReceiptCard(receipt, index);
            },
          ),
      ],
    );
  }

  Widget _buildReceiptCard(ReceiptFile receipt, int index) {
    final theme = Theme.of(context);
    final isImage = receipt.fileType == 'image';

    return GestureDetector(
      onTap: () => _previewReceipt(receipt),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.3),
              ),
              color: theme.colorScheme.surface,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: isImage
                  ? Image.file(
                      File(receipt.filePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorPlaceholder(theme);
                      },
                    )
                  : _buildPDFPlaceholder(theme, receipt),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _removeReceipt(index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          if (!isImage)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  receipt.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPDFPlaceholder(ThemeData theme, ReceiptFile receipt) {
    return Container(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf,
            size: 40,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              receipt.fileName,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 40,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'Error loading image',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
