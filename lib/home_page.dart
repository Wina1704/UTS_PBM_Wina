import 'package:flutter/material.dart';
import 'storage_service.dart';

class Activity {
  final String name;
  final DateTime date;
  bool isDone;

  Activity(this.name, this.date, {this.isDone = false});

  factory Activity.fromString(String line) {
    final parts = line.split('|');
    return Activity(
      parts[0],
      DateTime.parse(parts[1]),
      isDone: parts[2] == 'true',
    );
  }

  @override
  String toString() => '$name|${date.toIso8601String()}|$isDone';
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Activity> _activities = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final _quoteController = PageController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      final lines = await StorageService.readLines('activities.txt');
      final loaded = lines.map(Activity.fromString).toList();
      if (mounted) {
        setState(() {
          _activities.addAll(loaded);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveActivities() async {
    final lines = _activities.map((e) => e.toString()).toList();
    await StorageService.writeLines('activities.txt', lines);
  }

  void _addActivity(Activity activity) {
    setState(() {
      _activities.insert(0, activity);
      _listKey.currentState?.insertItem(0);
    });
    _saveActivities();
  }

  void _toggleActivity(int index, bool value) {
    setState(() {
      _activities[index].isDone = value;
    });
    _saveActivities();
  }

  void _deleteCompleted() {
    for (var i = _activities.length - 1; i >= 0; i--) {
      if (_activities[i].isDone) {
        final removed = _activities.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => SizeTransition(
            sizeFactor: animation,
            child: _buildActivityItem(removed),
          ),
        );
      }
    }
    _saveActivities();
  }

  Widget _buildActivityItem(Activity activity) {
    return ListTile(
      leading: Checkbox(
        value: activity.isDone,
        onChanged: null,
      ),
      title: Text(activity.name),
      subtitle: Text(
        '${activity.date.day}/${activity.date.month}/${activity.date.year}',
      ),
    );
  }

  Future<void> _showAddDialog() async {
    final nameController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Aktivitas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Aktivitas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Pilih Tanggal'),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                _addActivity(Activity(nameController.text, selectedDate));
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteCompleted,
            tooltip: 'Hapus yang selesai',
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 120,
            child: PageView(
              controller: _quoteController,
              children: const [
                _QuoteCard(text: 'Belajar hari ini untuk sukses besok! 🚀'),
                _QuoteCard(text: 'Progress kecil tetap progress! 💪'),
                _QuoteCard(text: 'You can do it! 🔥'),
              ],
            ),
          ),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _activities.length,
              itemBuilder: (context, index, animation) => SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                  leading: Checkbox(
                    value: _activities[index].isDone,
                    onChanged: (value) => _toggleActivity(index, value!),
                  ),
                  title: Text(_activities[index].name),
                  subtitle: Text(
                    '${_activities[index].date.day}/'
                    '${_activities[index].date.month}/'
                    '${_activities[index].date.year}',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String text;

  const _QuoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}