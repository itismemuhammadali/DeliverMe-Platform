import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IndependentContractScreen extends StatelessWidget {
  IndependentContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        text: '   Independent Contractor Agrement',
        leading: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 30.h),
                child: TextWidget(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                  textAlign: TextAlign.justify,
                  text: '''
Independent Contractor Agreement
Last Updated: January 5, 2025

1. INTRODUCTION
This Independent Contractor Agreement ("Agreement") is entered into between DeliverMee ("we," "our," or "us") and you ("Contractor" or "you") to establish the terms and conditions under which you will provide services to us as an independent contractor.

2. SCOPE OF WORK
You agree to provide delivery and related services as described by DeliverMee through our mobile application and platform. The nature, timing, and location of the services will be agreed upon for each task or assignment.

3. RELATIONSHIP OF THE PARTIES
You acknowledge and agree that you are an independent contractor and not an employee, partner, or agent of DeliverMee. Nothing in this Agreement shall be construed to create an employer-employee relationship.

4. COMPENSATION
You will be compensated for services rendered in accordance with the rates and payment schedule agreed upon in the DeliverMee platform. You are solely responsible for all taxes, insurance, and benefits related to your earnings.

5. CONTRACTOR RESPONSIBILITIES
As a contractor, you agree to:

Perform services in a timely, professional manner

Use your own vehicle, tools, or equipment as needed

Comply with all applicable laws and local delivery regulations

Maintain appropriate licenses, insurance, and permits

6. CONFIDENTIALITY
You agree to maintain the confidentiality of any proprietary or sensitive information you access during the course of your work with DeliverMee.

7. TERMINATION
Either party may terminate this Agreement at any time with or without cause, with or without notice, to the extent permitted by law.

8. LIMITATION OF LIABILITY
DeliverMee is not liable for any claims, damages, or losses incurred as a result of services performed under this Agreement. You assume full responsibility for your own actions and liabilities.

9. CHANGES TO THIS AGREEMENT
DeliverMee may modify this Agreement from time to time. Continued engagement as a contractor after changes are posted will constitute your acceptance of the revised terms.

10. CONTACT US
If you have any questions about this Agreement, please contact us at:
legal@delivermee.com''',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
