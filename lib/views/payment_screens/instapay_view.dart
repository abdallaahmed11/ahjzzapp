import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// (نفس الـ imports السابقة)
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/alternative_payment_viewmodel.dart';
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/views/booking_confirmation_view.dart';

class InstaPayView extends StatelessWidget {
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;
  final double totalPrice;
  final String? discountCode;

  const InstaPayView({
    Key? key,
    required this.provider, required this.service, required this.selectedDate,
    required this.selectedTime, required this.totalPrice, this.discountCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ألوان إنستا باي (تدرج)
    final Color instaPrimary = Color(0xFF4A148C); // Deep Purple

    return ChangeNotifierProvider(
      create: (ctx) => AlternativePaymentViewModel(
        provider: provider, service: service, selectedDate: selectedDate,
        selectedTime: selectedTime, totalPrice: totalPrice, discountCode: discountCode,
        paymentMethodName: "instapay",
        dbService: ctx.read<DbService>(), authService: ctx.read<AuthService>(),
      ),
      child: Consumer<AlternativePaymentViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("InstaPay Payment", style: TextStyle(color: Colors.white)),
              backgroundColor: instaPrimary,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.send_to_mobile, size: 80, color: instaPrimary),
                  SizedBox(height: 20),

                  Text(
                    "Total Amount: \$${totalPrice.toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 40),

                  TextField(
                    controller: viewModel.identifierController,
                    decoration: InputDecoration(
                      labelText: "InstaPay Address (IPA)",
                      hintText: "username@instapay",
                      prefixIcon: Icon(Icons.alternate_email, color: instaPrimary),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: instaPrimary, width: 2)),
                    ),
                  ),

                  Spacer(),

                  if (viewModel.errorMessage != null)
                    Text(viewModel.errorMessage!, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: instaPrimary,
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
                        : Text("Confirm Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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