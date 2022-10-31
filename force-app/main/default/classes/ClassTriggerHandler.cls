public class ClassTriggerHandler extends TriggerHandler {
    private List<Class__c> newList;
	private List<Class__c> oldList;
	private Map<Id, Class__c> newMap;
	private Map<Id, Class__c> oldMap;

	public override void setupNewList() {
		newList = (List<Class__c>) newSObjList;
	}

	public override void setupOldList() {
		oldList = (List<Class__c>) oldSObjList;
	}

	public override void setupNewMap() {
		newMap = new Map<Id, Class__c>(newList);
	}

	public override void setupOldMap() {
		oldMap = new Map<Id, Class__c>(oldList);
	}

	public override void onAfterUpdate() {

	}

	public override void onAfterInsert() {
		Set<Id> classIdsZoom = new Set<Id>();

		//We only want to operate on the Classes who are type Virtual.
		for (Class__c singleClass : newList) {
            if (singleClass.Attendance_Type__c == 'Virtual') {
            	classIdsZoom.add(singleClass.id);
                System.debug(classIdsZoom);
            }            
		}

		if (classIdsZoom.size() > 0) {
			runClassBatch(classIdsZoom);
		}    
	}
    
    private void runClassBatch(Set<Id> classIdsZoom) {
		ZoomBatchUpdate b = new ZoomBatchUpdate();
		b.classIds = classIdsZoom;
		System.debug(b.classIds);
		if (!System.isBatch()) {
            System.debug('Get Here');
			Database.executeBatch(b, 1);
		}
	}
}