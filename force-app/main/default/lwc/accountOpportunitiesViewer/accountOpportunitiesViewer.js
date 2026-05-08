// ─── Imports LWC 
// LightningElement : classe de base de tout composant LWC
// api    : expose une propriété en entrée depuis la page parente
// wire   : décore une méthode pour qu'elle soit appelée automatiquement par le framework
import { LightningElement, api, wire } from 'lwc';

// Méthode Apex chargée automatiquement via @wire dès que recordId est disponible
import getOpportunities from '@salesforce/apex/AccountOpportunitiesController.getOpportunities';

// reduceErrors : utilitaire LWC qui formate les erreurs en messages lisibles
import { reduceErrors } from 'c/ldsUtils';

// refreshApex : force le rechargement d'une donnée @wire sans recharger la page
import { refreshApex } from '@salesforce/apex';


export default class AccountOpportunitiesViewer extends LightningElement {

    @api recordId;       // Id du compte affiché — reçu automatiquement depuis la page Salesforce
    opportunities;       // Liste des Opportunités retournées par @wire — alimente le datatable
    error;               // Message d'erreur affiché dans le template si le chargement échoue
    wiredResult;         // Stocke le résultat brut du @wire — nécessaire pour refreshApex


    // Colonnes du datatable définies dans la classe car elles utilisent des types Salesforce
    // (currency, date) qui pourraient évoluer selon les besoins du composant
    columns = [
        { label: 'Nom Opportunité', fieldName: 'Name',      type: 'text'     },
        { label: 'Montant',         fieldName: 'Amount',    type: 'currency'  },
        { label: 'Date de Clôture', fieldName: 'CloseDate', type: 'date'      },
        { label: 'Phase',           fieldName: 'StageName', type: 'text'      }
    ];


    // Chargement automatique des Opportunités dès que recordId est connu
    // $recordId : le $ indique à @wire de relancer l'appel si recordId change
    @wire(getOpportunities, { accountId: '$recordId' })
    wiredOpportunities(result) {

        // On conserve le résultat brut pour pouvoir le passer à refreshApex plus tard
        this.wiredResult = result;

        if (result.data) {
            // Données reçues avec succès : on alimente le datatable
            this.opportunities = result.data;
            this.error = undefined;
        } else if (result.error) {
            // Erreur Apex : reduceErrors formate le message pour l'affichage
            this.error = reduceErrors(result.error);
            this.opportunities = undefined;
        }
    }


    // Force le rechargement des données @wire sans recharger toute la page
    // Utile si les Opportunités ont été modifiées depuis l'affichage initial
    handleRafraichir() {
        refreshApex(this.wiredResult);
    }


    // Retourne true uniquement si le tableau contient au moins une opportunité
    // Utilisé dans le template avec if:false={hasOpportunities} pour afficher le message "Aucune opportunité"
    get hasOpportunities() {
        return Array.isArray(this.opportunities)
            && this.opportunities.length > 0;
    }
}