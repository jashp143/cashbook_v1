import 'package:url_launcher/url_launcher.dart';
import '../database/models/transaction.dart';
import '../providers/account_provider.dart';
import '../providers/contact_provider.dart';
import 'package:intl/intl.dart';

class WhatsAppShare {
  /// Formats transaction details into a readable WhatsApp message
  static String formatTransactionMessage(
    Transaction transaction,
    AccountProvider accountProvider,
    ContactProvider contactProvider,
  ) {
    final accountName = transaction.accountId != null
        ? accountProvider.getAccountById(transaction.accountId)?.name ?? 'N/A'
        : 'N/A';
    final secondAccountName = transaction.secondAccountId != null
        ? accountProvider.getAccountById(transaction.secondAccountId)?.name ?? 'N/A'
        : null;
    final contactName = transaction.contactId != null
        ? contactProvider.getContactById(transaction.contactId)?.name ?? 'N/A'
        : 'N/A';

    // Format date
    String formattedDate = transaction.date;
    try {
      final date = DateFormat('yyyy-MM-dd').parse(transaction.date);
      formattedDate = DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      // Keep original format
    }

    // Build professional message based on transaction type
    final buffer = StringBuffer();
    
    if (transaction.type == 'income') {
      // Income message format
      buffer.writeln('*💰 Income Transaction*');
      buffer.writeln('');
      
      // Main message line
      if (contactName != 'N/A' && contactName.isNotEmpty) {
        if (accountName != 'N/A') {
          buffer.writeln('Received *₹${transaction.amount.toStringAsFixed(2)}* from *$contactName* in *$accountName* account on *$formattedDate*.');
        } else {
          buffer.writeln('Received *₹${transaction.amount.toStringAsFixed(2)}* from *$contactName* on *$formattedDate*.');
        }
      } else {
        if (accountName != 'N/A') {
          buffer.writeln('Received *₹${transaction.amount.toStringAsFixed(2)}* in *$accountName* account on *$formattedDate*.');
        } else {
          buffer.writeln('Received *₹${transaction.amount.toStringAsFixed(2)}* on *$formattedDate*.');
        }
      }
      
      // Additional details
      if (transaction.billNumber != null && transaction.billNumber!.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('*Bill Number:* ${transaction.billNumber}');
      }
      
      if (transaction.companyName != null && transaction.companyName!.isNotEmpty) {
        buffer.writeln('*Company:* ${transaction.companyName}');
      }
      
      if (transaction.remark != null && transaction.remark!.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('*Note:* ${transaction.remark}');
      }
      
    } else if (transaction.type == 'expense') {
      // Expense message format
      buffer.writeln('*💸 Expense Transaction*');
      buffer.writeln('');
      
      // Main message line
      if (contactName != 'N/A' && contactName.isNotEmpty) {
        if (accountName != 'N/A') {
          buffer.writeln('Paid *₹${transaction.amount.toStringAsFixed(2)}* to *$contactName* from *$accountName* account on *$formattedDate*.');
        } else {
          buffer.writeln('Paid *₹${transaction.amount.toStringAsFixed(2)}* to *$contactName* on *$formattedDate*.');
        }
      } else {
        if (accountName != 'N/A') {
          buffer.writeln('Paid *₹${transaction.amount.toStringAsFixed(2)}* from *$accountName* account on *$formattedDate*.');
        } else {
          buffer.writeln('Paid *₹${transaction.amount.toStringAsFixed(2)}* on *$formattedDate*.');
        }
      }
      
      // Additional details
      if (transaction.billNumber != null && transaction.billNumber!.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('*Bill Number:* ${transaction.billNumber}');
      }
      
      if (transaction.companyName != null && transaction.companyName!.isNotEmpty) {
        buffer.writeln('*Company:* ${transaction.companyName}');
      }
      
      if (transaction.remark != null && transaction.remark!.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('*Note:* ${transaction.remark}');
      }
      
    } else {
      // Transfer message format
      buffer.writeln('*🔄 Transfer Transaction*');
      buffer.writeln('');
      
      if (accountName != 'N/A' && secondAccountName != null && secondAccountName != 'N/A') {
        buffer.writeln('Transferred *₹${transaction.amount.toStringAsFixed(2)}* from *$accountName* to *$secondAccountName* on *$formattedDate*.');
      } else if (accountName != 'N/A') {
        buffer.writeln('Transferred *₹${transaction.amount.toStringAsFixed(2)}* from *$accountName* on *$formattedDate*.');
      } else {
        buffer.writeln('Transferred *₹${transaction.amount.toStringAsFixed(2)}* on *$formattedDate*.');
      }
      
      if (transaction.remark != null && transaction.remark!.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('*Note:* ${transaction.remark}');
      }
    }

    return buffer.toString();
  }

  /// Formats phone number for WhatsApp URL
  /// WhatsApp requires international format without + sign
  /// Example: +91 98765 43210 -> 919876543210
  static String? _formatPhoneNumberForWhatsApp(String phoneNumber) {
    if (phoneNumber.isEmpty) return null;
    
    // Remove all non-digit characters (spaces, dashes, parentheses, +, etc.)
    var cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Handle common international dialing codes
    // Remove 00 prefix (international dialing code used in some countries)
    if (cleanPhone.startsWith('00') && cleanPhone.length > 2) {
      cleanPhone = cleanPhone.substring(2);
    }
    
    // Remove leading zeros (but keep at least one digit)
    // This handles cases like "091234567890" -> "91234567890"
    while (cleanPhone.startsWith('0') && cleanPhone.length > 1) {
      cleanPhone = cleanPhone.substring(1);
    }
    
    // Validate length - WhatsApp accepts 7-15 digits (E.164 format)
    if (cleanPhone.length < 7 || cleanPhone.length > 15) {
      // Invalid length
      return null;
    }
    
    return cleanPhone;
  }

  /// Shares transaction via WhatsApp
  /// Returns true if WhatsApp was opened successfully, false otherwise
  static Future<bool> shareTransaction(
    Transaction transaction,
    AccountProvider accountProvider,
    ContactProvider contactProvider, {
    String? phoneNumber,
  }) async {
    try {
      final message = formatTransactionMessage(
        transaction,
        accountProvider,
        contactProvider,
      );

      // URL encode the message
      final encodedMessage = Uri.encodeComponent(message);

      // Build WhatsApp URL
      String whatsappUrl;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Format phone number for WhatsApp
        final formattedPhone = _formatPhoneNumberForWhatsApp(phoneNumber);
        if (formattedPhone != null && formattedPhone.isNotEmpty) {
          // Use formatted phone number
          whatsappUrl = 'https://wa.me/$formattedPhone?text=$encodedMessage';
        } else {
          // Invalid phone format, share without specific number
          whatsappUrl = 'https://wa.me/?text=$encodedMessage';
        }
      } else {
        // Open WhatsApp without a specific contact
        whatsappUrl = 'https://wa.me/?text=$encodedMessage';
      }

      final uri = Uri.parse(whatsappUrl);
      
      // Try to launch directly - canLaunchUrl can be unreliable for deep links
      // launchUrl will return false if it can't launch, or throw an exception
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          // If externalApplication fails, try platformDefault
          return await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        }
        
        return launched;
      } catch (e) {
        // If launchUrl throws an exception, try with platformDefault as fallback
        try {
          return await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
        } catch (e2) {
          // If both fail, return false
          return false;
        }
      }
    } catch (e) {
      // Return false on any error
      return false;
    }
  }
}

