@isTest
public  class ZoomServiceTests {
    @testSetup
    public static void setup() {
        WFT_Custom_Settings__c customSetting = new WFT_Custom_Settings__c();
        customSetting.Zoom_Meeting_Host__c = 'ccoelho@bitwiseindustries.com';
        customSetting.Zoom_API_JWT__c = 'testKey';
        customSetting.Zoom_API_User__c = 'WFTIntegrations@bitwiseindustries.com';
        customSetting.Enable_Class_Trigger__c = true;
        insert customSetting;
    }
    @IsTest
    public static void createZoomMeetingObjectETTest() {
       Class__c classET = new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Toledo',
            Time_Zone__c = 'Eastern',
            Section_Number__c = 1,
            Class_Nights__c = 'Monday / Wednesday',
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),  
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        );

        String expectedTimeZone = 'America/New_York';
        Test.startTest();
        ZoomService.ZoomMeeting testZoomMeeting = ZoomService.createZoomMeetingObject(classET);
        System.AssertEquals(expectedTimeZone,testZoomMeeting.timezone);
        Test.stopTest();
        
    }
    @isTest
     public static void createZoomMeetingObjectCTTest() {
       Class__c classCT = new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Toledo',
            Time_Zone__c = 'Central',
            Section_Number__c = 1,
            Class_Nights__c = 'Tuesday / Thursday',
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),  
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        );

        String expectedTimeZone = 'America/Chicago';
        Test.startTest();
        ZoomService.ZoomMeeting testZoomMeeting = ZoomService.createZoomMeetingObject(classCT);
        System.AssertEquals(expectedTimeZone,testZoomMeeting.timezone);
        Test.stopTest();
        
    }
    @isTest
     public static void createZoomMeetingObjectMTTest() {
       Class__c classMT = new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Toledo',
            Time_Zone__c = 'Mountain',
            Section_Number__c = 1,
            Class_Nights__c = 'Wednesday',
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),  
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        );

        String expectedTimeZone = 'America/Denver';
        Test.startTest();
        ZoomService.ZoomMeeting testZoomMeeting = ZoomService.createZoomMeetingObject(classMT);
        System.AssertEquals(expectedTimeZone,testZoomMeeting.timezone);
        Test.stopTest();
        
    }
    @isTest
     public static void createZoomMeetingObjectPTTest() {
       Class__c classPT = new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Fresno',
            Time_Zone__c = 'Pacific',
            Section_Number__c = 1,
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),  
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        );

        String expectedTimeZone = 'America/Los_Angeles';
        Test.startTest();
        ZoomService.ZoomMeeting testZoomMeeting = ZoomService.createZoomMeetingObject(classPT);
        System.AssertEquals(expectedTimeZone,testZoomMeeting.timezone);
        Test.stopTest();      
    }
    @isTest
    public static void createMeetingTest() {
        Class__c classPT = new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Fresno',
            Time_Zone__c = 'Pacific',
            Section_Number__c = 1,
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),  
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        );

        List<Class__c> classes = new List<Class__c>();
        List<Class__c> returnedClasses = new List<Class__c>();
        classes.add(classPT);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ZoomResponseMock');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
         
        Test.startTest();
        returnedClasses = ZoomService.createMeeting(classes);
        System.assertEquals('1100000', returnedClasses[0].Zoom_Meeting_Id__c);
        Test.stopTest();
    }

    public static void createMeetingTestFailedResponse() {
        Class__c classPT = new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Fresno',
            Time_Zone__c = 'Pacific',
            Section_Number__c = 1,
            Start_Date__c = Date.today().addDays(30),
            End_Date__c = Date.today().addDays(60),  
            Class_Capacity__c = 35,
            Class_Skill_Level__c = 'Beginner',
            Class_Cost__c = 250,
            Class_Description__c = 'This is a test class.',
            Posted_To_Website__c = Date.today(),
            Removed_From_Website__c = Date.today().addDays(30)
        );

        List<Class__c> classes = new List<Class__c>();
        List<Class__c> returnedClasses = new List<Class__c>();
        classes.add(classPT);
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ZoomResponseMock');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
         
        Test.startTest();
        returnedClasses = ZoomService.createMeeting(classes);
        System.assertEquals(classes[0].Zoom_Meeting_Id__c, returnedClasses[0].Zoom_Meeting_Id__c);
        Test.stopTest();
    }

}