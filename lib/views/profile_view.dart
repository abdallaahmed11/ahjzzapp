import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/profile_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
// (لا نحتاج استيراد UpdateProfileView هنا لأننا سنستخدم المسار /update-profile)

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // استخدام .watch للاستماع للتغييرات (مثل تحديث الاسم)
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: kLightBackgroundColor,

      // **** 1. إصلاح الـ Overflow ****
      // تغليف الـ AppBar بـ PreferredSize لتحديد ارتفاعه
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // <-- تحديد الارتفاع المناسب (جرب 80 أو 90)
        child: AppBar(
          backgroundColor: kPrimaryColor,
          automaticallyImplyLeading: false,
          elevation: 0,
          // (استخدام FlexibleSpaceBar لضمان عدم تغطية الساعة)
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // دائرة الأحرف الأولى
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(
                      viewModel.userName.isNotEmpty && viewModel.userName != "Loading..."
                          ? viewModel.userName.substring(0, 2).toUpperCase()
                          : '??',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  SizedBox(width: 16),
                  // الاسم والإيميل
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.userName, // عرض الاسم الحقيقي
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        viewModel.userEmail, // عرض الإيميل الحقيقي
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
      // *******************************

      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20),
        children: [
          // --- قسم الحساب (Account) ---
          _buildSectionTitle('Account'),
          _buildProfileOptionCard(
            icon: Icons.person_outline,
            title: 'Update Profile',
            // **** 2. إصلاح تحديث الاسم ****
            // تحويل onTap إلى async وانتظار النتيجة
            onTap: () async {
              // الانتقال لشاشة التعديل وانتظارها
              final result = await Navigator.of(context).pushNamed('/update-profile');

              // إذا رجعت الشاشة بـ "true" (يعني الحفظ نجح)
              if (result == true && context.mounted) {
                // اطلب من الـ ViewModel تحديث البيانات (جلب الاسم الجديد)
                print("ProfileView: Refreshing profile data after update...");
                context.read<ProfileViewModel>().loadUserProfile();
              }
            },
            // ****************************
          ),
          _buildProfileOptionCard(
            icon: Icons.payment,
            title: 'Payment Methods',
            onTap: () { /* TODO: Navigate to Payment Methods screen */ },
          ),

          // --- (باقي الأقسام: Preferences, Support, Logout - كما هي) ---
          _buildSectionTitle('Preferences'),
          _buildNotificationToggle(viewModel),
          _buildLanguageSelector(viewModel),

          _buildSectionTitle('Support'),
          _buildProfileOptionCard(
            icon: Icons.help_outline,
            title: 'Help Center',
            onTap: () { /* TODO: Navigate to Help Center screen */ },
          ),
          _buildProfileOptionCard(
            icon: Icons.support_agent,
            title: 'Contact Support',
            onTap: () { /* TODO: Navigate to Contact Support screen */ },
          ),

          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton.icon(
              onPressed: () async {
                await viewModel.logout();
                // (الـ AuthWrapper في main.dart سيتكفل بالرجوع لشاشة اللوجين)
              },
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text('Logout', style: TextStyle(color: Colors.red)),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- (كل الدوال المساعدة كما هي) ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildProfileOptionCard({required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(icon, color: Colors.grey[700]),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(Icons.notifications_none, color: Colors.grey[700]),
          title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
          trailing: Switch(
            value: viewModel.notificationsEnabled,
            onChanged: (value) => viewModel.toggleNotifications(value),
            activeColor: kPrimaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(ProfileViewModel viewModel) {
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
                  Text('Language', style: TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageButton(viewModel, 'English'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildLanguageButton(viewModel, 'العربية'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(ProfileViewModel viewModel, String language) {
    bool isSelected = viewModel.selectedLanguage == language;
    return OutlinedButton(
      onPressed: () => viewModel.changeLanguage(language),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? kPrimaryColor : Colors.white,
        foregroundColor: isSelected ? Colors.white : kPrimaryColor,
        side: BorderSide(color: isSelected ? kPrimaryColor : Colors.grey[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(language),
    );
  }
}