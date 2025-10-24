import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/reset_password_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';

class ResetPasswordView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ResetPasswordViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: kLightBackgroundColor,
          appBar: AppBar(
            backgroundColor: kLightBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Back to Login', // [cite: 24]
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(), //
                  SizedBox(height: 32),

                  Text(
                    'Reset Password', // [cite: 26]
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Enter your email address and we'll send you a link to reset your password.", // [cite: 27]
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 40),

                  _buildTextField(
                    controller: viewModel.emailController,
                    label: 'Email', // [cite: 28]
                    hint: 'your.email@example.com', // [cite: 29]
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),

                  // رسالة الخطأ أو النجاح
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  if (viewModel.success)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "Success! Please check your email for a reset link.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kPrimaryColor, fontSize: 14),
                      ),
                    ),

                  SizedBox(height: 10),

                  // زر الإرسال
                  ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () {
                      viewModel.sendResetLink();
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
                      'Send Reset Link', // [cite: 30]
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- (نفس الـ Widgets المساعدة) ---

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
          'Ahjiz', // [cite: 25]
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