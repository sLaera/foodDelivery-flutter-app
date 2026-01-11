class MarkerInfo {
  String nome;
  String numero;
  String key;
  double lat;
  double lng;
  String via;
  String descrizione;
  String facebook;
  String imageURL;
  String categoria;
  String whatsapp;
  String profilepic;

  MarkerInfo(String nome, String numero, double lat, double lng, String via,
      String descrizione, String facebook,String imageURL,String categoria,String whatsapp,String profilepic,
      {String key = ''}) {
    this.nome = nome;
    this.numero = numero;
    this.lat = lat;
    this.lng = lng;
    this.via = via;
    this.descrizione = descrizione;
    this.facebook = facebook;
    this.imageURL=imageURL;
    this.categoria=categoria;
    if (key != "") this.key = key;
    this.whatsapp=whatsapp;
    this.profilepic=profilepic;
  }

  //---identifica se una stringa è presente tra i parametri dell'attività
  bool contains(String str){
    return nome.toLowerCase().contains(str.toLowerCase())
        || numero.toLowerCase().contains(str.toLowerCase())
        || via.toLowerCase().contains(str.toLowerCase())
        || categoria.toLowerCase().contains(str.toLowerCase());
  }

  //---trasforma lo snapshot di firebase in un oggetto di tipo ristorante
  static fromSnapToObj(var snapshot) {
    return MarkerInfo(
        snapshot.value["nome"],
        snapshot.value["numero"],
        snapshot.value["lat"],
        snapshot.value["lng"],
        snapshot.value["via"],
        snapshot.value["descrizione"],
        snapshot.value["facebook"],
        snapshot.value["imageURL"],
        snapshot.value["categoria"],
        snapshot.value["whatsapp"],
        snapshot.value["profilepic"],
        key: snapshot.key);
  }

  toJson() {
    return {
      "nome": nome,
      "numero": numero,
      "lat": lat,
      "lng": lng,
      "via": via,
      "descrizione": descrizione,
      "facebook": facebook,
      "imageURL": imageURL,
      "categoria": categoria,
    };
  }
}
