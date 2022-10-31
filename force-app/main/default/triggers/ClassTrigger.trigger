trigger ClassTrigger on Class__c (after insert) {
    WFT_Custom_Settings__c customSetting =  WFT_Custom_Settings__c.getOrgDefaults();
    System.debug(customSetting);
    if (customSetting.Enable_Class_Trigger__c) {
        TriggerHandler.handleTrigger(ClassTriggerHandler.class);
    }
}