import 'package:get/get.dart';
import '../Models/location_model.dart';
import '../Repositories/location_repository.dart';
class LocationViewModel extends GetxController{

  var allLocation = <LocationModel>[].obs;
  LocationRepository locationRepository = LocationRepository();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchAllLocation();
  }

  fetchAllLocation() async{
    var location = await locationRepository.getLocation();
    allLocation.value = location;
  }

  addLocation(LocationModel locationModel){
    locationRepository.add(locationModel);
    fetchAllLocation();
  }

  updateLocation(LocationModel locationModel){
    locationRepository.update(locationModel);
    fetchAllLocation();
  }

  deleteLocation(int id){
    locationRepository.delete(id);
    fetchAllLocation();
  }

}