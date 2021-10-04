import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class Network{
  //tuto: https://medium.com/swlh/authenticating-flutter-application-with-laravel-api-caea30abd57
  //url base de laravel api
  //if you are using android studio emulator, change localhost to 10.0.2.2
  final String _host = 'localhost';
  final String _url = 'http://localhost:8000/api/v1';

  //variable inicial de token.
  var token;

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token')!);
  }
  
  authData(data, apiUrl) async {
    //verifica conexión https://plus.fluttercommunity.dev/docs/connectivity_plus/usage
    var connectivityResult = await (Connectivity().checkConnectivity());
    // I am not connected to a mobile network. && I am not connected to a wifi network. 
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // final result = await InternetAddress.lookup(_host); //para validad conexion solo dispositivo mobil
      var fullUrl = _url + apiUrl;
      final response = await http.post(
            Uri.parse(fullUrl),
            body: jsonEncode(data),
            headers: _setHeaders()
      );
      return response;
    } 
  }

  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    await _getToken();
    print('token: $token');
    return await http.get(
        Uri.parse(fullUrl),
        headers: _setHeaders()
    );
  }

  getRequest(apiUrl) async {
    await _getToken();
    print('token: $token');
    return await http.get(
        Uri.parse(apiUrl),
        headers: _setHeaders()
    );
  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
    'Authorization' : 'Bearer $token'
  };

}