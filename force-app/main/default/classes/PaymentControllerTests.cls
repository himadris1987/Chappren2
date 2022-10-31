@isTest
public class PaymentControllerTests {
    static PaymentController cont;
    static Space__c space;

    public static void setup() {
        
        insert new Cowork_Room_Booking__c (
            Podcast_Booth_Member_Price__c = 10,
            Podcast_Booth_Non_Member_Price__c = 10,
            Conference_Room_Member_Price__c = 10,
            Conference_Room_Non_Member_Price__c = 10
        );

        insert new Cowork_Membership_Types__c(
            Name = 'Individual',
            Label__c = 'Individual',
            Pricing_Plan_Id__c = 'Individual-Monthly',
            Sort_Order__c = 1
        );

        insert new Cowork_Membership_Types__c(
            Name = 'Group',
            Label__c = 'Group',
            Pricing_Plan_Id__c = 'Group-Monthly',
            Sort_Order__c = 0
        );

        insert new Cowork_Membership_Types__c(
            Name='DayPass',
            Label__c = 'Day Pass',
            Sort_Order__c = 2
        );

        space = new Space__c(
            Name = 'Passing Unit Tests',
            Cowork_Reservable__c = true
        );
        insert space;

        cont = new PaymentController();

        StripePaymentServiceMock mock = new StripePaymentServiceMock();
        StripePaymentService.instance = mock;
        
        GoogleCalendarServiceMock gCalMock = new GoogleCalendarServiceMock();
        GoogleCalendarService.instance = gCalMock;
        
        cont.paymentFirstName = 'Unit';
        cont.paymentLastName = 'Test 1';
        cont.paymentEmail = 'unit@test.com';
        cont.paymentPhone = '1235551234';
        cont.memberCompany = 'Unit Tests R Us';
        cont.memberCity = 'Townsville';
        cont.memberState = 'California';
        cont.discountCode = '';
        cont.membershipType = 'Individual';
        cont.codeOfConductValue = true;
        cont.covidPolicyValue = true;
        insert TestDataFactory.createGateway('Cowork');
    }

    @isTest
    public static void testProcessNew() {
        // A completely new user signs up for a membership.
        setup();

        PageReference currentPage = Page.Payment;
        currentPage.getParameters().put('card_token', 'TOKEN');
        Test.setCurrentPage(currentPage);
        
        
        Test.startTest();
        PageReference result = cont.processToken();
        Test.stopTest();

        List<Contact> conts = [SELECT Id, AccountId, Cowork_Stripe_Customer_Id__c FROM Contact];
        System.assertEquals(1, conts.size());
        System.assertEquals('CUSTOMER_ID', conts[0].Cowork_Stripe_Customer_Id__c);
        List<Account> accts = [SELECT Id FROM Account];
        System.assertEquals(1, accts.size());
        System.assertEquals(accts[0].Id, conts[0].AccountId, 'The created Contact does not link to the created account.');
        List<Membership__c> memberships = [SELECT Id, Stripe_Subscription_Id__c FROM Membership__c];
        System.assertEquals(1, memberships.size());
        System.assertEquals('SUBSCRIPTION_ID', memberships[0].Stripe_Subscription_Id__c);
        // List<Payment_Result__c> results = [SELECT Id, Status__c FROM Payment_Result__c];
        // System.assertEquals(1, results.size());
        // System.assertEquals('success', results[0].Status__c);
    }

    @isTest
    public static void testProcessExistingContact() {
        // A user with an existing contact signs up for a membership.
        setup();

        Contact c = new Contact(LastName = 'Test 1', FirstName='Unit', email='unit@test.com', Cowork_Stripe_Customer_Id__c = 'CUSTOMER_ID');
        insert c;

        PageReference currentPage = Page.Payment;
        currentPage.getParameters().put('card_token', 'TOKEN');
        Test.setCurrentPage(currentPage);
        
        
        Test.startTest();
        PageReference result = cont.processToken();
        Test.stopTest();

        List<Contact> conts = [SELECT Id, AccountId, Cowork_Stripe_Customer_Id__c FROM Contact];
        System.assertEquals(1, conts.size());
        System.assertEquals('CUSTOMER_ID', conts[0].Cowork_Stripe_Customer_Id__c);
        List<Account> accts = [SELECT Id FROM Account];
        System.assertEquals(1, accts.size());
        System.assertEquals(accts[0].Id, conts[0].AccountId, 'The created Contact does not link to the created account.');
        List<Membership__c> memberships = [SELECT Id, Stripe_Subscription_Id__c FROM Membership__c];
        System.assertEquals(1, memberships.size());
        System.assertEquals('SUBSCRIPTION_ID', memberships[0].Stripe_Subscription_Id__c);
        // List<Payment_Result__c> results = [SELECT Id, Status__c FROM Payment_Result__c];
        // System.assertEquals(1, results.size());
        // System.assertEquals('success', results[0].Status__c);
    }

    @isTest
    public static void testProcessExistingAccount() {
        // A user with an existing contact signs up for a membership.
        setup();

        Account acct = new Account(Name='Unit Tests R Us', BillingCity = 'Townsville', BillingState = 'California');

        insert acct;

        PageReference currentPage = Page.Payment;
        currentPage.getParameters().put('card_token', 'TOKEN');
        Test.setCurrentPage(currentPage);
        
        
        Test.startTest();
        PageReference result = cont.processToken();
        Test.stopTest();

        List<Contact> conts = [SELECT Id, AccountId, Cowork_Stripe_Customer_Id__c FROM Contact];
        System.assertEquals(1, conts.size());
        System.assertEquals('CUSTOMER_ID', conts[0].Cowork_Stripe_Customer_Id__c);
        List<Account> accts = [SELECT Id FROM Account];
        System.assertEquals(1, accts.size());
        System.assertEquals(accts[0].Id, conts[0].AccountId, 'The created Contact does not link to the created account.');
        List<Membership__c> memberships = [SELECT Id, Stripe_Subscription_Id__c FROM Membership__c];
        System.assertEquals(1, memberships.size());
        System.assertEquals('SUBSCRIPTION_ID', memberships[0].Stripe_Subscription_Id__c);
        // List<Payment_Result__c> results = [SELECT Id, Status__c FROM Payment_Result__c];
        // System.assertEquals(1, results.size());
        // System.assertEquals('success', results[0].Status__c);
    }

    @isTest
    public static void testProcessExistingAccountContact() {
        // A user with an existing contact signs up for a membership.
        setup();

        Account acct = new Account(Name='Unit Tests R Us', BillingCity = 'Townsville', BillingState = 'California');
        
        insert acct;
        Contact c = new Contact(LastName = 'Test 1', FirstName='Unit', email='unit@test.com', AccountId = acct.Id);
        insert c;

        PageReference currentPage = Page.Payment;
        currentPage.getParameters().put('card_token', 'TOKEN');
        Test.setCurrentPage(currentPage);
        
        
        Test.startTest();
        PageReference result = cont.processToken();
        Test.stopTest();

        List<Contact> conts = [SELECT Id, AccountId, Cowork_Stripe_Customer_Id__c FROM Contact];
        System.assertEquals(1, conts.size());
        System.assertEquals('CUSTOMER_ID', conts[0].Cowork_Stripe_Customer_Id__c);
        List<Account> accts = [SELECT Id FROM Account];
        System.assertEquals(1, accts.size());
        System.assertEquals(accts[0].Id, conts[0].AccountId, 'The created Contact does not link to the created account.');
        List<Membership__c> memberships = [SELECT Id, Stripe_Subscription_Id__c FROM Membership__c];
        System.assertEquals(1, memberships.size());
        System.assertEquals('SUBSCRIPTION_ID', memberships[0].Stripe_Subscription_Id__c);
        // List<Payment_Result__c> results = [SELECT Id, Status__c FROM Payment_Result__c];
        // System.assertEquals(1, results.size());
        // System.assertEquals('success', results[0].Status__c);
    }

    @isTest
    public static void testFormIsValid() {

        cont = new PaymentController();
        cont.paymentFirstName = '';
        cont.paymentLastName = '';
        cont.paymentEmail = '';
        cont.paymentPhone = '';
        cont.membershipType = 'Group';
        cont.memberCount = 0;

        Test.startTest();
        Boolean formIsValid = cont.isValidForm();
        Test.stopTest();

        System.assertEquals(false, formIsValid);
        System.assertNotEquals(null, cont.error);
        System.assertNotEquals('', cont.error);
    }

    @isTest
    public static void testProcessPriceChangeGroup() {
        cont = new PaymentController();
        cont.membershipType = 'group';
        cont.memberCount = 5;

        Test.startTest();
        PageReference result = cont.processPriceChange();    
        Test.stopTest();

        System.assertEquals(null, result);
        System.assertNotEquals(null, cont.price);
    }

    @isTest
    public static void testConferenceRoomBooking() {
        setup();
        PageReference currentPage = Page.Payment;
        currentPage.getParameters().put('conferenceRoom','true');
        currentPage.getParameters().put('conferenceDuration','120');
        currentPage.getParameters().put('conferenceStartTime','Mon Sep 16 12:00:00 GMT 2019');
        currentPage.getParameters().put('conferenceLocation', space.Id);
        currentPage.getParameters().put('memberEmail','unit@test.com');
        Test.setCurrentPage(currentPage);

        cont = new PaymentController();
        cont.paymentFirstName = 'test';
        cont.paymentLastName = 'test';
        cont.paymentPhone = 'test';
        cont.memberCompany = 'test';
        cont.memberCity = 'test';
        cont.memberState = 'California';
        cont.discountCode = '';
        cont.codeOfConductValue = true;
        cont.covidPolicyValue = true;

        
        System.assertEquals('unit@test.com', cont.paymentEmail);
        System.assertEquals('DayPass', cont.membershipType);
        System.assertEquals(true, cont.conferenceRoom);
        
        Test.startTest();
        PageReference result = cont.processToken();
        Test.stopTest();

        //Ensure a reservation got made.
        System.assertEquals(1, [SELECT Id FROM Reservation__c].size());

    }

   
}