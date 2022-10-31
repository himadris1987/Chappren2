public class BLDGCheckinController {

    public String location {get;set;}

    public String[] MeetWithNames {get;set;}

    public Contact meetingContact {get;set;}
    public List<Contact> contactsForCheckins = new list<Contact>();
    public String meetWithName {get;set;}
    public Space__c locationAsSpace;


    // variables for contacts
    public String contactFirstName{get;set;}
    public String contactLastName{get;set;}
    public String contactPhoneNumber{get;set;}
    public String contactPronoun{get;set;}
    public String contactEmail{get;set;}
    public String contactCompany{get;set;}


    private Map<String,String> paramMap = new Map<String,String>();
    
     public BLDGCheckinController() {

         paramMap = ApexPages.currentPage().getParameters();
        
         switch on paramMap.get('location') {
             when 'BWH' {
                 location = 'BWH';
                 locationAsSpace = [SELECT Id, Name FROM Space__c WHERE Name = 'Bitwise Hive' Limit 1];
             }
             when 'BW41' {
                 location = 'BW41';
                 locationAsSpace = [SELECT Id, Name FROM Space__c WHERE Name = 'Bitwise | 41' Limit 1];
             }
             when else {
                 location = 'BWSS';
                 locationAsSpace = [SELECT Id, Name FROM Space__c WHERE Name = 'Bitwise South Stadium' Limit 1];
             }
         }
         System.debug(locationAsSpace);
         getContactsForCheckIns();
          
    }
    
    public pageReference navigateToMeetingWith() {
        pageReference newPage = new pageReference('/apex/bwMeetingWith');
        newPage.setRedirect(false);
        return newPage;
    }
        
    public void getContactsForCheckIns(){
        MeetWithNames = new List<String>();
        
        switch on location{
            when 'BWH' {
                ContactsForCheckIns = [SELECT Id, FirstName, LastName, Pronouns__c FROM Contact WHERE Check_In_Locations__c includes('Bitwise Hive') ORDER BY Name ASC];

            }
            when 'BW41' {
                ContactsForCheckIns = [SELECT Id, FirstName, LastName, Pronouns__c FROM Contact WHERE Check_In_Locations__c includes('Bitwise | 41') ORDER BY Name ASC];

            }
            when else {
                ContactsForCheckIns = [SELECT Id, FirstName, LastName, Pronouns__c FROM Contact WHERE Check_In_Locations__c includes('Bitwise South Stadium') ORDER BY Name ASC];
            }
        }
        System.debug(ContactsForCheckIns);
        System.debug(ContactsForCheckIns.size());

        
        if (ContactsForCheckIns.size() < 0) {
            MeetWithNames.add('No Names Returned');
            return;
        }
        System.debug(ContactsForCheckIns.size());
        // System.debug(MeetWithNames);
        for (Contact c : ContactsForCheckIns) {
            // System.debug(MeetWithNames);
            System.debug(c.FirstName);
            System.debug(c.LastName);
            MeetWithNames.add(c.FirstName + ' ' + c.LastName);        
        }
            System.debug(MeetWithNames);         
	}
	
	public void createDeliveryCheckIn() {
		insert new Check_in__c(
								Check_In_Location__c = locationAsSpace.Id,
								Delivery__c = true);
   
	}

    public pageReference createCheckIn() {

        for (contact c: contactsForCheckins) { 
            String fullName = c.firstName + ' ' + c.lastName;
            if(meetWithName == fullName) {
                meetingContact = c;
            }
        }
        
        system.debug(meetingContact);

        Check_in__c newCheckin = new Check_in__c();
        newCheckin.Meeting_With__c = meetingContact.Id;
        newCheckin.Visitor_Pronouns__c = contactPronoun;
        newCheckin.Visitor_First_Name__c = contactFirstName;
        newCheckin.Visitor_Last_Name__c = contactLastName;
        newCheckin.Visitor_Email__c = contactEmail;
        newCheckin.Visitor_Company__c = contactCompany;
        newCheckin.Check_In_Location__c = locationAsSpace.Id;

        insert newCheckin;

        Pagereference newPage = new Pagereference('/apex/bwMeetingConfirmation');
        newpage.setRedirect(false);
        return newPage;
    }
                
    public pageReference backToHome() {
        pageReference home = new Pagereference('/apex/bwCheckin');
        home.getParameters().put('location',location);
        home.setRedirect(true);
        return home;
    }


    public list<SelectOPtion> getPronounList() {
        list<selectOption> pronounOptions = new List<selectOption>();
        pronounOptions.add(new SelectOption('', '-Please Select-'));
        pronounOptions.add(new SelectOption('He/Him', 'He/Him'));
        pronounOptions.add(new SelectOption('She/Her', 'She/Her'));
        pronounOptions.add(new SelectOption('They/Them', 'They/Them'));
        pronounOptions.add(new SelectOption('Prefer Not to Answer', 'Prefer Not to Answer'));
        return pronounOptions;
    }
}