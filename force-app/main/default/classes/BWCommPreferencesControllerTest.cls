@isTest
public class BWCommPreferencesControllerTest {
    
    @isTest 
    static void updatePreferencesTest(){

        contact testContact = new Contact(FirstName='Victor', LastName='Carranza', WFT_Email_Opt_In__c= false, Email='viccarranza67@gmail.com');
        insert testContact;

        Test.setCurrentPageReference(new PageReference('apex/BWCommPreferences.page')); 
        System.currentPageReference().getParameters().put('Id', testContact.id);

        BWCommPreferencesController controller = new BWCommPreferencesController();

        System.assertEquals(testContact.Id,controller.contact.id);
        controller.wftEmailOptIn = true;
        controller.updatePreferences();
        
        Contact returnedContact = [SELECT Id, WFT_Email_Opt_In__c, WFT_SMS_Opt_In__c, 
                                   Cowork_Email_Opt_In__c, Cowork_SMS_Opt_In__c FROM Contact WHERE Id =: testContact.Id];
        System.assertEquals(controller.contact.WFT_Email_Opt_In__c, returnedContact.WFT_Email_Opt_In__c);
              
    }
}