@isTest
private class BLDGCheckinControllerTest {
   
    @TestSetup
    static void setupTestData() {
        Space__c space1 = new Space__c(Name = 'Bitwise South Stadium');
        insert space1;

        Space__c space2 = new Space__c(Name = 'Bitwise Hive');
        insert space2;

        Space__c space3 = new Space__c(Name = 'Bitwise | 41');
        insert space3;

        Account acct1 = new Account(Name = 'Bitwise');
        insert acct1;

        Contact contact1 = new Contact( FirstName = 'Bitwise Employee',
                                        LastName = '1',
                                        Pronouns__c = 'He/Him',
                                        Check_In_Locations__c = 'Bitwise Hive;Bitwise | 41');
        insert contact1;

        Contact contact2 = new Contact( FirstName = 'Bitwise Employee',
        LastName = '2',
        Pronouns__c = 'He/Him',
        Check_In_Locations__c = 'Bitwise South Stadium;Bitwise Hive;Bitwise | 41');
        insert contact2;




    }

    @isTest static void testControllerLoadNoParam() {
        BLDGCheckinController controller = new BLDGCheckinController();

        Space__c location = [SELECT Id, Name FROM Space__c WHERE Name = 'Bitwise South Stadium' Limit 1];

        System.assertEquals(location.Id, controller.locationAsSpace.Id);
    }

    @isTest static void testControllerWithParams() {
   

        Test.setCurrentPageReference(new PageReference('apex/bwCheckin.page')); 
        System.currentPageReference().getParameters().put('location', 'BWSS');

        BLDGCheckinController controller = new BLDGCheckinController();

        Space__c location = [SELECT Id, Name FROM Space__c WHERE Name = 'Bitwise South Stadium' Limit 1];

        System.assertEquals(location.Id, controller.locationAsSpace.Id);

        
        System.currentPageReference().getParameters().put('location', 'BWH');

        controller = new BLDGCheckinController();

        location = [SELECT Id, Name FROM Space__c WHERE Name = 'Bitwise Hive' Limit 1];

        System.assertEquals(location.Id, controller.locationAsSpace.Id);

       
        System.currentPageReference().getParameters().put('location', 'BW41');

        controller = new BLDGCheckinController();

        location = [SELECT Id, Name FROM Space__c WHERE Name = 'Bitwise | 41' Limit 1];

        System.assertEquals(location.Id, controller.locationAsSpace.Id);
    }

    @isTest static void testGetContactsForCheckIns() {
        
        BLDGCheckinController controller = new BLDGCheckinController();
        controller.location = 'BWSS';
        controller.getContactsForCheckIns();
        System.assertEquals(1, controller.MeetWithNames.size());

        controller = new BLDGCheckinController();
        controller.location = 'BW41';
        controller.getContactsForCheckIns();
        System.assertEquals(2, controller.MeetWithNames.size());

        controller = new BLDGCheckinController();
        controller.location = 'BWH';
        controller.getContactsForCheckIns();
        System.assertEquals(2, controller.MeetWithNames.size());

    }

    @isTest static void testCreateDeliveryCheckIn() {
        BLDGCheckinController controller = new BLDGCheckinController();
        controller.createDeliveryCheckIn();
        System.assertEquals(1, controller.MeetWithNames.size());
    }

    @isTest static void testCreateCheckIn() {
        BLDGCheckinController controller = new BLDGCheckinController();
        controller.contactFirstName = 'Vistor 1';
        controller.contactLastName = 'Vistor 1 Last Name';
        controller.contactPhoneNumber = '2092092099';
        controller.contactPronoun = 'He/Him';
        controller.contactEmail = 'vistor1@test.com';
        controller.meetWithName = 'Bitwise Employee 1';
        controller.meetingContact = [SELECT Id FROM Contact WHERE FirstName = 'Bitwise Employee' AND LastName = '1' Limit 1];
        controller.locationAsSpace = [SELECT Id, Name FROM Space__c WHERE Name = 'Bitwise | 41' Limit 1];
        controller.createCheckIn();
        List<Check_In__c> checkIn = [SELECT Id FROM Check_In__c];
        System.assertEquals(1, checkIn.size());
    }

    @isTest static void testGetPronounList() {
        BLDGCheckinController controller = new BLDGCheckinController();
        System.assertEquals(5,controller.getPronounList().size());
    }

    @isTest static void testNavigateToMeetingWith() {
        BLDGCheckinController controller = new BLDGCheckinController();
        System.assertEquals('/apex/bwMeetingWith',controller.navigateToMeetingWith().getUrl());
    }

    @isTest static void testBackToHome() {
        BLDGCheckinController controller = new BLDGCheckinController();
        System.assertEquals('/apex/bwCheckin?location='+controller.location,controller.backToHome().getUrl());
    }
}