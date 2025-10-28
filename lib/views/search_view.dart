import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/search_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/models/service_provider.dart';
// استيراد شاشة تفاصيل المزود (للانتقال إليها)
import 'package:ahjizzzapp/views/provider_details_view.dart';

class SearchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        // شريط البحث الحقيقي
        title: TextField(
          controller: null, // (الـ ViewModel هو اللي بيدير النص)
          autofocus: true, // فتح الكيبورد تلقائياً
          decoration: InputDecoration(
            hintText: 'Search for services or providers...',
            border: InputBorder.none, // بدون خط سفلي
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
          onChanged: (query) {
            // إرسال كل تغيير في النص للـ ViewModel
            viewModel.onSearchChanged(query);
          },
        ),
        backgroundColor: Colors.white, // خلفية بيضاء للـ AppBar
        elevation: 1,
        // زر مسح البحث (يظهر فقط إذا كان هناك نص)
        actions: [
          if (viewModel.query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey[700]),
              onPressed: () {
                // (سنحتاج لإضافة controller في الـ VM لمسح النص)
                // viewModel.clearSearch();
                // (الحل البديل حالياً هو استدعاء onSearchChanged بنص فارغ)
                viewModel.onSearchChanged('');
                // (لإخفاء الكيبورد - يتطلب controller)
              },
            )
        ],
      ),
      backgroundColor: kLightBackgroundColor,
      body: _buildBody(context, viewModel),
    );
  }

  // دالة بناء الجسم (Body)
  Widget _buildBody(BuildContext context, SearchViewModel viewModel) {
    if (viewModel.isLoading) {
      // 1. عرض مؤشر التحميل
      return Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (viewModel.query.isEmpty) {
      // 2. عرض رسالة افتراضية قبل البحث
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[300]),
            SizedBox(height: 10),
            Text('Find a service', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );
    }

    if (viewModel.results.isEmpty) {
      // 3. عرض رسالة إذا لم يتم العثور على نتائج
      return Center(
        child: Text(
          'No results found for "${viewModel.query}"',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // 4. عرض قائمة النتائج (سنستخدم نفس كرت "Top Rated" من HomeView)
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: viewModel.results.length,
      itemBuilder: (context, index) {
        final provider = viewModel.results[index];
        // (يمكنك استخدام كرت ServiceProvider العادي من ServiceListView أيضاً)
        return _buildProviderCard(context, provider);
      },
    );
  }

  // (استخدمنا نفس الكرت من ServiceListView لتوحيد الشكل)
  Widget _buildProviderCard(BuildContext context, ServiceProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // الانتقال لشاشة التفاصيل عند الضغط على النتيجة
          print("Navigating to details for provider: ${provider.name}");
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:(context) => ProviderDetailsView(provider: provider),
              settings: const RouteSettings(name: '/provider-details'),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              provider.image.isNotEmpty ? provider.image : "https://via.placeholder.com/300x150?text=No+Image",
              height: 150, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150, color: Colors.grey[200],
                child: Center(child: Icon(Icons.storefront, color: Colors.grey[500], size: 40)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            provider.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
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
                  Text(
                    "Starts from ${provider.price}",
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
}