import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/list_item.dart';
import '../providers/item_provider.dart';
import '../utils/currency_formatter.dart';

class ReceiptOcrScreen extends ConsumerStatefulWidget {
  final String listId;

  const ReceiptOcrScreen({super.key, required this.listId});

  @override
  ConsumerState<ReceiptOcrScreen> createState() => _ReceiptOcrScreenState();
}

class _ReceiptOcrScreenState extends ConsumerState<ReceiptOcrScreen> {
  bool _isProcessing = false;
  String? _parsedRawText;
  List<OcrParsedItem> _parsedItems = [];
  List<OcrMatchResult> _matches = [];

  // Realistic simulated receipts for PH stores (SM Supermarket, Puregold, Robinsons)
  final List<MockReceipt> _mockReceipts = [
    MockReceipt(
      storeName: 'SM SUPERMARKET - MEGAMALL',
      rawText: '''
SM SUPERMARKET
OR# 123456789-PH
-----------------------------
MILO Refill 1   1x   185.00
EGGS DOZEN      1x    95.00
GARDENIA BREAD  2x    85.00
COCA-COLA 1.5L  1x    72.00
Century Tuna    3x    42.00
-----------------------------
TOTAL PHP            606.00
CASH RECEIVED        1000.00
CHANGE               394.00
THANK YOU! COME AGAIN.
''',
    ),
    MockReceipt(
      storeName: 'PUREGOLD PRICE CLUB',
      rawText: '''
PUREGOLD SHAW
REG04-T100234
-----------------------------
Milo 22g        5x    15.00
Century Tuna    2x    42.00
Pancit Canton   6x    18.00
Safeguard Soap  1x    54.00
Gardenia Bread  1x    85.00
-----------------------------
TOTAL                402.00
ITEMS COUNT            15
''',
    ),
  ];

  void _processReceipt(String text) {
    setState(() {
      _isProcessing = true;
    });

    // Simulate OCR processing delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final parsed = _parseReceiptText(text);
      final items = ref.read(listItemsProvider(widget.listId));
      final matches = _matchParsedToGroceryList(parsed, items);

      setState(() {
        _isProcessing = false;
        _parsedRawText = text;
        _parsedItems = parsed;
        _matches = matches;
      });
    });
  }

  List<OcrParsedItem> _parseReceiptText(String text) {
    final List<OcrParsedItem> items = [];
    final lines = text.split('\n');

    // Matches e.g., "MILO Refill 1   1x   185.00" or "Milo 22g        5x    15.00"
    // Also matches "Century Tuna    2x    42.00"
    final regex = RegExp(r'^\s*([a-zA-Z0-9\s!\.\-]+?)\s+(\d+)\s*[xX]\s+(\d+(?:\.\d{2})?)\s*$');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.contains('---') || line.toLowerCase().contains('total') || line.toLowerCase().contains('change')) {
        continue;
      }
      final match = regex.firstMatch(line);
      if (match != null) {
        final name = match.group(1)!.trim();
        final qty = double.tryParse(match.group(2)!) ?? 1.0;
        final price = double.tryParse(match.group(3)!) ?? 0.0;
        items.add(OcrParsedItem(name: name, quantity: qty, price: price));
      }
    }
    return items;
  }

  List<OcrMatchResult> _matchParsedToGroceryList(List<OcrParsedItem> parsed, List<ListItem> listItems) {
    return parsed.map((p) {
      // Find matching item in shopping list using simple fuzzy logic
      ListItem? bestMatch;
      double highestScore = 0.0;

      for (final item in listItems) {
        final score = _calculateSimilarity(p.name.toLowerCase(), item.name.toLowerCase());
        if (score > highestScore && score > 0.4) {
          highestScore = score;
          bestMatch = item;
        }
      }

      return OcrMatchResult(
        parsedItem: p,
        matchedItem: bestMatch,
        similarityScore: highestScore,
        shouldImport: bestMatch != null, // Auto-import matched items
      );
    }).toList();
  }

  double _calculateSimilarity(String s1, String s2) {
    // Basic Jaro-Winkler or overlap score for quick offline matching
    final words1 = s1.split(' ');
    final words2 = s2.split(' ');
    int matches = 0;
    for (final w1 in words1) {
      if (w1.length < 3) continue;
      for (final w2 in words2) {
        if (w2.length < 3) continue;
        if (w1 == w2 || w1.contains(w2) || w2.contains(w1)) {
          matches++;
          break;
        }
      }
    }
    return matches / max(words1.length, words2.length);
  }

  Future<void> _importMatches() async {
    int importedCount = 0;
    final listNotifier = ref.read(listItemsProvider(widget.listId).notifier);

    for (final match in _matches) {
      if (!match.shouldImport) continue;

      if (match.matchedItem != null) {
        // Match found: update price and complete
        final updated = match.matchedItem!.copyWith(
          isCompleted: true,
          unitPrice: match.parsedItem.price,
          quantity: match.parsedItem.quantity, // Sync receipt quantity
        );
        listNotifier.updateItem(updated);
        importedCount++;
      } else {
        // No match: add as a new completed item
        final newItem = await listNotifier.addItem(
          name: match.parsedItem.name,
          quantity: match.parsedItem.quantity,
          unit: 'pcs',
          unitPrice: match.parsedItem.price,
        );
        listNotifier.updateItem(newItem.copyWith(isCompleted: true));
        importedCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully imported/synced $importedCount items!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _resetScanner() {
    setState(() {
      _parsedRawText = null;
      _parsedItems = [];
      _matches = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt OCR'),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Extracting items from receipt...',
                    style: AppTheme.bodyLarge.copyWith(color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600),
                  ),
                ],
              ),
            )
          : _parsedRawText == null
              ? _buildReceiptUploadUI(isDark, theme)
              : _buildMatchingUI(isDark, theme),
    );
  }

  Widget _buildReceiptUploadUI(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.neutral300,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Scan Grocery Receipt',
                  style: AppTheme.headline2.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Upload or choose a mock receipt to automatically parse product names, quantities, and prices to match your list.',
                  style: AppTheme.bodyRegular.copyWith(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Select Simulated Receipt Template',
            style: AppTheme.label.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral600,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Column(
            children: _mockReceipts.map((mock) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _processReceipt(mock.rawText),
                  icon: const Icon(Icons.receipt_outlined),
                  label: Text(mock.storeName),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingUI(bool isDark, ThemeData theme) {
    return Column(
      children: [
        // Summary header
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.primaryContainer,
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OCR Processing Complete',
                      style: AppTheme.headline3.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Found ${_parsedItems.length} items. Match them to your current list below.',
                      style: AppTheme.caption.copyWith(color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Side-by-side list matcher
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _matches.length,
            itemBuilder: (context, index) {
              final match = _matches[index];
              final hasMatch = match.matchedItem != null;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurfaceElevated : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: match.shouldImport
                        ? (hasMatch ? AppTheme.success.withValues(alpha: 0.5) : theme.colorScheme.primary.withValues(alpha: 0.5))
                        : (isDark ? AppTheme.darkBorder : AppTheme.neutral200),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: match.shouldImport,
                      onChanged: (val) {
                        setState(() {
                          match.shouldImport = val ?? false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Scanned info
                          Text(
                            match.parsedItem.name,
                            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${match.parsedItem.quantity.toInt()}x @ ${CurrencyFormatter.formatWhole(match.parsedItem.price)}',
                                style: AppTheme.caption.copyWith(
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Matched shopping list item
                          if (hasMatch)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.link_rounded, size: 14, color: AppTheme.success),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Matches: ${match.matchedItem!.name}',
                                      style: AppTheme.caption.copyWith(
                                        color: AppTheme.success,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.add_circle_outline_rounded, size: 14, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Will add as a new item',
                                      style: AppTheme.caption.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetScanner,
                  child: const Text('Scan Another'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _importMatches,
                  child: const Text('Import & Sync List'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MockReceipt {
  final String storeName;
  final String rawText;

  MockReceipt({required this.storeName, required this.rawText});
}

class OcrParsedItem {
  final String name;
  final double quantity;
  final double price;

  OcrParsedItem({required this.name, required this.quantity, required this.price});
}

class OcrMatchResult {
  final OcrParsedItem parsedItem;
  final ListItem? matchedItem;
  final double similarityScore;
  bool shouldImport;

  OcrMatchResult({
    required this.parsedItem,
    this.matchedItem,
    required this.similarityScore,
    required this.shouldImport,
  });
}
