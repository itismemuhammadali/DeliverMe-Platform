import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'local_database.dart';

class OfflineService extends GetxService {
  static OfflineService get to => Get.find();
  
  final LocalDatabase _localDb = LocalDatabase();
  final _uuid = const Uuid();

  /// Queue an action to be performed offline
  Future<void> queueAction(String action, Map<String, dynamic> data) async {
    final id = _uuid.v4();
    await _localDb.insertOfflineAction(id, action, data);
    print('📦 Action $action queued offline with ID $id');
    
    // Try to sync immediately if online
    syncData();
  }

  /// Sync all unsynced actions to the backend
  Future<void> syncData() async {
    final unsynced = await _localDb.getUnsyncedActions();
    if (unsynced.isEmpty) return;

    print('🔄 Syncing ${unsynced.length} offline actions...');

    for (var item in unsynced) {
      final id = item['id'] as String;
      final action = item['action'] as String;
      final data = jsonDecode(item['data'] as String);

      try {
        final result = await FirebaseFunctions.instance
            .httpsCallable('processOfflineAction')
            .call({
          'action': action,
          'data': data,
        });

        if (result.data['success'] == true) {
          await _localDb.markActionSynced(id);
          print('✅ Action $id ($action) synced successfully');
        }
      } catch (e) {
        print('❌ Failed to sync action $id: $e');
        // Stop syncing if one fails (might be network issue)
        break;
      }
    }
  }

  /// Cache data locally
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    await _localDb.cacheData(key, data);
  }

  /// Get cached data
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    return await _localDb.getCachedData(key);
  }
}
