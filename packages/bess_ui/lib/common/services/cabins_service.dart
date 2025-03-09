import 'package:get/get.dart';

import '../../data/models/cabin.dart';

class CabinsService extends GetxService {

  Cabin fetchCabinById(String id){
    return Cabin(name: "TEST CABIN", capacity: 999);
    // TODO: fetch cabin from database
    // returns null if no cabin is found and throws an error
  }


}