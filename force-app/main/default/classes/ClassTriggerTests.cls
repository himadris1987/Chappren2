@isTest
public class ClassTriggerTests {
	@testSetup
    public static void setup() {
        WFT_Custom_Settings__c customSetting = new WFT_Custom_Settings__c();
        customSetting.Zoom_Meeting_Host__c = 'ccoelho@bitwiseindustries.com';
        customSetting.Zoom_API_JWT__c = 'testKey';
        customSetting.Zoom_API_User__c = 'WFTIntegrations@bitwiseindustries.com';
        customSetting.Enable_Class_Trigger__c = true;
        insert customSetting;
    }
    @isTest
    public static void TestInsertVirtualClass() {
        Class__c classPT = new Class__c(
            Name = 'Test Websites for Beginners',
            Class__c = 'Websites for Beginners',
            Market__c = 'Fresno',
            Attendance_Type__c = 'Virtual',
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
   
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ZoomResponseMock');
        mock.setStatusCode(201);
        mock.setHeader('Content-Type', 'application/json');
        
        Class__c returnedClass;
        
        Test.setMock(HttpCalloutMock.class, mock);
    
        Test.startTest();
        insert classPT;
        Test.stopTest();
      	returnedClass = [SELECT Id, Zoom_Meeting_Id__c FROM Class__c WHERE Id =: classPT.Id];
        System.assertEquals('1100000', returnedClass.Zoom_Meeting_Id__c);
    }
}