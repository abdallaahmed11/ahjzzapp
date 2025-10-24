import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/service_list_viewmodel.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/views/provider_details_view.dart';
class ServiceListView extends StatelessWidget {
  // We receive category info when navigating to this screen
  final String categoryId;
  final String categoryName;

  const ServiceListView({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel specifically for this screen instance
    return ChangeNotifierProvider(
      // create: (ctx) => ServiceListViewModel(ctx.read<DbService>(), categoryId, categoryName), // Future
      create: (ctx) => ServiceListViewModel(categoryId, categoryName), // Temporary
      child: Consumer<ServiceListViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(categoryName), // Display category name
              backgroundColor: kLightBackgroundColor,
              elevation: 1,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                // Sort/Filter Button (Placeholder)
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.grey[700]),
                  onPressed: () {
                    // TODO: Implement filter/sort options (e.g., show a bottom sheet)
                    print("Filter/Sort tapped");
                  },
                ),
              ],
            ),
            backgroundColor: kLightBackgroundColor,
            body: viewModel.isLoading
                ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
                : _buildProviderList(context, viewModel),
          );
        },
      ),
    );
  }

  // Widget to build the list of providers
  Widget _buildProviderList(BuildContext context, ServiceListViewModel viewModel) {
    if (viewModel.providers.isEmpty) {
      return Center(child: Text('No providers found for this category.'));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: viewModel.providers.length,
      itemBuilder: (context, index) {
        final provider = viewModel.providers[index];
        // Build a card for each provider
        return _buildProviderCard(context, provider);
      },
    );
  }

  // Widget for the individual provider card
  Widget _buildProviderCard(BuildContext context, ServiceProvider provider) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell( // Make the card tappable
        onTap: () {
          print("Tapped on provider: ${provider.name}");
          // Navigate to ProviderDetailsView, passing the provider object
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProviderDetailsView(provider: provider),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                provider.image, // Ensure valid image URL
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                // Add error handling for images
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
            ),
            // Provider Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text(
                            provider.rating.toString(),
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          // (Optional: Add review count here)
                        ],
                      ),
                      // Distance
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 16),
                          SizedBox(width: 4),
                          Text(
                            provider.distance,
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  // Price Indicator (using the price from the mock data)
                  Text(
                    "Starts from ${provider.price}", // Simple price display
                    style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}