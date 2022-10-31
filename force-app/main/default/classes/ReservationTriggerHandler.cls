public class ReservationTriggerHandler extends TriggerHandler {
    private List<Reservation__c> newList;
	private List<Reservation__c> oldList;
	private Map<Id, Reservation__c> newMap;
	private Map<Id, Reservation__c> oldMap;

	public override void setupNewList() {
		newList = (List<Reservation__c>) newSObjList;
	}

	// public override void setupOldList() {
	// 	oldList = (List<Reservation__c>) oldSObjList;
	// }

	public override void setupNewMap() {
		newMap = new Map<Id, Reservation__c>(newList);
	}

	// public override void setupOldMap() {
	// 	oldMap = new Map<Id, Reservation__c>(oldList);
	// }

    public override void onAfterInsert() {
        GoogleCalendarReservationBatch b = new GoogleCalendarReservationBatch();
        b.reservationIds = newMap.keySet();
        Database.executeBatch(b,1);
    }

	public override void onBeforeInsert() {
		List<Reservation__c> toInsert = new List<Reservation__c>();

		for (Reservation__c res : newList) {
			//If it's an "overnight" reservation (split across midnight), split it into two.
			Datetime localStartTime = (res.Start__c);
			Datetime localEndTime = (res.End__c);
			System.debug('local times: ');
			System.debug(localStartTime);
			System.debug(localEndTime);
			Date localStartDate = localStartTime.date();
			Date localEndDate = localEndTime.date();

			System.debug(localStartDate);
			System.debug(localEndDate);
			if (localStartDate != localEndDate && (localStartTime.minute() > 0 || localEndTime.hour() > 0)) {
				System.debug('over midnight');
				DateTime tempEnd = res.End__c;
				res.End__c = Datetime.newInstance(res.End__c.year(), res.End__c.month(), res.End__c.day());
				
				Reservation__c newRes = res.clone(false, true, false, false);
				newRes.Start__c = res.End__c;
				newRes.End__c = tempEnd;

				toInsert.add(newRes);
			}
		}

		System.debug(toInsert);

		insert toInsert;
	}

	public DateTime gmtToLocal(Datetime input) {
		Integer offset = UserInfo.getTimezone().getOffset(input);
		Datetime local = input.addSeconds(offset/1000);
		return local;
	}

	public Date getDate(Datetime dt) {
		return date.newInstance(dt.year(), dt.month(), dt.day());
	}

}