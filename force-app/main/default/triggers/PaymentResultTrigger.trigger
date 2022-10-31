trigger PaymentResultTrigger on Payment_Result__c (before insert, before update) {
    TriggerHandler.handleTrigger(PaymentResultTriggerHandler.class);
}