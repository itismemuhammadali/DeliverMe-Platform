import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../common/constant/app_colors.dart';

class PdfViewerService {
  static const String _pdfPath = 'Independent_Contractor_Agreement_Driver.pdf';

  /// Opens the Independent Contractor Agreement PDF
  static Future<void> openIndependentContractorAgreement() async {
    try {
      // Show loading dialog first
      _showLoadingDialog();

      // For web platform
      if (GetPlatform.isWeb) {
        Get.back(); // Close loading dialog
        final url = Uri.parse('/$_pdfPath');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.inAppWebView);
        } else {
          throw Exception('Could not launch PDF viewer');
        }
      } else {
        // For mobile platforms, try to open PDF externally first
        await _openPdfExternally();
      }
    } catch (e) {
      Get.back(); // Close loading dialog if open
      print('Error opening PDF: $e');
      // Show fallback dialog with agreement text
      await _showFallbackDialog();
    }
  }

  /// Shows loading dialog
  static void _showLoadingDialog() {
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Loading Agreement...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Opens PDF externally using device's default PDF viewer
  static Future<void> _openPdfExternally() async {
    try {
      // Get the asset as bytes
      final ByteData data = await rootBundle.load('assets/$_pdfPath');
      final Uint8List bytes = data.buffer.asUint8List();

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$_pdfPath');

      // Write bytes to temporary file
      await tempFile.writeAsBytes(bytes);

      // Close loading dialog
      Get.back();

      // Try to open with external PDF viewer
      final uri = Uri.file(tempFile.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // If external launch fails, show fallback dialog
        await _showFallbackDialog();
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      print('Error opening PDF externally: $e');
      // Show fallback dialog with agreement text
      await _showFallbackDialog();
    }
  }

  /// Shows fallback dialog when PDF cannot be loaded
  static Future<void> _showFallbackDialog() async {
    Get.dialog(
      Dialog(
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.8,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description,
                    color: AppColors.primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Independent Contractor Agreement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'INDEPENDENT CONTRACTOR AGREEMENT (DRIVER)\n\n'
                    'This Agreement is entered into by and between DELIVERMEE Tech Corp., an Ontario corporation ("Company"), and the undersigned driver ("Contractor").\n\n'
                    '1. ENGAGEMENT\n'
                    'Contractor agrees to provide delivery and moving services to users of the DeliverMee platform as an independent contractor, not as an employee.\n\n'
                    '1.1) Eligibility & Age Requirement\n'
                    'Contractor represents and warrants that they are at least 18 years of age, hold a valid driver\'s license, and are legally permitted to perform delivery services in the jurisdiction in which they operate.\n\n'
                    '2. INDEPENDENT CONTRACTOR STATUS\n'
                    '• Contractor is not an employee of DeliverMee.\n'
                    '• Contractor is responsible for their own taxes, insurance, and expenses.\n'
                    '• Nothing in this Agreement shall be interpreted as creating an employment relationship.\n\n'
                    '2.1 Acknowledgment of Independent Contractor Status\n'
                    'Contractor acknowledges that they are an independent contractor and not an employee of DeliverMee. Contractor is not entitled to any employee benefits, including but not limited to vacation pay, sick leave, health insurance, or pension plans.\n\n'
                    '3. RESPONSIBILITIES\n'
                    'Contractor shall:\n'
                    '• Maintain a valid driver\'s license.\n'
                    '• Use a registered and insured vehicle.\n'
                    '• Comply with traffic laws and safety regulations.\n'
                    '• Provide professional, courteous service to customers.\n\n'
                    '3.1 Delivery Location & Entry Disclaimer\n'
                    'Contractor agrees that deliveries must be completed by placing items at the driveway, doorstep, or designated exterior location of the delivery address. Contractor shall not enter the customer\'s home, apartment, or any enclosed space.\n\n'
                    '3.2 Conduct and Safety\n'
                    'Contractor agrees to:\n'
                    '• Refrain from using substances, smoking, or behaving inappropriately during any delivery.\n'
                    '• Treat all customers with respect and maintain clear and professional communication.\n'
                    '• Follow all applicable laws and regulations.\n\n'
                    '3.3 Use of Platform and Devices\n'
                    'Contractor agrees to:\n'
                    '• Use the DeliverMee app to accept, manage, and complete jobs.\n'
                    '• Provide their own smartphone with sufficient data and GPS capability.\n'
                    '• Maintain responsibility for their own fuel, tolls, equipment, and mobile device performance.\n\n'
                    '4. PAYMENT\n'
                    '• Contractor is paid per delivery job completed.\n'
                    '• DeliverMee may deduct a platform fee before payout.\n'
                    '• Contractor is responsible for reporting income and remitting taxes.\n\n'
                    '5. INSURANCE & LIABILITY\n'
                    'Contractor must maintain active auto insurance and liability coverage. DeliverMee does not provide insurance for the Contractor or their vehicle.\n\n'
                    '6. TERM AND TERMINATION\n'
                    'This Agreement remains in effect until terminated by either party. Either party may terminate at any time, with or without cause.\n\n'
                    '7. CONFIDENTIALITY\n'
                    'Contractor agrees to protect DeliverMee\'s confidential information and refrain from disclosing any sensitive data or operational details to third parties.\n\n'
                    '8. NON-SOLICITATION\n'
                    'Contractor agrees not to directly solicit or accept delivery work from DeliverMee customers outside of the Platform for a period of 12 months after their last completed job with DeliverMee.\n\n'
                    '9. INDEMNITY\n'
                    'Contractor shall indemnify, defend, and hold harmless DeliverMee, its affiliates, officers, directors, employees, and agents from and against any and all claims, damages, liabilities, losses, costs, and expenses arising out of or related to the Contractor\'s performance of services.\n\n'
                    '10. GOVERNING LAW\n'
                    'This Agreement shall be governed by and construed in accordance with the laws of Ontario, Canada.\n\n'
                    '11. ENTIRE AGREEMENT\n'
                    'This Agreement represents the complete understanding between the parties and supersedes all prior agreements, oral or written, relating to the subject matter.\n\n'
                    '12. BACKGROUND CHECK CONSENT\n'
                    'Contractor agrees that DeliverMee may conduct background checks or driver history reviews, either directly or through third-party services such as Checkr.\n\n'
                    '13. MEDIA UPLOADS AND PROOF OF DELIVERY\n'
                    'Contractor acknowledges that DeliverMee may require photo documentation for proof of delivery. These images must be accurate and timely.\n\n'
                    '14. SURGE PRICING AND INCENTIVES\n'
                    'DeliverMee may offer surge pricing, bonuses, or incentives to Contractors during periods of high demand. Eligibility, rates, and criteria are subject to change at DeliverMee\'s sole discretion.\n\n'
                    '15. FORCE MAJEURE\n'
                    'DeliverMee shall not be liable for any delay or failure to perform under this Agreement due to events beyond its control.\n\n'
                    '16. AMENDMENT\n'
                    'DeliverMee reserves the right to update this Agreement at any time, with notice provided through the Platform or via email.\n\n'
                    '17. DISPUTE RESOLUTION\n'
                    'Any dispute, controversy, or claim arising out of or relating to this Agreement shall first be submitted to mediation in the Province of Ontario before any party may initiate litigation.\n\n'
                    '18. NOTICE\n'
                    'All notices under this Agreement must be in writing and delivered by email or via the DeliverMee platform.\n\n'
                    '19. SAFETY TRAINING AND POLICIES\n'
                    'Contractor agrees to complete any safety training provided by DeliverMee and to comply with all operational policies, procedures, and guidelines.\n\n'
                    '20. DATA PRIVACY CONSENT\n'
                    'Contractor consents to the collection, use, and disclosure of their personal information as necessary to perform delivery services.\n\n'
                    '21. SEVERABILITY\n'
                    'If any provision of this Agreement is found to be invalid, illegal, or unenforceable by a court of competent jurisdiction, the remaining provisions shall continue in full force and effect.\n\n'
                    '22. INTELLECTUAL PROPERTY RIGHTS\n'
                    'Contractor agrees that any and all content, inventions, processes, ideas, methods, materials, or documentation developed, created, or contributed in connection with the use of the DeliverMee Platform shall be the sole and exclusive property of DeliverMee Inc.\n\n'
                    '23. USE OF SUBCONTRACTORS\n'
                    'Contractor shall not assign or delegate any delivery tasks to third parties or subcontractors without the express written consent of DeliverMee.\n\n'
                    '24. ONGOING BACKGROUND SCREENING\n'
                    'Contractor acknowledges that DeliverMee may, at its sole discretion, conduct periodic background or driving record checks during the term of this Agreement.\n\n'
                    '25. TEMPORARY SUSPENSION\n'
                    'DeliverMee reserves the right to suspend Contractor\'s access to the Platform at any time, with or without notice, for investigation of conduct, complaints, safety concerns, or suspected policy violations.\n\n'
                    '26. NON-DISPARAGEMENT\n'
                    'Contractor agrees not to make any false, defamatory, or misleading statements about DeliverMee, its services, customers, or personnel.\n\n'
                    '27. ELECTRONIC SIGNATURE\n'
                    'This Agreement may be executed and accepted electronically. Contractor acknowledges that electronic acceptance shall have the same force and effect as a handwritten signature.\n\n'
                    '28. RETURN OF PROPERTY\n'
                    'If DeliverMee provides Contractor with any physical property, including uniforms, identification, delivery bags, or signage, Contractor agrees to return all such items in good condition upon termination of this Agreement.\n\n'
                    '29. PERFORMANCE STANDARDS\n'
                    'Contractor agrees to meet reasonable performance expectations set by DeliverMee, which may include punctuality, customer ratings, acceptance rates, and delivery completion metrics.\n\n'
                    '30. POST-TERMINATION USE OF PLATFORM IP\n'
                    'Upon termination of this Agreement, Contractor agrees to cease use of all DeliverMee trademarks, branding, logos, app access, and materials.\n\n'
                    '31. NO REIMBURSEMENT OF EXPENSES\n'
                    'Contractor acknowledges they are solely responsible for all expenses incurred in the course of performing services under this Agreement.\n\n'
                    '32. ACKNOWLEDGMENT\n'
                    'Contractor acknowledges that they have read and understood this Agreement, had the opportunity to seek independent legal advice, and agree to be bound by its terms.\n\n'
                    '33. HEALTH AND SAFETY COMPLIANCE\n'
                    'Contractor agrees to follow safe lifting techniques, secure loads properly, and use equipment when necessary.\n\n'
                    '34. NO EMPLOYMENT RELATIONSHIP CREATED\n'
                    'Nothing in this Agreement or in the conduct of the parties shall be deemed to create a joint venture, partnership, or employment relationship.\n\n'
                    '35. SUGGESTIONS AND IMPROVEMENTS\n'
                    'Any ideas, feedback, or suggestions provided by Contractor regarding improvements to the DeliverMee Platform shall become the sole property of DeliverMee.\n\n'
                    '36. AUDIT AND VERIFICATION RIGHTS\n'
                    'DeliverMee reserves the right to audit or verify Contractor\'s compliance with the requirements of this Agreement.\n\n'
                    '37. INJUNCTIVE RELIEF\n'
                    'Contractor acknowledges that breach of confidentiality, intellectual property, or non-solicitation provisions may cause irreparable harm to DeliverMee.\n\n'
                    '38. BRAND USE AND REPRESENTATION\n'
                    'If DeliverMee provides branding materials, Contractor agrees to use them professionally and solely in connection with Platform services.\n\n'
                    '39. IMMEDIATE TERMINATION FOR MISCONDUCT\n'
                    'DeliverMee reserves the right to terminate this Agreement without notice if the Contractor engages in conduct that poses a safety risk or violates criminal law.\n\n'
                    '40. DISPUTE PROCEDURE FOR DEACTIVATION\n'
                    'If Contractor\'s account is suspended, deactivated, or otherwise impacted, Contractor may request a formal review by submitting a written explanation within 5 business days.\n\n'
                    '41. ACCESSIBILITY STANDARDS COMPLIANCE\n'
                    'Contractor agrees to treat all individuals with respect and dignity and comply with the Accessibility for Ontarians with Disabilities Act (AODA).\n\n'
                    '42. SOCIAL MEDIA CONDUCT\n'
                    'Contractor agrees not to make public statements, posts, or comments on social media that disparage DeliverMee, its users, or partners.\n\n'
                    '43. DATA RETENTION\n'
                    'Contractor acknowledges that DeliverMee may retain delivery records, photographic evidence, and activity logs in accordance with its data retention policy.\n\n'
                    '44. TAX REPORTING OBLIGATIONS\n'
                    'Contractor acknowledges they are solely responsible for all tax filings, including income and HST (if registered).\n\n'
                    '45. NO SUBCONTRACTING WITHOUT CONSENT\n'
                    'Contractor may not delegate or subcontract delivery services to another party without prior written consent from DeliverMee.\n\n'
                    '46. NO WEAPONS OR HAZARDOUS MATERIALS\n'
                    'Contractor agrees not to carry firearms, illegal weapons, or hazardous/dangerous materials while performing services through the Platform.\n\n'
                    '47. CONTRACTOR RECORD-KEEPING\n'
                    'Contractor agrees to maintain accurate records of their delivery activities, expenses, mileage, and income for tax, insurance, and business purposes.\n\n'
                    '48. SURVIVAL OF KEY TERMS\n'
                    'Sections regarding Intellectual Property, Confidentiality, Indemnification, Non-Solicitation, Limitation of Liability, and Dispute Resolution shall survive the termination or expiration of this Agreement.\n\n'
                    '49. INTERNAL FEEDBACK AND INCIDENT REPORTING\n'
                    'Contractor is encouraged to report any suspected safety violations, customer misconduct, harassment, fraud, or technical issues to DeliverMee.\n\n'
                    '50. ANTI-HARASSMENT AND NON-DISCRIMINATION POLICY\n'
                    'Contractor agrees to refrain from any form of harassment, discrimination, or abusive behavior toward customers, other contractors, or DeliverMee representatives.\n\n'
                    '51. NO GUARANTEE OF WORK OR HOURS\n'
                    'Contractor acknowledges that DeliverMee does not guarantee any specific volume of work or earnings potential.\n\n'
                    '52. IMAGE AND LIKENESS RELEASE\n'
                    'Contractor grants DeliverMee the right to use their name, likeness, voice, or image in promotional, operational, or training materials.\n\n'
                    '53. POLICY UPDATES AND CONTINUED USE\n'
                    'Contractor agrees to comply with any updated operational policies, feature requirements, or legal notices issued by DeliverMee.\n\n'
                    '54. RIGHT TO REFUSE UNSAFE DELIVERIES\n'
                    'Contractor may decline any delivery they reasonably believe to be unsafe, unlawful, or beyond the physical limitations of their vehicle.\n\n'
                    '55. ELECTRONIC SIGNATURE AND ACCEPTANCE\n'
                    'The parties agree that this Agreement may be signed electronically and that such signatures shall be legally binding.\n\n'
                    '56. AUDIT AND COMPLIANCE COOPERATION\n'
                    'Contractor agrees to cooperate with any audit or review conducted by DeliverMee or its partners.\n\n'
                    '57. GOVERNING LANGUAGE\n'
                    'This Agreement is written in English and shall be interpreted and enforced accordingly.\n\n'
                    '58. LEGAL WORK ELIGIBILITY\n'
                    'Contractor represents that they are legally authorized to work in Canada and will immediately notify DeliverMee of any change in immigration or employment status.\n\n'
                    '59. NO EMPLOYER-EMPLOYEE RELATIONSHIP\n'
                    'Contractor agrees not to represent themselves as an employee of DeliverMee or request employment-related benefits.\n\n'
                    '60. PERFORMANCE STANDARDS AND PLATFORM RATINGS\n'
                    'Contractor understands that access to the Platform may be contingent on maintaining customer satisfaction, timely delivery, and platform ratings.\n\n'
                    '61. BRANDING AND IDENTIFICATION\n'
                    'If DeliverMee provides branding materials, use of such items is optional and does not imply employment.\n\n'
                    '62. DEATH OR INCAPACITY\n'
                    'In the event of the Contractor\'s death or incapacity, this Agreement shall terminate automatically.\n\n'
                    '63. GEOGRAPHIC SCOPE OF SERVICES\n'
                    'The Contractor acknowledges and agrees that all delivery services performed through the DeliverMee platform shall be conducted exclusively within the Province of Ontario, Canada.\n\n'
                    'By accepting this agreement, Contractor acknowledges they have read, understood, and agree to these terms.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'I Understand',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
