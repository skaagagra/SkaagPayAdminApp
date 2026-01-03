import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../models/operator.dart';
import '../services/plans_service.dart';
import '../widgets/manage_plan_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final operators = await _plansService.getOperators();
      setState(() => _operators = operators);

      // If no operator selected, select the first one if available to filter initially? 
      // Or show all. Let's show all initially.
      await _fetchPlans();
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPlans() async {
    setState(() => _isLoading = true);
    try {
      final plans = await _plansService.getPlans(operatorId: _selectedOperator?.id);
      setState(() => _plans = plans);
    } catch (e) {
       // Handle error
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
                    ? Center(child: Text('No plans found.'))
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
