import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  static const String name = 'filter_screen';
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  bool showUrgentOnly = true;
  RangeValues distanceRange = const RangeValues(0, 10);
  final List<String> bloodTypes = const [
    'O-',
    'O+',
    'A-',
    'A+',
    'B-',
    'B+',
    'AB-',
    'AB+',
  ];
  final Set<String> selectedBloodTypes = {'O-', 'A+'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                showUrgentOnly = false;
                distanceRange = const RangeValues(0, 10);
                selectedBloodTypes
                  ..clear()
                  ..addAll({'O-', 'A+'});
              });
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: showUrgentOnly,
              onChanged: (value) => setState(() => showUrgentOnly = value),
              title: const Text('Sólo alertas urgentes'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Distancia (km)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            RangeSlider(
              values: distanceRange,
              max: 30,
              divisions: 6,
              labels: RangeLabels(
                '${distanceRange.start.toStringAsFixed(0)} km',
                '${distanceRange.end.toStringAsFixed(0)} km',
              ),
              onChanged: (value) => setState(() => distanceRange = value),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tipos de sangre',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: bloodTypes.map((type) {
                final isSelected = selectedBloodTypes.contains(type);
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      if (isSelected) {
                        selectedBloodTypes.remove(type);
                      } else {
                        selectedBloodTypes.add(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'urgentOnly': showUrgentOnly,
                    'distance': distanceRange,
                    'bloodTypes': selectedBloodTypes,
                  });
                },
                child: const Text('Aplicar filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
