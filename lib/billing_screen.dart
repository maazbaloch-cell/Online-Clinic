import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'doctor_model.dart';
import 'services/notification_service.dart';

class BillingScreen extends StatefulWidget {
  final String patientName;
  final String? patientId;

  const BillingScreen({super.key, required this.patientName, this.patientId});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _checkupFeeCtrl = TextEditingController(text: "50");
  final TextEditingController _medicineFeeCtrl = TextEditingController();
  final TextEditingController _deliveryFeeCtrl = TextEditingController(text: "10");
  final TextEditingController _notesCtrl = TextEditingController();
  final _notificationService = NotificationService();
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Generate Bill",
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isSending 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6CDF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF2D6CDF)),
                    SizedBox(width: 10.w),
                    Text(
                      "Patient: ${widget.patientName}",
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2D6CDF)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
              Text("Consultation Fee (\$)", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              _buildTextField(_checkupFeeCtrl, "Enter amount", Icons.attach_money, isNumber: true),
              SizedBox(height: 20.h),
              Text("Medicine Charges (\$)", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              _buildTextField(_medicineFeeCtrl, "Enter amount", Icons.medication_liquid_rounded, isNumber: true),
              SizedBox(height: 20.h),
              Text("Delivery Charges (\$)", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              _buildTextField(_deliveryFeeCtrl, "Enter amount", Icons.local_shipping_rounded, isNumber: true),
              SizedBox(height: 20.h),
              Text("Prescription / Notes", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              _buildTextField(_notesCtrl, "Write medicines or advice here...", Icons.note_add_rounded, maxLines: 4),
              SizedBox(height: 40.h),
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6CDF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  ),
                  onPressed: _submitBill,
                  child: Text(
                    "Send Bill to Patient",
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF2D6CDF)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.r),
          borderSide: const BorderSide(color: Color(0xFF2D6CDF), width: 2),
        ),
      ),
      validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
    );
  }

  Future<void> _submitBill() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);
      
      final total = (double.tryParse(_checkupFeeCtrl.text) ?? 0) + 
                    (double.tryParse(_medicineFeeCtrl.text) ?? 0) + 
                    (double.tryParse(_deliveryFeeCtrl.text) ?? 0);

      try {
        if (widget.patientId != null) {
          await _notificationService.sendNotification(
            userId: widget.patientId!,
            title: "New Bill Received",
            body: "Doctor has sent you a bill of \$\$total. Please complete your payment.",
            type: "payment",
            data: {
              'patient_name': widget.patientName,
              'amount': total,
              'notes': _notesCtrl.text,
            },
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bill sent and Patient Notified!"), backgroundColor: Colors.green),
          );
          context.go('/doctor-dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e")));
        }
      } finally {
        if (mounted) setState(() => _isSending = false);
      }
    }
  }
}
