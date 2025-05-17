enum Verbosity {
  none(0, 'None'),
  essential(1, 'Essential'),
  verbose(2, 'Verbose'),
  excessive(3, 'Excessive');

  final int level;
  final String name;
  const Verbosity(this.level, this.name);
}
