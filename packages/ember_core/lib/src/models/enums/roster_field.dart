enum RosterField {
  id('Core Id'),
  fullName('Full Name'),
  firstName('First Name'),
  preferredName('First Name (pref)'),
  lastName('Last Name'),
  gender('Gender'),
  birthdate('Birthdate'),
  age('Age'),
  note('Note'),
  cabinName('Cabin');

  final String title;
  const RosterField(this.title);
}