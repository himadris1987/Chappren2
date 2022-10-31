public class VenturesIdeaSubmissionController {

    list<Contact> contactList{get; set;}
    public list<Account> defaultAccountId{get; set;}
    public contact submitter{get; set;}
    public string submitterFirstName{get; set;}
    public string submitterLastName{get; set;}
    public string submitterEmail{get; set;}
    public string submitterPhone{get; set;}

    public string ideaName{get; set;}
    public string ideaSummary{get; set;}
    public string ideaTargetMarket{get; set;}
    public string ideaCompetitiveLandscape{get; set;}
    public string ideaPainPoints{get; set;}
    public string ideaValueProposition{get; set;}
    public string ideaExistingOptions{get; set;}
    public string ideaKeyFeatures{get; set;}
    public string ideaKeyBenefits{get; set;}
    public string ideaProductTraction{get; set;}
    public string ideaTeam{get; set;}


    public PageReference submitIdea() {
       	//List<contact> contactList = new List<contact>();
        contactList = [SELECT Id, AccountId FROM Contact WHERE email = :submitterEmail];

        if(contactList.size()>0) {
            submitter = contactList[0];
        } else {
            submitter = createNewContact();
        }
        insertIdea();
        PageReference pageRef = new PageReference('/apex/VenturesIdeaConfirmation');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void insertIdea() {
        Idea__c idea = new Idea__c (
            Submitter__c = submitter.Id,
            Account__c = submitter.AccountId,
            Name = ideaName,
            Summary__c = ideaSummary,
            Target_Market__c = ideaTargetMarket,
            Competitive_Landscape__c = ideaCompetitiveLandscape,
            Pain_Points__c = ideaPainPoints,
            Value_Proposition__c = ideaValueProposition,
            Existing_Options__c = ideaExistingOptions,
            Key_Features__c = ideaKeyFeatures,
            Key_Benefits__c = ideaKeyBenefits,
            Product_Traction__c = ideaProductTraction,
            Team__c = ideaTeam
        );
        insert idea;
        system.debug('Idea Submitted');
    }

    public Contact createNewContact() {
        
        Id IndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individuals').getRecordTypeId();
		defaultAccountId = [SELECT Id FROM Account WHERE RecordType.Id = :IndividualRecordTypeId]; 
        Contact newContact = new Contact (
            AccountId = defaultAccountId[0].Id,
            firstName = submitterFirstName,
            lastName = submitterLastName,
            email = submitterEmail,
            MobilePhone = submitterPhone
        );
        insert newContact;
        system.debug('Contact Created, Idea Submitted');
        return newContact;
    }
}