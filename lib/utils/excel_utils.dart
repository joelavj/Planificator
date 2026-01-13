import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class FolderManager {
  static List<Directory> initDesktopStructure() {
    final desktop = _getDesktopPath();
    final dossiers = ["Factures", "Traitements"];
    List<Directory> paths = [];

    for (var nom in dossiers) {
      final dir = Directory(p.join(desktop.path, nom));
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      paths.add(dir);
    }
    return paths;
  }

  static Directory _getDesktopPath() {
    String home = "";
    Map<String, String> envVars = Platform.environment;

    if (Platform.isWindows) {
      home = envVars['USERPROFILE'] ?? "";
    } else if (Platform.isLinux || Platform.isMacOS) {
      home = envVars['HOME'] ?? "";
    }

    var desktop = Directory(p.join(home, 'Desktop'));
    if (!desktop.existsSync()) {
      desktop = Directory(p.join(home, 'Bureau'));
    }
    return desktop;
  }
}

class ExcelService {
  final List<Directory> paths = FolderManager.initDesktopStructure();

  // --- LOGIQUE COMMUNE POUR LE NETTOYAGE DU NOM (safe_client_name) ---
  String _getSafeName(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'_+$'), '');
  }

  // --- 1. FONCTION : generate_comprehensive_facture_excel (Annuel) ---
  Future<void> generateComprehensiveFactureExcel(
    List<Map<String, dynamic>> data,
    String clientFullName,
  ) async {
    final int reportPeriod = DateTime.now().year;
    final String safeName = _getSafeName(clientFullName);

    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.name = "Factures $clientFullName $reportPeriod";

    int currentRow = 1;
    currentRow = _insertClientHeader(sheet, data, clientFullName, currentRow);

    // Titre fusionné
    sheet.getRangeByIndex(currentRow, 1, currentRow, 9).merge();
    sheet
        .getRangeByIndex(currentRow, 1)
        .setText("Rapport de Facturation pour la période : $reportPeriod");
    sheet.getRangeByIndex(currentRow, 1).cellStyle = _getHeaderStyle(workbook);
    currentRow += 2;

    currentRow = _insertMainTable(
      sheet,
      workbook,
      data,
      currentRow,
      isMonthly: false,
    );

    // Logique Totaux (Simule Pandas sum/groupby)
    _insertTotals(sheet, workbook, data, currentRow, isMonthly: false);

    _saveFile(
      workbook,
      paths[0],
      "Rapport_Factures_${safeName}_$reportPeriod.xlsx",
    );
  }

  // --- 2. FONCTION : generer_facture_excel (Mensuel ou Annuel) ---
  Future<void> genererFactureExcel(
    List<Map<String, dynamic>> data,
    String clientFullName,
    int year,
    int month,
  ) async {
    final String safeName = _getSafeName(clientFullName);

    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    int currentRow = 1;
    currentRow = _insertClientHeader(sheet, data, clientFullName, currentRow);

    // Titre - varie selon que c'est un mois spécifique ou tous les mois
    String titleText;
    String filename;

    if (month == 0) {
      // Tous les mois (annuel)
      titleText = "Rapport de Facturation pour l'année : $year";
      filename = "$safeName-Annuel-$year.xlsx";
    } else {
      // Mois spécifique
      final String monthNameFr = DateFormat.MMMM(
        'fr_FR',
      ).format(DateTime(year, month)).toUpperCase();
      titleText = "Facture du mois de : $monthNameFr $year";
      filename = "$safeName-$monthNameFr-$year.xlsx";
    }

    sheet.getRangeByIndex(currentRow, 1, currentRow, 9).merge();
    sheet.getRangeByIndex(currentRow, 1).setText(titleText);
    sheet.getRangeByIndex(currentRow, 1).cellStyle = _getHeaderStyle(workbook);
    currentRow += 2;

    currentRow = _insertMainTable(
      sheet,
      workbook,
      data,
      currentRow,
      isMonthly: month != 0,
    );
    _insertTotals(sheet, workbook, data, currentRow, isMonthly: month != 0);

    _saveFile(workbook, paths[0], filename);
  }

  // --- 3. FONCTION : generate_traitements_excel ---
  Future<void> generateTraitementsExcel(
    List<Map<String, dynamic>> data,
    int year,
    int month,
  ) async {
    final String monthNameFr = DateFormat.MMMM(
      'fr_FR',
    ).format(DateTime(year, month)).toUpperCase();
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    // Titre
    sheet.getRangeByIndex(1, 1, 1, 7).merge();
    sheet
        .getRangeByIndex(1, 1)
        .setText("Rapport des Traitements du mois de $monthNameFr $year");
    sheet.getRangeByIndex(1, 1).cellStyle = _getHeaderStyle(workbook);

    sheet
        .getRangeByIndex(3, 1)
        .setText("Nombre total de traitements ce mois-ci : ${data.length}");
    sheet.getRangeByIndex(3, 1).cellStyle.bold = true;

    if (data.isEmpty) {
      sheet.getRangeByIndex(5, 1).setText("Aucun traitement trouvé.");
    } else {
      List<String> headers = data[0].keys.toList();
      // Écriture headers
      for (int i = 0; i < headers.length; i++) {
        var cell = sheet.getRangeByIndex(5, i + 1);
        cell.setText(headers[i]);
        cell.cellStyle = _getBoldBorderStyle(workbook);
      }
      // Données + Couleurs (Effectué = Rouge, À venir = Vert)
      for (int i = 0; i < data.length; i++) {
        for (int j = 0; j < headers.length; j++) {
          var cell = sheet.getRangeByIndex(6 + i, j + 1);
          var value = data[i][headers[j]];
          cell.setValue(value);
          cell.cellStyle.borders.all.lineStyle = LineStyle.thin;

          if (headers[j] == 'Etat traitement') {
            if (value == 'Effectué') {
              cell.cellStyle.backColor = '#FFC7CE';
            } else if (value == 'À venir') {
              cell.cellStyle.backColor = '#C6EFCE';
            }
          }
        }
      }
    }

    for (int i = 1; i <= 10; i++) {
      sheet.autoFitColumn(i);
    }
    _saveFile(workbook, paths[1], "traitements-$monthNameFr-$year.xlsx");
  }

  // --- MÉTHODES PRIVÉES (LOGIQUE INTERNE) ---

  int _insertClientHeader(
    Worksheet sheet,
    List<Map<String, dynamic>> data,
    String clientFullName,
    int row,
  ) {
    if (data.isEmpty) return row;
    final info = data[0];
    String displayName = "${info['client_nom']} ${info['client_prenom']}";
    if (info['client_categorie'] != 'Particulier') {
      displayName =
          "${info['client_nom']} (Responsable: ${info['client_prenom'] ?? 'N/A'})";
    }

    final List<List<String>> rows = [
      ["Client :", displayName],
      ["N° Contrat :", info['Référence Contrat']?.toString() ?? 'N/A'],
      ["Adresse :", info['client_adresse']?.toString() ?? 'N/A'],
      ["Téléphone :", info['client_telephone']?.toString() ?? 'N/A'],
      ["Catégorie Client :", info['client_categorie']?.toString() ?? 'N/A'],
      ["Axe Client :", info['client_axe']?.toString() ?? 'N/A'],
    ];

    for (var r in rows) {
      sheet.getRangeByIndex(row, 1).setText(r[0]);
      sheet.getRangeByIndex(row, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(row, 2).setText(r[1]);
      row++;
    }
    return row + 1;
  }

  int _insertMainTable(
    Worksheet sheet,
    Workbook wb,
    List<Map<String, dynamic>> data,
    int startRow, {
    required bool isMonthly,
  }) {
    final headers = [
      'Numéro Facture',
      'Date de Planification',
      'Date de Facturation',
      'Type de Traitement',
      'Etat du Planning',
      'Mode de Paiement',
      'Détails Paiement',
      'Etat de Paiement',
      'Montant Facturé',
    ];

    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.getRangeByIndex(startRow, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = _getBoldBorderStyle(wb);
    }

    int rIdx = startRow + 1;
    for (var item in data) {
      String details = _formatPaymentDetails(item);
      List<dynamic> rowData = [
        item['Numéro Facture'] ?? "Aucun",
        item['Date de Planification'] ?? 'N/A',
        isMonthly ? item['Date de traitement'] : item['Date de Facturation'],
        isMonthly ? item['Traitement (Type)'] : item['Type de Traitement'],
        isMonthly ? item['Etat traitement'] : item['Etat du Planning'],
        item['Mode de Paiement'] ?? 'N/A',
        details,
        isMonthly
            ? item['Etat paiement (Payée ou non)']
            : item['Etat de Paiement'],
        isMonthly ? item['montant_facture'] : item['Montant Facturé'],
      ];

      for (int cIdx = 0; cIdx < rowData.length; cIdx++) {
        var cell = sheet.getRangeByIndex(rIdx, cIdx + 1);
        cell.setValue(rowData[cIdx]);
        cell.cellStyle.borders.all.lineStyle = LineStyle.thin;

        // Couleurs Payé/Non payé
        String status =
            (isMonthly
                    ? item['Etat paiement (Payée ou non)']
                    : item['Etat de Paiement'])
                .toString();
        if (status == 'Payé') {
          cell.cellStyle.backColor = '#C6EFCE';
        } else if (status == 'Non payé') {
          cell.cellStyle.backColor = '#FFC7CE';
        }
      }
      rIdx++;
    }
    return rIdx + 1;
  }

  void _insertTotals(
    Worksheet sheet,
    Workbook wb,
    List<Map<String, dynamic>> data,
    int row, {
    required bool isMonthly,
  }) {
    if (data.isEmpty) return;

    final String amountKey = isMonthly ? 'montant_facture' : 'Montant Facturé';
    final String statusKey = isMonthly
        ? 'Etat paiement (Payée ou non)'
        : 'Etat de Paiement';

    double total = data.fold(0, (prev, e) => prev + (e[amountKey] ?? 0));
    double paid = data
        .where((e) => e[statusKey] == 'Payé')
        .fold(0, (prev, e) => prev + (e[amountKey] ?? 0));

    sheet.getRangeByIndex(row, 1).setText("Montant Total Facturé :");
    sheet.getRangeByIndex(row++, 9).setNumber(total);

    sheet.getRangeByIndex(row, 1).setText("Montant Total Payé :");
    sheet.getRangeByIndex(row, 9).setNumber(paid);
    sheet.getRangeByIndex(row++, 9).cellStyle.backColor = '#C6EFCE';

    // Auto-fit à la fin
    for (int i = 1; i <= 9; i++) {
      sheet.autoFitColumn(i);
    }
  }

  String _formatPaymentDetails(Map<String, dynamic> item) {
    String mode = item['Mode de Paiement'] ?? 'N/A';
    String date = item['Date de Paiement'] != null
        ? DateFormat('yyyy-MM-dd').format(item['Date de Paiement'])
        : 'N/A';
    if (mode == 'Chèque') {
      return "Chèque: ${item['Numéro du Chèque']} ($date, ${item['Établissement Payeur']})";
    }
    if (mode == 'Virement' || mode == 'Mobile Money' || mode == 'Espèce') {
      return "$mode: ($date)";
    }
    return "N/A";
  }

  Style _getHeaderStyle(Workbook wb) {
    Style s = wb.styles.add('h');
    s.bold = true;
    s.fontSize = 14;
    s.hAlign = HAlignType.center;
    return s;
  }

  Style _getBoldBorderStyle(Workbook wb) {
    Style s = wb.styles.add(DateTime.now().microsecondsSinceEpoch.toString());
    s.bold = true;
    s.borders.all.lineStyle = LineStyle.thin;
    return s;
  }

  void _saveFile(Workbook wb, Directory dir, String fileName) {
    final List<int> bytes = wb.saveAsStream();
    File(p.join(dir.path, fileName)).writeAsBytesSync(bytes);
    wb.dispose();
  }

  /// Méthode générique pour créer des exports Excel
  Future<String> genererExcelGenerique({
    required String title,
    required List<String> headers,
    required List<List<dynamic>> data,
    required String fileName,
  }) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    final Style headerStyle = workbook.styles.add('headerStyle');
    headerStyle.bold = true;
    headerStyle.fontSize = 12;
    headerStyle.hAlign = HAlignType.center;
    headerStyle.backColor = '#4472C4';
    headerStyle.fontColor = '#FFFFFF';

    final Style boldStyle = workbook.styles.add('boldStyle');
    boldStyle.bold = true;

    int currentRow = 1;

    // Titre
    sheet.getRangeByIndex(currentRow, 1, currentRow, headers.length).merge();
    sheet.getRangeByIndex(currentRow, 1).setText(title);
    sheet.getRangeByIndex(currentRow, 1).cellStyle = headerStyle;
    currentRow += 2;

    // Headers
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(currentRow, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = headerStyle;
      cell.cellStyle.borders.all.lineStyle = LineStyle.thin;
    }
    currentRow++;

    // Données
    for (var row in data) {
      for (int i = 0; i < row.length; i++) {
        final cell = sheet.getRangeByIndex(currentRow, i + 1);
        cell.setValue(row[i]);
        cell.cellStyle.borders.all.lineStyle = LineStyle.thin;
      }
      currentRow++;
    }

    // Sauvegarde
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final folder2 = Directory(
      p.join(FolderManager._getDesktopPath().path, 'Exports'),
    );
    if (!folder2.existsSync()) {
      folder2.createSync(recursive: true);
    }

    final finalPath = p.join(folder2.path, '$fileName.xlsx');
    await File(finalPath).writeAsBytes(bytes);
    return finalPath;
  }
}
