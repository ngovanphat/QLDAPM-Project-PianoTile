import 'package:shared_preferences/shared_preferences.dart';

addIntToSF(String key,int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt(key, value);
}
Future<int> getIntValuesSF(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return int
  int intValue = prefs.getInt(key);
  return intValue;
}