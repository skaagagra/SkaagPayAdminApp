import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../models/operator.dart';
import '../services/plans_service.dart';
import '../widgets/manage_plan_dialog.dart';
import '../utils/constants.dart';

class PlansScreen extends StatefulWidget {
  @override
  _PlansScreenState createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final PlansService _plansService = PlansService();
  List<Plan> _plans = [];
  List<Operator> _operators = [];
  Operator? _selectedOperator;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final operators = await _plansService.getOperators();
      setState(() => _operators = operators);
      await _fetchPlans();
    } catch (e) {
      setState(() => _errorMessage = 'Init Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final plans = await _plansService.getPlans(operatorId: _selectedOperator?.id);
      setState(() => _plans = plans);
    } catch (e) {
       setState(() => _errorMessage = 'Fetch Error: $e');
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showManageDialog({Plan? plan}) {
    showDialog(
      context: context,
      builder: (context) => ManagePlanDialog(
        plan: plan,
        operators: _operators,
        onSave: _fetchPlans,
      ),
    );
  }

  Future<void> _deletePlan(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Plan?'),
        content: Text('Are you sure you want to delete this plan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes')),
        ],
      )
    );

    if (confirmed == true) {
      await _plansService.deletePlan(id);
      _fetchPlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recharge Plans'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showManageDialog(),
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<Operator>(
              value: _selectedOperator,
              decoration: InputDecoration(
                labelText: 'Filter by Operator',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              items: [
                DropdownMenuItem<Operator>(value: null, child: Text('All Operators')),
                ..._operators.map((op) => DropdownMenuItem(value: op, child: Text(op.name))).toList(),
              ],
              onChanged: (val) {
                setState(() => _selectedOperator = val);
                _fetchPlans();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _plans.isEmpty
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No plans found.'),
                          SizedBox(height: 20),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('ERROR: $_errorMessage', style: TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                            ),
                          Text('DEBUG INFO:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                          Text('Base URL: ${AppConstants.baseUrl}'),
                          Text('Plans Count: ${_plans.length}'),
                          Text('Operators Count: ${_operators.length}'),
                          Text('Selected Operator: ${_selectedOperator?.name ?? "None"}'),
                        ],
                      ))
                    : ListView.builder(
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('₹${double.parse(plan.amount).toInt()}')),
                              title: Text('${plan.operatorName} - ₹${plan.amount}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${plan.data} | ${plan.validity}'),
                                  if (plan.additionalBenefits.isNotEmpty) Text(plan.additionalBenefits, style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showManageDialog(plan: plan)),
                                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deletePlan(plan.id)),
                                ],
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
}
