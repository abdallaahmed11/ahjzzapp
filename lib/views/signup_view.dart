import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/signup_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';

class SignUpView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. استخدام "Consumer" لمراقبة التغييرات في الـ ViewModel
    return Consumer<SignUpViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: kLightBackgroundColor,
          // زر الرجوع
          appBar: AppBar(
            backgroundColor: kLightBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(), //
                  SizedBox(height: 32),

                  Text(
                    'Create Account', // [cite: 12]
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign up to start booking services', // [cite: 13]
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 40),

                  _buildTextField(
                    controller: viewModel.nameController,
                    label: 'Full Name', // [cite: 14]
                    hint: 'Ahmed Hassan', // [cite: 15]
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: viewModel.emailController,
                    label: 'Email', // [cite: 16]
                    hint: 'your.email@example.com', // [cite: 17]
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: viewModel.passwordController,
                    label: 'Password', // [cite: 18]
                    hint: 'Create a password', // [cite: 19]
                    isPassword: true,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: viewModel.confirmPasswordController,
                    label: 'Confirm Password', // [cite: 20]
                    hint: 'Re-enter your password', // [cite: 21]
                    isPassword: true,
                  ),
                  SizedBox(height: 20),

                  // إظهار رسالة الخطأ
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  SizedBox(height: 10),

                  // زر إنشاء الحساب
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                      bool success = await viewModel.signUp();
                      if (success && context.mounted) {
                        Navigator.of(context)
                            .pushReplacementNamed('/dashboard');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Create Account', // [cite: 22]
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 24),

                  // رابط تسجيل الدخول
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?", style: TextStyle(color: Colors.grey[600])), // [cite: 23]
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // الرجوع لصفحة اللوجين
                        },
                        child: Text(
                          'Login', // [cite: 23]
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- (نفس الـ Widgets المساعدة من شاشة Login) ---

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(Icons.content_cut, color: Colors.white, size: 40),
        ),
        SizedBox(height: 12),
        Text(
          'Ahjiz', // [cite: 11]
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        )
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
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
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
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
          ),
        ),
      ],
    );
  }
}