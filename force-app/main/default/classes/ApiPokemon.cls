/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class ApiPokemon implements Database.AllowsCallouts, Database.Batchable<String>, Database.Stateful {
    //Esto indica que la clase puede realizar llamadas a servicios externos, se puede ejecutar en lotes y mantiene el estado entre las transacciones por lotes.

     // Método para generar un número aleatorio
    public Integer generateRandomNumber(Integer min,Integer max) {
        return (Integer)Math.floor(Math.random() * (max - min + 1) + min);
    }

    public Iterable<String> start(Database.BatchableContext BC) {
        //Envía una solicitud HTTP GET a PokeApi y recupera una lista de URL de Pokemon. Luego extra las URl y las agrega a una lista. 
        list<String> listaUrl = new list<String>();
        String apiUrl = 'https://pokeapi.co/api/v2/pokemon?offset=0&limit=10';

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) { 
            //Convertir respuesta en mapa
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            //lista de objetos especificos
            List<Object> listaObjetos = (List<Object>) jsonResponse.get('results');
            for (Object pokemonObj : listaObjetos) { //Itera sobre cada objeto de la lista
                Map<String, Object> pokemonNombre = (Map<String, Object>) pokemonObj;
                String pokemonName = (String) pokemonNombre.get('name');
                String url=(String)pokemonNombre.get('url');
                listaUrl.add(url); //Agrega URL y los agrega a lista que utilizara mas adelante
            }
        }
        return listaUrl; //Devuelve la lista que    //un for que hace la llamada a todos y cuando acabe inserta y se ejecuta el segundo lote 
    }
    public void execute(Database.BatchableContext BC, List<String> listUrl) {
        //Procesa cada URL de la lista  envia una solcitud HTTP GET para obtener la informacion detallada de cada Pokemon. Extrae los atributos necesarios 
        list<Pokemones__c> listaPokemon = new list<Pokemones__c>();

        for(String recorrido : listUrl){
            Http http = new Http(); // Crea una instancia de Http
        HttpRequest detailsRequest = new HttpRequest();
        detailsRequest.setEndpoint(recorrido);
        detailsRequest.setMethod('GET');
        HttpResponse detailsResponse = http.send(detailsRequest);

        

        if (detailsResponse.getStatusCode() == 200) {
            Map<String, Object> detailsJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(detailsResponse.getBody());
            
            Integer pokemonHeight = (Integer) detailsJsonResponse.get('height');
            String pokemonName = (String) detailsJsonResponse.get('name');
            Integer id=(Integer)detailsJsonResponse.get('id');
            Integer peso=(Integer)detailsJsonResponse.get('weight');
            Integer defensa = (Integer)detailsJsonResponse.get('defense');

            // tipos
            List<Object> typesListJson = (List<Object>) detailsJsonResponse.get('types');
            String type1 = ''; // Primer tipo
            String type2 = ''; // Segundo tipo
            
            if (typesListJson != null && !typesListJson.isEmpty()) {
                Integer typeCount = 0; // Contador para llevar el registro de los tipos encontrados
                for (Object typeObj : typesListJson) {
                    Map<String, Object> typeMap = (Map<String, Object>) typeObj;
                    if (typeMap != null) {
                        Map<String, Object> types = (Map<String, Object>) typeMap.get('type');
                        if (types != null) {
                            String typeName = (String) types.get('name');
                            if (typeCount == 0) {
                                type1 = typeName;
                            } else if (typeCount == 1) {
                                type2 = typeName;
                            }
                            typeCount++;
                            // Si hemos encontrado dos tipos, salimos del bucle
                            if (typeCount >= 2) {
                                break;
                            }
                        }
                    }
                }
                
            }
            //Habilidades
            List<Object> abilitiesList = (List<Object>)detailsJsonResponse.get('abilities');
            List<String> abilitiesName = new List<String>();
                Map<String, Object> abilityData = (Map<String, Object>) abilitiesList[0];
                Map<String, Object> ability = (Map<String, Object>) abilityData.get('ability');                    
                String abilityName = (String)ability.get('name');
                // Consultar el Id de la habilidad desde Salesforce
            
            Habilidad__c newHabilidad = new Habilidad__c();
                newHabilidad = [SELECT Id FROM Habilidad__c WHERE Name = :abilityName LIMIT 1];


            //front_default
            Map<String, Object> sprites = (Map<String, Object>)detailsJsonResponse.get('sprites');
            String imageUrl = (String)sprites.get('front_default');




            // Movimientos
            List<Object> movesListJson = (List<Object>)detailsJsonResponse.get('moves');
            List<String> movesNames = new List<String>();
            Integer movesCount = 0;
            for (Object moveObj : movesListJson) {
                if (movesCount < 4) { // Limita la cantidad de movimientos a 4 por cada Pokemon
                    Map<String, Object> moveMap = (Map<String, Object>)moveObj;
                    Map<String, Object> moveDetails = (Map<String, Object>)moveMap.get('move');
                    String moveName = (String)moveDetails.get('name');
                    movesNames.add(moveName); // Agrega el nombre del movimiento a la lista
                    movesCount++;
                }
            } 

            // Generar número aleatorio
            Integer randomIndex = generateRandomNumber(0, movesNames.size() - 1);
            String randomMove = movesNames[randomIndex];

            List<Movimiento__c> movements = [SELECT Name, Tipo__c FROM Movimiento__c WHERE Tipo__c = :type1 OR Tipo__c = :type2];
            Movimiento__c aleatorymove;
            Movimiento__c aleatorymove2;
            Movimiento__c aleatorymove3;


            if (!movements.isEmpty()) {
                Integer index = (Integer)Math.floor(Math.random() * movements.size());
                aleatorymove = movements[index];
                Integer index2 = (Integer)Math.floor(Math.random() * movements.size());
                aleatorymove2 = movements[index2];
                Integer index3 = (Integer)Math.floor(Math.random() * movements.size());
                aleatorymove3 = movements[index3];
            }

            // stats
            List <Object> stats = (List<Object>)detailsJsonResponse.get('stats');
                
            Map<String, Object> statVida = (Map<String, Object>)stats[0];
            Map<String, Object> statAtaque = (Map<String, Object>)stats[1];
            Map<String, Object> statDefensa = (Map<String, Object>)stats[2];
            Map<String, Object> statVelocidad = (Map<String, Object>)stats[5];

            //al estar inicilalixando la lista esta antes
            
                Pokemones__c newPokemon = new Pokemones__c(
                    Name = pokemonName,
                    Altura__c = pokemonHeight,
                    Peso__c=peso,
                    ExistId__c = String.valueOf(id),
                    Velocidad__c = (Integer)statVelocidad.get('base_stat'),
                    Vida__c = (Integer)statVida.get('base_stat'),
                    Ataque__c = (Integer)statAtaque.get('base_stat'),
                    Defensa__c= (Integer)statDefensa.get('base_stat'),               
                    Habilidad__c = newHabilidad.Id,
                    Tipo__c=type1+';'+type2,
                    Slot1__c = aleatorymove.id,   
                    Slot2__c = aleatorymove2.id,                 
                    Slot3__c = aleatorymove3.id,
                    Url__c = imageUrl
                    
                );
                listaPokemon.add(newPokemon);
                System.debug(type1 + type2);
        }
        
            } 
            insert listaPokemon;
        }

    public void finish(Database.BatchableContext BC) {
        System.debug('Hemos acabado!!');
    }
}

