import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/account_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../database/models/transaction.dart';
import '../../widgets/transaction_form_fields.dart';
import '../../l10n/app_localizations.dart';

class TransferFormScreen extends StatefulWidget {
  final Transaction? transactionToEdit;
  
  const TransferFormScreen({super.key, this.transactionToEdit});

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
    // Pre-fill form if editing
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _amountController.text = t.amount.toStringAsFixed(0);
      _fromAccountId = t.accountId;
      _toAccountId = t.secondAccountId;
      _noteController.text = t.remark ?? '';
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(t.date);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
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

    final l10n = AppLocalizations.of(context)!;
    if (_fromAccountId == null || _toAccountId == null) {
      Fluttertoast.showToast(
        msg: l10n.pleaseSelectBothAccounts,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    if (_fromAccountId == _toAccountId) {
      Fluttertoast.showToast(
        msg: l10n.fromAndToAccountsMustBeDifferent,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    try {
      final now = DateTime.now().toIso8601String();
      final isEditing = widget.transactionToEdit != null;
      
      final transaction = Transaction(
        id: isEditing ? widget.transactionToEdit!.id : null,
        type: 'transfer',
        amount: double.parse(_amountController.text),
        accountId: _fromAccountId,
        secondAccountId: _toAccountId,
        remark: _noteController.text.isEmpty ? null : _noteController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        createdAt: isEditing ? widget.transactionToEdit!.createdAt : now,
      );

      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();

      if (isEditing) {
        await transactionProvider.updateTransaction(
          transaction,
          null, // No receipts for transfers
          accountProvider,
        );
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Fluttertoast.showToast(
            msg: l10n.transferUpdatedSuccessfully,
            toastLength: Toast.LENGTH_SHORT,
          );
          context.go('/');
        }
      } else {
        await transactionProvider.addTransaction(
          transaction,
          null, // No receipts for transfers
          accountProvider,
        );
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Fluttertoast.showToast(
            msg: l10n.transferCompletedSuccessfully,
            toastLength: Toast.LENGTH_SHORT,
          );
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Fluttertoast.showToast(
          msg: l10n.error(e.toString()),
          toastLength: Toast.LENGTH_SHORT,
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
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.transactionToEdit != null ? l10n.editTransfer : l10n.transfer),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go('/'),
              ),
            ),
            body: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                  TransactionFormFields.buildAmountField(
                    controller: _amountController,
                    label: l10n.amount,
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
                        label: l10n.fromAccount,
                        validator: (value) {
                          if (value == null) {
                            return l10n.pleaseSelectFromAccount;
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
                        label: l10n.toAccount,
                        validator: (value) {
                          if (value == null) {
                            return l10n.pleaseSelectToAccount;
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TransactionFormFields.buildTextField(
                    controller: _noteController,
                    label: l10n.noteOptional,
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
                    label: l10n.date,
                  ),
                  const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveTransfer,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(widget.transactionToEdit != null ? l10n.updateTransfer : l10n.completeTransfer),
                        ),
                      ),
                    ),
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
