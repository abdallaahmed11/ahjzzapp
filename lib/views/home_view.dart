import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/home_viewmodel.dart'; // استيراد الـ ViewModel
import 'package:ahjizzzapp/shared/app_colors.dart';     // استيراد الألوان
import 'package:ahjizzzapp/views/notifications_view.dart'; // استيراد شاشة التنبيهات
import 'package:ahjizzzapp/views/service_list_view.dart';  // استيراد شاشة قائمة الخدمات
import 'package:ahjizzzapp/views/provider_details_view.dart';// استيراد شاشة تفاصيل المزود
import 'package:ahjizzzapp/models/service_provider.dart';   // استيراد الموديل المطلوب للانتقال

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // استخدام Consumer لمراقبة التغييرات في HomeViewModel
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kLightBackgroundColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${viewModel.userName}!', // عرض اسم المستخدم
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            Text(
              'What service do you need today?', // نص فرعي
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[700]), // أيقونة البحث
            onPressed: () { /* TODO: Implement Search */ },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, // أيقونة التنبيهات
                color: Colors.grey[700]),
            onPressed: () {
              // الانتقال لشاشة التنبيهات
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => NotificationsView()),
              );
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      backgroundColor: kLightBackgroundColor,
      // إظهار مؤشر التحميل أو محتوى الشاشة
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : RefreshIndicator( // لإضافة السحب للتحديث
        onRefresh: viewModel.fetchData, // استدعاء دالة جلب البيانات
        color: kPrimaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // للسماح بالسحب
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndFilters(context), // قسم البحث والفلاتر

              _buildSectionHeader(context, 'Services Near You', 'See All'), // عنوان قسم الخدمات القريبة
              _buildServicesNearYouList(context, viewModel), // قائمة الخدمات القريبة

              _buildSectionHeader(context, 'Categories', null), // عنوان قسم الفئات
              _buildCategoriesList(context, viewModel), // قائمة الفئات

              _buildSectionHeader(context, 'Top Rated in Your Area', null), // عنوان قسم الأعلى تقييماً
              _buildTopRatedList(context, viewModel), // قائمة الأعلى تقييماً

              _buildPromoBanner(context), // بانر العرض
            ],
          ),
        ),
      ),
    );
  }

  // --- الدوال المساعدة لبناء أجزاء الواجهة ---

  Widget _buildSearchAndFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for services...',
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
          Row(
            children: [
              _buildFilterChip(context, Icons.location_on, 'Cairo, Egypt', true),
              SizedBox(width: 10),
              _buildFilterChip(context, Icons.calendar_today, 'Today', false),
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (actionText != null)
            InkWell(
              onTap: () {
                // TODO: Implement navigation for "See All"
                print("$title - See All tapped");
              },
              child: Text(
                actionText,
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServicesNearYouList(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.servicesNearYou.isEmpty && !viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Text('No nearby services found.', style: TextStyle(color: Colors.grey[600])),
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
              clipBehavior: Clip.antiAlias, // لقص الصورة
              child: InkWell(
                onTap: () {
                  print("Tapped nearby service: ${service.name}");
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
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:(context, error, stackTrace) => Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: Center(child: Icon(Icons.storefront, color: Colors.grey[500], size: 40)),
                          ) ,
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
                                service.price,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
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
                                Text(service.rating.toString()),
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
        child: Text('No categories found.', style: TextStyle(color: Colors.grey[600])),
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
              print("Tapped category: ${category.name}");
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

  // **** دالة بناء قائمة الأعلى تقييماً (المُعدلة) ****
  Widget _buildTopRatedList(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.topRatedProviders.isEmpty && !viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Text(
            'No top rated providers found yet.',
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
                // **** 1. إضافة الصورة هنا ****
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: provider.image.isNotEmpty
                      ? NetworkImage(provider.image) // استخدام الصورة الحقيقية
                      : null,
                  child: provider.image.isEmpty
                      ? Icon(Icons.storefront, color: Colors.grey[500])
                      : null,
                ),
                SizedBox(width: 12),
                // ***************************

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
                        print("Book Now tapped for (Top Rated): ${provider.name}");
                        // **** 2. التعديل هنا: استخدام provider.image ****
                        final providerData = ServiceProvider(
                            id: provider.id,
                            name: provider.name,
                            image: provider.image, // <-- استخدام الصورة الحقيقية
                            rating: provider.rating,
                            price: provider.price,
                            distance: "Nearby" // (لسه محتاجين نظبط المسافة)
                        );
                        // *****************************************

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProviderDetailsView(provider: providerData),
                          ),
                        );
                      },
                      child: Text('Book Now'),
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
  // ---------------------------------------------

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
                      'NEW USER OFFER',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Get 30% Off',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'On your first booking with us',
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