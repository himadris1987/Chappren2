public class ZoomService {
    
    @InvocableMethod(callout=true label='Create Zoom Meeting From Class' description='Creates a Zoom Link and populates Zoom Link field on class.' category='Class')
    public static List<Class__c> createMeeting(List<Class__c> classes) {
        for(Class__c c : classes) {
            ZoomMeeting meeting = createZoomMeetingObject(c);
            System.debug(meeting);
            Map<String, Object> zoomResponse = createMeetingAndParseResponse(meeting);
            if(! zoomResponse.isEmpty()) {
                c.Zoom_Link__c = (String) zoomResponse.get('join_url');
                Long zoomId = (Long) zoomResponse.get('id');
                c.Zoom_Meeting_Id__c = String.valueOf(zoomId);
            }
        }
        return classes;
    }
    
    public static ZoomMeeting createZoomMeetingObject(Class__c c) {
        ZoomMeeting meeting = new ZoomMeeting();
        WFT_Custom_Settings__c customSetting =  WFT_Custom_Settings__c.getOrgDefaults();
        System.debug(customSetting.Zoom_API_User__c);
        meeting.userId = customSetting.Zoom_API_User__c;
        meeting.topic = c.Market__c + ' ' + c.Display_Name__c + ' ' + c.Time_Zone__c;
        meeting.type = 8;
        meeting.start_time = dateTime.newInstanceGmt(c.Start_Date__c, Time.newInstance(18, 0, 0, 0));
        meeting.duration = 180;
        System.debug(customSetting.Zoom_Meeting_Host__c);
        meeting.schedule_for = customSetting.Zoom_Meeting_Host__c;

        switch on c.Time_Zone__c {
            when 'Eastern' {
                meeting.timezone = 'America/New_York';
            }
            when 'Central' {
                meeting.timezone = 'America/Chicago';
            }
            when 'Mountain' {
                meeting.timezone = 'America/Denver';
            }
            when else {
                meeting.timezone = 'America/Los_Angeles';
            }
        }
        meeting.default_password = true;
        meeting.agenda = c.Class_Description__c;
        meeting.recurrence.type = 2;
        meeting.recurrence.repeat_interval = 1;
        
        switch on c.Class_Nights__c {
            when 'Monday / Wednesday' {
                meeting.recurrence.weekly_days = '2,4';
            }
            when 'Tuesday / Thursday' {
                meeting.recurrence.weekly_days = '3,5';
            }
            when 'Wednesday' {
                meeting.recurrence.weekly_days = '4';
            }
            when else {
                meeting.recurrence.weekly_days = '2,3,4,5';
            }
        }
        
        meeting.recurrence.end_date_time = dateTime.newInstanceGmt(c.End_Date__c,  Time.newInstance(21, 0, 0, 0));
        meeting.settings.host_video = false;
        meeting.settings.participant_video = false;
        meeting.settings.mute_upon_entry = true;
        meeting.settings.waiting_room = true;
        meeting.settings.alternative_hosts = customSetting.Zoom_Meeting_Alternate_Hosts__c;

        return meeting;
    }
    
    private static Map<String,Object> createMeetingAndParseResponse(ZoomMeeting meeting) {
        Map<String,Object> responseMap = new Map<String,Object>();
        HttpResponse response = createMeeting(meeting);
        System.debug(response.getStatusCode());

        if (response.getStatusCode() == 201) {
            System.debug('Success');
            responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            
        } else {
            System.debug('Failure');
            System.debug(response.getBody());
        }
        return responseMap;
    }

    private static HttpResponse createMeeting(ZoomMeeting  meeting) {
        HttpRequest req = new HttpRequest();
        WFT_Custom_Settings__c customSetting =  WFT_Custom_Settings__c.getOrgDefaults();
        req.setEndpoint('https://api.zoom.us/v2/users/' + customSetting.Zoom_API_User__c + '/meetings');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        //Custom Setting HERE
        String auth = 'Bearer ' + customSetting.Zoom_API_JWT__c;
        req.setHeader('Authorization', auth);
        String payload = JSON.serialize(meeting);
        req.setBody(payload);
        
        if ( customSetting.Most_Recent_Zoom_Meeting_API_Call__c != System.now().date()) {
            customSetting.Most_Recent_Zoom_Meeting_API_Call__c = System.now().date();
            customSetting.Daily_User_Zoom_Meeting_API_Calls__c = 0;
        }
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        customSetting.Daily_User_Zoom_Meeting_API_Calls__c++;
        update customSetting;
        return res;
    }

    // public static String createJWT() {
    //     String apiKey = 'HjYj1tT5SS6yzSOEFVsBmA';
    //     String secretKey = 'kBc1nBiPpMKVJZvqlU5AMGZ8bpI4OMC3W5uH';
    //     DateTime tokenExpiration = (DateTime) System.today() + 30;
    //     System.debug(tokenExpiration);
    //     System.debug(tokenExpiration.getTime().format());
        
    //     String header = '{ "alg": "HS256","typ": "JWT"}';
    //     header = EncodingUtil.base64Encode(Blob.valueOf(header));
    //     System.debug(header);
        
    //     String payload ='{"iss": "' + apiKey + '","exp": ' + tokenExpiration.getTime().format() +'}';
    //     payload = EncodingUtil.base64Encode(Blob.valueOf(payload));
    //     System.debug(payload);
        
    //     String input = header + '.' + payload;

    //     input = input.replace('+', '-');
    //     input = input.replace('/', '_');
    //     while ( input.endsWith('=')){
    //         input = input.subString(0,input.length()-1);
    //     }

    //     System.debug(input);
        
    //     return 'token';
    // }

     public class ZoomMeeting {
        public String userId;
        public String topic;
        public Integer type;
        public Boolean pre_schedule;
        public Datetime start_time;
        public Integer duration;
        public String schedule_for;
        public String timezone;
        public String password; 
        public Boolean default_password; 
        public String agenda; 
        MeetingRecurrence recurrence = new MeetingRecurrence(); 
        MeetingSettings settings = new MeetingSettings();   
    }

   public class MeetingRecurrence {
        public Integer type;
        public Integer repeat_interval;
        public String weekly_days;
        public Integer monthly_day;
        public Integer monthly_week;
        public Integer monthly_week_day;
        public Integer end_times;
        public Datetime end_date_time;
   }

   public class MeetingSettings {
        public Boolean host_video;
        public Boolean participant_video;
        public Boolean cn_meeting;
        public Boolean in_meeting;
        public Boolean join_before_host;
        public Boolean mute_upon_entry;
        public Boolean watermark;
        public Boolean use_pmi;
        public Integer approval_type;
        public Integer registration_type;
        public String audio;
        public String auto_recording;
        public String alternative_hosts;
        public Boolean waiting_room;
        public Boolean enforce_login;
        public String enforce_login_domains;
    }
}