import 'dart:math';
import 'package:ammas_kitchen/data/shelf_life_data.dart';

/// v2 Smart Item Identifier
/// Combines OCR text analysis + fuzzy matching against 423-item database
/// No LLM needed — pure on-device processing

class SmartIdentifier {
  static final SmartIdentifier instance = SmartIdentifier._();
  SmartIdentifier._();

  // Pre-built search index: alias -> ShelfLifeItem
  late final Map<String, ShelfLifeItem> _exactIndex;
  late final List<_SearchEntry> _searchEntries;
  bool _initialized = false;

  /// Initialize the search index (call once on app start)
  void initialize() {
    if (_initialized) return;

    _exactIndex = {};
    _searchEntries = [];

    for (final item in shelfLifeDatabase) {
      // Index exact name
      _exactIndex[item.name.toLowerCase()] = item;

      // Index all aliases
      for (final alias in item.aliases) {
        _exactIndex[alias.toLowerCase()] = item;
      }

      // Build search entries with all terms
      for (final term in item.searchTerms) {
        _searchEntries.add(_SearchEntry(term: term, item: item));
      }
    }

    _initialized = true;
  }

  // =========================================================================
  // MAIN API: Identify item from OCR text
  // =========================================================================

  /// Given raw OCR text from one or more photos, identify the item.
  /// Returns a ranked list of matches with confidence scores.
  List<IdentificationResult> identifyFromOCR(String ocrText) {
    initialize();
    if (ocrText.trim().isEmpty) return [];

    final lowerText = ocrText.toLowerCase();
    final tokens = _tokenize(lowerText);
    final results = <String, IdentificationResult>{};

    // Strategy 1: Exact phrase match against aliases (highest confidence)
    for (final entry in _searchEntries) {
      if (lowerText.contains(entry.term) && entry.term.length >= 3) {
        final key = entry.item.name;
        final existing = results[key];
        final score = _calculateScore(entry.term, lowerText, isExact: true);
        if (existing == null || existing.confidence < score) {
          results[key] = IdentificationResult(
            item: entry.item,
            confidence: score,
            matchedTerm: entry.term,
            matchType: 'exact',
          );
        }
      }
    }

    // Strategy 2: Token-level matching (for multi-word OCR text)
    for (final token in tokens) {
      if (token.length < 3) continue; // skip tiny tokens

      // Check exact index
      final exactMatch = _exactIndex[token];
      if (exactMatch != null) {
        final key = exactMatch.name;
        final score = _calculateScore(token, lowerText, isExact: true);
        final existing = results[key];
        if (existing == null || existing.confidence < score) {
          results[key] = IdentificationResult(
            item: exactMatch,
            confidence: score,
            matchedTerm: token,
            matchType: 'token_exact',
          );
        }
      }

      // Check fuzzy matches
      for (final entry in _searchEntries) {
        if (entry.term.length < 3) continue;
        final similarity = _levenshteinSimilarity(token, entry.term);
        if (similarity > 0.75) {
          final key = entry.item.name;
          final score = similarity * 0.8; // Fuzzy matches get lower confidence
          final existing = results[key];
          if (existing == null || existing.confidence < score) {
            results[key] = IdentificationResult(
              item: entry.item,
              confidence: score,
              matchedTerm: entry.term,
              matchType: 'fuzzy',
            );
          }
        }
      }
    }

    // Strategy 3: Bigram matching for multi-word items like "TOOR DAL"
    for (int i = 0; i < tokens.length - 1; i++) {
      final bigram = '${tokens[i]} ${tokens[i + 1]}';
      final match = _exactIndex[bigram];
      if (match != null) {
        final key = match.name;
        results[key] = IdentificationResult(
          item: match,
          confidence: 0.95,
          matchedTerm: bigram,
          matchType: 'bigram_exact',
        );
      }
    }

    // Sort by confidence (highest first)
    final sorted = results.values.toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    // Return top 5
    return sorted.take(5).toList();
  }

  // =========================================================================
  // OCR TEXT EXTRACTION: Parse structured data from packaging
  // =========================================================================

  /// Extract structured packaging info from OCR text
  PackagingInfo extractPackagingInfo(String ocrText) {
    return PackagingInfo.fromOCR(ocrText);
  }

  /// Merge info from multiple OCR scans (front + back of package)
  PackagingInfo mergePackagingInfo(List<String> ocrTexts) {
    final infos = ocrTexts.map((t) => PackagingInfo.fromOCR(t)).toList();
    return PackagingInfo.merge(infos);
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  List<String> _tokenize(String text) {
    // Split on whitespace, punctuation, and common separators
    return text
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  double _calculateScore(String term, String fullText, {bool isExact = false}) {
    // Longer matches get higher scores
    final lengthBonus = min(term.length / 15.0, 1.0);
    // Exact matches get a base boost
    final exactBonus = isExact ? 0.3 : 0.0;
    return min(0.5 + lengthBonus * 0.3 + exactBonus, 1.0);
  }

  /// Levenshtein similarity (0.0 to 1.0)
  double _levenshteinSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final len1 = s1.length;
    final len2 = s2.length;

    // Quick reject for very different lengths
    if ((len1 - len2).abs() > max(len1, len2) * 0.4) return 0.0;

    var prev = List<int>.generate(len2 + 1, (i) => i);
    var curr = List<int>.filled(len2 + 1, 0);

    for (int i = 1; i <= len1; i++) {
      curr[0] = i;
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        curr[j] = min(
          min(curr[j - 1] + 1, prev[j] + 1),
          prev[j - 1] + cost,
        );
      }
      final temp = prev;
      prev = curr;
      curr = temp;
    }

    final distance = prev[len2];
    final maxLen = max(len1, len2);
    return 1.0 - (distance / maxLen);
  }
}

// =========================================================================
// RESULT MODELS
// =========================================================================

class IdentificationResult {
  final ShelfLifeItem item;
  final double confidence; // 0.0 to 1.0
  final String matchedTerm;
  final String matchType; // exact, token_exact, bigram_exact, fuzzy

  const IdentificationResult({
    required this.item,
    required this.confidence,
    required this.matchedTerm,
    required this.matchType,
  });

  String get confidenceLabel {
    if (confidence > 0.85) return 'High';
    if (confidence > 0.65) return 'Medium';
    return 'Low';
  }
}

/// Structured data extracted from packaging OCR text
class PackagingInfo {
  final String? productName;
  final String? brand;
  final String? expiryDateRaw;
  final DateTime? expiryDate;
  final String? mfgDateRaw;
  final DateTime? mfgDate;
  final String? mrp;
  final String? netWeight;
  final String? batchNumber;
  final String? barcode;
  final String rawText;

  PackagingInfo({
    this.productName,
    this.brand,
    this.expiryDateRaw,
    this.expiryDate,
    this.mfgDateRaw,
    this.mfgDate,
    this.mrp,
    this.netWeight,
    this.batchNumber,
    this.barcode,
    this.rawText = '',
  });

  /// Parse packaging info from raw OCR text
  factory PackagingInfo.fromOCR(String text) {
    final lower = text.toLowerCase();

    return PackagingInfo(
      expiryDateRaw: _extractExpiryDate(text),
      expiryDate: _parseDate(_extractExpiryDate(text)),
      mfgDateRaw: _extractMfgDate(text),
      mfgDate: _parseDate(_extractMfgDate(text)),
      mrp: _extractMRP(text),
      netWeight: _extractNetWeight(text),
      batchNumber: _extractBatchNumber(text),
      brand: _extractBrand(lower),
      rawText: text,
    );
  }

  /// Merge multiple PackagingInfo objects (from front + back photos)
  factory PackagingInfo.merge(List<PackagingInfo> infos) {
    if (infos.isEmpty) return PackagingInfo();
    if (infos.length == 1) return infos.first;

    String? bestProductName;
    String? bestBrand;
    String? bestExpiryRaw;
    DateTime? bestExpiry;
    String? bestMfgRaw;
    DateTime? bestMfg;
    String? bestMrp;
    String? bestWeight;
    String? bestBatch;
    final allText = StringBuffer();

    for (final info in infos) {
      allText.write(info.rawText);
      allText.write(' ');
      bestProductName ??= info.productName;
      bestBrand ??= info.brand;
      bestExpiryRaw ??= info.expiryDateRaw;
      bestExpiry ??= info.expiryDate;
      bestMfgRaw ??= info.mfgDateRaw;
      bestMfg ??= info.mfgDate;
      bestMrp ??= info.mrp;
      bestWeight ??= info.netWeight;
      bestBatch ??= info.batchNumber;
    }

    return PackagingInfo(
      productName: bestProductName,
      brand: bestBrand,
      expiryDateRaw: bestExpiryRaw,
      expiryDate: bestExpiry,
      mfgDateRaw: bestMfgRaw,
      mfgDate: bestMfg,
      mrp: bestMrp,
      netWeight: bestWeight,
      batchNumber: bestBatch,
      rawText: allText.toString(),
    );
  }

  // --- Pattern extractors ---

  static String? _extractExpiryDate(String text) {
    final patterns = [
      // "EXP", "EXPIRY", "BEST BEFORE", "BB", "USE BY" followed by date
      RegExp(r'(?:exp(?:iry)?(?:\s*date)?|best\s*before|b\.?b\.?|use\s*by)[:\s./\-]*(.+?)(?:\n|$)', caseSensitive: false),
      // "EXP" on its own line followed by date on next line
      RegExp(r'exp[:\s]*\n\s*(.+?)(?:\n|$)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final raw = match.group(1)?.trim();
        if (raw != null && raw.isNotEmpty) return raw;
      }
    }
    return null;
  }

  static String? _extractMfgDate(String text) {
    final patterns = [
      RegExp(r'(?:mf[gd]|mfg\.?\s*(?:date)?|manufactured|pkg\.?\s*(?:date)?|pkd|packed\s*on)[:\s./\-]*(.+?)(?:\n|$)', caseSensitive: false),
      RegExp(r'mfd?[:\s]*\n\s*(.+?)(?:\n|$)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final raw = match.group(1)?.trim();
        if (raw != null && raw.isNotEmpty) return raw;
      }
    }
    return null;
  }

  static String? _extractMRP(String text) {
    final patterns = [
      RegExp(r'(?:mrp|m\.?r\.?p\.?)[:\s]*[₹rs.]*\s*([\d,]+\.?\d*)', caseSensitive: false),
      RegExp(r'(?:price|cost)[:\s]*[₹rs.]*\s*([\d,]+\.?\d*)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1)?.trim();
    }
    return null;
  }

  static String? _extractNetWeight(String text) {
    final patterns = [
      RegExp(r'(?:net\s*(?:wt|weight|qty|quantity)|contents)[:\s.]*(\d+\.?\d*\s*(?:g|gm|gms|gram|kg|kgs|ml|l|ltr|litre)s?)', caseSensitive: false),
      RegExp(r'(\d+\.?\d*\s*(?:g|gm|gms|kg|kgs|ml|l|ltr))\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) return match.group(1)?.trim();
    }
    return null;
  }

  static String? _extractBatchNumber(String text) {
    final pattern = RegExp(r'(?:batch|lot)\s*(?:no\.?|number)?[:\s]*([A-Za-z0-9\-/]+)', caseSensitive: false);
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  static String? _extractBrand(String lowerText) {
    // Check against known Indian brands
    const knownBrands = {
      'amul': 'Amul',
      'nandini': 'Nandini',
      'britannia': 'Britannia',
      'parle': 'Parle',
      'mtr': 'MTR',
      'everest': 'Everest',
      'mdh': 'MDH',
      'eastern': 'Eastern',
      'catch': 'Catch',
      'maggi': 'Maggi',
      'nestle': 'Nestle',
      'kissan': 'Kissan',
      'del monte': 'Del Monte',
      'haldiram': 'Haldiram',
      'bikaji': 'Bikaji',
      'tata': 'Tata',
      'fortune': 'Fortune',
      'saffola': 'Saffola',
      'sundrop': 'Sundrop',
      'aashirvaad': 'Aashirvaad',
      'pillsbury': 'Pillsbury',
      'patanjali': 'Patanjali',
      'dabur': 'Dabur',
      'itc': 'ITC',
      'sunfeast': 'Sunfeast',
      'kurkure': 'Kurkure',
      'lays': 'Lays',
      'bingo': 'Bingo',
      'tropicana': 'Tropicana',
      'real': 'Real',
      'paper boat': 'Paper Boat',
      'lijjat': 'Lijjat',
      'bru': 'Bru',
      'nescafe': 'Nescafe',
      'tata tea': 'Tata Tea',
      'red label': 'Red Label',
      'brooke bond': 'Brooke Bond',
      'horlicks': 'Horlicks',
      'bournvita': 'Bournvita',
      'quaker': 'Quaker',
      'kellogg': 'Kellogg',
      'mccain': 'McCain',
      'safal': 'Safal',
      'id fresh': 'ID Fresh',
      'milky mist': 'Milky Mist',
      'mother dairy': 'Mother Dairy',
      'maiyas': 'Maiyas',
      'weikfield': 'Weikfield',
      'smith': 'Smith & Jones',
      'ching': "Ching's",
      'knorr': 'Knorr',
      'fun foods': 'Fun Foods',
      'veeba': 'Veeba',
      'phool': 'Phool',
      'cycle': 'Cycle',
      'india gate': 'India Gate',
      'daawat': 'Daawat',
      'bambino': 'Bambino',
      '24 mantra': '24 Mantra',
      'organic tattva': 'Organic Tattva',
      'pro nature': 'Pro Nature',
      'epigamia': 'Epigamia',
      'yakult': 'Yakult',
    };

    for (final entry in knownBrands.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Try to parse a date string in various Indian formats
  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;

    // Clean up
    var cleaned = raw.trim().replaceAll(RegExp(r'\s+'), ' ');

    // Month name map
    const months = {
      'jan': 1, 'january': 1,
      'feb': 2, 'february': 2,
      'mar': 3, 'march': 3,
      'apr': 4, 'april': 4,
      'may': 5,
      'jun': 6, 'june': 6,
      'jul': 7, 'july': 7,
      'aug': 8, 'august': 8,
      'sep': 9, 'sept': 9, 'september': 9,
      'oct': 10, 'october': 10,
      'nov': 11, 'november': 11,
      'dec': 12, 'december': 12,
    };

    // Pattern: "SEP-24", "SEP 24", "SEP.24", "SEP/24" (month-year, common on Indian packaging)
    final monthYearMatch = RegExp(r'([a-zA-Z]{3,9})[\s.\-/]+(\d{2,4})', caseSensitive: false).firstMatch(cleaned);
    if (monthYearMatch != null) {
      final monthStr = monthYearMatch.group(1)!.toLowerCase();
      var year = int.tryParse(monthYearMatch.group(2)!);
      final month = months[monthStr];
      if (month != null && year != null) {
        if (year < 100) year += 2000;
        if (year > 2020 && year < 2040) {
          // Last day of month
          return DateTime(year, month + 1, 0);
        }
      }
    }

    // Pattern: "MM/YYYY" or "MM-YYYY" or "MM.YYYY"
    final mmyyyyMatch = RegExp(r'(\d{1,2})[/.\-](\d{4})').firstMatch(cleaned);
    if (mmyyyyMatch != null) {
      final month = int.tryParse(mmyyyyMatch.group(1)!);
      final year = int.tryParse(mmyyyyMatch.group(2)!);
      if (month != null && year != null && month >= 1 && month <= 12 && year > 2020) {
        return DateTime(year, month + 1, 0);
      }
    }

    // Pattern: "DD/MM/YYYY" or "DD-MM-YYYY" or "DD.MM.YYYY"
    final ddmmyyyyMatch = RegExp(r'(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2,4})').firstMatch(cleaned);
    if (ddmmyyyyMatch != null) {
      final day = int.tryParse(ddmmyyyyMatch.group(1)!);
      final month = int.tryParse(ddmmyyyyMatch.group(2)!);
      var year = int.tryParse(ddmmyyyyMatch.group(3)!);
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        if (day >= 1 && day <= 31 && month >= 1 && month <= 12 && year > 2020) {
          return DateTime(year, month, day);
        }
      }
    }

    // Pattern: "DD MMM YYYY" or "DD MMMM YYYY"
    final ddMmmYyyy = RegExp(r'(\d{1,2})\s+([a-zA-Z]{3,9})\s+(\d{2,4})', caseSensitive: false).firstMatch(cleaned);
    if (ddMmmYyyy != null) {
      final day = int.tryParse(ddMmmYyyy.group(1)!);
      final monthStr = ddMmmYyyy.group(2)!.toLowerCase();
      var year = int.tryParse(ddMmmYyyy.group(3)!);
      final month = months[monthStr];
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        if (day >= 1 && day <= 31 && year > 2020) {
          return DateTime(year, month, day);
        }
      }
    }

    // Pattern: "YYYY-MM-DD" (ISO)
    final isoMatch = RegExp(r'(\d{4})[/.\-](\d{1,2})[/.\-](\d{1,2})').firstMatch(cleaned);
    if (isoMatch != null) {
      final year = int.tryParse(isoMatch.group(1)!);
      final month = int.tryParse(isoMatch.group(2)!);
      final day = int.tryParse(isoMatch.group(3)!);
      if (year != null && month != null && day != null && year > 2020) {
        return DateTime(year, month, day);
      }
    }

    return null;
  }
}

class _SearchEntry {
  final String term;
  final ShelfLifeItem item;
  const _SearchEntry({required this.term, required this.item});
}
