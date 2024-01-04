extension ChunkListExtension<T> on List<T> {
  List<List<T>> chunk(int chunkSize) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += chunkSize) {
      int end = (i + chunkSize < length) ? i + chunkSize : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
}

extension DistinctByPropertyExtension<T> on List<T> {
  List<T> distinctByProperty<K>(K Function(T) propertyExtractor) {
    Set<K> seen = <K>{};
    return where((element) => seen.add(propertyExtractor(element))).toList();
  }
}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
      (Map<K, List<E>> map, E element) =>
          map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

extension GroupConsecutiveExtension<T> on List<T> {
  List<List<T>> groupConsecutive(Function(T) getProperty) {
    List<List<T>> result = [];

    if (isEmpty) {
      return result;
    }

    List<T> currentGroup = [this[0]];

    for (int i = 1; i < length; i++) {
      if (getProperty(this[i]) == getProperty(currentGroup.last)) {
        currentGroup.add(this[i]);
      } else {
        result.add(List.from(currentGroup));
        currentGroup = [this[i]];
      }
    }

    result.add(List.from(currentGroup));

    return result;
  }
}

void pprint(Object? object) {
  if (object == null) return;
  print("alo2_$object");
}
