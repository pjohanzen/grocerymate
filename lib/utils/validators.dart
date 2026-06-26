class Validators {
  Validators._();

  static String? validateListName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a list name';
    }
    if (value.trim().length > 50) {
      return 'List name must be 50 characters or less';
    }
    return null;
  }

  static String? validateItemName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an item name';
    }
    if (value.trim().length > 100) {
      return 'Item name must be 100 characters or less';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a quantity';
    }
    final qty = double.tryParse(value.trim());
    if (qty == null || qty <= 0) {
      return 'Enter a valid quantity';
    }
    if (qty > 99999) {
      return 'Quantity too large';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Price is optional
    }
    final price = double.tryParse(value.trim().replaceAll(RegExp(r'[₱,]'), ''));
    if (price == null || price < 0) {
      return 'Enter a valid price';
    }
    if (price > 9999999) {
      return 'Price too large';
    }
    return null;
  }

  static String? validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Budget is optional
    }
    final budget = double.tryParse(value.trim().replaceAll(RegExp(r'[₱,]'), ''));
    if (budget == null || budget < 0) {
      return 'Enter a valid budget';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value != null && value.length > 200) {
      return 'Notes must be 200 characters or less';
    }
    return null;
  }
}
