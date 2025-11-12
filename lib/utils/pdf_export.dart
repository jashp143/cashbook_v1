import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../database/models/transaction.dart';
import '../database/models/account.dart';
import '../database/models/contact.dart';

class PDFExport {
  static Future<File> generateTransactionReport({
    required List<Transaction> transactions,
    List<Account>? accounts,
    List<Contact>? contacts,
    String? accountFilter,
    String? contactFilter,
    String? dateRange,
    double? accountBalance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 16),
          _buildFilters(
            accountFilter: accountFilter,
            contactFilter: contactFilter,
            dateRange: dateRange,
          ),
          pw.SizedBox(height: 20),
          _buildTransactionTable(transactions, accounts, contacts),
          pw.SizedBox(height: 20),
          _buildSummary(transactions, accountBalance: accountBalance),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/transaction_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey400, width: 2),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Transaction Report',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated on ${DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFilters({
    String? accountFilter,
    String? contactFilter,
    String? dateRange,
  }) {
    final filters = <pw.Widget>[];
    if (accountFilter != null) {
      filters.add(
        pw.Row(
          children: [
            pw.Text('Account: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            pw.Text(accountFilter, style: const pw.TextStyle(fontSize: 11)),
          ],
        ),
      );
    }
    if (contactFilter != null) {
      filters.add(
        pw.Row(
          children: [
            pw.Text('Contact: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            pw.Text(contactFilter, style: const pw.TextStyle(fontSize: 11)),
          ],
        ),
      );
    }
    if (dateRange != null) {
      filters.add(
        pw.Row(
          children: [
            pw.Text('Date Range: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            pw.Text(dateRange, style: const pw.TextStyle(fontSize: 11)),
          ],
        ),
      );
    }

    if (filters.isEmpty) return pw.SizedBox.shrink();

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Filters Applied',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 8),
          ...filters.map((filter) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: filter,
              )),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionTable(
    List<Transaction> transactions,
    List<Account>? accounts,
    List<Contact>? contacts,
  ) {
    if (transactions.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        child: pw.Center(
          child: pw.Text(
            'No transactions found',
            style: pw.TextStyle(
              fontSize: 14,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 1,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2), // Date
        1: const pw.FlexColumnWidth(1.0), // Type
        2: const pw.FlexColumnWidth(1.2), // Amount
        3: const pw.FlexColumnWidth(1.3), // Account
        4: const pw.FlexColumnWidth(1.2), // Contact
        5: const pw.FlexColumnWidth(1.5), // Bill/Company
        6: const pw.FlexColumnWidth(2.0), // Remark
      },
      children: [
        _buildTableHeader(),
        ...transactions.map((transaction) => _buildTableRow(
              transaction,
              accounts,
              contacts,
            )),
      ],
    );
  }

  static pw.TableRow _buildTableHeader() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            'Date',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.grey900,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            'Type',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.grey900,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            'Amount',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.grey900,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            'Account',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.grey900,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            'Contact',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.grey900,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            'Bill/Company',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.grey900,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            'Remark',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
              color: PdfColors.grey900,
            ),
          ),
        ),
      ],
    );
  }

  static pw.TableRow _buildTableRow(
    Transaction transaction,
    List<Account>? accounts,
    List<Contact>? contacts,
  ) {
    final accountName = accounts != null && accounts.isNotEmpty
        ? accounts
                .firstWhere(
                  (a) => a.id == transaction.accountId,
                  orElse: () => accounts.first,
                )
                .name
        : 'N/A';
    final contactName = transaction.contactId != null &&
            contacts != null &&
            contacts.isNotEmpty
        ? contacts
                .firstWhere(
                  (c) => c.id == transaction.contactId,
                  orElse: () => contacts.first,
                )
                .name
        : 'N/A';

    // Format date
    String formattedDate = transaction.date;
    try {
      final date = DateFormat('yyyy-MM-dd').parse(transaction.date);
      formattedDate = DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      // Keep original format if parsing fails
    }

    // Determine type color
    PdfColor typeColor = PdfColors.grey800;
    if (transaction.type == 'income') {
      typeColor = PdfColors.green700;
    } else if (transaction.type == 'expense') {
      typeColor = PdfColors.red700;
    } else if (transaction.type == 'transfer') {
      typeColor = PdfColors.blue700;
    }

    // Build bill/company info
    String billCompanyInfo = '';
    if (transaction.billNumber != null && transaction.billNumber!.isNotEmpty) {
      billCompanyInfo = 'Bill: ${transaction.billNumber}';
    }
    if (transaction.companyName != null && transaction.companyName!.isNotEmpty) {
      if (billCompanyInfo.isNotEmpty) {
        billCompanyInfo += '\n';
      }
      billCompanyInfo += transaction.companyName!;
    }
    if (billCompanyInfo.isEmpty) {
      billCompanyInfo = '-';
    }

    return pw.TableRow(
      decoration: const pw.BoxDecoration(
        color: PdfColors.white,
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            formattedDate,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            transaction.type.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: typeColor,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            'Rs ${transaction.amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: typeColor,
            ),
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            accountName,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            contactName,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            billCompanyInfo,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            transaction.remark ?? '-',
            style: const pw.TextStyle(fontSize: 10),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(List<Transaction> transactions, {double? accountBalance}) {
    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalTransfer = transactions
        .where((t) => t.type == 'transfer')
        .fold(0.0, (sum, t) => sum + t.amount);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey400, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Transaction Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          if (accountBalance != null) ...[
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: accountBalance >= 0
                    ? PdfColors.green50
                    : PdfColors.red50,
                border: pw.Border.all(
                  color: accountBalance >= 0
                      ? PdfColors.green700
                      : PdfColors.red700,
                  width: 1.5,
                ),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Account Balance:',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey900,
                    ),
                  ),
                  pw.Text(
                    'Rs ${accountBalance.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: accountBalance >= 0
                          ? PdfColors.green700
                          : PdfColors.red700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Income:',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
              pw.Text(
                'Rs ${totalIncome.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green700,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Expense:',
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
              ),
              pw.Text(
                'Rs ${totalExpense.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red700,
                ),
              ),
            ],
          ),
          if (totalTransfer > 0) ...[
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Transfer:',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                ),
                pw.Text(
                  'Rs ${totalTransfer.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
              ],
            ),
          ],
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey300, height: 1),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Transactions:',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.Text(
                '${transactions.length}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          'This is a computer-generated report. Please verify all details.',
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

