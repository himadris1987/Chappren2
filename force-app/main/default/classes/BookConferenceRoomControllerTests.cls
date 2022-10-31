@isTest
public class BookConferenceRoomControllerTests {
    static BookConferenceRoomController cont;
    static Space__c conferenceRoom;
    static Space__c podcastBooth;
    static Contact contactRecord;

    public static void setup() {
        GoogleCalendarService.instance = new GoogleCalendarServiceMock();

        //Override the constants file to ensure the logic is tested the same way, regardless of constants. 
        Constants.blockLength = 30;
        Constants.maxReservationLength = 300;

        conferenceRoom = new Space__c(
            Name='Test Conference Room', 
            Cowork_Reservable__c = true, 
            Reservation_Room_Type__c = 'Conference Room', 
            Calendar_Id__c = 'Test_Calendar_Id'
        );
        podcastBooth = new Space__c(
            Name='Test Podcast Booth', 
            Cowork_Reservable__c = true, 
            Reservation_Room_Type__c = 'Podcast Booth', 
            Calendar_Id__c = 'Test_Calendar_Id'
        );
        insert new List<Space__c>{conferenceRoom, podcastBooth};

        contactRecord = new Contact(
            LastName = 'Test',
            FirstName = 'Unit',
            Email = 'unittest@example.com'
        );
        insert contactRecord;
    }

    @isTest
    public static void testSetup() {
        setup();
    }

    @isTest
    public static void testSetTimeOptions() {
        setup();

        cont = new BookConferenceRoomController();
        
        Test.startTest();
        cont.setTimeOptions();
        Test.stopTest();

        System.assertEquals(11, cont.timeOptions.size());
        System.assertEquals('0', cont.timeOptions[0].getValue());
        System.assertEquals('30', cont.timeOptions[1].getValue());
        System.assertEquals('60', cont.timeOptions[2].getValue());
    }

    @isTest
    public static void testConstructor() {
        setup();
        
        Test.startTest();
        cont = new BookConferenceRoomController();
        Test.stopTest();

        System.assertEquals(Date.today(), cont.apptDate);
        System.assertEquals('Conference Room', cont.roomType);
    }

    @isTest
    public static void testRenderFormConferenceRoom() {
        setup();

        cont = new BookConferenceRoomController();
        cont.duration=60;
        cont.roomType = 'Conference Room';
        
        Test.startTest();
        cont.renderForm();
        Test.stopTest();

        System.assertEquals(1, cont.availableTimeSlots.keySet().size());
        System.assertEquals(conferenceRoom.Id, new List<Id>(cont.availableTimeSlots.keySet())[0]);
    }

    @isTest
    public static void testRenderFormPodcastBooth() {
        setup();

        cont = new BookConferenceRoomController();
        cont.roomType = 'Podcast Booth';
        
        Test.startTest();
        cont.renderForm();
        Test.stopTest();

        System.assertEquals(180, cont.duration);
        System.assertEquals(1, cont.availableTimeSlots.keySet().size());
        System.assertEquals(podcastBooth.Id, new List<Id>(cont.availableTimeSlots.keySet())[0]);
    }

    @isTest
    public static void testSubmitFormExistingMembership() {
        setup();

        PageReference pr = Page.BookConferenceRoom;
        Date d = Date.today();
        DateTime dtObj = Datetime.newInstance(d.year(), d.month(), d.day(), 6,0,0);
        String dtString = dtObj.format('EEE MMM dd HH:mm:ss') + ' GMT ' +String.valueOf(dtObj.year());
        // pr.getParameters().put('chosen_time', conferenceRoom.Id + '.' + dtString);
        // Test.setCurrentPage(pr);

        Membership__c membership = new Membership__c(
            Contact__c = contactRecord.Id,
            Status__c = 'Active'
        );

        insert membership;



        cont = new BookConferenceRoomController();
        cont.email = 'unittest@example.com';
        cont.duration = 60;


        Test.startTest();
        String nextPr = BookConferenceRoomController.submitFormRemoting(conferenceRoom.Id + '.' + dtString, 'unittest@example.com','60');
        Test.stopTest();

        List<Reservation__c> resList = [SELECT Id, Membership__c FROM Reservation__c];


        System.assertEquals(1, resList.size());
        System.assertEquals(membership.Id, resList[0].Membership__c);
    }

    @isTest
    public static void testSubmitFormNoMembership() {
        setup();

        PageReference pr = Page.BookConferenceRoom;
        Date d = Date.today();
        DateTime dtObj = Datetime.newInstance(d.year(), d.month(), d.day(), 6,0,0);
        String dtString = dtObj.format('EEE MMM dd HH:mm:ss') + ' GMT ' +String.valueOf(dtObj.year());
        pr.getParameters().put('chosen_time', conferenceRoom.Id + '.' + dtString);
        Test.setCurrentPage(pr);

        cont = new BookConferenceRoomController();
        cont.email = 'unittest@example.com';
        cont.duration = 60;


        Test.startTest();
        String nextPr = BookConferenceRoomController.submitFormRemoting(conferenceRoom.Id + '.' + dtString, 'unittest@example.com','60');
        Test.stopTest();


        System.assert(nextPr.contains('payment'));
    }

}