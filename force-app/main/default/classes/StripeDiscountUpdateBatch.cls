public class StripeDiscountUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Set<Id> discountIds;
    public string mode;

    public static String department = 'Cowork';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.assertNotEquals(null, discountIds, 'discountIds in StripeDiscountUpdateBatch is null.');

        String query = 'SELECT Code__c, Amount_Off__c, Name, Duration_In_Months__c, Duration__c, Redeem_By__c, Max_Redemptions__c, Id FROM Discount__c WHERE Id IN :discountIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Discount__c> discounts) {
        for (Discount__c d : discounts) {
            // if (mode == 'update') {
            //     StripePaymentService.getInstance().updateDiscount(d);
            /*} else*/ if (mode == 'insert') {
                StripePaymentService.getInstance().createDiscount(department, d);
            } else if (mode == 'delete') {
                StripePaymentService.getInstance().deleteDiscount(department, d);
            }
        }
    }

    public void finish(Database.BatchableContext BC) {}
}