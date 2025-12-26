/// Utilitaires pour la génération et export d'Excel
/// Version simplifiée avec CSV au lieu d'Excel

import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExcelUtils {
  /// Génère un fichier CSV de facturation
  static Future<Uint8List?> generateInvoiceExcel({
    required List<Map<String, dynamic>> data,
    required String clientFullName,
    required String clientCategory,
    required String clientAxis,
    required String clientAddress,
    required String clientPhone,
    required String contractReference,
  }) async {
    try {
      final StringBuffer csv = StringBuffer();

      // En-têtes client
      csv.writeln('CLIENT,$clientFullName');
      csv.writeln('CONTRAT,$contractReference');
      csv.writeln('ADRESSE,$clientAddress');
      csv.writeln('TELEPHONE,$clientPhone');
      csv.writeln('CATEGORIE,$clientCategory');
      csv.writeln('AXE,$clientAxis');
      csv.writeln('');

      // En-têtes tableau
      csv.writeln(
        'Numéro Facture,Date Planification,Date Facturation,Type Traitement,État Planning,Mode Paiement,État Paiement,Montant',
      );

      // Données
      for (final item in data) {
        csv.writeln(
          '${item["facture_numero"] ?? "N/A"},${item["date_planification"] ?? "N/A"},${item["date_facturation"] ?? "N/A"},${item["type_traitement"] ?? "N/A"},${item["etat_planning"] ?? "N/A"},${item["mode_paiement"] ?? "N/A"},${item["etat_paiement"] ?? "N/A"},${item["montant"] ?? 0}',
        );
      }

      // Retourner en bytes
      return Uint8List.fromList(csv.toString().codeUnits);
    } catch (e) {
      return null;
    }
  }

  /// Sauvegarde le fichier sur le téléphone
  static Future<String?> saveInvoiceExcel({
    required Uint8List excelBytes,
    required String clientName,
  }) async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        return null;
      }

      final timestamp = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
      final filename = 'Facture_${clientName}_$timestamp.csv';
      final file = File('${directory.path}/$filename');

      await file.writeAsBytes(excelBytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Génère et sauvegarde directement un fichier de facturation
  static Future<String?> generateAndSaveInvoiceExcel({
    required List<Map<String, dynamic>> data,
    required String clientFullName,
    required String clientCategory,
    required String clientAxis,
    required String clientAddress,
    required String clientPhone,
    required String contractReference,
  }) async {
    try {
      final excelBytes = await generateInvoiceExcel(
        data: data,
        clientFullName: clientFullName,
        clientCategory: clientCategory,
        clientAxis: clientAxis,
        clientAddress: clientAddress,
        clientPhone: clientPhone,
        contractReference: contractReference,
      );

      if (excelBytes == null) return null;

      return await saveInvoiceExcel(
        excelBytes: excelBytes,
        clientName: clientFullName,
      );
    } catch (e) {
      return null;
    }
  }
}
