import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/profile_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- 1. استيراد المكتبة

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // استخدام .watch للاستماع للتغييرات (مثل تحديث الاسم)
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: kLightBackgroundColor,

      // (الـ AppBar كما هو)
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: AppBar(
          backgroundColor: kPrimaryColor,
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Center(
                child: Row(
                  children: [
                    // (دائرة الأحرف الأولى)
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Text(
                        viewModel.userName.isNotEmpty && viewModel.userName != "Loading..."
                            ? viewModel.userName.substring(0, (viewModel.userName.length >= 2 ? 2 : 1)).toUpperCase()
                            : '??',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    SizedBox(width: 16),
                    // (الاسم والإيميل)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          viewModel.userName, // (ده متغير، مش هيترجم)
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          viewModel.userEmail, // (ده متغير، مش هيترجم)
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // **** 2. ترجمة الجسم (Body) ****
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20),
        children: [
          // --- قسم الحساب (Account) ---
          _buildSectionTitle(context, 'Account'), // (هنعدل الدالة دي)
          _buildProfileOptionCard(
            icon: Icons.person_outline,
            title: 'profile_update'.tr(), // "Update Profile"
            onTap: () async {
              final result = await Navigator.of(context).pushNamed('/update-profile');
              if (result == true && context.mounted) {
                context.read<ProfileViewModel>().loadUserProfile();
              }
            },
          ),
          _buildProfileOptionCard(
            icon: Icons.payment,
            title: 'profile_payments'.tr(), // "Payment Methods"
            onTap: () { /* TODO: Navigate */ },
          ),

          // --- قسم التفضيلات (Preferences) ---
          _buildSectionTitle(context, 'Preferences'),
          _buildNotificationToggle(viewModel),
          // **** 3. تعديل ويدجت اللغة ****
          _buildLanguageSelector(context, viewModel), // تمرير context
          // **************************

          // --- قسم الدعم (Support) ---
          _buildSectionTitle(context, 'Support'),
          _buildProfileOptionCard(
            icon: Icons.help_outline,
            title: 'profile_help'.tr(), // "Help Center"
            onTap: () { /* TODO: Navigate */ },
          ),
          _buildProfileOptionCard(
            icon: Icons.support_agent,
            title: 'profile_contact'.tr(), // "Contact Support"
            onTap: () { /* TODO: Navigate */ },
          ),

          // --- زر تسجيل الخروج ---
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: () async {
                await viewModel.logout();
                // (الـ AuthWrapper سيتكفل بالباقي)
              },
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text(
                  'profile_logout'.tr(), // "Logout"
                  style: TextStyle(color: Colors.red)
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
              ),
            ),
          ),
        ],
      ),
      // *******************************
    );
  }

  // --- (تعديل الدوال المساعدة) ---

  // (دالة عنوان القسم - معدلة عشان تقبل context لو احتجنا نترجم العنوان نفسه)
  Widget _buildSectionTitle(BuildContext context, String titleKey) {
    // (حالياً هنسيبها زي ما هي، بس جاهزة للترجمة لو ضفنا المفاتيح)
    // final String title = titleKey.tr();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        titleKey, // (هنفترض إن العناوين دي مش محتاجة ترجمة حالياً)
        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
      ),
    );
  }

  // (دالة كرت الخيارات - معدلة عشان تقبل عنوان مترجم جاهز)
  Widget _buildProfileOptionCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(icon, color: Colors.grey[700]),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)), // (النص جاي مترجم جاهز)
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: onTap,
        ),
      ),
    );
  }

  // (دالة زر الإشعارات - معدلة لترجمة النص)
  Widget _buildNotificationToggle(ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(Icons.notifications_none, color: Colors.grey[700]),
          title: Text(
              'profile_notifications'.tr(), // "Notifications"
              style: TextStyle(fontWeight: FontWeight.w500)
          ),
          trailing: Switch(
            value: viewModel.notificationsEnabled,
            onChanged: (value) => viewModel.toggleNotifications(value),
            activeColor: kPrimaryColor,
          ),
        ),
      ),
    );
  }

  // **** 4. تعديل ويدجت اختيار اللغة ****
  Widget _buildLanguageSelector(BuildContext context, ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.language, color: Colors.grey[700]),
                  SizedBox(width: 16),
                  Text(
                      'profile_language'.tr(), // "Language"
                      style: TextStyle(fontWeight: FontWeight.w500)
                  ),
                ],
              ),
              SizedBox(height: 8),
              // الأزرار الفعلية
              Row(
                children: [
                  Expanded(
                    // زر الإنجليزية
                    child: _buildLanguageButton(
                        context,
                        viewModel,
                        'English',
                        'en' // كود اللغة
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    // زر العربية
                    child: _buildLanguageButton(
                        context,
                        viewModel,
                        'العربية',
                        'ar' // كود اللغة
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (دالة زر اللغة - معدلة لتستدعي الدالة الجديدة)
  Widget _buildLanguageButton(BuildContext context, ProfileViewModel viewModel, String label, String languageCode) {
    // معرفة اللغة النشطة حالياً من المكتبة
    bool isSelected = context.locale.languageCode == languageCode;

    return OutlinedButton(
      // استدعاء الدالة الجديدة في الـ ViewModel وتمرير الكود 'ar' أو 'en'
      onPressed: () => viewModel.changeLanguage(context, languageCode),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? kPrimaryColor : Colors.white,
        foregroundColor: isSelected ? Colors.white : kPrimaryColor,
        side: BorderSide(color: isSelected ? kPrimaryColor : Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
// ****************************************
}