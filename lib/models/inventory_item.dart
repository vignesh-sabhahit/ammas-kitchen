class InventoryItem {
  final int? id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final String storageLocation;
  final String? photoPath;
  final DateTime? expiryDate;
  final DateTime? mfgDate;
  final bool isPerishable;
  final int? defaultShelfDays;
  final DateTime addedDate;
  final DateTime updatedDate;
  final String status; // active, used, expired, deleted
  final String? notes;
  final String? brand;
  final String? photoPaths; // comma-separated paths for multi-photo

  InventoryItem({
    this.id,
    required this.name,
    this.category = 'other',
    this.quantity = 1,
    this.unit = 'pieces',
    this.storageLocation = 'pantry',
    this.photoPath,
    this.expiryDate,
    this.mfgDate,
    this.isPerishable = true,
    this.defaultShelfDays,
    DateTime? addedDate,
    DateTime? updatedDate,
    this.status = 'active',
    this.notes,
    this.brand,
    this.photoPaths,
  })  : addedDate = addedDate ?? DateTime.now(),
        updatedDate = updatedDate ?? DateTime.now();

  /// Days until expiry. Negative means already expired.
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  /// Expiry status for color coding
  ExpiryStatus get expiryStatus {
    final days = daysUntilExpiry;
    if (days == null) return ExpiryStatus.none;
    if (days < 0) return ExpiryStatus.expired;
    if (days == 0) return ExpiryStatus.today;
    if (days <= 3) return ExpiryStatus.soon;
    return ExpiryStatus.fresh;
  }

  /// Get list of all photo paths (combines photoPath and photoPaths)
  List<String> get allPhotoPaths {
    final paths = <String>[];
    if (photoPaths != null && photoPaths!.isNotEmpty) {
      paths.addAll(photoPaths!.split(',').where((p) => p.isNotEmpty));
    } else if (photoPath != null && photoPath!.isNotEmpty) {
      paths.add(photoPath!);
    }
    return paths;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'storage_location': storageLocation,
      'photo_path': photoPath,
      'expiry_date': expiryDate?.toIso8601String(),
      'mfg_date': mfgDate?.toIso8601String(),
      'is_perishable': isPerishable ? 1 : 0,
      'default_shelf_days': defaultShelfDays,
      'added_date': addedDate.toIso8601String(),
      'updated_date': updatedDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'brand': brand,
      'photo_paths': photoPaths,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String? ?? 'other',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1,
      unit: map['unit'] as String? ?? 'pieces',
      storageLocation: map['storage_location'] as String? ?? 'pantry',
      photoPath: map['photo_path'] as String?,
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      mfgDate: map['mfg_date'] != null
          ? DateTime.parse(map['mfg_date'] as String)
          : null,
      isPerishable: (map['is_perishable'] as int?) == 1,
      defaultShelfDays: map['default_shelf_days'] as int?,
      addedDate: map['added_date'] != null
          ? DateTime.parse(map['added_date'] as String)
          : DateTime.now(),
      updatedDate: map['updated_date'] != null
          ? DateTime.parse(map['updated_date'] as String)
          : DateTime.now(),
      status: map['status'] as String? ?? 'active',
      notes: map['notes'] as String?,
      brand: map['brand'] as String?,
      photoPaths: map['photo_paths'] as String?,
    );
  }

  InventoryItem copyWith({
    int? id,
    String? name,
    String? category,
    double? quantity,
    String? unit,
    String? storageLocation,
    String? photoPath,
    DateTime? expiryDate,
    DateTime? mfgDate,
    bool? isPerishable,
    int? defaultShelfDays,
    DateTime? addedDate,
    DateTime? updatedDate,
    String? status,
    String? notes,
    String? brand,
    String? photoPaths,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      storageLocation: storageLocation ?? this.storageLocation,
      photoPath: photoPath ?? this.photoPath,
      expiryDate: expiryDate ?? this.expiryDate,
      mfgDate: mfgDate ?? this.mfgDate,
      isPerishable: isPerishable ?? this.isPerishable,
      defaultShelfDays: defaultShelfDays ?? this.defaultShelfDays,
      addedDate: addedDate ?? this.addedDate,
      updatedDate: updatedDate ?? DateTime.now(),
      status: status ?? this.status,
      notes: notes ?? this.notes,
      brand: brand ?? this.brand,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}

enum ExpiryStatus {
  fresh,   // > 3 days
  soon,    // 1-3 days
  today,   // expires today
  expired, // already expired
  none,    // no expiry date set
}
