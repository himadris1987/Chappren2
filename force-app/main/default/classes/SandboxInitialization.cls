public class SandboxInitialization implements SandboxPostCopy{
    public void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());
        System.debug('Profile of User: ' + userinfo.getProfileId());
        System.debug('User Name: ' + userinfo.getName());
        System.debug('User Type: ' + userinfo.getUserType());
        System.debug('User Id: ' + userinfo.getUserId());

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
    }
}