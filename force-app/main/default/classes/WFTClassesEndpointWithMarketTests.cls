@isTest
public  class WFTClassesEndpointWithMarketTests {
    @TestSetup
    static void setup() {
        List<Market__c> bwMarkets = new List<Market__c>();

        bwMarkets.add(new Market__c(Name = 'Fresno', Status__c = 'Active', PostalCodes__c = '93706,93721,93725'));
        
        insert bwMarkets;
        
        List<Class__c> classesToInsert = new List<Class__c>();
         classesToInsert.add( new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Fresno',
            Class_Nights__c = 'Monday / Wednesday',
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),  
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        ));

        classesToInsert.add(new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Merced',
            Class_Nights__c = 'Monday / Wednesday',
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        ));

        classesToInsert.add(new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Bakersfield',
            Class_Nights__c = 'Monday / Wednesday',
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        ));

         
        classesToInsert.add(new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Oakland',
            Class_Nights__c = 'Monday / Wednesday',
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        ));

        insert classesToInsert;
    }
    @IsTest
    public static void testEndpoint() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/WFTClasses';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
  
       WFTClassesEndpointWithMarket.ClassResult returnData = new  WFTClassesEndpointWithMarket.ClassResult();
        returnData =  WFTClassesEndpointWithMarket.WFTClassesEndpointWithMarket();
        System.assertEquals(4, returnData.numberOfClasses);
    }
}