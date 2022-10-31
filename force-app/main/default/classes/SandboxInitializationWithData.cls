public class SandboxInitializationWithData implements SandboxPostCopy{
    //The number of each type of Object to create when Class Runs
    public Integer numOfAccounts = 10, numOfContactsPerAccount = 5, numOfOpps = 20,
    numOfCasesIT = 5, numOfCasesSFDC = 5, numOfRegistrationsPerClass = 5, numOfClasses = 8;

    public void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());

        Id individualAcctRtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individuals').getRecordTypeId();

        List<Account> existingAccts = [SELECT Id FROM Account WHERE RecordTypeId = :individualAcctRtId];

        if (existingAccts.size() == 0) {
            Account acct = new Account(
                Name = 'Individuals',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individuals').getRecordTypeId()
            );

            insert acct;
        }
     
        Gateway__c coworkGateway = new Gateway__c(
            Name = 'Cowork (Test)',
            Department__c = 'Cowork',
            Active__c = true
        );

        
        Gateway__c wftGateway = new Gateway__c(
            Name = 'WFT (Test)',
            Department__c = 'WFT',
            Active__c = true
        );

        insert new List<Gateway__c>{coworkGateway, wftGateway};

        //Create accounts
        List<Account> accounts = TestDataFactory.createMultipleAccounts(numOfAccounts, '');
        insert accounts;

        //Add contacts for each account
        List<Contact> contacts = new List<Contact>();
        for(Account acc : accounts) {
            contacts.addAll(TestDataFactory.createMultipleContacts(numOfContactsPerAccount, acc));
        }
        insert contacts;
        
        //Create Opps
        TestDataFactory.createMultipleOpportunities(numOfOpps, '');

        // Create cases
        Account bwAccount = TestDataFactory.createAccount();
        bwAccount.Name = 'Bitwise Industries';
        insert bwAccount;
        TestDataFactory.createMultipleCases(numOfCasesIT, 'IT', bwAccount);
        TestDataFactory.createMultipleCases(numOfCasesSFDC, 'SFDC', bwAccount);
        
        //Create first set of instructors - InPerson
        List<Contact> instructorsInPerson = TestDataFactory.createMultipleContacts(numOfClasses, bwAccount);
        for(Contact c : instructorsInPerson ) {
            c.Qualified_Instructor__c = true;
        }
        insert instructorsInPerson;

        // Create first round of classes - Attendance type:In-Person and Market:Fresno
        List<Class__c> classesInPerson = TestDataFactory.createClassRound('In-Person','Fresno');
        //add instructor for each class & save
        for (Class__c cls : classesInPerson) {
            cls.Instructor__c = instructorsInPerson.remove(0).Id;
        }
        insert classesInPerson;
        
        //Add Registrations to first round of classes
        for (Class__c cls : classesInPerson) {
            TestDataFactory.addRegistrationsToClass(numOfRegistrationsPerClass, cls);
        }

        //Create second set of instructors - Virtual
        List<Contact> instructorsVirtual = TestDataFactory.createMultipleContacts(numOfClasses, bwAccount);
        for(Contact c : instructorsVirtual ) {
            c.Qualified_Instructor__c = true;
        }
        insert instructorsVirtual;

        // Create second round of classes - Attendance type:Virtual and Market:Virtual
        List<Class__c> classesVirtual = TestDataFactory.createClassRound('Virtual','Virtual');
        //add instructor for each class & save
        for (Class__c cls : classesVirtual) {
            cls.Instructor__c = instructorsVirtual.remove(0).Id;
        }
        insert classesVirtual;
        
        //Add Registrations to Second round of classes
        for (Class__c cls : classesVirtual) {
            TestDataFactory.addRegistrationsToClass(numOfRegistrationsPerClass, cls);
        }

    }    
}