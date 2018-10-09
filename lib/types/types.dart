class Pair<F, S> {
  F first;
  S second;

  Pair();

  Pair.from(this.first, this.second);
}

class Triple<T, U, V> {
  T first;
  U second;
  V third;

  Triple();

  Triple.from(this.first, this.second, this.third);
}

class ExclusivePair<F, S> {
  F _first;
  S _second;

  ExclusivePair(F first, S second)
      : assert(!(first == null && second == null)),
        assert(!(first != null && second != null)),
        _first = first,
        _second = second;

  ExclusivePair.withFirst(this._first) : _second = null;

  ExclusivePair.withSecond(this._second) : _first = null;

  bool get isFirst => _first != null;

  bool get isSecond => _second != null;

  F get first => _first;

  S get second => _second;
}
