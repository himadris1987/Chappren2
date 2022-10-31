@isTest
public class ContactTriggerTests {
    static Contact cont;
    
    public static void setup() {
        SlackUsersService.instance = new SlackUsersServiceMock();
    }

    @isTest
    public static void testSlackAfterUpdate() {
        setup();

        cont = TestDataFactory.createContact();
        
        
        cont.Slack_Email_Address__c = '';
        insert cont;

        cont.Slack_Email_Address__c = 'email@slack.com';
        
        Test.startTest();
        update cont;
        Test.stopTest();
    }

    @isTest
    public static void testStripeAfterInsert() {
        setup();
		
        cont = TestDataFactory.createContact();
        
		
        cont.Slack_Email_Address__c = 'email@slack.com';
        
        
        Test.startTest();
        insert cont;
        Test.stopTest();
    }
}