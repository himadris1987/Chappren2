trigger DiscountTrigger on Discount__c (after insert, after update, after delete, after undelete) {
    TriggerHandler.handleTrigger(DiscountTriggerHandler.class);
}