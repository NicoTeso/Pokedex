import { LightningElement , api, track} from 'lwc';
import getPokemonList from '@salesforce/apex/PokemonController.getPokemonList';
import addPokemonToTrainer from '@salesforce/apex/PokemonController.addPokemonToTrainer'; // Asegúrate de importar la función correcta

const COLUMNS = [

    {label: '  Nombre Pokemon', fieldName: 'Name', type: 'text'},
    {label: '  Tipo', fieldName: 'Tipo__c', type: 'picklist'},
    {label: '  Generacion', fieldName: 'Generacion__c', type: 'Number'}
];

export default class Pokemon extends LightningElement {

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

    pageSize = 5; // Número de elementos por página
    totalItems = 0; // Número total de elementos
    currentPage = 1; // Página actual
    totalPages = 0; // Número total de páginas
    itemsToDisplay = []; // Elementos a mostrar en la página actual

    //carga la lista de Pokemon cuando este conectado
    connectedCallback(){
        this.loadPokemonList();
    }

    //llama a getPokemonList y actualiza la lista del filtro 
    loadPokemonList(){
        getPokemonList ({
            searchKey: this.searchKey,
            typeFilter: this.selectedType,
            generationFilter: this.selectedGeneration
        })
        .then(result => {
            this.totalItems = result.length;
            this.filteredPokemon = result;
            this.totalItems = result.length;
            this.totalPages = Math.ceil(this.totalItems / this.pageSize);
            this.filteredPokemon = result;
            this.updateItemsToDisplay();
        })
        .catch(error => {
            console.error('Error fetching Pokémon: ' + error);
        });
    }

    updateItemsToDisplay() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = this.currentPage * this.pageSize;
        this.itemsToDisplay = this.filteredPokemon.slice(start, end);
    }

    // Agrega el método handleAddToTrainer para manejar la adición del Pokémon seleccionado a un entrenador
    handleAddToTrainer(event) {
        const selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        if (selectedRows.length) {
            const selectedPokemon = selectedRows[0]; 
            addPokemonToTrainer({ trainerName: this.Name, pokemonId: selectedPokemon.Id })
            .then(result => {
                // Manejar la respuesta si es necesario
            })
            .catch(error => {
                // Manejar los errores si es necesario
                console.error('Error al agregar el Pokémon al entrenador: ' + error);
            });
        } else {
            // Manejar el caso en el que no se selecciona ningún Pokémon
            console.log('No se ha seleccionado ningún Pokémon para agregar al entrenador.');

        }    
        
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

    handlePrevious() {
    if (this.currentPage > 1) {
        this.currentPage--;
        this.updateItemsToDisplay();
    }
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRowName = selectedRows.length ? selectedRows[0].Name : '';
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateItemsToDisplay();
        }
    }
    
}


