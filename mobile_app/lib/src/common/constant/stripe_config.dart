class StripeConfig {
  // Stripe configuration
  static const String currency = 'cad';
  static const String countryCode = 'CA';

  // Test card numbers for development (CAD compatible)
  static const Map<String, String> testCards = {
    'visa': '4242424242424242',
    'visa_debit': '4000056655665556',
    'mastercard': '5555555555554444',
    'amex': '378282246310005',
    'discover': '6011111111111117',
    'diners': '3056930009020004',
    // Canadian test cards
    'visa_ca': '4242424242424242',
    'mastercard_ca': '5555555555554444',
  };

  // Test card details
  static const String testExpiryMonth = '12';
  static const String testExpiryYear = '2025';
  static const String testCvc = '123';
  static const String testCardholderName = 'Test User';

  // Validation methods
  static bool isValidPublicKey(String key) {
    return key.startsWith('pk_test_') || key.startsWith('pk_live_');
  }

  static bool isTestMode(String key) {
    return key.startsWith('pk_test_');
  }

  static String getEnvironment(String key) {
    return isTestMode(key) ? 'Test' : 'Live';
  }

  // NOTE: For production, use StripeConfigService instead of this class
  // StripeConfigService loads keys from Firebase Remote Config dynamically
  static String getRemoteConfigPublicKey() {
    throw Exception(
        'Stripe public key not configured. Set stripe_public_key in Firebase Remote Config.');
  }
}
