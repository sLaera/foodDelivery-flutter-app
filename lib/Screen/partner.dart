import 'dart:async';
import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:FuoriMenu/Models/Attivita.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PartnerPage extends StatefulWidget {
  PartnerPage({this.ristorante});

  MarkerInfo ristorante;

  @override
  PartnerPageState createState() => PartnerPageState(ristorante);
}

class PartnerPageState extends State<PartnerPage> {
  PartnerPageState(MarkerInfo ristorante);

  @override
  Widget build(BuildContext context) {
    String nomeRistorante = widget.ristorante.nome;
    String descrizioneRistorante = widget.ristorante.descrizione;
    String numero = widget.ristorante.numero;
    String imageURL = widget.ristorante.imageURL;
    String categoria = widget.ristorante.categoria;
    String facebookUrl = widget.ristorante.facebook;
    String via = widget.ristorante.via;
    String wapp=widget.ristorante.whatsapp;
    String profilepic=widget.ristorante.profilepic;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
          ),
          //IMMAGINE DI SFONDO
          Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(
                        imageURL,
                      )))),
          //SCHERMATA CON INFORMAZIONI

          SingleChildScrollView(
              child: Column(
            children: <Widget>[
              //SPAZIO DA TOP
              Container(
                height: 200.0,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                //spaziatura dai bordi laterali
                child: Card(
                  //rettangolo bianco
                  child: Container(
                    height: 180.0,
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 27),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                nomeRistorante,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: (FontWeight.bold),
                                  fontSize: 25.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(4),
                            child: Text(
                              via, //max 34 caratteri
                              maxLines: 2,
                              overflow: TextOverflow.clip,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.all(4.0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            color: Color(0xffecebf0),
                            child: Text(
                              StringUtils.capitalize(categoria),
                              style: TextStyle(
                                fontSize: 15.0,
                              ),
                              overflow: TextOverflow.ellipsis,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        descrizioneRistorante,
                        overflow: TextOverflow.clip,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
          Positioned(
            top: 40,
            left: 10,
            child: MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              elevation: 2.0,
              color: Colors.orange,
              child: Icon(
                Icons.arrow_back,
                size: 20.0,
              ),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            ),
          ),
          Positioned.fill(
            top: 100,
            child: Align(
              alignment: Alignment.topCenter,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(profilepic),
                backgroundColor: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        whatsappButton(wapp),
                        SizedBox(
                          width: 10,
                        ),
                        ClipOval(
                          //BOTTONE FACEBOOK
                          child: Material(
                            color: Colors.orange, // button color
                            child: InkWell(
                              splashColor: Colors.deepOrange, // inkwell color
                              child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.asset('assets/Icons/facebook.ico')),
                              onTap: () {
                                _launchUrl(facebookUrl);
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ClipOval(
                          //BOTTONE TELEFONO
                          child: Material(
                            color: Colors.orange, // button color
                            child: InkWell(
                              splashColor: Colors.deepOrange, // inkwell color
                              child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.phone)),
                              onTap: () {
                                _launchCaller(numero);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ) //TELEFONO FEISBUK
        ],
      ),
    );
  }
}

_launchCaller(String numero) async {
  var url = "tel:" + numero;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_launchUrl(String addr) async {
  var url = addr;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

void launchWhatsApp({
  @required String phone,
}) async {
  String a = "https://api.whatsapp.com/send?phone=" + phone;

  if (await canLaunch(a)) {
    await launch(a);
  } else {
    throw 'Could not launch ${a}';
  }
}

whatsappButton(String whp){
  if(whp=="") {
    return SizedBox(height: 0,width: 0,);
  } else {
    return ClipOval(
    //BOTTONE WHATSAPP
    child: Material(
      color: Colors.orange, // button color
      child: InkWell(
        splashColor: Colors.deepOrange, // inkwell color
        child: SizedBox(
            width: 50,
            height: 50,
            child: Image.asset('assets/Icons/whatsapp.ico'),
        ),
        onTap: () {
          launchWhatsApp(phone: "39" + whp);
        },
      ),
    ),
  );
  }
}
