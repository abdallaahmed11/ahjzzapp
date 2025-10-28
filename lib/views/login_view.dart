import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/login_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:easy_localization/easy_localization.dart'; // <-- 1. استيراد المكتبة

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLogo(context), // تمرير context للوجو
              SizedBox(height: 32),

              // **** 2. ترجمة النصوص ****
              Text(
                "login_title".tr(), // "Welcome Back!"
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "login_subtitle".tr(), // "Login to continue..."
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 40),

              // (الحقول)
              _buildTextField(
                controller: viewModel.emailController,
                label: "login_email_label".tr(), // "Email"
                hint: 'your.email@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: viewModel.passwordController,
                label: "login_password_label".tr(), // "Password"
                hint: 'Enter your password',
                isPassword: true,
              ),
              SizedBox(height: 12),

              // رابط "نسيت كلمة المرور"
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/reset-password'),
                  child: Text(
                    "login_forgot_password".tr(), // "Forgot Password?"
                    style: TextStyle(color: kPrimaryColor),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // زر تسجيل الدخول
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                  bool success = await viewModel.login();
                  if (success && context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  }
                },
                child: viewModel.isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  "login_button".tr(), // "Login"
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 24),

              // رابط إنشاء حساب
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("login_no_account".tr(), style: TextStyle(color: Colors.grey[600])), // "Don't have an account?"
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/signup'),
                    child: Text(
                      "login_signup".tr(), // "Sign Up"
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // ************************
            ],
          ),
        ),
      ),
    );
  }

  // (دالة اللوجو - مُعدلة لتترجم اسم التطبيق)
  Widget _buildLogo(BuildContext context) {
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
          "app_title".tr(), // <-- ترجمة اسم التطبيق
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        )
      ],
    );
  }

  // (دالة حقل النص - كما هي)
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
          label, // (النص هنا جاي مترجم جاهز)
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint, // (الهنت ممكن نترجمه برضه لو حابين)
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