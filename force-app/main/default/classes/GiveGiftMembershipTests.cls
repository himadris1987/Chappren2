@isTest
public class GiveGiftMembershipTests {
    static GiveGiftMembershipController cont;
    
    public static void setup() {
        StripePaymentService.instance = new StripePaymentServiceMock();

        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'Individuals' and SObjectType='Account' LIMIT 1].Id;

        insert new Account(Name='Individual', RecordTypeId = recordTypeId);

        insert TestDataFactory.createGateway('Cowork');
    }

    @isTest
    public static void testSetup() {
        setup();
    }

    @isTest
    public static void testConstructor() {
        setup();

        
        Test.startTest();
        cont = new GiveGiftMembershipController();
        Test.stopTest();

        System.assertNotEquals(null, cont.price);
        System.assertNotEquals(null, cont.amountToCharge);
    }

    @isTest
    public static void testProcessToken() {
        setup();

        cont = new GiveGiftMembershipController();
        
        cont.paymentFirstName = 'Test';
        cont.paymentLastName = 'Giver';
        cont.paymentEmail = 'testGiver@example.com';
        cont.paymentPhone = '1234567890';
        cont.memberFirstName = 'Test';
        cont.memberLastName = 'Member';

        PageReference pr = Page.GiveGiftMembership;
        pr.getParameters().put('card_token', 'CARD_TOKEN');
        Test.setCurrentPage(pr);
        
        Test.startTest();
        cont.processToken();
        Test.stopTest();

        List<Payment_Result__c> paymentResults = [SELECT Id, Source__c, Status__c FROM Payment_Result__c];

        System.assertEquals(1, paymentResults.size());
        System.assertEquals('success', paymentResults.get(0).Status__c);
    }

    @isTest
    public static void testInvalidForm() {
        setup();

        cont = new GiveGiftMembershipController();

        cont.paymentFirstName = '';
        cont.paymentLastName = '';
        cont.paymentEmail = '';
        cont.paymentPhone = '';
        cont.memberFirstName = '';
        cont.memberLastName = '';
        
        Test.startTest();
        PageReference result = cont.processToken();
        Test.stopTest();

        System.assertEquals(null,result);
        System.assert(cont.error.contains('First Name must be filled in.'));
        System.assert(cont.error.contains('Last Name must be filled in.'));
        System.assert(cont.error.contains('Email must be filled in.'));
        System.assert(cont.error.contains('Phone must be filled in.'));
    }

    @isTest
    public static void testUpdateDiscountCodeCorrect() {
        setup();

        cont = new GiveGiftMembershipController();

        cont.discountCode = 'FREEMONTH';        
        
        Test.startTest();
        cont.updateDiscountCode();
        Test.stopTest();

        System.assertEquals(360, cont.amountToCharge);
    }

    @isTest
    public static void testUpdateDiscountCodeIncorrect() {
        setup();

        cont = new GiveGiftMembershipController();

        cont.discountCode = 'wrong';        
        
        Test.startTest();
        cont.updateDiscountCode();
        Test.stopTest();

        System.assertEquals(399, cont.amountToCharge);
        System.assertNotEquals('', cont.error);
    }
}