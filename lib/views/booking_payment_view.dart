import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import the ViewModel for this screen
import 'package:ahjizzzapp/viewmodels/booking_payment_viewmodel.dart';

// Import necessary models passed to this screen
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart'; // Contains ProviderServiceModel

// Import shared resources
import 'package:ahjizzzapp/shared/app_colors.dart';

// Import services needed for ViewModel creation
import 'package:ahjizzzapp/services/auth_service.dart';
import 'package:ahjizzzapp/services/db_service.dart';

// Import the screen to navigate to upon success
import 'package:ahjizzzapp/views/booking_confirmation_view.dart';

class BookingPaymentView extends StatelessWidget {
  // Data required for the booking, received via navigation arguments
  final ServiceProvider provider;
  final ProviderServiceModel service;
  final DateTime selectedDate;
  final String selectedTime;

  // Constructor to receive the required booking data
  const BookingPaymentView({
    Key? key,
    required this.provider,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel specific to this instance of the screen
    // It reads the required DbService and AuthService from the context
    return ChangeNotifierProvider(
      create: (ctx) => BookingPaymentViewModel(
        ctx.read<DbService>(),     // Inject DbService from parent Provider
        ctx.read<AuthService>(),   // Inject AuthService from parent Provider
        provider: provider,        // Pass booking data to ViewModel
        service: service,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
      ),
      // Use Consumer to listen to changes in the ViewModel and rebuild UI
      child: Consumer<BookingPaymentViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Confirm Your Booking'),
              backgroundColor: kLightBackgroundColor,
              elevation: 1,
              // Standard back button
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            backgroundColor: kLightBackgroundColor,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0), // Padding around the content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Make children fill width
                children: [
                  // 1. Booking Summary Section
                  _buildBookingSummaryCard(viewModel),
                  const SizedBox(height: 24),

                  // 2. Special Requests Input Field
                  _buildTextField(viewModel.notesController, 'Add special requests or notes...'),
                  const SizedBox(height: 16),

                  // 3. Discount Code Input Field
                  _buildTextField(viewModel.discountController, 'Enter discount code (optional)'),
                  const SizedBox(height: 24),

                  // 4. Payment Method Section
                  const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // "Pay on Arrival" option
                  _buildPaymentOption(
                    context: context,
                    title: 'Pay on Arrival',
                    value: PaymentMethod.payOnArrival,
                    groupValue: viewModel.selectedPaymentMethod,
                    onChanged: (method) => viewModel.selectPaymentMethod(method!),
                  ),
                  // "Pay Online" option (currently disabled)
                  _buildPaymentOption(
                    context: context,
                    title: 'Pay Online',
                    subtitle: 'Credit/Debit Card (Coming Soon)', // Indicate unavailability
                    value: PaymentMethod.payOnline,
                    groupValue: viewModel.selectedPaymentMethod,
                    onChanged: null, // Disable this option for now
                  ),
                  const SizedBox(height: 24),

                  // Display Error Message if any
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom Navigation Bar containing the confirmation button
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16.0), // Padding around the button
              child: ElevatedButton(
                // Disable button while loading
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                  // Call the confirmBooking method in the ViewModel
                  bool success = await viewModel.confirmBooking();
                  // If booking was successful and the widget is still mounted
                  if (success && context.mounted) {
                    // Navigate to the confirmation screen
                    // pushAndRemoveUntil clears the booking flow screens (Details, Time, Payment)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) =>  BookingConfirmationView(),
                        // Optional: Give the route a name for popUntil logic
                        settings: const RouteSettings(name: '/booking-confirmation'),
                      ),
                      // Remove routes until we hit the dashboard or the first route
                          (route) => route.settings.name == '/dashboard' || route.isFirst,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14), // Button height
                ),
                // Show loading indicator or button text
                child: viewModel.isLoading
                    ? const SizedBox(
                  height: 20, // Size of the indicator
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2, // Thickness of the indicator circle
                  ),
                )
                    : const Text(
                  'Confirm Booking',
                  // Text style inherited from ElevatedButtonTheme in main.dart
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Helper Widgets ---

  // Builds the card summarizing the booking details
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
            _buildSummaryRow('Price:', viewModel.service.price, isBold: true),
            // TODO: Add discount display logic later
          ],
        ),
      ),
    );
  }

  // Helper for creating rows within the summary card
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

  // Builds a standard TextField for notes and discount code
  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        // Using InputBorder.none removes the underline
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!), // Light border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!), // Consistent border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryColor), // Highlight border when focused
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Text padding
      ),
    );
  }

  // Builds a Card containing a RadioListTile for payment options
  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    String? subtitle,
    required PaymentMethod value,
    required PaymentMethod groupValue,
    required ValueChanged<PaymentMethod?>? onChanged, // Nullable if disabled
  }) {
    // Determine if this option is selected
    bool isSelected = groupValue == value;
    return Card(
      elevation: 1, // Slight elevation
      margin: const EdgeInsets.only(bottom: 8), // Spacing below card
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          // Highlight border if selected
          side: BorderSide(color: isSelected ? kPrimaryColor : Colors.grey[300]!)
      ),
      child: RadioListTile<PaymentMethod>(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])) : null,
        value: value, // The value this radio button represents
        groupValue: groupValue, // The currently selected value in the group
        onChanged: onChanged, // Callback when tapped (null if disabled)
        activeColor: kPrimaryColor, // Color of the radio button when selected
        controlAffinity: ListTileControlAffinity.trailing, // Place radio button on the right
      ),
    );
  }
}