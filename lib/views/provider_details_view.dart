import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import the ViewModel which defines ProviderServiceModel
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
// Import the base ServiceProvider model
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';

// NO duplicate class definition here!

class ProviderDetailsView extends StatelessWidget {
  // We receive the basic provider info when navigating here
  final ServiceProvider provider;

  const ProviderDetailsView({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel for this screen instance
    return ChangeNotifierProvider(
      // create: (ctx) => ProviderDetailsViewModel(ctx.read<DbService>(), provider), // Future
      create: (ctx) => ProviderDetailsViewModel(provider), // Temporary
      child: Consumer<ProviderDetailsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            // Use SliverAppBar for the collapsing header effect
            body: CustomScrollView(
              slivers: <Widget>[
                // App Bar with Image Header
                SliverAppBar(
                  expandedHeight: 250.0, // Height of the image header
                  floating: false,
                  pinned: true, // Keep the AppBar visible when scrolling
                  backgroundColor: kPrimaryColor, // Background behind image
                  leading: IconButton( // Back button
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      viewModel.provider.name,
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    titlePadding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    background: Image.network(
                      viewModel.provider.image,
                      fit: BoxFit.cover,
                      // Add fade effect
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[400],
                        child: Center(child: Icon(Icons.storefront, color: Colors.grey[600], size: 50)),
                      ),
                    ),
                  ),
                ),

                // Main Content (Provider Info and Service List)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Provider Name (again, larger) & Rating/Location
                        Text(
                          viewModel.provider.name,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text(
                              viewModel.provider.rating.toString(),
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            // TODO: Add review count maybe?
                            SizedBox(width: 16),
                            Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 16),
                            SizedBox(width: 4),
                            Text(
                              viewModel.provider.distance,
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // TODO: Add Working Hours
                        Text(
                          "Working Hours: 9:00 AM - 10:00 PM (Example)", // Placeholder
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                        Divider(height: 32),

                        // Service List Section
                        Text(
                          'Select Service',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        // Display loading or the list of services
                        viewModel.isLoading
                            ? Center(child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: kPrimaryColor),
                        ))
                            : _buildServiceList(context, viewModel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom Button (sticky)
            bottomNavigationBar: viewModel.selectedService != null
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => viewModel.proceedToBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Proceed to Book (${viewModel.selectedService!.price})',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
                : null, // Hide button if no service is selected
          );
        },
      ),
    );
  }

  // Widget to build the list of selectable services
  Widget _buildServiceList(BuildContext context, ProviderDetailsViewModel viewModel) {
    if (viewModel.services.isEmpty) {
      return Center(child: Text('No specific services listed for this provider.'));
    }

    return ListView.builder(
      shrinkWrap: true, // Important inside CustomScrollView
      physics: NeverScrollableScrollPhysics(), // Let the outer scroll handle it
      itemCount: viewModel.services.length,
      itemBuilder: (context, index) {
        // Use the ProviderServiceModel defined in the ViewModel
        final ProviderServiceModel service = viewModel.services[index];
        final bool isSelected = viewModel.selectedService?.id == service.id;

        return Card(
          elevation: isSelected ? 3 : 1, // Highlight selected card
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? kPrimaryColor : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            title: Text(service.name, style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text("${service.duration} • ${service.price}"), // Display duration & price
            trailing: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? kPrimaryColor : Colors.grey[400],
            ),
            onTap: () => viewModel.selectService(service),
          ),
        );
      },
    );
  }
}