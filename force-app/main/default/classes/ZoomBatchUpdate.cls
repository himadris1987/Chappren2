global class ZoomBatchUpdate implements Database.Batchable<sObject>, Database.AllowsCallouts {
	public Set<ID> classIds;
    
   
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug(classIds);

        return Database.getQueryLocator([SELECT Id, Display_Name__c, Time_Zone__c, Market__c, Section_Number__c, Class_Description__c, Class_Nights__c, Start_Date__c, End_Date__c FROM Class__c WHERE ID IN: classIds]);
    }
    global void execute(Database.BatchableContext bc, List<Class__c> records){
        System.debug(records);
        List<Class__c> classToUpdate = new List<Class__c>();
        classToUpdate = ZoomService.createMeeting(records);
    	System.debug(classToUpdate);
        update classToUpdate;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}