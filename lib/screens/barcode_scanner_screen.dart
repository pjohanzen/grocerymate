import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/item_provider.dart';
import '../services/local_storage_service.dart';
import '../utils/currency_formatter.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  final String listId;

  const BarcodeScannerScreen({super.key, required this.listId});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  final _manualCodeController = TextEditingController();
  bool _isScanning = true;
  String? _scannedCode;
  Map<dynamic, dynamic>? _foundProduct;
  bool _isNewProduct = false;

  final _newProductNameController = TextEditingController();
  final _newProductPriceController = TextEditingController();
  String? _newProductCategoryId;

  // Preloaded simulation barcodes for simple testing/demos
  final List<Map<String, String>> _mockBarcodes = [
    {'code': '4800003010123', 'name': 'Milo 22g'},
    {'code': '4800003010456', 'name': 'Coca-Cola 1.5L'},
    {'code': '4800012345678', 'name': 'Safeguard Soap'},
    {'code': '4800022334455', 'name': 'Gardenia Bread'},
    {'code': '4800033445566', 'name': 'Century Tuna'},
    {'code': '4800044556677', 'name': 'Pancit Canton'},
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_laserController);
  }

  @override
  void dispose() {
    _laserController.dispose();
    _manualCodeController.dispose();
    _newProductNameController.dispose();
    _newProductPriceController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(String code) {
    if (!_isScanning) return;
    setState(() {
      _isScanning = false;
      _scannedCode = code;
      final product = LocalStorageService.getBarcodeProduct(code);
      if (product != null) {
        _foundProduct = product;
        _isNewProduct = false;
      } else {
        _foundProduct = null;
        _isNewProduct = true;
        _newProductNameController.clear();
        _newProductPriceController.clear();
        _newProductCategoryId = null;
      }
    });
  }

  void _addFoundProductToList() {
    if (_foundProduct == null) return;
    ref.read(listItemsProvider(widget.listId).notifier).addItem(
          name: _foundProduct!['name'],
          quantity: 1.0,
          unit: 'pcs',
          unitPrice: _foundProduct!['price'],
          categoryId: _foundProduct!['categoryId'],
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${_foundProduct!['name']}" to list!'),
        backgroundColor: AppTheme.success,
      ),
    );

    _resetScanner();
  }

  Future<void> _saveNewProductAndAdd() async {
    final name = _newProductNameController.text.trim();
    final priceStr = _newProductPriceController.text.trim();
    final price = priceStr.isEmpty ? null : double.tryParse(priceStr);

    if (name.isEmpty || _scannedCode == null) return;

    final newProduct = {
      'name': name,
      'categoryId': _newProductCategoryId,
      'price': price ?? 0.0,
    };

    // Save barcode locally
    await LocalStorageService.saveBarcodeProduct(_scannedCode!, newProduct);

    // Add to current shopping list
    ref.read(listItemsProvider(widget.listId).notifier).addItem(
          name: name,
          quantity: 1.0,
          unit: 'pcs',
          unitPrice: price,
          categoryId: _newProductCategoryId,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved and added "$name" to list!'),
          backgroundColor: AppTheme.success,
        ),
      );
      _resetScanner();
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _scannedCode = null;
      _foundProduct = null;
      _isNewProduct = false;
      _manualCodeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isScanning) ...[
                // VIEW FINDER WITH ANIMATED LASER
                Center(
                  child: Container(
                    width: 280,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 2.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Viewfinder grid look
                        Center(
                          child: Opacity(
                            opacity: 0.15,
                            child: Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 120,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        // Laser line
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 200 * _laserAnimation.value,
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.8),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              'Align barcode within frame',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // QUICK SIMULATION BUTTONS
                Text(
                  'Simulation Control Deck',
                  style: AppTheme.label.copyWith(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.neutral500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _mockBarcodes.map((mock) {
                    return ActionChip(
                      label: Text(mock['name']!),
                      onPressed: () => _onBarcodeDetected(mock['code']!),
                    );
                  }).toList()
                    ..add(
                      ActionChip(
                        avatar: const Icon(Icons.help_outline_rounded, size: 14),
                        label: const Text('Unknown Barcode'),
                        onPressed: () => _onBarcodeDetected('4800099998888'),
                      ),
                    ),
                ),
                const SizedBox(height: 20),

                // MANUAL INPUT
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Or Enter Barcode Manually',
                  style: AppTheme.headline3.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualCodeController,
                        decoration: const InputDecoration(
                          hintText: 'Enter barcode number...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(64, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final val = _manualCodeController.text.trim();
                        if (val.isNotEmpty) _onBarcodeDetected(val);
                      },
                      child: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
              ] else ...[
                // PRODUCT MATCHED VIEW
                if (_foundProduct != null) ...[
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 48, color: theme.colorScheme.primary),
                          const SizedBox(height: 12),
                          Text(
                            'Product Identified!',
                            style: AppTheme.headline3.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _foundProduct!['name'],
                            style: AppTheme.headline2.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: ${CurrencyFormatter.formatWhole(_foundProduct!['price'])}',
                            style: AppTheme.monoBold.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _addFoundProductToList,
                            child: const Text('Add to Shopping List'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _resetScanner,
                            child: const Text('Scan Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (_isNewProduct) ...[
                  // NEW PRODUCT REGISTER VIEW
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.new_releases_outlined, color: theme.colorScheme.secondary),
                              const SizedBox(width: 8),
                              const Text('Unknown Barcode detected!', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Barcode: $_scannedCode',
                            style: AppTheme.monoRegular.copyWith(fontSize: 12),
                          ),
                          const Divider(height: 24),
                          Text('Product Name', style: AppTheme.label),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _newProductNameController,
                            decoration: const InputDecoration(hintText: 'e.g., Milo Refill'),
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 12),
                          Text('Category', style: AppTheme.label),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _newProductCategoryId,
                            hint: const Text('Select category'),
                            items: categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _newProductCategoryId = v),
                            dropdownColor: isDark ? AppTheme.darkSurfaceHigh : Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text('Price', style: AppTheme.label),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _newProductPriceController,
                            decoration: const InputDecoration(
                              hintText: '₱0.00',
                              prefixText: '₱ ',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _saveNewProductAndAdd,
                            child: const Text('Save & Add to List'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _resetScanner,
                            child: const Text('Cancel Scan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
