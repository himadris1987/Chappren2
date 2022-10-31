@isTest
public with sharing class RedeemGiftTests {
    static RedeemGiftController cont;

    public static void setup(Integer option) {
        StripePaymentServiceMock mock = new StripePaymentServiceMock();
        StripePaymentService.instance = mock;
        
        cont = new RedeemGiftController();
        if(option == 1)
        {
            cont.memberFirstName = 'Unit';
            cont.memberLastName = 'Test 1';
            cont.memberEmail = 'unit@test.com';
            cont.memberPhone = '1235551234';
            cont.memberCompany = 'Unit Tests R Us';
            cont.memberCount = 1;
            cont.memberCity = 'Townsville';
            cont.memberState = 'California';
            cont.discountCode = 'GO';
            cont.checkboxValue = true;
        }
        if(option == 2)
        {
            cont.memberFirstName = '';
            cont.memberLastName = '';
            cont.memberEmail = '';
            cont.memberPhone = '';
            cont.memberCompany = '';
            cont.memberCity = '';
            cont.memberState = '';
            cont.discountCode = '';
            cont.checkboxValue = false;
        }
    }

    @isTest
    public static void validForm(){
        Boolean checkValid;
        setup(2);
        checkValid = cont.formIsValid();
        System.assertEquals(false, checkValid);
        
        setup(1);
         checkValid = cont.formIsValid();
         System.assertEquals(true, checkValid);
    }
    @isTest
    public static void AandC() {
        setup(1);
        
        cont.pullAccountAndContact();
        System.AssertEquals('unit@test.com',cont.contact.Email);
        
       
    }
    @isTest
    public static void AandC2(){
        
        setup(1);  
        Account act = new Account(Name = 'Unit Tests R Us');
        upsert act;
        act = [SELECT Id, Name FROM Account WHERE Name = 'Unit Tests R Us'];
        System.AssertEquals('Unit Tests R Us',act.Name);
        Contact con = new Contact(FirstName = 'Unit', LastName = 'Test 1', Account = act, Email = 'unit@test.com', Phone = '1235551234');
        upsert con;
        cont.pullAccountAndContact();
        System.AssertEquals('Unit Tests R Us',cont.account.Name);
    }
    @isTest
    public static void testMemberNew() {
        setup(1);
        Discount__c discount = new Discount__c(Name = 'GO',Code__c = 'GO',Times_Redeemed__c = 0, Max_Redemptions__c = 1,Amount_Off__c = 0, 	Duration__c = 'Forever',  Gift_Membership__c = true, Purchaser_Email__c = 'test@test.com', Valid__c = True);
        insert discount;
        Test.startTest();
        cont.processForm();
        Test.stopTest();
    
            
        List<Contact> conts = [SELECT Id, AccountId, Cowork_Stripe_Customer_Id__c FROM Contact];
        System.assertEquals(1, conts.size());
 
        List<Account> accts = [SELECT Id FROM Account];
        System.assertEquals(1, accts.size());

        System.assertEquals(accts[0].Id, conts[0].AccountId, 'The created Contact does not link to the created account.');

        List<Membership__c> memberships = [SELECT Id, Stripe_Subscription_Id__c FROM Membership__c];
        System.assertEquals(1, memberships.size());
        
        cont.processForm();
		 System.assertEquals('This discount code has already been redeemed.', cont.error);
        
        discount = new Discount__c(Name = 'GO2',Code__c = 'GO2',Times_Redeemed__c = 0, Max_Redemptions__c = 1,Amount_Off__c = 0, Gift_Membership__c = true, Purchaser_Email__c = 'test@test.com', Duration__c = 'Forever', Valid__c = True);
        insert discount;
        cont.discountCode = 'GO2';
        
         cont.processForm();
		 System.assertEquals('There is already an active membership under that email address.', cont.error);
        
        cont.memberEmail= 'tester2@test.com';
        cont.discountCode = 'GO3';
        
        discount = new Discount__c(Name = 'GO3',Code__c = 'GO3', Max_Redemptions__c = 1,Amount_Off__c = 0, 	Duration__c = 'Forever', Gift_Membership__c = true, Purchaser_Email__c = 'test@test.com', Valid__c = True);
        insert discount;
         cont.memberLastName = 'Test 10';
         cont.memberEmail = 'unit10@test.com';
         cont.memberPhone = '101 010 1010';
        cont.processForm();
        
        discount = [SELECT Name, Times_Redeemed__c FROM Discount__c WHERE Code__c= 'GO3'];        
        System.assertEquals(1, discount.Times_Redeemed__c);
    }
    @isTest
    public static void BadInput() {
        setup(2);
        PageReference result;
        Discount__c discount = new Discount__c(Name = 'GO',Code__c = 'GO',Times_Redeemed__c = 0, Max_Redemptions__c = 1,Amount_Off__c = 0, 	Duration__c = 'Forever', Gift_Membership__c = true,Purchaser_Email__c = 'test@test.com', Valid__c = True);
        insert discount;
        Test.startTest();
        result = cont.processForm();
        Test.stopTest();
    
        System.assertEquals(null, result);  
    }
    
    @isTest
    public static void BadCode() {
        setup(1);
        cont.discountCode = '2';
        cont.processForm();
       
    
        System.assertEquals('That is an invalid Gift code.', cont.error);  
    }
    
}