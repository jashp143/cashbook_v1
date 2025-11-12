import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../database/models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/contact_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/whatsapp_share.dart';
import '../../l10n/app_localizations.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadAccounts();
      context.read<ContactProvider>().loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountProvider = context.read<AccountProvider>();
    final contactProvider = context.read<ContactProvider>();
    
    final transaction = widget.transaction;

    final accountName = transaction.accountId != null
        ? accountProvider.getAccountById(transaction.accountId)?.name ?? 'N/A'
        : 'N/A';
    final secondAccountName = transaction.secondAccountId != null
        ? accountProvider.getAccountById(transaction.secondAccountId)?.name ?? 'N/A'
        : null;
    final contactName = transaction.contactId != null
        ? contactProvider.getContactById(transaction.contactId)?.name ?? 'N/A'
        : 'N/A';

    final l10n = AppLocalizations.of(context)!;
    Color amountColor;
    IconData typeIcon;
    String typeLabel;
    Color backgroundColor;
    
    if (transaction.type == 'income') {
      amountColor = Colors.green;
      typeIcon = Icons.arrow_downward_rounded;
      typeLabel = l10n.income;
      backgroundColor = Colors.green;
    } else if (transaction.type == 'expense') {
      amountColor = Colors.red;
      typeIcon = Icons.arrow_upward_rounded;
      typeLabel = l10n.expense;
      backgroundColor = Colors.red;
    } else {
      amountColor = Colors.blue;
      typeIcon = Icons.swap_horiz_rounded;
      typeLabel = l10n.transfer;
      backgroundColor = Colors.blue;
    }

    // Format date
    String formattedDate = transaction.date;
    try {
      final date = DateFormat('yyyy-MM-dd').parse(transaction.date);
      formattedDate = DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      // Keep original format
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Navigate back if pop didn't happen
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(
                l10n.transactionDetails,
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            },
          ),
          elevation: 0,
          actions: [
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTransaction(context),
                  tooltip: l10n.editTransaction,
                );
              },
            ),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteTransaction(context),
                  tooltip: l10n.deleteTransaction,
                );
              },
            ),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareViaWhatsApp(context),
                  tooltip: l10n.shareViaWhatsApp,
                );
              },
            ),
          ],
        ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Amount
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: backgroundColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: backgroundColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      typeIcon,
                      color: backgroundColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    typeLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: backgroundColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${transaction.amount.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.transactionDetails,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Date
                  _buildDetailCard(
                    context,
                    icon: Icons.calendar_today_rounded,
                    label: l10n.date,
                    value: formattedDate,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Account (or From Account for transfers)
                  if (accountName != 'N/A')
                    _buildDetailCard(
                      context,
                      icon: Icons.account_balance_wallet_rounded,
                      label: transaction.type == 'transfer' ? l10n.fromAccount : l10n.account,
                      value: accountName,
                    ),
                  
                  // To Account (for transfers)
                  if (secondAccountName != null && secondAccountName != 'N/A') ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      label: l10n.toAccount,
                      value: secondAccountName,
                    ),
                  ],
                  
                  // Contact
                  if (contactName != 'N/A') ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.person_rounded,
                      label: l10n.contact,
                      value: contactName,
                    ),
                  ],
                  
                  // Bill Number
                  if (transaction.billNumber != null && transaction.billNumber!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.receipt_rounded,
                      label: l10n.billNumber,
                      value: transaction.billNumber!,
                    ),
                  ],
                  
                  // Company Name
                  if (transaction.companyName != null && transaction.companyName!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.business_rounded,
                      label: l10n.company,
                      value: transaction.companyName!,
                    ),
                  ],
                  
                  // Remark
                  if (transaction.remark != null && transaction.remark!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.note_rounded,
                      label: l10n.remark,
                      value: transaction.remark!,
                      isMultiline: true,
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editTransaction(context),
                          icon: const Icon(Icons.edit, size: 20),
                          label: Text(l10n.edit),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _deleteTransaction(context),
                          icon: const Icon(Icons.delete, size: 20),
                          label: Text(l10n.delete),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Share Button
                  _buildShareButton(context),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 14,
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
                const SizedBox(height: 4),
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
      ),
    );
  }

  Future<void> _editTransaction(BuildContext context) async {
    final transaction = widget.transaction;
    
    // Navigate to the appropriate form screen based on transaction type
    String route;
    if (transaction.type == 'income') {
      route = '/income';
    } else if (transaction.type == 'expense') {
      route = '/expense';
    } else {
      route = '/transfer';
    }
    
    // Navigate with transaction as extra data for editing
    context.go(route, extra: transaction);
  }

  Future<void> _deleteTransaction(BuildContext context) async {
    final transaction = widget.transaction;
    final l10n = AppLocalizations.of(context)!;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(
          l10n.deleteTransactionConfirmation(transaction.type, transaction.amount.toStringAsFixed(0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && transaction.id != null) {
      try {
        final transactionProvider = context.read<TransactionProvider>();
        final accountProvider = context.read<AccountProvider>();
        
        await transactionProvider.deleteTransaction(
          transaction.id!,
          accountProvider,
        );

        if (mounted) {
          Fluttertoast.showToast(
            msg: l10n.transactionDeletedSuccessfully,
            toastLength: Toast.LENGTH_SHORT,
          );
          context.go('/');
        }
      } catch (e) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: l10n.errorDeletingTransaction(e.toString()),
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      }
    }
  }

  Future<void> _shareViaWhatsApp(BuildContext context) async {
    final accountProvider = context.read<AccountProvider>();
    final contactProvider = context.read<ContactProvider>();
    
    // Get contact phone number if available
    String? phoneNumber;
    String? contactName;
    if (widget.transaction.contactId != null) {
      final contact = contactProvider.getContactById(widget.transaction.contactId);
      phoneNumber = contact?.phone;
      contactName = contact?.name;
    }

    // If phone number exists, ask user how they want to share
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final l10n = AppLocalizations.of(context)!;
      final shareOption = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.shareViaWhatsApp),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (contactName != null) ...[
                Text('${l10n.contact}: $contactName'),
                const SizedBox(height: 8),
              ],
              Text('${l10n.phone}: $phoneNumber'),
              const SizedBox(height: 16),
              Text(
                l10n.chooseHowToShare,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.withPhoneNumberDescription,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.withoutPhoneNumberDescription,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('with_number'),
              child: Text(l10n.withPhoneNumber),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('without_number'),
              child: Text(l10n.withoutPhoneNumber),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(l10n.cancel),
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
      widget.transaction,
      accountProvider,
      contactProvider,
      phoneNumber: phoneNumber,
    );

    final l10n = AppLocalizations.of(context)!;
    if (!success && context.mounted) {
      Fluttertoast.showToast(
        msg: l10n.couldNotOpenWhatsApp,
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (success && phoneNumber != null && context.mounted) {
      // Show a helpful message if sharing with phone number
      Fluttertoast.showToast(
        msg: l10n.whatsAppNotRegisteredMessage,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  Widget _buildShareButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: ElevatedButton.icon(
        onPressed: () => _shareViaWhatsApp(context),
        icon: const Icon(Icons.message, size: 20),
        label: Text(l10n.shareViaWhatsApp),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366), // WhatsApp green
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

