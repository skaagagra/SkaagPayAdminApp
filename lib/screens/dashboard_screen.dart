import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'topup_screen.dart';
import 'recharge_screen.dart';
import 'users_screen.dart';
import 'plans_screen.dart';
import 'app_update_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    try {
      final stats = await _apiService.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading stats: $e')));
      print('Dashboard Error: $e');
    }
  }

  void _logout() async {
    await _authService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(onPressed: _logout, icon: Icon(Icons.logout, color: Colors.white)),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadStats(),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_stats != null) ...[
                      _buildStatCard('Total Users', _stats!['total_users'].toString(), Colors.blue),
                      SizedBox(height: 16),
                      _buildStatCard('Pending TopUps', _stats!['pending_topups'].toString(), Colors.orange),
                      SizedBox(height: 16),
                      _buildStatCard('Today Recharges', _stats!['todays_recharges_count'].toString(), Colors.green),
                      SizedBox(height: 16),
                      _buildStatCard('Recharge Volume', '₹${_stats!['todays_recharges_sum']}', Colors.purple),
                    ],
                    SizedBox(height: 32),
                    Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'Manage Users',
                            Icons.people,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => UsersScreen())),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            'Manage TopUps',
                            Icons.account_balance_wallet,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => TopUpScreen())),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'View Recharges',
                            Icons.phonelink_ring,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => RechargeScreen())),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            'Manage Plans',
                            Icons.list_alt,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlansScreen())),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'Update App',
                            Icons.system_update,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => UploadUpdateScreen())),
                          ),
                        ),
                        SizedBox(width: 16),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                SizedBox(height: 8),
                Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(Icons.analytics, color: color),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue[900]),
            SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
