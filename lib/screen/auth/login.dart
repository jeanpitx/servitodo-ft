import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:servitodo/network/api.dart';
import 'package:servitodo/screen/main/home.dart';
import 'package:servitodo/screen/auth/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;

  _showMsg(msg,context) {
    final snackBar = SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 5),
      action: SnackBarAction(//boton para cerrar
        label: 'Close',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      //key: _scaffoldKey,
      body: Container(
          color: Colors.teal,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Card(
                        elevation: 4.0,
                        color: Colors.white,
                        margin: EdgeInsets.only(left: 20, right: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[

                                TextFormField(
                                  style: TextStyle(color: Color(0xFF000000)),
                                  cursorColor: Color(0xFF9b9b9b),
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Colors.grey,
                                    ),
                                    hintText: "Email",
                                    hintStyle: TextStyle(
                                        color: Color(0xFF9b9b9b),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  initialValue: "yojean02@hotmail.com",
                                  validator: (emailValue) {
                                    if (emailValue!.isEmpty) {
                                      return 'Please enter email';
                                    }
                                    //validacion de formato de correo
                                    if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailValue)){
                                      return 'The Email format is not valid';
                                    }
                                    email = emailValue;
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  style: TextStyle(color: Color(0xFF000000)),
                                  cursorColor: Color(0xFF9b9b9b),
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.vpn_key,
                                      color: Colors.grey,
                                    ),
                                    hintText: "Password",
                                    labelText: 'Password',
                                    hintStyle: TextStyle(
                                        color: Color(0xFF9b9b9b),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  initialValue: "zambrano1",
                                  validator: (passwordValue) {
                                    if (passwordValue!.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    password = passwordValue;
                                    return null;
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: FlatButton(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: 8, bottom: 8, left: 10, right: 10),
                                      child: Text(
                                        _isLoading? 'Proccessing...' : 'Login',
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.0,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    color: Colors.teal,
                                    disabledColor: Colors.grey,
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                        new BorderRadius.circular(20.0)),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _login();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => Register()));
                          },
                          child: Text(
                            'Create new Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
    );
  }

  void _login() async{
    setState(() {
      _isLoading = true;
    });
    var data = {
      'email' : email,
      'password' : password
    };

    var response = await Network().authData(data, '/login');

    
    if(response.statusCode == 200){
      var body = json.decode(response.body);
      if(body['response']!="failed"){
        print("Iniciando sesión");
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('token', json.encode(body['token']));
        localStorage.setString('user', json.encode(body['user']));
        _showMsg(body['message'],context);
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => Home()
            ),
        );
      }else{
        //_showMsg(body['message'],context); // antes solo estaba asi
        var msg_error=body["message"];
        if(body.containsKey('errors')){
          var errors = body['errors'] as Map;
          errors.forEach((k,v) {//https://gist.github.com/aruld/1299216 or usrMap.forEach((k,v) => print('${k}: ${v}'));
            msg_error+="\n * $k: $v";
          }); 
        }
        _showMsg(msg_error,context);
        print(msg_error);
      }
    }else{
      var msg_error= "Ha ocurrido un error:";
      msg_error+="\n * codigo: ${response.statusCode}";
      var body = json.decode(response.body) as Map;
      body.forEach((k,v) {
        msg_error+="\n * $k: $v";
      }); 
      _showMsg(msg_error,context);
      print(msg_error);
    }

    setState(() {
      _isLoading = false;
    });
  }
}