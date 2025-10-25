import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// استيراد الـ ViewModel (اللي جواه الموديل بتاع الخدمة)
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart';
import 'package:ahjizzzapp/models/service_provider.dart'; // الموديل الأساسي
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/services/db_service.dart'; // <-- استيراد DbService

class ProviderDetailsView extends StatelessWidget {
  // استقبال بيانات المزود الأساسية من الشاشة السابقة
  final ServiceProvider provider;

  const ProviderDetailsView({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // توفير الـ ViewModel لهذه الشاشة وتمرير DbService والمزود له
    return ChangeNotifierProvider(
      create: (ctx) => ProviderDetailsViewModel(
        ctx.read<DbService>(), // قراءة الخدمة من الـ context
        provider,              // تمرير المزود
      ),
      child: Consumer<ProviderDetailsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            // استخدام CustomScrollView لعمل تأثير الـ AppBar القابل للطي
            body: CustomScrollView(
              slivers: <Widget>[
                // 1. الـ AppBar مع الصورة
                SliverAppBar(
                  expandedHeight: 250.0, // ارتفاع الصورة
                  floating: false,
                  pinned: true, // تثبيت الـ AppBar في الأعلى عند السكرول
                  backgroundColor: kPrimaryColor, // لون الخلفية خلف الصورة
                  leading: IconButton( // زر الرجوع
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar( // الجزء المرن
                    title: Text( // عنوان المزود
                      viewModel.provider.name,
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    titlePadding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                    background: Image.network( // صورة المزود
                      viewModel.provider.image.isNotEmpty ? viewModel.provider.image : "https://via.placeholder.com/400x250?text=No+Image",
                      fit: BoxFit.cover,
                      // إضافة تعتيم بسيط للصورة لتحسين قراءة النص
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                      // إظهار أيقونة بديلة في حالة فشل تحميل الصورة
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[400],
                        child: Center(child: Icon(Icons.storefront, color: Colors.grey[600], size: 50)),
                      ),
                    ),
                  ),
                ),

                // 2. المحتوى الرئيسي (تفاصيل المزود وقائمة الخدمات)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المزود (بخط كبير) وتفاصيل التقييم/الموقع
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
                              viewModel.provider.rating.toStringAsFixed(1), // تقييم
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 16),
                            SizedBox(width: 4),
                            Text(
                              viewModel.provider.distance, // مسافة
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // بيانات وهمية مؤقتة لساعات العمل
                        Text(
                          "Working Hours: 9:00 AM - 10:00 PM (Example)",
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                        Divider(height: 32), // خط فاصل

                        // --- قسم قائمة الخدمات ---
                        Text(
                          'Select Service',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),

                        // عرض مؤشر التحميل أو رسالة الخطأ أو قائمة الخدمات
                        _buildServiceContent(context, viewModel),
                        // ------------------------
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // 3. زر المتابعة (يظهر فقط عند اختيار خدمة)
            bottomNavigationBar: viewModel.selectedService != null
                ? Padding(
              padding: const EdgeInsets.all(16.0), // هوامش حول الزر
              child: ElevatedButton(
                onPressed: () => viewModel.proceedToBooking(context), // استدعاء دالة المتابعة
                style: ElevatedButton.styleFrom(
                  // (يستخدم الـ style من الـ Theme في main.dart)
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  // عرض سعر الخدمة المختارة على الزر
                  'Proceed to Book (${viewModel.selectedService!.price})',
                ),
              ),
            )
                : null, // إخفاء الزر إذا لم يتم اختيار خدمة
          );
        },
      ),
    );
  }

  // --- دالة مساعدة لعرض محتوى قائمة الخدمات ---
  Widget _buildServiceContent(BuildContext context, ProviderDetailsViewModel viewModel) {
    if (viewModel.isLoading) {
      // 1. عرض مؤشر تحميل
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(color: kPrimaryColor),
          ));
    }

    if (viewModel.errorMessage != null) {
      // 2. عرض رسالة الخطأ
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            viewModel.errorMessage!,
            style: TextStyle(color: Colors.red[700]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (viewModel.services.isEmpty) {
      // 3. عرض رسالة إذا كانت القائمة فارغة
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No specific services listed for this provider.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ));
    }

    // 4. عرض قائمة الخدمات
    return ListView.builder(
      shrinkWrap: true, // ضروري داخل CustomScrollView
      physics: NeverScrollableScrollPhysics(), // ليعتمد على السكرول الخارجي
      itemCount: viewModel.services.length,
      itemBuilder: (context, index) {
        final ProviderServiceModel service = viewModel.services[index];
        final bool isSelected = viewModel.selectedService?.id == service.id;

        // كرت الخدمة القابل للاختيار
        return Card(
          elevation: isSelected ? 3 : 1, // تمييز العنصر المختار
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            // تغيير لون الإطار عند الاختيار
            side: BorderSide(
              color: isSelected ? kPrimaryColor : Colors.grey[300]!,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            title: Text(service.name, style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text("${service.duration} • ${service.price}"), // عرض المدة والسعر
            // إظهار أيقونة الاختيار
            trailing: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? kPrimaryColor : Colors.grey[400],
            ),
            onTap: () => viewModel.selectService(service), // استدعاء دالة الاختيار
          ),
        );
      },
    );
  }
// ------------------------------------
}