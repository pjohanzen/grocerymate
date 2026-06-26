import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormatter = NumberFormat.compactCurrency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  static final NumberFormat _noDecimalFormatter = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 0,
  );

  /// Format as "₱1,234.56"
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format as "₱1,235" (no decimals)
  static String formatWhole(double amount) {
    return _noDecimalFormatter.format(amount);
  }

  /// Format as "₱1.2K" for large numbers
  static String formatCompact(double amount) {
    if (amount < 10000) return formatWhole(amount);
    return _compactFormatter.format(amount);
  }

  /// Format as "₱85/kg" for unit prices
  static String formatUnitPrice(double price, String unit) {
    return '${formatWhole(price)}/$unit';
  }

  /// Format budget display: "₱2,450 / ₱5,000"
  static String formatBudgetDisplay(double spent, double budget) {
    return '${formatWhole(spent)} / ${formatWhole(budget)}';
  }

  /// Parse currency string to double
  static double? parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[₱,\s]'), '');
    return double.tryParse(cleaned);
  }
}
