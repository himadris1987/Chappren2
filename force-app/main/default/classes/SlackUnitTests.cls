@isTest
public class SlackUnitTests {
 

    static void setup() {
      SlackUsersService s = new SlackUsersServiceMock();
      SlackUsersService.instance = s;

      StripePaymentService st = new StripePaymentServiceMock();
      StripePaymentService.instance = st;
    }
    
    static SlackUsersService serviceSetup(){
      SlackUsersService s = new SlackUsersService();
      SlackUsersService.instance = s;
      return s;
    }
    
    static StaticResourceCalloutMock mockRequests(String resource, Integer statusCode){
    	StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource(resource);
		mock.setStatusCode(statusCode);
		mock.setHeader('Content-Type', 'application/json');
        return mock;
    }


    @isTest
    public static void testEmailInsert() {
        setup();

        Contact c = new Contact(LastName='Ever',
                                FirstName='Greatest',
                                Slack_Email_Address__c = 'test@example.com');
        
        
        Test.startTest();
        insert c;
        Test.stopTest();

        Contact loaded = [SELECT Id, Slack_Image__c FROM Contact WHERE Id = :c.Id];

        System.assertEquals('http://bitwiseindustries.com', loaded.Slack_Image__c);
    }
    
    @isTest
    public static void testSlackIdInsert() {
        setup();
        
         Contact c = new Contact(LastName='Ever',
                                FirstName='Greatest',
                                Slack_Id__c = 'ABCDEF');
        Test.startTest();
        insert c;
        Test.stopTest();
        Contact loaded = [SELECT Id, Slack_Image__c, Slack_Handle__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('http://bitwiseindustries.com', loaded.Slack_Image__c);
        System.assertEquals('AwesomeGuy', loaded.Slack_Handle__c);
    }
	
    @isTest static void testSuccessfulRequestForProfileFromUserId(){
		SlackUsersService s = serviceSetup();
        Test.startTest();
        StaticResourceCalloutMock mock = mockRequests('SlackJSONTest',200);
        Test.setMock(HttpCalloutMock.class, mock);
        s.getProfileFromUserId('UP387NH33');
        Test.stopTest();
        
        
         System.assertEquals('UP387NH33',s.userId,
            'The UserId does not match.');
          
        s.getProfileFromUserId('');
         System.assertEquals(null,s.userId,
            'The UserId does not match.');
                  
    }
     @isTest static void testfailedRequestForProfileFromUserId(){
         SlackUsersService s = serviceSetup();
         Test.startTest();
         StaticResourceCalloutMock mock = mockRequests('SlackJSONTest2',200);
         Test.setMock(HttpCalloutMock.class, mock);
         s.getProfileFromUserId('UP387NH33');
         Test.stopTest();
         System.assertEquals(null,s.userId,
            'The UserId does not match.');
     }
    
    @isTest static void testBadCodeRequestForProfileFromUserId(){
    	SlackUsersService s = serviceSetup();
         Test.startTest();
         StaticResourceCalloutMock mock = mockRequests('SlackJSONTest2',500);
         Test.setMock(HttpCalloutMock.class, mock);
         s.getProfileFromUserId('UP387NH33');
         Test.stopTest();
         System.assertEquals(null,s.userId,
            'The UserId does not match.');
    
    }
    
     @isTest static void testSuccessfulRequestForUserIdAndProfileFromEmail(){
         SlackUsersService s = serviceSetup();
         Test.startTest();
         StaticResourceCalloutMock mock = mockRequests('SlackUserJSONTest',200);
         Test.setMock(HttpCalloutMock.class, mock);
         
         s.getUserIdAndProfileFromEmail('spengler@ghostbusters.example.com');
         
         System.assertEquals('W012A3CDE', s.userId, 'The Ids match.');
         
         s.getUserIdAndProfileFromEmail('');
         
         System.assertEquals(null, s.userId, 'The Ids match.');
     }
    
     @isTest static void testfailedRequestForUserIdAndProfileFromEmail(){
         SlackUsersService s = serviceSetup();
         Test.startTest();
         StaticResourceCalloutMock mock = mockRequests('SlackJSONTest2',200);
         Test.setMock(HttpCalloutMock.class, mock);
         s.getUserIdAndProfileFromEmail('spengler@ghostbusters.example.com');
         Test.stopTest();
         System.assertEquals(null,s.userId,
            'The UserId does not match.');
     }
    
    @isTest static void testBadCodeRequestForUserIdAndProfileFromEmail(){
    	SlackUsersService s = serviceSetup();
         Test.startTest();
         StaticResourceCalloutMock mock = mockRequests('SlackJSONTest2',500);
         Test.setMock(HttpCalloutMock.class, mock);
         s.getUserIdAndProfileFromEmail('spengler@ghostbusters.example.com');
         Test.stopTest();
         System.assertEquals(null,s.userId,
            'The UserId does not match.');
    
    }
    @istest static void testContactisUpdatedStartingWithUserId(){
        SlackUsersService s = serviceSetup();
        Test.startTest();
        StaticResourceCalloutMock mock = mockRequests('SlackJSONTest',200);
        Test.setMock(HttpCalloutMock.class, mock);
        s.getProfileFromUserId('UP387NH33');
        Test.stopTest();
        
        Contact before = new Contact(firstName = 'Christian',
                           lastName = 'Coelho', 
                           Email='coelho.christian@gmail.com', 
                           Slack_Id__c  = 'UP387NH33',
                           Slack_Email_Address__c = '',
                           Slack_Image__c = '',
                           Slack_Handle__c= '');
        upsert before;
        
         System.assertEquals('UP387NH33',s.userId,
            'The UserId does not match.');
         Contact after = s.updateContactSlackFieldsFromProfileAndUserId();
         
        System.assertNotEquals(before.Slack_Email_Address__c,after.Slack_Email_Address__c);
        System.assertNotEquals(before.Slack_Handle__c,after.Slack_Handle__c);
        System.assertNotEquals(before.Slack_Image__c,after.Slack_Image__c);
        
        
    }
    
    @istest static void testContactisUpdatedStartingWithoutUserId(){
         SlackUsersService s = serviceSetup();
        Test.startTest();
        StaticResourceCalloutMock mock = mockRequests('SlackJSONTest',200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest();
        System.assertEquals(null,s.userId);
        System.assertEquals(null,s.updateContactSlackFieldsFromProfileAndUserId());
    }
    
      @istest static void testContactisUpdatedUserIdBadQuery(){
         SlackUsersService s = serviceSetup();
        Test.startTest();
        StaticResourceCalloutMock mock = mockRequests('SlackJSONTest',200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.stopTest();
        s.userId = 'W';
        System.assertEquals(null,s.updateContactSlackFieldsFromProfileAndUserId());
    }
    
    @isTest static void testaddContactSlackFieldsFromProfileUsingEmail(){
         SlackUsersService s = serviceSetup();
         Test.startTest();
         StaticResourceCalloutMock mock = mockRequests('SlackUserJSONTest',200);
         Test.setMock(HttpCalloutMock.class, mock);
         s.getUserIdAndProfileFromEmail('spengler@ghostbusters.example.com');
         Test.stopTest();
        
         Contact before = new Contact(firstName = 'Spengler',
                           lastName = 'Ghosts', 
                           Email='tester@gmail.com', 
                           Slack_Id__c  = '',
                           Slack_Email_Address__c = 'spengler@ghostbusters.example.com',
                           Slack_Image__c = '',
                           Slack_Handle__c= '');
        
        upsert before;
        	
        
         Contact after = s.addContactSlackFieldsFromProfileUsingEmail();
        
        System.assertNotEquals(before.Slack_Id__c,after.Slack_Id__c);
        System.assertNotEquals(before.Slack_Handle__c,after.Slack_Handle__c);
        System.assertNotEquals(before.Slack_Image__c,after.Slack_Image__c);
        
        
    }
    
     @isTest static void testaddContactSlackFieldsFromProfileUsingEmailWithoutProfileOrUserId(){
         SlackUsersService s = serviceSetup();
         System.assertEquals(null,s.addContactSlackFieldsFromProfileUsingEmail());
         
     }
    
    @isTest static void testaddContactSlackFieldsFromProfileUsingEmailBadQuery(){
         SlackUsersService s = serviceSetup();
         s.slackProfile.email = 'bad@bad.com';
         s.userId = '5';
         System.assertEquals(null,s.addContactSlackFieldsFromProfileUsingEmail());
         
     }
    @isTest static void testaddContactSlackFieldsFromProfileUsingEmailContactHasSlackId(){
       SlackUsersService s = serviceSetup();
         Test.startTest();
         StaticResourceCalloutMock mock = mockRequests('SlackUserJSONTest',200);
         Test.setMock(HttpCalloutMock.class, mock);
         Test.stopTest();
         s.userId = 'AAA';
        	
        
        System.assertEquals(null,s.addContactSlackFieldsFromProfileUsingEmail());
    }
    	 
   
}