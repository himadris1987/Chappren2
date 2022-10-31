public class TestDataFactory {
    static Integer contactCount = 0, accountCount = 0, leadCount = 0, classCount = 0, 
    opportunityCount = 0, caseCount = 0, apprenticeshipCount = 0 ; 

    public static Lead createLead() {
        lead l = new Lead(
        	LastName = 'Lead '+ String.valueOf(leadCount), 
            Company = 'Company '+ String.valueOf(leadCount));

        leadCount++;
        return l;
	}

    public static Lead createLead(String recordTypeName) {
        Id recTypeID;
        
        try {
			recTypeID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		} catch (Exception e) {
			System.debug('Record type '+ recordTypeName + ' does not exist. Please note that Record type name is Case-Sensitive');
            return null;
		}
        
        Lead l = createLead();
        l.RecordTypeId = recTypeID;
        return l;
	}

    // Create multiple Leads
    // public static List<Lead> createMultipleLeads(Integer numberOfLeads, String recordTypeName) {
        public static List<Lead> createMultipleLeads(Integer numberOfLeads, String recordTypeName) {
            List<Lead> listLeads = new List<Lead>();
            
            for (Integer i = 0; i < numberOfLeads; i++) {
                if (String.isBlank(recordTypeName)) {
                    listLeads.add(createLead());
                } else {
                    listLeads.add(createLead(recordTypeName));
                }
            }
            return listLeads;
        }        
   
    //Create case with default redord type
    public static Case createCase(Contact con) {

        Case c = new Case(
            Subject = 'Case ' + String.valueOf(caseCount),
            ContactId = con.Id,
            Status = 'New',
            Origin = 'Email');

		caseCount++;
        return c;
	}

    //Create case with specific redord type
    public static Case createCase(Contact con, String recordTypeName) {
        ID recTypeId;
        
        try {
			recTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		} catch (Exception e) {
			System.debug('Record type '+ recordTypeName + ' does not exist. Please note that Record type name is Case-Sensitive');
            return null;
		}
        
        Case c = createCase(con);
        c.RecordTypeId = recTypeId;
        return c;
	}

    // Create multiple Cases
    // public static List<Case> createMultipleCases(Integer numberOfCases, String recordTypeName) {
    public static List<Case> createMultipleCases(Integer numberOfCases, String recordTypeName, Account contactAccount) {
        List<Case> cases = new List<Case>();
        List<Contact> contacts = createMultipleContacts(numberOfCases, contactAccount);
        insert contacts;

        for(Contact con : contacts) {
            if (String.isBlank(recordTypeName)) {
                cases.add(createCase(con));
            } else {
                cases.add(createCase(con, recordTypeName));
            }
        }
        insert cases;
        return cases;
    }  

    //Class__c has only 1 record type.
    //className parameter must be supplied, otherwise you will get an error (bad value for restricted picklist field)
    public static Class__c createClass(String className) {
        Class__c c = new Class__c(
           Class__c = className,
           Start_Date__c = System.today(),
           End_Date__c = System.today() + 42,
           Class_Length__c = '6 Weeks',
           Class_Nights__c = 'Tuesday / Thursday');

       classCount++;
       return c;
    }

    //Returns picklist values for the given object and field.
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> pickListvalues = new List<String>();
        List<String> types = new List<String>{objectName};
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            List<Schema.PicklistEntry> plEntries = res.fields.getMap().get(fieldName).getDescribe().getPicklistValues();
            for (Schema.PicklistEntry plEntry : plEntries) {
                if (plEntry.isActive()) {
                    pickListvalues.add(plEntry.getValue());
                }
            }
        }
        return pickListvalues;
     }

    //Create Class Round should create each of the standard Classes
    public static List<Class__c> createClassRound(String attendanceType, String market){
        List<String> classNames = getPicklistValues('Class__c', 'Class__c');
        List<Class__c> listClasses = new List<Class__c>();
        Date mondayDate, tuesdayDate;

        mondayDate = System.today().toStartOfWeek() + 1;
        tuesdayDate = mondayDate + 1;

        Integer count = 0;
        for (String className : classNames) {
            count++;
            if( className == 'Other' || className.contains('Angular')) {
                continue;
            }
            
            Class__c c = createClass(className);
            // Check to see if number is even or odd
            if (Math.mod(count, 2) != 0) {
                c.Start_Date__c = mondayDate;
                c.End_Date__c = mondayDate + 42; //6 wks from start date
                c.Class_Nights__c = 'Monday / Wednesday';
            } else {
                c.Start_Date__c = tuesdayDate;
                c.End_Date__c = tuesdayDate + 42; //6 wks from start date
                c.Class_Nights__c = 'Tuesday / Thursday';
            }
            c.Attendance_Type__c = attendanceType;
            c.Class_Length__c = '6 Weeks';
            c.Instruction_Time__c = '36 hrs. Instruction';
            
            c.Scheduled_Time__c = '6:00pm - 9:00pm';
            c.Time_Zone__c = 'Pacific';
            c.Market__c = market;
            
            listClasses.add(c);
        }
        return listClasses;
    }

    //Registration__c has only one Record type
    public static Registration__c createRegistration(Contact con, Class__c cls) {

        Registration__c r = new Registration__c(
            Registrant__c = con.Id,
            Class__c = cls.Id);

        return r;
	}

    // Function will add Regisrations to Class by creating new contacts, insert List<Contacts> Add Contacts, to Registrations, insert Registrations
    // Class must be already created to call this function
    // public static List<Registration__c> addRegistrationsToClass(Integer numberOfStudents, Class__c cls) {
    public static List<Registration__c> addRegistrationsToClass(Integer numberOfStudents, Class__c cls) {

        Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individuals').getRecordTypeId();
        Account individual = [SELECT Id FROM Account WHERE RecordTypeId = :individualRecordType LIMIT 1];
        
        List<Registration__c> listRegistrations = new List<Registration__c>();
        List<Contact> listContacts = createMultipleContacts(numberOfStudents, individual);
        insert listContacts;
       
        for (Contact con : listContacts) {
            listRegistrations.add(createRegistration(con, cls));
        }

        insert listRegistrations;
        return listRegistrations; 
    }
        
    //Apprenticeship__c has only one Record type
    public static Apprenticeship__c createApprenticeship(Contact con) {

        Apprenticeship__c a = new Apprenticeship__c(
            Name = 'Apprenticeship ' + String.valueof(apprenticeshipCount),
            Apprenticeship_Lead__c = con.Id, // Flow (WFT - Apprentice - After Save - Create) needs this field
            Start_Date__c = System.today(), //optional
            End_Date__c = System.today() + 180); //optional

        apprenticeshipCount++;
        return a;
    }
    
    //Apprentice__c has only one Record type
    public static Apprentice__c createApprentice(Contact con, Apprenticeship__c aps) {

        Apprentice__c a = new Apprentice__c(
            Contact__c = con.Id,
            Apprenticeship__c = aps.Id);

        return a;
	}
   
    // Function will add Apprentices to Apprenticeship by creating new contacts, insert List<Contacts> Add Contacts, to Apprenticeship, insert Apprentices
    // Apprenticeship must be already created to call this function
    // public static List<Apprentice__c> addApprenticesToClass(Integer numberOfApprentices, Apprenticeship__c aps) {
    //add comms    
    public static List<Apprentice__c> addApprenticesToApprenticeship(Integer numberOfApprentices, Apprenticeship__c aps) {

        List<Apprentice__c> listApprentice = new List<Apprentice__c>();
        List<Contact> listContacts = createMultipleContacts(numberOfApprentices);
        insert listContacts;

        for (Contact con : listContacts){
            listApprentice.add(createApprentice(con, aps));
        }

        insert listApprentice;
        return listApprentice; 
    }        

   
    public static Gateway__c createGateway(String department) {
        return new Gateway__c(
            Name = department,
            Publishable_Key__c = 'PublishableKey',
            Secret_Key__c = 'SecretKey',
            Department__c = department,
            Active__c=true
        );
    }

    //Contact has only one Record type
    public static Contact createContact() {
        Contact c = new Contact(
            LastName = 'Test ' + String.valueOf(contactCount),
            FirstName = 'Contact',
            Email = 'testcontact' + String.valueOf(contactCount) + '@example.com' 
        );
        contactCount++;
        return c;
    }

    // Create multiple Contacts
    // public static List<Contacts> createMultipleContacts(Integer numberOfContacts, String recordTypeName) {
    // Contact has only one Record type        
    public static List<Contact> createMultipleContacts(Integer numberOfContacts) {
        List<Contact> listContacts = new List<Contact>();

        for(Integer i = 0; i < numberOfContacts; i++){
            listContacts.add(createContact());
        }

        return listContacts;
    }        

    public static List<Contact> createMultipleContacts(Integer numberOfContacts, Account acc) {
        List<Contact> listContacts = new List<Contact>();

        for(Integer i = 0; i < numberOfContacts; i++){
            Contact c = createContact();
            c.AccountId = acc.Id;
            listContacts.add(c);
        }

        return listContacts;
    }

    public static Account createAccount() {
        return new Account(
            Name = 'Account ' + String.valueOf(accountCount++)
        );
	}

    public static Account createAccount(String recordTypeName) {
        Id recTypeID;
        
        try {
			recTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		} catch (Exception e) {
			System.debug('Record type '+ recordTypeName + ' does not exist. Please note that Record type name is Case-Sensitive');
            return null;
		}

        Account a = createAccount();
        a.RecordTypeId = recTypeId;

        return a;
	}

    public static Account createIndividualAccount() {
        Account output = createAccount();
        output.Name = 'Individual';
        output.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individuals').getRecordTypeId();
        return output;
    }

    // Create multiple Accounts
    // public static List<Account> createMultipleAccount(Integer numberOfAccounts, String recordTypeName) {
    public static List<Account> createMultipleAccounts(Integer numberOfAccounts, String recordTypeName) {
        List<Account> listAccounts = new List<Account>();

        for (Integer i = 0; i < numberOfAccounts; i++) {
            if (String.isBlank(recordTypeName)) {
                listAccounts.add(createAccount());
            } else {
                listAccounts.add(createAccount(recordTypeName));
            }
        }

        return listAccounts;
    }       

    public static Opportunity createOpportunity(Account acc, Contact con) {
        
        Opportunity o = new Opportunity(
        	Name = 'Opportunity ' + String.valueOf(opportunityCount),  
            AccountId = acc.Id,
            Primary_Contact__c = con.Id,
            Pardot_Business_Unit__c = 'BWTC',
            CloseDate = System.today() + 90,
            StageName = 'Validation');
        
        opportunityCount++;
		return o;
	}

    public static Opportunity createOpportunity(Account acc, Contact con, String recordTypeName) {
        ID recTypeId;
        
        try {
			recTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		} catch (Exception e) {
			System.debug('Record type '+ recordTypeName + ' does not exist. Please note that Record type name is Case-Sensitive');
			return null;
		}
        
        Opportunity o = createOpportunity(acc, con);
        o.RecordTypeId = recTypeId;
        return o;
	}
   
    // Create multiple Opportunities
    // public static List<Opportunity> createMultipleOpportunity(Integer numberOfOpportunitys, String recordTypeName) {
    // create accounts, contacts, opps and insert them
    public static List<Opportunity> createMultipleOpportunities(Integer numberOfOpportunities, String recordTypeName) {
        
        List<Opportunity> opportunities = new List<Opportunity>();
        List<Contact> contacts = new List<Contact>();

        //Add accounts
        List<Account> accounts = createMultipleAccounts(numberOfOpportunities,'');
        insert accounts;

        //Create one contact for each account
        for(Account acc : accounts) {
            Contact c = createContact();
            c.AccountId = acc.Id;
            contacts.add(c);
        }
        insert contacts;

        // Create one opportunity for each account
        for(Account acc : accounts) {
            if (String.isBlank(recordTypeName)){
                opportunities.add(createOpportunity(acc, contacts.remove(0)));
            } else {
                opportunities.add(createOpportunity(acc, contacts.remove(0), recordTypeName));
            }                
        }

        insert opportunities;
        return opportunities;
    }
          
}