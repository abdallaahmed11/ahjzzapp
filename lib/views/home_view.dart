import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/home_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/views/notifications_view.dart';
import 'package:ahjizzzapp/views/service_list_view.dart';
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. استخدام "Consumer" لمراقبة التغييرات
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: kLightBackgroundColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${viewModel.userName}!', // [cite: 31]
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                ),
                Text(
                  'What service do you need today?', // [cite: 32]
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.grey[700]), // [cite: 40]
                onPressed: () { /* TODO: Implement Search */ },
              ),
              IconButton(
                icon: Icon(Icons.notifications_none_outlined, color: Colors.grey[700]),
                onPressed: () { Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => NotificationsView()),
                ); },
              ),
              SizedBox(width: 8),
            ],
          ),
          backgroundColor: kLightBackgroundColor,
          // إظهار التحميل أو المحتوى
          body: viewModel.isLoading
              ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndFilters(context),

                _buildSectionHeader(context, 'Services Near You', 'See All'), // [cite: 35, 42]
                _buildServicesNearYouList(context, viewModel),

                _buildSectionHeader(context, 'Categories', null), // [cite: 38]
                _buildCategoriesList(context, viewModel),

                _buildSectionHeader(context, 'Top Rated in Your Area', null), // [cite: 48, 57]
                _buildTopRatedList(context, viewModel),

                _buildPromoBanner(context), // [cite: 65-67]
              ],
            ),
          ),
        );
      },
    );
  }

  // --- (دوال مساعدة لتقسيم الواجهة) ---

  Widget _buildSearchAndFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // شريط البحث
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for services...', // [cite: 33]
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: Icon(Icons.filter_list, color: kPrimaryColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 12),
          // الفلاتر
          Row(
            children: [
              _buildFilterChip(context, Icons.location_on, 'Cairo, Egypt', true), // [cite: 34]
              SizedBox(width: 10),
              _buildFilterChip(context, Icons.calendar_today, 'Today', false), // [cite: 41]
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
          Text(
            label,
            style: TextStyle(color: isActive ? Colors.white : Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String? actionText) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (actionText != null)
            Text(
              actionText,
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _buildServicesNearYouList(BuildContext context, HomeViewModel viewModel) {
    return Container(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.servicesNearYou.length,
        itemBuilder: (context, index) {
          final service = viewModel.servicesNearYou[index];
          // كرت الخدمة
          return Container(
            width: 200,
            margin: EdgeInsets.all(4),
            child: Card(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الصورة والسعر
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          service.image, // (تأكد من وضع رابط صورة حقيقي)
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            service.price, // [cite: 39]
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // التفاصيل
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name, // [cite: 36]
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(service.rating.toString()), // [cite: 37]
                            ]),
                            Row(children: [
                              Icon(Icons.location_on, color: Colors.grey, size: 16),
                              SizedBox(width: 4),
                              Text(service.distance, style: TextStyle(fontSize: 12, color: Colors.grey[700])), // [cite: 43]
                            ]),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // (Inside _buildCategoriesList in home_view.dart)

  Widget _buildCategoriesList(BuildContext context, HomeViewModel viewModel) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.quickCategories.length,
        itemBuilder: (context, index) {
          final category = viewModel.quickCategories[index];
          // --- WRAP THIS COLUMN ---
          return InkWell( // <-- ADD InkWell
            onTap: () {
              print("Tapped category: ${category.name}");
              // Navigate to ServiceListView, passing category details
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ServiceListView(
                    categoryId: category.id, // Pass ID
                    categoryName: category.name, // Pass Name
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8), // For ripple effect
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: category.color.withOpacity(0.15),
                    child: Icon(category.icon, size: 28, color: category.color),
                  ),
                  SizedBox(height: 6),
                  Text(category.name, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                ],
              ),
            ),
          ); // --- END InkWell ---
        },
      ),
    );
  }

  Widget _buildTopRatedList(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: viewModel.topRatedProviders.length,
        itemBuilder: (context, index) {
          final provider = viewModel.topRatedProviders[index];
          // كرت التقييم
          return Card(
            elevation: 1,
            shadowColor: Colors.black12,
            margin: EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // (يمكن إضافة صورة هنا)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(provider.name, style: TextStyle(fontWeight: FontWeight.bold)), // [cite: 58, 60, 62]
                        Text(provider.category, style: TextStyle(fontSize: 12, color: Colors.grey[600])), // [cite: 58, 60, 63]
                        SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text('${provider.rating} (${provider.reviews} reviews)', style: TextStyle(fontSize: 12)), // [cite: 59, 61, 64]
                        ]),
                      ],
                    ),
                  ),
                  // السعر وزر الحجز
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        provider.price, // [cite: 68, 70, 72]
                        style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Book Now'), // [cite: 69, 71, 73]
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            textStyle: TextStyle(fontSize: 12)
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.indigo.shade600, // لون تقريبي
          borderRadius: BorderRadius.circular(15),
        ),
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
                'NEW USER OFFER', // [cite: 65]
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Get 30% Off', // [cite: 66]
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'On your first booking with us', // [cite: 67]
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}