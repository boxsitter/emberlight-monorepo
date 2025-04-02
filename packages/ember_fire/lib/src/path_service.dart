import 'package:ember_core/ember_core.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_core/ember_core_validators.dart';
import 'package:get/get.dart';

class PathService extends GetxService {
  ClientContext context = Get.find<ClientContext>();

  String _getPath(String collectionName, String domain, String? ref) {
    if (!BessIdValidation.isValidDomain(domain)) {
      throw ArgumentError('Error getting path, invalid domain');
    }

    String outputPath;
    if (domain == 'rot') {
      outputPath = '';
    } else {
      outputPath = 'organization/';
    }

    String suffix;
    if (ref == null) {
      suffix = collectionName;
    } else {
      BessIdValidation.simpleValidate(ref);
      suffix = '$collectionName/${BessIdFunctions.refIdToObj(ref)}';
    }

    Map<String, String> domainPaths = {
      'brn': '${context.organizationId}/branch/${context.branchId}',
      'sea': '/season/${context.seasonId}',
      'ses': '/session/${context.sessionId}',
    };

    for (var entry in domainPaths.entries) {
      if (domain == entry.key) break;
      outputPath += entry.value;
    }

    return '$outputPath/$suffix';
  }

  String getDocPathFromRef(String ref) {
    List<String> idParts = BessIdFunctions.getIdParts(ref);
    return _getPath(idParts[2], idParts[1], ref);
  }

  String getCollectionPathFromRef(String ref) {
    List<String> idParts = BessIdFunctions.getIdParts(ref);
    return _getPath(idParts[2], idParts[1], null);
  }

  String getCollectionPath(String collectionName, String domain) {
    return _getPath(collectionName, domain, null);
  }

}