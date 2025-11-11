import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../database/models/transaction.dart';
import '../database/models/account.dart';
import '../database/models/contact.dart';

class ExcelExport {
  static Future<File> generateTransactionReport({
    required List<Transaction> transactions,
    List<Account>? accounts,
    List<Contact>? contacts,
    String? accountFilter,
    String? contactFilter,
    String? dateRange,
    double? accountBalance,
  }) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    final sheet = excel['Transaction Report'];

    int currentRow = 0;

    // Title
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: currentRow));
    final titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    titleCell.value = TextCellValue('Transaction Report');
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 18,
      backgroundColorHex: ExcelColor.lightBlue,
      fontColorHex: ExcelColor.blue,
    );
    currentRow++;

    // Generated date
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: currentRow));
    final dateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    dateCell.value = TextCellValue(
        'Generated on ${DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now())}');
    dateCell.cellStyle = CellStyle(
      fontSize: 10,
      fontColorHex: ExcelColor.grey,
    );
    currentRow += 2;

    // Add filter info if any
    if (accountFilter != null || contactFilter != null || dateRange != null) {
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: currentRow));
      final filterTitleCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      filterTitleCell.value = TextCellValue('Filters Applied');
      filterTitleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
        backgroundColorHex: ExcelColor.grey,
      );
      currentRow++;

      if (accountFilter != null) {
        final labelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
        labelCell.value = TextCellValue('Account:');
        labelCell.cellStyle = CellStyle(bold: true, fontSize: 11);
        final valueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
        valueCell.value = TextCellValue(accountFilter);
        valueCell.cellStyle = CellStyle(fontSize: 11);
        currentRow++;
      }
      if (contactFilter != null) {
        final labelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
        labelCell.value = TextCellValue('Contact:');
        labelCell.cellStyle = CellStyle(bold: true, fontSize: 11);
        final valueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
        valueCell.value = TextCellValue(contactFilter);
        valueCell.cellStyle = CellStyle(fontSize: 11);
        currentRow++;
      }
      if (dateRange != null) {
        final labelCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
        labelCell.value = TextCellValue('Date Range:');
        labelCell.cellStyle = CellStyle(bold: true, fontSize: 11);
        final valueCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
        valueCell.value = TextCellValue(dateRange);
        valueCell.cellStyle = CellStyle(fontSize: 11);
        currentRow++;
      }
      currentRow++;
    }

    // Table header row
    final headerRow = [
      'Date',
      'Type',
      'Amount',
      'Account',
      'Contact',
      'Bill Number',
      'Company Name',
      'Remark',
    ];
    for (int col = 0; col < headerRow.length; col++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: currentRow));
      cell.value = TextCellValue(headerRow[col]);
      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 11,
        backgroundColorHex: ExcelColor.grey,
        fontColorHex: ExcelColor.white,
      );
    }
    currentRow++;

    // Add transactions
    for (var transaction in transactions) {
      final accountName = accounts != null && accounts.isNotEmpty
          ? accounts
                  .firstWhere(
                    (a) => a.id == transaction.accountId,
                    orElse: () => accounts.first,
                  )
                  .name ??
              'N/A'
          : 'N/A';
      final contactName = transaction.contactId != null &&
              contacts != null &&
              contacts.isNotEmpty
          ? contacts
                  .firstWhere(
                    (c) => c.id == transaction.contactId,
                    orElse: () => contacts.first,
                  )
                  .name ??
              'N/A'
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
      ExcelColor typeColor = ExcelColor.grey;
      if (transaction.type == 'income') {
        typeColor = ExcelColor.green;
      } else if (transaction.type == 'expense') {
        typeColor = ExcelColor.red;
      } else if (transaction.type == 'transfer') {
        typeColor = ExcelColor.blue;
      }

      // Date
      final dateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      dateCell.value = TextCellValue(formattedDate);
      dateCell.cellStyle = CellStyle(fontSize: 10);

      // Type
      final typeCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
      typeCell.value = TextCellValue(transaction.type.toUpperCase());
      typeCell.cellStyle = CellStyle(
        fontSize: 10,
        bold: true,
        fontColorHex: typeColor,
      );

      // Amount
      final amountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: currentRow));
      amountCell.value = DoubleCellValue(transaction.amount);
      amountCell.cellStyle = CellStyle(
        fontSize: 10,
        bold: true,
        fontColorHex: typeColor,
      );

      // Account
      final accountCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow));
      accountCell.value = TextCellValue(accountName);
      accountCell.cellStyle = CellStyle(fontSize: 10);

      // Contact
      final contactCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: currentRow));
      contactCell.value = TextCellValue(contactName);
      contactCell.cellStyle = CellStyle(fontSize: 10);

      // Bill Number
      final billCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: currentRow));
      billCell.value = TextCellValue(transaction.billNumber ?? '-');
      billCell.cellStyle = CellStyle(fontSize: 10);

      // Company Name
      final companyCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: currentRow));
      companyCell.value = TextCellValue(transaction.companyName ?? '-');
      companyCell.cellStyle = CellStyle(fontSize: 10);

      // Remark
      final remarkCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: currentRow));
      remarkCell.value = TextCellValue(transaction.remark ?? '-');
      remarkCell.cellStyle = CellStyle(fontSize: 10);

      currentRow++;
    }

    // Add empty row before summary
    currentRow++;

    // Add summary
    final totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalTransfer = transactions
        .where((t) => t.type == 'transfer')
        .fold(0.0, (sum, t) => sum + t.amount);

    // Summary title
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    final summaryTitleCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    summaryTitleCell.value = TextCellValue('Transaction Summary');
    summaryTitleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      backgroundColorHex: ExcelColor.grey,
    );
    currentRow++;

    // Account Balance (if provided)
    if (accountBalance != null) {
      final balanceLabelCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      balanceLabelCell.value = TextCellValue('Account Balance:');
      balanceLabelCell.cellStyle = CellStyle(bold: true, fontSize: 12);
      final balanceValueCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
      balanceValueCell.value = DoubleCellValue(accountBalance);
      balanceValueCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
        fontColorHex: accountBalance >= 0 ? ExcelColor.green : ExcelColor.red,
      );
      currentRow++;
      // Empty row for spacing
      currentRow++;
    }

    // Total Income
    final incomeLabelCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    incomeLabelCell.value = TextCellValue('Total Income:');
    incomeLabelCell.cellStyle = CellStyle(bold: true, fontSize: 11);
    final incomeValueCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    incomeValueCell.value = DoubleCellValue(totalIncome);
    incomeValueCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.green,
    );
    currentRow++;

    // Total Expense
    final expenseLabelCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    expenseLabelCell.value = TextCellValue('Total Expense:');
    expenseLabelCell.cellStyle = CellStyle(bold: true, fontSize: 11);
    final expenseValueCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    expenseValueCell.value = DoubleCellValue(totalExpense);
    expenseValueCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.red,
    );
    currentRow++;

    // Total Transfer (if applicable)
    if (totalTransfer > 0) {
      final transferLabelCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
      transferLabelCell.value = TextCellValue('Total Transfer:');
      transferLabelCell.cellStyle = CellStyle(bold: true, fontSize: 11);
      final transferValueCell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
      transferValueCell.value = DoubleCellValue(totalTransfer);
      transferValueCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 11,
        fontColorHex: ExcelColor.blue,
      );
      currentRow++;
    }

    // Total Transactions count
    currentRow++;
    final countLabelCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    countLabelCell.value = TextCellValue('Total Transactions:');
    countLabelCell.cellStyle = CellStyle(bold: true, fontSize: 12);
    final countValueCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow));
    countValueCell.value = IntCellValue(transactions.length);
    countValueCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 12,
    );

    // Auto-size columns
    for (int col = 0; col < 8; col++) {
      sheet.setColumnWidth(col, 15);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/transaction_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    return file;
  }
}

