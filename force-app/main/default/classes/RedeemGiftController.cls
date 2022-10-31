public with sharing class RedeemGiftController {
    public string error{get;set;} 

    public String memberFirstName {get;set;}
    public String memberLastName {get;set;}
    public String memberEmail {get;set;}
    public String memberPhone {get;set;}
    public String memberCompany {get;set;}
    public String memberCity {get;set;}
    public String memberState {get;set;}
    public String membershipType {get;set;}
    public Integer memberCount {get;set;}
    public String discountCode{get;set;}
    public Boolean checkboxValue{get; set;}

    public Membership__c membership;
    public Contact contact;
    public Account account;

    List<String> states = new List<String>();
    public List<SelectOption> getPopulateStates() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','State'));
        for (Schema.PicklistEntry pe : SObjectType.Survey__c.fields.State__c.getPicklistValues()) {
            options.add(new SelectOption(pe.getLabel(), pe.getLabel()));
        }   
        return options;
    }
        
    public List<String> getStates() {
        return states;
    }
        
    public void setStates(List<String> countries) {
        this.states = states;
    }

    public RedeemGiftController() {

        membershipType = 'Individual Yearly';
        System.debug(membershipType);

    }
    


    public PageReference processForm() {
        
        error = '';
       
        System.debug('Get in processForm');

        PageReference result = null; 

        //Clean the data of whitespace. 
        memberFirstName = memberFirstName.trim();
        memberLastName = memberLastName.trim();
        memberEmail = memberEmail.trim();
        memberPhone = memberPhone.trim();
        memberCompany = memberCompany.trim();
        memberCity = memberCity.trim();
        if (!String.isBlank(memberState)) {
            memberState = memberState.trim();
        }
        discountCode = discountCode.trim();

        if (!formIsValid()) {
            System.debug('Form is invalid');
            return result;
        }
        //If there's a discount code applied, make sure it's valid. If not, yell at the user.
        Discount__c discountRecord = null;

        if (discountCode != '') {
            List<Discount__c> codes = [SELECT Id, Code__c, Times_Redeemed__c, Max_Redemptions__c FROM Discount__c WHERE Code__c = :discountCode AND Valid__c = true AND Gift_Membership__c = true];

            if (codes.size() == 0) {
                System.debug('Invalid Discount Code');
                error = 'That is an invalid Gift code.';
                return result;
            } else {
                discountRecord = codes[0];
                if(discountRecord.Times_Redeemed__c >= discountRecord.Max_Redemptions__c ) {
                    System.debug('Invalid Discount Code');
                    error = 'This discount code has already been redeemed.';
                    return result;
                }
            }
        }

        System.debug(discountRecord);
        
        //Search for the Account and Contact, trying to match based on what the user entered.
        pullAccountAndContact();

        //See if there's an active membership for the Contact. If there is, yell at the user.
        if ([SELECT Id FROM Membership__c WHERE Status__c = 'Active' AND Contact__c = :contact.Id].size() > 0) {
            System.debug('Active membership already exists');
            error = 'There is already an active membership under that email address.';
            return result;
        }

        memberCount = 1;

        //Create a membership for the user.
        membership = new Membership__c(Contact__c = contact.Id,
                                       Membership_Start_Date__c = Date.today(),
                                       Status__c = 'Active',
                                       Type__c = membershipType,
                                       Number_Of_Members__c = memberCount);

        result = new PageReference('https://hashtagcoworkplace.com/membership-redeemed/');
            
           


        //If it's a new account, insert the account.
        if (account.Id == null) {
            //Balaji
            system.debug(account);
            insert account;
        }

        contact.AccountId = account.Id;
        upsert contact;

        membership.Contact__c = contact.Id;
      

        insert membership;

       System.debug(membership);

        //Update the discount, if there is one.
        if (discountRecord != null) {
            if(discountRecord.Times_Redeemed__c == null){
                discountRecord.Times_Redeemed__c = 1;
            }
            else {
                discountRecord.Times_Redeemed__c += 1;
            }
            discountRecord.Recipient_First_Name__c = contact.FirstName;
            discountRecord.Recipient_Last_Name__c = contact.LastName;
            update discountRecord;
        }

        System.debug(discountRecord);
        System.debug(result);
        return result;
    }

   

    public Boolean formIsValid() {
        List<String> errors = new List<String>();
        System.debug('In Form is Valid');
        if (memberFirstName == '') {
            errors.add('First Name must be filled in.');
        }
        if (memberLastName == '') {
            errors.add('Last Name must be filled in.');
        }
        if (memberEmail == '') {
            errors.add('Email must be filled in.');
        }
        if (memberPhone == '') {
            errors.add('Phone must be filled in.');
        }

        if(discountCode == ''){
            errors.add('You must have a Gift Code to redeem a gift.');
        }

        if (checkboxValue == false) {
            errors.add('You must agree to the code of conduct.');
        }

        if (!String.isBlank(memberCity) && String.isBlank(memberState)) {
            errors.add('Please select a state.');
        }

        if (errors.size() > 0) {
            error = String.join(errors, '\n');
            return false;
        }

        return true;
    }

    public void pullAccountAndContact() {
        //Look for an existing Contact/Account.
        List<Contact> conts = [SELECT Id, FirstName, LastName, Email, Phone, AccountId FROM Contact WHERE Email LIKE :memberEmail];
        contact = new Contact();

        if (conts.size() > 0) {
            contact = conts[0];
        }

        List<Account> accts;

        if (contact.AccountId != null) {
            accts = [SELECT Id FROM Account WHERE Id = :contact.AccountId];
        } else if (memberCompany != '') {
            accts = [SELECT Id FROM Account WHERE Name LIKE :memberCompany AND BillingCity LIKE :memberCity AND BillingState LIKE :memberState];
        } else {
            accts = [SELECT Id FROM Account WHERE RecordType.Name = 'Individuals'];
        }

        if (accts.size() > 0) {
            account = accts[0];
        } else {
            account = new Account(Name = memberCompany, BillingCity = memberCity, BillingState = memberState);
        }

        if(contact.Id == null) {
            contact = new Contact();
            contact.FirstName = memberFirstName;
            contact.LastName = memberLastName;
            contact.Email = memberEmail;
            contact.Phone = memberPhone;
            if (account.Id != null) {
                contact.AccountId = account.Id;
            }
        }
    }

}