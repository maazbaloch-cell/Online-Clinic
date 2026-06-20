import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'doctor_model.dart';
import 'services/auth_service.dart';
import 'services/doctor_service.dart';
import 'Inbox_screen.dart';
import 'Patient_Appointments.dart';
import 'notifications.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  final _authService = AuthService();
  final _doctorService = DoctorService();
  
  String _userName = "User";
  String? _userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadUserData(),
      _fetchDoctors(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _fetchDoctors() async {
    try {
      final doctors = await _doctorService.getAllDoctors();
      setState(() {
        _doctors = doctors;
      });
    } catch (e) {
      debugPrint("Error fetching doctors: $e");
    }
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final res = await Supabase.instance.client
            .from('patients')
            .select('image_url')
            .eq('id', user.id)
            .maybeSingle();
        
        setState(() {
          final firstName = user.userMetadata?['first_name'] ?? "";
          final lastName = user.userMetadata?['last_name'] ?? "";
          _userName = "$firstName $lastName".trim();
          if (_userName.isEmpty) _userName = user.email?.split('@')[0] ?? "User";
          _userImageUrl = res?['image_url'];
        });
      } catch (e) {
        debugPrint("Error loading user image: $e");
      }
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
      body: RefreshIndicator(
        onRefresh: _fetchDoctors,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildSearchBar(),
                      SizedBox(height: 25.h),
                      _buildActionCards(),
                      SizedBox(height: 25.h),
                      _buildSectionTitle("Specialties"),
                      SizedBox(height: 15.h),
                      _buildCategoryFilter(),
                      SizedBox(height: 25.h),
                      _buildSectionTitle("Nearby Doctors"),
                      SizedBox(height: 15.h),
                      filteredDoctors.isEmpty 
                        ? Center(child: Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Text("No doctors found", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                          ))
                        : _buildDoctorsGrid(filteredDoctors),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundColor: Colors.blue[50],
                backgroundImage: _userImageUrl != null ? NetworkImage(_userImageUrl!) : null,
                child: _userImageUrl == null ? Icon(Icons.person, color: Colors.blue, size: 25.sp) : null,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello', style: TextStyle(color: const Color(0xFF8A8A9D), fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  Text(_userName, style: TextStyle(color: const Color(0xFF1F1F2E).withOpacity(0.8), fontSize: 18.sp, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.blue),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InboxScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.blue),
                onPressed: _logout,
              ),
            ],
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

  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PatientAppointmentsScreen())),
            child: Container(
              height: 100.h,
              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(20.r)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 30),
                    SizedBox(height: 8.h),
                    Text('My Bookings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Container(
            height: 100.h,
            decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(20.r)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.medical_services, color: Colors.blue, size: 30),
                  SizedBox(height: 8.h),
                  Text('Lab Tests', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ],
              ),
            ),
          ),
        ),
      ],
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                    child: doctor.networkImageUrl != null
                        ? Image.network(
                            doctor.networkImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.person, color: Colors.grey, size: 40)),
                          )
                        : Container(color: Colors.grey[200], child: const Icon(Icons.person, color: Colors.grey, size: 40)),
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
                          Text("Rs ${doctor.fee}", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12.sp)),
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
