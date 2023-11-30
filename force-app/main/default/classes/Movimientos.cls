/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-03-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Movimientos implements Database.AllowsCallouts, Database.Batchable<String>, Database.Stateful {

    public Iterable<String> start(Database.BatchableContext BC) { //Hace lista de url de todos los movimientos 

        list<String> listaUrl = new list<String>();
        String apiUrl = 'https://pokeapi.co/api/v2/move?offset=0&limit=800';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> listaObjetos = (List<Object>) jsonResponse.get('results');
            for (Object movimientoObj:listaObjetos) {
                Map<String, Object> movimientoApi = (Map<String, Object>) movimientoObj;
                Integer abilidadesindentificador = (Integer) movimientoApi.get('id');
                String url=(String)movimientoApi.get('url');
                listaUrl.add(url);
            }
        }

        return listaUrl;
    }
    public void execute(Database.BatchableContext BC, List<String> listUrl) { //se ejecuta mientras haya listas dentro de listUrl
        list<Movimiento__c> listaPokemon = new list<Movimiento__c>();

        Http http = new Http(); // Crea una instancia de Http
        String pokemonDetailsUrl = listUrl.remove(0);
        HttpRequest detailsRequest = new HttpRequest();

        detailsRequest.setEndpoint(pokemonDetailsUrl);
        detailsRequest.setMethod('GET');
        HttpResponse detailsResponse = http.send(detailsRequest);

        if (detailsResponse.getStatusCode() == 200) {
            Map<String, Object> detailsJsonResponse = (Map<String, Object>) JSON.deserializeUntyped(detailsResponse.getBody()); //deserializa 
            String name=(String)detailsJsonResponse.get('name');
            String id =  String.valueOf(detailsJsonResponse.get('id'));

            Integer chanceEfecto=(Integer)detailsJsonResponse.get('effect_chance');
            if(chanceEfecto == null){
                chanceEfecto = 0;
            }
            Integer punteria=(Integer)detailsJsonResponse.get('accuracy');
            System.debug(punteria);
            Integer prioridad=(Integer)detailsJsonResponse.get('priority');
            String efecto=(String)detailsJsonResponse.get('short_effect');
            Integer poder=(Integer)detailsJsonResponse.get('power');
            Integer pp=(Integer)detailsJsonResponse.get('pp');
            
            Map<String, Object> types = (Map<String, Object>) detailsJsonResponse.get('type');
            
            String tipo = (String) types.get('name'); 

            Map<String, Object> obj = (Map<String, Object>) detailsJsonResponse.get('target');

            String objetivo = (String) obj.get('name');

                Movimiento__c movimiento=new Movimiento__c(
                    Punteria__c=punteria,
                    Chance_de_Efecto__c=chanceEfecto,
                    Prioridad__c=prioridad,
                    Name=name,
                    ExistId__c=id,
                    Efecto__c=efecto,
                    Poder__c=poder,
                    Pp__c=pp,
                    Tipo__c= tipo,
                    Objetivo__c = objetivo
                );

                listaPokemon.add(movimiento);
                
            
            }
            insert listaPokemon;

    }
    public void finish(Database.BatchableContext BC) {
    }
}
