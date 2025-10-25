import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import ViewModel, Models, Services, Shared Resources, and next View
import 'package:ahjizzzapp/viewmodels/service_list_viewmodel.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/views/provider_details_view.dart';

class ServiceListView extends StatelessWidget {
  // Receive category info when navigating to this screen
  final String categoryId; // Keep ID if needed for other potential logic
  final String categoryName;

  const ServiceListView({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel specific to this screen instance,
    // injecting the required DbService and category details.
    return ChangeNotifierProvider(
      create: (ctx) => ServiceListViewModel(
        ctx.read<DbService>(), // Read DbService instance from the parent Provider
        // categoryId,        // Pass categoryId if needed by ViewModel later
        categoryName,      // Pass categoryName for fetching and display
      ),
      // Use Consumer to rebuild the UI when the ViewModel notifies listeners
      child: Consumer<ServiceListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.categoryName), // Display category name from ViewModel
              backgroundColor: kLightBackgroundColor,
              elevation: 1,
              // Standard back button
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                // Sort/Filter Dropdown Menu Button
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, color: Colors.black54), // Changed icon to sort
                  tooltip: "Sort Providers", // Tooltip for accessibility
                  // Called when a menu item is selected
                  onSelected: (String result) {
                    viewModel.changeSortOption(result); // Trigger ViewModel action
                  },
                  // Defines the items in the dropdown menu
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    // Option to sort by Top Rated
                    PopupMenuItem<String>(
                      value: 'Top Rated', // Value passed to onSelected
                      enabled: viewModel.sortBy != 'Top Rated', // Disable if already selected
                      child: Text('Sort by: Top Rated', style: TextStyle(fontWeight: viewModel.sortBy == 'Top Rated' ? FontWeight.bold : FontWeight.normal)),
                    ),
                    // Option to sort by Name (Default)
                    PopupMenuItem<String>(
                      value: 'Name', // Value passed to onSelected
                      enabled: viewModel.sortBy != 'Name', // Disable if already selected
                      child: Text('Sort by: Name', style: TextStyle(fontWeight: viewModel.sortBy == 'Name' ? FontWeight.bold : FontWeight.normal)),
                    ),
                    // Add more sort/filter options here later (e.g., Price, Distance)
                  ],
                ),
              ],
            ),
            backgroundColor: kLightBackgroundColor,
            // Body conditionally displays Loading, Error, or the Provider List
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator(color: kPrimaryColor)) // Show loading indicator
            // Show error message if fetch failed
                : viewModel.errorMessage != null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column( // Display error and a retry button
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700], size: 40),
                    const SizedBox(height: 10),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: viewModel.fetchProviders, // Retry fetching
                      child: const Text("Retry"),
                    )
                  ],
                ),
              ),
            )
            // Show the list of providers if loading is done and no error
                : _buildProviderList(context, viewModel),
          );
        },
      ),
    );
  }

  // Widget to build the scrollable list of providers
  Widget _buildProviderList(BuildContext context, ServiceListViewModel viewModel) {
    // Show a message if the list is empty after loading
    if (viewModel.providers.isEmpty) {
      return const Center(
          child: Text(
            'No providers found for this category.',
            style: TextStyle(color: Colors.grey),
          ));
    }

    // Use ListView.builder for efficient list rendering
    return ListView.builder(
      padding: const EdgeInsets.all(16), // Padding around the list
      itemCount: viewModel.providers.length, // Number of items in the list
      itemBuilder: (context, index) {
        final provider = viewModel.providers[index]; // Get current provider data
        return _buildProviderCard(context, provider); // Build a card for each provider
      },
    );
  }

  // Widget for the individual provider card (UI details)
  Widget _buildProviderCard(BuildContext context, ServiceProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16), // Spacing below the card
      elevation: 2, // Card shadow
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Rounded corners
      clipBehavior: Clip.antiAlias, // Ensures image respects card border radius
      child: InkWell( // Make the entire card tappable
        onTap: () {
          // Navigate to ProviderDetailsView when the card is tapped
          print("Navigating to details for provider: ${provider.name}");
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:(context) => ProviderDetailsView(provider: provider), // Pass provider data
              settings: const RouteSettings(name: '/provider-details'), // Optional route name
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Image
            Image.network(
              provider.image.isNotEmpty ? provider.image : "https://via.placeholder.com/300x150?text=No+Image", // Placeholder if no image
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              // Show placeholder/icon on image load error
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: Center(child: Icon(Icons.storefront, color: Colors.grey[500], size: 40)),
              ),
            ),
            // Provider Details below the image
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Name
                  Text(
                    provider.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Rating and Distance Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating display
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            provider.rating.toStringAsFixed(1), // Format rating to 1 decimal place
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          // TODO: Optionally add review count here "(123)"
                        ],
                      ),
                      // Distance display
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            provider.distance,
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Price Indicator
                  Text(
                    "Starts from ${provider.price}", // Simple price display
                    style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} // End of ServiceListView