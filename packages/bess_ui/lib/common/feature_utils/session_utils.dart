import '../../../../data/models/cabin.dart';
import '../../../../data/models/session.dart';

class SessionUtils {
  static Cabin? getCabinByNameFromSession(Session session, String cabinName) {
    for (Cabin cabin in session.cabins.values) {
      if (cabin.name.toLowerCase() == cabinName.toLowerCase()) {
        return cabin;
      }
    }
    return null;
  }
}