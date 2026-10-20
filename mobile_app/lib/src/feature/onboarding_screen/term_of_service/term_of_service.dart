import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermofServiceScreen extends StatefulWidget {
  final bool isprivecy;
  TermofServiceScreen({super.key, required this.isprivecy});

  @override
  State<TermofServiceScreen> createState() => _TermofServiceScreenState();
}

class _TermofServiceScreenState extends State<TermofServiceScreen> {
  String _getPrivacyPolicyText() {
    return '''
Privacy Policy

Effective Date: June 25th 2025

1. Introduction
DELIVERMEE Tech Corp. ("we," "our," or "us") is committed to protecting the privacy of our users ("you" or "your"). This Privacy Policy outlines how we collect, use, disclose, and protect your personal information in compliance with the laws of Ontario, Canada, including the Personal Information Protection and Electronic Documents Act (PIPEDA).

By using our delivery app (the "App"), you consent to the practices described in this Privacy Policy. If you do not agree with this Privacy Policy, please do not use the App.

2. Information We Collect
We may collect the following types of information:

(a) Personal Information
• Name
• Email address
• Phone number
• Delivery address
• Payment information (e.g., credit card details, billing address)
• Government-issued identification, including driver's licenses or other IDs (if required for verification purposes)

(b) Technical Information
• IP address
• Device type and operating system
• App usage data (e.g., features accessed, time spent on the App)

(c) Location Information
• Real-time geolocation data (with your explicit consent)

(d) Driver Information
If you sign up as a Driver, we may collect additional information including:
• Driver's license number and expiration date
• Vehicle registration and insurance details
• Background check results (if applicable)
• Bank account or payout details
• Delivery history and performance metrics

3. How We Use Your Information
We use your information to:
• Provide and improve our delivery services
• Process payments and fulfill orders
• Communicate with you regarding your orders, updates, and promotions
• Ensure the security and functionality of the App
• Comply with legal and regulatory requirements

4. Disclosure of Your Information
We may disclose your personal information to:
• Service Providers: Third-party vendors who assist in delivering our services, such as payment processors, analytics tools, or delivery partners.
• Background Check Services: If you apply to be a Driver, we may share your information with third-party background check providers (e.g., Checkr) to verify identity, driving record, and criminal history, where permitted by law.
• Legal Authorities: If required by law or to protect our rights, property, or safety.
• Business Transactions: In the event of a merger, acquisition, or sale of assets, your information may be transferred as part of that transaction.

We do not sell or rent your personal information to third parties for marketing purposes.

5. International Transfers
Some of your personal information may be processed or stored outside of Canada (e.g., in the United States), where privacy laws may differ. We take appropriate steps to ensure that your information is adequately protected and handled in accordance with applicable data protection laws.

6. Retention of Information
We retain your personal information only as long as necessary to fulfill the purposes for which it was collected or as required by law. Once the retention period expires, your information will be securely deleted or anonymized.

7. Security of Information
We implement appropriate technical and organizational measures to protect your personal information from unauthorized access, loss, or misuse. However, no security system is completely secure, and we cannot guarantee the absolute security of your data.

8. Your Rights
Under Ontario law and PIPEDA, you have the right to:
• Access and obtain a copy of your personal information
• Request correction of inaccurate or incomplete information
• Withdraw your consent to data processing at any time, subject to legal or contractual restrictions

To request access, correction, or deletion of your personal data, please contact us at delivermee1@gmail.com. We may require identity verification and will respond within 30 days.

9. Cookies and Tracking Technologies
We use cookies and similar technologies to enhance your experience on the App. You can manage your cookie preferences through your device settings. Note that disabling cookies may affect the functionality of the App.

10. Third-Party Links
The App may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies.

11. Children's Privacy
Our App is not intended for people under the age of 18. We do not knowingly collect personal information from children. If we become aware that a child has provided us with personal information, we will delete such information promptly.

12. Data Breach Notification
In the event of a data breach that poses a real risk of significant harm, we will notify affected individuals and any applicable authorities as required under Canadian law.

13. Changes to This Privacy Policy
We may update this Privacy Policy from time to time. Any changes will be effective upon posting the revised policy on the App. Your continued use of the App after such changes constitutes your acceptance of the updated policy.

14. Location Data Usage
We collect and use real-time location data to support core features of the App. This includes:
• Tracking Driver location during active deliveries
• Confirming proximity to pickup and drop-off addresses
• Providing real-time delivery updates to Customers
• Ensuring the safety, efficiency, and compliance of services

If location permissions are disabled, certain features may be unavailable. You can control location access through your device settings at any time.

15. Extended Driver Data Retention
Certain Driver-related data — such as delivery history, banking information, regulatory documents, and performance records — may be retained longer than general user data. This is done to comply with legal, tax, insurance, and audit obligations. Once no longer required, such data will be securely deleted or anonymized in accordance with our retention practices.

16. Automated Decision-Making
We may use automated tools to assist with tasks such as:
• Matching Drivers with delivery requests
• Detecting fraudulent or suspicious activity
• Monitoring app usage patterns and performance metrics

These tools are designed to enhance the efficiency and fairness of the platform. However, they do not make final decisions without human oversight. If you have concerns about automated decision-making, you may contact us to request more information or a manual review.

17. Communications
By using the App, you agree to receive transactional communications from DeliverMee, including order confirmations, delivery updates, and account notifications, via push notification, SMS, or email.

You may also receive promotional messages, which you can opt out of at any time by following the unsubscribe instructions in the message or by adjusting your device or account settings.

18. Data Access and Confidentiality
Access to personal information is restricted to authorized DeliverMee personnel, contractors, and third-party service providers who require such access to operate, maintain, or support the Platform.

All individuals and vendors with access to personal data are bound by confidentiality obligations and are required to follow appropriate data protection practices.

19. User-Generated Content
The App may allow users or Drivers to upload user-generated content, such as delivery photos, messages, reviews, or feedback.

This content may be visible to other users depending on the App's functionality and may be retained for quality control, support, and dispute resolution purposes.

DeliverMee reserves the right to moderate, restrict, or remove content that violates our Terms and Conditions or community guidelines.

20. Consent and Withdrawal
We collect, use, and disclose your personal information with your consent, except where otherwise permitted or required by law.

You may withdraw your consent to our use or disclosure of your personal information at any time, subject to legal or contractual restrictions and reasonable notice. However, withdrawing consent may limit your ability to access or use certain features of the App.

21. Data Portability
You have the right to request that we provide you with your personal information in a structured, commonly used, and machine-readable format. Where feasible, you may also request that your data be transmitted to another service provider.

22. Data Minimization
We only collect personal information that is necessary for the purposes outlined in this Privacy Policy. We encourage users to limit the information they provide to only what is needed for the intended service.

23. Deactivation and Account Deletion
You may request to deactivate or permanently delete your account by contacting us at delivermee1@gmail.com. Upon confirmation, we will delete your personal information, subject to any retention obligations for legal, regulatory, or legitimate business purposes.

24. Data Accuracy and User Responsibility
We rely on you to ensure that the personal information you provide is accurate, complete, and up to date.

You are responsible for notifying us of any changes to your information. Inaccurate or outdated data may affect your ability to use the App or receive services.

25. Behavioural Analytics
We may use behavioural analytics tools (e.g., Mixpanel, Google Analytics, Hotjar) to:
• Understand how users interact with the App
• Improve user experience
• Diagnose technical issues

Data collected through these tools is anonymized or pseudonymized and not used to identify you directly.

26. Data Sharing with Insurance Providers
If you are a Driver, we may share certain data (e.g., delivery records, incident reports, or driving behavior data) with insurance partners to support claims processing or coverage verification.

This data sharing will be limited to what is necessary and only with reputable providers under confidentiality obligations.

27. Marketplace Platform Responsibilities
If DeliverMee facilitates third-party listings (e.g., contractors offering delivery services via the app), clarify:
• Whether DeliverMee is a data controller or processor for data shared between users and drivers
• Responsibilities for user-generated listings, reviews, and data collection between platform users

28. Limitation of Liability
DeliverMee is not liable for unauthorized access to or use of personal data beyond our reasonable control, and disclaims all liability for third-party services not directly managed by DeliverMee.

29. Privacy Impact Assessments (PIAs)
We conduct privacy impact assessments when introducing new features or technology that may affect your privacy, in accordance with Canadian privacy best practices.

30. AI and Machine Learning
If any AI features are introduced (e.g., route optimization, fraud detection, pricing algorithms):

Certain features of the App may use machine learning or AI-based tools to support delivery operations and user safety. These tools operate within ethical boundaries and are subject to human oversight to avoid discriminatory outcomes or unfair profiling.

31. Biometric Data
In the event that biometric data such as facial recognition or other biometric identifiers are used for identity verification or fraud prevention, we will:
• Obtain your explicit consent before collecting such data
• Clearly disclose the purpose and retention period
• Ensure secure storage and permanent deletion once no longer required

You may decline to provide biometric data, but certain features may be unavailable as a result.

32. Data Storage and Service Providers
We use secure third-party cloud service providers such as Amazon Web Services (AWS), Google Cloud, and Firebase to store and process your personal information.

These providers may store data in data centers located outside of Canada, including the United States.

All service providers are contractually obligated to implement security safeguards and handle your data in accordance with applicable privacy laws, including PIPEDA.

33. Do Not Track and Global Privacy Control Signals
Some browsers and devices support privacy signals such as "Do Not Track" (DNT) or "Global Privacy Control" (GPC).

At this time, DeliverMee does not respond to these signals.

We continue to monitor evolving standards and may update our practices as privacy technology and regulations develop.

34. Law Enforcement and Legal Requests
We may disclose your personal information to law enforcement agencies, regulatory authorities, or other parties when required by law, subpoena, court order, or other lawful request.

We evaluate each request to ensure that it is lawful, proportionate, and limited to the necessary information.

Where permitted, we will notify affected users before disclosing their data.

35. Data Breach Response Protocol
DeliverMee has procedures in place to detect, investigate, and respond to data breaches.

In the event of a breach involving personal information, we will:
• Promptly investigate and contain the breach
• Assess the scope and impact of the incident
• Notify affected users and regulators as required by law

We continuously review our systems and processes to reduce the risk of future breaches.

36. Security Vulnerability Reporting
We encourage responsible disclosure of any suspected security or privacy vulnerabilities.

If you identify a potential issue, please report it to us at delivermee1@gmail.com with the subject line: "Security Disclosure."

We take all reports seriously and will investigate them in a timely manner.

Please do not share technical details publicly until the issue has been resolved.

37. Third-Party Authentication and Social Logins
If you sign in to the App using third-party authentication services such as Google, Apple, or Facebook, we may receive limited profile information from that service, including your name, email address, and profile image.

This information is used solely to authenticate your identity and create or manage your DeliverMee account.

We do not share this data with unaffiliated third parties, and you may revoke access through your third-party account settings at any time.

38. Data Anonymization and Aggregation
We may anonymize or aggregate your personal information to generate statistical or analytical data for business intelligence, product improvement, and research purposes.

Once anonymized, this data does not identify you and may be retained indefinitely.

We do not attempt to re-identify anonymized or aggregated information.

39. Cross-Device Tracking
To provide a seamless user experience, we may use technologies that associate your usage data across different devices where you are logged into your DeliverMee account (e.g., smartphone, tablet).

This allows us to deliver consistent features and personalized services regardless of which device you use to access the App.

40. In-App Privacy Controls
The App may include privacy-related settings that allow you to control how your personal data is used.

These controls may include options to:
• Manage location access
• Adjust communication preferences
• Enable or disable push notifications
• Review linked accounts and connected services

You can manage these settings at any time through the App or your device's privacy controls.

41. International Users and Non-Canadian Data Rights
DeliverMee is based in Canada and governed by Canadian privacy laws.

If you are accessing the App from outside of Canada, including the European Economic Area (EEA), you may be entitled to additional rights under your local privacy laws, such as the right to object to certain processing or request data portability.

Please contact us at delivermee1@gmail.com if you wish to exercise these rights or obtain more information.

42. Accessibility of This Privacy Policy
We strive to make this Privacy Policy easy to understand and accessible to all users.

It is available in English and may be provided in alternative formats or languages upon request, where reasonable.

For accessibility-related inquiries, please contact us at delivermee1@gmail.com.

43. Data Sharing for Fraud Prevention
We may share certain personal information with trusted third parties, including payment processors, identity verification partners, delivery participants, or law enforcement agencies, to detect, investigate, or prevent fraud, abuse, or misuse of the App.

This may include data such as transaction history, account behavior, device identifiers, or flagged reports submitted by other users or Drivers.

44. Privacy Complaints and Regulatory Recourse
If you have a concern or complaint about how we manage your personal information, please contact us at delivermee1@gmail.com.

45. Retention of Communications and Support Records
We may retain copies of communications made through the App, including chat messages, customer support emails, call logs, or issue reports, for the purposes of:
• Quality assurance
• Dispute resolution
• Service improvements
• Compliance with legal obligations

These records will be stored securely and only accessible to authorized personnel.

46. Use of Recording Devices by Drivers
In the event that dash cameras, audio recorders, or other monitoring devices are used by Drivers for safety or evidence purposes, it is the Driver's responsibility to comply with applicable privacy and consent laws.

DeliverMee may request access to such recordings during an investigation or dispute.

We do not access or store such recordings unless submitted voluntarily or legally required.

47. API Access and Third-Party Integrations
If you use DeliverMee services through an API, integration, or developer tool, you agree to only use data as authorized and for legitimate business purposes.

All third-party developers must comply with this Privacy Policy, applicable laws, and our Terms and Conditions.

Unauthorized scraping, misuse, or resale of user data is strictly prohibited.

48. Post-Termination Data Retention
When your account is deactivated or deleted, certain personal data may continue to be retained for a limited period for legal, compliance, security, or fraud prevention reasons.

This may include transaction history, device identifiers, background check results, or support communications.

Such data will be securely stored and deleted when no longer required.

49. Consent Management and Record-Keeping
We maintain records of the consents you provide to ensure compliance with applicable data protection laws. These records include the date, scope, and purpose of consent and can be reviewed upon your request.

50. Privacy by Design and Default
DeliverMee is committed to integrating privacy protections into the design and operation of our App and business processes. We implement appropriate technical and organizational measures to ensure that, by default, only personal data necessary for each specific purpose is processed.

51. Third-Party Vendor Risk Management
We carefully select and regularly assess third-party service providers to ensure they meet our privacy and security standards. We require all vendors with access to personal information to adhere to strict confidentiality and data protection obligations.

52. Security Incident Reporting to Authorities
In the event of a data breach, DeliverMee will notify relevant data protection authorities within applicable statutory timeframes (e.g., within 72 hours under GDPR). We commit to full cooperation with regulators during investigations and will keep affected users informed as required by law.

53. User Responsibility and Security
You are responsible for maintaining the confidentiality of your account credentials and for all activities occurring under your account. Please notify us immediately if you suspect any unauthorized use or security breach related to your account.

54. Third-Party Service Terms
Our App may use third-party services, APIs, or SDKs (e.g., payment processors, mapping providers). Your use of such services is subject to their terms and privacy policies. We encourage you to review those policies before using related features.

55. Mobile Device Permissions
Beyond location data, DeliverMee may request access to device features such as the camera (for uploading delivery photos) or microphone (for voice notes). These permissions are only used to support App functionality and are requested with your explicit consent.

56. Data Accuracy Obligations of Users
You agree to provide accurate, complete, and up-to-date information when using the App.

Providing false or misleading data may result in suspension or termination of your account and access to DeliverMee's services.

57. Cross-Platform Data Sharing
To provide a seamless experience, DeliverMee may share your personal data across multiple platforms (mobile app, website, partner integrations) when you use the same account. This enables consistent service delivery and personalization.

58. User Content License
By uploading photos, messages, reviews, or other content to the App, you grant DeliverMee a worldwide, royalty-free, sublicensable license to use, display, reproduce, and distribute such content solely for operating, promoting, and improving the platform and services.

59. Updates to AI Functionality
DeliverMee may update or introduce AI-driven features that impact data processing or user experience. We will notify users of significant changes affecting privacy and offer opt-out options where feasible. Final decisions made by AI tools will be subject to human review upon request.

60. Apple App Store / Google Play Terms (Third-Party App Store Integration)
These Terms incorporate and supplement the Apple App Store Terms of Service and Google Play Terms of Service. You acknowledge that Apple or Google and their subsidiaries are third-party beneficiaries of these Terms and may enforce them against you.

61. Driver Classification Reinforcement
Drivers acknowledge they are independent contractors and not employees of DeliverMee.

Nothing in these Terms shall be construed to create a partnership, joint venture, or employment relationship between DeliverMee and any Driver.

62. Indemnification Clarification
You agree to indemnify, defend, and hold harmless DeliverMee, its affiliates, and its officers from any claims, damages, liabilities, and expenses (including legal fees) arising from:
• your violation of these Terms
• your use of the Platform or Services
• your violation of any applicable laws, including traffic or delivery regulations

63. Force Majeure Clause (Acts of God)
DeliverMee shall not be liable for any delay or failure to perform resulting from causes outside our reasonable control, including but not limited to acts of God, natural disasters, pandemics, power outages, strikes, or governmental actions.

64. Severability Clause
If any provision of these Terms is found to be invalid or unenforceable, the remaining provisions shall remain in full force and effect.

65. Feedback & Suggestions Clause
Any feedback or suggestions provided to DeliverMee shall be deemed non-confidential and DeliverMee shall be free to use such information without restriction or compensation.

66. Changes to the Platform
We may modify or discontinue the Platform, or any features or services provided therein, at any time without notice. We are not liable to you or any third party for such modifications.

67. Contact Us
For any questions regarding the privacy policy please contact us at delivermee1@gmail.com
''';
  }

  String _getTermsAndConditionsText() {
    return '''
Terms and Conditions for DeliverMee
Effective Date: June 25th 2025

Please read these Terms and Conditions ("Terms") carefully before using the DeliverMee app and services ("Platform"), operated by DELIVERMEE Tech Corp. ("we," "us," or "our"), a registered business in Ontario, Canada.

By accessing or using the Platform, you agree to be bound by these Terms.

1. Platform Overview
DeliverMee is a logistics platform that connects users ("Customers") with independent drivers ("Drivers") who own or operate vehicles suitable for moving or delivering items, including pickup trucks, cargo vans, and box trucks.

DeliverMee does not provide transportation services and is not a carrier. All delivery services are performed by independent third-party Drivers who are not employed by DeliverMee.

2. Eligibility
You must be at least 18 years old and legally able to enter into a binding contract to use the Platform. By using the Platform, you represent and warrant that you meet these requirements.

3. Independent Contractor Disclaimer
All Drivers who provide delivery services through the Platform are independent contractors, not employees, agents, or representatives of DeliverMee.

DeliverMee:
• Does not control how Drivers perform their services.
• Does not guarantee the quality, safety, or legality of deliveries.
• Is not responsible for any loss, damage, injury, death, or delay arising from the actions or omissions of any Driver.

Drivers are solely responsible for:
• Maintaining appropriate commercial and vehicle insurance.
• Complying with all local laws and regulations.
• Providing safe, timely, and professional delivery services.

4. User Accounts
To use the Platform, you may be required to create an account. You agree to provide accurate information and keep your login credentials secure. You are responsible for all activity under your account.

5. Payment and Fees
Customers agree to pay all fees associated with their orders, including base rates, distance fees, wait times, and other applicable charges. All payments are processed through third-party payment providers. DeliverMee may deduct a service fee before remitting payment to Drivers.

6. Cancellations and Refunds
Customers may cancel a delivery within a limited timeframe before incurring a cancellation fee. Refunds will be handled on a case-by-case basis. DeliverMee is not responsible for delays or damages once an item is in a Driver's possession.

7. Damage and Claims
DeliverMee is not liable for damage to items during transport. Customers are encouraged to ensure their items are adequately packed and insured. Any claims must be submitted within 48 hours of the completed delivery and will be reviewed at our discretion.

8. Driver Conduct and Requirements
Drivers using the Platform must:
• Own or lease a registered, insured, and roadworthy vehicle.
• Possess a valid driver's license.
• Follow all traffic and safety laws.
• Treat customers and their property with respect and care.

DeliverMee reserves the right to suspend or deactivate a Driver's access to the Platform at its sole discretion.

9. Delivery Drop-Off Policy
Drivers are required to complete deliveries by placing items at the customer's driveway, doorstep, or designated exterior drop-off location. Drivers are not permitted to enter any customer's residence or enclosed property.

Should a driver choose to enter a customer's premises (e.g., home, garage, building interior), they do so at their own risk, and DeliverMee assumes no liability for:
• Personal injury
• Property damage
• Theft or loss
• Disputes arising from entry
• Death

Customers are also advised not to request or require drivers to enter their homes. All parties are expected to respect this policy to ensure safety and legal clarity.

10. Prohibited Uses
You agree not to use the Platform to:
• Engage in unlawful, harassing, threatening, or fraudulent activity.
• Circumvent DeliverMee to engage Drivers or Customers for off-platform services.
• Impersonate another person or misrepresent your affiliation.
• Upload harmful or malicious code, or attempt to disrupt platform functionality.

DeliverMee may terminate or restrict your account at its sole discretion for any prohibited use.

11. Limitation of Liability
To the maximum extent permitted by law, DeliverMee shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to lost profits, lost data, personal injury, or property damage.

12. Indemnification
You agree to indemnify and hold harmless DeliverMee, its officers, directors, employees, and agents from and against any claims, liabilities, damages, losses, and expenses arising out of your use of the Platform, your violation of these Terms, or your interaction with Drivers or Customers.

13. Disputes Between Users
DeliverMee is not responsible for resolving disputes between Drivers and Customers. While we may assist in dispute resolution at our discretion, DeliverMee does not assume any obligation to mediate, reimburse, or provide compensation for such disputes.

14. Service Suspension and Modification
DeliverMee reserves the right to modify, suspend, or terminate the Platform or any user's access to it, at any time, with or without notice. Reasons may include violation of these Terms, suspected fraud, security concerns, or business needs.

15. Dispute Resolution
Any disputes arising from the use of the Platform will first be resolved through informal negotiation. If unresolved, disputes will be submitted to binding arbitration in accordance with Ontario law.

16. Changes to These Terms
We reserve the right to update or change these Terms at any time. Continued use of the Platform after changes are made constitutes acceptance of the new Terms.

17. Media and Photo Policy
DeliverMee may allow or require Drivers to upload photos to verify delivery completion. These photos may be shared with the recipient for proof of delivery. By using the Platform, you consent to the collection, storage, and use of such images for operational and dispute-resolution purposes. DeliverMee retains ownership of these images for platform use only.

18. Force Majeure
DeliverMee shall not be held liable for delays or failures in performance resulting from events beyond its reasonable control, including but not limited to acts of God, natural disasters, epidemics, labor strikes, telecommunications failures, service outages, or government orders.

19. Pricing and Platform Fees
DeliverMee reserves the right to set, adjust, or apply dynamic pricing for delivery services offered through the Platform. This may include changes based on distance, demand, time of day, or other operational factors.

All applicable charges will be clearly disclosed to Customers prior to order confirmation. DeliverMee may also deduct a platform or service fee from the amounts paid to Drivers.

20. Background Checks and Identity Verification
Drivers may be subject to identity verification and background screening, including criminal history or driving record checks, either directly by DeliverMee or through a third-party provider.

By signing up as a Driver, you consent to such checks as a condition of access to and continued use of the Platform.

21. Non-Solicitation
You agree not to circumvent the Platform by soliciting or arranging delivery services directly with Drivers or Customers introduced through DeliverMee, for the purpose of avoiding platform fees or policies.

DeliverMee reserves the right to deactivate or restrict any account found to be engaging in such activity.

22. Device and Account Responsibility
You are solely responsible for maintaining the confidentiality and security of your account credentials and any device used to access the Platform.

DeliverMee is not liable for any unauthorized access, charges, or damages resulting from failure to secure your login information or mobile device.

23. Governing Law
These Terms shall be governed by and construed in accordance with the laws of the Province of Ontario and the federal laws of Canada applicable therein.

Any disputes not resolved through informal negotiation or arbitration will be subject to the jurisdiction of the courts located in Ontario, Canada.

24. Severability
If any provision of these Terms is determined to be invalid, unlawful, or unenforceable by a court of competent jurisdiction, the remaining provisions shall remain in full force and effect.

25. Intellectual Property Rights
All content, technology, and materials available through the Platform, including but not limited to software code, logos, trade names, text, graphics, images, workflows, data, and delivery documentation (collectively, "Platform Materials"), are the exclusive property of DeliverMee Inc. or its licensors, and are protected under Canadian and international intellectual property laws.

By accessing or using the Platform, you agree to the following:
• You will not copy, reproduce, modify, distribute, display, or create derivative works from the Platform Materials without our prior written consent.
• You will not reverse engineer, decompile, scrape, extract data from, or attempt to replicate any part of the DeliverMee Platform, including its business model, branding, user interface, or backend systems, for commercial or competitive purposes.
• You will not use DeliverMee's name, trademarks, logos, or likeness without prior written permission.

Contributions by Drivers, Contractors, or Partners:
Any content, software, ideas, designs, inventions, processes, or other materials created by Drivers, contractors, advisors, or other third-party collaborators ("Contributors") in connection with their use of or engagement with the Platform shall be treated as follows:
• All intellectual property developed by Contributors in the course of providing services to DeliverMee shall be considered "work made for hire" where permitted by law.
• Where such classification is not available under applicable law, the Contributor irrevocably assigns all rights, title, and interest in such intellectual property to DeliverMee Inc.
• Contributors also irrevocably waive all moral rights to such intellectual property, to the fullest extent permitted by law.
• Contributors agree to disclose any inventions, tools, methods, or content created while working with DeliverMee, and further agree to cooperate with DeliverMee (at DeliverMee's request and expense) to execute documents or take action needed to confirm DeliverMee's ownership of such intellectual property, including after termination of engagement.
• If Contributors intend to use pre-existing intellectual property (developed prior to working with DeliverMee), they must disclose and obtain written approval in advance. If no such disclosure is made, the Contributor acknowledges that all work is the original creation of and for DeliverMee.

Photos and Media Uploads:
Drivers may be required to upload delivery-related photos for verification and dispute resolution. By doing so, the Driver grants DeliverMee a perpetual, worldwide, royalty-free, and irrevocable license to use, display, reproduce, and store such media for operational, safety, legal, and promotional purposes. DeliverMee retains all rights to photos uploaded through the Platform.

Violation of Intellectual Property Terms:
Any unauthorized use, misappropriation, infringement, or attempt to replicate DeliverMee's intellectual property may result in immediate suspension or termination of your account and may lead to legal action.

27. User-Generated Content
By submitting, uploading, or posting any content to the Platform—including delivery notes, item descriptions, messages, images, or reviews—you grant DeliverMee a non-exclusive, worldwide, royalty-free, sublicensable, and transferable license to use, store, reproduce, modify, adapt, publish, display, and distribute such content for operational, promotional, legal, or service quality purposes.

You represent and warrant that you have all necessary rights, licenses, and authority to grant this license and that your content does not violate any third-party rights or applicable laws.

DeliverMee reserves the right to remove or disable access to any content that violates these Terms or applicable law.

28. Third-Party Services
The Platform may integrate or rely on services provided by third parties, such as payment processors, mapping providers, background screening companies, messaging tools, or identity verification platforms. Your use of such third-party services is subject to their own terms and conditions, privacy policies, and practices.

DeliverMee is not responsible for the availability, accuracy, functionality, or legal compliance of any third-party service. You agree that DeliverMee shall not be liable for any damages or losses arising from your use of, or reliance on, third-party tools, data, or integrations available through the Platform.

29. Data and Analytics Ownership
DeliverMee retains all rights, title, and interest in and to all data generated through use of the Platform, including anonymized and aggregated information such as delivery trends, pricing analysis, geographic usage patterns, performance metrics, and operational statistics.

Such data may be used by DeliverMee to improve the Platform, develop new features, inform business decisions, conduct research, or support strategic initiatives, provided it does not personally identify any user without their express consent.

30. Automated Decision-Making
Certain features of the Platform may use automated processes, including algorithms or artificial intelligence, to perform functions such as delivery assignment, route optimization, fraud prevention, and service quality analysis. These systems operate using pre-defined logic, data inputs, and real-time conditions to enhance fairness, efficiency, and safety.

If you believe an automated decision has impacted you in error, you may contact DeliverMee for review. While we strive to ensure the accuracy and neutrality of these systems, no system is perfect, and we welcome user feedback to improve platform functionality.

31. Beta Features
DeliverMee may occasionally provide access to beta, experimental, or early-release features. These features are offered "as-is" without any warranty and may be modified, limited, or discontinued at any time without prior notice.

By using beta features, you understand and accept that they may be unstable, incomplete, or contain bugs. Your use of such features is voluntary and at your own risk.

32. Survival
The following sections shall survive any termination of your account or use of the Platform: Intellectual Property Rights, User-Generated Content, Indemnification, Limitation of Liability, Dispute Resolution, Non-Solicitation, Data and Analytics Ownership, and any other provisions which by their nature are intended to remain in effect after termination.

33. Fraud, Abuse, and Account Suspension
DeliverMee reserves the right to investigate, suspend, or terminate any account suspected of engaging in fraudulent, abusive, harmful, or unlawful behaviour. This includes, but is not limited to: falsifying delivery confirmations, creating fake orders or accounts, abusing referral or promotional offers, impersonating others, or attempting to manipulate platform features.

DeliverMee may take legal action or report such behaviour to relevant authorities where appropriate.

34. Taxes and Legal Compliance
Drivers are solely responsible for complying with all applicable tax laws and government regulations in connection with income earned through the Platform. DeliverMee does not withhold income tax, issue T4s, or remit taxes on behalf of Drivers. It is your responsibility to maintain appropriate business licenses, vehicle permits, insurance, and tax records as required by provincial or federal law.

35. Communication Consent
By creating an account with DeliverMee, you consent to receive communications from us, including service-related messages, account updates, delivery confirmations, customer support messages, marketing offers, and promotional content via email, SMS, phone, and in-app notifications. You can adjust your communication preferences or opt out of non-essential communications at any time. Standard messaging or data rates may apply.

36. Insurance Disclaimer
DeliverMee does not provide insurance coverage for Drivers, Customers, or items being transported. Drivers are solely responsible for obtaining and maintaining appropriate commercial auto and liability insurance. Customers are advised to ensure items are adequately protected and, if necessary, insured during transport. DeliverMee assumes no liability for damage, loss, or theft of items in transit.

37. Service Availability
DeliverMee does not guarantee continuous or uninterrupted access to the Platform or the availability of Drivers at any given time or location. Service availability may be affected by factors beyond our control, including technical issues, network disruptions, geographic coverage, or market demand. We reserve the right to limit, suspend, or restrict Platform access at our discretion.

38. User Reviews and Feedback
You may have the opportunity to leave feedback, ratings, or reviews about other users or your experience on the Platform. By submitting such content, you grant DeliverMee a perpetual, irrevocable license to use, display, and incorporate your feedback for quality control, dispute resolution, and platform improvements. DeliverMee is not responsible for the accuracy of user-generated reviews and may remove content that violates these Terms or applicable law.

39. Export Controls and Restricted Use
The Platform may not be used in, or by individuals or entities located in, countries subject to Canadian trade restrictions or export controls. You represent and warrant that you are not located in any such jurisdiction and are not listed on any Canadian government list of prohibited parties. DeliverMee reserves the right to block access where legally required.

40. Data Security and Breach Notification
DeliverMee takes reasonable administrative, technical, and physical measures to protect your personal information. However, no system is 100% secure. In the event of a data breach affecting your information, DeliverMee will notify affected users in accordance with applicable privacy and data breach laws.

41. Limited License to Use Platform
Subject to your compliance with these Terms, DeliverMee grants you a limited, non-exclusive, non-transferable, and revocable license to access and use the Platform solely for its intended purposes. You agree not to copy, modify, distribute, sell, or lease any part of the Platform or its code. All rights not expressly granted herein are reserved by DeliverMee.

42. Feedback and Suggestions
If you choose to submit feedback, suggestions, improvements, or ideas regarding the Platform, you acknowledge that DeliverMee may use them without restriction or compensation to you. DeliverMee has no obligation to review or implement any feedback but retains the right to do so at its discretion.

43. Monitoring and Enforcement
DeliverMee reserves the right (but not the obligation) to monitor access to and use of the Platform for the purposes of security, compliance, operational integrity, or enforcement of these Terms. We may remove content, suspend accounts, or take other corrective action in response to suspected misuse or violations of law or our policies.

44. Interpretation and Waiver
Headings in these Terms are for convenience only and do not affect interpretation. No waiver of any breach or default shall constitute a waiver of any subsequent breach or default. Any failure by DeliverMee to enforce any provision of these Terms shall not constitute a waiver of our right to enforce such provision.

45. Assignment
You may not assign or transfer your rights or obligations under these Terms without prior written consent. DeliverMee may assign its rights and obligations under these Terms without restriction in connection with a merger, acquisition, restructuring, or sale of assets.

46. Entire Agreement
These Terms, together with our Privacy Policy and any additional agreements entered into between you and DeliverMee, constitute the entire agreement between you and DeliverMee regarding the use of the Platform and supersede all prior agreements, communications, or understandings (oral or written).

47. Privacy and Data Collection
DeliverMee collects, uses, and discloses personal data in accordance with its Privacy Policy, which is incorporated by reference into these Terms. By using the Platform, you consent to the collection and use of your data as described.

48. Children's Use and COPPA Compliance
DeliverMee is not intended for use by individuals under the age of 18. We do not knowingly collect personal data from children. If we become aware that we have inadvertently collected such information, we will take appropriate steps to delete it.

49. App Store Terms
These Terms supplement and incorporate the Apple App Store or Google Play Store Terms of Service. You acknowledge and agree that Apple or Google and their subsidiaries are third-party beneficiaries of these Terms, and that they have the right to enforce these Terms against you.

50. Business Use Disclaimer
If you are accessing or using the Platform on behalf of a business or entity, you represent and warrant that you have the authority to bind such entity to these Terms, and all references to 'you' or 'your' shall include that entity.

51. No Guarantee of Employment or Income (for Drivers)
DeliverMee does not guarantee that Drivers will receive any minimum number of delivery opportunities or income. Drivers understand and accept that the availability of delivery requests may vary based on demand, location, time, and other factors.

52. Geographic Limitations
DeliverMee currently operates exclusively within the Province of Ontario, Canada. Customers may only request delivery services to and from locations within Ontario. DeliverMee reserves the right to reject, cancel, or refuse any delivery request that extends beyond this geographic scope.

53. Contact Us
Contact us at: delivermee1@gmail.com
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          text: widget.isprivecy ? "Privacy Policy" : "Terms and Conditions",
          leading: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Container(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: SingleChildScrollView(
            child: TextWidget(
              text: widget.isprivecy
                  ? _getPrivacyPolicyText()
                  : _getTermsAndConditionsText(),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
