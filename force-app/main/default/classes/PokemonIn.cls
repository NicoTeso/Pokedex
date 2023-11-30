/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-27-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
//*Altura__c, Ataque__c, CreatedById, Defensa__c, Entrenador__c,Evolucion__c, ExistId__c, Habilidad__c, LastModifiedById, Numero_de_Pokemon__c, OwnerId, Peso__c, Name, Tipo__c, Velocidad__c, Vida__c

public class PokemonIn implements Database.AllowsCallouts, Database.Batchable<String> {
    List<String> scope = new List<String>();

    public List<Pokemones__c> pokemonList;

    public Iterable<String> start(Database.BatchableContext BC) {
        // Inicializa un nuevo objeto HTTP para realizar la solicitud
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // Establece la URL de la API de Pokémon a la que se realizará la solicitud
        String url = 'https://pokeapi.co/api/v2/pokemon?limit=900';
        request.setEndpoint(url);
        request.setMethod('GET');

        // Envía la solicitud HTTP y obtiene la respuesta
        HttpResponse response = http.send(request);

        // Verifica si el código de estado de la respuesta es 200 (éxito)
        if (response.getStatusCode() == 200) {
            // Convierte la respuesta JSON en un mapa no tipado para manipulación
            Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Obtiene la lista de resultados de la API
            List<Object> lista = (List<Object>) data.get('results');
            // Itera sobre cada objeto en la lista de resultados de la API

            for (Object obj : lista) {
                //crear nuevo objeto pokemon 
                Map<String, Object> resultados = (Map<String, Object>) obj;
                Pokemones__c pokemon = new Pokemones__c();
                pokemon.Name = (String) resultados.get('name');
                pokemon.Url__c = (String) resultados.get('url');
                // Agrega el nuevo registro a la lista de Pokémon
                pokemonList.add(pokemon);
            }

        } else {
            // Si la solicitud no fue exitosa, imprime un mensaje de error
            System.debug('Error al conectar con la API');
        }
            return scope ;    
    }
    

    public void execute(Database.BatchableContext BC, List<String> scope) {
        System.debug('Cantidad de registros recibidos en execute: ' + scope.size());
        for (String pokemonUrl  : scope) {
            // Realizar la solicitud HTTP a la URL de cada Pokemon
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(pokemonUrl);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            // Verificar si la solicitud fue exitosa
            if (response.getStatusCode() == 200) {
                // Procesar la respuesta y obtener los detalles del Pokemon
                // Convertir la respuesta en un mapa para manipulación
                Map<String, Object> pokemonDetails = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                // Obtener el campo "altura" del Pokemon si existe
                if (pokemonDetails.containsKey('height')) {
                    Object heightObj = pokemonDetails.get('height');
                    if (heightObj != null && heightObj instanceof Integer) {
                        Integer height = (Integer) heightObj;
                        Pokemones__c pokemonRecord = new Pokemones__c(Altura__c = height);
                        // Inserta o actualiza el registro en Salesforce
                        System.debug(pokemonRecord);
                    insert pokemonRecord ;
                    }
                } else {
                    System.debug('El campo "altura" no existe para este Pokemon');
                }
            } else {
                // Si la solicitud no fue exitosa, imprimir un mensaje de error en la consola de depuración
                System.debug('Error al obtener los detalles del Pokemon');
            }
        }
    }
    public void finish(Database.BatchableContext BC) {
    // Puedes agregar aquí el código que se ejecutará después de que el batch haya terminado
    // Inserta los registros de Pokémon en Salesforce
    insert pokemonList;
    }
}