public with sharing class CERelatedOpps {

    @AuraEnabled
    public static void updateOppAsCommericallyReady(Id expanCityRecId , Id oppRecId) {
        try {
            Opportunity opp = [SELECT Expansion_City__c FROM Opportunity WHERE Id = :oppRecId ];
            opp.Expansion_City__c = expanCityRecId;
            opp.Commercial_Readiness_Opportunity__c =  true;
            
            update opp;
        } catch (Exception ex1) {
            throw new AuraHandledException(ex1.getMessage());
        }
    }

    public static Expansion_City__c getExpanCityDetails(Id expanCityRecId) {

        return  [   SELECT PostalCodes__c, City__c, State__c 
                    FROM Expansion_City__c 
                    WHERE Id = :expanCityRecId ];
    }

    private static List<String> getExpansionCitiesForState(String state) {
        List<String> cities = new List<String>();
        List<Expansion_City__c> expanCities = [SELECT City__c FROM Expansion_City__c WHERE State__c = :state];
        
        for(Expansion_City__c ec : expanCities) {
            cities.add(ec.City__c);
        }
        
        return cities;
    }

    private static List<String> getAllPostalCodesForState(String state) {
        List<String> postalCodes = new List<String>();
        List<Expansion_City__c> expanCities = [SELECT PostalCodes__c  FROM Expansion_City__c WHERE State__c = :state];
        
        for(Expansion_City__c ec : expanCities) {
            if (!String.isBlank(ec.PostalCodes__c)) {
                postalCodes.addAll(ec.PostalCodes__c.deleteWhitespace().Split(','));
            }

        }
        
        return postalCodes;
    }

    private static String formatSortFieldAndDirection(String sortField, String sortDir) {
        String nullsSort = 'NULLS LAST';

        if(String.isBlank(sortField)) {
            sortField = 'Amount';
            sortDir = 'DESC';
        }

        if(String.isBlank(sortDir)) {
            sortDir = sortField.equalsIgnoreCase('Amount') ? 'DESC' : 'ASC';
        }

        if(sortField.equalsIgnoreCase('Amount')) {
            nullsSort = sortDir.equalsIgnoreCase('DESC') ? 'NULLS LAST' : 'NULLS FIRST';
        }

        return (sortField + ' ' + sortDir + ' ' + nullsSort);
    }
    
    private static String formatSortFieldAndDirectionForAccounts(String sortField, String sortDir) {
        String nullsSort = 'NULLS LAST';
        sortField = String.isBlank(sortField) ? 'Name' : sortField;
        sortDir = String.isBlank(sortDir) ? 'ASC' : sortDir;
        
        return (sortField + ' ' + sortDir + ' ' + nullsSort);
    }

    @TestVisible
    private static List<String> splitPostalCodes(String postalCodes) {
        if (String.isNotBlank(postalCodes)) { 
            return postalCodes.deleteWhitespace().Split(',');
        } else {
            return new List<String>();
        }

    }

    private static Set<Id> getRelatedAccountIds(Id expanCityRecId) {
        List<Opportunity> opps = [Select AccountId FROM Opportunity WHERE Expansion_City__c = :expanCityRecId];
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : opps) {
            accountIds.add(opp.AccountId);
        }

        return accountIds;
    }

    @AuraEnabled(cacheable = true)
    public static Integer getRelatedCityOppsCount(Id expanCityRecId) {

        Expansion_City__c expanCity = getExpancityDetails(expanCityRecId);
        String city = expanCity.City__c;
        String state = expanCity.State__c;
        List<String> postalCodes = splitPostalCodes(expanCity.PostalCodes__c);

        Integer oppsCount = [SELECT COUNT() FROM Opportunity 
                            WHERE  ((PostalCode__c IN :postalCodes) OR (City__c = :city AND State__c = :state))
                                AND (Expansion_City__r.city__c != :city) AND StageName != 'Closed Lost'
                            WITH SECURITY_ENFORCED];

        return oppsCount;
    }

    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getRelatedCityOpps(Id expanCityRecId, Integer limitSize, Integer offset, String sortField, String sortDir) {

        Expansion_City__c expanCity = getExpancityDetails(expanCityRecId);
        String city = expanCity.City__c;
        String state = expanCity.State__c;
        List<String> postalCodes = splitPostalCodes(expanCity.PostalCodes__c);
        String sortFieldAndDirection = formatSortFieldandDirection(sortField, sortDir);

        String query = 'SELECT Name, Account.Name, Amount, Stage__c, RecordType.Name, Owner.Name'
                        + ' FROM Opportunity'
                        + ' WHERE ((PostalCode__c IN :postalCodes) OR (City__c = :city AND State__c = :state))'
                        + ' AND (Expansion_City__r.city__c != :city) AND Stage__c != \'Closed Lost\''
                        + ' WITH SECURITY_ENFORCED'
                        + ' ORDER BY ' + sortFieldAndDirection
                        + ' LIMIT :limitSize OFFSET :offset';

        List<Opportunity> opps =  (List<Opportunity>) Database.query(query);

        return opps;
    }

    @AuraEnabled(cacheable = true)
    public static Integer getRelatedStateOppsCount(Id expanCityRecId) {
        Expansion_City__c expanCity = getExpancityDetails(expanCityRecId);
        String state = expanCity.State__c;
        List<String> cities = getExpansionCitiesForState(state);
        List<String> postalCodes = getAllPostalCodesForState(state);
        
        Integer oppsCount = [SELECT COUNT() FROM Opportunity
                            WHERE  State__c = :state
                            AND ((City__c NOT IN :cities AND PostalCode__c NOT IN :postalCodes) AND Expansion_City__c = '' )
                            AND StageName != 'Closed Lost'];

        return oppsCount;
    }

    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getRelatedStateOpps(Id expanCityRecId, Integer limitSize, Integer offset, String sortField, String sortDir) {

        Expansion_City__c expanCity = getExpancityDetails(expanCityRecId);
        String state = expanCity.State__c;
        List<String> postalCodes = getAllPostalCodesForState(state);
        List<String> cities = getExpansionCitiesForState(state);
        String sortFieldAndDirection = formatSortFieldandDirection(sortField, sortDir);

        String query = 'SELECT Id, Name, Account.Name, Amount, Stage__c, RecordType.Name, Owner.Name '
                    + ' FROM Opportunity '
                    + ' WHERE State__c = :state AND ((City__c NOT IN :cities AND PostalCode__c NOT IN :postalCodes) AND Expansion_City__c = NULL) AND Stage__c != \'Closed Lost\' '
                    + ' WITH SECURITY_ENFORCED '
                    + ' ORDER BY ' + sortFieldAndDirection
                    + ' LIMIT :limitSize OFFSET :offset';

        List<Opportunity> opps =  (List<Opportunity>) Database.query(query);

        return opps;
    }

    @AuraEnabled(cacheable = true)
    public static Integer getRelatedAccountsCount(Id expanCityRecId) {

        return getRelatedAccountIds(expanCityRecId).size();
    }

    @AuraEnabled(cacheable = true)
    public static List<Account> getRelatedAccounts(Id expanCityRecId, Integer limitSize, Integer offset, String sortField, String sortDir) {
        Set<Id> accountIds = getRelatedAccountIds(expanCityRecId);
        String sortFieldAndDirection = formatSortFieldAndDirectionForAccounts(sortField, sortDir);

        String query = 'SELECT Name, Owner.Name, Type, Primary_Contact__r.Name'
                        + ' FROM Account'
                        + ' WHERE Id IN :accountIds'
                        + ' WITH SECURITY_ENFORCED'
                        + ' ORDER BY ' + sortFieldAndDirection
                        + ' LIMIT :limitSize OFFSET :offset';
        List<Account> accounts = (List<Account>) Database.query(query);

        return accounts;
    }

    @AuraEnabled(cacheable = true)
    public static Integer getRelatedContactsCount(Id expanCityRecId) {
        Set<Id> accountIds = getRelatedAccountIds(expanCityRecId);
        Integer contactCount = [SELECT COUNT()
                            FROM Contact
                            WHERE AccountId IN :accountIds
                            WITH SECURITY_ENFORCED];
        return contactCount;
    }

    @AuraEnabled(cacheable = true)
    public static List<Contact> getRelatedContacts(Id expanCityRecId, Integer limitSize, Integer offset, String sortField, String sortDir) {
        Set<Id> accountIds = getRelatedAccountIds(expanCityRecId);
        String sortFieldAndDirection = formatSortFieldAndDirectionForAccounts(sortField, sortDir);

        String query = 'SELECT Name, Pronouns__c, Title, Account.Name, Active_Contact__c'
                        + ' FROM Contact'
                        + ' WHERE AccountId IN :accountIds'
                        + ' WITH SECURITY_ENFORCED'
                        + ' ORDER BY ' + sortFieldAndDirection
                        + ' LIMIT :limitSize OFFSET :offset';
        List<Contact> contacts = (List<Contact>) Database.query(query);

        return contacts;
    }    

    @AuraEnabled(cacheable = true)
    public static Integer getLocalAccountsCount(Id expanCityRecId) {
        Expansion_City__c expanCity = getExpancityDetails(expanCityRecId);                                            
        String city = expanCity.City__c;
        String state = expanCity.State__c;
        
        List<String> postalCodes = splitPostalCodes(expanCity.PostalCodes__c);

        Integer accountCount = [SELECT COUNT()
                            FROM Account
                            WHERE ((BillingPostalCode IN :postalCodes) OR (BillingCity = :city AND BillingState = :state))
                            WITH SECURITY_ENFORCED];

        return accountCount;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Account> getLocalAccounts(Id expanCityRecId, Integer limitSize, Integer offset, String sortField, String sortDir) {
        Expansion_City__c expanCity = getExpancityDetails(expanCityRecId);                                            
        String city = expanCity.City__c;
        String state = expanCity.State__c;
        List<String> postalCodes = splitPostalCodes(expanCity.PostalCodes__c);
        String sortFieldAndDirection = formatSortFieldAndDirectionForAccounts(sortField, sortDir);

        String query = 'SELECT Name, Owner.Name, Type, Primary_Contact__r.Name'
                    + ' FROM Account'
                    + ' WHERE ((BillingPostalCode IN :postalCodes) OR (BillingCity = :city AND BillingState = :state))'
                    + ' WITH SECURITY_ENFORCED'
                    + ' ORDER BY ' + sortFieldAndDirection
                    + ' LIMIT :limitSize OFFSET :offset';

        List<Account> accounts = (List<Account>) Database.query(query);

        return accounts;
    }

    @AuraEnabled(cacheable = true)
    public static Integer getLocalContactsCount(Id expanCityRecId) {
        Expansion_City__c expanCity = getExpancityDetails(expanCityRecId);                                            
        String city = expanCity.City__c;
        String state = expanCity.State__c;
        List<String> postalCodes = splitPostalCodes(expanCity.PostalCodes__c);

        Integer contactCount = [SELECT COUNT()
                            FROM Contact
                            WHERE ((Account.BillingPostalCode IN :postalCodes) OR (Account.BillingCity = :city AND Account.BillingState = :state))
                            WITH SECURITY_ENFORCED];

        return contactCount;
    }

    @AuraEnabled(cacheable = true)
    public static List<Contact> getLocalContacts(Id expanCityRecId, Integer limitSize, Integer offset, String sortField, String sortDir) {
        Expansion_City__c expanCity = getExpancityDetails(expanCityRecId);                                            
        String city = expanCity.City__c;
        String state = expanCity.State__c;
        List<String> postalCodes = splitPostalCodes(expanCity.PostalCodes__c);
        String sortFieldAndDirection = formatSortFieldAndDirectionForAccounts(sortField, sortDir);

        String query = 'SELECT Name, Pronouns__c, Title, Account.Name, Active_Contact__c'
                        + ' FROM Contact'
                        + ' WHERE ((Account.BillingPostalCode IN :postalCodes) OR (Account.BillingCity = :city AND Account.BillingState = :state))'
                        + ' WITH SECURITY_ENFORCED'
                        + ' ORDER BY ' + sortFieldAndDirection
                        + ' LIMIT :limitSize OFFSET :offset';

        list<Contact> contacts = (list<Contact>) Database.query(query);
        
        return contacts;
    }
}