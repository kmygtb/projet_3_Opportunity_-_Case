@IsTest
private class AccountCasesControllerTest {

    @TestSetup
    static void setup() {
        Account testAccount = TestDataFactory.createTestAccount();
        TestDataFactory.createTestCase(testAccount.Id, 'Problème de livraison urgente');
        TestDataFactory.createTestCase(testAccount.Id, 'Retard sur facture client');
    }

    // ─── Cas nominal ──────────────────────────────────────────────────────────
    @IsTest
    static void testFindCasesBySubject_avecResultats() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<Case> results = AccountCasesController.findCasesBySubject(
                acc.Id,
                'livraison'
            );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one case');
    }

    // ─── Aucun résultat ───────────────────────────────────────────────────────
    @IsTest
    static void testFindCasesBySubject_sansResultat() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            List<Case> results = AccountCasesController.findCasesBySubject(
                acc.Id,
                'xzqkjf'
            );
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'Should return empty list');
    }

    // ─── accountId null ───────────────────────────────────────────────────────
    @IsTest
    static void testFindCasesBySubject_accountIdNull() {
        Test.startTest();
            try {
                AccountCasesController.findCasesBySubject(null, 'livraison');
                Assert.fail('Une exception aurait dû être levée');
            } catch (AuraHandledException e) {
                Assert.isNotNull(e.getMessage());
            }
        Test.stopTest();
    }

    // ─── Terme vide ───────────────────────────────────────────────────────────
    @IsTest
    static void testFindCasesBySubject_searchTermVide() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
            try {
                AccountCasesController.findCasesBySubject(acc.Id, '');
                Assert.fail('Une exception aurait dû être levée');
            } catch (AuraHandledException e) {
                Assert.isNotNull(e.getMessage());
            }
        Test.stopTest();
    }
}