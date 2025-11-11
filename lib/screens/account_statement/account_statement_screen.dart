import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/account_provider.dart';
import '../../providers/contact_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../database/models/account.dart';
import '../../database/models/transaction.dart';
import '../../utils/pdf_export.dart';
import '../../utils/excel_export.dart';
import '../../utils/date_formatter.dart';

class AccountStatementScreen extends StatefulWidget {
  const AccountStatementScreen({super.key});

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
  int? _selectedAccountId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;
  List<Transaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
      context.read<ContactProvider>().loadContacts();
      // Set default dates to current month
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = now;
      setState(() {});
      _loadTransactions();
    });
  }

  void _loadTransactions() async {
    if (_selectedAccountId == null || _startDate == null || _endDate == null) {
      setState(() {
        _filteredTransactions = [];
      });
      return;
    }

    final transactionProvider = context.read<TransactionProvider>();
    final startDateStr = DateFormatter.formatDate(_startDate!);
    final endDateStr = DateFormatter.formatDate(_endDate!);

    await transactionProvider.loadFilteredTransactions(
      accountId: _selectedAccountId,
      startDate: startDateStr,
      endDate: endDateStr,
    );

    setState(() {
      _filteredTransactions = transactionProvider.transactions;
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = _startDate;
        }
      });
      _loadTransactions();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _loadTransactions();
    }
  }

  Future<void> _exportPDF() async {
    if (_selectedAccountId == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select account and date range')),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final accountProvider = context.read<AccountProvider>();
      final contactProvider = context.read<ContactProvider>();
      final account = accountProvider.getAccountById(_selectedAccountId);

      if (account == null) {
        throw Exception('Account not found');
      }

      final dateRange = DateFormatter.getDateRangeString(_startDate!, _endDate!);

      final file = await PDFExport.generateTransactionReport(
        transactions: _filteredTransactions,
        accounts: accountProvider.accounts,
        contacts: contactProvider.contacts,
        accountFilter: account.name,
        dateRange: dateRange,
        accountBalance: account.balance,
      );

      await Share.shareXFiles([XFile(file.path)], text: 'Account Statement - ${account.name}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportExcel() async {
    if (_selectedAccountId == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select account and date range')),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final accountProvider = context.read<AccountProvider>();
      final contactProvider = context.read<ContactProvider>();
      final account = accountProvider.getAccountById(_selectedAccountId);

      if (account == null) {
        throw Exception('Account not found');
      }

      final dateRange = DateFormatter.getDateRangeString(_startDate!, _endDate!);

      final file = await ExcelExport.generateTransactionReport(
        transactions: _filteredTransactions,
        accounts: accountProvider.accounts,
        contacts: contactProvider.contacts,
        accountFilter: account.name,
        dateRange: dateRange,
        accountBalance: account.balance,
      );

      await Share.shareXFiles([XFile(file.path)], text: 'Account Statement - ${account.name}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting Excel: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/accounts');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Account Statement',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/accounts');
              }
            },
          ),
        ),
      body: Column(
        children: [
          // Selection Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Account Selection
                Consumer<AccountProvider>(
                  builder: (context, accountProvider, child) {
                    return DropdownButtonFormField<int>(
                      value: _selectedAccountId,
                      decoration: InputDecoration(
                        labelText: 'Select Account',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.account_balance_wallet),
                      ),
                      items: accountProvider.accounts.map((account) {
                        return DropdownMenuItem<int>(
                          value: account.id,
                          child: Text(account.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAccountId = value;
                        });
                        _loadTransactions();
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Date Range Selection
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectStartDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start Date',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _startDate != null
                                          ? DateFormat('MMM dd, yyyy').format(_startDate!)
                                          : 'Select date',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _selectEndDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Date',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _endDate != null
                                          ? DateFormat('MMM dd, yyyy').format(_endDate!)
                                          : 'Select date',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Export Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportPDF,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.picture_as_pdf),
                        label: const Text('Export PDF'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportExcel,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.table_chart),
                        label: const Text('Export Excel'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Summary Section
          if (_selectedAccountId != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  final account = accountProvider.getAccountById(_selectedAccountId);
                  double totalIncome = 0;
                  double totalExpense = 0;
                  for (var t in _filteredTransactions) {
                    if (t.type == 'income') {
                      totalIncome += t.amount;
                    } else if (t.type == 'expense') {
                      totalExpense += t.amount;
                    }
                  }
                  final netAmount = totalIncome - totalExpense;
                  final accountBalance = account?.balance ?? 0.0;

                  return Column(
                    children: [
                      // Account Balance - Prominent Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accountBalance >= 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accountBalance >= 0
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: accountBalance >= 0 ? Colors.green : Colors.red,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Balance',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${accountBalance.toStringAsFixed(2)}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: accountBalance >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_filteredTransactions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        // Period Summary
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryItem(
                                context,
                                'Income',
                                totalIncome,
                                Colors.green,
                                Icons.arrow_downward,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.dividerColor,
                            ),
                            Expanded(
                              child: _buildSummaryItem(
                                context,
                                'Expense',
                                totalExpense,
                                Colors.red,
                                Icons.arrow_upward,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: theme.dividerColor,
                            ),
                            Expanded(
                              child: _buildSummaryItem(
                                context,
                                'Net',
                                netAmount,
                                netAmount >= 0 ? Colors.blue : Colors.orange,
                                Icons.trending_up,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          // Transactions List
          Expanded(
            child: _selectedAccountId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select an account to view statement',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'for the selected date range',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = _filteredTransactions[index];
                          return _buildTransactionCard(context, transaction);
                        },
                      ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    final theme = Theme.of(context);
    final accountProvider = context.read<AccountProvider>();
    final contactProvider = context.read<ContactProvider>();

    final accountName = transaction.accountId != null
        ? accountProvider.getAccountById(transaction.accountId)?.name ?? 'N/A'
        : 'N/A';
    final contactName = transaction.contactId != null
        ? contactProvider.getContactById(transaction.contactId)?.name ?? 'N/A'
        : 'N/A';

    Color amountColor;
    IconData typeIcon;
    String typeLabel;
    if (transaction.type == 'income') {
      amountColor = Colors.green;
      typeIcon = Icons.arrow_downward;
      typeLabel = 'Income';
    } else if (transaction.type == 'expense') {
      amountColor = Colors.red;
      typeIcon = Icons.arrow_upward;
      typeLabel = 'Expense';
    } else {
      amountColor = Colors.blue;
      typeIcon = Icons.swap_horiz;
      typeLabel = 'Transfer';
    }

    String dateDisplay = transaction.date;
    try {
      final date = DateFormat('yyyy-MM-dd').parse(transaction.date);
      dateDisplay = DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      // Keep original format
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.push(
              '/transaction/${transaction.id}',
              extra: transaction,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: amountColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, color: amountColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            typeLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              dateDisplay,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (contactName != 'N/A')
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              contactName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      if (transaction.remark != null &&
                          transaction.remark!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            transaction.remark!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '₹${transaction.amount.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

