typedef ParseCallback<T> = T Function(List<String> s);
List<T> parseToObjects<T>(String d, RegExp re, ParseCallback<T> trans,
    {RegExp? splitter}) {
  Iterable<String> lines =
      getLines(d, splitter: splitter).where((s) => s.isNotEmpty);
  return lines
      .map((line) {
        final match = re.firstMatch(line);
        if (match == null) return null;
        return trans(match
            .groups(List.generate(match.groupCount, (index) => index + 1))
            .map((s) => s ?? "")
            .toList());
      })
      .where((e) => e != null)
      .cast<T>()
      .toList();
}

Iterable<String> getLines(String d, {RegExp? splitter}) {
  splitter = splitter ?? RegExp(r'\n', multiLine: false);
  final lines = d.split(splitter);
  return lines;
}
