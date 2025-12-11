import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/topup_request.dart';
import '../utils/constants.dart';

class TopUpScreen extends StatefulWidget {
  @override
  _TopUpScreenState createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final ApiService _apiService = ApiService();
  List<TopUpRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getTopUpRequests();
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _handleAction(int id, String action) async {
    final success = await _apiService.connectTopUpAction(id, action);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action Successful')));
      _loadRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action Failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage TopUps', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                final req = _requests[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('User: ${req.userPhone}', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('₹${req.amount}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Status: ${req.status}'),
                        Text('Date: ${req.createdAt.split('T')[0]}'),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[300]!)
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.receipt_long, size: 16, color: Colors.grey[700]),
                              SizedBox(width: 8),
                              Text('Ref: ${req.transactionReference}', style: GoogleFonts.sourceCodePro(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        if (req.status == 'PENDING')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () => _handleAction(req.id, 'REJECT'),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                child: Text('Reject'),
                              ),
                              SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () => _handleAction(req.id, 'APPROVE'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: Text('Approve', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
