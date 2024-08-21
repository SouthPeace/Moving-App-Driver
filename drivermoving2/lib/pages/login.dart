
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class login2 extends StatefulWidget {
  @override
  _loginstate2 createState() => _loginstate2();
}

var password_check = "";
var message = "";
var link_reg = "";
class _loginstate2 extends State<login2> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login(String email , password) async {
    link_reg = "";
    try{
      var url = "https://www.site.com/flutter_driver_login";
      final response = await http.post(
        // Uri.parse('https://jsonplaceholder.typicode.com/albums'),
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if(response.statusCode == 200){

        var data = jsonDecode(response.body.toString());
        print(data['token']);
        print('Login successfully');
        if(data['application_progress'] == 'not_complete'){

          setState(() {
            message = 'driver registration not complete';
            link_reg = 'go_register';
          });

        }else if(data['application_progress'] == 'being_processed'){

          setState(() {
            message = 'driver registration being processed';
            link_reg = 'go_register';
          });

        }else if(data['application_progress'] == 'rejected'){

          setState(() {
            message = 'we are sorry to inform you on your application being rejected';
            link_reg = 'go_register';
          });

        }else if(data['application_progress'] == 'approved'){
          password_check ="";
          message = '';
          link_reg = '';
          Navigator.pushNamed(context, '/dashboard', arguments: {
            'driver_id': data['driver_id'],
            'password': password,
          });
        }


      }else if(response.statusCode == 201){
        print('password doesnt exist');
        passwordController.clear();
        setState(() {
          password_check = "passward is not correct";
        });
      }
    }catch(e){
      print(e.toString());
    }
  }

  Color mainColor = Color(0xff247BA0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Image.asset(
                'assets/bloommlogo.png',
                fit: BoxFit.fitWidth,
                height: 100,
                width: 100,
              ),
            ),
            Container(
                width: 100,
                child: Text('MDriver', style: TextStyle(fontSize: 25))
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(password_check),
            Text(message),
            (link_reg == "go_register") ? GestureDetector(
              child: Text(link_reg, style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
              onTap: () async {
                final url = 'https://www.google.com';
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication,);
              },
            ) : Text(""),
            TextFormField(
              controller: emailController,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                  hintText: 'Email',
                hintStyle: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 20,),
            TextFormField(
              controller: passwordController,
              style: TextStyle(fontSize: 20),
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Password',
                hintStyle: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(height: 40,),
            GestureDetector(
              onTap: (){

                login(emailController.text.toString(), passwordController.text.toString());
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Center(child: Text('Login',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),),
              ),
            ),
            Text(""),
            Row(
              children: <Widget>[
                Spacer(),
                Container(
                  width: 160.0,
                  child: GestureDetector(
                    onTap: (){
                      password_check ="";
                      message = '';
                      link_reg = '';
                      Navigator.pushNamed(context, '/home');
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Center(child: Text('Register',style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
