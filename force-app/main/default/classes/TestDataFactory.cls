@IsTest
public class TestDataFactory {
    public static Account createTestAccount() {
        Account acc = new Account(Name='Test Account');
        insert acc;
        return acc;
    }
    /**
     * @method      createTestOpportunity
     * @description Crée et insère une Opportunité de test liée à un compte
     * @param       accountId — Id du compte parent
     * @return      Opportunity — l'opportunité créée avec son Id
     */
    public static Opportunity createTestOpportunity(Id accountId) {
        Opportunity opp = new Opportunity(
                Name='Test Opportunity',
                StageName='Prospecting',
                CloseDate=System.today().addDays(30),
                Amount=10000,
                AccountId=accountId
        );
        insert opp;
        return opp;
    }

    /**
     * @method      createTestCase
     * @description Crée et insère un Case de test lié à un compte
     * @param       accountId — Id du compte parent
     * @param       subject   — Sujet du Case (permet de varier les sujets selon le test)
     * @return      Case — le Case créé avec son Id
     */
    public static Case createTestCase(Id accountId, String subject) {
        Case c = new Case(
            Subject   = subject,
            Status    = 'New',
            Priority  = 'High',
            AccountId = accountId
        );
        insert c;
        return c;
    }
}