@isTest
public class TestDataFactoryTest{
    @isTest static void testCreateContact(){
        List<Contact> contacts = new List<Contact>();
        contacts.add(TestDataFactory.createContact());
        insert contacts;
        List<Contact> contactsDB = [SELECT Id FROM Contact];
        System.assertEquals(1,contactsDB.size());
    }

    @isTest static void testcreateMultipleContacts(){
        Account acc = TestDataFactory.createAccount();
        insert acc;
        List<Contact> contacts = TestDataFactory.createMultipleContacts(10, acc);
        insert contacts;
        List<Contact> contactsDB = [SELECT Id FROM Contact];
        System.assertEquals(10, contactsDB.size());
    }

    @isTest static void testCreateLead(){
        List<Lead> leads = new List<Lead>();
        leads.add(TestDataFactory.createLead());
        insert leads;
        List<lead> LeadsDB = [SELECT Id FROM Lead];
        System.assertEquals(1, leadsDB.size());
    }

    @isTest static void testCreateLeadWithRecordType(){
        List<Lead> leads = new List<Lead>();
        leads.add(TestDataFactory.createLead('BWRD'));
        insert leads;
        List<lead> LeadsDB = [SELECT Id FROM Lead];
        System.assertEquals(1, leadsDB.size());
    }

    @isTest static void testCreateLeadWithInvalidRecordType(){
        List<Lead> leads = new List<Lead>();
        Lead lead =  TestDataFactory.createLead('BWRDX');
        if (lead != null) leads.add(lead);
        if (leads.size() > 0) insert leads;
        List<lead> LeadsDB = [SELECT Id FROM Lead];
        System.assertEquals(0, leadsDB.size());
    }    

    @isTest static void testCreateMultipleLeadsWithRecordType(){
        List<Lead> leads = TestDataFactory.createMultipleLeads(50, 'BWRD');
        insert leads;
        List<lead> LeadsDB = [SELECT Id FROM Lead];
        System.assertEquals(50, leadsDB.size());
    }

    @isTest static void testCreateMultipleLeadsWithoutRecordType(){
        List<Lead> leads = TestDataFactory.createMultipleLeads(25, '');
        insert leads;
        List<lead> LeadsDB = [SELECT Id FROM Lead];
        System.assertEquals(25, leadsDB.size());
    }

    @isTest static void testCreateCase(){
        Contact con1 = TestDataFactory.createContact();
        insert con1;
        List<Case> cases = new List<Case>();
        Cases.add(TestDataFactory.createCase(con1));
        insert Cases;
        List<Case> CasesDB = [SELECT Id FROM Case];
        System.assertEquals(1, CasesDB.size());
    }

    @isTest static void testCreateCaseWithRecordType(){
        Contact con1 = TestDataFactory.createContact();
        insert con1;
        List<Case> cases = new List<Case>();
        Cases.add(TestDataFactory.createCase(con1, 'IT'));
        insert Cases;
        List<Case> CasesDB = [SELECT Id FROM Case];
        System.assertEquals(1 ,CasesDB.size());
    }
    @isTest static void testCreateCaseWithInvalidRecordType(){
        Contact con1 = TestDataFactory.createContact();
        insert con1;
        List<Case> cases = new List<Case>();
        Case c =  TestDataFactory.createCase(con1,'ITX');
        if (c != null) cases.add(c);
        if (cases.size() > 0) insert cases;
        List<Case> CasesDB = [SELECT Id FROM Case];
        System.assertEquals(0, casesDB.size());
    }

    @isTest static void testCreateMultipleCasesWithRecordType(){
        Account acc = TestDataFactory.createAccount();
        insert acc;
        List<Case> cases = TestDataFactory.createMultipleCases(15, 'IT', acc);
        List<case> CasesDB = [SELECT Id FROM Case];
        System.assertEquals(15,casesDB.size());
    }

    @isTest static void testCreateMultipleCasesWithOutRecordType(){
        Account acc = TestDataFactory.createAccount();
        insert acc;
        List<Case> cases = TestDataFactory.createMultipleCases(20, '', acc);
        List<case> CasesDB = [SELECT Id FROM Case];
        System.assertEquals(20, casesDB.size());
    }

    @isTest static void testCreateClass(){
        List<Class__c> classes  = new List<Class__c>();
        classes.add(TestDataFactory.createClass('Websites for Beginners'));
        insert classes;
        List<Class__c> classesDB = [SELECT Id FROM Class__c];
        System.assertEquals(1, classesDB.size());
    }

    @isTest static void testCreateClassRound(){
        List<Class__c> classes = TestDataFactory.createClassRound('In-Person','Fresno');
        insert classes;
        List<Class__c> classesDB = [SELECT Id FROM Class__c];
        System.assertEquals(4, classesDB.size());
    }

    @isTest static void testCreateRegistration(){
        Contact con1 = TestDataFactory.createContact();
        insert con1;
        Class__c cls1 = TestDataFactory.createClass('Websites for Beginners');
        insert cls1;
        
        List<Registration__c> regs  = new List<Registration__c>();
        regs.add(TestDataFactory.createRegistration(con1,cls1));
        insert regs;
        List<Registration__c> regsDB = [SELECT Id FROM Registration__c];
        System.assertEquals(1, regsDB.size());
    }

    //TODO CHECK
    @isTest static void testaddRegistrationsToClass(){
        //Make sure and account with Individuals record type is created.
        Account indAccount = TestDataFactory.createIndividualAccount();
        insert indAccount;
        Class__c cls1 = TestDataFactory.createClass('Websites for Beginners');
        insert cls1;
        List<Registration__c> regs = TestDataFactory.addRegistrationsToClass(10, cls1);
        List<Registration__c> regsDB = [SELECT Id FROM Registration__c];
        System.assertEquals(10, regsDB.size());
    }

    @isTest static void testCreateApprenticeship(){
        Contact con1 = TestDataFactory.createContact();
        insert con1;
        
        List<Apprenticeship__c> apss  = new List<Apprenticeship__c>();
        apss.add(TestDataFactory.createApprenticeship(con1));
        insert apss;
        List<Apprenticeship__c> apssDB = [SELECT Id FROM Apprenticeship__c];
        System.assertEquals(1, apssDB.size());
    }

    @isTest static void testCreateApprentice(){
        Contact conLead = TestDataFactory.createContact();
        insert conLead;
        Apprenticeship__c aps1 = TestDataFactory.createApprenticeship(conLead);
        insert aps1;
        Contact con1 = TestDataFactory.createContact();
        insert con1;
        
        List<Apprentice__c> apcs  = new List<Apprentice__c>();
        apcs.add(TestDataFactory.createApprentice(con1,aps1));
        insert apcs;
        List<Apprentice__c> apcsDB = [SELECT Id FROM Apprentice__c];
        System.assertEquals(1, apcsDB.size());
    }

    @isTest static void testAddApprenticesToApprenticeship(){

        Contact conLead = TestDataFactory.createContact();
        insert conLead;
        Apprenticeship__c aps1 = TestDataFactory.createApprenticeship(conLead);
        insert aps1;

        List<Apprentice__c> apcs1 = TestDataFactory.addApprenticesToApprenticeship(12, aps1);
        List<Apprentice__c> apcsDB = [SELECT Id FROM Apprentice__c];
        System.assertEquals(12, apcsDB.size());
    }

    @isTest static void testCreateGateway(){
        List<Gateway__c> gateways = new List<Gateway__c>();
        gateways.add(TestDataFactory.createGateway('WFT'));
        insert gateways;
        List<Gateway__c> gatewaysDB = [SELECT Id FROM Gateway__c];
        System.assertEquals(1,gatewaysDB.size());
    }

    @isTest static void testCreateAccount(){
        List<Account> accounts = new List<Account>();
        accounts.add(TestDataFactory.createAccount());
        insert accounts;
        List<Account> accountsDB = [SELECT Id FROM Account];
        System.assertEquals(1, accountsDB.size());
    }

    @isTest static void testCreateAccountWithRecordType(){
        List<Account> accounts = new List<Account>();
        accounts.add(TestDataFactory.createAccount('General'));
        insert accounts;
        List<Account> accountsDB = [SELECT Id FROM Account];
        System.assertEquals(1, accountsDB.size());
    }

    @isTest static void testCreateIndividualAccount(){
        List<Account> accounts = new List<Account>();
        accounts.add(TestDataFactory.createIndividualAccount());
        insert accounts;
        List<Account> accountsDB = [SELECT Id FROM Account];
        System.assertEquals(1, accountsDB.size());
    }

    @isTest static void testCreateMultipleAccounts(){
        List<Account> accounts = TestDataFactory.createMultipleAccounts(17,'BWRD');
        insert accounts;
        List<Account> accountsDB = [SELECT Id FROM Account];
        System.assertEquals(17, accountsDB.size());
    }

    @isTest static void testCreateOpportunity(){
        Account acc1 = TestDataFactory.createAccount();
        insert acc1;
        Contact con1 = TestDataFactory.createContact();
        insert con1;

        List<Opportunity> opps = new List<Opportunity>();
        opps.add(TestDataFactory.createOpportunity(acc1, con1));
        insert opps;
        List<Opportunity> oppsDB = [SELECT Id FROM Opportunity];
        System.assertEquals(1, oppsDB.size());
    }

    @isTest static void testCreateOpportunityWithRecordType(){
        Account acc1 = TestDataFactory.createAccount();
        insert acc1;
        Contact con1 = TestDataFactory.createContact();
        insert con1;

        List<Opportunity> opps = new List<Opportunity>();
        opps.add(TestDataFactory.createOpportunity(acc1, con1, 'BWTC'));
        insert opps;
        List<Opportunity> oppsDB = [SELECT Id FROM Opportunity];
        System.assertEquals(1, oppsDB.size());
    }

    @isTest static void testCreateMultipleOpportunities(){
        List<Opportunity> opps = TestDataFactory.createMultipleOpportunities(21,'BWRD');
        List<Opportunity> oppsDB = [SELECT Id FROM Opportunity];
        System.assertEquals(21, oppsDB.size());
    }

}