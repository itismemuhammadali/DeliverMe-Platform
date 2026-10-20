import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

class StripeConfigService extends GetxService {
  static StripeConfigService get to => Get.find<StripeConfigService>();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Observable stripe keys
  final RxString stripePublicKey = ''.obs;
  final RxString stripeCurrency = 'cad'.obs;
  final RxBool isConfigLoaded = false.obs;
  final RxString configError = ''.obs;

  static const String defaultCurrency = 'cad';

  @override
  Future<void> onInit() async {
    super.onInit();
    await initializeRemoteConfig();
  }

  /// Initialize Firebase Remote Config and fetch Stripe keys
  Future<void> initializeRemoteConfig() async {
    try {
      print('🔧 Initializing StripeConfigService...');

      // Set default values
      await _remoteConfig.setDefaults({
        'stripe_currency': defaultCurrency,
        'stripe_country_code': 'CA',
      });

      // Set minimum fetch interval to 0 so we always get fresh keys
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 60),
        minimumFetchInterval: Duration.zero,
      ));

      // Fetch remote config with cache expiration
      await _remoteConfig.fetchAndActivate();
      print('✅ Remote Config fetched and activated');

      // Get values from remote config
      _loadStripeKeys();

      print('✅ StripeConfigService initialized successfully');
      isConfigLoaded.value = true;
    } catch (e) {
      print('❌ Error initializing RemoteConfig: $e');
      configError.value = 'Failed to load config: $e';
      isConfigLoaded.value = true;
    }
  }

  /// Load Stripe keys from Remote Config
  void _loadStripeKeys() {
    try {
      print('📥 Loading Stripe keys from Remote Config...');

      // Get public key
      final publicKey = _remoteConfig.getString('stripe_public_key');
      final currency = _remoteConfig.getString('stripe_currency');

      if (publicKey.isNotEmpty) {
        stripePublicKey.value = publicKey;
        print('✅ Public Key loaded: ${publicKey.substring(0, 20)}...');
      } else {
        print('❌ Stripe public key not configured in Remote Config');
        configError.value =
            'Stripe public key not configured. Set stripe_public_key in Firebase Remote Config.';
      }

      if (currency.isNotEmpty) {
        stripeCurrency.value = currency.toLowerCase();
        print('✅ Currency loaded: $currency');
      } else {
        stripeCurrency.value = defaultCurrency;
      }

      print('🔍 Final Stripe Public Key: ${stripePublicKey.value.isNotEmpty ? stripePublicKey.value.substring(0, 20) : "NOT SET"}...');
      print('🔍 Final Currency: ${stripeCurrency.value}');
    } catch (e) {
      print('❌ Error loading Stripe keys: $e');
    }
  }

  /// Get current Stripe public key
  String getPublicKey() {
    if (stripePublicKey.value.isEmpty) {
      throw Exception(
          'Stripe public key not configured. Set stripe_public_key in Firebase Remote Config.');
    }
    return stripePublicKey.value;
  }

  /// Get current currency
  String getCurrency() {
    return stripeCurrency.value.isNotEmpty ? stripeCurrency.value : defaultCurrency;
  }

  /// Check if public key is valid
  bool isValidPublicKey() {
    final key = getPublicKey();
    return key.startsWith('pk_test_') || key.startsWith('pk_live_');
  }

  /// Check if in test mode
  bool isTestMode() {
    return getPublicKey().startsWith('pk_test_');
  }

  /// Get environment name
  String getEnvironment() {
    return isTestMode() ? 'Test' : 'Live';
  }

  /// Force refresh config from Remote Config
  Future<void> refreshConfig() async {
    try {
      print('🔄 Refreshing Remote Config...');
      await _remoteConfig.fetchAndActivate();
      _loadStripeKeys();
      print('✅ Remote Config refreshed successfully');
    } catch (e) {
      print('❌ Error refreshing config: $e');
      configError.value = 'Failed to refresh config: $e';
    }
  }

  /// Get Remote Config value (generic)
  String getRemoteConfigValue(String key, String defaultValue) {
    try {
      return _remoteConfig.getString(key).isNotEmpty
          ? _remoteConfig.getString(key)
          : defaultValue;
    } catch (e) {
      print('⚠️ Error getting Remote Config value for $key: $e');
      return defaultValue;
    }
  }

  /// Debug: Print all Remote Config values
  void debugPrintConfig() {
    print('📋 ===== REMOTE CONFIG DEBUG =====');
    print('Public Key: ${stripePublicKey.value.substring(0, 20)}...');
    print('Currency: ${stripeCurrency.value}');
    print('Valid Public Key: ${isValidPublicKey()}');
    print('Environment: ${getEnvironment()}');
    print('Is Config Loaded: ${isConfigLoaded.value}');
    print('Config Error: ${configError.value}');
    print('🏁 ==============================');
  }
}
