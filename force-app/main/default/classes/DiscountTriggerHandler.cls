public class DiscountTriggerHandler extends TriggerHandler {
    private List<Discount__c> newList;
	private List<Discount__c> oldList;
	private Map<Id, Discount__c> newMap;
	private Map<Id, Discount__c> oldMap;

	public override void setupNewList() {
		newList = (List<Discount__c>) newSObjList;
	}

	public override void setupOldList() {
		oldList = (List<Discount__c>) oldSObjList;
	}

	public override void setupNewMap() {
		newMap = new Map<Id, Discount__c>(newList);
	}

	public override void setupOldMap() {
		oldMap = new Map<Id, Discount__c>(oldList);
	}

    public override void onAfterInsert() {
        //Insert all new discounts.
        StripeDiscountUpdateBatch batch = new StripeDiscountUpdateBatch();
        batch.discountIds = idsToUpload(newList);
        batch.mode = 'insert';
        if (!System.isBatch()) {
            Database.executeBatch(batch,1);
        }
    }

    public override void onAfterUpdate() {
        //If any fields have changed, update that record in Stripe.
        Set<Id> toUpdate = new Set<Id>();

        for (Discount__c discount : newList) {
            Discount__c old = oldMap.get(discount.Id);

            if (discount.Name != old.Name && !discount.Gift_Membership__c) {
                toUpdate.add(discount.Id);
            }
        }

        StripeDiscountUpdateBatch batch = new StripeDiscountUpdateBatch();
        batch.discountIds = toUpdate;
        batch.mode = 'update';
        if (!System.isBatch()) {
            Database.executeBatch(batch,1);
        }
    }

    public override void onAfterDelete() {
        StripeDiscountUpdateBatch batch = new StripeDiscountUpdateBatch();
        batch.discountIds = idsToUpload(oldList);
        batch.mode = 'delete';
        if (!System.isBatch()) {
            Database.executeBatch(batch,1);
        }
    }

    public Set<Id> idsToUpload(List<Discount__c> discounts) {
        Set<Id> output = new Set<Id>();

        for (Discount__c discount : discounts) {
            if (!discount.Gift_Membership__c) {
                output.add(discount.Id);
            }
        }

        return output;
    }
}