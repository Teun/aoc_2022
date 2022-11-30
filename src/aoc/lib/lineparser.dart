typedef ParseCallback<T> = T Function (List<String> s);
List<T> parseToObjects<T>(String d, RegExp re, ParseCallback<T> trans) {
    final lines = d.split("\n").where((s) => s.isNotEmpty);
    return lines.map((line) {
        final match = re.firstMatch(line);
        if(match == null)return null;
        return trans(match.groups(List.generate(match.groupCount, (index) => index + 1)).cast());
    }).where((e) => e != null).cast<T>().toList();
}
