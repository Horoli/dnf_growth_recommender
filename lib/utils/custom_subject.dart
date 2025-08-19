part of dnf_growth_recommender;

class CustomSubject<T> {
  T? initValue;
  final BehaviorSubject<T> _subject;
  CustomSubject({
    this.initValue,
  }) : _subject = initValue != null
            ? BehaviorSubject<T>.seeded(initValue as T)
            : BehaviorSubject<T>();

  Stream<T> get browse => _subject.stream;

  // bool get hasValue => _subject.hasValue;
  T? get lastValue => _subject.valueOrNull;

  bool get hasValue {
    final value = lastValue;
    if (value == null) return false;

    if (value is List) return (value as List).isNotEmpty;
    if (value is Map) return (value as Map).isNotEmpty;
    if (value is Set) return (value as Set).isNotEmpty;
    if (value is String) return (value as String).isNotEmpty;

    return true;
  }

  void sink(T value) {
    _subject.add(value);
  }

  void refresh() {
    final T? current = lastValue;
    if (current != null) {
      _subject.add(current);
    }
  }

  void dispose() {
    _subject.close();
  }
}
