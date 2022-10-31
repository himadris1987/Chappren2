@isTest 
public class CERelatedOppsTest {

    @testSetup 
    static void setup() {
        Expansion_City__c expanCity = new Expansion_City__c();
        expanCity.Name = 'Fresno';
        expanCity.City__c = 'Fresno';
        expanCity.State__c = 'California';
        expanCity.PostalCodes__c = '93711';
        insert expanCity;

        Account acc1 = TestDataFactory.createAccount();
        acc1.BillingPostalCode = '93711';
        insert acc1;
        Contact con1 = TestDataFactory.createContact();
        con1.AccountId = acc1.Id;
        insert con1;

        Opportunity opp1 = TestDataFactory.createOpportunity(acc1, con1);
        opp1.PostalCode__c = '93711';
        insert opp1;
        
        Contact con2 = TestDataFactory.createContact();
        insert con2;

        Opportunity opp2 = TestDataFactory.createOpportunity(acc1, con2);
        opp2.PostalCode__c = '93611';
        opp2.Expansion_City__c = expanCity.Id;
        opp2.Commercial_Readiness_Opportunity__c = true;
        insert opp2;

        Opportunity opp3 = TestDataFactory.createOpportunity(acc1, con2);
        opp3.State__c = 'California';
        opp3.PostalCode__c = '90241';
        insert opp3;

        Account acc4 = TestDataFactory.createAccount();
        acc4.BillingPostalCode = '22400'; //San Diego'
        acc4.BillingState='California';
        insert acc4;

        Contact con4 = TestDataFactory.createContact();
        con4.AccountId = acc4.Id;
        insert con4;

        Opportunity opp4 = TestDataFactory.createOpportunity(acc4, con4);
        opp4.State__c = 'California';
        opp4.PostalCode__c = '22400';
        insert opp4;
    }

    @isTest
    public static void splitPostalCodesTest() {
        List<String> postalCode = CERelatedOpps.splitPostalCodes('');
        System.assertEquals(new List<String>(), postalCode);
    }

    @isTest 
    public static void updateOppAsCommericallyReadyTest() {
        Expansion_City__c expanCity = [SELECT Id FROM Expansion_City__c WHERE Name = 'Fresno'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE PostalCode__c = '93711'];

       
        CERelatedOpps.updateOppAsCommericallyReady(expanCity.Id, opp.Id);
        
        Integer numOfOppsDB = [SELECT Id FROM Opportunity WHERE Expansion_City__c = :expanCity.Id AND PostalCode__c = '93711' AND Commercial_Readiness_Opportunity__c = True].size();
        System.assertEquals(1, numOfOppsDB);
    }

    @isTest
    public static void getRelatedCityOppsCountTest() {
        Expansion_City__c expanCity = [SELECT Id FROM Expansion_City__c WHERE Name = 'Fresno'];

        
        Integer oppsCountDB = CERelatedOpps.getRelatedCityOppsCount(expanCity.Id);
        

        System.assertEquals(1, oppsCountDB);
    }

    @isTest 
    public static void getRelatedCityOppsTest() {
        List<Opportunity> oppsDB = new List<Opportunity>();
        Expansion_City__c expanCity = [SELECT Id FROM Expansion_City__c WHERE Name = 'Fresno'];

        
        oppsDB = CERelatedOpps.getRelatedCityOpps(expanCity.Id, 50, 0, 'Amount', 'Desc');
        

        System.assertEquals(1, oppsDB.size());
    }

    @isTest
    public static void getRelatedStateOppsCountTest() {
        Expansion_City__c expanCity = [SELECT Id FROM Expansion_City__c WHERE State__c = 'California'];

        
        Integer oppsCountDB = CERelatedOpps.getRelatedStateOppsCount(expanCity.Id);
        

        System.assertEquals(2, oppsCountDB);
    }
    
    @isTest 
    public static void getRelatedStateOppsTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];

        
        List<Opportunity> oppsDB = CERelatedOpps.getRelatedStateOpps(expanCity.Id, 50, 0, 'Amount', 'Desc');
        

        System.assertEquals(2, oppsDB.size());
    }

     @isTest 
    public static void getRelatedStateOppsNoSortTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];

        //test for blank sort field and sort dir
        List<Opportunity> oppsDB = CERelatedOpps.getRelatedStateOpps(expanCity.Id, 50, 0, '', ''); 
        

        System.assertEquals(2, oppsDB.size());
    }

     @isTest 
    public static void getRelatedStateOppsNoSortDirTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];

        //test for sort dir
        List<Opportunity> oppsDB = CERelatedOpps.getRelatedStateOpps(expanCity.Id, 50, 0, 'Amount', ''); 
        

        System.assertEquals(2, oppsDB.size());
    }

    @isTest
    public static void getRelatedAccountsCountTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];
        
        
        Integer accountCountDB = CERelatedOpps.getRelatedAccountsCount(expanCity.Id);
        

        System.assertEquals(1, accountCountDB);
    }

    @isTest 
    public static void getRelatedAccountsTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];

        
        List<Account> accountsDB = CERelatedOpps.getRelatedAccounts(expanCity.Id, 50, 0, 'Name', 'Desc');
        

        System.assertEquals(1, accountsDB.size());
    }

    @isTest
    public static void getRelatedContactsCountTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];
        
        
        Integer contactCountDB = CERelatedOpps.getRelatedContactsCount(expanCity.Id);
        

        System.assertEquals(1, contactCountDB);
    }

    @isTest 
    public static void getRelatedContactsTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];

        
        List<Contact> contactsDB = CERelatedOpps.getRelatedContacts(expanCity.Id, 50, 0, 'Name', 'Desc');
        

        System.assertEquals(1, contactsDB.size());
    }

    @isTest
    public static void getLocalAccountsCountTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE Name = 'Fresno'];
        
        Integer accountsCountDB = CERelatedOpps.getLocalAccountsCount(expanCity.Id);
        
        System.assertEquals(1, accountsCountDB);
    }

    @isTest 
    public static void getLocalAccountsTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];
        
        list<Account> accountsDB = CERelatedOpps.getLocalAccounts(expanCity.Id, 50, 0, 'Name', 'Desc');

        System.assertEquals(1, accountsDB.size());
    }

    @isTest
    public static void getLocalContactsCountTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];
        
        Integer contactsCountDB = CERelatedOpps.getLocalContactsCount(expanCity.Id);

        System.assertEquals(1, contactsCountDB);
    }

    @isTest 
    public static void getLocalContactsTest() {
        Expansion_City__c expanCity = [SELECT Id, PostalCodes__c FROM Expansion_City__c WHERE State__c = 'California'];
        
        List<Contact> contacts = CERelatedOpps.getLocalContacts(expanCity.Id, 50, 0, 'Name', 'Desc');
       
        System.assertEquals(1, contacts.size());
    }
}