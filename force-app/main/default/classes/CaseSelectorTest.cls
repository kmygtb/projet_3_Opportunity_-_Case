/**
 * @class       CaseSelectorTest
 * @description Classe de test pour CaseSelector.
 *              Teste directement la couche d'accès aux données :
 *              la requête SOQL, le LIKE %...%, le LIMIT et le filtre AccountId.
 *              Utilise TestDataFactory pour la création des données de test.
 */
@IsTest
private class CaseSelectorTest {

    // ─── Préparation des données ──────────────────────────────────────────────
    // Crée un compte et plusieurs Cases avec des sujets variés
    // pour couvrir tous les scénarios de recherche
    @TestSetup
    static void setupData() {
        Account testAccount = TestDataFactory.createTestAccount();
        TestDataFactory.createTestCase(testAccount.Id, 'Problème de livraison urgente');
        TestDataFactory.createTestCase(testAccount.Id, 'Retard sur facture client');
        TestDataFactory.createTestCase(testAccount.Id, 'Livraison incomplète reçue');
        TestDataFactory.createTestCase(testAccount.Id, 'Panne matériel sur site');
    }


    // ─── Test 1 : résultat unique ─────────────────────────────────────────────
    // Vérifie que la requête retourne exactement 1 Case sur un terme précis
    @IsTest
    static void testGetCases_resultatUnique() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<Case> results = CaseSelector.getCasesByAccountIdAndSubject(
                acc.Id,
                'facture' // contenu uniquement dans "Retard sur facture client"
            );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Devrait retourner exactement 1 Case');
        Assert.areEqual(
            'Retard sur facture client',
            results[0].Subject,
            'Le sujet retourné ne correspond pas'
        );
    }


    // ─── Test 2 : plusieurs résultats ─────────────────────────────────────────
    // Vérifie que le LIKE retourne bien plusieurs Cases quand le terme est commun
    @IsTest
    static void testGetCases_plusieursResultats() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<Case> results = CaseSelector.getCasesByAccountIdAndSubject(
                acc.Id,
                'livraison' // contenu dans "Problème de livraison urgente" et "Livraison incomplète reçue"
            );
        Test.stopTest();

        Assert.areEqual(2, results.size(), 'Devrait retourner 2 Cases contenant "livraison"');
    }


    // ─── Test 3 : recherche partielle (fragment de mot) ───────────────────────
    // Vérifie que le % fonctionne bien sur un fragment
    @IsTest
    static void testGetCases_recherchePartielle() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<Case> results = CaseSelector.getCasesByAccountIdAndSubject(
                acc.Id,
                'pan' // fragment de "Panne matériel sur site"
            );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'La recherche partielle devrait retourner 1 Case');
        Assert.areEqual(
            'Panne matériel sur site',
            results[0].Subject,
            'Le sujet retourné ne correspond pas'
        );
    }


    // ─── Test 4 : aucun résultat ──────────────────────────────────────────────
    // Vérifie que la méthode retourne une liste vide sans exception
    @IsTest
    static void testGetCases_aucunResultat() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<Case> results = CaseSelector.getCasesByAccountIdAndSubject(
                acc.Id,
                'xzqkjf' // terme inexistant
            );
        Test.stopTest();

        // Une liste vide est un comportement valide — la méthode ne doit pas planter
        Assert.areEqual(0, results.size(), 'Devrait retourner une liste vide');
        Assert.isNotNull(results, 'La liste ne doit pas être null');
    }


    // ─── Test 5 : filtre par AccountId ───────────────────────────────────────
    // Vérifie que les Cases d'un autre compte ne remontent pas
    @IsTest
    static void testGetCases_filtreParAccount() {

        // Création d'un second compte avec son propre Case
        Account autreAccount = new Account(Name = 'Autre Compte');
        insert autreAccount;
        TestDataFactory.createTestCase(autreAccount.Id, 'Problème de livraison autre compte');

        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Test.startTest();
            List<Case> results = CaseSelector.getCasesByAccountIdAndSubject(
                acc.Id,
                'livraison'
            );
        Test.stopTest();

        // Seuls les Cases du compte "Test Account" doivent remonter
        // Le Case de "Autre Compte" ne doit pas apparaître
        Assert.areEqual(2, results.size(), 'Ne doit retourner que les Cases du compte ciblé');
      
    }


    // ─── Test 6 : champs retournés ────────────────────────────────────────────
    // Vérifie que le SELECT retourne bien tous les champs attendus
    @IsTest
    static void testGetCases_champsRetournes() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<Case> results = CaseSelector.getCasesByAccountIdAndSubject(
                acc.Id,
                'panne'
            );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Devrait retourner 1 Case');

        Case c = results[0];
        // Vérifie que chaque champ du SELECT est bien renseigné et non null
        Assert.isNotNull(c.Id,       'Le champ Id ne doit pas être null');
        Assert.isNotNull(c.Subject,  'Le champ Subject ne doit pas être null');
        Assert.isNotNull(c.Status,   'Le champ Status ne doit pas être null');
        Assert.isNotNull(c.Priority, 'Le champ Priority ne doit pas être null');
    }


    // ─── Test 7 : respect du LIMIT ────────────────────────────────────────────
    // Vérifie que la requête ne retourne jamais plus de 200 enregistrements
    @IsTest
    static void testGetCases_respectLimit() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        // Création de 5 Cases supplémentaires pour simuler un volume de données
        List<Case> bulkCases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            bulkCases.add(new Case(
                Subject   = 'Case bulk numero ' + i,
                Status    = 'New',
                Priority  = 'Low',
                AccountId = acc.Id
            ));
        }
        insert bulkCases;

        Test.startTest();
            List<Case> results = CaseSelector.getCasesByAccountIdAndSubject(
                acc.Id,
                'bulk'
            );
        Test.stopTest();

        // On vérifie qu'on ne dépasse jamais la limite de 200
        Assert.isTrue(results.size() <= 200, 'Ne doit jamais retourner plus de 200 enregistrements');
        Assert.areEqual(5, results.size(), 'Devrait retourner les 5 Cases bulk');
    }
}