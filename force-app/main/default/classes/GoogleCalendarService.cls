public virtual class GoogleCalendarService {
    static final String dtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss.SSSZ';
    static final Integer blockLength = 30; //The length of reservable time-blocks, in minutes.

    @TestVisible private static GoogleCalendarService instance = null;
    public static GoogleCalendarService getInstance() {
        if (instance == null) {
            instance = new GoogleCalendarService();
        }

        return instance;
    }

    public virtual List<CalendarEvent> getCalendarEvents(String calendarId, DateTime start, DateTime finish) {
        return getCalendarEvents(calendarId, start, finish, 0);
    }

    public virtual List<CalendarEvent> getCalendarEvents(String calendarId, DateTime start, DateTime finish, Integer extraMinutes) {
        String startStr = start.format(dtFormat);
        String finishStr = finish.addMinutes(extraMinutes).format(dtFormat);

        System.debug(startStr);
        System.debug(finishStr);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Google_Calendar/calendars/' + calendarId + '/events?singleEvents=true&timeMin='+startStr+'&timeMax='+finishStr);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');

        HttpResponse resp = new Http().send(req);

        CalendarResponse response = (CalendarResponse)JSON.deserialize(resp.getBody().replace('"end"','"finish"'), CalendarResponse.class);

        System.debug(resp.getBody());

        for (CalendarEvent ce : response.items) {
            ce.parse();
            System.debug(ce.startDt);
        }
        
        return response.items;        
    }

    public virtual void createCalendarEvent(String calendarId, DateTime start, DateTime finish, String summary) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Google_Calendar/calendars/'+calendarId+'/events');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        TimeZone tz = UserInfo.getTimeZone();
        Integer offset = tz.getOffset(start) / (60 * 1000);
        start = start.addMinutes(-1 * offset);
        finish = finish.addMinutes(-1 * offset);

        String body = '{' +
                      '    "start": {' +
                      '        "dateTime": "' + createRFCString(start) + '"' +
                      '    }, ' +
                      '    "end": {' +
                      '        "dateTime": "' + createRFCString(finish) + '"' +
                      '    }, ' +
                      '    "summary": "' + summary + '"' +
                      '}';

        req.setBody(body);

        System.debug(body);

        HttpResponse resp = new Http().send(req);

        System.debug(resp.getStatusCode());
        System.debug(resp.getBody());
    }

    public virtual List<CalendarEvent> getBlocks(DateTime start, DateTime finish, Integer blockLength) {
        return getBlocks(start, finish, blockLength, 0);
    }

    public virtual List<CalendarEvent> getBlocks(DateTime start, DateTime finish, Integer blockLength, Integer extraMinutes) {
        Long ms = finish.getTime() - start.getTime() + (extraMinutes * 60 * 1000);
        Integer minutes = (Integer)(ms/(1000 * 60));
        Integer blockAmount = minutes/blockLength;
        List<CalendarEvent> output = new List<CalendarEvent>();

        for (Integer i = 0; i < blockAmount; ++i) {
            CalendarEvent e = new CalendarEvent();
            e.startDt = start;
            e.finishDt = start.addMinutes(blockLength);
            start = e.finishDt;
            output.add(e);
        }

        return output;

    }

    public virtual Boolean blocksConflict(CalendarEvent a, CalendarEvent b) {
        if (a.startDt >= b.finishDt || b.startDt >= a.finishDt) {
            //If a starts after b ends or vice versa, they don't conflict.
            return false;
        }
        return true;
    }

    //Take the data from existing events (from the calendar) and all possible events on that date
    // to create a list of blocks, with status filled.
    public virtual List<CalendarEvent> getStatusBlocks(String calendarId, Date d, Integer extraMinutes) {
        DateTime start =  Datetime.NewInstance(d.year(), d.month(), d.day(), 0,0,0);
        DateTime finish =  Datetime.NewInstance(d.year(), d.month(), d.day(), 0, 0, 0).addDays(1);
        List<CalendarEvent> existing = getCalendarEvents(calendarId, start, finish, extraMinutes);
        List<CalendarEvent> possible = getBlocks(start,finish, blockLength, extraMinutes);

        List<CalendarEvent> output = new List<CalendarEvent>();

        //Loop through the "possible" timeslots, and see if any of the existing bookings conflict.
        for (CalendarEvent possibleCE : possible) {
            Boolean booked = false;
            for (CalendarEvent existingCE : existing) {
                if (blocksConflict(possibleCE, existingCE)) {
                    booked = true;
                } 
            }

            if (booked) {
                possibleCE.roomStatus = 'booked';
            } else {
                possibleCE.roomStatus = 'free';
            }

            output.add(possibleCE);
        }

        return output;
    }


    public virtual List<CalendarEvent> getTimeAmounts(String calendarId, Date d) {
        return getTimeAmounts(calendarId, d, 0);
    }

    //On each incoming CalendarEvent, determine how much time would be available starting with that block. 
    // i.e. If a room isn't booked until 10am, the 8am block would show 2 hours, the 8:30 block showing 1.5 hours, etc.
    public virtual List<CalendarEvent> getTimeAmounts(String calendarId, Date d, Integer extraMinutes) {
        List<CalendarEvent> timeline = getStatusBlocks(calendarId, d, extraMinutes);

        List<CalendarEvent> tempList = new List<CalendarEvent>();

        for (CalendarEvent ce : timeline) {            
            if (ce.roomStatus == 'free') {
                for (CalendarEvent tempce : tempList) {
                    tempce.freeTime += blockLength;
                }

                ce.freeTime = blockLength;
                tempList.add(ce);
            } else {
                tempList = new List<CalendarEvent>();
            }
        }

        return timeline;
    }
    
    public virtual List<DateTime> getAvailableTimes(String calendarId, Date d, Integer meetingLength) {
        List<CalendarEvent> timeline = getTimeAmounts(calendarId, d, meetingLength);
        List<DateTime> output = new List<DateTime>();

        for (CalendarEvent ce : timeline) {
            System.debug(ce.startDt);
            System.debug(ce.freeTime);
            if (ce.freeTime >= meetingLength && ce.startDt.date() == d) {
                output.add(ce.startDt);
            }
        }

        return output;
    }

    public static DateTime parseDateTime(String dt) {
        //Google passes Date/Time with a timezone adjustment, so deal with that.
        String tz = dt.subString(19,22); //Get the timezone adjustment ('-07')
        Integer adjustment = Integer.valueOf(tz);
        return Datetime.valueOfGmt(dt.substring(0, dt.length()-6).replace('T',' ')).addHours(-1 * adjustment);
    }

    public static String createRFCString(DateTime dt) {
        // dt = DateTime.newInstanceGmt(
        //     dt.Year(),
        //     dt.Month(),
        //     dt.Day(),
        //     dt.Hour(),
        //     dt.Minute(),
        //     0
        // );
        
        return String.format(
            '{0}-{1}-{2}T{3}:{4}:00Z',
            new String[]{
                String.valueOf(dt.Year()),
                String.valueOf(dt.Month()),
                String.valueOf(dt.Day()),
                String.valueOf(dt.Hour()),
                String.valueOf(dt.Minute())
            }
        );
    }

    public class CalendarEvent {
        public Map<String, String> start;
        public Map<String, String> finish;
        public String calendarId;
        public String summary;
        public DateTime startDt;
        public DateTime finishDt;
        public String roomStatus;
        public Integer freeTime;

        public void parse() {
            String startStr = start.get('dateTime');
            startDt = parseDateTime(startStr);
            // startDt = Datetime.valueOfGmt(startStr.substring(0, startStr.length()-6).replace('T',' '));
            String finishStr = finish.get('dateTime');
            finishDt = parseDateTime(finishStr);
        }

        public DateTime parseDateTime(string dt) {
            return GoogleCalendarService.parseDateTime(dt);
        }

        
    }

    public class CalendarResponse {
        public List<CalendarEvent> items;
    }

}