import 'package:prism_browser/domain/search/prism_search.dart';

/// Offline stand-in for Wikipedia: tests never touch the network.
class FakeKnowledgeSource implements KnowledgeSource {
  FakeKnowledgeSource({List<KnowledgePage>? pages, this.fail = false})
    : pages = pages ?? defaultPages;

  final List<KnowledgePage> pages;
  final bool fail;
  final List<(String, String)> calls = [];

  static final defaultPages = [
    KnowledgePage(
      title: 'Призма (оптика)',
      url: Uri.parse('https://ru.wikipedia.org/wiki/Призма_(оптика)'),
      description: 'Оптический элемент',
      extract:
          'Призма — оптический элемент из прозрачного материала, '
          'преломляющий и разлагающий свет в спектр.',
    ),
    KnowledgePage(
      title: 'Дисперсия света',
      url: Uri.parse('https://ru.wikipedia.org/wiki/Дисперсия_света'),
      description: 'Зависимость показателя преломления от длины волны',
    ),
  ];

  @override
  String get name => 'Wikipedia';

  @override
  Future<List<KnowledgePage>> search(
    String query, {
    required String lang,
  }) async {
    calls.add((query, lang));
    if (fail) throw StateError('offline');
    return pages;
  }
}
