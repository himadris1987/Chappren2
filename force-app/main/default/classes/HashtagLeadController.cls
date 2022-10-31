public class HashtagLeadController {
    public string leadFirstName{get; set;}
    public string leadLastName{get; set;}
    public string leadEmail{get; set;}
    public string leadPhone{get; set;}
    public string leadCompany{get; set;}
    public Id leadRecordTypeId {get; set;}


    public hashtagLeadController() {
    }

    public void createNewLead() {
        if(leadCompany == '' || leadCompany == null) {
            leadCompany = 'Individual';
        }
        try {
        Id leadRecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType='Lead' AND Name='Cowork Lead'].id;
        Lead newLead = new Lead(firstname = leadFirstName, lastName = leadLastName, email = leadEmail, phone = leadPhone, company = leadCompany, recordtypeid = leadRecordTypeId ,leadSource = 'Website');
        insert newLead;

        } catch (Dmlexception e) {
            System.debug('The following error has occured: ' + e.getMessage());
        }   
    }
}