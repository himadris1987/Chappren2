public class ContactTriggerHandler extends TriggerHandler {
    private List<Contact> newList;
	private List<Contact> oldList;
	private Map<Id, Contact> newMap;
	private Map<Id, Contact> oldMap;

	public override void setupNewList() {
		newList = (List<Contact>) newSObjList;
	}

	public override void setupOldList() {
		oldList = (List<Contact>) oldSObjList;
	}

	public override void setupNewMap() {
		newMap = new Map<Id, Contact>(newList);
	}

	public override void setupOldMap() {
		oldMap = new Map<Id, Contact>(oldList);
	}

	public override void onAfterUpdate() {
		
		Set<Id> contactIdsSlack = new Set<Id>();
        
		//We only want to operate on the contacts who's Slack ID/Email has changed.
		for (Contact cont : newList) {
			Contact old = oldMap.get(cont.Id);
            
			if(cont.Slack_Email_Address__c != old.Slack_Email_Address__c || cont.Slack_Id__c != old.Slack_Id__c) {
                contactIdsSlack.add(cont.id);
            }
		}

		if (contactIdsSlack.size() > 0) {
			runSlackBatch(contactIdsSlack);
		}
	}

	public override void onAfterInsert() {
		Set<Id> contactIdsSlack = new Set<Id>();

		//We only want to operate on the contacts who's Customer ID has changed.
		for (Contact cont : newList) {

			if( !String.isBlank(cont.Slack_Email_Address__c) || !String.isBlank(cont.Slack_Id__c)){
                contactIdsSlack.add(cont.id);
            }
		}

		if (contactIdsSlack.size() > 0) {
			runSlackBatch(contactIdsSlack);
		}    
	}
    
    private void runSlackBatch(Set<Id> contactIds) {
		SlackBatchUpdate b = new SlackBatchUpdate();
		b.contactIds = contactIds;

		if (!System.isBatch()) {
			Database.executeBatch(b, 1);
		}
	}
}