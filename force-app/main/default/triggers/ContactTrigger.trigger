trigger ContactTrigger on Contact (after insert, after update) {
    TriggerHandler.handleTrigger(ContactTriggerHandler.class);
}