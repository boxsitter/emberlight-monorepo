import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_core/ember_core_validators.dart';
import 'package:get/get.dart';

class PathService extends GetxService {
  ClientContext context = Get.find<ClientContext>();

  String _getPath(String collectionName, String domain, String? id) {
    if (!CoreIdValidation.isValidDomain(domain)) {
      throw ArgumentError('Error getting path, invalid domain');
    }

    String outputPath;
    if (domain == 'rot') {
      outputPath = '';
    } else {
      outputPath = 'organization/';
    }

    String suffix;
    if (id == null) {
      suffix = collectionName;
    } else {
      CoreIdValidation.simpleValidate(id);
      suffix = '$collectionName/$id';
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

  String getDocPathFromId(String id) {
    List<String> idParts = IdFunctions.getIdParts(id);
    return _getPath(idParts[1], idParts[0], id);
  }

  String getCollectionPathFromId(String id) {
    List<String> idParts = IdFunctions.getIdParts(id);
    return _getPath(idParts[1], idParts[0], null);
  }

  String getCollectionPath(String collectionName, String domain) {
    return _getPath(collectionName, domain, null);
  }

}