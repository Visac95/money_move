// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MoneyMove';

  @override
  String get noDescription => 'No description';

  @override
  String get editText => 'Edit';

  @override
  String get deleteText => 'Delete';

  @override
  String get navigationTextHome => 'Home';

  @override
  String get navigationTextTransactions => 'Transactions';

  @override
  String get navigationTextDeudas => 'Debts';

  @override
  String get titleText => 'Title';

  @override
  String get dateText => 'Date';

  @override
  String get descriptionText => 'Description';

  @override
  String get category => 'Category';

  @override
  String get titleTransactionsScreen => 'Transactions';

  @override
  String get noTransactionsYet => 'No transactions yet 😴';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get chooseCategoryManualTitle =>
      'Choose category for your transaction';

  @override
  String get editTransaccionText => 'Edit Transaction';

  @override
  String get deleteTransactionText => 'Delete Transaction';

  @override
  String get deletedTransactionMessage => 'Transaction deleted';

  @override
  String get titleDeudasScreen => 'Debts';

  @override
  String get noDeudasYet => 'No debts yet 😴';

  @override
  String get addDeuda => 'Add Debt';

  @override
  String get editDeudaText => 'Edit Debt';

  @override
  String get changeLanguage => 'Language changed';

  @override
  String get seeAllTransactionsText => 'See all transactions';

  @override
  String get transactionNotExist => 'The transaction does not exist';

  @override
  String get transactionDetailsTitle => 'Transaction Details';

  @override
  String get expenseMade => 'Expense Made';

  @override
  String get incomeReceived => 'Income Received';
}
