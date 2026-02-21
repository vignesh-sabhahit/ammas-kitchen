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
import 'package:ammas_kitchen/services/smart_identifier.dart';
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
  final _identifier = SmartIdentifier.instance;

  // Multi-photo support
  final List<String> _photoPaths = [];
  final List<String> _ocrTexts = [];

  String _category = 'other';
  double _quantity = 1;
  String _unit = 'pieces';
  String _storageLocation = 'fridge';
  DateTime? _expiryDate;
  DateTime? _mfgDate;
  bool _isProcessing = false;

  // v2 identification results
  List<IdentificationResult> _identificationResults = [];
  PackagingInfo? _packagingInfo;
  String? _detectedBrand;
  List<String> _mlLabels = []; // fallback ML Kit labels

  @override
  void initState() {
    super.initState();
    _identifier.initialize();
  }

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
                  Text('Scanning your item...', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Reading text & identifying product',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Multi-photo section
                  _buildMultiPhotoSection(),
                  const SizedBox(height: 20),

                  // Identification results banner
                  if (_identificationResults.isNotEmpty) _buildIdentificationBanner(),

                  // Packaging info banner
                  if (_packagingInfo != null) _buildPackagingInfoBanner(),

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

  // =========================================================================
  // MULTI-PHOTO SECTION
  // =========================================================================

  Widget _buildMultiPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo grid
        SizedBox(
          height: 160,
          child: Row(
            children: [
              // Existing photos
              ..._photoPaths.asMap().entries.map((entry) {
                final idx = entry.key;
                final path = entry.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: idx < _photoPaths.length - 1 ? 8 : 0),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Label: Front / Back
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              idx == 0 ? '📷 Front' : '📷 Back',
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ),
                        // Remove button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removePhoto(idx),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Add photo button (if < 2 photos)
              if (_photoPaths.length < 2) ...[
                if (_photoPaths.isNotEmpty) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _photoPaths.isEmpty ? Icons.camera_alt : Icons.flip_camera_android,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _photoPaths.isEmpty
                                ? 'Take a photo'
                                : 'Add back side',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_photoPaths.isEmpty)
                            Text(
                              'Front of the package',
                              style: TextStyle(color: Colors.grey[400], fontSize: 11),
                            ),
                          if (_photoPaths.length == 1)
                            Text(
                              'For expiry/MFG date',
                              style: TextStyle(color: Colors.grey[400], fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Tip text
        if (_photoPaths.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '💡 Tip: Take front photo first, then back for expiry dates',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // IDENTIFICATION RESULTS BANNER
  // =========================================================================

  Widget _buildIdentificationBanner() {
    final topResult = _identificationResults.first;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: topResult.confidence > 0.7 ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: topResult.confidence > 0.7 ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                topResult.confidence > 0.7 ? '✅' : '🔍',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Identified: ${topResult.item.name}',
                  style: TextStyle(
                    color: topResult.confidence > 0.7 ? Colors.green[800] : Colors.orange[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: topResult.confidence > 0.7 ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  topResult.confidenceLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: topResult.confidence > 0.7 ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          if (_detectedBrand != null) ...[
            const SizedBox(height: 4),
            Text(
              'Brand: $_detectedBrand',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
          // Alternative suggestions
          if (_identificationResults.length > 1) ...[
            const SizedBox(height: 8),
            const Text('Did you mean:', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _identificationResults.skip(1).take(4).map((result) {
                return ActionChip(
                  label: Text(
                    '${categoryIcons[result.item.category] ?? ''} ${result.item.name}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _selectIdentification(result),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // PACKAGING INFO BANNER
  // =========================================================================

  Widget _buildPackagingInfoBanner() {
    final info = _packagingInfo!;
    final hasUsefulInfo = info.expiryDate != null ||
        info.mfgDate != null ||
        info.mrp != null ||
        info.netWeight != null;

    if (!hasUsefulInfo) return const SizedBox.shrink();

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
              const Text('📋', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('Package Info',
                  style: TextStyle(
                      color: Colors.blue[800], fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          if (info.expiryDate != null)
            _infoRow('Expiry', DateFormat('dd MMM yyyy').format(info.expiryDate!),
                info.expiryDateRaw),
          if (info.mfgDate != null)
            _infoRow('MFG Date', DateFormat('dd MMM yyyy').format(info.mfgDate!),
                info.mfgDateRaw),
          if (info.mrp != null) _infoRow('MRP', '₹${info.mrp}', null),
          if (info.netWeight != null)
            _infoRow('Net Weight', info.netWeight!, null),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, String? raw) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(color: Colors.blue[600], fontSize: 12)),
          ),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          if (raw != null)
            Text(' (from: "$raw")',
                style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }

  // =========================================================================
  // CATEGORY, QUANTITY, LOCATION, EXPIRY BUILDERS (same as v1, with updates)
  // =========================================================================

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
              label:
                  Text('${categoryIcons[entry.key] ?? ''} ${entry.value}'),
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
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quantity',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Unit',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
              onSelected: (_) => setState(() => _storageLocation = location),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  // =========================================================================
  // ACTIONS
  // =========================================================================

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(_photoPaths.isEmpty
                  ? 'Take Photo (Front)'
                  : 'Take Photo (Back)'),
              subtitle: Text(_photoPaths.isEmpty
                  ? 'Product name & brand side'
                  : 'Expiry date & MFG date side'),
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
        _photoPaths.add(savedPath);
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

  void _removePhoto(int index) {
    setState(() {
      _photoPaths.removeAt(index);
      if (index < _ocrTexts.length) _ocrTexts.removeAt(index);
      // Re-run identification with remaining photos
      _reprocessAllPhotos();
    });
  }

  // =========================================================================
  // v2 IMAGE PROCESSING — OCR-first, then fuzzy match
  // =========================================================================

  Future<void> _processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      // Run OCR and ML Kit labels in parallel
      final textFuture = _detectAllText(inputImage);
      final labelFuture = _detectLabels(inputImage);

      final results = await Future.wait([textFuture, labelFuture]);
      final ocrText = results[0] as String;
      final labels = results[1] as List<String>;

      _ocrTexts.add(ocrText);
      _mlLabels = labels;

      // Now run smart identification on ALL collected OCR text
      _runSmartIdentification();

      setState(() => _isProcessing = false);
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Couldn't read the image. Please enter the name manually."),
          ),
        );
      }
    }
  }

  void _reprocessAllPhotos() {
    if (_ocrTexts.isEmpty) {
      _identificationResults = [];
      _packagingInfo = null;
      _detectedBrand = null;
      return;
    }
    _runSmartIdentification();
  }

  void _runSmartIdentification() {
    // Combine all OCR text from all photos
    final combinedText = _ocrTexts.join('\n');

    // 1. Extract packaging info (expiry, MFG, MRP, brand, weight)
    _packagingInfo = _identifier.mergePackagingInfo(_ocrTexts);

    // 2. Run fuzzy matching against 423-item database
    _identificationResults = _identifier.identifyFromOCR(combinedText);

    // 3. If OCR didn't find anything, try ML Kit labels as fallback
    if (_identificationResults.isEmpty && _mlLabels.isNotEmpty) {
      for (final label in _mlLabels) {
        final labelResults = _identifier.identifyFromOCR(label);
        if (labelResults.isNotEmpty) {
          _identificationResults = labelResults;
          break;
        }
      }
    }

    // 4. Apply the best match
    if (_identificationResults.isNotEmpty) {
      _selectIdentification(_identificationResults.first);
    }

    // 5. Apply packaging info
    _detectedBrand = _packagingInfo?.brand;

    if (_packagingInfo?.expiryDate != null && _expiryDate == null) {
      _expiryDate = _packagingInfo!.expiryDate;
    }
    if (_packagingInfo?.mfgDate != null) {
      _mfgDate = _packagingInfo!.mfgDate;
    }

    setState(() {});
  }

  /// Select an identification result and auto-fill the form
  void _selectIdentification(IdentificationResult result) {
    final item = result.item;

    _nameController.text = item.name;
    _category = item.category;
    _storageLocation = item.defaultLocation;
    _unit = item.defaultUnit;
    _quantity = item.typicalQuantity;

    if (item.brand != null) {
      _detectedBrand = item.brand;
    }

    // Auto-set expiry from shelf life if not already set from OCR
    if (_expiryDate == null && item.isPerishable) {
      final days = item.defaultShelfDays;
      _expiryDate = DateTime.now().add(Duration(days: days));
    }

    setState(() {});
  }

  // =========================================================================
  // OCR & ML KIT
  // =========================================================================

  /// Detect ALL text from image (not just dates — everything)
  Future<String> _detectAllText(InputImage inputImage) async {
    final recognizer = TextRecognizer();
    try {
      final recognized = await recognizer.processImage(inputImage);
      return recognized.text;
    } finally {
      recognizer.close();
    }
  }

  /// ML Kit image labeling as fallback
  Future<List<String>> _detectLabels(InputImage inputImage) async {
    final labeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.5));
    try {
      final labels = await labeler.processImage(inputImage);
      return labels.map((l) => l.label).toList();
    } finally {
      labeler.close();
    }
  }

  // =========================================================================
  // SHELF LIFE & SAVE
  // =========================================================================

  Future<void> _suggestShelfLife() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final db = DatabaseService.instance;
    final item = db.findShelfLifeItem(name);

    if (item != null && mounted) {
      final days =
          item.getShelfDays(_storageLocation) ?? item.defaultShelfDays;
      final suggestedDate = DateTime.now().add(Duration(days: days));
      if (_expiryDate == null) {
        setState(() => _expiryDate = suggestedDate);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.name} typically lasts $days days in $_storageLocation. Expiry set to ${DateFormat('dd MMM').format(suggestedDate)}.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Fallback to category default
      final days = db.getShelfLifeByCategorySync(_category, _storageLocation);
      if (days != null && mounted) {
        final suggestedDate = DateTime.now().add(Duration(days: days));
        if (_expiryDate == null) {
          setState(() => _expiryDate = suggestedDate);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Using default shelf life for $_category: $days days. Expiry set to ${DateFormat('dd MMM').format(suggestedDate)}.',
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
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
      photoPath: _photoPaths.isNotEmpty ? _photoPaths.first : null,
      expiryDate: _expiryDate,
      mfgDate: _mfgDate,
      isPerishable: !['spice', 'dryfruits', 'oil'].contains(_category),
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
      SnackBar(content: Text('$name added to your kitchen! 🍳')),
    );
  }
}
