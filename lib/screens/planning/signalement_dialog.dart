import 'package:flutter/material.dart';
import 'package:planificator/models/index.dart';
import 'package:planificator/repositories/signalement_repository.dart';

class SignalementDialog extends StatefulWidget {
  final PlanningDetails planningDetail;
  final VoidCallback onSaved;

  const SignalementDialog({
    Key? key,
    required this.planningDetail,
    required this.onSaved,
  }) : super(key: key);

  @override
  State<SignalementDialog> createState() => _SignalementDialogState();
}

class _SignalementDialogState extends State<SignalementDialog> {
  final _signalementRepo = SignalementRepository();

  late TextEditingController _motifCtrl;
  late TextEditingController _dateCtrl;

  String _type = 'décalage'; // 'avancement' ou 'décalage'
  bool _changeRedondance = false; // Changer la redondance ou garder
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _motifCtrl = TextEditingController();
    _dateCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _motifCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSignalement() async {
    if (_isLoading) return;

    if (_motifCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez entrer un motif')));
      return;
    }

    if (_dateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _signalementRepo.createSignalement(
        planningDetailId: widget.planningDetail.id!,
        motif: _motifCtrl.text,
        type: _type,
      );

      if (mounted) {
        widget.onSaved();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signalement de $_type enregistré')),
        );
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );
    if (picked != null) {
      setState(() => _dateCtrl.text = picked.toString().split(' ')[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Signalement pour ${widget.planningDetail.datePlanification}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'avancement', label: Text('Avancement')),
                ButtonSegment(value: 'décalage', label: Text('Décalage')),
              ],
              selected: {_type},
              onSelectionChanged: (newSelection) {
                setState(() => _type = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _motifCtrl,
              decoration: const InputDecoration(
                labelText: 'Motif',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateCtrl,
              decoration: InputDecoration(
                labelText: 'Nouvelle date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Changer la redondance (pour tous les futurs)'),
              value: _changeRedondance,
              onChanged: (val) =>
                  setState(() => _changeRedondance = val ?? false),
            ),
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
                  onPressed: _isLoading ? null : _saveSignalement,
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
    );
  }
}
