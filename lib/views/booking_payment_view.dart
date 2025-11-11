import 'package:ahjizzzapp/views/payment_screens/instapay_view.dart';
import 'package:ahjizzzapp/views/payment_screens/paypal_view.dart';
import 'package:ahjizzzapp/views/payment_screens/vodafone_cash_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// (باقي الـ imports كما هي)
import 'package:ahjizzzapp/viewmodels/booking_payment_viewmodel.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/views/booking_confirmation_view.dart';

import 'credit_card_payment_view.dart';
// (لم نعد بحاجة لـ CreditCardPaymentView)

class BookingPaymentView extends StatelessWidget {
  // (الـ constructor كما هو)
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;
  const BookingPaymentView({
    Key? key,
    required this.provider,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => BookingPaymentViewModel(
        ctx.read<DbService>(),
        ctx.read<AuthService>(),
        provider: provider,
        service: service,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
      ),
      child: Consumer<BookingPaymentViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Confirm Your Booking'),
              backgroundColor: kLightBackgroundColor,
              elevation: 1,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            backgroundColor: kLightBackgroundColor,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBookingSummaryCard(viewModel),
                  const SizedBox(height: 24),
                  _buildTextField(viewModel.notesController, 'Add special requests or notes...'),
                  const SizedBox(height: 16),
                  _buildDiscountField(context, viewModel),
                  if (viewModel.discountMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Text(
                        viewModel.discountMessage!,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: viewModel.appliedDiscount != null ? kPrimaryColor : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  _buildPaymentOption(
                    context: context,
                    title: 'Pay on Arrival',
                    value: PaymentMethod.payOnArrival,
                    groupValue: viewModel.selectedPaymentMethod,
                    onChanged: (method) => viewModel.selectPaymentMethod(method!),
                  ),

                  _buildPaymentOption(
                    context: context,
                    title: 'Pay Online',
                    subtitle: 'Credit Card, Vodafone Cash, InstaPay', // <-- تعديل النص
                    value: PaymentMethod.payOnline,
                    groupValue: viewModel.selectedPaymentMethod,
                    onChanged: (method) => viewModel.selectPaymentMethod(method!),
                  ),

                  const SizedBox(height: 24),
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),

            // **** 2. تعديل الزر السفلي ****
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null // تعطيل الزر أثناء تحميل أي عملية
                    : () async {
                  // تحديد الإجراء بناءً على طريقة الدفع
                  if (viewModel.selectedPaymentMethod == PaymentMethod.payOnline) {
                    // 1. إذا اختار الدفع أونلاين، اظهر النافذة المنبثقة
                    _showPaymentOptionsSheet(context, viewModel);
                  } else {
                    // 2. إذا اختار الدفع عند الوصول، أكد الحجز مباشرة
                    bool success = await viewModel.submitPayOnArrivalBooking();
                    if (success && context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) =>  BookingConfirmationView(),
                          settings: const RouteSettings(name: '/booking-confirmation'),
                        ),
                            (route) => route.settings.name == '/dashboard' || route.isFirst,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                  // تغيير النص بناءً على طريقة الدفع
                    viewModel.selectedPaymentMethod == PaymentMethod.payOnline
                        ? 'Proceed to Payment (\$${viewModel.totalPrice.toStringAsFixed(2)})'
                        : 'Confirm Booking'
                ),
              ),
            ),
            // **********************************
          );
        },
      ),
    );
  }

  // --- (كل الدوال المساعدة كما هي) ---
  Widget _buildBookingSummaryCard(BookingPaymentViewModel viewModel) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(height: 20),
            _buildSummaryRow('Provider:', viewModel.provider.name),
            _buildSummaryRow('Service:', viewModel.service.name),
            _buildSummaryRow('Date:', viewModel.formattedDate),
            _buildSummaryRow('Time:', viewModel.formattedTime),
            const Divider(height: 20),
            _buildSummaryRow(
              'Price:',
              '\$${viewModel.originalPrice.toStringAsFixed(2)}',
            ),
            if (viewModel.appliedDiscount != null)
              _buildSummaryRow(
                'Discount (${viewModel.appliedDiscount!.discountPercentage.toInt()}%):',
                '-\$${viewModel.discountAmount.toStringAsFixed(2)}',
                color: kPrimaryColor,
              ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Total Price:',
              '\$${viewModel.totalPrice.toStringAsFixed(2)}',
              isBold: true,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color, double size = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isBold ? kPrimaryColor : Colors.black87),
              fontSize: size,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kPrimaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDiscountField(BuildContext context, BookingPaymentViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: viewModel.discountController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Enter discount code',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                borderSide: BorderSide(color: kPrimaryColor),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13.5),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: viewModel.isVerifyingDiscount ? null : () {
            FocusScope.of(context).unfocus();
            viewModel.validateDiscountCode();
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
          child: viewModel.isVerifyingDiscount
              ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    String? subtitle,
    required PaymentMethod value,
    required PaymentMethod groupValue,
    required ValueChanged<PaymentMethod?>? onChanged,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: groupValue == value ? kPrimaryColor : Colors.grey[300]!)
      ),
      child: RadioListTile<PaymentMethod>(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: kPrimaryColor,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  // **** 3. دالة جديدة: إظهار النافذة المنبثقة لاختيار الدفع ****
  void _showPaymentOptionsSheet(BuildContext context, BookingPaymentViewModel viewModel) {
    // دالة مساعدة للانتقال للشاشة المناسبة
    void _navigateToPayment(Widget paymentScreen) {
      Navigator.of(context).pop(); // 1. إغلاق الـ BottomSheet
      Navigator.of(context).push(  // 2. فتح شاشة الدفع المحددة
        MaterialPageRoute(builder: (context) => paymentScreen),
      );
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Select Payment Method', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              // 1. Credit Card
              ListTile(
                leading: Icon(Icons.credit_card, color: kPrimaryColor),
                title: Text('Credit/Debit Card'),
                onTap: () => _navigateToPayment(CreditCardPaymentView(
                  provider: viewModel.provider, service: viewModel.service,
                  selectedDate: viewModel.selectedDate, selectedTime: viewModel.selectedTime,
                  totalPrice: viewModel.totalPrice, discountCode: viewModel.appliedDiscount?.id,
                )),
              ),

              // 2. Vodafone Cash
              ListTile(
                leading: Icon(Icons.phone_android, color: Colors.red),
                title: Text('Vodafone Cash'),
                onTap: () => _navigateToPayment(VodafoneCashView(
                  provider: viewModel.provider, service: viewModel.service,
                  selectedDate: viewModel.selectedDate, selectedTime: viewModel.selectedTime,
                  totalPrice: viewModel.totalPrice, discountCode: viewModel.appliedDiscount?.id,
                )),
              ),

              // 3. InstaPay
              ListTile(
                leading: Icon(Icons.send_to_mobile, color: Colors.purple),
                title: Text('InstaPay'),
                onTap: () => _navigateToPayment(InstaPayView(
                  provider: viewModel.provider, service: viewModel.service,
                  selectedDate: viewModel.selectedDate, selectedTime: viewModel.selectedTime,
                  totalPrice: viewModel.totalPrice, discountCode: viewModel.appliedDiscount?.id,
                )),
              ),

              // 4. PayPal
              ListTile(
                leading: Icon(Icons.paypal, color: Colors.blue.shade800),
                title: Text('PayPal'),
                onTap: () => _navigateToPayment(PayPalView(
                  provider: viewModel.provider, service: viewModel.service,
                  selectedDate: viewModel.selectedDate, selectedTime: viewModel.selectedTime,
                  totalPrice: viewModel.totalPrice, discountCode: viewModel.appliedDiscount?.id,
                )),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
// ****************************************************
}