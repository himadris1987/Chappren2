@isTest 
public class PaymentResultTriggerTests {
    static Contact cont;
    static Membership__c membership;

    static void setup() {
        StripePaymentServiceMock mock = new StripePaymentServiceMock();
        StripePaymentService.instance = mock;
        
        GoogleCalendarServiceMock gCalMock = new GoogleCalendarServiceMock();
        GoogleCalendarService.instance = gCalMock;

        cont = TestDataFactory.createContact();
        cont.Cowork_Stripe_Customer_Id__c = 'CUSTOMER_ID';
        insert cont;

        membership = new Membership__c(
            Contact__c = cont.Id,
            Stripe_Subscription_Id__c = 'SUBSCRIPTION_ID'
        );

        insert membership;
    }

    @isTest
    public static void testInsertLink() {
        setup();

        Payment_Result__c res = new Payment_Result__c(
            Customer_Id__c = 'CUSTOMER_ID',
            Subscription_Id__c = 'SUBSCRIPTION_ID'
        );
        
        Test.startTest();
        insert res;
        Test.stopTest();

        Payment_Result__c res_up = loadResult(res.Id);

        System.assertEquals(res_up.Contact__c, cont.Id);
    }

    @isTest
    public static void testUpdateLink() {
        setup();

        Payment_Result__c res = new Payment_Result__c();
        insert res;

        res.Customer_Id__c = 'CUSTOMER_ID';
        res.Subscription_Id__c = 'SUBSCRIPTION_ID';

        Test.startTest();
        update res;
        Test.stopTest();

        Payment_Result__c res_up = loadResult(res.Id);

        System.assertEquals(res_up.Contact__c, cont.Id);
    }

    static Payment_Result__c loadResult(Id resultId) {
        return [SELECT Id, Contact__c, Membership__c FROM Payment_Result__c WHERE Id = :resultId];
    }
}