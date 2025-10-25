import 'package:flutter/material.dart';

// هذا هو الويدجت الموحد للنجوم
class StarRating extends StatelessWidget {
  final double rating;                  // التقييم الحالي (عدد النجوم)
  final ValueChanged<double>? onRatingChanged; // دالة عند الضغط (اختيارية)
  final int starCount;                  // إجمالي عدد النجوم (عادة 5)
  final Color color;                    // لون النجمة
  final double size;                    // حجم الأيقونة

  StarRating({
    this.starCount = 5,
    this.rating = 0.0,
    this.onRatingChanged, // اختياري (لو مش موجود، يبقى للعرض فقط)
    this.color = Colors.amber,
    this.size = 24.0,     // حجم افتراضي
  });

  // دالة بناء النجمة الواحدة
  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(Icons.star_border, color: Colors.grey[400], size: size);
    } else if (index > rating - 1 && index < rating) {
      icon = Icon(Icons.star_half, color: color, size: size);
    } else {
      icon = Icon(Icons.star, color: color, size: size);
    }

    // إذا كانت onRatingChanged موجودة (يعني للتقييم)، اجعلها قابلة للضغط
    if (onRatingChanged != null) {
      return InkResponse(
        onTap: () => onRatingChanged!(index + 1.0), // إرسال التقييم الجديد
        child: icon,
      );
    }

    // إذا كانت onRatingChanged غير موجودة، اعرض الأيقونة فقط
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) => buildStar(context, index)),
    );
  }
}