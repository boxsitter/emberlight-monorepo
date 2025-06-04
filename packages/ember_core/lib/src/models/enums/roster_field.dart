enum RosterField {
  id('Core Id', false),
  fullName('Full Name', false),
  firstName('First Name', true, 'nameFirst'),
  preferredName('Preferred Name', false, 'nickname'),
  lastName('Last Name', true, 'nameLast'),
  gender('Gender', false, 'expressionName', 'Gender'),
  birthdate('Birthdate', true, 'Birthdate'),
  age('Age', false),
  note('Note', false),
  cabinName('Cabin', false, 'Cabin'),
  ultracampId('UltraCamp id', false, 'idPerson');

  final String title;
  final bool required;
  final String? csvHeader;
  final String? csvHeaderAlt;
  const RosterField(this.title, this.required, [this.csvHeader, this.csvHeaderAlt]);
}