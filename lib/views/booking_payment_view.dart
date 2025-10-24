import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/booking_payment_viewmodel.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart'; // Contains ProviderServiceModel
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/services/auth_service.dart'; // Needed for providing AuthService

class BookingPaymentView extends StatelessWidget {
  // Receive all necessary booking data
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
    // Provide the ViewModel for this screen instance
    return ChangeNotifierProvider(
      // create: (ctx) => BookingPaymentViewModel(ctx.read<DbService>(), ctx.read<AuthService>(), // Future
      create: (ctx) => BookingPaymentViewModel(ctx.read<AuthService>(), // Temporary
        provider: provider,
        service: service,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
      ),
      child: Consumer<BookingPaymentViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Confirm Your Booking'),
              backgroundColor: kLightBackgroundColor,
              elevation: 1,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            backgroundColor: kLightBackgroundColor,
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Booking Summary Card
                  _buildBookingSummaryCard(viewModel),
                  SizedBox(height: 24),

                  // 2. Special Requests/Notes [cite: 199]
                  _buildTextField(viewModel.notesController, 'Add special requests or notes...'),
                  SizedBox(height: 16),

                  // 3. Discount Code [cite: 202]
                  _buildTextField(viewModel.discountController, 'Enter discount code (optional)'),
                  SizedBox(height: 24),

                  // 4. Payment Options [cite: 201]
                  Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
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
                    subtitle: 'Credit/Debit Card (Coming Soon)', // Indicate unavailability
                    value: PaymentMethod.payOnline,
                    groupValue: viewModel.selectedPaymentMethod,
                    onChanged: null, // Disable online payment for now
                    // onChanged: (method) => viewModel.selectPaymentMethod(method!),
                  ),
                  SizedBox(height: 24),

                  // Error Message
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
            // Bottom "Confirm & Pay" Button
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                  bool success = await viewModel.confirmBooking();
                  if (success && context.mounted) {
                    // TODO: Navigate to a Booking Confirmation Screen
                    Navigator.of(context).popUntil((route) => route.isFirst); // Go back to Home for now
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking Confirmed Successfully!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: viewModel.isLoading
                    ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                  'Confirm Booking', // Text changes based on payment method later
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget for the Booking Summary Card
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
            Text('Booking Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Divider(height: 20),
            _buildSummaryRow('Provider:', viewModel.provider.name),
            _buildSummaryRow('Service:', viewModel.service.name),
            _buildSummaryRow('Date:', viewModel.formattedDate),
            _buildSummaryRow('Time:', viewModel.formattedTime),
            Divider(height: 20),
            _buildSummaryRow('Price:', viewModel.service.price, isBold: true),
            // TODO: Add discount calculation later
          ],
        ),
      ),
    );
  }

  // Helper for rows in the summary card
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? kPrimaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Widget for text input fields (Notes, Discount)
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

  // Widget for Payment Option Radio Buttons
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
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: kPrimaryColor,
        controlAffinity: ListTileControlAffinity.trailing, // Radio button on the right
      ),
    );
  }
}