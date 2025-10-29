import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ahjizzzapp/viewmodels/manage_services_viewmodel.dart';
import 'package:ahjizzzapp/services/db_service.dart';
import 'package:ahjizzzapp/shared/app_colors.dart';
import 'package:ahjizzzapp/viewmodels/provider_details_viewmodel.dart'; // (عشان موديل الخدمة)

class ManageServicesView extends StatelessWidget {
  final String providerId;
  final String providerName;

  const ManageServicesView({
    Key? key,
    required this.providerId,
    required this.providerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // توفير الـ ViewModel للشاشة دي
    return ChangeNotifierProvider(
      create: (ctx) => ManageServicesViewModel(
        ctx.read<DbService>(),
        providerId,
      ),
      child: Consumer<ManageServicesViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Manage Services'),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20.0),
                child: Text(
                  providerName, // اسم المزود
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            backgroundColor: kLightBackgroundColor,
            body: Column(
              children: [
                // 1. قائمة الخدمات الحالية
                Expanded(
                  child: viewModel.isLoading && viewModel.services.isEmpty
                      ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
                      : viewModel.services.isEmpty
                      ? Center(child: Text('No services added yet.'))
                      : ListView.builder(
                    itemCount: viewModel.services.length,
                    itemBuilder: (ctx, index) {
                      final service = viewModel.services[index];
                      return ListTile(
                        title: Text(service.name),
                        subtitle: Text("${service.duration} • ${service.price}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            // تأكيد الحذف
                            _showDeleteConfirmDialog(context, viewModel, service);
                          },
                        ),
                        // (يمكن إضافة زر تعديل هنا لاحقًا)
                      );
                    },
                  ),
                ),
                // 2. فورم إضافة خدمة جديدة
                _buildAddServiceForm(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  // فورم الإضافة
  Widget _buildAddServiceForm(BuildContext context, ManageServicesViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
        ],
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Add New Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          _buildTextField(viewModel.nameController, 'Service Name (e.g., Men\'s Haircut)'),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTextField(viewModel.priceController, 'Price (e.g., \$25)'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildTextField(viewModel.durationController, 'Duration (e.g., 30 min)'),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (viewModel.errorMessage != null)
            Text(viewModel.errorMessage!, style: TextStyle(color: Colors.red, fontSize: 12)),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add Service'),
            onPressed: viewModel.isLoading ? null : viewModel.addService,
          ),
        ],
      ),
    );
  }

  // حقل نصي مساعد
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  // رسالة تأكيد الحذف
  void _showDeleteConfirmDialog(BuildContext context, ManageServicesViewModel viewModel, ProviderServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Service?'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              viewModel.deleteService(service.id);
            },
          ),
        ],
      ),
    );
  }
}