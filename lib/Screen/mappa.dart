import 'dart:async';

import 'package:FuoriMenu/App_Code/Constants.dart';
import 'package:FuoriMenu/Screen/Wrapper.dart';
import 'package:FuoriMenu/Servizi/AuthFirebase.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'src/locations.dart' as locations;
import '../Models/Attivita.dart';
import 'partner.dart';

class Mappa extends StatefulWidget {

  Mappa({this.auth});

  final AuthService auth;

  @override
  _MappaState createState() => _MappaState();
}

class _MappaState extends State<Mappa> {
  String selectedCategory='nessuna';
  BitmapDescriptor ristoranteMarker;
  BitmapDescriptor caffetteriaMarker;
  BitmapDescriptor pizzeriaMarker;
  BitmapDescriptor beverageMarker;
  BitmapDescriptor fastFoodMarker;
  BitmapDescriptor gastronomiaMarker;
  BitmapDescriptor pasticceriaMarker;

  bool _isLoading;

  GoogleMapController _controller;
  bool isMapCreated = false;
  List<MarkerInfo> _lista;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  StreamSubscription<Event> _onAdded;
  StreamSubscription<Event> _onChanged;

  Query _query;

  /// side list
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  List filteredList = new List<MarkerInfo>(); // names filtered by search text
  ///-------------

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    _filter.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _isLoading = true;

    ///inizializzazione marker icon
    //GET MARKER ICONS
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
        'assets/markerIcons/ristoranteMarker.png')
        .then((onValue) {
      ristoranteMarker = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
        'assets/markerIcons/caffetteriaMarker.png')
        .then((onValue) {
      caffetteriaMarker = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
        'assets/markerIcons/pizzeriaMarker.png')
        .then((onValue) {
      pizzeriaMarker = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
        'assets/markerIcons/beverageMarker.png')
        .then((onValue) {
      beverageMarker = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
        'assets/markerIcons/fastFoodMarker.png')
        .then((onValue) {
      fastFoodMarker = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
        'assets/markerIcons/pasticceriaMarker.png')
        .then((onValue) {
      pasticceriaMarker = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
        'assets/markerIcons/gastronomiaMarker.png')
        .then((onValue) {
      gastronomiaMarker = onValue;
    });

    ///firebsae-----
    _lista = List();
    _query = _database.reference().child("Ristoranti").orderByChild("nome");
    _onAdded = _query.onChildAdded.listen(onEntryAdded);
    _onChanged = _query.onChildChanged.listen(onEntryChanged);

    ///txt listener ----
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = '';
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });

  }

  void onEntryChanged(Event event) {
    _isLoading=false;
    var oldEntry = _lista.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _lista[_lista.indexOf(oldEntry)] =
          MarkerInfo.fromSnapToObj(event.snapshot);
      aggiornaMappa();
    });
  }

  void onEntryAdded(Event event) {
    _isLoading=false;
    setState(() {
      _lista.add(MarkerInfo.fromSnapToObj(event.snapshot));
      aggiornaMappa();
    });
  }

  Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    if (isMapCreated) {
      changeMapMode();
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(''),
          actions: <Widget>[
            DdlCategorie(),
            PopupMenuButton<String>(
              onSelected: scegliOpzione,
              color: Colors.orange,
              itemBuilder: (BuildContext context){
                return Constants.ListMenuOprionsVal.map((String choice){
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(
                      Constants.ListMenuOprions[choice],
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList();
              },
            )
          ],
          backgroundColor: Colors.orange,
        ),
        drawer: Drawer(
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                _buildBar(),
                Divider(
                  height: 4,
                  thickness: 3,
                  color: Color(0xffecebf0),
                ),
                Expanded(child: _buildList()),
              ],
            ),
        ),
        body: Stack(
          children: <Widget>[
            _showCircularProgress(),
            GoogleMap(
              onMapCreated: (GoogleMapController controller) async {
                _controller = controller;
                isMapCreated = true;
                changeMapMode();
                setState(() {
                  aggiornaMappa();
                });
              },
              initialCameraPosition: CameraPosition(
                target: const LatLng(40.997059, 17.216721),
                zoom: 10,
              ),
              markers: _markers.values.toSet(),
            ),
            SiteButton(),
          ]
        ),
      ),
    );
  }

  Widget DdlCategorie() {
    return Padding(
        padding: const EdgeInsets.only(
          top: 5,
          right: 10
        ),
      child:DropdownButton<String>(
        value: selectedCategory,
        icon: Icon(Icons.arrow_downward,color: Colors.white,),
        iconSize: 20,
        underline: Container(
          height: 0,
        ),
        style: TextStyle(color: Colors.white,fontSize: 16),
        dropdownColor: Colors.orange,
        onChanged: scegliCategoria,
        items: Constants.ListCategory.map((String choice){
          return DropdownMenuItem<String>(
            value: choice,
            child: Text(Constants.ListMenuCategory[choice]),
          );
        }).toList(),
      )
    );
  }

  void scegliCategoria(categoria){
    setState(() {
      selectedCategory=categoria;
      if(categoria != 'nessuna'){
        _lista = List();
        _query = _database.reference().child("Ristoranti").orderByChild("categoria").equalTo(categoria);
        _onAdded = _query.onChildAdded.listen(onEntryAdded);
        _onChanged = _query.onChildChanged.listen(onEntryChanged);
        _markers={};
        aggiornaMappa();
        build(context);
      }else{
        _lista = List();
        _query = _database.reference().child("Ristoranti");
        _onAdded = _query.onChildAdded.listen(onEntryAdded);
        _onChanged = _query.onChildChanged.listen(onEntryChanged);
        _markers={};
        aggiornaMappa();
        build(context);
      }
    });
  }

  void scegliOpzione(opzione){
    if(opzione == 'logout'){
      widget.auth.signOut().then((value) =>
        {
          Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => Wrapper(auth:widget.auth),
            ),
          )
        }
      );
    }
  }

  void aggiornaMappa() async {
    //String _iconImage = 'assets/pin.png';
    // ignore: deprecated_member_use
    //final bitmapIcon = await BitmapDescriptor.fromAsset(_iconImage);
    for (final ristorante in _lista) {
      final marker = Marker(
        icon: getMarkerIcon(ristorante.categoria),
        markerId: MarkerId(ristorante.key),
        position: LatLng(ristorante.lat, ristorante.lng),
        infoWindow: InfoWindow(
            title: ristorante.nome,
            snippet: ristorante.via,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartnerPage(ristorante: ristorante),
                ),
              );
            }),
      );
      _markers[ristorante.key] = marker;
    }
  }

  void changeMapMode() {
    getJsonFile("assets/maps/lightTheme.json").then(setMapStyle);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }

  BitmapDescriptor getMarkerIcon(String categoria) {
    switch(categoria){
      case 'ristorante':
        return ristoranteMarker;
        break;
      case 'pizzeria':
        return pizzeriaMarker;
        break;
      case 'bevarage':
        return beverageMarker;
        break;
      case 'fastFood':
        return fastFoodMarker;
        break;
      case 'gastronomia':
        return gastronomiaMarker;
        break;
      case 'caffetteria':
        return caffetteriaMarker;
        break;
      case 'pasticceria':
        return pasticceriaMarker;
        break;
    }
    if (categoria == 'ristorante') {
      return ristoranteMarker;
    }
    if (categoria == 'caffetteria') {
      return caffetteriaMarker;
    }
    if (categoria == 'pizzeria') {
      return pizzeriaMarker;
    }
  }


  //#region lista laterale
  /// visualizza la barra di ricerca
  Widget _buildBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _filter,
        decoration: InputDecoration(
          hintText: ('🔎 Cerca un attività'),
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }

  ///visualizza la lista cercata
  Widget _buildList() {
    if(_searchText.toLowerCase().isEmpty && _lista.length > Constants.MAX_LIST_LENGHT){
      filteredList = _lista.sublist(0,Constants.MAX_LIST_LENGHT);
    }else{
      filteredList = _lista;
      var tempList = List<MarkerInfo>();
      for (var i = 0; i < filteredList.length; i++) {
        if (filteredList[i].contains(_searchText.toLowerCase())) {
          tempList.add(filteredList[i]);
        }
      }
      if(tempList.length > Constants.MAX_LIST_LENGHT){
        filteredList = tempList.sublist(0,Constants.MAX_LIST_LENGHT);
      }else{
        filteredList = tempList;
      }

    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _lista == null ? 0 : filteredList.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          child: ListTile(
              title: _listItem(filteredList[index].nome,
                  filteredList[index].via, filteredList[index].numero,
                  filteredList[index].profilepic),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PartnerPage(ristorante: filteredList[index]
                        ),
                  ),
                );
              }
          ),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xffecebf0)))
          ),
        );
      },
    );

  }


  Widget _listItem(String nome, String via, String numero,String profilepic) {
    return Row(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(profilepic),
            backgroundColor: Colors.white,
          ),
        ),
        SizedBox(width: 10,),
        Flexible(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  nome,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  via ,
                  overflow: TextOverflow.clip,
                ),
              ]),
        ),
      ],
    );
  }

//#endregion

  Widget SiteButton(){
    return Positioned(
      bottom: 30,
      left: 20,
      child: Column(
          children: <Widget>[
            ClipOval(
              //BOTTONE sito web
              child: Material(
                color: Colors.orange, // button color
                child: InkWell(
                  splashColor: Colors.deepOrange, // inkwell color
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 8,
                          bottom: 5,
                          left: 5,
                          top: 5
                      ),
                      child: Image.asset(
                        'assets/Logo.png',
                        height: 50,
                        width: 50,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  onTap: () {
                    //launchWhatsApp(phone: "39" + whp);
                    launch('https://www.ristofoodelivery.it');
                  },
                ),
              ),
            ),
          ]
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }


}
