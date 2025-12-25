import 'package:flutter/widgets.dart';
import 'package:money_move/l10n/app_localizations.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale){
    if (!AppLocalizations.supportedLocales.contains(locale)) return;
      _locale = locale;
      notifyListeners();
  }

  void clearLocale(){
    _locale = null;
    notifyListeners();
  } 

}