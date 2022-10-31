global class SlackBatchUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts {
	public Set<ID> contactIds;
    
   
    public Database.QueryLocator start(Database.BatchableContext bc) {
         
        String query = 'SELECT Name, Id, Slack_Email_Address__c, Slack_Id__c, Slack_Handle__c FROM Contact WHERE (Slack_Email_Address__c != \'\' OR Slack_Id__c != \'\') AND Id IN :contactIds';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contact> records){
        Contact emptyObj= new Contact();
        List<Contact> contsToUpdate = new List<Contact>();
        
        for(Contact c : records){
            System.debug(c);
          
            Contact toUpdate = new Contact();
            System.debug(c.Slack_Id__c);
            if(!String.isBlank(c.Slack_Id__c)){
                System.debug(c);
                SlackUsersService.getInstance().getProfileFromUserId(c.Slack_Id__c);
                toUpdate = SlackUsersService.getInstance().updateContactSlackFieldsFromProfileAndUserId();
                System.debug(toUpdate);
                
            }
            else if(!String.isBlank(c.Slack_Email_Address__c)){
                System.debug(c);
                SlackUsersService.getInstance().getUserIdAndProfileFromEmail(c.Slack_Email_Address__c);
                toUpdate = SlackUsersService.getInstance().addContactSlackFieldsFromProfileUsingEmail();
                System.debug(toUpdate);
            }
            
            if( toUpdate != null && toUpdate != emptyObj){
                System.debug(toUpdate);
                contsToUpdate.add(toUpdate);
            }
    	}

        update contsToUpdate;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }

}