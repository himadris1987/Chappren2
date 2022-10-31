public class GoogleCalendarServiceMock extends GoogleCalendarService{

    public static Boolean createCalendarEventRan = false;
    public static Boolean getAvailableTimesRan = false;
    
    public override void createCalendarEvent(String calendarId, DateTime start, DateTime finish, String summary) {
        createCalendarEventRan = true;
        System.assert(start < finish);
    }

    public override List<DateTime> getAvailableTimes(String calendarId, Date d, Integer meetingLength) {
        getAvailableTimesRan = true;
        return new List<DateTime> {
            DateTime.newInstance(d.year(), d.month(), d.day(), 5, 0, 0),
            DateTime.newInstance(d.year(), d.month(), d.day(), 6, 0, 0),
            DateTime.newInstance(d.year(), d.month(), d.day(), 7, 0, 0),
            DateTime.newInstance(d.year(), d.month(), d.day(), 8, 0, 0)
        };
    }

}