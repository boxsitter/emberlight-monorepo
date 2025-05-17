enum Module {
  bessie('BESSIE'),
  core('CORE'),
  fire('FIRE'),
  quickLog('LOG'),
  unknown('UNKNOWN');

  final String name;
  const Module(this.name);
}