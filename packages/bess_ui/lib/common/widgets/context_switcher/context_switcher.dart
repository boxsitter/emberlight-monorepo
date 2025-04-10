import 'package:flutter/cupertino.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const frameworks = {
  'sessiona': 'Session A',
  'sessionb': 'Session B',
  'testsession': 'Test Session',
};


Future<dynamic> buildShowShadDialog(BuildContext context, ShadThemeData theme) {
  return showShadDialog(
    context: context,
    builder: (context) => ShadDialog(
      title: const Text('Change active session'),
      description: const Text("Any unsaved changes or data will be discarded"),
      actions: const [ShadButton(child: Text('Switch'))],
      child: Container(
        width: 375,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Session',
              textAlign: TextAlign.end,
              style: theme.textTheme.small,
            ),
            const SizedBox(width: 16),
            SessionSelectWithSearch(),
          ],
        ),
      ),
    ),
  );
}

class SessionSelectWithSearch extends StatefulWidget {
  const SessionSelectWithSearch({super.key});

  @override
  State<SessionSelectWithSearch> createState() => _SessionSelectWithSearchState();
}

class _SessionSelectWithSearchState extends State<SessionSelectWithSearch> {
  var searchValue = '';

  Map<String, String> get filteredFrameworks => {
    for (final framework in frameworks.entries)
      if (framework.value.toLowerCase().contains(searchValue.toLowerCase()))
        framework.key: framework.value
  };

  @override
  Widget build(BuildContext context) {
    return ShadSelect<String>.withSearch(
      minWidth: 180,
      maxWidth: 300,
      placeholder: const Text('Select session...'),
      onSearchChanged: (value) => setState(() => searchValue = value),
      searchPlaceholder: const Text('Search session'),
      options: [
        if (filteredFrameworks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('No session found'),
          ),
        ...frameworks.entries.map(
              (framework) {
            // this offstage is used to avoid the focus loss when the search results appear again
            // because it keeps the widget in the tree.
            return Offstage(
              offstage: !filteredFrameworks.containsKey(framework.key),
              child: ShadOption(
                value: framework.key,
                child: Text(framework.value),
              ),
            );
          },
        )
      ],
      selectedOptionBuilder: (context, value) => Text(frameworks[value]!),
    );
  }
}