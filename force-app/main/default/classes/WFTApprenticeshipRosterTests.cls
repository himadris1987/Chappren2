@isTest
public class WFTApprenticeshipRosterTests {
    @TestSetup
    static void makeData(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator'  
        AND UserRole.Name = 'System Administrator' AND IsActive = true LIMIT 1];

        System.runAs ( adminUser ) {
        Contact currUserAsContact = new Contact(firstName = 'Contact', lastName = 'User111', email = 'currUserAsContact111@test.com', User__c = adminUser.Id);
            insert currUserAsContact;
        }

        Contact apprenticeLead = TestDataFactory.createContact();
        insert apprenticeLead;

        Apprenticeship__c apprenticeship1 = TestDataFactory.createApprenticeship(apprenticeLead);
        apprenticeship1.Name = 'test apprenticeship1';
        insert apprenticeship1;

        List<Apprentice__c> apprentices = TestDataFactory.addApprenticesToApprenticeship(3, apprenticeship1);
    }

    @isTest
    public static void getApprenticesTest() {
        WFTApprenticeshipRosterController c = new WFTApprenticeshipRosterController();
        Apprenticeship__c apprenticeship = [SELECT Id FROM Apprenticeship__c WHERE Name = 'test apprenticeship1'];

        c.apprenticeshipId = apprenticeship.Id;
        Test.startTest();
        c.getApprentices();
        Test.stopTest();

        System.assertEquals(c.apprentices.size(), 3);
    }
    
    @isTest
    static void showCareerReadyCheckTest() {
      WFTApprenticeshipRosterController c = new WFTApprenticeshipRosterController();
  
      Test.startTest();
      c.showCareerReadyCheck();
      Test.stopTest();
  
      System.AssertEquals(true, c.displayCareerReadyCheck);
    }

    @isTest 
    static void getUserContactIdTest() {
      WFTApprenticeshipRosterController c = new WFTApprenticeshipRosterController();
  
      contact contactUser = new contact(
        firstName = 'Contact1',
        lastName = 'User1',
        email = 'contactUser11@gmail.com',
        user__c = UserInfo.getUserId()
      );
      insert contactUser;
  
      Test.startTest();
      c.getUserContactId();
      Test.stopTest();
  
      System.assertEquals(contactUser.Id, c.currentUserContactId);
    }

    @isTest 
    static void saveCareerReadyCheckTest() {
      WFTApprenticeshipRosterController c = new WFTApprenticeshipRosterController();
      c.analyticalPicklistModal = '1';
      c.analyticalNoteTextModal = 'Analytical test';

      Test.startTest();
      c.saveCareerReadyCheck();
      Test.stopTest();

      Career_Ready_Check__c note = [SELECT Analytical_Notes__c FROM Career_Ready_Check__c LIMIT 1];
      System.AssertEquals('Analytical test', note.Analytical_Notes__c);
    }

    @isTest 
    static void saveNotesTest() {
      WFTApprenticeshipRosterController c = new WFTApprenticeshipRosterController();
      c.notes = 'Test notes';
  
      Test.startTest();
      c.saveNotes();
      Test.stopTest();
  
      Student_Engagement__c notes = [SELECT Engagement_Notes__c FROM Student_Engagement__c LIMIT 1];
      System.assertEquals('Test notes', notes.Engagement_Notes__c);
    }
  
    @isTest 
    static void saveNotesBlankTest() {
      WFTApprenticeshipRosterController c = new WFTApprenticeshipRosterController();
      c.notes = '';
  
      Test.startTest();
      c.saveNotes();
      Test.stopTest();
  
      list<Student_Engagement__c> notes = [SELECT Engagement_Notes__c FROM Student_Engagement__c];
      System.assertEquals(0, notes.size());
    }

    @isTest 
    static void showNotesTest() {
      WFTApprenticeshipRosterController c = new WFTApprenticeshipRosterController();
      
      Test.startTest();
      c.showNotes();
      Test.stopTest();
  
      System.assertEquals(true, c.displayNotes);
    }
  
}