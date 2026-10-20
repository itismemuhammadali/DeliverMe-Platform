import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/dialog.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/payment/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final TextEditingController _cardholderNameController =
      TextEditingController();
  final PaymentMethodController paymentController =
      Get.find<PaymentMethodController>();

  bool isAddingCard = false;
  bool isCardComplete = false;

  @override
  void dispose() {
    _cardholderNameController.dispose();
    super.dispose();
  }

  /// Tokenize card via Stripe SDK on-device, then send only the token to backend.
  /// Card data never touches our server — PCI compliant.
  Future<void> _addCard() async {
    if (!isCardComplete) {
      Get.snackbar(
        'Incomplete Card',
        'Please fill in all card details.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_cardholderNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Name Required',
        'Please enter the cardholder name.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isAddingCard = true);

    try {
      // Step 1: Tokenize card on-device via Stripe SDK.
      // Card number, expiry, and CVV are handled entirely by Stripe — never sent to our backend.
      print('💳 Tokenizing card via Stripe SDK...');
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: _cardholderNameController.text.trim(),
            ),
          ),
        ),
      );

      print('✅ Card tokenized: ${paymentMethod.id}');
      print('💳 Card brand: ${paymentMethod.card.brand}');
      print('💳 Last 4: ${paymentMethod.card.last4}');

      // Step 2: Send only the payment method token (pm_xxx) to backend.
      // Backend attaches it to the Stripe customer — no raw card data involved.
      final result = await paymentController.addPaymentMethod(
        paymentMethodId: paymentMethod.id,
      );

      final last4 = paymentMethod.card.last4;

      if (result['success']) {
        Get.dialog(
          ConfirmationDialog(
            aspectRatio: 1 / 0.6,
            onYesBtnClick: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to payment screen
            },
            subDescription:
                'Your card ending in $last4 has been added successfully.',
            heading: 'Card Added',
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to add card. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on StripeException catch (e) {
      print('❌ Stripe error: ${e.error.message}');
      // User cancelled or card was declined
      if (e.error.code == FailureCode.Canceled) {
        // User dismissed — no error shown
        return;
      }
      Get.snackbar(
        'Card Error',
        e.error.localizedMessage ?? e.error.message ?? 'Card was declined.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      print('❌ Unexpected error adding card: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => isAddingCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'Add Card', leading: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cardholder name
              TextWidget(
                text: 'Cardholder Name',
                fontSize: 14.sp,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _cardholderNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'e.g. John Smith',
                  hintStyle: TextStyle(
                    color: AppColors.hintTextColor,
                    fontSize: 14.sp,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF4F4F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Stripe CardField — handles card number, expiry, CVC securely on-device
              TextWidget(
                text: 'Card Details',
                fontSize: 14.sp,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 10.h),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                child: CardField(
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.blackColor,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Card number',
                    hintStyle: TextStyle(
                      color: AppColors.hintTextColor,
                      fontSize: 14.sp,
                    ),
                  ),
                  onCardChanged: (card) {
                    setState(() {
                      isCardComplete = card?.complete ?? false;
                    });
                  },
                ),
              ),

              SizedBox(height: 8.h),

              // Card security note
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14.sp,
                    color: Colors.green[700],
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: TextWidget(
                      text:
                          'Your card details are encrypted and processed securely by Stripe. We never store your card number.',
                      fontSize: 11.sp,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              TextWidget(
                text:
                    'Your personal data will be used to process your order, support your experience throughout this website, and for other purposes described in our privacy policy.',
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),

              SizedBox(height: 20.h),

              CustomButton(
                text: isAddingCard ? 'Adding Card...' : 'Add Card',
                buttonColor:
                    isAddingCard ? Colors.grey : AppColors.primaryColor,
                ontap: isAddingCard ? () {} : () => _addCard(),
              ),

              SizedBox(height: 20.h),

              // Powered by Stripe badge
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, size: 16.sp, color: Colors.grey),
                    SizedBox(width: 6.w),
                    TextWidget(
                      text: 'Secured by Stripe',
                      fontSize: 12.sp,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
