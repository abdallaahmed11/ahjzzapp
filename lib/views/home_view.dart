import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ahjizzzapp/viewmodels/home_viewmodel.dart';
import 'package:ahjizzzapp/viewmodels/admin_viewmodel.dart'; // <-- استيراد AdminViewModel
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/views/notifications_view.dart';
import 'package:ahjizzzapp/views/service_list_view.dart';
import 'package:ahjizzzapp/views/provider_details_view.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
import 'package:ahjizzzapp/models/top_rated_provider.dart';
// (لا نحتاج استيراد search_view.dart هنا لأننا نستخدم المسار)

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final adminViewModel = context.watch<AdminViewModel>(); // <-- الوصول لـ AdminViewModel

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kLightBackgroundColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "home_hello".tr(namedArgs: {'name': viewModel.userName}),
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              "home_subtitle".tr(),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          // **** 1. تعديل زر الأدمن ****
          if (adminViewModel.isAdmin) // <-- شرط الإظهار
            IconButton(
              icon: Icon(Icons.add_circle, color: kPrimaryColor, size: 28), // تكبير الأيقونة
              onPressed: () {
                print("Admin: Navigating to Add New Service Screen");
                // الانتقال للشاشة الجديدة باستخدام المسار (Route)
                Navigator.of(context).pushNamed('/add-provider');
              },
              tooltip: "Add New Service",
            ),
          // ***************************

          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[700]),
            onPressed: () {
              Navigator.of(context).pushNamed('/search');
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: Colors.grey[700]),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NotificationsView()),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      backgroundColor: kLightBackgroundColor,
      // (باقي كود الـ body والـ RefreshIndicator كما هو)
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : RefreshIndicator(
        onRefresh: () async {
          // تحديث بيانات الهوم والأدمن معاً
          await viewModel.fetchData();
          await adminViewModel.checkUserRole(); // (اختياري: للتأكد من الدور)
        },
        color: kPrimaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndFilters(context, viewModel),
              _buildSectionHeader(context, "home_section_nearby".tr(), "home_see_all".tr()),
              _buildServicesNearYouList(context, viewModel),
              _buildSectionHeader(context, "home_section_categories".tr(), null),
              _buildCategoriesList(context, viewModel),
              _buildSectionHeader(context, "home_section_top_rated".tr(), null),
              _buildTopRatedList(context, viewModel),
              _buildPromoBanner(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- (كل الدوال المساعدة لبناء الواجهة كما هي) ---

  Widget _buildSearchAndFilters(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/search');
            },
            child: AbsorbPointer(
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: "home_search_hint".tr(),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.filter_list, color: kPrimaryColor),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none,),
                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none,),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildCityFilterButton(context, viewModel),
              SizedBox(width: 10),
              _buildFilterChip(context, Icons.calendar_today, "home_filter_date".tr(), false),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, IconData icon, String label, bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[200]!)
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey[700]),
          SizedBox(width: 6),
          Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildCityFilterButton(BuildContext context, HomeViewModel viewModel) {
    return PopupMenuButton<String>(
      onSelected: (String newCity) {
        viewModel.changeCity(newCity);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: kPrimaryColor, borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text(viewModel.selectedCity, style: TextStyle(color: Colors.white)),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.white),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) {
        return viewModel.availableCities.map((String city) {
          return PopupMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList();
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String? actionText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (actionText != null)
            InkWell(
              onTap: () { print("$title - See All tapped"); },
              child: Text(actionText, style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildServicesNearYouList(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.servicesNearYou.isEmpty && !viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Text("home_no_nearby".tr(namedArgs: {'city': viewModel.selectedCity}), style: TextStyle(color: Colors.grey[600])),
      );
    }
    return Container(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.servicesNearYou.length,
        itemBuilder: (context, index) {
          final service = viewModel.servicesNearYou[index];
          return Container(
            width: 200,
            margin: EdgeInsets.all(4),
            child: Card(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProviderDetailsView(provider: service),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Image.network(
                          service.image.isNotEmpty ? service.image : "https://via.placeholder.com/200x120?text=No+Image",
                          height: 120, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder:(context, error, stackTrace) => Container(
                            height: 120, color: Colors.grey[200],
                            child: Center(child: Icon(Icons.storefront, color: Colors.grey[500], size: 40)),
                          ) ,
                        ),
                        Positioned(
                            top: 8, right: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: Text( service.price, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12) ),
                            )
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text( service.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(service.rating.toStringAsFixed(1)),
                              ]),
                              Row(children: [
                                Icon(Icons.location_on, color: Colors.grey, size: 16),
                                SizedBox(width: 4),
                                Text(service.distance, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                              ]),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.quickCategories.isEmpty && !viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Text("home_no_categories".tr(), style: TextStyle(color: Colors.grey[600])),
      );
    }
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.quickCategories.length,
        itemBuilder: (context, index) {
          final category = viewModel.quickCategories[index];
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ServiceListView(
                    categoryId: category.id,
                    categoryName: category.name,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: category.color.withOpacity(0.15),
                    child: Icon(category.icon, size: 28, color: category.color),
                  ),
                  SizedBox(height: 6),
                  Text(
                    category.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopRatedList(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.topRatedProviders.isEmpty && !viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Text(
            "home_no_top_rated".tr(namedArgs: {'city': viewModel.selectedCity}),
            style: TextStyle(color: Colors.grey[600])
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: viewModel.topRatedProviders.length,
      itemBuilder: (context, index) {
        final provider = viewModel.topRatedProviders[index];
        return Card(
          elevation: 1,
          shadowColor: Colors.black12,
          margin: EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: provider.image.isNotEmpty
                      ? NetworkImage(provider.image)
                      : null,
                  child: provider.image.isEmpty
                      ? Icon(Icons.storefront, color: Colors.grey[500])
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 2),
                      Text(provider.category, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text('${provider.rating} (${provider.reviews} reviews)', style: TextStyle(fontSize: 12)),
                      ]),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.price,
                      style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: () {
                        final providerData = ServiceProvider(
                            id: provider.id,
                            name: provider.name,
                            image: provider.image,
                            rating: provider.rating,
                            price: provider.price,
                            distance: "Nearby"
                        );
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProviderDetailsView(provider: providerData),
                          ),
                        );
                      },
                      child: Text("home_book_now".tr()),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: TextStyle(fontSize: 12)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16,16,16, 24),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.purple.shade600],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      "home_promo_offer".tr(),
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "home_promo_title".tr(),
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "home_promo_subtitle".tr(),
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.card_giftcard, color: Colors.white.withOpacity(0.5), size: 50),
            ),
          ],
        ),
      ),
    );
  }
}