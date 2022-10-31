@isTest 
public class DiscountTriggerTests {
    public static void setup() {
        StripePaymentService.instance = new StripePaymentServiceMock();
    }

    @isTest
    public static void testInsert() {
        setup();
        
        Discount__c discount = new Discount__c(Duration__c = 'Once', Amount_Off__c = 349, Code__c = 'Discount1234');

        Test.startTest();
        insert discount;
        Test.stopTest();

        System.assertNotEquals(null, discount);
    }

    @isTest
    public static void testDelete() {
        setup();
        
        Discount__c discount = new Discount__c(Duration__c = 'Once', Amount_Off__c = 349, Code__c = 'Discount1234');
        insert discount;

        Test.startTest();
        delete discount;
        Test.stopTest();

        System.assertEquals(0, [SELECT Id FROM Discount__c].size());
    }
}