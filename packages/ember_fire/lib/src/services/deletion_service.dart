// import 'package:ember_core/ember_core_models.dart';
// import 'package:ember_core/ember_core_services.dart';
// import 'package:ember_fire/src/repositories/pull_repository.dart';
// import 'package:get/get.dart';
//
// class DeletionService extends GetxService {
//   PullRepository pullRepo = Get.find<PullRepository>();
//   ClientContextService clientContextService = Get.find<ClientContextService>();
//
//   Future<DeleteRequest> deleteCoreObject(String objectToDeleteId) async {
//     //get chain of components
//     Set<Map<String, dynamic>> cmpsToDelete = await fetchAllComponents(objectToDeleteId);
//     Set<String> cmpsToDeleteIds = extractIds(cmpsToDelete);
//
//     //get a set of all references to those components
//     Map<String, Set<String>> refTracker = (await clientContextService.session).refTracker;
//     Set<String> objectsToPurgeIds = {};
//
//     for (String id in cmpsToDeleteIds) {
//       objectsToPurgeIds.addAll((refTracker[id] as Iterable<String>).toList());
//     }
//
//     // TODO: remove the set of objects to be deleted from references to purge, it would be unnecessary calls
//     objectsToPurgeIds.removeAll(cmpsToDeleteIds);
//
//     // TODO: don't forget to update the reference tracker (Only necessary for deleted items, purged objects will be updated on push)
//     for (final key in cmpsToDeleteIds) {
//       refTracker.remove(key);
//     }
//     Set<Map<dynamic, dynamic>> documentsToPurge = {};
//     Set<FromJsonable> objectsToPurge = {};
//
//     // TODO: handle master objects
//   }
//
//   Future<Set<Map<String, dynamic>>> fetchAllComponents(String id, {Set<String>? visited}) async {
//     visited ??= {};
//     if (visited.contains(id)) return {};
//     visited.add(id);
//
//     final doc = await pullRepo.getDocument(id);
//     if (doc == null) return {};
//
//     // Start with the current document.
//     Set<Map<String, dynamic>> results = {doc};
//
//     // Extract subcomponent IDs and recursively fetch them.
//     Set<String> subcomponentIds = getCmps(doc);
//     for (final cmpId in subcomponentIds) {
//       results.addAll(await fetchAllComponents(cmpId, visited: visited));
//     }
//
//     return results;
//   }
//
//   Set<String> getCmps(Map<String, dynamic> json) {
//     final Set<String> output = {};
//
//     json.forEach((key, value) {
//       final String lowerKey = key.toLowerCase();
//       if (lowerKey.endsWith("cmp") || lowerKey.endsWith("cmps")) {
//         if (value is String) {
//           output.add(value);
//         } else if (value is List) {
//           for (var element in value) {
//             if (element is String) {
//               output.add(element);
//             }
//           }
//         }
//       }
//     });
//
//     return output;
//   }
//
//   Set<String> extractIds(Set<Map<String, dynamic>> jsonSet) {
//     return jsonSet
//         .where((json) => json.containsKey('id') && json['id'] is String)
//         .map((json) => json['id'] as String)
//         .toSet();
//   }
//
//
//   Future<DeleteRequest> deletePrincipal(CoreObject objectToDelete) {
//     //get chain of components
//
//     //get a set of all references to those components
//
//     // TODO: don't forget to update the reference tracker
//
//     // TODO: handle master objects
//   }
//
//   Future<DeleteRequest> deleteDomain() {
//
//     // Much easier process, just delete the domain document.
//     // Since references are contained to within domains, there is nothing to clean up
//     // Still, stringent checks are necessary to make sure this isn't done by mistake
//   }