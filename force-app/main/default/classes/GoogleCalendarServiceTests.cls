@isTest
public class GoogleCalendarServiceTests {
    private final static DateTime start = Datetime.newInstance(2019, 9, 16);
    private final static DateTime finish = start.addDays(1);

    @isTest
    public static void testGetCalendarEvents() {

        Test.setMock(HttpCalloutMock.class, new GoogleCalendarServiceCalloutMock());

        Test.startTest();
        List<GoogleCalendarService.CalendarEvent> result = GoogleCalendarService.getInstance().getCalendarEvents('Test_Calendar_Id', start, finish);
        Test.stopTest();

        System.assertEquals(2, result.size());
    }

    @isTest
    public static void testGetAvailableTimes() {
        Test.setMock(HttpCalloutMock.class, new GoogleCalendarServiceCalloutMock());
        
        Test.startTest();
        List<DateTime> result = GoogleCalendarService.getInstance().getAvailableTimes('Test_Calendar_Id', Date.newInstance(2019,9,16), 120);
        Test.stopTest();

        System.assertEquals(38, result.size());

    }

    @isTest
    public static void testCreateCalendarEvent() {
        Test.setMock(HttpCalloutMock.class, new GoogleCalendarServiceCalloutMock());
        
        Test.startTest();
        GoogleCalendarService.getInstance().createCalendarEvent('Test_Calendar_Id',start,start.addHours(2),'Test User');
        Test.stopTest();
    }
    
}