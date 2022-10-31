@isTest
public class BWUATConfirmationTest {
    @TestSetup
    static void setup(){
		Account a = new Account(Name = 'Test Account');
		insert a;
		Contact c = new Contact(FirstName = 'Test', LastName = 'User', AccountId = a.Id, Email = 'testuser@test.com');
		insert c;

        Case testCase = new Case(Subject = 'Test Case', Status='UAT', 
								 ContactId = c.Id,
        						 First_Response_Sent_Date__c = System.today(),
								 First_Response_Email_Sent__c = true, 
								 Summary_Of_What_Was_Done__c = 'Things were done to solve this case.',
								 SuppliedName = 'Case Submitter Name' );
		insert testCase;
    }

	@isTest
	static void testGetCase(){
		BWUATConfirmationController c = new BWUATConfirmationController();
		Case testSingleCase = [SELECT Id, Subject FROM Case WHERE Subject = 'Test Case'];
		c.caseId = testSingleCase.Id;
		c.GetCase();
		System.assertEquals(testSingleCase.Subject, c.singleCase.Subject);
	}
	@isTest
	static void testCaseSolved(){
		BWUATConfirmationController c = new BWUATConfirmationController();
		Case testSingleCase = [SELECT Id, Subject FROM Case WHERE Subject = 'Test Case'];
		c.caseId = testSingleCase.Id;
		c.GetCase();
		c.caseSolved();
		System.assertEquals('Closed', c.singleCase.Status);
	}

	@isTest
	static void testCaseRejectedUAT() {
		BWUATConfirmationController c = new BWUATConfirmationController();
		Case testSingleCase = [SELECT Id, Subject FROM Case WHERE Subject = 'Test Case'];
		c.caseId = testSingleCase.Id;
		c.GetCase();
		c.caseRejectedUAT();
		System.assertEquals('Pending', c.singleCase.Status);
	}

}