import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/contact_provider.dart';
import '../../database/models/transaction.dart';
import '../../utils/whatsapp_share.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Set<int> _expandedTransactions = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountProvider = context.read<AccountProvider>();
      context.read<ContactProvider>().loadContacts();
      accountProvider.loadAccounts().then((_) async {
        // Set default to "Khata Vahi" account (ID 1) if no account is selected
        // Find Khata Vahi account from the loaded accounts
        if (accountProvider.selectedAccountId == null || accountProvider.selectedAccountId == -1) {
          final cashBookAccount = accountProvider.accounts.firstWhere(
            (account) => account.name.toLowerCase() == 'khata vahi',
            orElse: () => accountProvider.accounts.isNotEmpty ? accountProvider.accounts.first : throw StateError('No accounts found'),
          );
          accountProvider.setSelectedAccount(cashBookAccount.id);
        }
        await _loadTransactions();
      });
    });
  }

  Future<void> _loadTransactions([AccountProvider? accountProvider]) async {
    final accountProviderInstance = accountProvider ?? context.read<AccountProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    
    // If an account is selected (and not -1 for All Accounts), filter transactions for that account
    // If -1 (All Accounts), load ALL transactions from all accounts
    final selectedId = accountProviderInstance.selectedAccountId;
    if (selectedId != null && selectedId != -1) {
      // Filter by specific account - includes transactions where account is 
      // either account_id or second_account_id (for transfers)
      await transactionProvider.loadFilteredTransactions(
        accountId: selectedId,
      );
    } else {
      // Load ALL transactions from ALL accounts - no filtering
      // This aggregates all transactions across all accounts
      await transactionProvider.loadTransactions();
    }
  }

  void _toggleTransaction(int transactionId) {
    setState(() {
      if (_expandedTransactions.contains(transactionId)) {
        _expandedTransactions.remove(transactionId);
      } else {
        _expandedTransactions.add(transactionId);
      }
    });
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
        title: Consumer<AccountProvider>(
          builder: (context, accountProvider, child) {
            // Always rebuild when accountProvider changes - capture values immediately
            final selectedAccountId = accountProvider.selectedAccountId;
            final selectedAccountName = (accountProvider.selectedAccountId == null || accountProvider.selectedAccountId == -1)
                ? 'All Accounts' 
                : (accountProvider.selectedAccount?.name ?? 'All Accounts');
            
            if (accountProvider.accounts.isEmpty) {
              return Text(
                'Khata Vahi',
                style: TextStyle(fontWeight: FontWeight.bold),
                key: ValueKey('cashbook-empty'),
              );
            }
            
            return PopupMenuButton<int?>(
              key: ValueKey('account-selector-$selectedAccountId'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedAccountName,
                    key: ValueKey('account-title-$selectedAccountId'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
              itemBuilder: (BuildContext context) {
                // Capture the current selectedAccountId to ensure we use the latest value
                final currentSelectedId = accountProvider.selectedAccountId;
                
                return [
                  // "All Accounts" option to show all transactions
                  PopupMenuItem<int?>(
                    value: -1,
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 20,
                          color: (currentSelectedId == null || currentSelectedId == -1)
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'All Accounts',
                          style: (currentSelectedId == null || currentSelectedId == -1)
                              ? TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  // Show all accounts including Khata Vahi
                  ...accountProvider.accounts.map((account) {
                    return PopupMenuItem<int?>(
                      value: account.id,
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 20,
                            color: currentSelectedId == account.id
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            account.name,
                            style: currentSelectedId == account.id
                                ? TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    );
                  }),
                ];
              },
              onSelected: (int? value) async {
                // Update the selected account - this will trigger notifyListeners()
                accountProvider.setSelectedAccount(value);
                
                // Force a rebuild by calling setState
                if (mounted) {
                  setState(() {});
                  // Load transactions with the selected account
                  await _loadTransactions(accountProvider);
                }
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Balance Card
          Consumer<TransactionProvider>(
            builder: (context, transactionProvider, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Current Balance Title (Centered)
                    Text(
                      'Current Balance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Balance Amount (Centered)
                    Text(
                      '₹${transactionProvider.totalBalance.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Income and Expense Row
                    Row(
                      children: [
                        // Income Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Income',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${transactionProvider.totalIncome.toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Vertical Divider
                        Container(
                          width: 1,
                          height: 32,
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                        // Expense Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.arrow_upward_rounded,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Expense',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${transactionProvider.totalExpense.toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context,
                            label: 'Income',
                            icon: Icons.add_rounded,
                            color: Colors.green,
                            onTap: () => context.go('/income'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            label: 'Expense',
                            icon: Icons.remove_rounded,
                            color: Colors.red,
                            onTap: () => context.go('/expense'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildActionButton(
                            context,
                            label: 'Transfer',
                            icon: Icons.swap_horiz_rounded,
                            color: Colors.blue,
                            onTap: () => context.go('/transfer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Transactions List
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
                          'No transactions yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first transaction',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Group transactions by date
                final Map<String, List<Transaction>> groupedTransactions = {};
                for (var transaction in transactionProvider.transactions) {
                  final dateKey = transaction.date;
                  if (!groupedTransactions.containsKey(dateKey)) {
                    groupedTransactions[dateKey] = [];
                  }
                  groupedTransactions[dateKey]!.add(transaction);
                }

                final sortedDates = groupedTransactions.keys.toList()
                  ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final dateTransactions = groupedTransactions[date]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(date),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Transactions for this date
                        ...dateTransactions.map((transaction) => 
                          _buildTransactionCard(
                            context, 
                            transaction, 
                            transactionProvider,
                            isExpanded: _expandedTransactions.contains(transaction.id ?? 0),
                            onTap: () => _toggleTransaction(transaction.id ?? 0),
                          )
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Transaction transaction,
    TransactionProvider transactionProvider, {
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    final accountProvider = context.read<AccountProvider>();
    final contactProvider = context.read<ContactProvider>();

    final accountName = transaction.accountId != null
        ? accountProvider.getAccountById(transaction.accountId)?.name ?? 'N/A'
        : 'N/A';
    final secondAccountName = transaction.secondAccountId != null
        ? accountProvider.getAccountById(transaction.secondAccountId)?.name ?? 'N/A'
        : null;
    final contactName = transaction.contactId != null
        ? contactProvider.getContactById(transaction.contactId)?.name ?? 'N/A'
        : 'N/A';

    Color amountColor;
    IconData typeIcon;
    String typeLabel;
    if (transaction.type == 'income') {
      amountColor = Colors.green;
      typeIcon = Icons.arrow_downward_rounded;
      typeLabel = 'INCOME';
    } else if (transaction.type == 'expense') {
      amountColor = Colors.red;
      typeIcon = Icons.arrow_upward_rounded;
      typeLabel = 'EXPENSE';
    } else {
      amountColor = Colors.blue;
      typeIcon = Icons.swap_horiz_rounded;
      typeLabel = 'TRANSFER';
    }

    final theme = Theme.of(context);
    
    // Build description: "Account Name • Contact Name" or just "Account Name"
    String description = accountName;
    if (contactName != 'N/A' && contactName.isNotEmpty) {
      description = '$accountName • $contactName';
    }

    // Format date
    String formattedDate = transaction.date;
    try {
      final date = DateFormat('yyyy-MM-dd').parse(transaction.date);
      formattedDate = DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      // Keep original format
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            children: [
              // Main transaction row
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      typeIcon,
                      color: amountColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            typeLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '₹${transaction.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Expanded details
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Divider(
                        height: 1,
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: formattedDate,
                      ),
                      if (accountName != 'N/A') ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          icon: transaction.type == 'transfer' 
                              ? Icons.account_balance_wallet_rounded 
                              : Icons.account_balance_wallet_rounded,
                          label: transaction.type == 'transfer' ? 'From Account' : 'Account',
                          value: accountName,
                        ),
                      ],
                      if (secondAccountName != null && secondAccountName != 'N/A') ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'To Account',
                          value: secondAccountName,
                        ),
                      ],
                      if (contactName != 'N/A' && contactName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          icon: Icons.person_rounded,
                          label: 'Contact',
                          value: contactName,
                        ),
                      ],
                      if (transaction.billNumber != null && transaction.billNumber!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          icon: Icons.receipt_rounded,
                          label: 'Bill Number',
                          value: transaction.billNumber!,
                        ),
                      ],
                      if (transaction.companyName != null && transaction.companyName!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          icon: Icons.business_rounded,
                          label: 'Company',
                          value: transaction.companyName!,
                        ),
                      ],
                      if (transaction.remark != null && transaction.remark!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          context,
                          icon: Icons.note_rounded,
                          label: 'Remark',
                          value: transaction.remark!,
                          isMultiline: true,
                        ),
                      ],
                      const SizedBox(height: 12),
                      // WhatsApp Share Button
                      _buildWhatsAppShareButton(
                        context,
                        transaction,
                        transactionProvider,
                      ),
                    ],
                  ),
                ),
                crossFadeState: isExpanded 
                    ? CrossFadeState.showSecond 
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                maxLines: isMultiline ? null : 2,
                overflow: isMultiline ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return 'Today';
      } else if (dateOnly == yesterday) {
        return 'Yesterday';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildWhatsAppShareButton(
    BuildContext context,
    Transaction transaction,
    TransactionProvider transactionProvider,
  ) {
    final accountProvider = context.read<AccountProvider>();
    final contactProvider = context.read<ContactProvider>();

    return InkWell(
      onTap: () => _shareTransactionViaWhatsApp(
        context,
        transaction,
        accountProvider,
        contactProvider,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF25D366).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message,
              size: 16,
              color: const Color(0xFF25D366),
            ),
            const SizedBox(width: 6),
            Text(
              'Share via WhatsApp',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF25D366),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareTransactionViaWhatsApp(
    BuildContext context,
    Transaction transaction,
    AccountProvider accountProvider,
    ContactProvider contactProvider,
  ) async {
    // Get contact phone number if available
    String? phoneNumber;
    String? contactName;
    if (transaction.contactId != null) {
      final contact = contactProvider.getContactById(transaction.contactId);
      phoneNumber = contact?.phone;
      contactName = contact?.name;
    }

    // If phone number exists, ask user how they want to share
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final shareOption = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Share via WhatsApp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contactName != null) ...[
                Text('Contact: $contactName'),
                const SizedBox(height: 8),
              ],
              Text('Phone: $phoneNumber'),
              const SizedBox(height: 16),
              const Text(
                'Choose how to share:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '• With phone number: Opens chat directly (if number is on WhatsApp)',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                '• Without phone number: Opens WhatsApp, you can select the contact',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('with_number'),
              child: const Text('With Phone Number'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('without_number'),
              child: const Text('Without Phone Number'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (shareOption == null) {
        return; // User cancelled
      }

      if (shareOption == 'without_number') {
        phoneNumber = null; // Share without specific number
      }
    }

    final success = await WhatsAppShare.shareTransaction(
      transaction,
      accountProvider,
      contactProvider,
      phoneNumber: phoneNumber,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open WhatsApp. Please make sure WhatsApp is installed.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}


