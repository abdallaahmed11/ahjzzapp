import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/profile_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. ربط الواجهة بالـ ViewModel باستخدام Consumer
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: kLightBackgroundColor,
          appBar: AppBar(
            // الشريط العلوي الأخضر
            backgroundColor: kPrimaryColor,
            elevation: 0,
            title: Row(
              children: [
                // دائرة الأحرف الأولى
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Text(
                    // (لأخذ أول حرفين من الاسم)
                    viewModel.userName.isNotEmpty ? viewModel.userName.substring(0, 2).toUpperCase() : '??', //
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                SizedBox(width: 16),
                // الاسم والإيميل
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.userName, //
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      viewModel.userEmail, //
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(vertical: 20),
            children: [
              // --- قسم الحساب (Account) ---
              _buildSectionTitle('Account'), //
              _buildProfileOptionCard(
                icon: Icons.person_outline,
                title: 'Update Profile', //
                onTap: () { /* TODO: Navigate to Update Profile screen */ },
              ),
              _buildProfileOptionCard(
                icon: Icons.payment,
                title: 'Payment Methods', //
                onTap: () { /* TODO: Navigate to Payment Methods screen */ },
              ),

              // --- قسم التفضيلات (Preferences) ---
              _buildSectionTitle('Preferences'), //
              _buildNotificationToggle(viewModel), //
              _buildLanguageSelector(viewModel), //

              // --- قسم الدعم (Support) ---
              _buildSectionTitle('Support'), //
              _buildProfileOptionCard(
                icon: Icons.help_outline,
                title: 'Help Center', //
                onTap: () { /* TODO: Navigate to Help Center screen */ },
              ),
              _buildProfileOptionCard(
                icon: Icons.support_agent,
                title: 'Contact Support', //
                onTap: () { /* TODO: Navigate to Contact Support screen */ },
              ),

              // --- زر تسجيل الخروج ---
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton.icon(
                  onPressed: () async {
                    await viewModel.logout();
                    // (بعد الخروج بنجاح، العودة لشاشة اللوجين)
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  },
                  icon: Icon(Icons.logout, color: Colors.red),
                  label: Text('Logout', style: TextStyle(color: Colors.red)), //
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Widgets مساعدة ---

  // عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
      ),
    );
  }

  // كرت خيارات البروفايل (مثل Update Profile)
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
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]), //
          onTap: onTap,
        ),
      ),
    );
  }

  // خيار الإشعارات (مع زر التبديل)
  Widget _buildNotificationToggle(ProfileViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(Icons.notifications_none, color: Colors.grey[700]),
          title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.w500)), //
          trailing: Switch(
            value: viewModel.notificationsEnabled,
            onChanged: (value) => viewModel.toggleNotifications(value),
            activeColor: kPrimaryColor,
          ),
        ),
      ),
    );
  }

  // خيار اختيار اللغة
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
                  Text('Language', style: TextStyle(fontWeight: FontWeight.w500)), //
                ],
              ),
              SizedBox(height: 8),
              // أزرار اختيار اللغة (Toggle Buttons)
              Row(
                children: [
                  Expanded(
                    child: _buildLanguageButton(viewModel, 'English'), //
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildLanguageButton(viewModel, 'العربية'), //
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // زر اختيار اللغة (جزء من Widget اختيار اللغة)
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