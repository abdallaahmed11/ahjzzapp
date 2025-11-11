import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// استيراد الموديلات والـ ViewModels والخدمات
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/credit_card_payment_viewmodel.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/views/booking_confirmation_view.dart';

class CreditCardPaymentView extends StatelessWidget {
  // البيانات المستلمة من شاشة BookingPaymentView
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;
  final double totalPrice;
  final String? discountCode;

  const CreditCardPaymentView({
    Key? key,
    required this.provider,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.totalPrice,
    this.discountCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // توفير الـ ViewModel لهذه الشاشة
    return ChangeNotifierProvider(
      create: (ctx) => CreditCardPaymentViewModel(
        provider: provider,
        service: service,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        totalPrice: totalPrice,
        discountCode: discountCode,
        dbService: ctx.read<DbService>(),
        authService: ctx.read<AuthService>(),
      ),
      child: Consumer<CreditCardPaymentViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Enter Payment Details'),
            ),
            backgroundColor: kLightBackgroundColor,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // (يمكن إضافة صورة كارت هنا)
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: viewModel.cardHolderNameController,
                    label: 'Cardholder Name',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: viewModel.cardNumberController,
                    label: 'Card Number',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: viewModel.expiryDateController,
                          label: 'Expiry Date',
                          hint: 'MM/YY',
                          icon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildTextField(
                          controller: viewModel.cvvController,
                          label: 'CVV',
                          hint: '123',
                          icon: Icons.lock_outline,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),

                  // عرض رسالة الخطأ
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  // زر الدفع
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                      bool success = await viewModel.submitPayment();
                      if (success && context.mounted) {
                        // نجح الدفع والحجز، اذهب لشاشة التأكيد
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) =>  BookingConfirmationView(),
                            settings: const RouteSettings(name: '/booking-confirmation'),
                          ),
                              (route) => route.settings.name == '/dashboard' || route.isFirst,
                        );
                      }
                    },
                    child: viewModel.isLoading
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Pay \$${totalPrice.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // (ويدجت مساعد لحقل النص)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
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
          borderSide: BorderSide(color: kPrimaryColor, width: 2),
        ),
      ),
    );
  }
}