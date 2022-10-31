public class StripeMembershipChargeBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    static Map<Id, Decimal> chargeByMembership;

    public static final String DEPARTMENT = 'Cowork';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Running StripeMembershipChargeBatch.start()');
        chargeByMembership = getChargeAmounts(Date.today().addDays(-1)); //Charge for yesterday.
        Set<Id> memberships = chargeByMembership.keySet();
        System.debug('Charging for: '+memberships);
        String query = 'SELECT Name, Id, Contact__c, Contact__r.Cowork_Stripe_Customer_Id__c, Stripe_Subscription_Id__c FROM Membership__c WHERE Id IN :memberships'; 
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Membership__c> memberships) {
        System.debug('Running StripeMembershipChargeBatch.execute()');
        Date relevantDate = Date.today().addDays(-1);
        chargeByMembership = getChargeAmounts(relevantDate); //Charge for yesterday.
        System.debug('Starting charges.');
        for (Membership__c membership : memberships) {
            String stripeId = membership.Contact__r.Cowork_Stripe_Customer_Id__c;
            Decimal amount = chargeByMembership.get(membership.Id);
            System.debug('Charging '+membership.Id + ' $'+String.valueOf(amount));
            String chargeId = StripePaymentService.getInstance().chargeCustomer(DEPARTMENT, stripeId, null, amount, 'Conference Room Booking Fee');


            Payment_Result__c result = new Payment_Result__c(
                Membership__c = membership.Id,
                Charge_ID__c = chargeId,
                Contact__c = membership.Contact__c,
                Customer_ID__c = membership.Contact__r.Cowork_Stripe_Customer_Id__c,
                Subscription_ID__c = membership.Stripe_Subscription_Id__c,
                Source__c = 'End-Of-Day Charges'
            );

            if(chargeId.contains('error')) {
                result.Status__c = 'error';
            } else {
                result.Status__c = 'success';

                List<Reservation__c> reservations = [SELECT Id, Membership__c, Room_Type_Formula__c, Start__c, End__c, Start_Date__c, Length__c 
                                             FROM Reservation__c 
                                             WHERE Start_Date__c = :relevantDate AND
                                                   Status__c = 'Active' AND
                                                   Membership__c = :membership.Id];
                
                for (Reservation__c res : reservations) {
                    res.Status__c = 'Charged';
                }

                update reservations;
            }

            PaymentResultProcessingService.upsertPaymentResult(result);
        }
        System.debug('Done charging.');
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Running StripeMembershipChargeBatch.finish()');
    }

    /**
     * Pulls all important reservations and the price of them.
     */
    public Map<Id, Decimal> getChargeAmounts(Date day) {
        System.debug('Getting Charge Amounts for ' + string.valueOf(day));


        //Get reservations relating to today, and add up the amount of time they spend in each type of room.
        Map<Id, Integer> conferenceMinutes = new Map<Id, Integer>(); //Maps the ID of the membership to the amount that member spent in a conference room.
        Map<Id, Integer> podcastMinutes = new Map<Id, Integer>(); //Maps the ID of the membership to the amount that member spent in a podcast booth.
        Set<Id> memberIds = new Set<Id>();


        List<Reservation__c> reservations = [SELECT Id, Membership__c, Room_Type_Formula__c, Start__c, End__c, Start_Date__c, Length__c 
                                             FROM Reservation__c 
                                             WHERE Start_Date__c = :day AND
                                                   Status__c = 'Active'];

        System.debug('Iterating through reservations.');

        for (Reservation__c reservation : reservations) {
            System.debug('----- ' + reservation);
            Id memberId = reservation.Membership__c;
            memberIds.add(memberId);

            if (reservation.Room_Type_Formula__c == 'Conference Room') {

                //If the member isn't in the map, put them there.
                if (!conferenceMinutes.containsKey(memberId)) {
                    conferenceMinutes.put(memberId, 0);
                }

                conferenceMinutes.put(memberId, (Integer)(conferenceMinutes.get(memberId)+reservation.Length__c));

            } else if (reservation.Room_Type_Formula__c == 'Podcast Booth') {

                //If the member isn't in the map, put them there.
                if (!podcastMinutes.containsKey(memberId)) {
                    podcastMinutes.put(memberId, 0);
                }

                podcastMinutes.put(memberId, (Integer)(podcastMinutes.get(memberId)+reservation.Length__c));
            }
        }

        System.debug('Done iterating through reservations.');
        System.debug('----- MemberIds' + memberIds);
        System.debug('----- Conference Minutes: ' + conferenceMinutes);
        System.debug('----- Podcast Minutes: '+ podcastMinutes);

        Map<Id, Decimal> output = new Map<Id, Decimal>();

        //Query for memberships so you can charge appropriately.
        Map<Id, Membership__c> memberships = new Map<Id, Membership__c>([SELECT Id, Type__c, Contact__r.Cowork_Member__c FROM Membership__c WHERE Id IN :memberIds]);


        System.debug('Iterating through memberships.');
        for (Id memberId : memberIds) {
            Decimal amount = 0;
            Boolean isMember = memberships.get(memberId).Contact__r.Cowork_Member__c;
            Boolean isGroup = memberships.get(memberId).Type__c == 'Group' ? true : false;

            System.debug('Member '+memberId+' is member = ' + String.valueOf(isMember) + 'is Group = ' + String.valueOf(isGroup));

            if (conferenceMinutes.containsKey(memberId)) {
                System.debug('Conference Minutes: ' + conferenceMinutes.get(memberId));
                //If Group they get 4 free hours a day not 1
                if ( conferenceMinutes.get(memberId) > 240 && isMember && isGroup){
                    amount += (((Decimal)conferenceMinutes.get(memberId) - 240)/60) * Constants.conferenceRoomMemberPrice;
                    
                } else if (conferenceMinutes.get(memberId) > 60 && isMember && !isGroup) {
                    //If they book more than an hour, take 60 minutes off their booking and charge the correct amount. 
                    amount += (((Decimal)conferenceMinutes.get(memberId) - 60)/60) * Constants.conferenceRoomMemberPrice;
                } else if (!isMember) {
                    amount += (((Decimal)conferenceMinutes.get(memberId))/60) * Constants.conferenceRoomNonMemberPrice;
                }
            }

            if (podcastMinutes.containsKey(memberId)) {
                System.debug('Podcast Minutes: ' + podcastMinutes.get(memberId));
                Decimal chargeNumber = isMember? Constants.podcastBoothMemberPrice : Constants.podcastBoothNonMemberPrice;
                amount += ((Decimal)podcastMinutes.get(memberId)/180) * chargeNumber;
            }

            if (amount > 0) {
                output.put(memberId, amount);
            }
        }

        return output;
    }
}