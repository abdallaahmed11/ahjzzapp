import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // لتهيئة التاريخ
import 'package:ahjizzzapp/viewmodels/reviews_viewmodel.dart'; // الـ ViewModel
import 'package:ahjizzzapp/models/review_model.dart';           // الموديل
import 'package:ahjizzzapp/shared/app_colors.dart';             // الألوان
// **** استيراد الويدجت الموحد الجديد ****
import 'package:ahjizzzapp/views/widgets/star_rating_widget.dart';

class ReviewsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // قراءة الـ ViewModel الذي تم توفيره في DashboardView
    final viewModel = context.watch<ReviewsViewModel>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // إخفاء زر الرجوع
        title: Text('My Reviews'), // عنوان الشاشة
        backgroundColor: kLightBackgroundColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black54),
            onPressed: viewModel.fetchUserReviews, // استدعاء دالة التحديث
          ),
        ],
      ),
      backgroundColor: kLightBackgroundColor,
      body: _buildBody(context, viewModel),
    );
  }

  // دالة بناء الجسم (Body)
  Widget _buildBody(BuildContext context, ReviewsViewModel viewModel) {
    if (viewModel.isLoading) {
      // 1. عرض مؤشر التحميل
      return Center(child: CircularProgressIndicator(color: kPrimaryColor));
    }

    if (viewModel.errorMessage != null) {
      // 2. عرض رسالة الخطأ
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 40),
              SizedBox(height: 10),
              Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: viewModel.fetchUserReviews, // زر إعادة المحاولة
                child: Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    if (viewModel.userReviews.isEmpty) {
      // 3. عرض رسالة إذا كانت القائمة فارغة
      return Center(
        child: Text(
          'You have not written any reviews yet.',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // 4. عرض قائمة التقييمات
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: viewModel.userReviews.length,
      itemBuilder: (context, index) {
        final review = viewModel.userReviews[index];
        return _buildReviewCard(context, review); // بناء كرت لكل تقييم
      },
    );
  }

  // --- Widget: كرت التقييم (لعرض تقييمات المستخدم) ---
  Widget _buildReviewCard(BuildContext context, ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
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
              Text(
                review.providerName, // عرض اسم المزود الذي تم تقييمه
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                DateFormat('d MMM yyyy').format(review.createdAt), // تاريخ التقييم
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 6),

          // **** السطر المُعدل (يستخدم الويدجت الجديد) ****
          // للعرض فقط (لا نمرر onRatingChanged)
          StarRating(
            rating: review.rating,
            size: 16, // تحديد الحجم
          ),
          // *******************************************

          SizedBox(height: 10),
          if (review.reviewText.isNotEmpty)
            Text(
              review.reviewText,
              style: TextStyle(color: Colors.black87, fontSize: 14, fontStyle: FontStyle.italic),
            )
          else
            Text(
              '(No comment left)',
              style: TextStyle(color: Colors.grey[500], fontSize: 14, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

// **** حذف تعريف StarRating القديم من هنا (إن وجد) ****
}