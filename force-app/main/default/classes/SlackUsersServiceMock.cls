public class SlackUsersServiceMock extends SlackUsersService {

    public override void getUserIdAndProfileFromEmail(String email){
        slackProfile = new Profile();
        slackProfile.image_192 = 'http://bitwiseindustries.com';
        slackProfile.email = 'test@example.com';
        //TODO: Change variables on slackProfile
        userId = 'ABCDEF';
    }
    public override void getProfileFromUserId(String slackUserId){
        slackProfile = new Profile();
        slackProfile.image_192 = 'http://bitwiseindustries.com';
        slackProfile.email = 'test@example.com';
        slackProfile.display_name = 'AwesomeGuy';
        userId = 'ABCDEF';
    }

    public override Contact addContactSlackFieldsFromProfileUsingEmail(){ 
        Contact c = [SELECT Id, Slack_Email_Address__c, Slack_Id__c, Slack_Image__c FROM Contact LIMIT 1];
        c.Slack_Email_Address__c = 'test@example.com';
        c.Slack_Id__c = 'ABCDEF';
        c.Slack_Image__c = 'http://bitwiseindustries.com';
        return c;
    }

    public override Contact updateContactSlackFieldsFromProfileAndUserId(){
        Contact c = [SELECT Id, Slack_Email_Address__c, Slack_Id__c, Slack_Image__c FROM Contact LIMIT 1];
        c.Slack_Email_Address__c = 'test@example.com';
        c.Slack_Id__c = 'ABCDEF';
        c.Slack_Image__c = 'http://bitwiseindustries.com';
        c.Slack_Handle__c = 'AwesomeGuy';
        return c;

    }

}