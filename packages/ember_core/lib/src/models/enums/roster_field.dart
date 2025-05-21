enum RosterField {
  id('Core Id'),
  firstName('First Name'),
  preferredName('First Name (pref)'),
  lastName('Last Name'),
  gender('Gender'),
  birthday('Birthday'),
  age('Age'),
  note('Note'),
  cabinName('Cabin');

  final String title;
  const RosterField(this.title);
}