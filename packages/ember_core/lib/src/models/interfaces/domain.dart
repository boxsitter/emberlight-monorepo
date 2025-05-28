import '../../../ember_core_models.dart';

abstract class Domain extends CoreObject {
  Domain({required super.domain, required super.type, required super.idTag});
  // just a label for now
}