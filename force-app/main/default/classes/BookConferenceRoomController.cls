global class BookConferenceRoomController {
    //Values that will get set via Visualforce.
    public String email {get;set;}
    public Date apptDate {get;set;}
    public String roomType {get;set;}
    public Integer duration{get;set;}


    //Values used in rendering the VF page
    public List<SelectOption> timeOptions {get;set;}
    public List<Space__c> availableSpaces {get;set;}
    public Map<Id, List<TimeSlot>> availableTimeSlots{get;set;}

    public String chosenString{get;set;}
    
    //Flags to decide if a redirect is needed or not. 
    public Boolean redirect{get;set;}
    public String redirectUrl{get;set;}


    public BookConferenceRoomController() {
        //Set defaults 
        apptDate = Date.today();
        redirect = false;

        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param = params.get('roomType');
        
        if(param == 'Podcast')
            roomType ='Podcast Booth';
        else
            roomType = 'Conference Room';

        setTimeOptions();
        // renderForm();
    }

    public void renderForm() {
        System.debug('Beginning renderForm');
        availableSpaces = new List<Space__c>();
        availableTimeSlots = new Map<Id, List<TimeSlot>>();
        
        if (roomType == 'Podcast Booth') {
            duration=180;
        }

        System.debug(duration);

        if (duration == 0 || duration == null) {
            return;
        }

    

        //Get a list of bookable spaces with a calendar associated.
        List<Space__c> spaces = [SELECT Id, Name, Calendar_Id__c 
                                 FROM Space__c 
                                 WHERE Cowork_Reservable__c = true AND Reservation_Room_Type__c = :roomType AND Calendar_Id__c != ''];

        for(Space__c space : spaces) {
            System.debug(space.Name);
            String calendarId = space.Calendar_Id__c;
            List<DateTime> availableTimes = GoogleCalendarService.getInstance().getAvailableTimes(calendarId, apptDate, duration);
            System.debug('Got Available Times.');
            if (availableTimes.size() == 0) {
                continue;
            }

            List<TimeSlot> slots = new List<TimeSlot>();

            for (DateTime dt : availableTimes) {
                if (dt > System.now()) {
                    TimeSlot ts = new TimeSlot();
                    ts.start = dt;
                    ts.spaceId = space.Id;
                    ts.label = dt.format('h:mm a');
                    slots.add(ts);
                }
            }

            availableSpaces.add(space);
            
            availableTimeSlots.put(space.Id, slots);

        }        

        System.debug('Finishing renderForm');
        System.debug(availableSpaces);
        System.debug(availableTimeSlots);
        
    }

    // public PageReference submitForm() {
    //     String chosen_slot = chosenString;//ApexPages.currentPage().getParameters().get('chosen_time');
    //     System.debug(chosen_slot);
    //     List<String> data = chosen_slot.split('\\.');
    //     System.debug(data);
    //     String spaceId = data[0];
    //     String chosen_time = data[1];
        
    //     System.debug(email);
    //     //Figure out if they have a membership.
    //     Map<Id, Contact> conts = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Email LIKE :email]);



    //     List<Membership__c> memberships = new List<Membership__c>();

    //     if (conts.size() > 0) {
    //         System.debug('Found contacts');
    //         memberships = [SELECT Id, Contact__c FROM Membership__c WHERE Contact__c IN :conts.keySet() AND Status__c = 'Active'];
    //     }

    //     PageReference output;
    //     if (memberships.size() > 0) {
    //         System.debug('Found memberships');
    //         Membership__c membership = memberships[0];
    //         //Parse the date from the chosen time.
    //         DateTime start = parseTime(chosen_time);
            
    //         Reservation__c res = new Reservation__c(
    //             Space__c = spaceId,
    //             Contact__c = membership.Contact__c,
    //             Membership__c = membership.Id,
    //             Status__c = 'Active',
    //             Start__c = start,
    //             End__c = start.addMinutes(duration)
    //         );

    //         insert res;

    //         System.debug('Res inserted');
    //         output = new PageReference('https://hashtagcoworkplace.com/conference-room-reserved/');
    //        
    //     } else {
    //         System.debug('Page.Payment');
    //         output = Page.Payment;
    //         output.getParameters().put('conferenceRoom','true');
    //         output.getParameters().put('conferenceLocation',spaceId);
    //         output.getParameters().put('conferenceStartTime',chosen_time);
    //         output.getParameters().put('conferenceDuration', String.valueOf(duration));
    //         output.getParameters().put('memberEmail', email);
    //     }

    //     System.debug('returning');
    //     System.debug(output);
    //     String url = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + output.getUrl();
    //     redirectUrl = url;
    //     redirect = true;
    //     System.debug(url);

    //     return output;
    // }


    @RemoteAction
    global static String submitFormRemoting(String chosen_slot, String email, String durationStr) {
        System.debug('submitFormRemoting starting');
        //String chosen_slot = chosenString;//ApexPages.currentPage().getParameters().get('chosen_time');
        Integer duration = Integer.valueOf(durationStr);
        System.debug(chosen_slot);
        List<String> data = chosen_slot.split('\\.');
        System.debug(data);
        String spaceId = data[0];
        String chosen_time = data[1];
        
        System.debug(email);
        //Figure out if they have a membership.
        Map<Id, Contact> conts = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Email LIKE :email]);



        List<Membership__c> memberships = new List<Membership__c>();

        if (conts.size() > 0) {
            System.debug('Found contacts');
            memberships = [SELECT Id, Contact__c FROM Membership__c WHERE Contact__c IN :conts.keySet() AND Status__c = 'Active'];
        }

        PageReference output;
        if (memberships.size() > 0) {
            System.debug('Found memberships');
            Membership__c membership = memberships[0];
            //Parse the date from the chosen time.
            DateTime start = parseTime(chosen_time);
            
            Reservation__c res = new Reservation__c(
                Space__c = spaceId,
                Contact__c = membership.Contact__c,
                Membership__c = membership.Id,
                Status__c = 'Active',
                Start__c = start,
                End__c = start.addMinutes(duration)
            );

            insert res;

            System.debug('Res inserted');
            output = new PageReference('https://hashtagcoworkplace.com/conference-room-reserved/');
        } else {
            System.debug('Page.Payment');
            output = Page.Payment;
            output.getParameters().put('conferenceRoom','true');
            output.getParameters().put('conferenceLocation',spaceId);
            output.getParameters().put('conferenceStartTime',chosen_time);
            output.getParameters().put('conferenceDuration', String.valueOf(duration));
            output.getParameters().put('memberEmail', email);
        }

        System.debug('returning');
        System.debug(output);
        // String url = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + output.getUrl();
        // redirectUrl = url;
        // redirect = true;
        // System.debug(url);

        return output.getUrl();
    }

    public static DateTime parseTime(String dt) {
        List<String> dtList = dt.split(' ');
        String year = dtList[5];
        String day = dtList[2];
        String month = Constants.monthToNum.get(dtList[1]);
        String ts = dtList[3];
        return DateTime.valueOfGmt(year+'-'+month+'-'+day+' '+ts);
    }

    

    public void setTimeOptions() {
        timeOptions = new List<SelectOption>();
        timeOptions.add(new SelectOption('0', '-- Duration --'));
        for (Integer i = Constants.blockLength; i <= Constants.maxReservationLength; i += Constants.blockLength) {
            String value = String.valueOf(i);
            
            Integer hours = (Integer)Math.floor(i/60);
            Integer minutes = Math.mod(i, 60);

            String label = '';

            if (hours > 0) {
                label = String.valueOf(hours) + ' hrs ';
            }

            if (minutes > 0) {
                label += String.valueOf(minutes) + ' mins';
            }


            timeOptions.add(new SelectOption(value,label));
        }
    }


    public class TimeSlot {
        public DateTime start {get;set;}
        public Id spaceId {get;set;}
        public String label {get;set;}
    }
}