import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../database/models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/contact_provider.dart';
import '../../utils/whatsapp_share.dart';

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

    Color amountColor;
    IconData typeIcon;
    String typeLabel;
    Color backgroundColor;
    
    if (transaction.type == 'income') {
      amountColor = Colors.green;
      typeIcon = Icons.arrow_downward_rounded;
      typeLabel = 'Income';
      backgroundColor = Colors.green;
    } else if (transaction.type == 'expense') {
      amountColor = Colors.red;
      typeIcon = Icons.arrow_upward_rounded;
      typeLabel = 'Expense';
      backgroundColor = Colors.red;
    } else {
      amountColor = Colors.blue;
      typeIcon = Icons.swap_horiz_rounded;
      typeLabel = 'Transfer';
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
          title: const Text(
            'Transaction Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareViaWhatsApp(context),
              tooltip: 'Share via WhatsApp',
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
                    'Transaction Details',
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
                    label: 'Date',
                    value: formattedDate,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Account (or From Account for transfers)
                  if (accountName != 'N/A')
                    _buildDetailCard(
                      context,
                      icon: Icons.account_balance_wallet_rounded,
                      label: transaction.type == 'transfer' ? 'From Account' : 'Account',
                      value: accountName,
                    ),
                  
                  // To Account (for transfers)
                  if (secondAccountName != null && secondAccountName != 'N/A') ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'To Account',
                      value: secondAccountName,
                    ),
                  ],
                  
                  // Contact
                  if (contactName != 'N/A') ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.person_rounded,
                      label: 'Contact',
                      value: contactName,
                    ),
                  ],
                  
                  // Bill Number
                  if (transaction.billNumber != null && transaction.billNumber!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.receipt_rounded,
                      label: 'Bill Number',
                      value: transaction.billNumber!,
                    ),
                  ],
                  
                  // Company Name
                  if (transaction.companyName != null && transaction.companyName!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.business_rounded,
                      label: 'Company',
                      value: transaction.companyName!,
                    ),
                  ],
                  
                  // Remark
                  if (transaction.remark != null && transaction.remark!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailCard(
                      context,
                      icon: Icons.note_rounded,
                      label: 'Remark',
                      value: transaction.remark!,
                      isMultiline: true,
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
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
      widget.transaction,
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
    } else if (success && phoneNumber != null && context.mounted) {
      // Show a helpful message if sharing with phone number
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If WhatsApp says the number isn\'t registered, try sharing without phone number option.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildShareButton(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: ElevatedButton.icon(
        onPressed: () => _shareViaWhatsApp(context),
        icon: const Icon(Icons.message, size: 20),
        label: const Text('Share via WhatsApp'),
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

