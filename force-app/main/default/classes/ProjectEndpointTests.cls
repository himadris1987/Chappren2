@isTest
public class ProjectEndpointTests {
     @TestSetup
    static void setup() {

        Account a1 = new Account(Name = 'Test Account');
        insert a1;

        Contact contact1 = new Contact(AccountId = a1.Id, LDA_Time_Tracking__c = true, FirstName = 'Test', LastName = 'Contact', Email = 'testcontact@salesforce.com');
        insert contact1;

        Contact contact2 = new Contact(AccountId = a1.Id, LDA_Time_Tracking__c = true, FirstName = 'Test', LastName = 'Contact2', Email = 'testcontact2@salesforce.com');
        insert contact2;

        Project__c project1 = new Project__c(Name = 'Project 1', Status__c = 'Active', Account__c = a1.Id, RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('LDA').getRecordTypeId(), Type__c = 'State');
        insert project1;

        Project_Member__c pMember = new Project_Member__c(Project__c = project1.Id, Contact__c = contact1.Id, Status__c = 'Active');
        insert pMember;

        Time_Entry__c time1 = new Time_Entry__c(Contact__c = contact1.Id, Project__c = project1.Id, Hours__c = 1, Date__c = System.today());
        insert time1;

        Time_Entry__c time2 = new Time_Entry__c(Contact__c = contact1.Id, Project__c = project1.Id, Hours__c = .75, Date__c = System.today());
        insert time2;

        Time_Entry__c time3 = new Time_Entry__c(Contact__c = contact2.Id, Project__c = project1.Id, Hours__c = 1.5, Date__c = System.today() - 1);
        insert time3;


        Project__c project2 = new Project__c(Name = 'Project 2', Status__c = 'Active', Account__c = a1.Id);
        insert project2;

        Time_Entry__c time4 = new Time_Entry__c(Contact__c = contact2.Id, Project__c = project2.Id, Hours__c = 1, Date__c = System.today());
        insert time4;

        Time_Entry__c time5 = new Time_Entry__c(Contact__c = contact1.Id, Project__c = project2.Id, Hours__c = .75, Date__c = System.today());
        insert time5;

        Project_Member__c pMember2 = new Project_Member__c(Project__c = project2.Id, Contact__c = contact2.Id, Status__c = 'Active');
        insert pMember2;

    }
    @isTest
    public static void testGetProjectsBadParameters() {
        
       	RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/projects';
        request.httpMethod = 'GET';

        RestContext.request = request;
        RestContext.response =  new RestResponse();
        ProjectEndpoint.ProjectResult pResult = ProjectEndpoint.getProjectResults();
        System.AssertEquals('CONTACT_EMAIL_MUST_BE_PROVIDED',pResult.Error_Code);
    }
    @isTest
    public static void testGetProjectsFromContact() {
        Contact c = [SELECT Id, Email FROM Contact WHERE LastName = 'Contact'];
       	RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/projects';
        request.httpMethod = 'GET';
        request.params.put('contact', c.Email);
        RestContext.request = request;
        RestContext.response =  new RestResponse();
        ProjectEndpoint.ProjectResult pResult = ProjectEndpoint.getProjectResults();
        System.AssertEquals(1,pResult.Number_Of_Projects);
    }
    @isTest
    public static void testGetProjectsFromContactAndProjectId() {
        Contact c = [SELECT Id, Email FROM Contact WHERE LastName = 'Contact'];
        Project_Member__c pMember = [SELECT Id, Project__c FROM Project_Member__c
                                     WHERE Contact__c =: c.Id LIMIT 1];
       	RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/projects';
        request.httpMethod = 'GET';
        request.params.put('contact', c.Email);
        request.params.put('project', pMember.Project__c);
        RestContext.request = request;
        RestContext.response =  new RestResponse();
        ProjectEndpoint.ProjectResult pResult = ProjectEndpoint.getProjectResults();
        System.AssertEquals(1,pResult.Number_Of_Projects);
    }
    @isTest
    public static void testGetProjectsFromContactNonProjectMember() {
        
       	RestRequest request = new RestRequest();
        request.requestUri = 'https://yourInstance.salesforce.com/services/apexrest/projects';
        request.httpMethod = 'GET';
        request.params.put('contact', 'notapm@notapm.com');
        RestContext.request = request;
        RestContext.response =  new RestResponse();
        ProjectEndpoint.ProjectResult pResult = ProjectEndpoint.getProjectResults();
        System.AssertEquals('PROJECT_MEMBER_NOT_FOUND',pResult.Error_Code);
    }
   
}