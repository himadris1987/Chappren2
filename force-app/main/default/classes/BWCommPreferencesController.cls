public class BWCommPreferencesController {
    //Getting and setting the fields to be Queried
    public String contactId{get; set;}
    public String contactFirstName {get; set;}
    public String contactLastName {get; set;}
   
    public Boolean wftEmailOptIn {get; set;}
    public Boolean wftSMSOptIn {get; set;}
    public Boolean coworkEmailOptIn {get; set;}
    public Boolean coworkSMSOptIn {get; set;}
    
    @TestVisible private Contact contact; 

   //start of the SQOL Query 
    public BWCommPreferencesController() {
        contactFirstName = '';
        contactLastName = '';
        contactId = apexpages.currentPage().getparameters().get('Id');
        GetContact();
    }

    public void GetContact() {
        List<Contact> contacts = new List<Contact>(); 
        contacts =[SELECT Id, FirstName, LastName, Email, WFT_Email_Opt_In__c, WFT_SMS_Opt_In__c, 
                   Cowork_Email_Opt_In__c, Cowork_SMS_Opt_In__c FROM Contact WHERE Id =: contactId ];
        if (contacts.size() == 1 ) {
            contact = contacts[0];
            contactFirstName = contact.FirstName;
            contactLastName = contact.LastName;

			wftEmailOptIn = contact.WFT_Email_Opt_In__c;
    		wftSMSOptIn = contact.WFT_SMS_Opt_In__c;
    		coworkEmailOptIn = contact.Cowork_Email_Opt_In__c;
    		coworkSMSOptIn = contact.Cowork_SMS_Opt_In__c;
        }
        else {
            system.debug(contacts);
        }
    }
  
    public PageReference updatePreferences() {
        
		contact.WFT_Email_Opt_In__c = wftEmailOptIn;
    	contact.WFT_SMS_Opt_In__c = wftSMSOptIn;
        contact.Cowork_Email_Opt_In__c = coworkEmailOptIn;
        contact.Cowork_SMS_Opt_In__c = coworkSMSOptIn;
        
        update contact;
        return null;
    }

}