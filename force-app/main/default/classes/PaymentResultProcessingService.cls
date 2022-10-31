public class PaymentResultProcessingService {

    public static Payment_Result__c upsertPaymentResult(Payment_Result__c input) {
        //If we're updating an existing Payment Result.
        Payment_Result__c existing;
        if (input.Id != null) {
            existing = [SELECT Id, Amount__c, Charge_ID__c, Contact__c, Customer_ID__c, Gateway__c, Invoice_ID__c, Receipt_URL__c, Membership__c, Status__c, Subscription_ID__c FROM Payment_Result__c WHERE Id = :input.Id];
        } else if (input.Charge_ID__c != null) {
            List<Payment_Result__c> existingList = [SELECT Id, Amount__c, Charge_ID__c, Contact__c, Customer_ID__c, Gateway__c, Invoice_ID__c, Receipt_URL__c, Membership__c, Status__c, Subscription_ID__c FROM Payment_Result__c WHERE Charge_ID__c = :input.Charge_ID__c];

            if (existingList.size() > 0) {
                existing = existingList[0];
            } else {
                insert input;
                return input;
            }
        } else {
            //There isn't a payment result that matches, so insert and return.
            insert input;
            return input;
        }
        //Copy over every field from input if there is one.
        if (input.Amount__c != null) {
            existing.Amount__c = input.Amount__c;
        }

        if (input.Gateway__c != null) {
            existing.Gateway__c = input.Gateway__c;
        }

        if (input.Charge_ID__c != null) {
            existing.Charge_ID__c = input.Charge_ID__c;
        }

        if (input.Contact__c != null) {
            existing.Contact__c = input.Contact__c;
        }

        if (input.Customer_ID__c != null) {
            existing.Customer_ID__c = input.Customer_ID__c;
        }

        if (input.Invoice_ID__c != null) {
            existing.Invoice_ID__c = input.Invoice_ID__c;
        }

        if (input.Membership__c != null) {
            existing.Membership__c = input.Membership__c;
        }

        if (input.Receipt_URL__c != null) {
            existing.Receipt_URL__c = input.Receipt_URL__c;
        }

        if (input.Status__c != null) {
            existing.Status__c = input.Status__c;
        }

        if (input.Subscription_ID__c != null) {
            existing.Subscription_ID__c = input.Subscription_ID__c;
        }

        if (input.Registration__c != null) {
            existing.Registration__c = input.Registration__c;
        }

        update existing;
        return existing;
    }

}