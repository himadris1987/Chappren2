trigger AttachmentTrigger on Attachment (after insert, after update) {
	TriggerHandler.handleTrigger(AttachmentTriggerHandler.class);
}