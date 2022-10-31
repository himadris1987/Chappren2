@isTest
private class TriggerHandlerTests {
	static testMethod void testHandleBeforeInsert() {
		Lead l1 = new Lead();
		List<Lead> leads = new List<Lead> { l1 };

		TestTriggerHandler tth = (TestTriggerHandler) TriggerHandler.newInstance(TestTriggerHandler.class, true, false, true, false, false, false, leads, null);
		
		System.assertEquals(true, tth.isBefore);
		System.assertEquals(false, tth.isAfter);
		System.assertEquals(true, tth.isInsert);
		System.assertEquals(false, tth.isUpdate);
		System.assertEquals(false, tth.isDelete);
		System.assertEquals(false, tth.isUndelete);
		System.assertNotEquals(null, tth.newSObjList);
		System.assertEquals(null, tth.oldSObjList);

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
		
		tth.execute();

		System.assertEquals(true, tth.onApplyDefaultsExecuted);
		System.assertEquals(true, tth.onValidateExecuted);
		System.assertEquals(true, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
	}

	static testMethod void testHandleBeforeUpdate() {
		Lead l1 = new Lead();
		List<Lead> leads = new List<Lead> { l1 };

		TestTriggerHandler tth = (TestTriggerHandler) TriggerHandler.newInstance(TestTriggerHandler.class, true, false, false, true, false, false, leads, leads);
		
		System.assertEquals(true, tth.isBefore);
		System.assertEquals(false, tth.isAfter);
		System.assertEquals(false, tth.isInsert);
		System.assertEquals(true, tth.isUpdate);
		System.assertEquals(false, tth.isDelete);
		System.assertEquals(false, tth.isUndelete);
		System.assertNotEquals(null, tth.newSObjList);
		System.assertNotEquals(null, tth.oldSObjList);

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
		
		tth.execute();

		System.assertEquals(true, tth.onApplyDefaultsExecuted);
		System.assertEquals(true, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(true, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
	}

	static testMethod void testHandleBeforeDelete() {
		Lead l1 = new Lead();
		List<Lead> leads = new List<Lead> { l1 };

		TestTriggerHandler tth = (TestTriggerHandler) TriggerHandler.newInstance(TestTriggerHandler.class, true, false, false, false, true, false, null, leads);
		
		System.assertEquals(true, tth.isBefore);
		System.assertEquals(false, tth.isAfter);
		System.assertEquals(false, tth.isInsert);
		System.assertEquals(false, tth.isUpdate);
		System.assertEquals(true, tth.isDelete);
		System.assertEquals(false, tth.isUndelete);
		System.assertEquals(null, tth.newSObjList);
		System.assertNotEquals(null, tth.oldSObjList);

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
		
		tth.execute();

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(true, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
	}

	static testMethod void testHandleAfterInsert() {
		Lead l1 = new Lead();
		List<Lead> leads = new List<Lead> { l1 };

		TestTriggerHandler tth = (TestTriggerHandler) TriggerHandler.newInstance(TestTriggerHandler.class, false, true, true, false, false, false, leads, null);
		
		System.assertEquals(false, tth.isBefore);
		System.assertEquals(true, tth.isAfter);
		System.assertEquals(true, tth.isInsert);
		System.assertEquals(false, tth.isUpdate);
		System.assertEquals(false, tth.isDelete);
		System.assertEquals(false, tth.isUndelete);
		System.assertNotEquals(null, tth.newSObjList);
		System.assertEquals(null, tth.oldSObjList);

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
		
		tth.execute();

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(true, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
	}

	static testMethod void testHandleAfterUpdate() {
		Lead l1 = new Lead();
		List<Lead> leads = new List<Lead> { l1 };

		TestTriggerHandler tth = (TestTriggerHandler) TriggerHandler.newInstance(TestTriggerHandler.class, false, true, false, true, false, false, leads, leads);
		
		System.assertEquals(false, tth.isBefore);
		System.assertEquals(true, tth.isAfter);
		System.assertEquals(false, tth.isInsert);
		System.assertEquals(true, tth.isUpdate);
		System.assertEquals(false, tth.isDelete);
		System.assertEquals(false, tth.isUndelete);
		System.assertNotEquals(null, tth.newSObjList);
		System.assertNotEquals(null, tth.oldSObjList);

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
		
		tth.execute();

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(true, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
	}

	static testMethod void testHandleAfterDelete() {
		Lead l1 = new Lead();
		List<Lead> leads = new List<Lead> { l1 };

		TestTriggerHandler tth = (TestTriggerHandler) TriggerHandler.newInstance(TestTriggerHandler.class, false, true, false, false, true, false, null, leads);
		
		System.assertEquals(false, tth.isBefore);
		System.assertEquals(true, tth.isAfter);
		System.assertEquals(false, tth.isInsert);
		System.assertEquals(false, tth.isUpdate);
		System.assertEquals(true, tth.isDelete);
		System.assertEquals(false, tth.isUndelete);
		System.assertEquals(null, tth.newSObjList);
		System.assertNotEquals(null, tth.oldSObjList);

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
		
		tth.execute();

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(true, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
	}

	static testMethod void testHandleAfterUndelete() {
		Lead l1 = new Lead();
		List<Lead> leads = new List<Lead> { l1 };

		TestTriggerHandler tth = (TestTriggerHandler) TriggerHandler.newInstance(TestTriggerHandler.class, false, true, false, false, false, true, leads, null);
		
		System.assertEquals(false, tth.isBefore);
		System.assertEquals(true, tth.isAfter);
		System.assertEquals(false, tth.isInsert);
		System.assertEquals(false, tth.isUpdate);
		System.assertEquals(false, tth.isDelete);
		System.assertEquals(true, tth.isUndelete);
		System.assertNotEquals(null, tth.newSObjList);
		System.assertEquals(null, tth.oldSObjList);

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(false, tth.onAfterUndeleteExecuted);
		
		tth.execute();

		System.assertEquals(false, tth.onApplyDefaultsExecuted);
		System.assertEquals(false, tth.onValidateExecuted);
		System.assertEquals(false, tth.onBeforeInsertExecuted);
		System.assertEquals(false, tth.onBeforeUpdateExecuted);
		System.assertEquals(false, tth.onBeforeDeleteExecuted);
		System.assertEquals(false, tth.onAfterInsertExecuted);
		System.assertEquals(false, tth.onAfterUpdateExecuted);
		System.assertEquals(false, tth.onAfterDeleteExecuted);
		System.assertEquals(true, tth.onAfterUndeleteExecuted);
	}

	public class TestTriggerHandler extends TriggerHandler {
		@TestVisible private Boolean onApplyDefaultsExecuted = false;
		@TestVisible private Boolean onValidateExecuted = false;
		@TestVisible private Boolean onBeforeInsertExecuted = false;
		@TestVisible private Boolean onBeforeUpdateExecuted = false;
		@TestVisible private Boolean onBeforeDeleteExecuted = false;
		@TestVisible private Boolean onAfterInsertExecuted = false;
		@TestVisible private Boolean onAfterUpdateExecuted = false;
		@TestVisible private Boolean onAfterDeleteExecuted = false;
		@TestVisible private Boolean onAfterUndeleteExecuted = false;

		public override void setupNewList() {}
		public override void setupOldList() {}
		public override void setupNewMap() {}
		public override void setupOldMap() {}

		public override void onApplyDefaults() {
			onApplyDefaultsExecuted = true;
			super.onApplyDefaults();
		}

		public override void onValidate() {
			onValidateExecuted = true;
			super.onValidate();
		}

		public override void onBeforeInsert() {
			onBeforeInsertExecuted = true;
			super.onBeforeInsert();
		}

		public override void onBeforeUpdate() {
			onBeforeUpdateExecuted = true;
			super.onBeforeUpdate();
		}

		public override void onBeforeDelete() {
			onBeforeDeleteExecuted = true;
			super.onBeforeDelete();
		}

		public override void onAfterInsert() {
			onAfterInsertExecuted = true;
			super.onAfterInsert();
		}

		public override void onAfterUpdate() {
			onAfterUpdateExecuted = true;
			super.onAfterUpdate();
		}

		public override void onAfterDelete() {
			onAfterDeleteExecuted = true;
			super.onAfterDelete();
		}

		public override void onAfterUndelete() {
			onAfterUndeleteExecuted = true;
			super.onAfterUndelete();
		}
	}	
}