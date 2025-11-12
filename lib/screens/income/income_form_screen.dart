import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../providers/account_provider.dart';
import '../../providers/contact_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../database/models/transaction.dart';
import '../../database/models/receipt.dart';
import '../../widgets/transaction_form_fields.dart';
import '../../widgets/receipt_picker.dart';
import '../../l10n/app_localizations.dart';

class IncomeFormScreen extends StatefulWidget {
  final Transaction? transactionToEdit;
  
  const IncomeFormScreen({super.key, this.transactionToEdit});

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
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
    // Pre-fill form if editing
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _amountController.text = t.amount.toStringAsFixed(0);
      _selectedAccountId = t.accountId;
      _selectedContactId = t.contactId;
      _billNumberController.text = t.billNumber ?? '';
      _companyNameController.text = t.companyName ?? '';
      _remarkController.text = t.remark ?? '';
      try {
        _selectedDate = DateFormat('yyyy-MM-dd').parse(t.date);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
      context.read<ContactProvider>().loadContacts();
      // Load existing receipts if editing
      if (widget.transactionToEdit?.id != null) {
        _loadReceipts();
      }
    });
  }

  Future<void> _loadReceipts() async {
    if (widget.transactionToEdit?.id == null) return;
    try {
      final transactionProvider = context.read<TransactionProvider>();
      final receipts = await transactionProvider.getReceiptsForTransaction(
        widget.transactionToEdit!.id!,
      );
      setState(() {
        _receipts = receipts.map((r) {
          final fileName = r.filePath.split('/').last;
          return ReceiptFile(
            filePath: r.filePath,
            fileType: r.fileType,
            fileName: fileName,
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error loading receipts: $e');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _billNumberController.dispose();
    _companyNameController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAccountId == null) {
      final l10n = AppLocalizations.of(context)!;
      Fluttertoast.showToast(
        msg: l10n.pleaseSelectAnAccount,
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    try {
      final now = DateTime.now().toIso8601String();
      final isEditing = widget.transactionToEdit != null;
      
      final transaction = Transaction(
        id: isEditing ? widget.transactionToEdit!.id : null,
        type: 'income',
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
        createdAt: isEditing ? widget.transactionToEdit!.createdAt : now,
      );

      List<Receipt>? receipts;
      if (_receipts.isNotEmpty) {
        receipts = _receipts.map((file) {
          return Receipt(
            transactionId: isEditing ? widget.transactionToEdit!.id! : 0,
            filePath: file.filePath,
            fileType: file.fileType,
            createdAt: now,
          );
        }).toList();
      }

      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();

      if (isEditing) {
        await transactionProvider.updateTransaction(
          transaction,
          receipts,
          accountProvider,
        );
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Fluttertoast.showToast(
            msg: l10n.incomeUpdatedSuccessfully,
            toastLength: Toast.LENGTH_SHORT,
          );
          context.go('/');
        }
      } else {
        await transactionProvider.addTransaction(
          transaction,
          receipts,
          accountProvider,
        );
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          Fluttertoast.showToast(
            msg: l10n.incomeAddedSuccessfully,
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
              title: Text(widget.transactionToEdit != null ? l10n.editIncome : l10n.addIncome),
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TransactionFormFields.buildAccountDropdown(
                            accounts: accountProvider.accounts,
                            selectedAccountId: _selectedAccountId,
                            onChanged: (value) {
                              setState(() {
                                _selectedAccountId = value;
                              });
                            },
                            label: l10n.selectAccount,
                            validator: (value) {
                              if (value == null) {
                                return l10n.pleaseSelectAnAccount;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              l10n.incomeAccountNote,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<ContactProvider>(
                    builder: (context, contactProvider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TransactionFormFields.buildContactDropdown(
                            contacts: contactProvider.contacts,
                            selectedContactId: _selectedContactId,
                            onChanged: (value) {
                              setState(() {
                                _selectedContactId = value;
                              });
                            },
                            label: l10n.selectContact,
                            onAddNew: () => context.go('/contacts/new'),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              l10n.incomeContactNote,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TransactionFormFields.buildTextField(
                    controller: _billNumberController,
                    label: l10n.billNumberOptional,
                  ),
                  const SizedBox(height: 16),
                  TransactionFormFields.buildTextField(
                    controller: _companyNameController,
                    label: l10n.companyNameOptional,
                  ),
                  const SizedBox(height: 16),
                  TransactionFormFields.buildTextField(
                    controller: _remarkController,
                    label: l10n.remarkOptional,
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
                  ReceiptPicker(
                    key: ValueKey('receipts_${_receipts.length}_${widget.transactionToEdit?.id ?? 0}'),
                    initialReceipts: _receipts.isNotEmpty ? _receipts : null,
                    onReceiptsChanged: (receipts) {
                      setState(() {
                        _receipts = receipts;
                      });
                    },
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
                          onPressed: _saveIncome,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(widget.transactionToEdit != null ? l10n.updateIncome : l10n.saveIncome),
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
