import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({Key? key}) : super(key: key);
  final Map<String, List<String>> _schedule = const {
    'Senin': ['Matematika 08:00-10:00', 'Fisika 13:00-15:00'],
    'Selasa': ['Bahasa Inggris 09:00-11:00'],
    'Rabu': ['Praktikum Kimia 10:00-12:00'],
    'Kamis': ['Pemrograman 08:00-10:00'],
    'Jumat': ['Kewirausahaan 10:00-12:00'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Kuliah')),
      body: ListView(
        children: _schedule.entries.map((entry) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: Theme.of(context).textTheme.titleLarge),
                ...entry.value.map((subject) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(subject),
                )),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}
