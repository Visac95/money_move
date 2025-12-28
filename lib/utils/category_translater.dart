import 'package:flutter/material.dart';
import 'package:money_move/config/app_constants.dart'; // 1. IMPORTA TUS CONSTANTES
import 'package:money_move/l10n/app_localizations.dart';

String getCategoryName(BuildContext context, String categoryKey) {
  final l10n = AppLocalizations.of(context)!;

  switch (categoryKey) {
    // 2. USA EL PREFIJO "AppConstants." EN CADA CASO
    case AppConstants.catFood:
      return l10n.cat_food;
    case AppConstants.catTransport:
      return l10n.cat_transport;
    case AppConstants.catLeisure:
      return l10n.cat_leisure;
    case AppConstants.catHealth:
      return l10n.cat_health;
    case AppConstants.catEducation:
      return l10n.cat_education;
    case AppConstants.catChurch:
      return l10n.cat_church;
    case AppConstants.catJob:
      return l10n.cat_job;
    case AppConstants.catPet:
      return l10n.cat_pet;
    case AppConstants.catHome:
      return l10n.cat_home;
    case AppConstants.catServices:
      return l10n.cat_services;
    case AppConstants.catDebt:
      return l10n.cat_debt;
    case AppConstants.catOthers:
      return l10n.cat_others;
    default:
      return 'Desconocido';
  }
}
