import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'doctor_model.dart';
import 'models/Patient_model.dart';

class PaymentPage extends StatefulWidget {
  final Doctor doctor;
  final Challan? challan; // Added optional challan parameter

  const PaymentPage({super.key, required this.doctor, this.challan});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedWallet = 'Google Pay';
  String walletIcon = 'https://cdn-icons-png.flaticon.com/512/6124/6124998.png';

  // Fallback default fees if no challan is provided
  late double checkupFee;
  late double medicineFee;
  late double deliveryFee;

  @override
  void initState() {
    super.initState();
    // Initialize fees from challan or use defaults
    checkupFee = widget.challan?.consultationFee ?? 50.0;
    medicineFee = widget.challan?.medicineFee ?? 0.0;
    deliveryFee = widget.challan?.deliveryFee ?? 0.0;
  }

  // Default Patient for Testing
  final PatientModel defaultPatient = PatientModel(
    name: "Faizan Ansari",
    age: 24,
    email: "faizan@example.com",
    city: "Karachi",
    password: "",
    cnic: "42101-XXXXXXX-X",
    gender: "Male",
    address: "Street 12, DHA Phase 6",
    imagePath: null,
  );

  @override
  Widget build(BuildContext context) {
    double total = checkupFee + medicineFee + deliveryFee;
    String liveDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Checkout",
          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info Section (Top)
            Text("Patient Information", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F2E))),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFF2D6CDF),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF2D6CDF).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: const NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.challan?.patientName ?? defaultPatient.name, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(height: 4.h),
                        Text("${defaultPatient.age} Years • ${defaultPatient.gender}", style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.9))),
                        Text(defaultPatient.city, style: TextStyle(fontSize: 12.sp, color: Colors.white.withValues(alpha: 0.9))),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_user_rounded, color: Colors.white, size: 24.sp),
                ],
              ),
            ),
            
            SizedBox(height: 25.h),

            // Appointment & Doctor Section
            Text("Doctor & Schedule", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F2E))),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(15.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.r),
                        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 25.r,
                          backgroundImage: (widget.doctor.imagePath != null && widget.doctor.imagePath!.isNotEmpty)
                              ? (kIsWeb ? NetworkImage(widget.doctor.imagePath!) : FileImage(File(widget.doctor.imagePath!)) as ImageProvider)
                              : (widget.doctor.networkImageUrl != null ? NetworkImage(widget.doctor.networkImageUrl!) : const NetworkImage('https://via.placeholder.com/150')),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.doctor.fullName, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                            Text(widget.doctor.specialty, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF2D6CDF)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Colors.grey.shade200),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 18.sp, color: const Color(0xFF2D6CDF)),
                      SizedBox(width: 8.w),
                      Text(liveDate, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 25.h),

            // Bill Details Section
            Text("Bill Summary", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F2E))),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildBillRow("Consultation Fee", "\$ $checkupFee"),
                  SizedBox(height: 12.h),
                  _buildBillRow("Medicine Charges", "\$ $medicineFee"),
                  SizedBox(height: 12.h),
                  _buildBillRow("Delivery Charges", "\$ $deliveryFee"),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    child: Divider(color: Colors.grey.shade100, thickness: 1.5),
                  ),
                  _buildBillRow("Total Payable", "\$ $total", isTotal: true),
                ],
              ),
            ),

            SizedBox(height: 25.h),

            // Payment Method Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Payment Method", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F2E))),
                TextButton(
                  onPressed: _showWalletSelection,
                  child: Text("Change", style: TextStyle(color: const Color(0xFF2D6CDF), fontSize: 13.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(color: const Color(0xFF2D6CDF).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Image.network(walletIcon, width: 35.w, height: 35.h, errorBuilder: (c,e,s) => Icon(Icons.wallet, color: const Color(0xFF2D6CDF))),
                  SizedBox(width: 15.w),
                  Text(selectedWallet, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F1F2E))),
                  const Spacer(),
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF2D6CDF)),
                ],
              ),
            ),

            if (widget.challan?.notes != null && widget.challan!.notes.isNotEmpty) ...[
              SizedBox(height: 25.h),
              Text("Doctor Notes", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1F1F2E))),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15.r),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Text(
                  widget.challan!.notes,
                  style: TextStyle(fontSize: 13.sp, color: Colors.brown[800], fontStyle: FontStyle.italic),
                ),
              ),
            ],

            SizedBox(height: 40.h),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6CDF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 5,
                  shadowColor: const Color(0xFF2D6CDF).withValues(alpha: 0.4),
                ),
                onPressed: () {
                   _showSuccessDialog();
                },
                child: Text("Confirm & Pay \$ $total", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16.sp : 14.sp, color: isTotal ? Colors.black : Colors.grey[600], fontWeight: isTotal ? FontWeight.bold : FontWeight.w500)),
        Text(amount, style: TextStyle(fontSize: isTotal ? 16.sp : 14.sp, color: isTotal ? const Color(0xFF2D6CDF) : Colors.black, fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold)),
      ],
    );
  }

  void _showWalletSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Container(
          padding: EdgeInsets.all(25.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50.w, height: 5.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              SizedBox(height: 25.h),
              Text("Select Payment Method", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F1F2E))),
              SizedBox(height: 20.h),
              _walletOption(sheetContext, "Visa Card", "https://cdn-icons-png.flaticon.com/512/349/349221.png"),
              _walletOption(sheetContext, "PayPal", "https://cdn-icons-png.flaticon.com/512/174/174861.png"),
              _walletOption(sheetContext, "Google Pay", "https://cdn-icons-png.flaticon.com/512/6124/6124998.png"),
              _walletOption(sheetContext, "Apple Pay", "https://cdn-icons-png.flaticon.com/512/5968/5968412.png"),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  Widget _walletOption(BuildContext sheetContext, String name, String icon) {
    bool isSelected = selectedWallet == name;
    return GestureDetector(
      onTap: () {
        Navigator.pop(sheetContext);
        setState(() {
          selectedWallet = name;
          walletIcon = icon;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D6CDF).withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: isSelected ? const Color(0xFF2D6CDF) : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Image.network(icon, width: 32.w, errorBuilder: (c,e,s) => const Icon(Icons.payment)),
            SizedBox(width: 15.w),
            Text(name, style: TextStyle(fontSize: 15.sp, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? const Color(0xFF2D6CDF) : Colors.black87)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle_rounded, color: const Color(0xFF2D6CDF), size: 22.sp),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 80),
            SizedBox(height: 20.h),
            Text("Payment Successful!", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            const Text("Your appointment has been booked.", textAlign: TextAlign.center),
            SizedBox(height: 25.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6CDF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/dashboard');
                },
                child: const Text("Go to Dashboard", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
