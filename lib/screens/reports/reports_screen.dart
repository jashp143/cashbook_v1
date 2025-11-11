import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import '../../providers/account_provider.dart';
import '../../providers/contact_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../database/models/transaction.dart';
import '../../widgets/date_filter_chip.dart';
import '../../utils/pdf_export.dart';
import '../../utils/excel_export.dart';
import '../../utils/date_formatter.dart';

enum ViewMode { timeline, calendar }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int? _selectedAccountId;
  int? _selectedContactId;
  DateFilterType _selectedDateFilter = DateFilterType.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isExporting = false;
  ViewMode _viewMode = ViewMode.timeline;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _filtersExpanded = false;
  bool _calendarExpanded = true; // Calendar expanded state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
      context.read<ContactProvider>().loadContacts();
      _loadTransactions();
    });
  }

  void _loadTransactions() {
    final transactionProvider = context.read<TransactionProvider>();
    String? startDate;
    String? endDate;

    if (_selectedDateFilter == DateFilterType.today) {
      final today = DateTime.now();
      startDate = DateFormatter.formatDate(today);
      endDate = DateFormatter.formatDate(today);
    } else if (_selectedDateFilter == DateFilterType.weekly) {
      final today = DateTime.now();
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      startDate = DateFormatter.formatDate(weekStart);
      endDate = DateFormatter.formatDate(today);
    } else if (_selectedDateFilter == DateFilterType.monthly) {
      final today = DateTime.now();
      final monthStart = DateTime(today.year, today.month, 1);
      startDate = DateFormatter.formatDate(monthStart);
      endDate = DateFormatter.formatDate(today);
    } else if (_selectedDateFilter == DateFilterType.custom) {
      if (_customStartDate != null && _customEndDate != null) {
        startDate = DateFormatter.formatDate(_customStartDate!);
        endDate = DateFormatter.formatDate(_customEndDate!);
      }
    }

    transactionProvider.loadFilteredTransactions(
      accountId: _selectedAccountId,
      contactId: _selectedContactId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedDateFilter = DateFilterType.custom;
      });
      _loadTransactions();
    }
  }

  Future<void> _exportPDF() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();
      final contactProvider = context.read<ContactProvider>();

      final accountName = _selectedAccountId != null
          ? accountProvider.getAccountById(_selectedAccountId)?.name
          : null;
      final contactName = _selectedContactId != null
          ? contactProvider.getContactById(_selectedContactId)?.name
          : null;

      String dateRange;
      if (_selectedDateFilter == DateFilterType.today) {
        dateRange = 'Today';
      } else if (_selectedDateFilter == DateFilterType.weekly) {
        dateRange = 'This Week';
      } else if (_selectedDateFilter == DateFilterType.monthly) {
        dateRange = 'This Month';
      } else if (_selectedDateFilter == DateFilterType.custom &&
          _customStartDate != null &&
          _customEndDate != null) {
        dateRange = DateFormatter.getDateRangeString(
          _customStartDate!,
          _customEndDate!,
        );
      } else {
        dateRange = 'All Time';
      }

      final file = await PDFExport.generateTransactionReport(
        transactions: transactionProvider.transactions,
        accounts: accountProvider.accounts,
        contacts: contactProvider.contacts,
        accountFilter: accountName,
        contactFilter: contactName,
        dateRange: dateRange,
      );

      await Share.shareXFiles([XFile(file.path)], text: 'Transaction Report');
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
    setState(() {
      _isExporting = true;
    });

    try {
      final transactionProvider = context.read<TransactionProvider>();
      final accountProvider = context.read<AccountProvider>();
      final contactProvider = context.read<ContactProvider>();

      final accountName = _selectedAccountId != null
          ? accountProvider.getAccountById(_selectedAccountId)?.name
          : null;
      final contactName = _selectedContactId != null
          ? contactProvider.getContactById(_selectedContactId)?.name
          : null;

      String dateRange;
      if (_selectedDateFilter == DateFilterType.today) {
        dateRange = 'Today';
      } else if (_selectedDateFilter == DateFilterType.weekly) {
        dateRange = 'This Week';
      } else if (_selectedDateFilter == DateFilterType.monthly) {
        dateRange = 'This Month';
      } else if (_selectedDateFilter == DateFilterType.custom &&
          _customStartDate != null &&
          _customEndDate != null) {
        dateRange = DateFormatter.getDateRangeString(
          _customStartDate!,
          _customEndDate!,
        );
      } else {
        dateRange = 'All Time';
      }

      final file = await ExcelExport.generateTransactionReport(
        transactions: transactionProvider.transactions,
        accounts: accountProvider.accounts,
        contacts: contactProvider.contacts,
        accountFilter: accountName,
        contactFilter: contactName,
        dateRange: dateRange,
      );

      await Share.shareXFiles([XFile(file.path)], text: 'Transaction Report');
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
        // Back navigation is handled by MainScaffold for root routes
        // This allows normal back button behavior
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text('Export PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'excel',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart),
                      SizedBox(width: 8),
                      Text('Export Excel'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'pdf') {
                  _exportPDF();
                } else if (value == 'excel') {
                  _exportExcel();
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Compact Summary & Filters Header
          Consumer<TransactionProvider>(
            builder: (context, transactionProvider, child) {
              final transactions = transactionProvider.transactions;
              double totalIncome = 0;
              double totalExpense = 0;
              for (var t in transactions) {
                if (t.type == 'income') {
                  totalIncome += t.amount;
                } else if (t.type == 'expense') {
                  totalExpense += t.amount;
                }
              }
              final netAmount = totalIncome - totalExpense;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                  children: [
                    // Summary Row
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
                        Container(width: 1, height: 30, color: theme.dividerColor),
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            'Expense',
                            totalExpense,
                            Colors.red,
                            Icons.arrow_upward,
                          ),
                        ),
                        Container(width: 1, height: 30, color: theme.dividerColor),
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            'Net',
                            netAmount,
                            netAmount >= 0 ? Colors.blue : Colors.orange,
                            Icons.account_balance_wallet,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Compact Filter Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildCompactFilter(
                            context,
                            icon: Icons.filter_list,
                            label: 'Filters',
                            onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
                            isActive: _selectedAccountId != null || 
                                     _selectedContactId != null || 
                                     _selectedDateFilter != DateFilterType.all,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildViewToggleButton(
                            context,
                            icon: Icons.timeline_rounded,
                            label: 'Timeline',
                            isSelected: _viewMode == ViewMode.timeline,
                            onTap: () => setState(() => _viewMode = ViewMode.timeline),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildViewToggleButton(
                            context,
                            icon: Icons.calendar_today_rounded,
                            label: 'Calendar',
                            isSelected: _viewMode == ViewMode.calendar,
                            onTap: () => setState(() => _viewMode = ViewMode.calendar),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          // Expandable Filters
          if (_filtersExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Consumer<AccountProvider>(
                          builder: (context, accountProvider, child) {
                            return DropdownButtonFormField<int>(
                              value: _selectedAccountId,
                              isDense: true,
                              decoration: InputDecoration(
                                labelText: 'Account',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('All Accounts', style: TextStyle(fontSize: 14)),
                                ),
                                ...accountProvider.accounts.map((account) {
                                  return DropdownMenuItem<int>(
                                    value: account.id,
                                    child: Text(account.name, style: const TextStyle(fontSize: 14)),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedAccountId = value;
                                });
                                _loadTransactions();
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Consumer<ContactProvider>(
                          builder: (context, contactProvider, child) {
                            return DropdownButtonFormField<int>(
                              value: _selectedContactId,
                              isDense: true,
                              decoration: InputDecoration(
                                labelText: 'Contact',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              items: [
                                const DropdownMenuItem<int>(
                                  value: null,
                                  child: Text('All Contacts', style: TextStyle(fontSize: 14)),
                                ),
                                ...contactProvider.contacts.map((contact) {
                                  return DropdownMenuItem<int>(
                                    value: contact.id,
                                    child: Text(contact.name, style: const TextStyle(fontSize: 14)),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedContactId = value;
                                });
                                _loadTransactions();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DateFilterChip(
                    selectedFilter: _selectedDateFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        _selectedDateFilter = filter;
                      });
                      if (filter == DateFilterType.custom) {
                        _selectCustomDateRange();
                      } else {
                        _loadTransactions();
                      }
                    },
                  ),
                  if (_selectedDateFilter == DateFilterType.custom &&
                      _customStartDate != null &&
                      _customEndDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton.icon(
                        onPressed: _selectCustomDateRange,
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          '${DateFormat('MMM dd').format(_customStartDate!)} - ${DateFormat('MMM dd, yyyy').format(_customEndDate!)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // Transactions View
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                if (transactionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (transactionProvider.transactions.isEmpty) {
                  return Center(
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
                      ],
                    ),
                  );
                }

                return _viewMode == ViewMode.timeline
                    ? _buildTimelineView(context, transactionProvider)
                    : _buildCalendarView(context, transactionProvider);
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

  Widget _buildCompactFilter(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isActive 
                ? (isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive 
                  ? (isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2))
                  : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive 
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: isActive 
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Transaction transaction,
    TransactionProvider transactionProvider,
  ) {
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

    final theme = Theme.of(context);
    
    // Format date to be more compact
    String dateDisplay = transaction.date;
    try {
      final date = DateFormat('yyyy-MM-dd').parse(transaction.date);
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dateDisplay = 'Today';
      } else {
        dateDisplay = DateFormat('MMM dd').format(date);
      }
    } catch (e) {
      // Keep original format
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (accountName != 'N/A')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_balance_wallet, size: 14, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6)),
                                const SizedBox(width: 4),
                                Text(
                                  accountName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          if (contactName != 'N/A')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person, size: 14, color: theme.textTheme.bodySmall?.color?.withOpacity(0.6)),
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
                        ],
                      ),
                      if (transaction.remark != null && transaction.remark!.isNotEmpty)
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

  Widget _buildViewToggleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected 
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected 
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: isSelected 
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6)),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineView(
    BuildContext context,
    TransactionProvider transactionProvider,
  ) {
    final theme = Theme.of(context);
    final transactions = transactionProvider.transactions;

    // Group transactions by date
    final Map<String, List<Transaction>> groupedTransactions = {};
    for (var transaction in transactions) {
      final dateKey = transaction.date;
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateTransactions = groupedTransactions[date]!;
        
        // Calculate daily totals
        double dailyIncome = 0;
        double dailyExpense = 0;
        for (var t in dateTransactions) {
          if (t.type == 'income') {
            dailyIncome += t.amount;
          } else if (t.type == 'expense') {
            dailyExpense += t.amount;
          }
        }
        final dailyNet = dailyIncome - dailyExpense;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Date Header with Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.blue.withOpacity(0.15)
                    : Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.blue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _formatDateHeader(date),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (dailyIncome > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '₹${dailyIncome.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  if (dailyExpense > 0) ...[
                    const SizedBox(width: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          '₹${dailyExpense.toStringAsFixed(0)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (dailyNet != 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (dailyNet >= 0 ? Colors.blue : Colors.orange).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Net: ₹${dailyNet.abs().toStringAsFixed(0)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: dailyNet >= 0 ? Colors.blue : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Transactions for this date
            ...dateTransactions.map((transaction) => 
              _buildTransactionCard(context, transaction, transactionProvider)
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    TransactionProvider transactionProvider,
  ) {
    final theme = Theme.of(context);
    final transactions = transactionProvider.transactions;
    
    // Create a map of dates to transactions
    final Map<DateTime, List<Transaction>> events = {};
    for (var transaction in transactions) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(transaction.date);
        final dateKey = DateTime(date.year, date.month, date.day);
        if (!events.containsKey(dateKey)) {
          events[dateKey] = [];
        }
        events[dateKey]!.add(transaction);
      } catch (e) {
        // Skip invalid dates
      }
    }

    List<Transaction> _getEventsForDay(DateTime day) {
      final dateKey = DateTime(day.year, day.month, day.day);
      return events[dateKey] ?? [];
    }

    bool isSameDay(DateTime? a, DateTime? b) {
      if (a == null || b == null) return false;
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }

    final selectedDayTransactions = _getEventsForDay(_selectedDay);
    final transactionCount = selectedDayTransactions.length;

    return Column(
      children: [
        // Collapsible Calendar Header
        Container(
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
            children: [
              // Compact Date Selector (when collapsed) or Full Calendar (when expanded)
              AnimatedCrossFade(
                firstChild: _buildCompactDateSelector(context, theme, _selectedDay, transactionCount, _getEventsForDay),
                secondChild: _buildFullCalendar(context, theme, _focusedDay, _selectedDay, _getEventsForDay, isSameDay),
                crossFadeState: _calendarExpanded 
                    ? CrossFadeState.showSecond 
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
              // Toggle Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _calendarExpanded = !_calendarExpanded;
                        });
                      },
                      icon: Icon(
                        _calendarExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20,
                      ),
                      label: Text(
                        _calendarExpanded ? 'Hide Calendar' : 'Show Calendar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
              ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Selected Day Transactions
        Expanded(
          child: selectedDayTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.event_busy_outlined,
                          size: 64,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No transactions',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No transactions on ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                  itemCount: selectedDayTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = selectedDayTransactions[index];
                    return _buildTransactionCard(context, transaction, transactionProvider);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompactDateSelector(
    BuildContext context,
    ThemeData theme,
    DateTime selectedDay,
    int transactionCount,
    List<Transaction> Function(DateTime) getEventsForDay,
  ) {
    // Calculate totals for selected day
    final dayTransactions = getEventsForDay(selectedDay);
    double dayIncome = 0;
    double dayExpense = 0;
    for (var t in dayTransactions) {
      if (t.type == 'income') {
        dayIncome += t.amount;
      } else if (t.type == 'expense') {
        dayExpense += t.amount;
      }
    }
    final dayNet = dayIncome - dayExpense;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Date Navigation Row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                    _focusedDay = _selectedDay;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _calendarExpanded = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM dd').format(selectedDay),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${transactionCount} transaction${transactionCount != 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _selectedDay = _selectedDay.add(const Duration(days: 1));
                    _focusedDay = _selectedDay;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          // Quick Summary
          if (dayIncome > 0 || dayExpense > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (dayIncome > 0)
                  _buildQuickSummaryItem(
                    theme,
                    'Income',
                    dayIncome,
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                if (dayExpense > 0)
                  _buildQuickSummaryItem(
                    theme,
                    'Expense',
                    dayExpense,
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                if (dayNet != 0)
                  _buildQuickSummaryItem(
                    theme,
                    'Net',
                    dayNet,
                    dayNet >= 0 ? Colors.blue : Colors.orange,
                    Icons.account_balance_wallet,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickSummaryItem(
    ThemeData theme,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFullCalendar(
    BuildContext context,
    ThemeData theme,
    DateTime focusedDay,
    DateTime selectedDay,
    List<Transaction> Function(DateTime) getEventsForDay,
    bool Function(DateTime?, DateTime?) isSameDay,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: TableCalendar<Transaction>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 13,
          ),
          defaultTextStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 13,
          ),
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          cellMargin: const EdgeInsets.all(1.5),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleMedium?.copyWith(fontSize: 15) ?? const TextStyle(fontSize: 15),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            size: 22,
            color: theme.textTheme.bodyMedium?.color,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            size: 22,
            color: theme.textTheme.bodyMedium?.color,
          ),
          headerPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
      ),
    );
  }

  String _formatDateHeader(String dateStr) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      
      bool isSameDay(DateTime? a, DateTime? b) {
        if (a == null || b == null) return false;
        return a.year == b.year && a.month == b.month && a.day == b.day;
      }
      
      if (isSameDay(date, today)) {
        return 'Today';
      } else if (isSameDay(date, yesterday)) {
        return 'Yesterday';
      } else {
        // Use compact format: "Mon 15" or "Mon 15, 2024" if different year
        final now = DateTime.now();
        if (date.year == now.year) {
          return DateFormat('EEE, MMM dd').format(date);
        } else {
          return DateFormat('MMM dd, yyyy').format(date);
        }
      }
    } catch (e) {
      return dateStr;
    }
  }
}
