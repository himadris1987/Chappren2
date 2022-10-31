@isTest
public class SandboxInitializationWithDataTest {
    @isTest 
    public static void TestSandboxInitWithData(){
        SandboxInitializationWithData sbiData = new SandboxInitializationWithData();
        
        Test.startTest();
        Test.testSandboxPostCopyScript(sbiData, UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();

        Integer totalContacts = (sbiData.numOfAccounts * sbiData.numOfContactsPerAccount) + sbiData.numOfOpps + sbiData.numOfCasesIT 
                    + sbiData.numOfCasesSFDC + sbiData.numOfClasses + sbiData.numOfClasses 
                    + (sbiData.numOfRegistrationsPerClass * sbiData.numOfClasses);

        Integer numOfAccountsDB = [SELECT Id FROM Account].size();
        //Number of Accounts + Number of Accounts made for Opps + 1 Individual Account + 1 Account for Cases
        System.assertEquals(sbiData.numOfAccounts + sbiData.numOfOpps + 2, numOfAccountsDB);

        Integer numOfContactsDB = [SELECT Id FROM Contact].size();
        System.assertEquals(totalContacts, numOfContactsDB);

        Integer numOfOppsDB = [SELECT Id FROM Opportunity].size();
        System.assertEquals(sbiData.numOfOpps, numOfOppsDB);

        Integer numOfCasesDB = [SELECT Id FROM Case].size();
        System.assertEquals((sbiData.numOfCasesIT + sbiData.numOfCasesSFDC), numOfCasesDB);

        Integer numOfClassesDB = [SELECT Id FROM Class__c].size();
        System.assertEquals(sbiData.numOfClasses, numOfClassesDB);

        Integer numOfRegistrationsDB = [SELECT Id FROM Registration__c].size();
        System.assertEquals((sbiData.numOfRegistrationsPerClass * sbiData.numOfClasses), numOfRegistrationsDB);

    }
}