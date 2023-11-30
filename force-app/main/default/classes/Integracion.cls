/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 10-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Integracion {
    // Clase pública para realizar la integración
    public static void consultarAPI() {
        try {
            // Inicializa un nuevo objeto HTTP para realizar la solicitud
            Http http = new Http();
            HttpRequest conexion = new HttpRequest();
            // Establece la URL de la API de Pokémon a la que se realizará la solicitud
            String url = 'https://pokeapi.co/api/v2/pokemon?limit=900';
            conexion.setEndpoint(url);
            conexion.setMethod('GET');

            // Envía la solicitud HTTP y obtiene la respuesta
            HttpResponse respuesta = http.send(conexion);

            // Verifica si el código de estado de la respuesta es 200 (éxito)
            if (respuesta.getStatusCode() == 200) {
                // Convierte la respuesta JSON en un mapa no tipado para manipulación
                Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(respuesta.getBody());
                // Obtiene la lista de resultados de la API
                List<Object> lista = (List<Object>) data.get('results');
                // Imprime la lista en el registro de depuración
                System.debug(lista);
                // Inicializa una lista para almacenar los registros de Pokémon
                List<Pokemones__c> poke = new List<Pokemones__c>();
                // Imprime la lista de Pokémon en el registro de depuración
                System.debug(poke);

                // Itera sobre cada objeto en la lista de resultados de la API
                for (Object obj : lista) {
                    // Convierte cada objeto en un mapa no tipado para manipulación
                    Map<String, Object> pokemonData = (Map<String, Object>) obj;
                    // Crea un nuevo registro de Pokemones__c en Salesforce
                    Pokemones__c nuevoPokemon = new Pokemones__c();
                    // Asigna el nombre del Pokémon al nuevo registro
                    nuevoPokemon.Name = (String) pokemonData.get('name');
                    // Agrega el nuevo registro a la lista de Pokémon
                    poke.add(nuevoPokemon);
                }
                // Inserta los registros de Pokémon en Salesforce
                insert poke;
                // Imprime un mensaje indicando que el proceso ha terminado
                System.debug('Proceso Terminado');
            } else {
                // Si la solicitud no fue exitosa, imprime un mensaje de error
                System.debug('Error al conectar con la API');
            }
        } catch (Exception e) {
            // Captura cualquier excepción que ocurra durante el proceso
            System.debug('Ocurrió un error durante la solicitud: ' + e.getMessage());
        }
    }
}