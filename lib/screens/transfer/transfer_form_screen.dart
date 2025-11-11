import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../database/models/transaction.dart';
import '../../widgets/transaction_form_fields.dart';

class TransferFormScreen extends StatefulWidget {
  const TransferFormScreen({super.key});

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _fromAccountId;
  int? _toAccountId;
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both accounts')),
      );
      return;
    }

    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('From and To accounts must be different')),
      );
      return;
    }

    try {
      final now = DateTime.now().toIso8601String();
      final transaction = Transaction(
        type: 'transfer',
        amount: double.parse(_amountController.text),
        accountId: _fromAccountId,
        secondAccountId: _toAccountId,
        remark: _noteController.text.isEmpty ? null : _noteController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        createdAt: now,
      );

      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();

      await transactionProvider.addTransaction(
        transaction,
        null, // No receipts for transfers
        accountProvider,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer completed successfully')),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transfer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/'),
          ),
        ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TransactionFormFields.buildAmountField(
              controller: _amountController,
              label: 'Amount',
            ),
            const SizedBox(height: 16),
            Consumer<AccountProvider>(
              builder: (context, accountProvider, child) {
                return TransactionFormFields.buildAccountDropdown(
                  accounts: accountProvider.accounts,
                  selectedAccountId: _fromAccountId,
                  onChanged: (value) {
                    setState(() {
                      _fromAccountId = value;
                    });
                  },
                  label: 'From Account',
                  validator: (value) {
                    if (value == null) {
                      return 'Please select from account';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<AccountProvider>(
              builder: (context, accountProvider, child) {
                return TransactionFormFields.buildAccountDropdown(
                  accounts: accountProvider.accounts,
                  selectedAccountId: _toAccountId,
                  onChanged: (value) {
                    setState(() {
                      _toAccountId = value;
                    });
                  },
                  label: 'To Account',
                  validator: (value) {
                    if (value == null) {
                      return 'Please select to account';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TransactionFormFields.buildTextField(
              controller: _noteController,
              label: 'Note (Optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TransactionFormFields.buildDateField(
              context: context,
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              label: 'Date',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTransfer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Complete Transfer'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
