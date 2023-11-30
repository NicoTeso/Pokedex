/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Habilidades implements Database.AllowsCallouts, Database.Batchable<String>, Database.Stateful {
    
    public Iterable<String> start(Database.BatchableContext BC) {
        list<String> listaUrl = new list<String>();
        String apiUrl = 'https://pokeapi.co/api/v2/ability?offset=0&limit=363'; 

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> listaObjetos = (List<Object>) jsonResponse.get('results');
            for (Object habilidadObj : listaObjetos) {
                Map<String, Object> habilidadDetalle = (Map<String, Object>) habilidadObj;
                String habilidadName = (String) habilidadDetalle.get('name');
                String url = (String) habilidadDetalle.get('url');
                listaUrl.add(url);
            }
        }
        return listaUrl;
    }

    public void execute(Database.BatchableContext BC, List<String> listaUrl) {
        list<Habilidad__c> listaHabilidades = new list<Habilidad__c>();

        for(String str : listaUrl){

            Http http = new Http(); // Crea una instancia de Http
            HttpRequest detailsRequest = new HttpRequest();

            detailsRequest.setEndpoint(str);
            detailsRequest.setMethod('GET');
            HttpResponse detailsResponse = http.send(detailsRequest);

            if (detailsResponse.getStatusCode() == 200) {
                Map<String, Object> detailsJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(detailsResponse.getBody());
                String name=(String)detailsJsonResponse.get('name');
                String id =  String.valueOf(detailsJsonResponse.get('id'));
                String efecto = (String)detailsJsonResponse.get('effect');

                List<Object> effectentries = (List<Object>) detailsJsonResponse.get('effect_entries');
            

                    for(Object effectObj : effectentries){
                        Map<String, Object> language = (Map<String, Object>) effectObj;
                        String short_effect=(String) language.get('short_effect');
                        Map<String, Object> statData = (Map<String, Object>) language.get('language');
                        String statName = (String) statData.get('name');

                        if(statName.equals('en')){
                            efecto=short_effect;
                        }
                    }
                    
                    Habilidad__c newHabilidad = new Habilidad__c(
                        ExstId__c = id,
                        Name = name,
                        Efecto__c = efecto
                    );
                    listaHabilidades.add(newHabilidad);

                

                System.debug(listaHabilidades); // Verifica si la lista contiene los registros que esperas insertar

            }
        }
    System.debug(listaHabilidades);    
    insert listaHabilidades;
    

}
    public void finish(Database.BatchableContext BC) {
        System.debug('Proceso de Habilidades completado.');
    }


}