import 'dart:convert';
import 'dart:js_util';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:servitodo/screen/auth/login.dart';
import 'package:servitodo/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{

  //interfaz
  var modalSize = 120.0;
  String user = "usuario";
  String location = "Loading..";
  bool serviceEnabled=false;
  Position? _currentPosition;
  LocationPermission? permission;

  //inputs
  var category;

  @override
  void initState(){
    _loadLocation();
    _loadUserData();
    //_modalBottomSheetMenu();
    super.initState();
    /*Future.delayed(Duration(seconds: 0)).then((_) {
      _modalBottomSheetMenu();
    });*/
  }

  _loadLocation() async{
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
        print('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request permissions.');
    }
    _currentPosition=await Geolocator.getCurrentPosition();
    print("obteniendo ubicación para latitud $_currentPosition");
    var res = await Network().getRequest('https://nominatim.openstreetmap.org/reverse.php?lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}&format=json');
    print("resultado ubicación: $location");
    setState(() {
      location = json.decode(res.body)['address']['city'];
    });
  }

  _loadUserData() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var localuser = jsonDecode(localStorage.getString('user')!);
    //asi podemos obtener otros datos de los usuarios
    /*var res = await Network().getData('/profile');
    body = json.decode(res.body);
    localStorage.setString('user', json.encode(body['user']));*/

    if(localuser != null) {
      setState(() {
        user = localuser;
      });
    }
  }

  


  @override
  Widget build(BuildContext context) {
    //esta funcion permite cargar el modal al inicio sin llamarlo a traves de otra funcion
    /*SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
      showModalBottomSheet<void>(
        isDismissible: false,
        enableDrag: false,
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context){
          return new Container();
        }
      );
    });*/
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          location,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black87),
        //automaticallyImplyLeading: false,/*ocultamos el boton de regresar*/
      ),
      drawer: Drawer(/*Menu del boton hamburguesa*/
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Hi, $user',
              style: TextStyle(
                fontWeight: FontWeight.bold
                ),
              ),
              Center(
                child: RaisedButton(
                  elevation: 10,
                  onPressed: (){
                    logout();
                  },
                  color: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Text('Logout'),
                ),
              ),
            ],
          ),
      ),
    );
  }

  void logout() async{
    print("logout");
    var res = await Network().getData('/logout');
    var body = json.decode(res.body);
    print(body);
    if(body['response']=="success" || body['message']=="Unauthenticated."){print("ingresa");
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=>Login()));
    }
  }

  _modalBottomSheetMenu() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      showModalBottomSheet(
        isDismissible: false,
        isScrollControlled:true,
        enableDrag: true,
        context: context,
        barrierColor: Colors.grey.withOpacity(0.5),
        builder: (context) {
          return Container(
            height: modalSize,/*tamaño del modal*/
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(10.0),
                    topRight: const Radius.circular(10.0)
                  )
              ),
              child: new Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(150.0, 10.0, 150.0, 20.0),
                    child: Container(
                      height: 8.0,
                      width: 80.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(const Radius.circular(8.0))
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          style: TextStyle(color: Color(0xFF000000)),
                          cursorColor: Color(0xFF9b9b9b),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.accessible_forward,
                              color: Colors.grey,
                            ),
                            hintText: "¿Buscas algún servicio?",
                            hintStyle: TextStyle(
                                color: Color(0xFF9b9b9b),
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ]
                    )
                  )
                ],
              ),
            )
          );
        }
      );
    });
  }
}
