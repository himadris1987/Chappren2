public class GoogleCalendarReservationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public Set<Id> reservationIds;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.assertNotEquals(null, reservationIds, 'reservationIds in GoogleCalendarReservationBatch is null.');

        String query = 'SELECT Id, Space__r.Calendar_Id__c, Contact__r.Name, Start__c, End__c FROM Reservation__c WHERE Id IN :reservationIds';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Reservation__c> reservations) {
        for (Reservation__c res : reservations) {
            GoogleCalendarService.getInstance().createCalendarEvent(res.Space__r.Calendar_Id__c, res.Start__c, res.End__c, res.Contact__r.Name);
        }
    }

    public void finish(Database.BatchableContext BC) {}
}