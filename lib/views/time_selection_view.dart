import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:ahjizzzapp/viewmodels/time_selection_viewmodel.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart'; // Contains ProviderServiceModel
import 'package:ahjizzzapp/shared/app_colors.dart';

class TimeSelectionView extends StatelessWidget {
  // Receive provider and service info from the previous screen
  final ServiceProvider provider;
  final ProviderServiceModel service;

  const TimeSelectionView({
    Key? key,
    required this.provider,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel for this screen instance
    return ChangeNotifierProvider(
      // create: (ctx) => TimeSelectionViewModel(ctx.read<DbService>(), provider, service), // Future
      create: (ctx) => TimeSelectionViewModel(provider, service), // Temporary
      child: Consumer<TimeSelectionViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Select Date & Time'),
              backgroundColor: kLightBackgroundColor,
              elevation: 1,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            backgroundColor: kLightBackgroundColor,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Selector (Horizontal List)
                _buildDateSelector(context, viewModel),

                // Divider
                Divider(height: 1),

                // Time Slots Grid
                Expanded(
                  child: viewModel.isLoading
                      ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
                      : _buildTimeSlotsGrid(context, viewModel),
                ),
              ],
            ),
            // Bottom "Confirm Time" Button
            bottomNavigationBar: viewModel.selectedTime != null
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => viewModel.confirmTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Confirm Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
                : null, // Hide button if no time is selected
          );
        },
      ),
    );
  }

  // Widget for the horizontal date selector
  Widget _buildDateSelector(BuildContext context, TimeSelectionViewModel viewModel) {
    return Container(
      height: 90, // Fixed height for the date selector
      color: Colors.white, // White background for the selector
      padding: EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.availableDates.length,
        itemBuilder: (context, index) {
          final date = viewModel.availableDates[index];
          final bool isSelected = viewModel.selectedDate != null &&
              date.year == viewModel.selectedDate!.year &&
              date.month == viewModel.selectedDate!.month &&
              date.day == viewModel.selectedDate!.day;

          return InkWell(
            onTap: () => viewModel.selectDate(date),
            child: Container(
              width: 65, // Width of each date item
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? kPrimaryColor : Colors.grey[300]!,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Day Name (e.g., Fri)
                  Text(
                    DateFormat('EEE').format(date), // Short day name
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 6),
                  // Day Number (e.g., 24)
                  Text(
                    DateFormat('d').format(date), // Day number
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget for the grid of available time slots
  Widget _buildTimeSlotsGrid(BuildContext context, TimeSelectionViewModel viewModel) {
    if (viewModel.availableTimes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No available time slots for the selected date.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 time slots per row
        childAspectRatio: 2.5, // Adjust ratio for button size
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: viewModel.availableTimes.length,
      itemBuilder: (context, index) {
        final time = viewModel.availableTimes[index];
        final isSelected = viewModel.selectedTime == time;

        return OutlinedButton(
          onPressed: () => viewModel.selectTime(time),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? kPrimaryColor.withOpacity(0.1) : Colors.white,
            foregroundColor: isSelected ? kPrimaryColor : Colors.black87,
            side: BorderSide(
              color: isSelected ? kPrimaryColor : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(time),
        );
      },
    );
  }
}