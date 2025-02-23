import 'package:bessie/common/widgets/data_table/data_table.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/layouts/templates/site_layout.dart';

class SessionRoster extends StatelessWidget {
  const SessionRoster({super.key});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: SessionRosterDesktop());
  }
}

class SessionRosterDesktop extends StatelessWidget {
  SessionRosterDesktop({
    super.key,
  });

  // TODO: remove temp data
  final List<Map<String, dynamic>> data = [
    {"Name": "Julia Redley", "Preferred Name": "", "Gender": "F", "Age": 11, "Cabin": "Yarrow"},
    {"Name": "Gaguh Bahlz", "Preferred Name": "", "Gender": "M", "Age": 12, "Cabin": "Freeman 1"},
    {"Name": "Allison Peach", "Preferred Name": "", "Gender": "F", "Age": 10, "Cabin": "Leckenby"},
    {"Name": "Wyem Ceeyay", "Preferred Name": "", "Gender": "M", "Age": 9, "Cabin": "Henderson"},
    {"Name": "Cam P. Fiya", "Preferred Name": "", "Gender": "M", "Age": 11, "Cabin": "Yarrow"},
    {"Name": "Don Alverzo", "Preferred Name": "", "Gender": "M", "Age": 13, "Cabin": "Freeman 1"},
    {"Name": "Lan Tern", "Preferred Name": "", "Gender": "M", "Age": 10, "Cabin": "Leckenby"},
    {"Name": "I.P. Rocks", "Preferred Name": "", "Gender": "F", "Age": 8, "Cabin": "Henderson"},
    {"Name": "Connor Cant", "Preferred Name": "", "Gender": "M", "Age": 13, "Cabin": "Freeman 1"},
    {"Name": "K.C. Dher-Hector", "Preferred Name": "", "Gender": "F", "Age": 9, "Cabin": "Henderson"},
    {"Name": "Lee M. Thubritt", "Preferred Name": "", "Gender": "M", "Age": 8, "Cabin": "Henderson"},
    {"Name": "Ernie Yurt", "Preferred Name": "", "Gender": "M", "Age": 12, "Cabin": "Freeman 1"},
    {"Name": "Gowta Tu", "Preferred Name": "", "Gender": "F", "Age": 9, "Cabin": "Henderson"},
    {"Name": "Dan Helia", "Preferred Name": "", "Gender": "M", "Age": 10, "Cabin": "Leckenby"},
    {"Name": "Po LaPlunge", "Preferred Name": "", "Gender": "M", "Age": 11, "Cabin": "Yarrow"},
    {"Name": "Liza Chek", "Preferred Name": "", "Gender": "F", "Age": 10, "Cabin": "Leckenby"},
    {"Name": "Cab N. Coll", "Preferred Name": "", "Gender": "M", "Age": 12, "Cabin": "Freeman 1"},
    {"Name": "Tehl Miwye", "Preferred Name": "", "Gender": "M", "Age": 10, "Cabin": "Leckenby"},
    {"Name": "River Sandrodes", "Preferred Name": "", "Gender": "F", "Age": 13, "Cabin": "Freeman 1"},
    {"Name": "Emma Burrs", "Preferred Name": "Em", "Gender": "F", "Age": 8, "Cabin": "Henderson"},
    {"Name": "Bill Ben", "Preferred Name": "", "Gender": "M", "Age": 11, "Cabin": "Yarrow"},
    {"Name": "Prince S. Pat", "Preferred Name": "", "Gender": "M", "Age": 12, "Cabin": "Freeman 1"},
    {"Name": "Ricka Bamboo", "Preferred Name": "", "Gender": "F", "Age": 9, "Cabin": "Henderson"},
    {"Name": "Axel Straggon", "Preferred Name": "", "Gender": "NB", "Age": 13, "Cabin": "Freeman 1"},
    {"Name": "Valerie Eeyo", "Preferred Name": "Val", "Gender": "F", "Age": 12, "Cabin": "Freeman 1"},
  ];

  final List<String> columns = ["Name", "Preferred Name", "Gender", "Age", "Cabin"];

  @override
  Widget build(BuildContext context) {
    return BessDataTable(data: data, columns: columns);
  }
}