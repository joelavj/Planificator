import 'package:flutter/material.dart';
import 'package:planificator/models/index.dart';
import 'package:planificator/repositories/remarque_repository.dart';

class RemarqueDialog extends StatefulWidget {
  final PlanningDetails planningDetail;
  final Facture facture;
  final VoidCallback onSaved;

  const RemarqueDialog({
    Key? key,
    required this.planningDetail,
    required this.facture,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<RemarqueDialog> createState() => _RemarqueDialogState();
}

class _RemarqueDialogState extends State<RemarqueDialog> {
  final _remarqueRepo = RemarqueRepository();

  late TextEditingController _contenuCtrl;
  late TextEditingController _problemeCtrl;
  late TextEditingController _actionCtrl;
  late TextEditingController _nomFactureCtrl;
  late TextEditingController _datePayementCtrl;
  late TextEditingController _etablissementCtrl;
  late TextEditingController _numeroChequeCtrl;

  bool _estPayee = false;
  String? _modePaiement;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _contenuCtrl = TextEditingController();
    _problemeCtrl = TextEditingController();
    _actionCtrl = TextEditingController();
    _nomFactureCtrl = TextEditingController();
    _datePayementCtrl = TextEditingController();
    _etablissementCtrl = TextEditingController();
    _numeroChequeCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _contenuCtrl.dispose();
    _problemeCtrl.dispose();
    _actionCtrl.dispose();
    _nomFactureCtrl.dispose();
    _datePayementCtrl.dispose();
    _etablissementCtrl.dispose();
    _numeroChequeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveRemarque() async {
    if (_isLoading) return;

    // Validation
    if (_estPayee) {
      if (_modePaiement == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez choisir un mode de paiement')),
        );
        return;
      }
      if (_nomFactureCtrl.text.isEmpty || _datePayementCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir les infos paiement')),
        );
        return;
      }
      if (_modePaiement == 'Cheque' &&
          (_etablissementCtrl.text.isEmpty || _numeroChequeCtrl.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir info chèque')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await _remarqueRepo.createRemarque(
        planningDetailId: widget.planningDetail.id!,
        factureId: widget.facture.factureId,
        contenu: _contenuCtrl.text.isEmpty ? null : _contenuCtrl.text,
        probleme: _problemeCtrl.text.isEmpty ? null : _problemeCtrl.text,
        action: _actionCtrl.text.isEmpty ? null : _actionCtrl.text,
        modePaiement: _estPayee ? _modePaiement : null,
        nomFacture: _estPayee ? _nomFactureCtrl.text : null,
        datePayement: _estPayee ? _datePayementCtrl.text : null,
        etablissement: _modePaiement == 'Cheque'
            ? _etablissementCtrl.text
            : null,
        numeroCheque: _modePaiement == 'Cheque' ? _numeroChequeCtrl.text : null,
        estPayee: _estPayee,
      );

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Remarque enregistrée')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remarque pour ${widget.planningDetail.datePlanification}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contenuCtrl,
                decoration: const InputDecoration(
                  labelText: 'Remarque',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _problemeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Problème',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _actionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Action',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Payée'),
                value: _estPayee,
                onChanged: (val) => setState(() => _estPayee = val ?? false),
              ),
              if (_estPayee) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: _modePaiement,
                  decoration: const InputDecoration(
                    labelText: 'Mode paiement',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Cheque', 'Espece', 'Virement', 'Mobile Money']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) => setState(() => _modePaiement = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nomFactureCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Numéro facture',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _datePayementCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Date paiement',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_modePaiement == 'Cheque') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _etablissementCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Établissement',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _numeroChequeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Numéro chèque',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isLoading ? null : _saveRemarque,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enregistrer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
