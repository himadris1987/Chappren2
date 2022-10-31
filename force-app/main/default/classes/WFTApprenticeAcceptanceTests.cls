@istest
public class WFTApprenticeAcceptanceTests {
    @isTest
    public static void testGetApprentice() {
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        Contact cont = new Contact(AccountId = acct.Id,
                           FirstName = 'Test Apprentice',
                           LastName = 'Test Apprentice',
                           Email = 'testapp@test.com');
        insert cont;

        Contact contLead = new Contact(AccountId = acct.Id,
                           FirstName = 'Test Apprentice Lead',
                           LastName = 'Test Apprentice Lead',
                           Email = 'testapplead@test.com');
        insert contLead;

        Apprenticeship__c app = new Apprenticeship__c(Name = 'Test Apprenticeship', Apprenticeship_Lead__c = contLead.Id);
        insert app;

        Apprentice__c apprentice = new Apprentice__c(Apprenticeship__c = app.Id, Contact__c = cont.Id);
        insert apprentice;

        WFTApprenticeAcceptanceController c = new WFTApprenticeAcceptanceController();
        c.appId = apprentice.Id;
        c.getApprentice();

        System.assertEquals(apprentice.Id,  c.apprentice.Id);

    }

    @isTest
    public static void testAcceptApprenticeship() {
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        Contact cont = new Contact(AccountId = acct.Id,
                           FirstName = 'Test Apprentice',
                           LastName = 'Test Apprentice',
                           Email = 'testapp@test.com');
        insert cont;

        Contact contLead = new Contact(AccountId = acct.Id,
                           FirstName = 'Test Apprentice Lead',
                           LastName = 'Test Apprentice Lead',
                           Email = 'testapplead@test.com');
        insert contLead;

        Apprenticeship__c app = new Apprenticeship__c(Name = 'Test Apprenticeship', Apprenticeship_Lead__c = contLead.Id);
        insert app;

        Apprentice__c apprentice = new Apprentice__c(Apprenticeship__c = app.Id, Contact__c = cont.Id);
        insert apprentice;

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('WFTApprenticeAcceptanceMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        WFTApprenticeAcceptanceController c = new WFTApprenticeAcceptanceController();
        c.appId = apprentice.Id;
        c.getApprentice();
        c.acceptApprenticeship();
        Test.stopTest();
        System.assertEquals(true, c.apprentice.Apprentice_Acceptance__c = true);

    }
    
    @isTest
     public static void testAlreadyAcceptedApprenticeship() {
        Account acct = new Account(Name = 'Test Account');
        insert acct;
        Contact cont = new Contact(AccountId = acct.Id,
                           FirstName = 'Test Apprentice',
                           LastName = 'Test Apprentice',
                           Email = 'testapp@test.com');
        insert cont;

        Contact contLead = new Contact(AccountId = acct.Id,
                           FirstName = 'Test Apprentice Lead',
                           LastName = 'Test Apprentice Lead',
                           Email = 'testapplead@test.com');
        insert contLead;

        Apprenticeship__c app = new Apprenticeship__c(Name = 'Test Apprenticeship', Apprenticeship_Lead__c = contLead.Id);
        insert app;

        Apprentice__c apprentice = new Apprentice__c(Apprenticeship__c = app.Id, Apprentice_Acceptance__c = true, Contact__c = cont.Id);
        insert apprentice;

        WFTApprenticeAcceptanceController c = new WFTApprenticeAcceptanceController();
        c.appId = apprentice.Id;
        c.getApprentice();
        c.acceptApprenticeship();
        Apprentice__c fromDatabase = [SELECT Id, Apprentice_Acceptance__c FROM Apprentice__c WHERE Id =: c.appId];

        System.assertEquals(true, fromDatabase.Apprentice_Acceptance__c);

    }
    
}