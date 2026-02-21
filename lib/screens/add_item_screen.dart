import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ammas_kitchen/models/inventory_item.dart';
import 'package:ammas_kitchen/providers/inventory_provider.dart';
import 'package:ammas_kitchen/services/database_service.dart';
import 'package:ammas_kitchen/data/shelf_life_data.dart';
import 'package:intl/intl.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _photoPath;
  String _category = 'other';
  double _quantity = 1;
  String _unit = 'pieces';
  String _storageLocation = 'fridge';
  DateTime? _expiryDate;
  bool _isProcessing = false;
  String? _aiSuggestion;
  List<String> _detectedLabels = [];
  String? _detectedExpiryText;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        actions: [
          TextButton.icon(
            onPressed: _nameController.text.isNotEmpty ? _saveItem : null,
            icon: const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Identifying your item...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo section
                  _buildPhotoSection(),
                  const SizedBox(height: 20),

                  // AI suggestion banner
                  if (_aiSuggestion != null) _buildAiSuggestion(),

                  // Name field
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      hintText: 'e.g., Tomato, Amul Butter...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 18),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  _buildCategorySelector(),
                  const SizedBox(height: 16),

                  // Quantity & Unit
                  _buildQuantitySection(),
                  const SizedBox(height: 16),

                  // Storage location
                  _buildLocationSelector(),
                  const SizedBox(height: 16),

                  // Expiry date
                  _buildExpirySection(),
                  const SizedBox(height: 16),

                  // Notes
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Any extra info...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
          image: _photoPath != null
              ? DecorationImage(
                  image: FileImage(File(_photoPath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _photoPath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to take a photo',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'AI will identify the item for you',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 13,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _showImageSourceDialog,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAiSuggestion() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤖', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'AI detected: $_aiSuggestion',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (_detectedLabels.length > 1) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: _detectedLabels.take(5).map((label) {
                return ActionChip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    _nameController.text = label;
                    _guessCategory(label);
                    setState(() {});
                  },
                );
              }).toList(),
            ),
          ],
          if (_detectedExpiryText != null) ...[
            const SizedBox(height: 8),
            Text(
              'Detected date text: "$_detectedExpiryText"',
              style: TextStyle(color: Colors.blue[600], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categoryNames.entries.map((entry) {
            final isSelected = _category == entry.key;
            return ChoiceChip(
              label: Text(
                  '${categoryIcons[entry.key] ?? ''} ${entry.value}'),
              selected: isSelected,
              onSelected: (_) => setState(() => _category = entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Row(
      children: [
        // Quantity stepper
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quantity',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filled(
                    onPressed: _quantity > 0.5
                        ? () => setState(() => _quantity -= 0.5)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _quantity % 1 == 0
                        ? _quantity.toInt().toString()
                        : _quantity.toString(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  IconButton.filled(
                    onPressed: () => setState(() => _quantity += 0.5),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Unit selector
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Unit',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _unit,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: unitOptions.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _unit = val);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Storage Location',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: storageLocations.map((location) {
            final isSelected = _storageLocation == location;
            return ChoiceChip(
              label: Text(
                '${locationIcons[location] ?? ''} ${location[0].toUpperCase()}${location.substring(1)}',
              ),
              selected: isSelected,
              onSelected: (_) =>
                  setState(() => _storageLocation = location),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpirySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Expiry Date',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickExpiryDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 12),
                Text(
                  _expiryDate != null
                      ? DateFormat('dd MMM yyyy').format(_expiryDate!)
                      : 'Tap to set expiry date',
                  style: TextStyle(
                    fontSize: 16,
                    color: _expiryDate != null ? null : Colors.grey[500],
                  ),
                ),
                const Spacer(),
                if (_expiryDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () => setState(() => _expiryDate = null),
                  ),
              ],
            ),
          ),
        ),
        if (_expiryDate == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton.icon(
              onPressed: _suggestShelfLife,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('Auto-suggest shelf life'),
            ),
          ),
      ],
    );
  }

  // --- Actions ---

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _captureImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _captureImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      // Save to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'item_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = p.join(appDir.path, 'photos', fileName);
      await Directory(p.dirname(savedPath)).create(recursive: true);
      await File(image.path).copy(savedPath);

      setState(() {
        _photoPath = savedPath;
        _isProcessing = true;
      });

      await _processImage(savedPath);
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      // Run image labeling and text recognition in parallel
      final labelFuture = _detectLabels(inputImage);
      final textFuture = _detectText(inputImage);

      final results = await Future.wait([labelFuture, textFuture]);
      final labels = results[0] as List<String>;
      final detectedText = results[1] as String?;

      setState(() {
        _isProcessing = false;
        _detectedLabels = labels;

        if (labels.isNotEmpty) {
          _aiSuggestion = labels.first;
          _nameController.text = labels.first;
          _guessCategory(labels.first);
        }

        if (detectedText != null) {
          _detectedExpiryText = detectedText;
          _tryParseExpiryDate(detectedText);
        }
      });

      // Try to auto-suggest shelf life
      _suggestShelfLife();
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Couldn't identify the item. Please enter the name manually."),
          ),
        );
      }
    }
  }

  Future<List<String>> _detectLabels(InputImage inputImage) async {
    final labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
    try {
      final labels = await labeler.processImage(inputImage);
      return labels.map((l) => l.label).toList();
    } finally {
      labeler.close();
    }
  }

  Future<String?> _detectText(InputImage inputImage) async {
    final recognizer = TextRecognizer();
    try {
      final recognized = await recognizer.processImage(inputImage);
      final text = recognized.text;
      if (text.isEmpty) return null;

      // Look for date-like patterns
      final datePatterns = [
        RegExp(r'(?:exp(?:iry)?|best before|bb|use by)[:\s]*(.+)', caseSensitive: false),
        RegExp(r'(\d{1,2}[/\-\.]\d{1,2}[/\-\.]\d{2,4})'),
        RegExp(r'(\d{1,2}\s+(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\w*\s+\d{2,4})', caseSensitive: false),
      ];

      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          return match.group(1)?.trim() ?? match.group(0)?.trim();
        }
      }

      return null;
    } finally {
      recognizer.close();
    }
  }

  void _tryParseExpiryDate(String text) {
    // Try various Indian date formats
    final formats = [
      DateFormat('dd/MM/yyyy'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('dd.MM.yyyy'),
      DateFormat('MM/yyyy'),
      DateFormat('MM-yyyy'),
      DateFormat('dd MMM yyyy'),
      DateFormat('MMM yyyy'),
      DateFormat('dd/MM/yy'),
      DateFormat('dd-MM-yy'),
    ];

    for (final format in formats) {
      try {
        final date = format.parseStrict(text.trim());
        // Sanity check: should be in the future or recent past
        if (date.isAfter(DateTime(2020))) {
          setState(() => _expiryDate = date);
          return;
        }
      } catch (_) {}
    }
  }

  void _guessCategory(String name) {
    final lower = name.toLowerCase();
    final categoryGuess = {
      'vegetable': ['tomato', 'onion', 'potato', 'carrot', 'beans', 'capsicum', 'brinjal', 'cauliflower', 'cabbage', 'spinach', 'methi', 'coriander', 'curry', 'chilli', 'ginger', 'garlic', 'drumstick', 'gourd', 'bhindi', 'okra', 'ladies finger', 'beetroot', 'radish', 'peas', 'mushroom', 'cucumber'],
      'fruit': ['banana', 'apple', 'mango', 'papaya', 'grapes', 'orange', 'pomegranate', 'guava', 'coconut', 'lemon', 'watermelon', 'sapota', 'pineapple', 'strawberry', 'fig', 'dates'],
      'dairy': ['milk', 'curd', 'yogurt', 'paneer', 'butter', 'cheese', 'ghee', 'cream', 'buttermilk', 'egg', 'amul'],
      'grain': ['rice', 'wheat', 'flour', 'rava', 'poha', 'dal', 'lentil', 'rajma', 'chana', 'besan', 'ragi', 'vermicelli', 'noodle', 'pasta', 'oats', 'idli'],
      'spice': ['turmeric', 'chilli powder', 'coriander powder', 'cumin', 'mustard', 'garam masala', 'sambar', 'rasam', 'asafoetida', 'pepper', 'cardamom', 'cloves', 'cinnamon', 'bay leaf', 'fenugreek'],
      'beverage': ['juice', 'soda', 'water', 'tea', 'coffee'],
    };

    for (final entry in categoryGuess.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          setState(() => _category = entry.key);
          // Auto-suggest storage location
          if (entry.key == 'dairy' || entry.key == 'vegetable' || entry.key == 'fruit') {
            _storageLocation = 'fridge';
          } else if (entry.key == 'grain' || entry.key == 'spice') {
            _storageLocation = 'pantry';
          }
          return;
        }
      }
    }
  }

  Future<void> _suggestShelfLife() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final db = DatabaseService.instance;
    var days = await db.getShelfLifeDays(name, _storageLocation);
    days ??= await db.getShelfLifeDaysByCategory(_category, _storageLocation);

    if (days != null && mounted) {
      final suggestedDate = DateTime.now().add(Duration(days: days));
      if (_expiryDate == null) {
        setState(() => _expiryDate = suggestedDate);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$name typically lasts $days days in $_storageLocation. Expiry set to ${DateFormat('dd MMM').format(suggestedDate)}.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final item = InventoryItem(
      name: name,
      category: _category,
      quantity: _quantity,
      unit: _unit,
      storageLocation: _storageLocation,
      photoPath: _photoPath,
      expiryDate: _expiryDate,
      isPerishable: _category != 'spice' && _category != 'grain',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;
    final provider = context.read<InventoryProvider>();
    await provider.addItem(item);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name added to your kitchen!')),
    );
  }
}
