@isTest
public class CredentialServiceTests {
    static Gateway__c gateway;
    
    public static void setup() {
        gateway= new Gateway__c(
            Publishable_Key__c = 'Public',
            Secret_Key__c = 'Secret',
            Department__c = 'Cowork',
            Active__c = true
        );
        insert gateway;
    }

    @isTest
    public static void testGetStripeSettings() {
        setup();
        
        Test.startTest();
        Gateway__c settings = CredentialService.getStripeGateway('Cowork');
        Test.stopTest();

        System.assertNotEquals(null, settings);
        System.assertEquals(gateway.Id, settings.Id);
    }

    @isTest
    public static void testGetPublicStripeKey() {
        setup();
        
        Test.startTest();
        String key = CredentialService.getPublicStripeKey('Cowork');
        Test.stopTest();

        System.assertEquals('Public', key);
    }

    @isTest
    public static void testGetPrivateStripeKey() {
        setup();
        
        Test.startTest();
        String key = CredentialService.getPrivateStripeKey('Cowork');
        Test.stopTest();

        System.assertEquals('Secret', key);
    }
}