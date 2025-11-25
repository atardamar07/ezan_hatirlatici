import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class ZikirmatikScreen extends StatefulWidget {
  const ZikirmatikScreen({Key? key}) : super(key: key);

  @override
  _ZikirmatikScreenState createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends State<ZikirmatikScreen> with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _targetCount = 33;
  String _selectedZikir = 'Subhanallah';
  bool _isVibrationEnabled = true;
  bool _isSoundEnabled = true;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  late List<Map<String, String>> _zikirler;

  String get _selectedMeaning {
    final selectedZikirData = _zikirler.firstWhere(
          (z) => z['name'] == _selectedZikir,
      orElse: () => {'name': _selectedZikir, 'meaning': ''},
    );
    return selectedZikirData['meaning'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _zikirler = [];
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadSettings();
  }

  void _loadZikirs() {
    final loc = AppLocalizations.of(context)!;
    setState(() {
      _zikirler = [
        {'name': 'Subhanallah', 'meaning': loc.subhanallahMeaning},
        {'name': 'Elhamdülillah', 'meaning': loc.alhamdulillahMeaning},
        {'name': 'Allahu Ekber', 'meaning': loc.allahuAkbarMeaning},
        {'name': 'La İlahe İllallah', 'meaning': loc.laIlaheIllallahMeaning},
        {'name': 'Astagfirullah', 'meaning': loc.astagfirullahMeaning},
        {'name': 'Hasbünallah', 'meaning': loc.hasbunallahMeaning},
      ];
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadZikirs();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _targetCount = prefs.getInt('targetCount') ?? 33;
      _selectedZikir = prefs.getString('selectedZikir') ?? 'Subhanallah';
      _isVibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      _isSoundEnabled = prefs.getBool('soundEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('targetCount', _targetCount);
    await prefs.setString('selectedZikir', _selectedZikir);
    await prefs.setBool('vibrationEnabled', _isVibrationEnabled);
    await prefs.setBool('soundEnabled', _isSoundEnabled);
  }

  void _incrementCounter() {
    setState(() {
      // Eğer sayaç Hedefi geçtiyse hiçbir şey yapmasın
      if (_counter >= _targetCount) return;

      _counter++;
      _animationController.forward().then((_) => _animationController.reverse());

      // Web'de titreşim olmaz
      if (_isVibrationEnabled && !kIsWeb) {
        if (_counter == _targetCount) {
          Vibration.vibrate(duration: 500);  // hedef titreşimi
        } else {
          Vibration.vibrate(duration: 50);   // normal titreşim
        }
      }

      // ⭐ Hedefe ulaştıysa popup aç ve sayaç artık artmasın
      if (_counter == _targetCount) {
        _showCompletionDialog();
      }
    });
  }


  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.dhikrSettings),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: _selectedZikir,
                  isExpanded: true,
                  items: _zikirler.map((zikir) {
                    return DropdownMenuItem<String>(
                      value: zikir['name'],
                      child: Text(zikir['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedZikir = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.targetCount,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: _targetCount.toString()),
                  onChanged: (value) {
                    final newValue = int.tryParse(value) ?? 33;
                    setState(() => _targetCount = newValue);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.vibration),
                  value: _isVibrationEnabled,
                  onChanged: (value) {
                    setState(() => _isVibrationEnabled = value);
                  },
                ),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.sound),
                  value: _isSoundEnabled,
                  onChanged: (value) {
                    setState(() => _isSoundEnabled = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                _saveSettings();
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.congratulations),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 64),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!
                .completedDhikr(_selectedZikir, _targetCount)),
            if (_selectedMeaning.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _selectedMeaning,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCounter();
            },
            child: Text(AppLocalizations.of(context)!.restart),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCounter();
            },
            child: Text(AppLocalizations.of(context)!.continueText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final progress = _counter / _targetCount;
    final selectedZikirData = _zikirler.firstWhere(
          (z) => z['name'] == _selectedZikir,
      orElse: () => {'name': _selectedZikir, 'meaning': ''},
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: Text(AppLocalizations.of(context)!.dhikrCounter),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            color: colors.onSurface,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: colors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      _selectedZikir,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
                        fontSize: 28,
                      ),
                    ),
                    if (selectedZikirData['meaning'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          selectedZikirData['meaning']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _incrementCounter,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surface,
                    border: Border.all(
                      color: colors.primary,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: colors.onSurface.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _counter >= _targetCount ? colors.primary : colors.secondary,
                        ),
                      ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_counter',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
                          ),
                          ),
                          Text(
                            '/ $_targetCount',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colors.onSurface.withOpacity(0.6),
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '%${(progress * 100).toStringAsFixed(1)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _resetCounter,
                  icon: Icon(Icons.refresh, color: colors.onPrimary),
                  label: Text(AppLocalizations.of(context)!.reset,
                      style: TextStyle(color: colors.onPrimary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _incrementCounter,
                  icon: Icon(Icons.refresh, color: colors.onPrimary),
                  label: Text(AppLocalizations.of(context)!.count,
                      style: TextStyle(color: colors.onPrimary)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.tapToCount,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}