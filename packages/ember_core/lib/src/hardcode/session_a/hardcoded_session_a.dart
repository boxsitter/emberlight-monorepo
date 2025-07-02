import '../../../ember_core.dart';
class HardcodedSessionA {
  static final sessionA = Session(
    name: 'Session A',
    createdAt: DateTime.parse('2025-03-17T05:35:01.000Z').toUtc(),
    start: DateTime(2025, 7, 6).toUtc(),
    end: DateTime(2026, 7, 12).toUtc(),
  );
}