import { LightningElement , api, track} from 'lwc';
import getPokemonHome from '@salesforce/apex/PokemonController.getPokemonList';

const COLUMNS = [

    {label: '  Nombre Pokemon', fieldName: 'Name', type: 'text'},
    {label: '  Tipo', fieldName: 'Tipo__c', type: 'text'},
    {label: '  Generacion', fieldName: 'Generacion__c', type: 'Number'}
];

export default class PokemonHome extends LightningElement {

    //Inicializa los valores 
    columns = COLUMNS;
    @api recordId;
    @track filteredPokemon = [];
    @track typeOptions = [

        {label: "", value: " "},

        {label: "Normal", value: "Normal"},
        {label: "Fire", value: "Fire"},
        {label: "Water", value: "Water"},
        {label: "Electric", value: "Electric"},
        {label: "Grass", value: "Grass"},
        {label: "Ice", value: "Ice"},
        {label: "Fighting", value: "Fighting"},
        {label: "Poison", value: "Poison"},
        {label: "Ground", value: "Ground"},
        {label: "Flying", value: "Flying"},
        {label: "Psychic", value: "Psychic"},
        {label: "Bug", value: "Bug"},
        {label: "Rock", value: "Rock"},
        {label: "Ghost", value: "Ghost"},
        {label: "Steel", value: "Steel"},
        {label: "Dragon", value: "Dragon"},
        {label: "Dark", value: "Dark"},
        {label: "Fairy", value: "Fairy"}
    ];
    //Inicializa los valores
    @track selectedType = '';
    @track selectedGeneration = '';
    searchKey = '';
    @track selectedRowName = '';

    //carga la lista de Pokemon cuando este conectado
    connectedCallback(){
        this.loadPokemonList();
    }

    //llama a getPokemonList y actualiza la lista del filtro 
    loadPokemonList(){
        getPokemonHome ({
            searchKey: this.searchKey,
            typeFilter: this.selectedType,
            generationFilter: this.selectedGeneration
        })
        .then(result => {
            this.totalItems = result.length;
            this.filteredPokemon = result;
        })
        .catch(error => {
            console.error('Error fetching Pokémon: ' + error);
        });
    }

    //Actualiza el nombre
    handleSearch(event) {
        this.searchKey = event.target.value;
        this.loadPokemonList();
    }

    //Actualiza el tipo 
    handleTypeChange (event){
        this.selectedType = event.detail.value;
        this.loadPokemonList();
    }

    //Actualiza la generacion
    handleGenerationChange (event) {
        this.selectedGeneration = event.target.value;
        this.loadPokemonList();
    }
}