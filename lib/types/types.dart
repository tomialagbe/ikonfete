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
