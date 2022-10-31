@isTest()
public class CoworkSmsCampaignTest {
    // getTotalContact() function test
    @isTest static void getTotalContact0() {
		Integer totalContacts = CoworkSmsCampaignController.getTotalContact();
        System.assertEquals(0, totalContacts);
    }
    
    @isTest static void getTotalContact5() {        
        for (Integer i = 0; i < 10; i++) {
            Contact contact = new Contact(
            	Lastname = 'Felipe' + String.valueOf(i),
                Email = 'fvargas'+ String.valueOf(i) + '@bitwiseindustries.com',
                MobilePhone = '(559) 940-353'+ String.valueOf(i)
            );
            
            insert contact;
            
            if (i < 5) {
                Membership__c membership = new Membership__c (
                    Contact__c = contact.Id,
                    Membership_End_Date__c = Date.today()
                );
                    
                insert membership;
            } else {
                Membership__c membershipExp = new Membership__c (
                    Contact__c = contact.Id,
                    Membership_End_Date__c = Date.today().addDays(-7)
                );
                    
                insert membershipExp;    
            }
        }
       
		Integer totalContacts = CoworkSmsCampaignController.getTotalContact();
        System.assertEquals(5, totalContacts);
    }
    
    // getCoworkSmsCampaignPush() function test
    @isTest static void getCoworkSmsCampaignPush0() {
		List<Marketing_SMS_Push__c> mspResult = CoworkSmsCampaignController.getCoworkSmsCampaignPush();
        
        System.assertEquals(0, mspResult.size());
    }
    
    @isTest static void getCoworkSmsCampaignPush5() {
        Campaign campaign;
        
        for (Integer i = 0; i < 5; i++) {
            String Name = 'Cowork' + String.valueOf(i);
            
            if (i == 0){
                Name = 'Cowork';
            }
            
            campaign = new Campaign(
                Name = Name
            );
            
            insert campaign;
            
            for (Integer j = 0; j < 5; j++) {
                Marketing_SMS_Push__c msp = new Marketing_SMS_Push__c (
                    Campaign__c = campaign.Id
                );
                    
                insert msp;
            }
        } 
        
		List<Marketing_SMS_Push__c> mspResult = CoworkSmsCampaignController.getCoworkSmsCampaignPush();
        
        System.assertEquals(5, mspResult.size());
    }
    
    // sendMessages() function test
    @isTest static void sendMessagesError0() {
    	CoworkSmsCampaignController.sendMessages('APEX Testing');
    }
    
    @isTest static void sendMessagesError1() {
        Campaign campaign = new Campaign(
            Name = 'Cowork'
        );
        
        insert campaign;
        
    	CoworkSmsCampaignController.sendMessages('APEX Testing');
    }
    
    @isTest static void sendMessagesError2() {
        Campaign campaign = new Campaign(
            Name = 'Cowork'
        );
        
        Cowork_custom_settings__c settings = new Cowork_custom_settings__c(
            Twilio_API_Url__c	 = 'https://api.twilio.com/2010-04-01/Accounts/ACa6f76f4734d753d6aa552747e4bc9268/Messages.json',
            Twilio_Account_SID__c  = 'Dummy SID'
        );
        
        insert campaign;
        insert settings;
        
    	CoworkSmsCampaignController.sendMessages('APEX Testing');
    }
    
    @isTest static void sendMessagesError3() {
        Campaign campaign = new Campaign(
            Name = 'Cowork',
            Phone_Number__c = '+15592724676'
        );
        
        Cowork_custom_settings__c settings = new Cowork_custom_settings__c(
            Twilio_API_Url__c	 = 'https://api.twilio.com/2010-04-01/Accounts/ACa6f76f4734d753d6aa552747e4bc9268/Messages.json',
            Twilio_Account_SID__c  = 'Dummy SID'
        );
        
        insert campaign;
        insert settings;
        
    	CoworkSmsCampaignController.sendMessages('APEX Testing');
    }
    
    @isTest static void sendMessagesError4() {
        Campaign campaign = new Campaign(
            Name = 'Cowork',
            Phone_Number__c = '+15592724676'
        );
        
        Cowork_custom_settings__c settings = new Cowork_custom_settings__c(
            Twilio_API_Url__c	 = 'https://api.twilio.com/2010-04-01/Accounts/ACa6f76f4734d753d6aa552747e4bc9268/Messages.json',
            Twilio_Account_SID__c  = 'Dummy SID',
            Twilio_Auth_Token__c  = 'Dummy Token'
        );
        
        insert campaign;
        insert settings;
        
    	CoworkSmsCampaignController.sendMessages('APEX Testing');
    }
    
    @isTest static void sendMessagesSuccess() {
        Campaign campaign = new Campaign(
            Name = 'Cowork',
            Phone_Number__c = '+15592724676'
        );
        
        Cowork_custom_settings__c settings = new Cowork_custom_settings__c(
            Twilio_API_Url__c	 = 'https://api.twilio.com/2010-04-01/Accounts/ACa6f76f4734d753d6aa552747e4bc9268/Messages.json',
            Twilio_Account_SID__c  = 'Dummy SID',
            Twilio_Auth_Token__c  = 'Dummy Token'
        );
        
        insert campaign;
        insert settings;
        
        Contact contact1 = new Contact(
            Lastname = 'Felipe',
            Email = 'fvargas50@bitwiseindustries.com',
            MobilePhone = '(559) 940-3532'
        );
        
        Contact contact2 = new Contact(
            Lastname = 'Felipe2',
            Email = 'felipevargas60@bitwiseindustries.com',
            MobilePhone = '(559) 940-35322'
        );
        
        insert contact1;
        insert contact2;
                
        Membership__c membership1 = new Membership__c (
            Contact__c = contact1.Id,
            Membership_End_Date__c = Date.today()
        );
                
        Membership__c membership2 = new Membership__c (
            Contact__c = contact2.Id,
            Membership_End_Date__c = Date.today()
        );
        
        insert membership1;
        insert membership2;
        
        Test.setMock(HttpCalloutMock.class, new CoworkSmsCampaignController_Mock());
    	CoworkSmsCampaignController.sendMessages('APEX Testing');
    }
}