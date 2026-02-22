import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ammas_kitchen/models/inventory_item.dart';
import 'package:ammas_kitchen/providers/inventory_provider.dart';
import 'package:ammas_kitchen/data/shelf_life_data.dart';

class ItemDetailScreen extends StatefulWidget {
  final InventoryItem item;
  final bool editMode;

  const ItemDetailScreen({
    super.key,
    required this.item,
    this.editMode = false,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late InventoryItem _item;
  late bool _isEditing;
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  int _currentPhotoPage = 0;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _isEditing = widget.editMode;
    _nameController = TextEditingController(text: _item.name);
    _notesController = TextEditingController(text: _item.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expiryColor = _getExpiryColor(_item.expiryStatus);
    final photos = _item.allPhotoPaths;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Item' : _item.name),
        actions: [
          if (_isEditing)
            TextButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photos with page indicator dots
            if (photos.isNotEmpty)
              SizedBox(
                height: 250,
                child: photos.length == 1
                    ? Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(photos.first)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            itemCount: photos.length,
                            onPageChanged: (i) =>
                                setState(() => _currentPhotoPage = i),
                            itemBuilder: (context, index) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(photos[index]),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 30,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        index == 0 ? 'Front' : 'Back',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          // Page indicator dots
                          Positioned(
                            bottom: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                photos.length,
                                (i) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPhotoPage == i
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              )
            else if (_item.photoPath != null)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(_item.photoPath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  if (_isEditing)
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 18),
                    )
                  else
                    Row(
                      children: [
                        Text(
                          categoryIcons[_item.category] ?? '🏷️',
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _item.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Expiry status card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: expiryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: expiryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _item.expiryStatus == ExpiryStatus.fresh
                              ? Icons.check_circle
                              : _item.expiryStatus == ExpiryStatus.none
                                  ? Icons.help_outline
                                  : Icons.warning,
                          color: expiryColor,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getExpiryText(_item),
                                style: TextStyle(
                                  color: expiryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (_item.expiryDate != null)
                                Text(
                                  'Expires: ${DateFormat('dd MMMM yyyy').format(_item.expiryDate!)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_isEditing)
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _pickExpiryDate,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Details grid
                  _buildDetailRow(
                      'Category',
                      '${categoryIcons[_item.category] ?? ''} ${categoryNames[_item.category] ?? _item.category}'),
                  _buildDetailRow(
                      'Quantity',
                      '${_item.quantity % 1 == 0 ? _item.quantity.toInt() : _item.quantity} ${_item.unit}'),
                  _buildDetailRow(
                      'Location',
                      '${locationIcons[_item.storageLocation] ?? ''} ${_item.storageLocation[0].toUpperCase()}${_item.storageLocation.substring(1)}'),
                  if (_item.brand != null && _item.brand!.isNotEmpty)
                    _buildDetailRow('Brand', _item.brand!),

                  // MFG Date
                  if (_item.mfgDate != null || _isEditing)
                    _buildDetailRow(
                      'MFG Date',
                      _item.mfgDate != null
                          ? DateFormat('dd MMM yyyy').format(_item.mfgDate!)
                          : 'Not set',
                      editAction: _isEditing ? _pickMfgDate : null,
                    ),

                  // Best-before text
                  if (_item.bestBeforeText != null &&
                      _item.bestBeforeText!.isNotEmpty)
                    _buildDetailRow('Best Before', _item.bestBeforeText!),

                  _buildDetailRow(
                      'Added',
                      DateFormat('dd MMM yyyy, h:mm a')
                          .format(_item.addedDate)),
                  if (_item.notes != null && _item.notes!.isNotEmpty)
                    _buildDetailRow('Notes', _item.notes!),

                  const SizedBox(height: 24),

                  // Quantity controls
                  if (!_isEditing) ...[
                    const Text('Adjust Quantity',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filled(
                          onPressed: () => _updateQuantity(-1),
                          icon: const Icon(Icons.remove, size: 28),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Text(
                          '${_item.quantity % 1 == 0 ? _item.quantity.toInt() : _item.quantity}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 24),
                        IconButton.filled(
                          onPressed: () => _updateQuantity(1),
                          icon: const Icon(Icons.add, size: 28),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Mark as used button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _markUsed,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark as Used / Finished'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                  ],

                  // Notes edit
                  if (_isEditing) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {VoidCallback? editAction}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
          if (editAction != null)
            IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: editAction,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Color _getExpiryColor(ExpiryStatus status) {
    switch (status) {
      case ExpiryStatus.fresh:
        return Colors.green;
      case ExpiryStatus.soon:
        return Colors.orange;
      case ExpiryStatus.today:
        return Colors.red;
      case ExpiryStatus.expired:
        return Colors.red[900]!;
      case ExpiryStatus.none:
        return Colors.grey;
    }
  }

  String _getExpiryText(InventoryItem item) {
    final days = item.daysUntilExpiry;
    if (days == null) return 'No expiry date set';
    if (days < 0) return 'Expired ${-days} days ago';
    if (days == 0) return 'Expires today!';
    if (days == 1) return 'Expires tomorrow';
    return 'Expires in $days days';
  }

  void _updateQuantity(double delta) {
    final newQty = _item.quantity + delta;
    if (newQty <= 0) {
      _markUsed();
      return;
    }
    setState(() {
      _item = _item.copyWith(quantity: newQty);
    });
    context.read<InventoryProvider>().updateQuantity(_item.id!, newQty);
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _item.expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() {
        _item = _item.copyWith(expiryDate: picked);
      });
    }
  }

  Future<void> _pickMfgDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _item.mfgDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _item = _item.copyWith(mfgDate: picked);
      });
    }
  }

  Future<void> _saveChanges() async {
    final updated = _item.copyWith(
      name: _nameController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    await context.read<InventoryProvider>().updateItem(updated);
    setState(() {
      _item = updated;
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated!')),
      );
    }
  }

  Future<void> _markUsed() async {
    final removed =
        await context.read<InventoryProvider>().markUsed(_item.id!);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_item.name} marked as used'),
          action: removed != null
              ? SnackBarAction(
                  label: 'Undo',
                  onPressed: () =>
                      context.read<InventoryProvider>().undoMarkUsed(removed),
                )
              : null,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to remove ${_item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _markUsed();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
