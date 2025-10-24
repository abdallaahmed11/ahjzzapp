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
                  'Hello, ${viewModel.userName}!', // اسم المستخدم
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
      },
    );
  }

  // --- الدوال المساعدة لبناء أجزاء الواجهة ---

  Widget _buildSearchAndFilters(BuildContext context) {
    // (الكود كما هو)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for services...', // نص البحث
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: Icon(Icons.filter_list, color: kPrimaryColor), // أيقونة الفلتر
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
              _buildFilterChip(context, Icons.location_on, 'Cairo, Egypt', true), // فلتر الموقع
              SizedBox(width: 10),
              _buildFilterChip(context, Icons.calendar_today, 'Today', false), // فلتر التاريخ
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, IconData icon, String label, bool isActive) {
    // (الكود كما هو)
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
    // (الكود كما هو - مع InkWell لـ See All)
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title, // عنوان القسم
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (actionText != null)
            InkWell(
              onTap: () {
                // TODO: Implement navigation for "See All"
                print("$title - See All tapped");
              },
              child: Text(
                actionText, // نص "See All"
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServicesNearYouList(BuildContext context, HomeViewModel viewModel) {
    // (الكود كما هو - مع فحص القائمة الفارغة ومعالجة خطأ الصورة والانتقال)
    if (viewModel.servicesNearYou.isEmpty && !viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Text('No nearby services found.', style: TextStyle(color: Colors.grey[600])),
      );
    }
    return Container(
      height: 230, // ارتفاع محدد للقائمة الأفقية
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.servicesNearYou.length,
        itemBuilder: (context, index) {
          final service = viewModel.servicesNearYou[index];
          // كرت الخدمة
          return Container(
            width: 200, // عرض محدد للكرت
            margin: EdgeInsets.all(4),
            child: Card(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: InkWell( // لجعل الكرت قابل للضغط
                onTap: () {
                  print("Tapped nearby service: ${service.name}");
                  // الانتقال لشاشة التفاصيل عند الضغط
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProviderDetailsView(provider: service),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack( // لوضع السعر فوق الصورة
                      children: [
                        ClipRRect( // لجعل حواف الصورة دائرية
                          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.network(
                            // استخدام رابط احتياطي في حالة عدم وجود صورة
                            service.image.isNotEmpty ? service.image : "https://via.placeholder.com/200x120?text=No+Image",
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            // إظهار أيقونة بديلة في حالة فشل تحميل الصورة
                            errorBuilder:(context, error, stackTrace) => Container(
                              height: 120,
                              color: Colors.grey[200],
                              child: Center(child: Icon(Icons.storefront, color: Colors.grey[500], size: 40)),
                            ) ,
                          ),
                        ),
                        Positioned( // لتحديد مكان السعر
                            top: 8,
                            right: 8,
                            child: Container( // خلفية السعر البيضاء
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                service.price, // السعر
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                        ),
                      ],
                    ),
                    Padding( // التفاصيل تحت الصورة
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text( // اسم الخدمة
                            service.name,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Row( // التقييم والمسافة
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [ // التقييم
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(service.rating.toString()),
                              ]),
                              Row(children: [ // المسافة
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
    // (الكود كما هو - مع فحص القائمة الفارغة والانتقال)
    if (viewModel.quickCategories.isEmpty && !viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Text('No categories found.', style: TextStyle(color: Colors.grey[600])),
      );
    }
    return Container(
      height: 100, // ارتفاع محدد للقائمة الأفقية
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.quickCategories.length,
        itemBuilder: (context, index) {
          final category = viewModel.quickCategories[index];
          // أيقونة الفئة القابلة للضغط
          return InkWell(
            onTap: () {
              print("Tapped category: ${category.name}");
              // الانتقال لشاشة قائمة الخدمات عند الضغط
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ServiceListView(
                    categoryId: category.id, // تمرير ID الفئة
                    categoryName: category.name, // تمرير اسم الفئة
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8), // لجعل التأثير دائري
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar( // الدائرة الملونة للأيقونة
                    radius: 28,
                    backgroundColor: category.color.withOpacity(0.15),
                    child: Icon(category.icon, size: 28, color: category.color),
                  ),
                  SizedBox(height: 6),
                  Text( // اسم الفئة
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

  // **** دالة بناء قائمة الأعلى تقييماً (المُعدلة والمصححة) ****
  Widget _buildTopRatedList(BuildContext context, HomeViewModel viewModel) {
    // 1. فحص القائمة الفارغة
    if (viewModel.topRatedProviders.isEmpty && !viewModel.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Text(
            'No top rated providers found yet.',
            style: TextStyle(color: Colors.grey[600])
        ),
      );
    }
    // ------------------------------------

    // 2. بناء القائمة باستخدام ListView.builder
    // **لا نستخدم Padding هنا مباشرة، بل نستخدمه في العنصر الأب (Column)**
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding حول العناصر
      shrinkWrap: true, // مهم جداً داخل SingleChildScrollView
      physics: NeverScrollableScrollPhysics(), // لمنع السكرول المتداخل
      itemCount: viewModel.topRatedProviders.length, // استخدام البيانات من الـ ViewModel
      itemBuilder: (context, index) {
        final provider = viewModel.topRatedProviders[index]; // المزود الحالي
        // بناء الكرت
        return Card(
          elevation: 1,
          shadowColor: Colors.black12,
          margin: EdgeInsets.symmetric(vertical: 6), // مسافة بين الكروت
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded( // الجزء الأيسر: الاسم، الفئة، التقييم
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
                SizedBox(width: 8), // مسافة
                Column( // الجزء الأيمن: السعر وزر الحجز
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.price, // السعر
                      style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    ElevatedButton( // زر الحجز
                      onPressed: () {
                        print("Book Now tapped for (Top Rated): ${provider.name}");
                        // تحويل TopRatedProvider إلى ServiceProvider للانتقال
                        final providerData = ServiceProvider(
                            id: provider.id,
                            name: provider.name,
                            // استخدام صورة مؤقتة - ستحتاج لجلب الصورة الحقيقية
                            image: "https://via.placeholder.com/300?text=${provider.name.replaceAll(' ', '+')}",
                            rating: provider.rating,
                            price: provider.price,
                            distance: "Nearby" // مسافة مؤقتة
                        );

                        // الانتقال لشاشة تفاصيل المزود
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProviderDetailsView(provider: providerData),
                          ),
                        );
                      },
                      child: Text('Book Now'), // نص الزر
                      style: ElevatedButton.styleFrom( // تصميم الزر
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
    ); // <-- نهاية ListView.builder
    // ---------------------------------------------
  }


  Widget _buildPromoBanner(BuildContext context) {
    // (الكود كما هو - مع تعديل بسيط للشكل)
    return Padding(
      padding: const EdgeInsets.fromLTRB(16,16,16, 24), // Padding حول البانر
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          // استخدام gradient مشابه للتصميم
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.purple.shade600],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(15), // حواف دائرية
        ),
        child: Row( // لوضع الأيقونة بجانب النص
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // لجعل النص يأخذ المساحة المتاحة
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container( // شارة "NEW USER OFFER"
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      'NEW USER OFFER', // نص الشارة
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text( // نص العرض الرئيسي
                    'Get 30% Off',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text( // نص العرض الفرعي
                    'On your first booking with us',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding( // أيقونة الهدية على اليمين
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.card_giftcard, color: Colors.white.withOpacity(0.5), size: 50),
            ),
          ],
        ),
      ),
    );
  }
}