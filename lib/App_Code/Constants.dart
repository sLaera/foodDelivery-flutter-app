class Constants{
  static List<String> ListCategory=['ristorante','pizzeria','bevarage','fastFood','gastronomia','caffetteria','pasticceria','nessuna'];
  //mappa ogni categoria a cosa mostrare nel menu
  static Map<String,String> ListMenuCategory={
    'ristorante':'Ristorante',
    'pizzeria': 'Pizzeria',
    'bevarage':'Beverage',
    'fastFood':'Fast Food',
    'gastronomia':'Gastronomia',
    'caffetteria':'Caffetteria',
    'pasticceria':'Pasticceria',
    'nessuna':'Tutte le Attività'
  };

  static List<String> ListMenuOprionsVal=['logout'];
  static Map<String,String> ListMenuOprions={'logout': 'Disconnetti'};

  ///------costanti
  static int MAX_LIST_LENGHT = 20;
}