public class CoworkSmsCampaignController {
    @AuraEnabled(cacheable=true)
    public static Integer getTotalContact() {
        return [SELECT Id FROM Membership__c WHERE (Status__c = 'Active' AND IsExpired__c = false AND (Contact__r.MobilePhone != null OR Contact__r.Phone != null))].size();
    }

    @AuraEnabled(cacheable=true)
    public static Marketing_SMS_Push__c[] getCoworkSmsCampaignPush() {
        List<Marketing_SMS_Push__c> msp = new List<Marketing_SMS_Push__c>();
 
        // Get Cowork campaign push object
        try {
	        Campaign campaign = [SELECT Id, Name, Type, Phone_Number__c, Keyword__c FROM Campaign WHERE Name='Cowork' LIMIT 1];
    	    msp = [SELECT Id, Campaign__c, Message_Content__c, (SELECT Id FROM Marketing_Sent_SMS__r) FROM Marketing_SMS_Push__c  WHERE Campaign__c = :campaign.Id ORDER BY CreatedDate DESC];
        } catch (Exception e) {
            System.debug('Error getting object data for Campaign Push');
            System.debug(e);
        }
        
        return msp;
    }

    @AuraEnabled(cacheable=false)
    @future(callout=true)
    public static void sendMessages(String smsContent) {
        String fromPhoneNumber, campaignId, twilioAPIUrl, twilioAccountSID, twilioAuthToken, supportEmail;
        Campaign campaign;
        List<Marketing_Sent_SMS__c> sentMessages = new List<Marketing_Sent_SMS__c>();
        
        // Get Cowork campaign object
        try {
        	campaign = [SELECT Id, Name, Type, Phone_Number__c, Keyword__c FROM Campaign WHERE Name='Cowork' LIMIT 1];
            fromPhoneNumber = campaign.Phone_Number__c;
            campaignId = campaign.Id;    
        } catch (Exception e) {
            System.debug('Error getting Cowork SMS Campaign to send message.');
            System.debug(e);
            return;
        }

        // Get Cowork custom settings
        try {
            Cowork_custom_settings__c settings = Cowork_custom_settings__c.getOrgDefaults();
            twilioAPIUrl = settings.Twilio_API_Url__c;
            twilioAccountSID = settings.Twilio_Account_SID__c;
            twilioAuthToken = settings.Twilio_Auth_Token__c;
            supportEmail = settings.Support_Email__c ;
            
        } catch (Exception e) {
            System.debug('Error getting Cowork custom settings to send message.');
            System.debug(e);
            return;
        }
        
        // Check for campaign phone number
        if (String.isBlank(fromPhoneNumber)) {            
            System.debug('Campaign phone number is missing');
            System.debug(campaign);
            return;
        }
        
        // Check for valid custom setting variables
        if (String.isBlank(twilioApiUrl)) (System.debug('twilioApiUrl custom setting variable is missing'));
        if (String.isBlank(twilioAccountSID)) (System.debug('twilioAccountSID custom setting variable is missing'));
        if (String.isBlank(twilioAuthToken)) (System.debug('twilioAuthToken custom setting variable is missing'));
        
        if (String.isBlank(twilioAPIUrl) || String.isBlank(twilioAccountSID) || String.isBlank(twilioAuthToken)) {
            return;
        }
        
        // Loop through all non-expired memberships
        for (Membership__c membership : [SELECT Id, IsExpired__c, Contact__r.Id, Contact__r.Name, Contact__r.MobilePhone, Contact__r.Phone FROM Membership__c WHERE (Status__c = 'Active' AND IsExpired__c = false AND (Contact__r.MobilePhone != null OR Contact__r.Phone != null))]) {
            // Grab Phone Number from contact from either the MobilePhone or Phone field
            String phoneNumber = membership.Contact__r.MobilePhone;
            
            if (String.isBlank(phoneNumber)) {
                phoneNumber = membership.Contact__r.Phone;
            }
            
            // Check that membership's contact has a phone number
            if (!String.isBlank(phoneNumber)) {
                // Format phone number
                String toPhoneNumber = phoneNumber.replaceAll('[^0-9]', '');
                    
                if (toPhoneNumber.length() > 10) {
                    toPhoneNumber = toPhoneNumber.right(10);
                }
                
                toPhoneNumber = '+1' + toPhoneNumber;
                
                // Send request to Twilio to send message
                HttpRequest req = new HttpRequest();
                req.setEndpoint(twilioAPIUrl);
                req.setMethod('POST');
                
                Blob headerValue = Blob.valueOf(twilioAccountSID + ':' + twilioAuthToken);
                String authorizationHeader = 'Basic ' +
                    EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);                
                
                String payload = 'From='+EncodingUtil.urlEncode(fromPhoneNumber,'UTF-8')+'&To='+EncodingUtil.urlEncode(toPhoneNumber,'UTF-8')+'&Body='+EncodingUtil.urlEncode(smsContent,'UTF-8');
                req.setBody(payload);
                Http http = new Http();
                HTTPResponse res = http.send(req);
                
				// Check if Twilio accepted sending message request
                if (res.getStatusCode() == 201) {
                    Marketing_Sent_SMS__c  mss = new Marketing_Sent_SMS__c  (
                        Contact__c = membership.Contact__r.Id,
                        To_Phone__c = toPhoneNumber,
                        From_Phone__c = fromPhoneNumber
                    );
                    
                    sentMessages.add(mss);
                } else {
                    System.debug('Error sending message with Twilio.');
                    System.debug(membership);
                }
            }
        }

        // Create all object entries
        // Must be done after sending http requests due to SF restrictions
        Marketing_SMS_Push__c msp = new Marketing_SMS_Push__c (
        	Message_Content__c = smsContent,
            Campaign__c = campaignId
        );
        
        insert msp;        
        
        for (Marketing_Sent_SMS__c mss : sentMessages) {
            mss.Marketing_SMS_Push__c = msp.Id;
        }
        
        insert sentMessages;
    }
}