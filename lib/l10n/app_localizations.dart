import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MoneyMove'**
  String get appTitle;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @editText.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editText;

  /// No description provided for @cancelText.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelText;

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteText;

  /// No description provided for @navigationTextHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationTextHome;

  /// No description provided for @navigationTextTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navigationTextTransactions;

  /// No description provided for @navigationTextDeudas.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get navigationTextDeudas;

  /// No description provided for @titleText.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleText;

  /// No description provided for @dateText.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateText;

  /// No description provided for @descriptionText.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionText;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @cat_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get cat_food;

  /// No description provided for @cat_transport.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get cat_transport;

  /// No description provided for @cat_leisure.
  ///
  /// In en, this message translates to:
  /// **'Leisure'**
  String get cat_leisure;

  /// No description provided for @cat_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get cat_health;

  /// No description provided for @cat_education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get cat_education;

  /// No description provided for @cat_church.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get cat_church;

  /// No description provided for @cat_job.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get cat_job;

  /// No description provided for @cat_pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get cat_pet;

  /// No description provided for @cat_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get cat_home;

  /// No description provided for @cat_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get cat_services;

  /// No description provided for @cat_debt.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get cat_debt;

  /// No description provided for @cat_others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get cat_others;

  /// No description provided for @titleTransactionsScreen.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get titleTransactionsScreen;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet 😴'**
  String get noTransactionsYet;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @chooseCategoryManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose category for your transaction'**
  String get chooseCategoryManualTitle;

  /// No description provided for @editTransaccionText.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaccionText;

  /// No description provided for @accitionNotUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get accitionNotUndone;

  /// No description provided for @deleteTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransactionText;

  /// No description provided for @deletedTransactionMessage.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get deletedTransactionMessage;

  /// No description provided for @deletedDeudaMessege.
  ///
  /// In en, this message translates to:
  /// **'Debt deleted'**
  String get deletedDeudaMessege;

  /// No description provided for @titleDeudasScreen.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get titleDeudasScreen;

  /// No description provided for @noDeudasYet.
  ///
  /// In en, this message translates to:
  /// **'No debts yet 😴'**
  String get noDeudasYet;

  /// No description provided for @addDeuda.
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDeuda;

  /// No description provided for @editDeudaText.
  ///
  /// In en, this message translates to:
  /// **'Edit Debt'**
  String get editDeudaText;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Idioma cambiado'**
  String get changeLanguage;

  /// No description provided for @seeAllTransactionsText.
  ///
  /// In en, this message translates to:
  /// **'See all transactions'**
  String get seeAllTransactionsText;

  /// No description provided for @seeAllDeudasText.
  ///
  /// In en, this message translates to:
  /// **'See all debts'**
  String get seeAllDeudasText;

  /// No description provided for @transactionNotExist.
  ///
  /// In en, this message translates to:
  /// **'The transaction does not exist'**
  String get transactionNotExist;

  /// No description provided for @transactionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetailsTitle;

  /// No description provided for @expenseMade.
  ///
  /// In en, this message translates to:
  /// **'Expense Made'**
  String get expenseMade;

  /// No description provided for @incomeReceived.
  ///
  /// In en, this message translates to:
  /// **'Income Received'**
  String get incomeReceived;

  /// No description provided for @inputTitleTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Transaction Title'**
  String get inputTitleTransactionText;

  /// No description provided for @writeTitleTransactionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter transaction title'**
  String get writeTitleTransactionHint;

  /// No description provided for @descriptionTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Transaction Description'**
  String get descriptionTransactionText;

  /// No description provided for @optionalHintText.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalHintText;

  /// No description provided for @expenseText.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseText;

  /// No description provided for @incomeText.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeText;

  /// No description provided for @amountText.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountText;

  /// No description provided for @analizingText.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analizingText;

  /// No description provided for @selectCategoryText.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategoryText;

  /// No description provided for @saveTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransactionText;

  /// No description provided for @payableText.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get payableText;

  /// No description provided for @receivableText.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get receivableText;

  /// No description provided for @withInvolucradoText.
  ///
  /// In en, this message translates to:
  /// **'With'**
  String get withInvolucradoText;

  /// No description provided for @venceText.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get venceText;

  /// No description provided for @allAlrightDeudasText.
  ///
  /// In en, this message translates to:
  /// **'All settled 🎉'**
  String get allAlrightDeudasText;

  /// No description provided for @noOutstandingDeudas.
  ///
  /// In en, this message translates to:
  /// **'You have no outstanding debts'**
  String get noOutstandingDeudas;

  /// No description provided for @transactionsWillAppearHereText.
  ///
  /// In en, this message translates to:
  /// **'Your transactions will appear here'**
  String get transactionsWillAppearHereText;

  /// No description provided for @deudaTitleText.
  ///
  /// In en, this message translates to:
  /// **'Debt Title'**
  String get deudaTitleText;

  /// No description provided for @deudaEjTitleText.
  ///
  /// In en, this message translates to:
  /// **'Ex. Shoe purchase'**
  String get deudaEjTitleText;

  /// No description provided for @yoDeboText.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get yoDeboText;

  /// No description provided for @meDebenText.
  ///
  /// In en, this message translates to:
  /// **'They owe me'**
  String get meDebenText;

  /// No description provided for @involucradoNameHint.
  ///
  /// In en, this message translates to:
  /// **'Person\'s name'**
  String get involucradoNameHint;

  /// No description provided for @saveDeudaText.
  ///
  /// In en, this message translates to:
  /// **'Save Debt'**
  String get saveDeudaText;

  /// No description provided for @quienLeDeboText.
  ///
  /// In en, this message translates to:
  /// **'Who do I owe?'**
  String get quienLeDeboText;

  /// No description provided for @quienMeDebeText.
  ///
  /// In en, this message translates to:
  /// **'Who owes me?'**
  String get quienMeDebeText;

  /// No description provided for @totalBalanceText.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalanceText;

  /// No description provided for @incomesText.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomesText;

  /// No description provided for @expencesText.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expencesText;

  /// No description provided for @lastTransactionsText.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get lastTransactionsText;

  /// No description provided for @lastDeudasText.
  ///
  /// In en, this message translates to:
  /// **'Outstanding debts'**
  String get lastDeudasText;

  /// No description provided for @areYouSureTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re sure?'**
  String get areYouSureTitle;

  /// No description provided for @deudasPorPagarText.
  ///
  /// In en, this message translates to:
  /// **'Debts to pay'**
  String get deudasPorPagarText;

  /// No description provided for @deudasPorCobrarText.
  ///
  /// In en, this message translates to:
  /// **'Debts to collect'**
  String get deudasPorCobrarText;

  /// No description provided for @pagadaText.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get pagadaText;

  /// No description provided for @progressText.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressText;

  /// No description provided for @abonadoText.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get abonadoText;

  /// No description provided for @restanteText.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get restanteText;

  /// No description provided for @toText.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get toText;

  /// No description provided for @fromText.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get fromText;

  /// No description provided for @cobradoText.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get cobradoText;

  /// No description provided for @pagadoText.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get pagadoText;

  /// No description provided for @abonarText.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get abonarText;

  /// No description provided for @insertAmountPaymentText.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount to pay'**
  String get insertAmountPaymentText;

  /// No description provided for @abonoForText.
  ///
  /// In en, this message translates to:
  /// **'Credit towards'**
  String get abonoForText;

  /// No description provided for @pagoDeText.
  ///
  /// In en, this message translates to:
  /// **'Payment for'**
  String get pagoDeText;

  /// No description provided for @confirmText.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmText;

  /// No description provided for @markAsPaidText.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid?'**
  String get markAsPaidText;

  /// No description provided for @markAsPaidConfirmText.
  ///
  /// In en, this message translates to:
  /// **'This will pay off the remaining balance.'**
  String get markAsPaidConfirmText;

  /// No description provided for @deudaPaidSucessText.
  ///
  /// In en, this message translates to:
  /// **'Debt paid successfully! 🎉'**
  String get deudaPaidSucessText;

  /// No description provided for @totalPorPagarText.
  ///
  /// In en, this message translates to:
  /// **'Total to Pay'**
  String get totalPorPagarText;

  /// No description provided for @totalPorCobrarText.
  ///
  /// In en, this message translates to:
  /// **'Total to Collect'**
  String get totalPorCobrarText;

  /// No description provided for @paidDeudasText.
  ///
  /// In en, this message translates to:
  /// **'Paid debts'**
  String get paidDeudasText;

  /// No description provided for @recivedDeudasText.
  ///
  /// In en, this message translates to:
  /// **'Collected debts'**
  String get recivedDeudasText;

  /// No description provided for @abonoSucessText.
  ///
  /// In en, this message translates to:
  /// **'Payment made successfully'**
  String get abonoSucessText;

  /// No description provided for @putAmountHigherZeroText.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get putAmountHigherZeroText;

  /// No description provided for @putAmountLowerText.
  ///
  /// In en, this message translates to:
  /// **'The amount exceeds the remaining balance'**
  String get putAmountLowerText;

  /// No description provided for @errorHasOccurredText.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error has occurred'**
  String get errorHasOccurredText;

  /// No description provided for @seeAsociatedDeuda.
  ///
  /// In en, this message translates to:
  /// **'See associated debt'**
  String get seeAsociatedDeuda;

  /// No description provided for @debtdescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Debt Description'**
  String get debtdescriptionText;

  /// No description provided for @limitDateText.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get limitDateText;

  /// No description provided for @noHistorialText.
  ///
  /// In en, this message translates to:
  /// **'No history'**
  String get noHistorialText;

  /// No description provided for @noPaidDeudasText.
  ///
  /// In en, this message translates to:
  /// **'No paid debts in this section yet.'**
  String get noPaidDeudasText;

  /// No description provided for @filtrarText.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filtrarText;

  /// No description provided for @hoyText.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get hoyText;

  /// No description provided for @thisWeekText.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeekText;

  /// No description provided for @thisMonthText.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonthText;

  /// No description provided for @thisYearText.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get thisYearText;

  /// No description provided for @todoText.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get todoText;

  /// No description provided for @seeSettledDeudasText.
  ///
  /// In en, this message translates to:
  /// **'See settled debts'**
  String get seeSettledDeudasText;

  /// No description provided for @generateAutoTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Generate transaction automatically'**
  String get generateAutoTransactionText;

  /// No description provided for @lentFromText.
  ///
  /// In en, this message translates to:
  /// **'Money lent from'**
  String get lentFromText;

  /// No description provided for @lentToText.
  ///
  /// In en, this message translates to:
  /// **'Money lent to'**
  String get lentToText;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @darkModeText.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeText;

  /// No description provided for @languageText.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageText;

  /// No description provided for @pantallaText.
  ///
  /// In en, this message translates to:
  /// **'Screen'**
  String get pantallaText;

  /// No description provided for @generalText.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalText;

  /// No description provided for @stadisticText.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stadisticText;

  /// No description provided for @savingRateText.
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get savingRateText;

  /// No description provided for @wellDoneText.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get wellDoneText;

  /// No description provided for @beCarefulText.
  ///
  /// In en, this message translates to:
  /// **'Be careful'**
  String get beCarefulText;

  /// No description provided for @dailyExpenseText.
  ///
  /// In en, this message translates to:
  /// **'Daily Spend'**
  String get dailyExpenseText;

  /// No description provided for @promedioEstimadoText.
  ///
  /// In en, this message translates to:
  /// **'Est. average'**
  String get promedioEstimadoText;

  /// No description provided for @flujoNetoText.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get flujoNetoText;

  /// No description provided for @ingresosVsGastosText.
  ///
  /// In en, this message translates to:
  /// **'Income - Expenses'**
  String get ingresosVsGastosText;

  /// No description provided for @bigerExpensesText.
  ///
  /// In en, this message translates to:
  /// **'Largest Expense'**
  String get bigerExpensesText;

  /// No description provided for @saldoEvolutionText.
  ///
  /// In en, this message translates to:
  /// **'Balance Evolution'**
  String get saldoEvolutionText;

  /// No description provided for @cashFlowText.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlowText;

  /// No description provided for @categoryExpencesText.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get categoryExpencesText;

  /// No description provided for @noExpensesThisPeriodText.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get noExpensesThisPeriodText;

  /// No description provided for @noExpensesText.
  ///
  /// In en, this message translates to:
  /// **'No expenses'**
  String get noExpensesText;

  /// No description provided for @noConectionModeText.
  ///
  /// In en, this message translates to:
  /// **'No Connection Mode'**
  String get noConectionModeText;

  /// No description provided for @noConectionModeDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'It seems you are offline. You can continue using the app, but changes from other devices won\'t be reflected until you regain connection.'**
  String get noConectionModeDescriptionText;

  /// No description provided for @noShowAgainText.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show this again'**
  String get noShowAgainText;

  /// No description provided for @gotItText.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotItText;

  /// No description provided for @noConecctionAddTraxText.
  ///
  /// In en, this message translates to:
  /// **'Saved on device. It will upload when online ☁️⏳'**
  String get noConecctionAddTraxText;

  /// No description provided for @savedTrasactionSuccessText.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved successfully ✅'**
  String get savedTrasactionSuccessText;

  /// No description provided for @welcomeText.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MoneyMove!'**
  String get welcomeText;

  /// No description provided for @emailText.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailText;

  /// No description provided for @paswordText.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get paswordText;

  /// No description provided for @loginText.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginText;

  /// No description provided for @orContinueWithText.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWithText;

  /// No description provided for @errorAlEntrarEnText.
  ///
  /// In en, this message translates to:
  /// **'Error logging in'**
  String get errorAlEntrarEnText;

  /// No description provided for @filtrosText.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtrosText;

  /// No description provided for @profileText.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileText;

  /// No description provided for @sharedSpaceText.
  ///
  /// In en, this message translates to:
  /// **'Shared Space'**
  String get sharedSpaceText;

  /// No description provided for @sharedSpaceDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Manage your finances together with someone else'**
  String get sharedSpaceDescriptionText;

  /// No description provided for @sharedSpaceLargeDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Connect your account with a partner, family member, or associate. View unified balances, track joint transactions, and reach your financial goals by working as a single team.'**
  String get sharedSpaceLargeDescriptionText;

  /// No description provided for @inviteSomeoneText.
  ///
  /// In en, this message translates to:
  /// **'Invite someone'**
  String get inviteSomeoneText;

  /// No description provided for @inviteSomeoneDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Share your financial space with someone else. Manage your finances together and achieve your economic goals as a team.'**
  String get inviteSomeoneDescriptionText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
