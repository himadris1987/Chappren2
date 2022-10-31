public class TabletReservation {
    public string currentRoomId{get;set;}
    public space__c currentRoom{get;set;}
    // public list<Reservation__c> roomReservations{get;set;}
    public date getToday{get;set;}
    // public string formatedDate{get;set;}
    public List<Reservation__c> currentReservation{get;set;}
    public dateTime currentTime{get;set;}
    public Reservation__c printReservation{get;set;}


    public TabletReservation() {
        getToday = date.today();
        currentRoomId = apexpages.currentPage().getparameters().get('Id');
        getRoomInfo(currentRoomId);
        currentTime = System.now();
        // printReservation = checkCurrentReservation();
    }

    public void getRoomInfo(Id roomId) {
        // try{
            currentRoom = [SELECT Id, Name, Calendar_Link__c, Reservation_Room_Type__c FROM Space__c WHERE Id = :roomId ];
        // roomReservations = [SELECT id, name, start__c, end__c, contact__r.name FROM reservation__c WHERE space__c = :currentRoomId AND start_date__c = :getToday AND start__c > :System.now() ORDER BY start__c ASC];
        // } catch(QueryException e) {
        //     // Apexpages.addMessages(e);
        //     // testString = 'Hello from the catch block';

        // }        
    }

    // public Reservation__c checkCurrentReservation() {
    //     currentReservation = [SELECT id, name, start__c, end__c, contact__r.name FROM reservation__c WHERE space__c = :currentRoomId AND start_date__c = :getToday AND start__c <= :System.now() AND end__c > :System.now() LIMIT 1];
    //     if(currentReservation.size() > 0) {
    //         return currentReservation[0];
    //     } else {
    //         return null;
    //     }

    // }
}