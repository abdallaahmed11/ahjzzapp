class TopRatedProvider {
  final String id;
  final String name;
  final double rating;
  final int reviews;
  final String category;
  final String price;
  final String image; // <-- 1. إضافة حقل الصورة هنا

  TopRatedProvider({
    required this.id,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.category,
    required this.price,
    required this.image, // <-- 2. إضافته للـ constructor
  });
}