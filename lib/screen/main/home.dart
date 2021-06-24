import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:servitodo/screen/auth/login.dart';
import 'package:servitodo/network/api.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{

  String name = "usuario";

  @override
  void initState(){
    _loadUserData();
    super.initState();
  }

  _loadUserData() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));

    //asi podemos obtener otros datos de los usuarios
    /*var res = await Network().getData('/profile');
    body = json.decode(res.body);
    localStorage.setString('user', json.encode(body['name']));*/

    if(user != null) {
      setState(() {
        name = user;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test App'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Hi, $name',
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
}