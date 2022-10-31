/**
 * Though this looks at Stripe IDs, all Stripe IDs are unique globally, so there will never be a collision across Stripe Accounts.
 *
 */
public class PaymentResultTriggerHandler extends TriggerHandler{
    private List<Payment_Result__c> newList;
	private List<Payment_Result__c> oldList;
	private Map<Id, Payment_Result__c> newMap;
	private Map<Id, Payment_Result__c> oldMap;

	public override void setupNewList() {
		newList = (List<Payment_Result__c>) newSObjList;
	}

	public override void setupOldList() {
		oldList = (List<Payment_Result__c>) oldSObjList;
	}

	public override void setupNewMap() {
		newMap = new Map<Id, Payment_Result__c>(newList);
	}

	public override void setupOldMap() {
		oldMap = new Map<Id, Payment_Result__c>(oldList);
	}

    public override void onBeforeInsert() {
        linkContacts();
        linkMemberships();
    }

    public override void onBeforeUpdate() {
        linkContacts();
        linkMemberships();
    }

    public void linkContacts() {
        //Link to the proper Contact.
        Set<String> customerIds = new Set<String>();
        for (Payment_Result__c res : newList) {
            if (res.Customer_ID__c != null && res.Contact__c == null) {
                customerIds.add(res.Customer_ID__c);
            }
        }

        List<Contact> conts = [SELECT Id, Cowork_Stripe_Customer_Id__c FROM Contact WHERE Cowork_Stripe_Customer_Id__c IN :customerIds];

        Map<String, Contact> contMap = new Map<String, Contact>();

        for (Contact cont : conts) {
            contMap.put(cont.Cowork_Stripe_Customer_Id__c, cont);
        }

        for (Payment_Result__c res : newList) {
            if (contMap.containsKey(res.Customer_ID__c)) {
                res.Contact__c = contMap.get(res.Customer_ID__c).Id;
            }
        }
    }

    public void linkMemberships() {
        //Link to the proper Contact.
        Set<String> subscriptionIds = new Set<String>();
        for (Payment_Result__c res : newList) {
            
            if (res.Subscription_ID__c != null && res.Membership__c == null) {
                subscriptionIds.add(res.Subscription_ID__c);
            }
        }

        List<Membership__c> conts = [SELECT Id, Stripe_Subscription_Id__c FROM Membership__c WHERE Stripe_Subscription_Id__c IN :subscriptionIds];

        Map<String, Membership__c> membershipMap = new Map<String, Membership__c>();

        for (Membership__c cont : conts) {
            membershipMap.put(cont.Stripe_Subscription_Id__c, cont);
        }

        for (Payment_Result__c res : newList) {
            if (membershipMap.containsKey(res.Subscription_ID__c)) {
                res.Membership__c = membershipMap.get(res.Subscription_ID__c).Id;
            }
        }
    }
}