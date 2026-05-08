public with sharing class AccountOpportunitiesController {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities(Id accountId) {
        return OpportunitySelector.getOpportunitiesByAccountId(accountId);
    }
}