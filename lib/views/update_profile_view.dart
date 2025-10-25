import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/update_profile_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';

class UpdateProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // (الـ ViewModel تم توفيره في main.dart)
    final viewModel = context.watch<UpdateProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: kLightBackgroundColor,
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryColor)) // تحميل أول مرة
          : SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- حقل الإيميل (للقراءة فقط) ---
            _buildTextField(
              // استخدام controller مؤقت لعرض الإيميل فقط
              controller: TextEditingController(text: viewModel.userEmail),
              label: 'Email Address',
              hint: '',
              icon: Icons.email_outlined,
              enabled: false, // <-- جعله غير قابل للتعديل
            ),
            SizedBox(height: 20),

            // --- حقل الاسم ---
            _buildTextField(
              controller: viewModel.nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
            ),
            SizedBox(height: 20),

            // --- حقل الهاتف ---
            _buildTextField(
              controller: viewModel.phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),

            // --- حقل المدينة ---
            _buildTextField(
              controller: viewModel.cityController,
              label: 'City',
              hint: 'Enter your city (e.g., Cairo)',
              icon: Icons.location_city_outlined,
            ),
            SizedBox(height: 20),

            // --- حقل النبذة ---
            _buildTextField(
              controller: viewModel.bioController,
              label: 'Bio / About Me',
              hint: 'Tell us something about yourself...',
              icon: Icons.edit_outlined,
              maxLines: 3, // جعله متعدد الأسطر
            ),
            SizedBox(height: 30),

            // عرض رسالة الخطأ
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),

            // زر الحفظ
            ElevatedButton(
              // استخدام isSaving للتحميل عند الحفظ
              onPressed: viewModel.isSaving
                  ? null
                  : () async {
                bool success = await viewModel.saveChanges();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated successfully!')),
                  );
                  // إرجاع 'true' لإعلام شاشة Profile بالتحديث
                  Navigator.of(context).pop(true);
                }
              },
              child: viewModel.isSaving
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // (ويدجت مساعد لحقل النص - مُعدل ليقبل maxLines و enabled)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true, // <-- إضافة بارامتر enabled
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines, // تحديد عدد الأسطر
          enabled: enabled,   // تحديد إذا كان قابل للتعديل
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100], // لون مختلف إذا كان معطل
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: kPrimaryColor, width: 2),
            ),
            disabledBorder: OutlineInputBorder( // شكل الحقل وهو معطل
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }
}