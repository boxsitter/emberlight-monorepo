import 'dart:collection';

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

    // TODO: Make this less horrible, but also work when seasonId and sessionId aren't set yet
    if (domain == 'org') {
      outputPath += context.organizationId;
    } else if (domain == 'brn') {
      outputPath += '${context.organizationId}/branch/${context.branchId}';
    } else if (domain == 'sea') {
      outputPath += '${context.organizationId}/branch/${context.branchId}' '/season/${context.seasonId}';
    } else if (domain == 'ses') {
      outputPath += '${context.organizationId}/branch/${context.branchId}' '/season/${context.seasonId}' '/session/${context.sessionId}';
    }

    print('output path: $outputPath/$suffix');
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