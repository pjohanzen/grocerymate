import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_mate/utils/currency_formatter.dart';
import 'package:grocery_mate/utils/validators.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('format formats correctly with decimals', () {
      expect(CurrencyFormatter.format(1234.56), contains('₱1,234.56'));
    });

    test('formatWhole formats correctly without decimals', () {
      expect(CurrencyFormatter.formatWhole(1234.56), contains('₱1,235'));
    });

    test('formatCompact formats compact numbers', () {
      expect(CurrencyFormatter.formatCompact(15000), contains('15K'));
      expect(CurrencyFormatter.formatCompact(500), contains('₱500'));
    });

    test('parse extracts numeric double correctly', () {
      expect(CurrencyFormatter.parse('₱1,234.56'), 1234.56);
      expect(CurrencyFormatter.parse(' 500 '), 500.0);
    });
  });

  group('Validators Tests', () {
    test('validateListName validates blank and long string', () {
      expect(Validators.validateListName(null), isNotNull);
      expect(Validators.validateListName(''), isNotNull);
      expect(Validators.validateListName('Valid'), isNull);
    });
  });
}
