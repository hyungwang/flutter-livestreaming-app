String generateUUID() {
  List<String> time =
      DateTime.now().millisecondsSinceEpoch.toString().split("");
  List<String> alpha = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm'
  ];
  print(time);
  return time
      .asMap()
      .entries
      .map((el) {
        if (el.key % 3 == 0) {
          print(el);
          return alpha[el.key];
        } else {
          return el.value;
        }
      })
      .toList()
      .join('');
}
