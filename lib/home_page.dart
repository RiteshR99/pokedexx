import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedexx/pokemon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void dispose(){
    super.dispose();
  }

  String? selectedPokemon;
  String? selectedType;
  late List<Pokemon> pokedex = [];
  late List<Pokemon> originalPokedex = [];
  String? searchQuery;
  Map<int, bool> showFlavorTextMap = {};

  Future<void> fetchPokemonDetails(Pokemon pokemon) async {
    var response = await http.get(Uri.parse(pokemon.url));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      pokemon.id = jsonData['id'];
      pokemon.imageUrl = jsonData['sprites']['front_default'];

      var speciesUrl = jsonData['species']['url'];
      var speciesResponse = await http.get(Uri.parse(speciesUrl));
      if (speciesResponse.statusCode == 200) {
        var speciesJson = jsonDecode(speciesResponse.body);
        var flavorTextEntries = speciesJson['flavor_text_entries'] as List<dynamic>;
        for (var entry in flavorTextEntries) {
          if (entry['language']['name'] == 'en') {
            pokemon.flavorText = entry['flavor_text'];
            break;
          }
        }
        var types = jsonData['types'] as List<dynamic>;
        pokemon.types = types.map((type) => type['type']['name'].toString()).toList();

      } else {
        print('Failed to fetch species details for ${pokemon.name}: ${speciesResponse.statusCode}');
      }
    } else {
      print('Failed to fetch details for ${pokemon.name}: ${response.statusCode}');
    }
  }

  @override
  void initState(){
    super.initState();
    fetchpokemonData();
  }

  Future<void> fetchpokemonData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('pokedex')) {
      var pokedexJson = prefs.getString('pokedex')!;
      List<dynamic> jsonData = jsonDecode(pokedexJson);
      List<Pokemon> pokedex = [];
      for (var eachPokemon in jsonData) {
        final pokemon = Pokemon(
          name: eachPokemon['name'],
          url: eachPokemon['url'],
        );
        await fetchPokemonDetails(pokemon);
        pokedex.add(pokemon);
      }
      setState(() {
        this.pokedex = pokedex;
      });
    } else {
      var response = await http.get(Uri.https("pokeapi.co", "api/v2/pokemon"));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        List<Pokemon> pokedex = [];
        for (var eachPokemon in jsonData['results']) {
          final pokemon = Pokemon(
            name: eachPokemon['name'],
            url: eachPokemon['url'],
          );
          await fetchPokemonDetails(pokemon);
          pokedex.add(pokemon);
        }

        setState(() {
          this.pokedex = pokedex;
          this.originalPokedex = List.from(pokedex);
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    }
  }
  void filterByType(String type) {
    setState(() {
      if (selectedType == type) {
        selectedType = null;
        pokedex = List.from(originalPokedex);
      } else {
        selectedType = type;
        pokedex = originalPokedex.where((pokemon) => pokemon.types.contains(type)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              'assets/ss.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned.fill(
              top: 75.0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.white),
                        color: Colors.black45,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            icon: Icon(Icons.search, color: Colors.white),
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount: pokedex.length,
                            itemBuilder: (context, index) {
                              final pokemon = pokedex[index];
                              if (searchQuery == null || pokemon.name.toLowerCase().contains(searchQuery!.toLowerCase())) {
                                return _buildPokeTile(pokemon);
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ) ,),
            ),
            Positioned.fill(
              top: 140.0,
              left: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        filterByType('grass');
                      },
                      child: Image.asset('assets/grass.png'),
                    ),
                    InkWell(
                      onTap: () {
                        filterByType('ice');
                      },
                      child: Image.asset('assets/ice.png'),
                    ),
                    InkWell(
                      onTap: () {
                        filterByType('fire');
                      },
                      child: Image.asset('assets/fire.png'),
                    )
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
  Widget _buildPokeTile(Pokemon pokemon) {
    bool showFlavorText = showFlavorTextMap[pokemon.id] ?? false;

    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 2.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/gp.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 40.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.0),
                Text(
                  pokemon.id.toString(),
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    fontFamily: 'Mukta',
                  ),
                ),
                SizedBox(height: 3.0),
                Row(
                  children: [
                    Text(
                      pokemon.name.toString(),
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 35.0,
                        fontFamily: 'Mukta',
                      ),
                    ),
                    SizedBox(width: 20.0),
                    InkWell(
                      onTap: () {
                        setState(() {
                          showFlavorTextMap[pokemon.id] = !showFlavorText;
                        });
                      },
                      child: Icon(showFlavorText ? Icons.arrow_drop_up : Icons.arrow_drop_down_circle),
                    ),
                  ],
                ),
                SizedBox(height: 3.0),
                Visibility(
                  visible: showFlavorText,
                  child: Text(
                    pokemon.flavorText,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.normal,
                      fontSize: 15.0,
                      fontFamily: 'Mukta',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 20.0),
            Image.network(
              pokemon.imageUrl,
              width: 125.0,
              height: 125.0,
            ),
          ],
        ),
      ),
    );
  }
}