import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('glass.dart') || file.path.contains('.g.dart')) continue;

    String content = file.readAsStringSync();
    bool changed = false;

    if (content.contains('Scaffold(')) {
      content = content.replaceAll('Scaffold(', 'Scaffold(extendBodyBehindAppBar: true, extendBody: true,');
      changed = true;
    }
    
    if (content.contains(RegExp(r'\bAppBar\('))) {
      content = content.replaceAll(RegExp(r'\bAppBar\('), 'GlassAppBar(');
      changed = true;
    }

    if (content.contains(RegExp(r'\bCard\('))) {
      content = content.replaceAll(RegExp(r'\bCard\('), 'GlassCard(');
      changed = true;
    }

    if (changed) {
      if (!content.contains('package:korst/core/widgets/glass.dart')) {
        content = "import 'package:korst/core/widgets/glass.dart';\n$content";
      }
      // Fix duplicate extendBody or extendBodyBehindAppBar
      content = content.replaceAll('extendBodyBehindAppBar: true, extendBody: true, extendBody: true', 'extendBodyBehindAppBar: true, extendBody: true');
      
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
