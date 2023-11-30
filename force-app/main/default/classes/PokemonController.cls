/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-07-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PokemonController {
    
    @AuraEnabled (cacheable = true)
    //Metodo para obtener una lista de objetos de tipo "Pokemones__c" de Salesforce que cumplen con los criterios de búsqueda del filtro.
    public static List<Pokemones__c> getPokemonList(String searchKey, String typeFilter, String generationFilter){
        String soqlQuery = 'SELECT id, Name, Generacion__c, Tipo__c FROM Pokemones__c ';

        if (searchKey != null){ //Buscar Name
            soqlQuery += 'WHERE Name LIKE \'%' + searchKey + '%\'';
        }

        if (!String.isBlank(typeFilter) && typeFilter != null){ //Buscar tipo
            soqlQuery += ' AND Tipo__c includes (\'' + typeFilter + '\')';
        }

        if (!String.isBlank(generationFilter) && generationFilter != null){ //Buscar generacion
            soqlQuery += ' AND Generacion__c = ' + generationFilter;
        }

        soqlQuery += ' ORDER BY Name';
        return Database.query(soqlQuery);
    }

    public static List<Pokemones__c> getPokemonHome(String searchKey, String typeFilter, String generationFilter){
        String soqlQuery = 'SELECT id, Name, Generacion__c, Tipo__c FROM Pokemones__c ';

        if (searchKey != null){ //Buscar Name
            soqlQuery += 'WHERE Name LIKE \'%' + searchKey + '%\'';
        }

        if (!String.isBlank(typeFilter) && typeFilter != null){ //Buscar tipo
            soqlQuery += ' AND Tipo__c includes (\'' + typeFilter + '\')';
        }

        if (!String.isBlank(generationFilter) && generationFilter != null){ //Buscar generacion
            soqlQuery += ' AND Generacion__c = ' + generationFilter;
        }

        soqlQuery += ' ORDER BY Name';
        return Database.query(soqlQuery);
    }

    @AuraEnabled (cacheable = true)
    public static void addPokemonToTrainer(String trainerName, String pokemonId) {
        // Buscar el ID del entrenador en base a su nombre
        List<Trainers__c> trainers = [SELECT  Name FROM Trainers__c WHERE Name = :trainerName LIMIT 1];
        
        if (trainers.size() > 0) {
            Trainers__c trainer = trainers[0];
            // Agregar el ID del Pokémon al campo Pokemon__c en el objeto Entrenador__c
            if (trainer.Name != null) {
                trainer.Name += ';' + pokemonId;
            } else {
                trainer.Name = pokemonId;
            }
            // Actualizar el objeto Entrenador__c
            update trainer;
        } else {
            throw new AuraHandledException('No se encontró ningún entrenador con el nombre especificado: ' + trainerName);
        }
    }
}