public class MembershipChargeSchedulable implements Schedulable{
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new StripeMembershipChargeBatch(), 1);
    }
}