trigger ReservationTrigger on Reservation__c (before insert, after insert) {
    TriggerHandler.handleTrigger(ReservationTriggerHandler.class);
}