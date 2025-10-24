import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/login_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';

class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 1. ربط الواجهة بالـ ViewModel
    // "Consumer" يعيد بناء الـ Widget عند استدعاء "notifyListeners()"
    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: kLightBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(), // [cite: 30]
                  SizedBox(height: 32),

                  Text(
                    'Welcome Back!', // [cite: 31]
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Login to continue booking services', // [cite: 32]
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 40),

                  // ربط الـ TextFields بالـ ViewModel
                  _buildTextField(
                    controller: viewModel.emailController,
                    label: 'Email', // [cite: 33]
                    hint: 'your.email@example.com', // [cite: 34]
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    controller: viewModel.passwordController,
                    label: 'Password', // [cite: 35]
                    hint: 'Enter your password', // [cite: 36]
                    isPassword: true,
                  ),
                  SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/reset-password');
                      },
                      child: Text(
                        'Forgot Password?', // [cite: 38]
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // إظهار رسالة الخطأ إذا وجدت
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  // زر تسجيل الدخول
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                      // استدعاء اللوجيك من الـ ViewModel
                      bool success = await viewModel.login();
                      if (success && context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/dashboard');
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
                    // إظهار التحميل أو النص
                    child: viewModel.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Login', // [cite: 37]
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?", style: TextStyle(color: Colors.grey[600])), // [cite: 39]
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/signup');
                        },
                        child: Text(
                          'Sign Up', // [cite: 39]
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

  // --- (Widgets مساعدة كما هي) ---

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
          'Ahjiz', // [cite: 30]
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
            // (يمكنك إضافة باقي خصائص الـ border)
          ),
        ),
      ],
    );
  }
}