import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<CustomerSupportScreen> {
  final String supportEmail = 'lmoore@delivermee.com';
  final String supportPhone = '+15551234567';
  final String faqPhone = '+15551234567';

  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I track my delivery?',
      answer:
          'Go to the Deliveries tab, select your active delivery, and tap "Track Item" to view real-time location updates.',
    ),
    _FaqItem(
      question: 'How do I schedule a delivery?',
      answer:
          'Tap the + button on the home screen, enter pickup and drop-off details, select a vehicle type, and confirm your scheduled time.',
    ),
    _FaqItem(
      question: 'What payment methods are accepted?',
      answer:
          'We accept all major credit and debit cards. You can manage your payment methods in Profile > Payment Methods.',
    ),
    _FaqItem(
      question: 'How do I cancel or reschedule?',
      answer:
          'Open your delivery from the Deliveries tab and use the "Reschedule" or "Cancel" options. Cancellation fees may apply.',
    ),
  ];

  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: Uri.encodeFull('subject=Support Request&body=Hello, I need help with...'),
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No mail app found. Email: $supportEmail')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "Customer Support", leading: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            TextWidget(
              text: 'How can we help you today?',
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.blackColor,
            ),
            SizedBox(height: 4.h),
            TextWidget(
              text: 'Choose a topic below or reach out directly.',
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.greyTextColor,
            ),
            SizedBox(height: 24.h),

            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: AppIcons.mailIcon,
                    label: 'Email',
                    detail: supportEmail,
                    onTap: _launchEmail,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            TextWidget(
              text: 'Frequently Asked Questions',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            SizedBox(height: 12.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                return _FaqTile(item: _faqs[index]);
              },
            ),
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: Material(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(8.r),
                child: InkWell(
                  onTap: _launchEmail,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Center(
                    child: TextWidget(
                      text: 'Still Need Help? Contact Support',
                      color: AppColors.whiteColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomContainer(
        borderRadius: 16.r,
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              icon,
              width: 24.w,
              height: 24.h,
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 10.h),
            TextWidget(
              text: label,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.greyTextColor,
            ),
            SizedBox(height: 2.h),
            TextWidget(
              text: detail,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;

  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            onExpansionChanged: (value) {
              setState(() {
                _expanded = value;
              });
            },
            trailing: AnimatedRotation(
              turns: _expanded ? 0.5 : 0,
              duration: Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.greyTextColor,
              ),
            ),
            title: TextWidget(
              text: widget.item.question,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
            children: [
              TextWidget(
                text: widget.item.answer,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.greyTextColor,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  _FaqItem({required this.question, required this.answer});
}
