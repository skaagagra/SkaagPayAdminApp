import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/recharge_request.dart';

class RechargeScreen extends StatefulWidget {
  @override
  _RechargeScreenState createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final ApiService _apiService = ApiService();
  List<RechargeRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getRechargeRequests();
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showStatusDialog(RechargeRequest req) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOption(req, 'SUCCESS', Colors.green),
              _buildStatusOption(req, 'FAILED', Colors.red),
              _buildStatusOption(req, 'PENDING', Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(RechargeRequest req, String status, Color color) {
    return ListTile(
      title: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      onTap: () async {
        Navigator.pop(context);
        bool success = await _apiService.updateRechargeStatus(req.id, status);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status Updated')));
          _loadRequests();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update Failed')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recharge History', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                return GestureDetector(
                  onTap: () => _showStatusDialog(req),
                  child: Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: Icon(Icons.phone_android, color: Colors.blue),
                      ),
                      title: Text(req.mobileNumber, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${req.operator} • ${req.status}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${req.amount}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(req.createdAt.split('T')[0], style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
