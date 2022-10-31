@isTest
public class BasePaymentControllerTests {
    static BasePaymentController cont;
    static Account individualAccount;

    public static void setup() {
        cont = new BasePaymentController();

        StripePaymentServiceMock mock = new StripePaymentServiceMock();
        StripePaymentService.instance = mock;
        
        GoogleCalendarServiceMock gCalMock = new GoogleCalendarServiceMock();
        GoogleCalendarService.instance = gCalMock;
        
        cont.paymentFirstName = 'Unit';
        cont.paymentLastName = 'Test 1';
        cont.paymentEmail = 'unit@test.com';
        cont.paymentPhone = '1235551234';

        cont.DEPARTMENT = 'Cowork';
        cont.resultRecord = new Payment_Result__c();

        insert TestDataFactory.createGateway('Cowork');

        individualAccount = TestDataFactory.createIndividualAccount();
        insert individualAccount;
    }

    @isTest
    public static void testSetup() {
        setup();
    }

    @isTest
    public static void testGetApiKey() {
        setup();
        
        Test.startTest();
        String result = cont.getApiKey();
        Test.stopTest();

        System.assertEquals('PublishableKey', result);
    }

    @isTest
    public static void testCleanWhitespace() {
        setup();

        cont.paymentFirstName = '  Unit  ';
        cont.paymentLastName = '  Test 1  ';
        cont.paymentEmail = '  unit@test.com  ';
        cont.paymentPhone = '  1235551234  ';
        
        Test.startTest();
        cont.cleanWhitespace();
        Test.stopTest();

        System.assertEquals('Unit', cont.paymentFirstName);
        System.assertEquals('Test 1', cont.paymentLastName);
        System.assertEquals('unit@test.com', cont.paymentEmail);
        System.assertEquals('1235551234', cont.paymentPhone);
    }

    @isTest
    public static void testGetErrorsBlank() {
        setup();

        cont.paymentFirstName = '';
        cont.paymentLastName = '';
        cont.paymentEmail = '';
        cont.paymentPhone = '';
        
        Test.startTest();
        List<String> result = cont.getErrors();
        Test.stopTest();

        System.assertEquals(4, result.size());
        System.assert(result.contains('Please fill out the First Name field.'));
        System.assert(result.contains('Please fill out the Last Name field.'));
        System.assert(result.contains('Please fill out the Email field.'));
        System.assert(result.contains('Please fill out the Phone field.'));
    }

    @isTest
    public static void testGetErrorsInvalid() {
        setup();

        cont.paymentEmail='notarealemail';
        
        Test.startTest();
        List<String> result = cont.getErrors();
        Test.stopTest();

        System.assertEquals(1, result.size());
        System.assertEquals('Email must be a valid email.', result[0]);
    }

    @isTest
    public static void testIsValidFormTrue() {
        setup();
        
        Test.startTest();
        Boolean result = cont.isValidForm();
        Test.stopTest();

        System.assertEquals(true, result);
        System.assertEquals('', cont.error);
    }

    @isTest
    public static void testIsValidFormFalse() {
        setup();

        cont.paymentFirstName = '';
        
        Test.startTest();
        Boolean result = cont.isValidForm();
        Test.stopTest();

        System.assertEquals(false, result);
        System.assertEquals('Please fill out the First Name field.', cont.error);
    }

    @isTest
    public static void testPullAccountAndContactNoContact() {
        setup();
        
        Test.startTest();
        cont.pullAccountAndContact();
        Test.stopTest();

        System.assertEquals(individualAccount.Id, cont.account.Id);
        System.assertEquals(individualAccount.Id, cont.contact.AccountId);
        System.assertEquals(null, cont.contact.Id);
    }

    @isTest
    public static void testPullAccountAndContactIndividualAccount() {
        setup();

        Contact testContact = TestDataFactory.createContact();
        testContact.Email = 'testUser@example.com';
        testContact.AccountId = individualAccount.Id;
        insert testContact;

        cont.paymentEmail = 'testUser@example.com';
        
        Test.startTest();
        cont.pullAccountAndContact();
        Test.stopTest();

        System.assertEquals(individualAccount.Id, cont.account.Id);
        System.assertEquals(individualAccount.Id, cont.contact.AccountId);
        System.assertEquals(testContact.Id, cont.contact.Id);
    }

    @isTest
    public static void testPullAccountAndContactWithAccount() {
        setup();

        Account testAccount = TestDataFactory.createAccount();
        insert testAccount;

        Contact testContact = TestDataFactory.createContact();
        testContact.Email = 'testUser@example.com';
        testContact.AccountId = testAccount.Id;
        insert testContact;

        cont.paymentEmail = 'testUser@example.com';
        
        Test.startTest();
        cont.pullAccountAndContact();
        Test.stopTest();

        System.assertEquals(testAccount.Id, cont.account.Id);
        System.assertEquals(testAccount.Id, cont.contact.AccountId);
        System.assertEquals(testContact.Id, cont.contact.Id);
    }

    @isTest
    public static void testGetCustomerIdHasId() {
        setup();

        Contact testContact = TestDataFactory.createContact();
        testContact.Cowork_Stripe_Customer_Id__c = 'TEST_CUSTOMER_ID';
        testContact.Email = 'testUser@example.com';
        insert testContact;

        cont.paymentEmail = 'testUser@example.com';
        cont.pullAccountAndContact();
        
        Test.startTest();
        String result = cont.getCustomerId('TEST_TOKEN');
        Test.stopTest();

        System.assertEquals('TEST_CUSTOMER_ID',result);
        System.assertEquals(true, cont.customerExists);
    }

    @isTest
    public static void testGetCustomerIdNoId() {
        setup();

        cont.pullAccountAndContact();
        
        Test.startTest();
        String result = cont.getCustomerId('TEST_TOKEN');
        Test.stopTest();

        System.assertEquals('CUSTOMER_ID',result);
        System.assertEquals(false, cont.customerExists);
    }

    @isTest
    public static void testChargeCustomerNoExists() {
        setup();

        cont.pullAccountAndContact();
        cont.getCustomerId('TEST_TOKEN');
        
        Test.startTest();
        String result = cont.chargeCustomer('CUSTOMER_ID', 'TEST_TOKEN', 5, 'This is a test.');
        Test.stopTest();

        System.assertEquals(result, 'CHARGE_ID');
    }

    @isTest
    public static void testChargeCustomerCustomerExists() {
        setup();

        Contact testContact = TestDataFactory.createContact();
        testContact.Cowork_Stripe_Customer_Id__c = 'TEST_CUSTOMER_ID';
        testContact.Email = 'testUser@example.com';
        insert testContact;

        cont.paymentEmail = 'testUser@example.com';

        cont.pullAccountAndContact();
        cont.getCustomerId('TEST_TOKEN');
        
        Test.startTest();
        String result = cont.chargeCustomer('TEST_CUSTOMER_ID', 'TEST_TOKEN', 5, 'This is a test.');
        Test.stopTest();

        System.assertEquals(result, 'CHARGE_ID');
    }

    @isTest
    public static void testCreateSubscriptionNoExists() {
        setup();

        cont.pullAccountAndContact();
        cont.getCustomerId('TEST_TOKEN');
        
        Test.startTest();
        String result = cont.createSubscription('CUSTOMER_ID', 'TEST_TOKEN', 'individual-monthly', 0, 'discount', '');
        Test.stopTest();

        System.assertEquals(result, 'SUBSCRIPTION_ID');
    }

    @isTest
    public static void testCreateSubscriptionCustomerExists() {
        setup();

        Contact testContact = TestDataFactory.createContact();
        testContact.Cowork_Stripe_Customer_Id__c = 'TEST_CUSTOMER_ID';
        testContact.Email = 'testUser@example.com';
        insert testContact;

        cont.paymentEmail = 'testUser@example.com';

        cont.pullAccountAndContact();
        cont.getCustomerId('TEST_TOKEN');
        
        Test.startTest();
        String result = cont.createSubscription('TEST_CUSTOMER_ID', 'TEST_TOKEN', 'individual-monthly', 0, 'discount', '');
        Test.stopTest();

        System.assertEquals(result, 'SUBSCRIPTION_ID');
    }

    @isTest
    public static void testGetAccountZeroExisting() {
        cont = new BasePaymentController();        
        
        Test.startTest();
        Account result = cont.getAccount(new Contact());
        Test.stopTest();

        System.assertEquals(null, result);
    }

    @isTest
    public static void testGetCustomerIdFailing() {
        setup();

        ((StripePaymentServiceMock)StripePaymentService.instance).customerFail = true;

        cont.pullAccountAndContact();
        
        Test.startTest();
        String result = cont.getCustomerId('TEST_TOKEN');
        Test.stopTest();

        System.assertEquals('error:404',result);
    }

    @isTest
    public static void testGetContactCustomerIdNonExistingDepartment() {
        cont = new BasePaymentController();

        
        Test.startTest();
        String result = cont.getContactCustomerId(new Contact());        
        Test.stopTest();

        System.assertEquals(null, result);
    }

    
    @isTest
    public static void testChargeCustomerFailing() {
        setup();

        ((StripePaymentServiceMock)StripePaymentService.instance).chargeFail = true;

        cont.pullAccountAndContact();
        cont.getCustomerId('TEST_TOKEN');
        
        Test.startTest();
        String result = cont.chargeCustomer('CUSTOMER_ID', 'TEST_TOKEN', 5, 'Test charge');
        Test.stopTest();

        System.assertEquals('error:404',result);
    }


    @isTest
    public static void testCreateSubscriptionFailing() {
        setup();

        ((StripePaymentServiceMock)StripePaymentService.instance).subscriptionFail = true;

        cont.pullAccountAndContact();
        cont.getCustomerId('TEST_TOKEN');
        
        Test.startTest();
        String result = cont.createSubscription('CUSTOMER_ID', 'TEST_TOKEN', 'individual-monthly', 0, 'discount', '');
        Test.stopTest();

        System.assertEquals('error:404',result);
    }
}