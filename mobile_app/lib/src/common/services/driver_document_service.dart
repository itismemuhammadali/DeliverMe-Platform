import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../models/driver_model.dart';
import 'driver_api_service.dart';

class DriverDocumentService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera
  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );
      return image;
    } catch (e) {
      print('❌ Error picking image: $e');
      return null;
    }
  }

  /// Upload a file to Firebase Storage using gs:// path
  static Future<bool> uploadFileToFirebaseStorage({
    required String gsPath,
    required String filePath,
    required String contentType,
  }) async {
    try {
      print('🚀 Uploading file to Firebase Storage: $filePath');
      print('🚀 Firebase Storage path: $gsPath');
      print('🚀 Content Type: $contentType');

      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ File does not exist: $filePath');
        return false;
      }

      final fileSize = await file.length();
      print(
          '📄 File size: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');

      // Parse gs:// path to get bucket and path
      // Format: gs://bucket-name/path/to/file
      final uri = Uri.parse(gsPath);
      if (uri.scheme != 'gs') {
        print('❌ Invalid Firebase Storage path: $gsPath');
        return false;
      }

      final bucketName = uri.host;
      final storagePath = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;

      print('📄 Bucket: $bucketName');
      print('📄 Storage path: $storagePath');

      // Use Firebase Storage reference
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef.child(storagePath);

      // Upload file
      final bytes = await file.readAsBytes();
      final metadata = SettableMetadata(contentType: contentType);

      final uploadTask = fileRef.putData(bytes, metadata);
      final snapshot = await uploadTask;

      print('📡 Firebase Storage upload response status: ${snapshot.state}');

      if (snapshot.state == TaskState.success) {
        print('✅ File uploaded to Firebase Storage successfully');
        return true;
      } else {
        print('❌ Firebase Storage upload failed: ${snapshot.state}');
        return false;
      }
    } catch (e) {
      print('❌ Error uploading file to Firebase Storage: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Upload a file to GCS using signed URL or Firebase Storage SDK
  static Future<bool> uploadFileToGCS({
    required String uploadUrl,
    required String filePath,
    required String contentType,
  }) async {
    try {
      print('🚀 Uploading file to GCS: $filePath');
      print('🚀 Upload URL: $uploadUrl');
      print('🚀 Content Type: $contentType');

      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ File does not exist: $filePath');
        return false;
      }

      final fileSize = await file.length();
      print(
          '📄 File size: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');

      final bytes = await file.readAsBytes();
      print('📄 Bytes read: ${bytes.length}');

      // If URL is gs://, use Firebase Storage SDK with ref().child() pattern
      if (uploadUrl.startsWith('gs://')) {
        print('🔥 Using Firebase Storage SDK for upload');
        try {
          // Parse gs:// path to get bucket and storage path
          // Format: gs://bucket-name/path/to/file
          final uri = Uri.parse(uploadUrl);
          final bucketName = uri.host;
          final storagePath = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;

          print('📄 Bucket: $bucketName');
          print('📄 Storage path: $storagePath');

          // Use Firebase Storage reference with ref().child() pattern
          final storageRef = FirebaseStorage.instance.ref().child(storagePath);
          
          // Create metadata
          final metadata = SettableMetadata(contentType: contentType);
          
          // Upload file using putFile
          final uploadTask = await storageRef.putFile(file, metadata);
          
          if (uploadTask.state == TaskState.success) {
            print('✅ File uploaded to Firebase Storage successfully');
            return true;
          } else {
            print('❌ Firebase Storage upload failed: ${uploadTask.state}');
            return false;
          }
        } catch (e) {
          print('❌ Firebase Storage upload failed: $e');
          print('❌ Error type: ${e.runtimeType}');
          return false;
        }
      }

      // Otherwise use HTTP PUT (for signed URLs)
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': contentType,
        },
        body: bytes,
      );

      print('📡 GCS upload response status: ${response.statusCode}');
      print('📡 GCS upload response headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('✅ File uploaded to GCS successfully');
        return true;
      } else {
        print('❌ GCS upload failed: ${response.body}');
        print('❌ Response status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error uploading file to GCS: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  /// Upload bytes to GCS using signed URL
  static Future<bool> uploadBytesToGCS({
    required String uploadUrl,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      print('🚀 Uploading bytes to GCS');

      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': contentType,
        },
        body: bytes,
      );

      print('📡 GCS upload response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Bytes uploaded to GCS successfully');
        return true;
      } else {
        print('❌ GCS upload failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error uploading bytes to GCS: $e');
      return false;
    }
  }

  /// Complete document upload process
  static Future<String?> uploadDocument({
    required String docType,
    required XFile file,
  }) async {
    try {
      print('🚀 Starting document upload process for: $docType');

      // Check if driver is logged in
      final isLoggedIn = await DriverApiService.isLoggedIn();
      print('🔐 Driver logged in status: $isLoggedIn');

      if (!isLoggedIn) {
        throw Exception(
            'Driver must be logged in to upload documents. Please use registration flow for initial document upload.');
      }

      // Get current driver to get driver ID
      final currentDriver = await DriverApiService.getCurrentDriver();
      if (currentDriver?.id == null) {
        throw Exception('Driver ID not available');
      }

      // Get file info
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName).toLowerCase();

      // Determine content type based on file extension
      String contentType;
      switch (fileExtension) {
        case '.jpg':
        case '.jpeg':
          contentType = 'image/jpeg';
          break;
        case '.png':
          contentType = 'image/png';
          break;
        case '.pdf':
          contentType = 'application/pdf';
          break;
        default:
          contentType = 'application/octet-stream';
      }

      // Use public API for driving license and insurance documents (id_card is insurance in UI)
      final isPublicApi = (docType == 'driver_license' ||
          docType == 'insurance' ||
          docType == 'id_card');
      print(
          '📄 Using ${isPublicApi ? 'public' : 'authenticated'} API for $docType');
      if (docType == 'id_card') {
        print('📄 Note: id_card is treated as insurance document');
      }
      print('📄 Driver ID: ${currentDriver!.id}');

      print('📄 About to call upload API for $docType...');
      final uploadResponse = isPublicApi
          ? await DriverApiService.getPublicDocumentUploadUrl(
              driverId: currentDriver.id!,
              docType: docType,
              filename: fileName,
              contentType: contentType,
            )
          : await DriverApiService.getDocumentUploadUrl(
              docType: docType,
              filename: fileName,
              contentType: contentType,
            );

      print('📄 Upload API call completed for $docType');
      print('📄 Upload URL received: ${uploadResponse.uploadUrl}');
      print('📄 Object key: ${uploadResponse.objectKey}');

      // Upload file to GCS
      final uploadSuccess = await uploadFileToGCS(
        uploadUrl: uploadResponse.uploadUrl,
        filePath: file.path,
        contentType: contentType,
      );

      if (!uploadSuccess) {
        throw Exception('Failed to upload file to GCS');
      }

      print('✅ Document upload completed successfully');
      return uploadResponse.objectKey;
    } catch (e) {
      print('❌ Document upload failed: $e');
      rethrow;
    }
  }

  /// Upload multiple documents during registration
  static Future<Map<String, String?>> uploadRegistrationDocuments({
    required List<DocumentUploadRequest> documents,
    required Map<String, XFile> files,
  }) async {
    try {
      print('🚀 Starting registration document upload process');

      final results = <String, String?>{};

      // For registration, we'll upload documents after the driver is created
      // Store the files locally for now and return the file paths
      for (final doc in documents) {
        final file = files[doc.docType];
        if (file != null) {
          results[doc.docType] = file.path; // Store local path for now
          print('✅ Prepared ${doc.docType} for upload: ${file.path}');
        } else {
          print('⚠️ No file provided for document type: ${doc.docType}');
          results[doc.docType] = null;
        }
      }

      return results;
    } catch (e) {
      print('❌ Registration document upload failed: $e');
      rethrow;
    }
  }

  /// Upload documents after driver registration (when we have driver_id)
  static Future<Map<String, String?>> uploadDocumentsAfterRegistration({
    required int driverId,
    required Map<String, XFile> files,
    Function(String, bool)? onUploadingStateChanged,
  }) async {
    try {
      print(
          '🚀 Starting post-registration document upload process for driver: $driverId');
      print('📄 Files to upload: ${files.keys.toList()}');
      print('📄 Total files: ${files.length}');

      if (files.isEmpty) {
        print('⚠️ No files provided for upload');
        return {};
      }

      final results = <String, String?>{};

      for (final entry in files.entries) {
        final docType = entry.key;
        final file = entry.value;

        print('📄 Processing document: $docType');
        print('📄 File path: ${file.path}');
        print('📄 File name: ${file.name}');
        print('📄 File exists: ${await File(file.path).exists()}');

        try {
          // Mark as uploading
          onUploadingStateChanged?.call(docType, true);

          // Get file info
          final fileName = path.basename(file.path);
          final contentType = getContentTypeFromExtension(file.path);

          print('📄 File details - Name: $fileName, ContentType: $contentType');

          // Get upload path from backend
          print('📄 Getting upload URL for $docType...');
          if (docType == 'id_card') {
            print('📄 Note: id_card is treated as insurance document');
          }
          print('📄 About to call public upload API for $docType...');
          final uploadResponse =
              await DriverApiService.getPublicDocumentUploadUrl(
            driverId: driverId,
            docType: docType,
            filename: fileName,
            contentType: contentType,
          );
          print('📄 Public upload API call completed for $docType');

          print(
              '📄 Upload path received for $docType: ${uploadResponse.uploadUrl}');

          // Check if we got a Firebase Storage path (gs://) or a signed URL (https://)
          if (uploadResponse.uploadUrl.startsWith('gs://')) {
            // Use Firebase Storage SDK for direct upload
            print('📄 Using Firebase Storage SDK for $docType...');
            final uploadSuccess = await uploadFileToFirebaseStorage(
              gsPath: uploadResponse.uploadUrl,
              filePath: file.path,
              contentType: contentType,
            );

            if (uploadSuccess) {
              results[docType] = uploadResponse.objectKey;
              print(
                  '✅ Successfully uploaded ${docType}: ${uploadResponse.objectKey}');
            } else {
              results[docType] = null;
              print('❌ Firebase Storage upload failed for ${docType}');
            }
          } else {
            // Use HTTP PUT for signed URL
            print('📄 Using HTTP PUT for signed URL for $docType...');
            bool uploadSuccess = false;
            int retryCount = 0;
            const maxRetries = 2;

            while (!uploadSuccess && retryCount <= maxRetries) {
              if (retryCount > 0) {
                print(
                    '📄 Retrying upload for $docType (attempt ${retryCount + 1}/${maxRetries + 1})...');
                await Future.delayed(Duration(seconds: 2));
              }

              uploadSuccess = await uploadFileToGCS(
                uploadUrl: uploadResponse.uploadUrl,
                filePath: file.path,
                contentType: contentType,
              );

              retryCount++;
            }

            if (uploadSuccess) {
              results[docType] = uploadResponse.objectKey;
              print(
                  '✅ Successfully uploaded ${docType}: ${uploadResponse.objectKey}');
            } else {
              results[docType] = null;
              print(
                  '❌ GCS upload failed for ${docType} after ${maxRetries + 1} attempts');
            }
          }
        } catch (e) {
          print('❌ Error uploading ${docType}: $e');
          print('❌ Error type: ${e.runtimeType}');
          print('❌ Stack trace: ${StackTrace.current}');
          results[docType] = null;
        } finally {
          // Mark as not uploading
          onUploadingStateChanged?.call(docType, false);
        }
      }

      print('📄 Upload results summary:');
      results.forEach((docType, objectKey) {
        if (objectKey != null) {
          print('✅ $docType: $objectKey');
        } else {
          print('❌ $docType: FAILED');
        }
      });

      return results;
    } catch (e) {
      print('❌ Post-registration document upload failed: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      print('❌ Error getting file size: $e');
      return 0.0;
    }
  }

  /// Validate file size (max 10MB)
  static bool isValidFileSize(double sizeInMB) {
    return sizeInMB <= 10.0;
  }

  /// Validate file type
  static bool isValidFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.pdf'].contains(extension);
  }

  /// Get content type from file extension
  static String getContentTypeFromExtension(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  /// Debug method to check document upload status
  static void debugDocumentUploadStatus(Map<String, String?> results) {
    print('🔍 Document Upload Debug Status:');
    print('🔍 Total documents processed: ${results.length}');

    for (final entry in results.entries) {
      final docType = entry.key;
      final objectKey = entry.value;

      if (objectKey != null) {
        print('✅ $docType: Successfully uploaded (Key: $objectKey)');
      } else {
        print('❌ $docType: Upload failed');
      }
    }

    // Check if any documents failed
    final failedUploads =
        results.entries.where((e) => e.value == null).toList();
    if (failedUploads.isNotEmpty) {
      print('⚠️ Failed uploads: ${failedUploads.map((e) => e.key).join(', ')}');
    } else {
      print('🎉 All documents uploaded successfully!');
    }
  }
}
