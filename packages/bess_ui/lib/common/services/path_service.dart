import 'package:bessie/common/services/client_context_service.dart';
import 'package:bessie/common/utils/helpers/bess_id_functions.dart';
import 'package:bessie/common/utils/validators/bess_id_validation.dart';
import 'package:get/get.dart';

class PathService extends GetxService {
  ClientContext context = Get.find<ClientContext>();

  String _getPath(String collectionName, String domain, String? id) {
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
    if (id == null) {
      suffix = collectionName;
    } else {
      BessIdValidation.simpleValidate(id);
      suffix = '$collectionName/${BessIdFunctions.refIdToObj(id)}';
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
    List<String> idParts = BessIdFunctions.getIdParts(id);
    return _getPath(idParts[2], idParts[1], id);
  }

  String getCollectionPathFromId(String id) {
    List<String> idParts = BessIdFunctions.getIdParts(id);
    return _getPath(idParts[2], idParts[1], null);
  }

  String getCollectionPath(String collectionName, String domain) {
    return _getPath(collectionName, domain, null);
  }

}