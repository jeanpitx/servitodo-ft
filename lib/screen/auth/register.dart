import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:servitodo/network/api.dart';
import 'package:servitodo/screen/main/home.dart';
import 'package:servitodo/screen/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var name;
  var email;
  var password;
  var password_confirmation;

  _showMsg(msg, context) {
    final SnackBar snackBar = SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        child: Container(
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
                                      Icons.info,
                                      color: Colors.grey,
                                    ),
                                    hintText: "Name",
                                    hintStyle: TextStyle(
                                        color: Color(0xFF9b9b9b),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  validator: (nameValue) {
                                    if (nameValue!.isEmpty) {
                                      return 'Please enter Name';
                                    }
                                    name = nameValue;
                                    return null;
                                  },
                                ),

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
                                    hintStyle: TextStyle(
                                        color: Color(0xFF9b9b9b),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  validator: (passwordValue) {
                                    if (passwordValue!.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    password = passwordValue;
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
                                    hintText: "Password Confirmation",
                                    hintStyle: TextStyle(
                                        color: Color(0xFF9b9b9b),
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  validator: (passwordConfirmationValue) {
                                    if (passwordConfirmationValue!.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    if (passwordConfirmationValue!=password) {
                                      return 'The password confirmation does not match';
                                    }
                                    password_confirmation = passwordConfirmationValue;
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
                                        _isLoading? 'Proccessing...' : 'Register',
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
                                          _register();
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
                                    builder: (context) => Login()));
                          },
                          child: Text(
                            'Already Have an Account',
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
      ),
    );
  }
  void _register() async{
    setState(() {
      _isLoading = true;
    });
    var data = {
      'name' : name,
      'email' : email,
      'password': password,
      'password_confirmation': password_confirmation,
    };

    var res = await Network().authData(data, '/register');

    var body = json.decode(res.body);
    print(body);
    if(body.containsKey('response')){
      print("Iniciando sesión");
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('user', json.encode(body['user']));
      _showMsg(body['message'],context);
      //cambiamos de interfaz
      Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => Home()
        ),
      );
    }else{
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

    setState(() {
      _isLoading = false;
    });
  }
}