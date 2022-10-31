@isTest 
public class PaymentResultProcessingServiceTests {
    

    @isTest
    public static void testInsertNewPayment() {
        
        Payment_Result__c res = new Payment_Result__c();
        
        Test.startTest();
        Payment_Result__c upserted = PaymentResultProcessingService.upsertPaymentResult(res);
        Test.stopTest();

        System.assertNotEquals(null, upserted);
        System.assertNotEquals(null, upserted.Id);
    }

    @isTest
    public static void testInsertNewPaymentWithChargeId() {
        
        Payment_Result__c res = new Payment_Result__c(Charge_ID__c = 'TEST_CHARGE');
        
        Test.startTest();
        Payment_Result__c upserted = PaymentResultProcessingService.upsertPaymentResult(res);
        Test.stopTest();

        System.assertNotEquals(null, upserted);
        System.assertNotEquals(null, upserted.Id);
    }

    @isTest
    public static void testUpdateResultWithId() {
        
        Payment_Result__c res = new Payment_Result__c();

        insert res;

        res.Charge_ID__c = 'TEST_CHARGE';
        
        Test.startTest();
        Payment_Result__c upserted = PaymentResultProcessingService.upsertPaymentResult(res);
        Test.stopTest();

        System.assertNotEquals(null, upserted);
        System.assertNotEquals(null, upserted.Id);
        System.assertEquals('TEST_CHARGE', upserted.Charge_ID__c);
    }

    @isTest
    public static void testUpdateResultWithChargeId() {
        
        Payment_Result__c res = new Payment_Result__c();
        res.Charge_ID__c = 'TEST_CHARGE';
        insert res;

        Payment_Result__c newRes = new Payment_Result__c(Charge_ID__c = 'TEST_CHARGE', Amount__c = 10);
        
        Test.startTest();
        Payment_Result__c upserted = PaymentResultProcessingService.upsertPaymentResult(newRes);
        Test.stopTest();

        System.assertNotEquals(null, upserted);
        System.assertEquals(res.Id, upserted.Id);
        System.assertEquals('TEST_CHARGE', upserted.Charge_ID__c);
    }    
}