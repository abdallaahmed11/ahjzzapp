import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/rate_service_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/services/db_service.dart'; // <-- استيراد
import 'package:ahjizzzapp/services/auth_service.dart'; // <-- استيراد

// **** تعديل الدالة ****
// أصبحت تستقبل providerId أيضاً
void showRateServiceModal(BuildContext context, {
  required String bookingId,
  required String providerId, // <-- إضافة ID المزود
  required String providerName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // للسماح للنافذة بالارتفاع فوق الكيبورد
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // حواف دائرية
    ),
    builder: (_) {
      // **** تعديل الـ Provider ****
      // توفير الـ ViewModel مع تمرير الخدمات والبيانات اللازمة
      return ChangeNotifierProvider(
        create: (ctx) => RateServiceViewModel(
          dbService: ctx.read<DbService>(),     // تمرير DbService
          authService: ctx.read<AuthService>(), // تمرير AuthService
          bookingId: bookingId,
          providerId: providerId, // <-- تمرير ID المزود
          providerName: providerName,
        ),
        // الـ Widget الذي يعرض المحتوى
        child: RateServiceModalContent(),
      );
      // ----------------------------
    },
  );
}
// **********************

// المحتوى الفعلي للنافذة المنبثقة
class RateServiceModalContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // قراءة الـ ViewModel الذي تم توفيره في الأعلى
    final viewModel = Provider.of<RateServiceViewModel>(context);

    return Padding(
      // Padding يتفاعل مع الكيبورد
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // لجعل ارتفاع النافذة مناسباً للمحتوى
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. العنوان
          Text(
            'Rate Your Experience',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'How was your service at ${viewModel.providerName}?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),

          // 2. شريط النجوم
          Center(
            child: StarRating(
              rating: viewModel.rating,
              onRatingChanged: (rating) => viewModel.setRating(rating),
            ),
          ),
          SizedBox(height: 20),

          // 3. حقل كتابة التقييم
          TextField(
            controller: viewModel.reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your review (optional)...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: kPrimaryColor),
              ),
            ),
          ),
          SizedBox(height: 12),

          // 4. عرض رسالة الخطأ (إذا وجدت)
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),

          // 5. زر "Submit Review"
          ElevatedButton(
            onPressed: viewModel.isLoading
                ? null // تعطيل الزر أثناء التحميل
                : () async {
              // استدعاء دالة حفظ التقييم من الـ ViewModel
              bool success = await viewModel.submitReview();
              if (success && context.mounted) {
                Navigator.of(context).pop(); // إغلاق الـ Modal عند النجاح
                // إظهار رسالة تأكيد للمستخدم
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thank you for your review!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              // (يستخدم الـ style من الـ Theme)
              padding: EdgeInsets.symmetric(vertical: 14),
            ),
            // إظهار مؤشر تحميل أو نص الزر
            child: viewModel.isLoading
                ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Submit Review', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(height: 20), // مسافة في الأسفل
        ],
      ),
    );
  }
}

// (Widget النجوم المساعد - كما هو)
class StarRating extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final int starCount;
  final Color color;

  StarRating({
    this.starCount = 5,
    this.rating = 0.0,
    required this.onRatingChanged,
    this.color = Colors.amber,
  });

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(Icons.star_border, color: Colors.grey[400]);
    } else if (index > rating - 1 && index < rating) {
      icon = Icon(Icons.star_half, color: color);
    } else {
      icon = Icon(Icons.star, color: color);
    }
    return InkResponse(
      onTap: () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) => buildStar(context, index)),
    );
  }
}