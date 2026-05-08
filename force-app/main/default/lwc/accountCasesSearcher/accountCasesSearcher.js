// ─── Imports LWC 
// LightningElement : classe de base de tout composant LWC
// api : expose une propriété en entrée depuis la page parente
import { LightningElement, api } from 'lwc';

// Import de la méthode Apex — appelée manuellement via handleSearch()
import findCasesBySubject from '@salesforce/apex/AccountCasesController.findCasesBySubject';


// ─── Colonnes du datatable 
// Définie hors de la classe : constante partagée, créée une seule fois en mémoire
const COLUMNS = [
    { label: 'Sujet',    fieldName: 'Subject',  type: 'text' },
    { label: 'Statut',   fieldName: 'Status',   type: 'text' },
    { label: 'Priorité', fieldName: 'Priority', type: 'text' },
];


export default class AccountCaseSearchComponent extends LightningElement {

    @api recordId;       // Id du compte affiché — reçu automatiquement depuis la page Salesforce
    cases;               // Liste des Cases retournés par Apex — déclenche le rendu du datatable
    error;               // Message d'erreur affiché dans le template si présent
    searchTerm = '';     // Terme saisi par l'utilisateur, initialisé vide
    columns = COLUMNS;   // Référence à la constante des colonnes


    // Synchronise searchTerm à chaque frappe dans lightning-input
    // event.detail.value est la valeur standard LWC (à préférer à event.target.value)
    updateSearchTerm(event) {
        this.searchTerm = event.detail.value;
    }


    handleSearch() {

        // Garde : bloque l'appel serveur si la saisie est vide ou ne contient que des espaces
        if (!this.searchTerm || this.searchTerm.trim() === '') {
            this.error = 'Veuillez saisir un terme de recherche.';
            this.cases = undefined;
            return;
        }

        // Appel Apex avec l'Id du compte et le terme nettoyé (.trim() supprime les espaces parasites)
        findCasesBySubject({
            accountId: this.recordId,
            subjectSearchTerm: this.searchTerm.trim()
        })
        .then(result => {
            if (result && result.length > 0) {
                // Résultats trouvés : on alimente le datatable et on efface toute erreur précédente
                this.cases = result;
                this.error = undefined;
            } else {
                // Appel réussi mais aucun Case ne correspond au terme recherché
                this.cases = undefined;
                this.error = 'Aucun cas trouvé pour ce terme de recherche.';
            }
        })
        .catch(error => {
            // Récupère le message précis de l'AuraHandledException levée en Apex
            // Le || fournit un message de secours si body.message est absent
            this.error = error?.body?.message || 'Une erreur est survenue lors de la recherche.';
            this.cases = undefined;
        });
    }
}