/**
 * @class       CaseSelector
 * @description Couche d'accès aux données pour l'objet Case.
 *              Suit le pattern Selector : toutes les requêtes SOQL sur Case
 *              sont centralisées ici pour faciliter la maintenance et les tests.
 *              "with sharing" applique les règles de partage de l'utilisateur connecté.
 */
public with sharing class CaseSelector {

    /**
     * @method      getCasesByAccountIdAndSubject
     * @description Recherche les Cases d'un compte dont le sujet contient
     *              le terme fourni (recherche partielle gauche-droite via LIKE).
     *
     * @param       accountId         Id du compte parent dont on veut les Cases
     * @param       subjectSearchTerm Terme de recherche partiel sur le champ Subject
     * @return      List<Case>        Liste des Cases correspondants, vide si aucun résultat
     */
    public static List<Case> getCasesByAccountIdAndSubject(
        Id accountId,
        String subjectSearchTerm
    ) {
        // Les % encadrant le terme permettent la recherche partielle :
        // "livr" trouvera "Problème de livraison", "Suivi livraison", etc.
        String searchPattern = '%' + subjectSearchTerm + '%';

        return [
            SELECT Id,
                   Subject,   // Sujet du Case — champ de recherche principal
                   Status,    // Statut (New, Open, Escalated...)
                   Priority   // Priorité (Low, Medium, High)
            FROM   Case
            WHERE  AccountId = :accountId        // Filtre sur le compte parent
            AND    Subject LIKE :searchPattern   // Recherche partielle sur le sujet
            LIMIT  200  // Limite gouverneur : évite de dépasser les seuils Salesforce
        ];
    }
}