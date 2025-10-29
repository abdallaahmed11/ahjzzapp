import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// استيراد الـ ViewModels والـ Models
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/review_model.dart';
import 'package:ahjizzzapp/viewmodels/admin_viewmodel.dart'; // <-- 1. استيراد Admin VM
// استيراد المصادر الأخرى
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:intl/intl.dart';
import 'package:ahjizzzapp/views/widgets/star_rating_widget.dart'; // (ويدجت النجوم)
import 'package:ahjizzzapp/views/manage_services_view.dart'; // <-- 2. استيراد شاشة الأدمن الجديدة

class ProviderDetailsView extends StatelessWidget {
  final ServiceProvider provider;

  const ProviderDetailsView({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // **** 3. قراءة AdminViewModel ****
    // (استخدام .watch() عشان نضمن إنه تم تحميله)
    final bool isAdmin = context.watch<AdminViewModel>().isAdmin;
    // *******************************

    return ChangeNotifierProvider(
      create: (ctx) => ProviderDetailsViewModel(
        ctx.read<DbService>(),
        provider,
      ),
      child: Consumer<ProviderDetailsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: CustomScrollView(
              slivers: <Widget>[
                // 1. الـ AppBar
                SliverAppBar(
                  expandedHeight: 250.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: kPrimaryColor,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // **** 4. إضافة زر الأدمن هنا ****
                  actions: [
                    if (isAdmin) // <-- شرط الإظهار
                      IconButton(
                        icon: Icon(Icons.edit_note, color: Colors.white), // أيقونة القلم
                        tooltip: 'Manage Services',
                        onPressed: () {
                          // الانتقال لشاشة إدارة الخدمات
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ManageServicesView(
                              providerId: provider.id,
                              providerName: provider.name,
                            ),
                          )).then((_) {
                            // (عند الرجوع، نحدث قائمة الخدمات)
                            print("ProviderDetailsView: Refreshing services list after admin edit...");
                            viewModel.fetchProviderDetails();
                          });
                        },
                      ),
                  ],
                  // ******************************
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      viewModel.provider.name,
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    titlePadding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    background: Image.network(
                      viewModel.provider.image.isNotEmpty ? viewModel.provider.image : "https://via.placeholder.com/400x250?text=No+Image",
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[400],
                        child: Center(child: Icon(Icons.storefront, color: Colors.grey[600], size: 50)),
                      ),
                    ),
                  ),
                ),

                // 2. المحتوى الرئيسي (كما هو)
                viewModel.isLoading && viewModel.services.isEmpty
                    ? SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
                )
                    : viewModel.errorMessage != null
                    ? SliverFillRemaining(
                  child: Center(child: Text(viewModel.errorMessage!, style: TextStyle(color: Colors.red))),
                )
                    : SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(viewModel.provider.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  viewModel.provider.rating.toStringAsFixed(1),
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
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
                            Text(
                              "Working Hours: 9:00 AM - 10:00 PM (Example)",
                              style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            ),
                            Divider(height: 32),
                            Text('Select Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                          ],
                        ),
                      ),
                      _buildServiceList(context, viewModel),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(height: 32),
                            Text('Reviews (${viewModel.reviews.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 12),
                            _buildReviewsSection(context, viewModel),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // (زر المتابعة كما هو)
            bottomNavigationBar: viewModel.selectedService != null
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => viewModel.proceedToBooking(context),
                child: Text(
                  'Proceed to Book (${viewModel.selectedService!.price})',
                ),
              ),
            )
                : null,
          );
        },
      ),
    );
  }

  // (دالة _buildServiceList كما هي)
  Widget _buildServiceList(BuildContext context, ProviderDetailsViewModel viewModel) {
    if (viewModel.services.isEmpty && !viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'No specific services listed for this provider.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }
    return Column(
      children: viewModel.services.map((service) {
        final bool isSelected = viewModel.selectedService?.id == service.id;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Card(
            elevation: isSelected ? 3 : 1,
            margin: EdgeInsets.zero,
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
              subtitle: Text("${service.duration} • ${service.price}"),
              trailing: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? kPrimaryColor : Colors.grey[400],
              ),
              onTap: () => viewModel.selectService(service),
            ),
          ),
        );
      }).toList(),
    );
  }

  // (دالة _buildReviewsSection كما هي)
  Widget _buildReviewsSection(BuildContext context, ProviderDetailsViewModel viewModel) {
    if (viewModel.reviews.isEmpty) {
      return Text(
        'No reviews yet for this provider.',
        style: TextStyle(color: Colors.grey[600]),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: viewModel.reviews.length,
      itemBuilder: (context, index) {
        final review = viewModel.reviews[index];
        return _buildReviewCard(context, review);
      },
    );
  }

  // (دالة _buildReviewCard كما هي)
  Widget _buildReviewCard(BuildContext context, ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.userName, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                DateFormat('d MMM yyyy').format(review.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 4),
          // (استدعاء StarRating الموحد)
          StarRating(rating: review.rating, size: 16, onRatingChanged: (_){}),
          SizedBox(height: 8),
          if (review.reviewText.isNotEmpty)
            Text(
              review.reviewText,
              style: TextStyle(color: Colors.black87),
            ),
        ],
      ),
    );
  }
}