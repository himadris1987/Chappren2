public class BWUATConfirmationController {
    //Getting and setting the fields to be Queried
	public String caseId {get; set;}
	public String caseSubmitterName {get; set;}
	public String caseNumber {get; set;}
	public String caseSubject {get; set;}
	public String caseDescription {get; set;}
	public String caseSummary {get; set;}
	public String reasonForRejection {get; set;}
	public Boolean isCaseStatusUAT {get; set;}
	public Boolean isCaseStatusClosed {get; set;}
	
	@TestVisible private Case singleCase; 

	public BWUATConfirmationController() {
		isCaseStatusUAT = false;
		isCaseStatusClosed = false;
		caseSubmitterName = '';
		caseNumber = '';
		caseId = apexpages.currentPage().getparameters().get('Id');
		GetCase();
	}

	public void GetCase() {
		List<Case> cases = new List<Case>(); 
		cases = [SELECT Id, CreatedBy.Name, Status, CaseNumber,First_Response_Email_Sent__c, 
				 First_Response_Sent_Date__c, Subject, Description, Comments, SuppliedName, 
				 Summary_Of_What_Was_Done__c, Pending__c  
				 FROM Case WHERE Id =: caseId ];
		
		if (cases.size() == 1 ) {
			singleCase = cases[0];
			isCaseStatusUAT = singleCase.Status == 'UAT';
			isCaseStatusClosed = singleCase.Status == 'Closed';
			
			caseSubmitterName = String.isBlank(singleCase.SuppliedName) ? singleCase.CreatedBy.Name : singleCase.SuppliedName;
			caseNumber = singleCase.CaseNumber;
			caseSubject = singleCase.Subject;
			caseDescription = String.isBlank(singleCase.Description) ? 'No Description Found' : singleCase.Description;
			caseSummary = String.isBlank(singleCase.Summary_Of_What_Was_Done__c) ? 'No Actions Found' : singleCase.Summary_Of_What_Was_Done__c;
		}
	}

	public void caseSolved() {
		singleCase.Status = 'Closed';
		System.debug(singleCase.Status);
		update singleCase;
	}

	public void caseRejectedUAT() {
		singleCase.Status = 'Pending';
		singleCase.Comments = 'UAT REJECTION: \n' + reasonForRejection;
		singleCase.Pending__c = 'UAT Rejection';
		singleCase.First_Response_Email_Sent__c = false;
		singleCase.First_Response_Sent_Date__c = null;
		update singleCase;
	}
}