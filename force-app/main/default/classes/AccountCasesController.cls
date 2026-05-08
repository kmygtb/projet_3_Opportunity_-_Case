/**
 * @class       AccountCasesController
 * @description Contrôleur Apex exposé au composant LWC AccountCaseSearchComponent.
 *              Suit le pattern Controller / Selector :
 *              - Le Controller valide les entrées et expose la méthode au LWC
 *              - Le Selector (CaseSelector) exécute la requête SOQL
 *              "with sharing" garantit que l'utilisateur ne voit que ses données autorisées.
 */
public with sharing class AccountCasesController {

    /**
     * @method      findCasesBySubject
     * @description Point d'entrée appelé depuis le LWC via import @salesforce/apex.
     *              Valide les paramètres avant toute interaction avec la base,
     *              puis délègue la requête à CaseSelector.
     *
     * @param       accountId         Id du compte dont on recherche les Cases
     * @param       subjectSearchTerm Terme saisi par l'utilisateur dans le champ de recherche
     * @return      List<Case>        Liste des Cases correspondants
     * @throws      AuraHandledException si un paramètre est invalide — capturée par le .catch() LWC
     */
    @AuraEnabled // Rend la méthode accessible depuis un composant LWC ou Aura
    public static List<Case> findCasesBySubject(
        Id accountId,
        String subjectSearchTerm
    ) {
        // Sécurité : un accountId null interrogerait tous les Cases sans filtre de compte
        if (accountId == null) {
            throw new AuraHandledException(
                'Erreur : l\'identifiant du compte est obligatoire.'
            );
        }

        // isBlank() couvre les trois cas : null, "" (vide), "   " (espaces uniquement)
        // Plus fiable qu'un simple == null ou == ''
        if (String.isBlank(subjectSearchTerm)) {
            throw new AuraHandledException(
                'Erreur : le terme de recherche ne peut pas être vide.'
            );
        }

        // Le Controller ne contient aucune requête SOQL — il délègue au Selector
        // Séparation des responsabilités : si la requête change, seul CaseSelector est modifié
        return CaseSelector.getCasesByAccountIdAndSubject(accountId, subjectSearchTerm);
    }
}