import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../../../common/services/driver_api_service.dart';
import '../../../../common/services/driver_document_service.dart';

class DriverDocumentsController extends GetxController {
  static DriverDocumentsController get to => Get.find<DriverDocumentsController>();

  // State
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Documents map
  final RxMap<String, XFile> documents = <String, XFile>{}.obs;
  final RxMap<String, bool> uploadedDocuments = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDocumentTracking();
  }

  void _initializeDocumentTracking() {
    uploadedDocuments['driver_license'] = false;
    uploadedDocuments['id_card'] = false;
    uploadedDocuments['insurance'] = false;
  }

  /// Load document status from server
  Future<void> loadDocuments() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get current driver to check document status
      final currentDriver = await DriverApiService.getCurrentDriver();
      if (currentDriver != null) {
        print('📋 Driver profile data:');
        print('  - drivingLicenseImage: ${currentDriver.drivingLicenseImage}');
        print('  - drivingLicenseUrl: ${currentDriver.drivingLicenseUrl}');
        print('  - drivingLicenseFilename: ${currentDriver.drivingLicenseFilename}');
        print('  - idCardImage: ${currentDriver.idCardImage}');
        print('  - idCardUrl: ${currentDriver.idCardUrl}');
        print('  - idCardFilename: ${currentDriver.idCardFilename}');
        
        // Check which documents have been uploaded (non-null and non-empty)
        uploadedDocuments['driver_license'] =
            (currentDriver.drivingLicenseImage?.isNotEmpty ?? false) ||
            (currentDriver.drivingLicenseUrl?.isNotEmpty ?? false);
        uploadedDocuments['id_card'] =
            (currentDriver.idCardImage?.isNotEmpty ?? false) ||
            (currentDriver.idCardUrl?.isNotEmpty ?? false);
        // Insurance is stored in id_card fields on backend
        uploadedDocuments['insurance'] =
            (currentDriver.idCardImage?.isNotEmpty ?? false) ||
            (currentDriver.idCardUrl?.isNotEmpty ?? false);
        
        // Store filenames in a map for display
        _documentFilenames = {
          'driver_license': currentDriver.drivingLicenseFilename ?? '',
          'id_card': currentDriver.idCardFilename ?? '',
          'insurance': currentDriver.idCardFilename ?? '',
        };
        
        print('✅ Documents loaded');
        print('  - driver_license: ${uploadedDocuments["driver_license"]} (${_documentFilenames['driver_license']})');
        print('  - id_card: ${uploadedDocuments["id_card"]} (${_documentFilenames['id_card']})');
        print('  - insurance: ${uploadedDocuments["insurance"]} (${_documentFilenames['insurance']})');
      }

      print('✅ Documents loaded');
    } catch (e) {
      print('❌ Error loading documents: $e');
      error.value = 'Error loading documents: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  // Store for document filenames from server
  Map<String, String> _documentFilenames = {};

  /// Pick a document
  Future<void> pickDocument(String docType) async {
    try {
      final XFile? image = await DriverDocumentService.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null) return;

      final fileSize = await DriverDocumentService.getFileSizeInMB(image.path);
      if (!DriverDocumentService.isValidFileSize(fileSize)) {
        error.value = 'File size must be less than 10MB';
        return;
      }
      if (!DriverDocumentService.isValidFileType(image.path)) {
        error.value = 'Only JPG, PNG, and PDF files are allowed';
        return;
      }

      documents[docType] = image;
      print('📄 Document selected: $docType');
    } catch (e) {
      error.value = 'Failed to pick document: ${e.toString()}';
      print('❌ Error picking document: $e');
    }
  }

  /// Upload all documents
  Future<bool> uploadAllDocuments() async {
    try {
      isLoading.value = true;
      error.value = '';

      if (documents.isEmpty) {
        error.value = 'Please select at least one document to upload';
        return false;
      }

      final currentDriver = await DriverApiService.getCurrentDriver();
      if (currentDriver?.id == null) {
        error.value = 'Driver ID not available';
        return false;
      }

      // Upload each document
      for (final entry in documents.entries) {
        try {
          final docType = entry.key;
          final file = entry.value;

          final fileName = path.basename(file.path);
          final contentType =
              DriverDocumentService.getContentTypeFromExtension(file.path);

          // Get upload URL
          final uploadResponse = await DriverApiService.getPublicDocumentUploadUrl(
            driverId: currentDriver!.id!,
            docType: docType,
            filename: fileName,
            contentType: contentType,
          );

          // Upload to GCS
          final uploadSuccess = await DriverDocumentService.uploadFileToGCS(
            uploadUrl: uploadResponse.uploadUrl,
            filePath: file.path,
            contentType: contentType,
          );

          if (!uploadSuccess) {
            throw Exception('Failed to upload $docType to GCS');
          }

          // Confirm upload with backend to store the document reference
          print('🔐 Calling confirm-upload endpoint with: driverId=${currentDriver.id}, docType=$docType, objectKey=${uploadResponse.objectKey}, filename=$fileName');
          await DriverApiService.confirmDocumentUpload(
            driverId: currentDriver.id!,
            docType: docType,
            objectKey: uploadResponse.objectKey,
            filename: fileName,
          );
          print('✅ Confirm-upload response received');

          uploadedDocuments[docType] = true;
          print('✅ Document uploaded successfully: $docType');
        } catch (e) {
          print('❌ Error uploading document: $e');
          error.value = 'Failed to upload document: ${e.toString()}';
          return false;
        }
      }

      // Clear documents after successful upload
      documents.clear();
      
      // Force refresh driver profile from server to get updated document status
      print('🔄 Refreshing driver profile from server...');
      await DriverApiService.refreshDriverProfile();
      
      // Reload profile to get updated document status
      await loadDocuments();
      
      print('✅ All documents uploaded successfully');
      return true;
    } catch (e) {
      error.value = 'Error uploading documents: ${e.toString()}';
      print('❌ Error uploading all documents: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a document
  Future<bool> deleteDocument(String docType) async {
    try {
      isLoading.value = true;
      error.value = '';

      final currentDriver = await DriverApiService.getCurrentDriver();
      if (currentDriver?.id == null) {
        error.value = 'Driver ID not available';
        return false;
      }

      // Call backend to delete document
      await DriverApiService.deleteDocument(
        driverId: currentDriver!.id!,
        docType: docType,
      );

      // Update local state
      uploadedDocuments[docType] = false;
      documents.remove(docType);

      print('✅ Document deleted successfully: $docType');
      return true;
    } catch (e) {
      print('❌ Error deleting document: $e');
      error.value = 'Failed to delete document: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the document filename from server
  String getDocumentFileName(String docType) {
    // First check local document (pending upload)
    if (documents.containsKey(docType)) {
      return documents[docType]?.name ?? '';
    }
    // Then check server filenames (already uploaded)
    return _documentFilenames[docType] ?? '';
  }

  /// Check if document is uploaded
  bool isDocumentUploaded(String docType) {
    return uploadedDocuments[docType] ?? false;
  }

  /// Check if document is selected
  bool hasDocument(String docType) {
    return documents.containsKey(docType);
  }
}
