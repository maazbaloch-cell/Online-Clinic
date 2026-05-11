import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'doctor_model.dart';
import 'notifications.dart'; // Added notifications import

class BillingScreen extends StatefulWidget {
  final String patientName;
  const BillingScreen({super.key, required this.patientName});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _checkupFeeCtrl = TextEditingController(text: "50");
  final TextEditingController _medicineFeeCtrl = TextEditingController();
  final TextEditingController _deliveryFeeCtrl = TextEditingController(text: "10");
  final TextEditingController _notesCtrl = TextEditingController();

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(15.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6CDF).withValues(alpha: 0.1),
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

  void _submitBill() {
    if (_formKey.currentState!.validate()) {
      final challan = Challan(
        patientName: widget.patientName,
        consultationFee: double.parse(_checkupFeeCtrl.text),
        medicineFee: double.parse(_medicineFeeCtrl.text),
        deliveryFee: double.parse(_deliveryFeeCtrl.text),
        notes: _notesCtrl.text,
      );

      // Add actual notification to the system
      NotificationModel.addNotification(
        title: "New Bill Generated",
        body: "Doctor has sent you a bill for \$${challan.consultationFee + challan.medicineFee + challan.deliveryFee}. Please proceed to pay.",
        type: "payment",
        data: challan, // Passing challan object so notification can open it
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bill sent and Patient Notified!")),
      );
      
      context.go('/doctor-dashboard');
    }
  }
}
