import 'package:cloud_firestore/cloud_firestore.dart'; // مكتبة Firestore
import 'package:flutter/material.dart'; // عشان الـ Icons والألوان في الموديل الوهمي
import 'package:ahjizzzapp/models/quick_category.dart'; // الموديل اللي هنرجع بيه

class DbService {
  // إنشاء "مرجع" (reference) لمجموعة (collection) الفئات في Firestore
  // هنسمي المجموعة دي 'categories' على موقع Firestore
  final CollectionReference _categoriesCollection =
  FirebaseFirestore.instance.collection('categories');

  // --- دوال جلب البيانات ---

  // دالة لجلب قائمة الفئات
  Future<List<QuickCategory>> getCategories() async {
    try {
      // TODO: (الكود الحقيقي لجلب البيانات من Firestore)
      // QuerySnapshot snapshot = await _categoriesCollection.orderBy('name').get();
      // return snapshot.docs.map((doc) {
      //   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      //   // تحويل البيانات من Firestore للموديل بتاعنا
      //   return QuickCategory(
      //     id: doc.id,
      //     name: data['name'] ?? 'Unnamed', // اسم الفئة
      //     // (هتحتاج طريقة لتحويل اسم الأيقونة المخزن في Firestore إلى IconData)
      //     icon: _getIconFromString(data['iconName'] ?? 'default'),
      //     // (هتحتاج طريقة لتحويل كود اللون المخزن في Firestore إلى Color)
      //     color: _getColorFromString(data['colorCode'] ?? '#CCCCCC'),
      //   );
      // }).toList();

      // --- (بيانات وهمية مؤقتة بنفس شكل الفئات القديمة للتجربة) ---
      print("DbService: Fetching MOCK categories...");
      await Future.delayed(Duration(milliseconds: 800)); // محاكاة تحميل
      return [
        QuickCategory(id: "1", name: "Barbershop", icon: Icons.content_cut, color: Colors.blue.shade500),
        QuickCategory(id: "2", name: "Cleaning", icon: Icons.cleaning_services, color: Colors.purple.shade500),
        QuickCategory(id: "3", name: "Car Wash", icon: Icons.local_car_wash, color: Colors.pink.shade500),
        QuickCategory(id: "4", name: "Maintenance", icon: Icons.build, color: Colors.orange.shade500),
        QuickCategory(id: "5", name: "Beauty", icon: Icons.spa, color: Colors.pink.shade500),
      ];
      // -----------------------------------------------------------

    } catch (e) {
      print("Error fetching categories: $e");
      // إرجاع قائمة فارغة أو throw Exception حسب طريقة معالجة الأخطاء
      return [];
    }
  }

// (سنضيف دوال تانية هنا زي: getProvidersByCategory, getUserBookings, createBooking, ...)

// --- (دوال مساعدة وهمية مؤقتة) ---
// IconData _getIconFromString(String iconName) {
//   // (هنا هتحط if/else أو map لتحويل النص لأيقونة)
//   if (iconName == 'cut') return Icons.content_cut;
//   return Icons.category; // أيقونة افتراضية
// }
// Color _getColorFromString(String colorCode) {
//   // (هنا هتحول الـ hex code للون)
//   try {
//      return Color(int.parse(colorCode.substring(1, 7), radix: 16) + 0xFF000000);
//   } catch(e){
//      return Colors.grey; // لون افتراضي
//   }
// }
// ------------------------------------
}