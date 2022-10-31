public abstract class TriggerHandler {
	public Boolean isBefore { get; private set; }
	public Boolean isAfter { get; private set; }
	public Boolean isInsert { get; private set; }
	public Boolean isUpdate { get; private set; }
	public Boolean isDelete { get; private set; }
	public Boolean isUndelete { get; private set; }
	public List<SObject> newSObjList { get; private set; }
	public List<SObject> oldSObjList { get; private set; }

	public void setup(Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete, List<SObject> newSObjList, List<SObject> oldSObjList) {
		this.isBefore = isBefore;
		this.isAfter = isAfter;
		this.isInsert = isInsert;
		this.isUpdate = isUpdate;
		this.isDelete = isDelete;
		this.isUndelete = isUndelete;
		this.newSObjList = newSObjList;
		this.oldSObjList = oldSObjList;

		if(newSObjList != null) {
			setupNewList();

			if(!(isBefore && isInsert)) {
				setupNewMap();
			}
		}

		if(oldSObjList != null) {
			setupOldList();
			setupOldMap();
		}
	}

	public void execute() {
		if(isBefore) {
			if(isInsert) {
				handleBeforeInsert();
			} else if(isUpdate) {
				handleBeforeUpdate();
			} else if(isDelete) {
				handleBeforeDelete();
			}
		} else if(isAfter) {
			if(isInsert) {
				handleAfterInsert();
			} else if(isUpdate) {
				handleAfterUpdate();
			} else if(isDelete) {
				handleAfterDelete();
			} else if(isUndelete) {
				handleAfterUndelete();
			}
		}
	}

	public virtual void setupNewList() {}
	public virtual void setupOldList() {}
	public virtual void setupNewMap() {}
	public virtual void setupOldMap() {}

	public virtual void applyDefaults() {
		onApplyDefaults();
	}

	public virtual void validate() {
		onValidate();
	}

	public virtual void handleBeforeInsert() {
		applyDefaults();
		validate();
		onBeforeInsert();
	}

	public virtual void handleBeforeUpdate() {
		applyDefaults();
		validate();
		onBeforeUpdate();
	}

	public virtual void handleBeforeDelete() {
		onBeforeDelete();
	}

	public virtual void handleAfterInsert() {
		onAfterInsert();
	}

	public virtual void handleAfterUpdate() {
		onAfterUpdate();
	}

	public virtual void handleAfterDelete() {
		onAfterDelete();
	}

	public virtual void handleAfterUndelete() {
		onAfterUndelete();
	}

	public virtual void onApplyDefaults() {}
	public virtual void onValidate() {}
	public virtual void onBeforeInsert() {}
	public virtual void onBeforeUpdate() {}
	public virtual void onBeforeDelete() {}
	public virtual void onAfterInsert() {}
	public virtual void onAfterUpdate() {}
	public virtual void onAfterDelete() {}
	public virtual void onAfterUndelete() {}

	public static TriggerHandler newInstance(Type handlerType, Boolean isBefore, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isDelete, Boolean isUndelete, List<SObject> newSObjList, List<SObject> oldSObjList) {
		TriggerHandler th = (TriggerHandler) handlerType.newInstance();
		th.setup(isBefore, isAfter, isInsert, isUpdate, isDelete, isUndelete, newSObjList, oldSObjList);

		return th;
	}

	public static void handleTrigger(Type handlerType) {
		TriggerHandler th = TriggerHandler.newInstance(handlerType, trigger.isBefore, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete, trigger.new, trigger.old);
		th.execute();
	}
}