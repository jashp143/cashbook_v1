import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/account_provider.dart';
import '../../providers/contact_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../database/models/transaction.dart';
import '../../database/models/receipt.dart';
import '../../widgets/transaction_form_fields.dart';
import '../../widgets/receipt_picker.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  int? _selectedAccountId;
  int? _selectedContactId;
  final _billNumberController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _remarkController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<ReceiptFile> _receipts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
      context.read<ContactProvider>().loadContacts();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _billNumberController.dispose();
    _companyNameController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an account')),
      );
      return;
    }

    try {
      final now = DateTime.now().toIso8601String();
      final transaction = Transaction(
        type: 'expense',
        amount: double.parse(_amountController.text),
        accountId: _selectedAccountId,
        contactId: _selectedContactId,
        billNumber: _billNumberController.text.isEmpty
            ? null
            : _billNumberController.text,
        companyName: _companyNameController.text.isEmpty
            ? null
            : _companyNameController.text,
        remark: _remarkController.text.isEmpty ? null : _remarkController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        createdAt: now,
      );

      List<Receipt>? receipts;
      if (_receipts.isNotEmpty) {
        receipts = _receipts.map((file) {
          return Receipt(
            transactionId: 0, // Will be set when transaction is saved
            filePath: file.filePath,
            fileType: file.fileType,
            createdAt: now,
          );
        }).toList();
      }

      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();

      await transactionProvider.addTransaction(
        transaction,
        receipts,
        accountProvider,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully')),
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
          title: const Text('Add Expense'),
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
                  selectedAccountId: _selectedAccountId,
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  },
                  label: 'Select Account',
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an account';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<ContactProvider>(
              builder: (context, contactProvider, child) {
                return TransactionFormFields.buildContactDropdown(
                  contacts: contactProvider.contacts,
                  selectedContactId: _selectedContactId,
                  onChanged: (value) {
                    setState(() {
                      _selectedContactId = value;
                    });
                  },
                  label: 'Select Contact',
                  onAddNew: () => context.go('/contacts/new'),
                );
              },
            ),
            const SizedBox(height: 16),
            TransactionFormFields.buildTextField(
              controller: _billNumberController,
              label: 'Bill Number (Optional)',
            ),
            const SizedBox(height: 16),
            TransactionFormFields.buildTextField(
              controller: _companyNameController,
              label: 'Company Name (Optional)',
            ),
            const SizedBox(height: 16),
            TransactionFormFields.buildTextField(
              controller: _remarkController,
              label: 'Remark (Optional)',
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
            const SizedBox(height: 16),
            ReceiptPicker(
              onReceiptsChanged: (receipts) {
                setState(() {
                  _receipts = receipts;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveExpense,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
