import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
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
  String _selectedStatus = 'PENDING'; // Default Filter

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getRechargeRequests(status: _selectedStatus == 'ALL' ? null : _selectedStatus);
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
        actions: [
            // Filter Icon or Dropdown
            PopupMenuButton<String>(
                icon: Icon(Icons.filter_list, color: Colors.white),
                onSelected: (val) {
                    setState(() => _selectedStatus = val);
                    _loadRequests();
                },
                itemBuilder: (context) => [
                    PopupMenuItem(value: 'PENDING', child: Text('Pending Only')),
                    PopupMenuItem(value: 'SUCCESS', child: Text('Success Only')),
                    PopupMenuItem(value: 'FAILED', child: Text('Failed Only')),
                    PopupMenuItem(value: 'ALL', child: Text('Show All')),
                ],
            )
        ],
      ),
      body: Column(
        children: [
            // Active Filter Display
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(8),
                color: Colors.grey.shade200,
                child: Text('Showing: ${_selectedStatus}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _requests.isEmpty
                      ? Center(child: Text('No $_selectedStatus requests found.'))
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
                                    backgroundColor: _getStatusColor(req.status).withOpacity(0.1),
                                    child: Icon(Icons.phone_android, color: _getStatusColor(req.status)),
                                  ),
                                  title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                          Text('${req.userName} (ID: ${req.userId})', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                          SizedBox(height: 4),
                                          Text(req.mobileNumber, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                  ),
                                  subtitle: Text('${req.operator} • ${req.status}'),
                                  trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          // Copy Icon
                                          GestureDetector(
                                              onTap: () async {
                                                  await Clipboard.setData(ClipboardData(text: req.mobileNumber));
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied ${req.mobileNumber}')));
                                              },
                                              child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey.shade200,
                                                      borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(Icons.copy, size: 20, color: Colors.blue[800]),
                                              ),
                                          ),
                                          SizedBox(width: 12),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text('₹${req.amount}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              Text(req.createdAt.split('T')[0], style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                                      ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }

    Color _getStatusColor(String status) {
        switch(status) {
            case 'SUCCESS': return Colors.green;
            case 'FAILED': return Colors.red;
            default: return Colors.orange;
        }
    }
}
