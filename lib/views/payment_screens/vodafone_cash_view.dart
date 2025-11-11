import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/alternative_payment_viewmodel.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/views/booking_confirmation_view.dart';

class VodafoneCashView extends StatelessWidget {
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;
  final double totalPrice;
  final String? discountCode;

  const VodafoneCashView({
    Key? key,
    required this.provider, required this.service, required this.selectedDate,
    required this.selectedTime, required this.totalPrice, this.discountCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // اللون المميز لفودافون
    final Color vfColor = Color(0xFFE60000);

    return ChangeNotifierProvider(
      create: (ctx) => AlternativePaymentViewModel(
        provider: provider, service: service, selectedDate: selectedDate,
        selectedTime: selectedTime, totalPrice: totalPrice, discountCode: discountCode,
        paymentMethodName: "vodafone_cash",
        dbService: ctx.read<DbService>(), authService: ctx.read<AuthService>(),
      ),
      child: Consumer<AlternativePaymentViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Vodafone Cash Payment", style: TextStyle(color: Colors.white)),
              backgroundColor: vfColor,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // اللوجو (أيقونة مؤقتة)
                  Icon(Icons.phone_android, size: 80, color: vfColor),
                  SizedBox(height: 20),

                  // السعر
                  Text(
                    "Total Amount: \$${totalPrice.toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 40),

                  // حقل الإدخال
                  TextField(
                    controller: viewModel.identifierController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Enter Wallet Number",
                      prefixIcon: Icon(Icons.phone, color: vfColor),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: vfColor, width: 2)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "You will receive a request to confirm payment on your wallet.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),

                  Spacer(),

                  if (viewModel.errorMessage != null)
                    Text(viewModel.errorMessage!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),

                  SizedBox(height: 10),

                  // زر الدفع
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vfColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: viewModel.isLoading ? null : () async {
                      bool success = await viewModel.submitPayment();
                      if (success && context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) =>  BookingConfirmationView()),
                              (route) => route.settings.name == '/dashboard' || route.isFirst,
                        );
                      }
                    },
                    child: viewModel.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Pay Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}