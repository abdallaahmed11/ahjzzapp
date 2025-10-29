import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/add_provider_viewmodel.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';

class AddProviderView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddProviderViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Provider'),
        leading: IconButton(
          icon: Icon(Icons.close), // زر إغلاق
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: kLightBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: viewModel.nameController,
              label: 'Provider Name',
              hint: 'e.g., Sam\'s Barbershop',
              icon: Icons.storefront,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: viewModel.categoryController,
              label: 'Category',
              hint: 'e.g., Barbershop',
              icon: Icons.category_outlined,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: viewModel.cityController,
              label: 'City',
              hint: 'e.g., Cairo',
              icon: Icons.location_city_outlined,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: viewModel.imageUrlController,
              label: 'Image URL',
              hint: 'https://...',
              icon: Icons.image_outlined,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: viewModel.priceIndicatorController,
              label: 'Price Indicator',
              hint: 'e.g., \$25', // <-- تم إضافة \
              icon: Icons.attach_money,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: viewModel.distanceController,
              label: 'Distance',
              hint: 'e.g., 1.2 km away',
              icon: Icons.map_outlined,
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
              onPressed: viewModel.isSaving
                  ? null
                  : () async {
                bool success = await viewModel.saveProvider();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Provider added successfully!')),
                  );
                  Navigator.of(context).pop(); // إغلاق الشاشة بعد الحفظ
                }
              },
              child: viewModel.isSaving
                  ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Save Provider'),
            ),
          ],
        ),
      ),
    );
  }

  // (ويدجت مساعد لحقل النص - مُعدل ليقبل icon)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
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
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }
}