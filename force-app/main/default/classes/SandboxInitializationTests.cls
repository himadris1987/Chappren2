@isTest
public class SandboxInitializationTests {
    @isTest
    public static void testPrepSandbox() {      
        Test.startTest();
        Test.testSandboxPostCopyScript(new SandboxInitialization(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();

        List<Account> individualAccounts = [SELECT Id, RecordType.Name FROM Account];

        System.assertEquals(1, individualAccounts.size());
        System.assertEquals('Individuals', individualAccounts[0].RecordType.Name);

        System.assertEquals(2, [SELECT Id FROM Gateway__c].size());
    }   
}