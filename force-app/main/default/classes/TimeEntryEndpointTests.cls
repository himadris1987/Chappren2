@isTest
public class TimeEntryEndpointTests {
    @TestSetup
    static void setup() {

        Account a1 = new Account(Name = 'Test Account');
        insert a1;

        Contact contact1 = new Contact(AccountId = a1.Id, FirstName = 'Test', LDA_Time_Tracking__c = true, LastName = 'Contact', Email = 'testcontact@salesforce.com');
        insert contact1;

        Contact contact2 = new Contact(AccountId = a1.Id, FirstName = 'Test', LDA_Time_Tracking__c = true, LastName = 'Contact2', Email = 'testcontact2@salesforce.com');
        insert contact2;

        Project__c project1 = new Project__c(Name = 'Project 1', Account__c = a1.Id);
        insert project1;

        Project_Member__c pMember = new Project_Member__c(Project__c = project1.Id, Contact__c = contact2.Id, Status__c = 'Active');
        insert pMember;

        Time_Entry__c time1 = new Time_Entry__c(Contact__c = contact1.Id, Project__c = project1.Id, Hours__c = 1, Date__c = System.today());
        insert time1;

        Time_Entry__c time2 = new Time_Entry__c(Contact__c = contact1.Id, Project__c = project1.Id, Hours__c = .75, Date__c = System.today());
        insert time2;

        Time_Entry__c time3 = new Time_Entry__c(Contact__c = contact2.Id, Project__c = project1.Id, Hours__c = 1.5, Date__c = System.today() - 1);
        insert time3;


        Project__c project2 = new Project__c(Name = 'Project 2', Account__c = a1.Id);
        insert project2;

        Time_Entry__c time4 = new Time_Entry__c(Contact__c = contact2.Id, Project__c = project2.Id, Hours__c = 1, Date__c = System.today());
        insert time4;

        Time_Entry__c time5 = new Time_Entry__c(Contact__c = contact1.Id, Project__c = project2.Id, Hours__c = .75, Date__c = System.today());
        insert time5;

        Project_Member__c pMember2 = new Project_Member__c(Project__c = project2.Id, Contact__c = contact1.Id, Status__c = 'Active');
        insert pMember2;

    }

    @isTest
    public static void testGetTimeEntryRecordsForContact() {

        RestRequest request = new RestRequest();

        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/time';
        request.httpMethod = 'GET';
        request.params.put('contact','testcontact2@salesforce.com');
        RestContext.request = request;

        TimeEntryEndpoint.TimeEntryResult tResult = TimeEntryEndpoint.getTimeEntry();
        System.AssertEquals(2,tResult.Number_Of_Time_Records);
    }
  
    @isTest
    public static void testGetTimeEntryRecordsForContactAndProject() {

        RestRequest request = new RestRequest();

        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/time';
        request.httpMethod = 'GET';
        request.params.put('contact','testcontact2@salesforce.com');

        Project__c project1 = [SELECT Id FROM Project__c WHERE Name = 'Project 1'];

        request.params.put('project', project1.Id);
        RestContext.request = request;

        TimeEntryEndpoint.TimeEntryResult tResult = TimeEntryEndpoint.getTimeEntry();
        System.AssertEquals(1,tResult.Number_Of_Time_Records);
    }
     @isTest
    public static void testGetTimeEntryRecordsForProject() {

        RestRequest request = new RestRequest();

        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/time';
        request.httpMethod = 'GET';

        Project__c project1 = [SELECT Id FROM Project__c WHERE Name = 'Project 1'];

        request.params.put('project', project1.Id);
        RestContext.request = request;
        RestContext.response = new RestResponse();
        TimeEntryEndpoint.TimeEntryResult tResult = TimeEntryEndpoint.getTimeEntry();
        System.AssertEquals('CONTACT_EMAIL_MUST_BE_PROVIDED',tResult.Error_Code);
    }
   

     @isTest
    public static void testPostNewTimeEntryRecordForContact() {
        Contact c = [SELECT Id, Email FROM Contact WHERE LastName = 'Contact2'];
        Project_Member__c pMember = [SELECT Id, Project__c FROM Project_Member__c
                                     WHERE Contact__c =: c.Id LIMIT 1];
        
        RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/time';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String body = '{"contact": "' + c.Email +'",';
        body += '"project": "' + pMember.Project__c + '",';
        body += '"hours": "1.75","date": "2021-03-30","description": "Hello World"}';
        System.debug(body);
        request.requestBody = Blob.valueOf(body);

        RestContext.request = request;

        RestContext.response = new RestResponse();

        TimeEntryEndpoint.TimeEntryResult tResult = TimeEntryEndpoint.postTimeEntry();
        System.debug(tResult);
        System.AssertEquals('Hello World',tResult.Time_Entry_Records[0].description__c);
    }
    @isTest
    public static void testPostTimeEntryRecordMissingRequiredField() {
        Contact c = [SELECT Id, Email FROM Contact WHERE LastName = 'Contact2'];
        Project_Member__c pMember = [SELECT Id, Project__c FROM Project_Member__c
                                     WHERE Contact__c =: c.Id  LIMIT 1];
        
        RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/time';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String body = '{"contact": "' + c.Email +'",';
        body += '"hours": "1.75","date": "2021-03-30","notes": "Hello World"}';
        System.debug(body);
        request.requestBody = Blob.valueOf(body);

        RestContext.response = new RestResponse();
        RestContext.request = request;

        TimeEntryEndpoint.TimeEntryResult tResult = TimeEntryEndpoint.postTimeEntry();
        System.debug(tResult);
        System.AssertEquals('REQUIRED_FIELD_MISSING',tResult.Error_Code);
    }
    @isTest
     public static void testPostTimeEntryRecordMissingHours() {
        Contact c = [SELECT Id, Email FROM Contact WHERE LastName = 'Contact2'];
        Project_Member__c pMember = [SELECT Id, Project__c FROM Project_Member__c
                                     WHERE Contact__c =: c.Id  LIMIT 1];

        RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/time';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String body = '{"contact": "' + c.Email +'",';
        body += '"project": "' + pMember.Project__c + '",';
        body += '"hours": "-1.75","date": "2021-03-30","notes": "Hello World"}';
        System.debug(body);
        request.requestBody = Blob.valueOf(body);

        RestContext.response = new RestResponse();
        RestContext.request = request;

        TimeEntryEndpoint.TimeEntryResult tResult = TimeEntryEndpoint.postTimeEntry();
        System.debug(tResult);
        System.AssertEquals('BAD_PARAMETER',tResult.Error_Code);
    }
    @isTest
    public static void testPostNewTimeNotAProjectMember() {
        Contact c = [SELECT Id, Email FROM Contact WHERE LastName = 'Contact2'];
        Project_Member__c pMember = [SELECT Id, Project__c FROM Project_Member__c
                                     WHERE Contact__c =: c.Id LIMIT 1];
        

        RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/time';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String body = '{"contact": "notonproject@salsforce.com ",';
        body += '"project": "' + pMember.Project__c + '",';
        body += '"hours": "1.75","date": "2021-03-30","notes": "Hello World"}';
        System.debug(body);
        request.requestBody = Blob.valueOf(body);

        RestContext.response = new RestResponse();
        RestContext.request = request;

        TimeEntryEndpoint.TimeEntryResult tResult = TimeEntryEndpoint.postTimeEntry();
        System.debug(tResult);
        System.AssertEquals('PROJECT_MEMBER_NOT_FOUND',tResult.Error_Code);
    }

    @isTest
    public static void testDeleteTimeEntryBadParameter() {
        RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/time';
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response = new RestResponse();

        TimeEntryEndpoint.TimeEntryResult tResult = TimeEntryEndpoint.deleteTimeEntry();
        System.AssertEquals('REQUIRED_FIELD_MISSING',tResult.Error_Code);
    }  

    @isTest
    public static void testDeleteTimeEntry() {
        Time_Entry__c timeEntry = [SELECT Id FROM Time_Entry__c LIMIT 1];

        RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/time';
        request.httpMethod = 'GET';
        request.params.put('Id', timeEntry.Id);
        RestContext.request = request;
        RestContext.response = new RestResponse();
        
        TimeEntryEndpoint.TimeEntryResult tResult = TimeEntryEndpoint.deleteTimeEntry();
        System.AssertEquals('Record deleted.',tResult.Message);
    } 
}