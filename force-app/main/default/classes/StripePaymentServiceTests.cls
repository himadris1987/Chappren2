@isTest
public class StripePaymentServiceTests {
    static Contact cont;
    static Membership__c membership;
    static StripePaymentService service;

    public static void setup() {
        service = new StripePaymentService();
        StripePaymentService.instance = service;
        cont = TestDataFactory.createContact();
        insert cont;
        membership = new Membership__c(Contact__c = cont.Id);
        insert membership;
        insert TestDataFactory.createGateway('Cowork');
    }

    @isTest
    public static void testSetup() {
        setup();
    }

    @isTest
    public static void testCreateCustomer() {
        setup();

        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('customer', 200));
        
        Test.startTest();
        String result = service.createCustomer('Cowork', 'TEST_TOKEN','test@test.com','Unit Test 1', '1235551234', cont.Id);
        Test.stopTest();

        System.assertEquals('CUSTOMER_ID', result);
    }

    @isTest
    public static void testCreateCustomerFailed() {
        setup();

        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('customer', 404));
        
        Test.startTest();
        String result = service.createCustomer('Cowork', 'TEST_TOKEN','test@test.com','Unit Test 1', '1235551234', cont.Id);
        Test.stopTest();

        System.assert(service.errors.contains('CreateCustomer failed: 404'));
        System.assertEquals('error:404|An Unknown Error has occured.', result);
    }

    @isTest
    public static void testCreateSubscription() {
        setup();

        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('subscription', 200));
        
        Test.startTest();
        String result = service.createSubscription('Cowork', 'CUSTOMER_ID','plan-id', membership.Id, '');
        Test.stopTest();

        System.assertEquals('SUBSCRIPTION_ID', result);
    }

    @isTest
    public static void testCreateSubscriptionFailed() {
        setup();

        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('subscription', 404));
        
        Test.startTest();
        String result = service.createSubscription('Cowork', 'CUSTOMER_ID','plan-id', membership.Id, '');
        Test.stopTest();

        System.assert(service.errors.contains('CreateSubscription failed: 404'));
        System.assertEquals('error:404|An Unknown Error has occured.', result);
    }

  
    @isTest
    public static void testChargeCustomer() {
        setup();

        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('charge', 200));
        
        Test.startTest();
        String chargeId = service.chargeCustomer('Cowork', 'CUSTOMER_ID',null,5.0,'Test Description');
        Test.stopTest();

        System.assertEquals('CHARGE_ID', chargeId);
    }

    @isTest
    public static void testChargeCustomerFailed() {
        setup();

        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('charge', 404));
        
        Test.startTest();
        String chargeId = service.chargeCustomer('Cowork', 'CUSTOMER_ID',null,5.0,'Test Description');
        Test.stopTest();

        System.assert(service.errors.contains('ChargeCustomer failed: 404'));
        System.assertEquals('error:404|An Unknown Error has occured.', chargeId);
    }

    @isTest
    public static void testCreateSource() {
        setup();
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('source', 200));

        Test.startTest();
        String sourceId = service.createSource('Cowork', 'TEST_TOKEN');
        Test.stopTest();

        System.assertEquals('SOURCE_ID', sourceId);
    }

    @isTest
    public static void testCreateSourceFailed() {
        setup();
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('source', 404));

        Test.startTest();
        String sourceId = service.createSource('Cowork', 'TEST_TOKEN');
        Test.stopTest();

        System.assert(service.errors.contains('CreateSource failed: 404'));
        System.assertEquals('error:404|An Unknown Error has occured.', sourceId);
    }

    @isTest
    public static void testAttachSource() {
        setup();
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('source', 200));
        
        Test.startTest();
        service.attachSource('Cowork', 'CUSTOMER_ID', 'TEST_TOKEN');
        Test.stopTest();

        System.assertEquals(0, service.errors.size());
    }

    @isTest
    public static void testAttachSourceFailed() {
        setup();
        
        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('source', 404));
        
        Test.startTest();
        service.attachSource('Cowork', 'CUSTOMER_ID', 'TEST_TOKEN');
        Test.stopTest();

        System.assertEquals(1, service.errors.size());
        System.assert(service.errors.contains('AttachSource failed: 404'));
    }


    @isTest
    public static void testCreateDiscount() {
        setup();

        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('discount', 200));

        Discount__c discount = new Discount__c(
            Code__c = 'DISCOUNT_ID',
            Amount_Off__c = 10.00,
            Name = 'Test Discount',
            Duration_In_Months__c = 6,
            Duration__c = 'Repeating',
            Redeem_By__c = System.now(),
            Max_Redemptions__c = 10
        );
        
        Test.startTest();
        insert discount;
        Test.stopTest();

        Discount__c uploaded = [SELECT Id, Valid__c FROM Discount__c WHERE Id = :discount.Id];
        
        System.assert(uploaded.Valid__c);
    }

    @isTest
    public static void testCreateDiscountFailed() {
        setup();

        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('discount', 404));

        Discount__c discount = new Discount__c(
            Code__c = 'DISCOUNT_ID',
            Amount_Off__c = 10.00,
            Name = 'Test Discount',
            Duration_In_Months__c = 6,
            Duration__c = 'Repeating',
            Redeem_By__c = System.now(),
            Max_Redemptions__c = 10
        );
        
        Test.startTest();
        insert discount;
        Test.stopTest();

        Discount__c uploaded = [SELECT Id, Valid__c FROM Discount__c WHERE Id = :discount.Id];
        
        System.assert(!uploaded.Valid__c);
        System.assert(service.errors.contains('CreateDiscount failed: 404'));
    }

    @isTest
    public static void testDeleteDiscount() {
        setup();

        Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('discount', 200));

        Discount__c discount = new Discount__c(
            Code__c = 'DISCOUNT_ID',
            Amount_Off__c = 10.00,
            Name = 'Test Discount',
            Duration_In_Months__c = 6,
            Duration__c = 'Repeating',
            Redeem_By__c = System.now(),
            Max_Redemptions__c = 10
        );

        insert discount;
        
        Test.startTest();
        delete discount;
        Test.stopTest();
        
        System.assertEquals(0, service.errors.size());
    }

    // @isTest
    // public static void testUpdateDiscount() {
    //     setup();

    //     Test.setMock(HttpCalloutMock.class, new StripePaymentServiceCalloutMock('discount', 200));

    //     Discount__c discount = new Discount__c(
    //         Code__c = 'DISCOUNT_ID',
    //         Amount_Off__c = 10.00,
    //         Name = 'Test Discount',
    //         Duration_In_Months__c = 6,
    //         Duration__c = 'Repeating',
    //         Redeem_By__c = System.now(),
    //         Max_Redemptions__c = 10
    //     );

    //     insert discount;

    //     discount.Name = 'Test Discount (Updated)';
        
    //     Test.startTest();
    //     update discount;
    //     Test.stopTest();

    //     Discount__c uploaded = [SELECT Id, Valid__c FROM Discount__c WHERE Id = :discount.Id];
        
    //     System.assert(uploaded.Valid__c);
    // }
}