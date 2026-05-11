import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'doctor_model.dart';
import 'services/auth_service.dart';

class Dashboard extends StatefulWidget {
  final List<Doctor> doctors;

  const Dashboard({super.key, this.doctors = const []});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late List<Doctor> _doctors;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final _authService = AuthService();
  
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _doctors = widget.doctors.isEmpty ? CurrentDoctor.getDummyDoctors() : widget.doctors;
    _loadUserData();
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        final firstName = user.userMetadata?['first_name'] ?? "";
        final lastName = user.userMetadata?['last_name'] ?? "";
        _userName = "$firstName $lastName".trim();
        if (_userName.isEmpty) _userName = user.email?.split('@')[0] ?? "User";
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      context.go('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _doctors.where((doctor) {
      final matchesCategory = _selectedCategory == null || 
          doctor.specialty.toLowerCase() == _selectedCategory!.toLowerCase();
      final matchesSearch = doctor.fullName.toLowerCase().contains(_searchController.text.toLowerCase()) || 
          doctor.specialty.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    _buildSearchBar(),
                    SizedBox(height: 25.h),
                    _buildPromoCard(),
                    SizedBox(height: 25.h),
                    _buildSectionTitle("Specialties"),
                    SizedBox(height: 15.h),
                    _buildCategoryFilter(),
                    SizedBox(height: 25.h),
                    _buildSectionTitle("Nearby Doctors"),
                    SizedBox(height: 15.h),
                    _buildDoctorsGrid(filteredDoctors),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello', style: TextStyle(color: const Color(0xFF8A8A9D), fontSize: 15.sp, fontWeight: FontWeight.w600)),
              Text(_userName, style: TextStyle(color: const Color(0xFF1F1F2E).withValues(alpha: 0.8), fontSize: 20.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blue),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15.r), border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: const InputDecoration(hintText: 'Search Doctor or Specialty', border: InputBorder.none, prefixIcon: Icon(Icons.search, color: Colors.blue)),
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      height: 140.h,
      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20.r)),
      child: Stack(
        children: [
          Positioned(
            top: 40.h,
            left: 30.w,
            child: Text('Book and schedule with\nnearest doctors', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F1F2E))),
        Text('View All', style: TextStyle(fontSize: 14.sp, color: Colors.blue, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ["Dentist", "Allergist", "Cardiologist", "Surgeon"];
    return SizedBox(
      height: 45.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = val ? cat : null),
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.blue,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 12.sp),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorsGrid(List<Doctor> doctors) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10.h, crossAxisSpacing: 10.w, childAspectRatio: 0.7),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return GestureDetector(
          onTap: () => context.push('/doctor-detail', extra: doctor),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.r), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                    child: Image.network(
                      doctor.networkImageUrl ?? 'https://via.placeholder.com/150',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.person, color: Colors.grey, size: 40),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                      Text(doctor.specialty, style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 16.sp),
                          Text(" ${doctor.rating}", style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text("\$${doctor.fee}", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
