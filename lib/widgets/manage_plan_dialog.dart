import 'package:flutter/material.dart';
import '../models/plan.dart';
import '../models/operator.dart';
import '../services/plans_service.dart';

class ManagePlanDialog extends StatefulWidget {
  final Plan? plan;
  final List<Operator> operators;
  final Function onSave;

  const ManagePlanDialog({Key? key, this.plan, required this.operators, required this.onSave}) : super(key: key);

  @override
  _ManagePlanDialogState createState() => _ManagePlanDialogState();
}

class _ManagePlanDialogState extends State<ManagePlanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _plansService = PlansService();
  bool _isLoading = false;

  late TextEditingController _amountController;
  late TextEditingController _dataController;
  late TextEditingController _validityController;
  late TextEditingController _benefitsController;
  
  int? _selectedOperatorId;
  String _selectedPlanType = 'TOPUP';

  final List<String> _planTypes = ['TOPUP', 'DATA', 'SMS', 'UNLIMITED', 'ROAMING', 'OTHER'];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.plan?.amount ?? '');
    _dataController = TextEditingController(text: widget.plan?.data ?? '');
    _validityController = TextEditingController(text: widget.plan?.validity ?? '');
    _benefitsController = TextEditingController(text: widget.plan?.additionalBenefits ?? '');
    _selectedOperatorId = widget.plan?.operatorId ?? (widget.operators.isNotEmpty ? widget.operators.first.id : null);
    _selectedPlanType = widget.plan?.planType ?? 'TOPUP';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dataController.dispose();
    _validityController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOperatorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an operator')));
        return;
    }

    setState(() => _isLoading = true);

    final data = {
      'operator': _selectedOperatorId,
      'amount': _amountController.text,
      'data': _dataController.text,
      'validity': _validityController.text,
      'additional_benefits': _benefitsController.text,
      'plan_type': _selectedPlanType,
      'circle': 'ALL', // Defaulting to ALL as per plan
    };

    bool success;
    if (widget.plan == null) {
      success = await _plansService.createPlan(data);
    } else {
      success = await _plansService.updatePlan(widget.plan!.id, data);
    }

    setState(() => _isLoading = false);

    if (success) {
      widget.onSave();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Operation failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.plan == null ? 'Add Plan' : 'Edit Plan'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedOperatorId,
                items: widget.operators.map((op) => DropdownMenuItem(
                  value: op.id,
                  child: Text(op.name),
                )).toList(),
                onChanged: (val) => setState(() => _selectedOperatorId = val),
                decoration: InputDecoration(labelText: 'Operator'),
                validator: (val) => val == null ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedPlanType,
                items: _planTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (val) => setState(() => _selectedPlanType = val!),
                decoration: InputDecoration(labelText: 'Plan Type'),
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Price (Amount)'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _dataController,
                decoration: InputDecoration(labelText: 'Data (e.g. 1.5GB/Day)'),
              ),
              TextFormField(
                controller: _validityController,
                decoration: InputDecoration(labelText: 'Validity (e.g. 28 Days)'),
              ),
               TextFormField(
                controller: _benefitsController,
                decoration: InputDecoration(labelText: 'Additional Benefits'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? CircularProgressIndicator() : Text('Save'),
        ),
      ],
    );
  }
}
