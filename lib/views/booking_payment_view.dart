import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/booking_payment_viewmodel.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/views/booking_confirmation_view.dart';

class BookingPaymentView extends StatelessWidget {
  // استقبال البيانات اللازمة من الشاشة السابقة
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
    // توفير الـ ViewModel لهذه الشاشة
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
                  // 1. ملخص الحجز (مُعدل لعرض الخصم)
                  _buildBookingSummaryCard(viewModel),
                  const SizedBox(height: 24),

                  // 2. الملاحظات (كما هي)
                  _buildTextField(viewModel.notesController, 'Add special requests or notes...'),
                  const SizedBox(height: 16),

                  // 3. كود الخصم (مُعدل)
                  _buildDiscountField(context, viewModel), // <-- تم تعديل الدالة المساعدة

                  // (عرض رسالة الخصم)
                  if (viewModel.discountMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Text(
                        viewModel.discountMessage!,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          // اللون أخضر لو الخصم نجح، أحمر لو فشل
                          color: viewModel.appliedDiscount != null ? kPrimaryColor : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // 4. طرق الدفع (كما هي)
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
                    subtitle: 'Credit/Debit Card (Coming Soon)',
                    value: PaymentMethod.payOnline,
                    groupValue: viewModel.selectedPaymentMethod,
                    onChanged: null, // تعطيل الدفع أونلاين حالياً
                  ),
                  const SizedBox(height: 24),

                  // رسالة الخطأ العام
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
            // زر تأكيد الحجز (كما هو)
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                  bool success = await viewModel.confirmBooking();
                  if (success && context.mounted) {
                    // الانتقال لشاشة التأكيد
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) =>  BookingConfirmationView(),
                        settings: const RouteSettings(name: '/booking-confirmation'),
                      ),
                          (route) => route.settings.name == '/dashboard' || route.isFirst,
                    );
                  }
                },
                style: ElevatedButton.styleFrom( // استخدام الـ Theme
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: viewModel.isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Booking'),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- الدوال المساعدة ---

  // **** كرت ملخص الحجز (مُعدل) ****
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

            // --- عرض السعر والخصم ---
            _buildSummaryRow(
              'Price:',
              '\$${viewModel.originalPrice.toStringAsFixed(2)}', // السعر الأصلي
            ),

            // (عرض الخصم فقط إذا تم تطبيقه)
            if (viewModel.appliedDiscount != null)
              _buildSummaryRow(
                'Discount (${viewModel.appliedDiscount!.discountPercentage.toInt()}%):',
                '-\$${viewModel.discountAmount.toStringAsFixed(2)}', // قيمة الخصم
                color: kPrimaryColor, // باللون الأخضر
              ),

            const SizedBox(height: 8),
            // السعر الإجمالي
            _buildSummaryRow(
              'Total Price:',
              '\$${viewModel.totalPrice.toStringAsFixed(2)}', // السعر النهائي
              isBold: true,
              size: 18, // خط أكبر للسعر النهائي
            ),
            // ------------------------
          ],
        ),
      ),
    );
  }

  // (دالة بناء سطر الملخص - مُعدلة)
  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color, double size = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)), // حجم موحد للـ label
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? (isBold ? kPrimaryColor : Colors.black87),
              fontSize: size, // استخدام الحجم الممرر
            ),
          ),
        ],
      ),
    );
  }

  // (دالة بناء حقل النص - كما هي)
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

  // **** دالة جديدة: بناء حقل الخصم مع زر "Apply" ****
  Widget _buildDiscountField(BuildContext context, BookingPaymentViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // لمحاذاة زر Apply مع الحقل
      children: [
        // 1. حقل النص
        Expanded(
          child: TextField(
            controller: viewModel.discountController,
            // تحويل الحروف لكبيرة تلقائياً
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Enter discount code',
              filled: true,
              fillColor: Colors.white,
              // تعديل الـ border ليتناسب مع الزر
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13.5), // (تعديل بسيط للمحاذاة)
            ),
          ),
        ),
        // 2. زر "Apply"
        ElevatedButton(
          onPressed: viewModel.isVerifyingDiscount ? null : () {
            // استدعاء دالة التحقق من الكود
            FocusScope.of(context).unfocus(); // إخفاء الكيبورد
            viewModel.validateDiscountCode();
          },
          // إزالة الحواف الدائرية من اليسار ليلتصق بالحقل
          style: ElevatedButton.styleFrom(
            // تعديل الـ padding ليتناسب مع ارتفاع الحقل
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
  // *********************************************

  // (دالة بناء خيار الدفع - كما هي)
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
}